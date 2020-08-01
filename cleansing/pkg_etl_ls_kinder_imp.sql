CREATE OR REPLACE PACKAGE BODY pkg_etl_ls_kinder AS

    PROCEDURE load_ls_kinder AS

        CURSOR ls_at IS
        SELECT DISTINCT
            kindergarten,
            address,
            city,
            country,
            kindergarten_groups,
            group_scale,
            group_num
        FROM
            sa_kindergarten
        WHERE
            kindergarten IS NOT NULL
            AND group_num IS NOT NULL
            AND address IS NOT NULL
            AND city IS NOT NULL
            AND country IS NOT NULL
            AND kindergarten_groups IS NOT NULL
            AND group_scale IS NOT NULL;

    BEGIN
     EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_ls_groups';
        FOR i IN ls_at LOOP
            INSERT INTO dw_ls_groups (
                group_num,
                group_desc,
                group_scale,
                kindergarten_desc,
                address,
                city,
                country
            ) VALUES (
                i.group_num,
                i.kindergarten_groups,
                i.group_scale,
                i.kindergarten,
                i.address,
                i.city,
                i.country
            );

            EXIT WHEN ls_at%notfound;
        END LOOP;

        COMMIT;
    END load_ls_kinder;

END pkg_etl_ls_kinder;