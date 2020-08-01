CREATE OR REPLACE PACKAGE BODY pkg_load_dw_emp AS

    PROCEDURE load_dw_emp AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE T_EMPLOYEES';

      --Extract data
              INSERT INTO t_employees (
            employee_id,
            contract_num,
            first_name,
            last_name,
            phone_number,
            email,
            insert_dt,
            update_dt
        )
            SELECT
                dw_employee_id_seq.NEXTVAL,
                contract_num,
                first_name,
                last_name,
                phone_number,
                email,
                current_timestamp,
                current_timestamp
            FROM
                dw_cl_employees;

      --Commit Data
              COMMIT;
    END load_dw_emp;

END pkg_load_dw_emp;