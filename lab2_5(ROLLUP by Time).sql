--ROLLUP by time and type
WITH revenue AS (
    SELECT  /*+ materialize */
                sa.date_attendance,
        to_char(date_attendance, 'MM-YYYY')      AS month,
        trunc(date_attendance, 'Q')               qrt,
        to_char(date_attendance, 'YYYY')         AS year,
        type,
        COUNT(s.service)                          quantity_services,
        COUNT(s.service) * s.service_cost         total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    GROUP BY
        sa.date_attendance,
        to_char(date_attendance, 'MM-YYYY'),
        trunc(date_attendance, 'Q'),
        to_char(date_attendance, 'YYYY'),
        type,
        s.service_cost
)
SELECT
    decode(GROUPING(date_attendance), 1, 'ALL_DAYS', date_attendance)           date_attendance,
    decode(GROUPING(month), 1, 'ALL_MONTS', month)                              month,
    decode(GROUPING(qrt), 1, 'ALL_QRTs', qrt)                                   qrt,
    decode(GROUPING(year), 1, 'ALL_YEARS', year)                                year,
    decode(GROUPING(type), 1, 'ALL TYPE', type)                                   type,
    SUM(quantity_services),
    SUM(total_revenue)
FROM
    revenue
GROUP BY
    GROUPING SETS ( rollup(year),
                    ( qrt ),
                    ( month ),
                    ( date_attendance ),
                    ( type ) );
-- Grouping() function by time and type

WITH revenue AS (
    SELECT  /*+ materialize */
                sa.date_attendance,
        to_char(date_attendance, 'MM-YYYY')      AS month,
        trunc(date_attendance, 'Q')               qrt,
        to_char(date_attendance, 'YYYY')         AS year,
        type,
        COUNT(s.service)                          quantity_services,
        COUNT(s.service) * s.service_cost         total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    GROUP BY
        sa.date_attendance,
        to_char(date_attendance, 'MM-YYYY'),
        trunc(date_attendance, 'Q'),
        to_char(date_attendance, 'YYYY'),
        type,
        s.service_cost
)
SELECT
    decode(GROUPING(date_attendance), 1, 'ALL_DAYS', date_attendance)           date_attendance,
    decode(GROUPING(month), 1, 'ALL_MONTS', month)                              month,
    decode(GROUPING(qrt), 1, 'ALL_QRTs', qrt)                                   qrt,
    decode(GROUPING(year), 1, 'ALL_YEARS', year)                                year,
    decode(GROUPING(type), 1, 'ALL TYPE', type)                                   type,
    SUM(quantity_services),
    SUM(total_revenue)
FROM
    revenue
GROUP BY
    GROUPING SETS ( rollup(year),
                    ( qrt ),
                    ( month ),
                    ( date_attendance ),
                    ( type ) );
-- Grouping_ID function
WITH revenue AS (
    SELECT  /*+ materialize */
                sa.date_attendance,
        to_char(date_attendance, 'MM-YYYY')      AS month,
        trunc(date_attendance, 'Q')               qrt,
        to_char(date_attendance, 'YYYY')         AS year,
        type,
        COUNT(s.service)                          quantity_services,
        COUNT(s.service) * s.service_cost         total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    GROUP BY
        sa.date_attendance,
        to_char(date_attendance, 'MM-YYYY'),
        trunc(date_attendance, 'Q'),
        to_char(date_attendance, 'YYYY'),
        type,
        s.service_cost
)
SELECT
    decode(GROUPING(date_attendance), 1, 'ALL_DAYS', date_attendance)           date_attendance,
    decode(GROUPING(month), 1, 'ALL_MONTS', month)                              month,
    decode(GROUPING(qrt), 1, 'ALL_QRTs', qrt)                                   qrt,
    decode(GROUPING(year), 1, 'ALL_YEARS', year)                                year,
    decode(GROUPING(type), 1, 'ALL TYPE', type)                                   type,
    SUM(quantity_services),
    SUM(total_revenue),
    GROUPING_ID(year, qrt, month, date_attendance, type)                            gr_id
FROM
    revenue
GROUP BY
    GROUPING SETS ( rollup(year),
                    ( qrt ),
                    ( month ),
                    ( date_attendance ),
                    ( type ) )
HAVING
    GROUPING_ID(year, qrt, month, date_attendance, type) = 27;--to show result by qrts       