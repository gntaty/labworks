CREATE OR REPLACE PACKAGE BODY pkg_etl_ls_attendances AS

    PROCEDURE load_ls_attendances AS

        CURSOR ls_at IS
        SELECT DISTINCT
            date_attendance,
            child_name,
            child_lastname,
            emp_name,
            emp_lastname,
            kindergarten_groups,
            kindergarten,
            service
        FROM
            sa_attendances
        WHERE
            date_attendance IS NOT NULL
            AND child_name IS NOT NULL
            AND child_lastname IS NOT NULL
            AND emp_name IS NOT NULL
            AND emp_lastname IS NOT NULL
            AND kindergarten_groups IS NOT NULL
            AND kindergarten IS NOT NULL
            AND service IS NOT NULL;

    BEGIN
     EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_ls_attendances '
        FOR i IN ls_at LOOP
            INSERT INTO dw_ls_attendances (
                date_attendance,
                child_name,
                child_lastname,
                emp_name,
                emp_lastname,
                group_desc,
                kindergarten_desc,
                service_desc
            ) VALUES (
                i.date_attendance,
                i.child_name,
                i.child_lastname,
                i.emp_name,
                i.emp_lastname,
                i.kindergarten_groups,
                i.kindergarten,
                i.service
            );

            EXIT WHEN ls_at%notfound;
        END LOOP;

        COMMIT;
    END load_ls_attendances;
  -- Execute load_ls_attendances;
END pkg_etl_ls_attendances;