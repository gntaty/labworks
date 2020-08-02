DROP MATERIALIZED VIEW revenue_dd;

DROP MATERIALIZED VIEW revenue_mm;

DROP MATERIALIZED VIEW model_report;

CREATE MATERIALIZED VIEW revenue_mm
    REFRESH
        COMPLETE
        ON DEMAND
AS
    ( SELECT
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day))
        || '-'
        || to_char(EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM child_birht_day) + 1)            age_range,
        COUNT(distinct sa.attendance_num)                                                                                quantity_services,
       COUNT(distinct sa.attendance_num) * s.service_cost                                                               total_revenue
    FROM
             sa_attendances sa
        INNER JOIN sa_contracts     ch ON ch.child_lastname = sa.child_lastname
                                      AND ch.child_name = sa.child_name
        INNER JOIN sa_kindergarten  k ON k.kindergarten = sa.kindergarten
                                        AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN sa_service_type  s ON s.service = sa.service
    WHERE
        to_char(date_attendance, 'MM-YYYY') IN (
            SELECT
                MAX(to_char(date_attendance, 'MM-YYYY'))
            FROM
                sa_attendances
        )
    GROUP BY
        k.country,
        k.kindergarten,
        s.service,
        s.type,
        s.service_cost,
        child_birht_day
    );

EXECUTE dbms_mview.refresh('REVENUE_MM', '?', '', true, false,0, 0, 0, false, false);
/*(list of mat.views,refresh method: ?-forse,rollback segment to use,refresh
after errors:true,replication process for warehouse:false,0,0,0;atomic refresh:
false;out_of_place refresh: false(works with method)*/

ALTER TABLE sa_attendances ADD PRIMARY KEY ( attendance_num );

CREATE MATERIALIZED VIEW revenue_dd
    REFRESH
        COMPLETE
        ON COMMIT
AS
    SELECT 
        sa.kindergarten,
        sa.service,
        COUNT( sa.attendance_num) quantity_services
    FROM
             sa_attendances sa
    GROUP BY
        sa.kindergarten,
        sa.service;

CREATE MATERIALIZED VIEW model_report
    REFRESH
        COMPLETE
        ON DEMAND
        START WITH SYSDATE NEXT (current_timestamp + 1/720)
ENABLE QUERY REWRITE AS
    SELECT DISTINCT
        country,
        total_revenue,
        quantity_services
    FROM
        revenue_mm
    MODEL
        UNIQUE SINGLE REFERENCE
        DIMENSION BY ( country )
        MEASURES ( total_revenue,
                   quantity_services )
        RULES
        ( total_revenue[
            FOR country IN (
                SELECT DISTINCT
                    country
                FROM
                    revenue_mm
            )
        ]= SUM ( total_revenue )[cv(country)],
        quantity_services[
            FOR country IN (
                SELECT DISTINCT
                    country
                FROM
                    revenue_mm
            )
        ]= SUM ( quantity_services )[cv(country)]);

SELECT mv_name,collection_level,retention_period 
FROM DBA_MVREF_STATS_PARAMS;
