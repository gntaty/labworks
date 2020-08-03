drop table data_excel;
drop table sa_kindergarten;
drop table sa_service_type;
drop sequence kindergarten_id_seq;
drop table sa_contracts;
drop table sa_emp_contracts; 
drop table sa_attendances;
drop sequence sa_contract_id_seq;
drop sequence sa_emp_contract_id_seq;
drop sequence sa_kindergarten_id_seq;
--drop sequence sa_emp_contract_id_seq;


create table data_excel(  -- import data from name.xlsx (name, surname, gender) to generate data about children, parents, employees
first_name  NVARCHAR2(50),
last_name   NVARCHAR2(50),
gender      NVARCHAR2(6)
) tablespace ts_sa_attendances;

create table sa_kindergarten( --import data from groups.xlsx to generate data about groups, kindergartens and locations
kindergarten        NVARCHAR2(100),
address             NVARCHAR2(100),
city                NVARCHAR2(100),
country             NVARCHAR2(100),
kindergarten_groups NVARCHAR2(50),
group_scale int);
ALTER TABLE sa_kindergarten MOVE TABLESPACE ts_sa_attendances; 

CREATE SEQUENCE sa_kindergarten_id_seq; 
ALTER TABLE sa_kindergarten ADD (group_num NUMBER);
UPDATE sa_kindergarten SET group_num = sa_kindergarten_id_seq.NEXTVAL;

create table sa_service_type( -- import data from services.xlxs to generate data about services 
sevice_code     number,
service        NVARCHAR2(50),
type            NVARCHAR2(50),
service_cost    float);
ALTER TABLE sa_service_type MOVE TABLESPACE ts_sa_attendances;

create table sa_contracts as --generate data about children and their parents
select 
        date_of_contract
        ,child_name
        , child_lastname
        , gender
        , phone_number
        , parent_name1
        , parent_lastname1
        , parent_name2
        , parent_lastname2
        ,child_birht_day
from (select 
TO_DATE(
              TRUNC(
                   DBMS_RANDOM.VALUE(TO_CHAR(DATE '2016-01-01','J')
                                    ,TO_CHAR(DATE '2020-12-31','J')
                                    )
                    ),'J') date_of_contract 
        ,c.first_name child_name
        ,b.last_name child_lastname
        ,c.gender
        ,ROUND(dbms_random.value(100000000000, 999999999999)) phone_number
        ,b.first_name  parent_name1
        ,b.last_name  parent_lastname1
        ,a.first_name  parent_name2
        ,b.last_name  parent_lastname2
        ,TO_DATE(
              TRUNC(
                   DBMS_RANDOM.VALUE(TO_CHAR(DATE '2014-01-01','J')
                                    ,TO_CHAR(DATE '2018-12-31','J')
                                    )
                    ),'J') child_birht_day
        ,row_number() over(ORDER BY dbms_random.value) rn
from 
data_excel a
,data_excel b
,data_excel c)
where rn< 5001;

CREATE SEQUENCE sa_contract_id_seq; 
ALTER TABLE sa_contracts MOVE TABLESPACE ts_sa_attendances;
ALTER TABLE sa_contracts ADD (contract_num NUMBER);
UPDATE sa_contracts SET contract_num = sa_contract_id_seq.NEXTVAL;

create table sa_emp_contracts as --generate data about employees
SELECT
    date_of_contract
    ,emp_name
    ,emp_lastname
    ,phone_number
    ,email
FROM(select
        TO_DATE(
              TRUNC(
                   DBMS_RANDOM.VALUE(TO_CHAR(DATE '2016-01-01','J')
                                    ,TO_CHAR(DATE '2020-12-31','J')
                                    )
                    ),'J') date_of_contract 
        ,a.first_name emp_name
        ,b.last_name emp_lastname
        ,ROUND(dbms_random.value(100000000000, 999999999999)) phone_number
        ,lower(substr(a.first_name,0,1))||lower(a.last_name)||'@gmail.com' email
        ,row_number() over(ORDER BY dbms_random.value) rn
from data_excel a,data_excel b) sub
where rn<1501
;
CREATE SEQUENCE sa_emp_contract_id_seq;
ALTER TABLE sa_emp_contracts MOVE TABLESPACE ts_sa_attendances;
ALTER TABLE sa_emp_contracts ADD (contract_num NUMBER);
UPDATE sa_emp_contracts SET contract_num = sa_emp_contract_id_seq.NEXTVAL;

create table sa_attendances as --generate data about provided services
WITH cte_rnd AS (
    SELECT /* +MATERIALIZE*/
    rownum 
    ,TO_DATE(
              TRUNC(
                   DBMS_RANDOM.VALUE(TO_CHAR(DATE '2016-01-01','J')
                                    ,TO_CHAR(DATE '2020-12-31','J')
                                    )
                    ),'J') date_attendance
        ,floor(dbms_random.value(1, 50000)) contract_num
        ,floor(dbms_random.value(1, 1500)) emp_contract_num
        ,floor(dbms_random.value(1, 100))group_num
        ,floor(dbms_random.value(1000, 1080))service_code
FROM
        dual
    CONNECT BY
        level < 4000000 ) 
select  rownum attendance_num
        ,date_attendance
        ,child_name
        ,child_lastname
        ,emp_name
        ,emp_lastname
        ,kindergarten_groups
        ,kindergarten
        ,a.service_code
from cte_rnd a
inner join sa_contracts b on a.contract_num=b.contract_num
inner join sa_emp_contracts c on a.emp_contract_num = c.contract_num
inner join sa_kindergarten q on q.group_num=a.group_num
inner join sa_service_type y  ON y.sevice_code = a.service_code;
        
ALTER TABLE sa_attendances MOVE TABLESPACE ts_sa_attendances;        
