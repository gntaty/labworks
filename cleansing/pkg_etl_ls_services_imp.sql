CREATE OR REPLACE PACKAGE BODY pkg_etl_ls_serv AS procedure load_ls_services as 
declare
    cursor ls_at IS
    SELECT DISTINCT
        active_date,
        service,
        type,
        service_cost
    FROM
        sa_service_type
    WHERE
        active_date IS NOT NULL
        AND service IS NOT NULL
            AND type IS NOT NULL
                AND service_cost IS NOT NULL;
    ls_row ls_at%rowtype;
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_ls_services';
    FOR i IN ls_at LOOP
        INSERT INTO dw_ls_services (
            start_date,
            service_desc,
            type_desc,
            service_cost
        ) VALUES (
            i.active_date,
            i.service,
            i.type,
            i.service_cost
        );

        EXIT WHEN ls_at%notfound;
    END LOOP;

    COMMIT;
    END;
END load_ls_services;
END pkg_etl_ls_serv;