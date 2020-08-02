/* group by cube*/
WITH revenue AS (
    SELECT  /*+ materialize */ /*+ gather_plan_statistics */ 
                        sa.date_attendance,
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)            age_range,
        COUNT(s.service)                                                                                quantity_services,
        COUNT(s.service) * s.service_cost                                                               total_revenue
    FROM
             sa_attendances sa
        INNER JOIN sa_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN sa_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN sa_service_type     s ON s.service = sa.service
    WHERE
        sa.date_attendance IN (
            SELECT
                MAX(date_attendance)
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
SELECT
    country,
    kindergarten,
    type,
    age_range,
    SUM(quantity_services),
    SUM(total_revenue)
FROM
    revenue
GROUP BY
    age_range,
    CUBE(country,
         TYPE,
         kindergarten);
-- grouping() clause
WITH revenue AS (
    SELECT  /*+ materialize */
                        sa.date_attendance,
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)            age_range,
        COUNT(s.service)                                                                                quantity_services,
        COUNT(s.service) * s.service_cost                                                               total_revenue
    FROM
             sa_attendances sa
        INNER JOIN sa_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN sa_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN sa_service_type     s ON s.service = sa.service
    WHERE
        sa.date_attendance IN (
            SELECT
                MAX(date_attendance)
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
SELECT
    decode(GROUPING(country), 1, 'ALL COUNTRIES', country)                        country,
    decode(GROUPING(kindergarten), 1, 'All KINDERGARTEN', kindergarten)           kindergarten,
    decode(GROUPING( age_range), 1, 'All AGE',  age_range)           age_range,
    decode(GROUPING(TYPE), 1, 'ALL TYPE', TYPE)                          TYPE,
    SUM(quantity_services),
    SUM(total_revenue)
FROM
    revenue
GROUP BY
   age_range,
    CUBE(country,
         TYPE,
         kindergarten);
--grouping_id 
WITH revenue AS (
    SELECT  /*+ materialize */
                        sa.date_attendance,
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)            age_range,
        COUNT(s.service)                                                                                quantity_services,
        COUNT(s.service) * s.service_cost                                                               total_revenue
    FROM
             sa_attendances sa
        INNER JOIN sa_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN sa_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN sa_service_type     s ON s.service = sa.service
    WHERE
        sa.date_attendance IN (
            SELECT
                MAX(date_attendance)
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
SELECT
    decode(GROUPING(country), 1, 'ALL COUNTRIES', country)                        country,
    decode(GROUPING(kindergarten), 1, 'All KINDERGARTEN', kindergarten)           kindergarten,
    type,
    decode(GROUPING(age_range), 1, 'ALL AGE', age_range)                          age_range,
    SUM(quantity_services),
    SUM(total_revenue),
    GROUPING_ID(country, age_range, kindergarten)                                 gr_id
FROM
    revenue
GROUP BY
    type,
    CUBE(country,
         age_range,
         kindergarten)
HAVING
    GROUPING_ID(country, age_range, kindergarten) = 3;--to show result by countries