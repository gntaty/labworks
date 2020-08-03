CREATE OR REPLACE PACKAGE BODY pkg_etl_ls_attendances AS

    PROCEDURE load_ls_attendances AS
    BEGIN
    DECLARE
        CURSOR ls_at IS
        SELECT DISTINCT
            ATTENDANCE_NUM,
            date_attendance,
            sch.contract_num child_contract,
            sch.child_name,
            sch.child_lastname,
            emp.contract_num emp_contract,
            emp.emp_name,
            emp.emp_lastname,
            k.group_num,
            k.kindergarten_groups,
            k.kindergarten,
            k.country,
            sa.service_code
        FROM
            sa_attendances sa
            inner join sa_contracts sch on sch.child_name=sa.child_name and sch.child_lastname=sa.child_lastname
            inner join sa_emp_contracts emp on emp.emp_name=sa.emp_name and emp.emp_lastname=sa.emp_lastname
            inner join sa_kindergarten k on k.kindergarten_groups=sa.kindergarten_groups and k.kindergarten=sa.kindergarten;

    Begin
     EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_ls_attendances ';
        FOR i IN ls_at LOOP
            INSERT INTO  dw_ls_attendances (
                ATTENDANCE_NUM,
                date_attendance,
                child_contract,
                child_name,
                child_lastname,
                emp_contract,
                emp_name,
                emp_lastname,
                group_num,
                group_desc,
                kindergarten_desc,
                country,
                service_code
            ) VALUES (
           i.ATTENDANCE_NUM,
         i.date_attendance,
           i.child_contract,
            i.child_name,
            i.child_lastname,
            i.emp_contract,
            i.emp_name,
            i.emp_lastname,
            i.group_num,
            i.kindergarten_groups,
            i.kindergarten,
            i.country,
            i.service_code
          );

   EXIT WHEN ls_at%notfound;
            END LOOP;
 COMMIT;
 end;
    END load_ls_attendances;

END pkg_etl_ls_attendances;

            

