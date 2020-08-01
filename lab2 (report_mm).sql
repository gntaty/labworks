/*USE: ROLLUP or GROUPING SETS Extension*/
with revenue_mm as(
SELECT  /*+ materialize */
        k.country
        ,k.kindergarten
        ,s.service
        ,s.type
        ,to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)     age_range
        ,COUNT(s.service)                                                                         quantity_services
        ,COUNT(s.service) * s.service_cost                                                        total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    where TO_CHAR( date_attendance, 'MM-YYYY')
IN (
           SELECT
               max( TO_CHAR( date_attendance, 'MM-YYYY')) 
           FROM
                sa_attendances
        )
    GROUP BY
        sa.date_attendance,
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        s.service_cost,
        child_birht_day
)
select 
        decode(grouping(country),1,'TOTAL BY COUNTRIES',country)country
        ,decode(grouping(kindergarten),1,'TOTAL BY KINDERGARTENS',kindergarten)kindergarten
        ,decode (grouping(type),1,'TOTAL BY TYPE',type)type 
        ,SUM(quantity_services)
        ,SUM(total_revenue)
FROM revenue_mm
GROUP BY ROLLUP(COUNTRY,KINDERGARTEN,TYPE);

/*USE: Grouping() function */
with revenue_mm as(
SELECT  /*+ materialize */
        k.country
        ,k.kindergarten
        ,s.service
        ,s.type
        ,to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)     age_range
        ,COUNT(s.service)                                                                         quantity_services
        ,COUNT(s.service) * s.service_cost                                                        total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    where TO_CHAR( date_attendance, 'MM-YYYY')
IN (
           SELECT
               max( TO_CHAR( date_attendance, 'MM-YYYY')) 
           FROM
                sa_attendances
        )
    GROUP BY
        sa.date_attendance,
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        s.service_cost,
        child_birht_day
)
select 
        decode(grouping(country),1,'TOTAL BY COUNTRIES',country)country
        ,decode(grouping(kindergarten),1,'TOTAL BY KINDERGARTENS',kindergarten)kindergarten
        ,decode (grouping(type),1,'TOTAL BY TYPE',type)type 
        ,age_range
        ,SUM(quantity_services)
        ,SUM(total_revenue)
FROM revenue_mm
GROUP BY age_range, ROLLUP(COUNTRY,KINDERGARTEN,TYPE);

with revenue_mm as(
SELECT  /*+ materialize */
        k.country
        ,k.kindergarten
        ,s.service
        ,s.type
        ,to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)     age_range
        ,COUNT(s.service)                                                                         quantity_services
        ,COUNT(s.service) * s.service_cost                                                        total_revenue
    FROM
             sa_attendances sa
        INNER JOIN sa_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN sa_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN sa_service_type     s ON s.service = sa.service
    where TO_CHAR( date_attendance, 'MM-YYYY')
IN (
           SELECT
               max( TO_CHAR( date_attendance, 'MM-YYYY')) 
           FROM
                sa_attendances
        )
    GROUP BY
        sa.date_attendance,
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        s.service_cost,
        child_birht_day
)
select 
        decode(grouping(country),1,'TOTAL BY COUNTRIES',country)country
        ,decode(grouping(kindergarten),1,'TOTAL BY KINDERGARTENS',kindergarten)kindergarten
        ,decode (grouping(type),1,'TOTAL BY TYPE',type)type 
        ,SUM(quantity_services)
        ,SUM(total_revenue)
FROM revenue_mm
GROUP BY ROLLUP(COUNTRY,KINDERGARTEN,TYPE);

with revenue_mm as(
SELECT  /*+ materialize */
        k.country
        ,k.kindergarten
        ,s.service
        ,s.type
        ,to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)     age_range
        ,COUNT(s.service)                                                                         quantity_services
        ,COUNT(s.service) * s.service_cost                                                        total_revenue
    FROM
             sa_attendances sa
        INNER JOIN sa_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN sa_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN sa_service_type     s ON s.service = sa.service
    where TO_CHAR( date_attendance, 'MM-YYYY')
IN (
           SELECT
               max( TO_CHAR( date_attendance, 'MM-YYYY')) 
           FROM
                sa_attendances
        )
    GROUP BY
        sa.date_attendance,
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        s.service_cost,
        child_birht_day
)
select 
        decode(GROUPING(country), 1, 'ALL COUNTRIES', country)                        country,
    decode(GROUPING(kindergarten), 1, 'All KINDERGARTEN', kindergarten)           kindergarten,
    DECODE (GROUPING(TYPE),1,'ALL TYPE',TYPE) TYPE,
    decode(GROUPING(age_range), 1, 'ALL AGE', age_range)                         age_range,
    GROUPING_ID(country, age_range, kindergarten,type)                                 gr_id,
    SUM(quantity_services),
    SUM(total_revenue)
FROM
    revenue_mm
GROUP BY
    CUBE(country,
         age_range,
         TYPE,
         kindergarten)
HAVING
    GROUPING_ID(country, age_range, kindergarten,type) = 7;--to show result by countries;
