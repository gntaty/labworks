CREATE OR REPLACE PACKAGE BODY pkg_etl_ls_emp AS

    PROCEDURE load_ls_employees AS
    DECLARE     
        CURSOR ls_at IS
        SELECT DISTINCT
            date_of_contract,
            contract_num,
            emp_name,
            emp_lastname,
            phone_number,
            email
        FROM
            sa_emp_contracts
        WHERE
            date_of_contract IS NOT NULL
            AND contract_num IS NOT NULL
            AND emp_name IS NOT NULL
            AND emp_lastname IS NOT NULL;
            LS_row ls_at%ROWTYPE;

    BEGIN
     EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_cl_employees ';
        FOR i IN ls_at LOOP
            INSERT INTO dw_cl_employees (
                date_of_contract,
                contract_num,
                first_name,
                last_name,
                phone_number,
                email
            ) VALUES (
                i.date_of_contract,
                i.contract_num,
                i.emp_name,
                i.emp_lastname,
                i.phone_number,
                i.email
            );

            EXIT WHEN ls_at%notfound;
        END LOOP;

        COMMIT;
    END load_ls_employees;

END pkg_etl_ls_emp;