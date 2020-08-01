create or REPLACE view location as
(select *
FROM(WITH h_reg AS (
    SELECT
        path,
        part,
        CASE
            WHEN leaf = 1 THEN
                parent_geo_id
            ELSE
                region
        END region,
        country,
        geo_type_desc
    FROM
        (
            SELECT
                level,
                PRIOR parent_geo_id                                         par_all,
                parent_geo_id,
                child_geo_id,
                ltrim(sys_connect_by_path(child_geo_id, '-'), '-')          path,
                decode(level, 2, child_geo_id)                              region,
                decode(level, 3, child_geo_id)                              country,
                CONNECT_BY_ROOT child_geo_id                                part,
                CONNECT_BY_ISLEAF                                           leaf,
                geo_type_desc
            FROM
                (
                    SELECT
                        l.parent_geo_id              parent_geo_id,
                        l.child_geo_id               child_geo_id,
                        t_geo_types.geo_type_code    geo_type_desc
                    FROM
                             t_geo_object_links l
                        INNER JOIN u_dw_references.t_geo_objects t ON l.child_geo_id = t.geo_id
                        INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                    WHERE
                        l.link_type_id IN ( 1, 2, 3 )
                ) t1
            CONNECT BY
                parent_geo_id = PRIOR child_geo_id
            ORDER SIBLINGS BY
                child_geo_id
        ) t2
), h_group AS (
    SELECT
        path,
        country_group,
        CASE
            WHEN leaf = 1 THEN
                parent_geo_id
            ELSE
                country_sub_group
        END country_sub_group,
        country,
        geo_type_desc
    FROM
        (
            SELECT
                parent_geo_id,
                child_geo_id,
                ltrim(sys_connect_by_path(child_geo_id, '-'), '-')          path,
                decode(level, 2, child_geo_id)                              country_sub_group,
                decode(level, 3, child_geo_id)                              country,
                CONNECT_BY_ROOT child_geo_id                                country_group,
                CONNECT_BY_ISLEAF                                           leaf,
                geo_type_desc
            FROM
                (
                    SELECT
                        l.parent_geo_id              parent_geo_id,
                        l.child_geo_id               child_geo_id,
                        t_geo_types.geo_type_code    geo_type_desc
                    FROM
                             t_geo_object_links l
                        INNER JOIN u_dw_references.t_geo_objects t ON l.child_geo_id = t.geo_id
                        INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                    WHERE
                        l.link_type_id IN ( 4, 5, 6 )
                ) t1
            CONNECT BY
                parent_geo_id = PRIOR child_geo_id
            ORDER SIBLINGS BY
                child_geo_id
        ) t2
)
SELECT
    c.country_id                        country_id,
    c.country_code_a2                   country_code_a2,
    c.country_code_a3                   country_code_a3,
    c.country_desc                      country_desc,
    r.region_id                         region_id,
    r.region_code                       region_code,
    r.region_desc                       region_desc,
    COUNT(*)
    OVER(PARTITION BY region_id)        region_childs,
    p.part_id                           part_id,
    p.part_code                         part_code,
    p.part_desc                         part_desc,
    COUNT(DISTINCT region_id)
    OVER(PARTITION BY part_id)          part_childs,
    g.sub_group_id                      sub_group_id,
    g.sub_group_code                    sub_group_code,
    g.sub_group_desc                    sub_group_desc,
    COUNT(*)
    OVER(PARTITION BY sub_group_id)     sub_group_childs,
    g1.group_id                         group_id,
    g1.group_code                       group_code,
    g1.group_desc                       group_desc,
    COUNT(DISTINCT sub_group_id)
    OVER(PARTITION BY group_id)         group_childs
FROM
         h_group
    INNER JOIN lc_countries        c ON country = c.geo_id
    INNER JOIN lc_cntr_sub_groups  g ON h_group.country_sub_group = g.geo_id
    INNER JOIN lc_cntr_groups      g1 ON h_group.country_group = g1.geo_id
    RIGHT JOIN h_reg ON h_reg.country = h_group.country
    INNER JOIN lc_geo_regions      r ON region = r.geo_id
    INNER JOIN lc_geo_parts        p ON part = p.geo_id
WHERE
    h_group.geo_type_desc = 'COUNTRY'
UNION
SELECT
    c.country_id                        country_id,
    c.country_code_a2                   country_code_a2,
    c.country_code_a3                   country_code_a3,
    c.country_desc                      country_desc,
    r.region_id                         region_id,
    r.region_code                       region_code,
    r.region_desc                       region_desc,
    COUNT(*)
    OVER(PARTITION BY region_id)        region_childs,
    p.part_id                           part_id,
    p.part_code                         part_code,
    p.part_desc                         part_desc,
    COUNT(DISTINCT region_id)
    OVER(PARTITION BY part_id)          part_childs,
    g.sub_group_id                      sub_group_id,
    g.sub_group_code                    sub_group_code,
    g.sub_group_desc                    sub_group_desc,
    COUNT(*)
    OVER(PARTITION BY sub_group_id)     sub_group_childs,
    g1.group_id                         group_id,
    g1.group_code                       group_code,
    g1.group_desc                       group_desc,
    COUNT(DISTINCT sub_group_id)
    OVER(PARTITION BY group_id)         group_childs
FROM
         h_group
    INNER JOIN lc_countries        c ON country = c.geo_id
    INNER JOIN lc_cntr_sub_groups  g ON h_group.country_sub_group = g.geo_id
    INNER JOIN lc_cntr_groups      g1 ON h_group.country_group = g1.geo_id
    RIGHT JOIN h_reg ON h_reg.country = h_group.country
    INNER JOIN lc_geo_regions      r ON region = r.geo_id
    INNER JOIN lc_geo_parts        p ON part = p.geo_id
WHERE
    h_group.geo_type_desc = 'COUNTRY'
UNION ALL
SELECT
    c.country_id                     country_id,
    c.country_code_a2                country_code_a2,
    c.country_code_a3                country_code_a3,
    c.country_desc                   country_desc,
    r.region_id                      region_id,
    r.region_code                    region_code,
    r.region_desc                    region_desc,
    COUNT(*)
    OVER(PARTITION BY region_id)     region_childs,
    p.part_id                        part_id,
    p.part_code                      part_code,
    p.part_desc                      part_desc,
    COUNT(DISTINCT region_id)
    OVER(PARTITION BY part_id)       part_childs,
    NULL                             sub_group_id,
    NULL                             sub_group_code,
    NULL                             sub_group_desc,
    NULL                             sub_group_childs,
    NULL                             group_id,
    NULL                             group_code,
    NULL                             group_desc,
    NULL                             group_childs
FROM
         h_reg
    INNER JOIN lc_countries    c ON country = c.geo_id
    INNER JOIN lc_geo_regions  r ON region = r.geo_id
    INNER JOIN lc_geo_parts    p ON part = p.geo_id
WHERE
    h_reg.geo_type_desc = 'COUNTRY'));