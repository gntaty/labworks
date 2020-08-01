CREATE OR REPLACE PACKAGE BODY pkg_etl_ls_children AS

    PROCEDURE load_ls_children AS
        declare
        CURSOR ls_at IS
        SELECT DISTINCT
            date_of_contract,
            contract_num,
            child_name,
            child_lastname,
            gender,
            phone_number,
            parent_name1,
            parent_lastname1,
            parent_name2,
            parent_lastname2,
            child_birht_day
        FROM
            sa_contracts
        WHERE
            date_of_contract IS NOT NULL
            AND contract_num IS NOT NULL
            AND child_name IS NOT NULL
            AND child_lastname IS NOT NULL
            AND gender IS NOT NULL
            AND phone_number IS NOT NULL
            AND parent_name1 IS NOT NULL
            AND parent_lastname1 IS NOT NULL
            AND child_birht_day IS NOT NULL;
        LS_row ls_at%ROWTYPE;
    BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_cl_children';
        FOR i IN ls_at LOOP
            INSERT INTO dw_cl_children (
                date_of_contract,
                contract_num,
                first_name,
                last_name,
                gender,
                phone_number,
                parent_name_1,
                parent_lastname_1,
                parent_name_2,
                parent_lastname_2,
                date_of_birth
            ) VALUES (
                i.date_of_contract,
                i.contract_num,
                i.child_name,
                i.child_lastname,
                i.gender,
                i.phone_number,
                i.parent_name1,
                i.parent_lastname1,
                i.parent_name2,
                i.parent_lastname2,
                i.child_birht_day
            );

            EXIT WHEN ls_at%notfound;
        END LOOP;

        COMMIT;
    END load_ls_children;
  -- Execute load_ls_attendances;
END pkg_etl_ls_children;