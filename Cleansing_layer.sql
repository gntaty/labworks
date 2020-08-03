DROP TABLE dw_cl_children;

DROP TABLE dw_cl_employees;

DROP TABLE dw_ls_groups;

DROP TABLE dw_ls_services;

DROP TABLE dw_ls_attendances;

DROP TABLE dw_cl_md_children;

DROP TABLE dw_cl_md_employees;

DROP TABLE dw_ls_md_groups;

DROP TABLE dw_ls_md_services;

DROP TABLE dw_ls_md_attendances;

CREATE TABLE dw_cl_children (
    date_of_contract   DATE NOT NULL,
    contract_num       NUMBER NOT NULL,
    first_name         NVARCHAR2(50) NOT NULL,
    last_name          NVARCHAR2(50) NOT NULL,
    gender             CHAR(6) NOT NULL,
    parent_name_1      NVARCHAR2(50) NOT NULL,
    parent_lastname_1  NVARCHAR2(50) NOT NULL,
    parent_name_2      NVARCHAR2(50) NULL,
    parent_lastname_2  NVARCHAR2(50) NULL,
    date_of_birth      DATE NOT NULL,
    phone_number       NVARCHAR2(50) NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_cl_md_children (
    date_of_contract   DATE NOT NULL,
    contract_num       NUMBER NOT NULL,
    first_name         NVARCHAR2(50) NOT NULL,
    last_name          NVARCHAR2(50) NOT NULL,
    gender             CHAR(6) NOT NULL,
    parent_name_1      NVARCHAR2(50) NOT NULL,
    parent_lastname_1  NVARCHAR2(50) NOT NULL,
    parent_name_2      NVARCHAR2(50) NULL,
    parent_lastname_2  NVARCHAR2(50) NULL,
    date_of_birth      DATE NOT NULL,
    phone_number       NVARCHAR2(50) NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_cl_employees (
    date_of_contract  DATE NOT NULL,
    contract_num      NUMBER NOT NULL,
    first_name        NVARCHAR2(50) NOT NULL,
    last_name         NVARCHAR2(50) NOT NULL,
    phone_number      NVARCHAR2(50) NULL,
    email             NVARCHAR2(50) NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_cl_md_employees (
    date_of_contract  DATE NOT NULL,
    contract_num      NUMBER NOT NULL,
    first_name        NVARCHAR2(50) NOT NULL,
    last_name         NVARCHAR2(50) NOT NULL,
    phone_number      NVARCHAR2(50) NULL,
    email             NVARCHAR2(50) NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_ls_groups (
    group_num          NUMBER NOT NULL,
    group_desc         NVARCHAR2(50) NOT NULL, --kindergarten_groups
            group_scale        NUMBER(*, 0) NOT NULL,
    kindergarten_desc  NVARCHAR2(50) NOT NULL,--kindergarten
            address            NVARCHAR2(100) NOT NULL,
    city               NVARCHAR2(50) NOT NULL,
    country            NVARCHAR2(50) NOT NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_ls_md_groups (
    group_num          NUMBER NOT NULL,
    group_desc         NVARCHAR2(50) NOT NULL, --kindergarten_groups
            group_scale        NUMBER(*, 0) NOT NULL,
    kindergarten_desc  NVARCHAR2(50) NOT NULL,--kindergarten
            address            NVARCHAR2(100) NOT NULL,
    city               NVARCHAR2(50) NOT NULL,
    country            NVARCHAR2(50) NOT NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_ls_services (
    service_code  NUMBER NOT NULL,
    service_desc  NVARCHAR2(50) NOT NULL,--service
            type_desc     NVARCHAR2(50) NOT NULL,--type
            service_cost  FLOAT NOT NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_ls_md_services (
    service_code  NUMBER NOT NULL,
    service_desc  NVARCHAR2(50) NOT NULL,--service
            type_desc     NVARCHAR2(50) NOT NULL,--type
            service_cost  FLOAT NOT NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_ls_attendances (
    attendance_num     NUMBER NOT NULL,
    date_attendance    DATE NOT NULL,
    child_contract     NUMBER NOT NULL,
    child_name         NVARCHAR2(50) NOT NULL,
    child_lastname     NVARCHAR2(50) NOT NULL,
    emp_contract       NUMBER NOT NULL,
    emp_name           NVARCHAR2(50) NOT NULL,
    emp_lastname       NVARCHAR2(50) NOT NULL,
    group_num          NUMBER NOT NULL,
    group_desc         NVARCHAR2(50) NOT NULL,
    kindergarten_desc  NVARCHAR2(50) NOT NULL,
    country            NVARCHAR2(50) NOT NULL,
    service_code       NVARCHAR2(50) NOT NULL
)
TABLESPACE ts_cleansing;

CREATE TABLE dw_ls_md_attendances (
    attendance_num     NUMBER NOT NULL,
    date_attendance    DATE NOT NULL,
    child_contract     NUMBER NOT NULL,
    child_name         NVARCHAR2(50) NOT NULL,
    child_lastname     NVARCHAR2(50) NOT NULL,
    emp_contract       NUMBER NOT NULL,
    emp_name           NVARCHAR2(50) NOT NULL,
    emp_lastname       NVARCHAR2(50) NOT NULL,
    group_num          NUMBER NOT NULL,
    group_desc         NVARCHAR2(50) NOT NULL,
    kindergarten_desc  NVARCHAR2(50) NOT NULL,
    country            NVARCHAR2(50) NOT NULL,
    service_desc       NVARCHAR2(50) NOT NULL
)
TABLESPACE ts_cleansing;