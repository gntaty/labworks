CREATE OR REPLACE PACKAGE BODY pkg_etl_ls_serv AS

    PROCEDURE load_ls_services AS
    BEGIN
        DECLARE
            CURSOR ls_at IS
            SELECT distinct
                sevice_code,
               service,
                type,
                service_cost
            FROM
                sa_service_type
            WHERE
                service IS NOT NULL
                AND type IS NOT NULL
                AND service_cost IS NOT NULL;

        BEGIN
            EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_ls_services';
            FOR i IN ls_at LOOP
                INSERT INTO dw_ls_services (
                    service_code,
                    service_desc,
                    type_desc,
                    service_cost
                ) VALUES (
                    i.sevice_code,
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