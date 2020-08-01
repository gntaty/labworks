CREATE OR REPLACE PACKAGE BODY pkg_etl_dim_emp AS

    PROCEDURE etl_dim_emp AS
    BEGIN
      --truncate cleansing tables
              EXECUTE IMMEDIATE 'TRUNCATE TABLE DIM_EMPLOYEES';

      --Extract data
              INSERT INTO dim_employees (
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
                employee_id,
                contract_num,
                first_name,
                last_name,
                phone_number,
                email,
                current_timestamp,
                current_timestamp
            FROM
                t_employees;

      --Commit Data
              COMMIT;
    END etl_dim_emp;

END pkg_etl_dim_emp;