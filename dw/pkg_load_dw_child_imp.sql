CREATE OR REPLACE PACKAGE BODY pkg_load_dw_child AS

    PROCEDURE load_dw_child AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE t_children';
      --Extract data
                            INSERT INTO t_children (
            child_id,
            date_of_contract,
            contract_num,
            first_name,
            last_name,
            gender,
            parent_name_1,
            parent_lastname_1,
            parent_name_2,
            parent_lastname_2,
            date_of_birth,
            phone_number,
            insert_dt,
            update_dt
        )
            SELECT
                dw_children_id_seq.NEXTVAL,
                date_of_contract,
                contract_num,
                first_name,
                last_name,
                gender,
                parent_name_1,
                parent_lastname_1,
                parent_name_2,
                parent_lastname_2,
                date_of_birth,
                phone_number,
                current_timestamp,
                current_timestamp
            FROM
                dw_cl_children;

      --Commit Data
                        COMMIT;
    END load_dw_child;

END pkg_load_dw_child;