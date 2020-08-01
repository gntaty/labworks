CREATE OR REPLACE PACKAGE BODY pkg_etl_dim_child AS

    PROCEDURE etl_dim_child AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DIM_CHILDREN';
        DECLARE
            TYPE var_cur IS
                TABLE OF VARCHAR2(50);
            TYPE num_cur IS
                TABLE OF NUMBER;
            TYPE date_cur IS
                TABLE OF DATE;
            TYPE all_cur IS REF CURSOR;
            ls_at              all_cur;
            child_id           num_cur;
            date_of_contract   date_cur;
            contract_num       num_cur;
            first_name         var_cur;
            last_name          var_cur;
            gender             var_cur;
            parent_name_1      var_cur;
            parent_lastname_1  var_cur;
            parent_name_2      var_cur;
            parent_lastname_2  var_cur;
            date_of_birth      var_cur;
            phone_number       var_cur;
        BEGIN
            OPEN ls_at FOR SELECT DISTINCT
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
                               phone_number
                           FROM
                               t_children;

            FETCH ls_at BULK COLLECT INTO
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
                phone_number;

            CLOSE ls_at;
            FORALL i IN child_id.first..child_id.last
                INSERT INTO dim_children (
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
                ) VALUES (
                    child_id(i),
                    date_of_contract(i),
                    contract_num(i),
                    first_name(i),
                    last_name(i),
                    gender(i),
                    parent_name_1(i),
                    parent_lastname_1(i),
                    parent_name_2(i),
                    parent_lastname_2(i),
                    date_of_birth(i),
                    phone_number(i),
                    current_timestamp,
                    current_timestamp
                );

            COMMIT;
        END;

    END etl_dim_child;

END pkg_etl_dim_child;