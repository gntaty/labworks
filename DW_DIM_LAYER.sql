DROP TABLE t_children;

DROP TABLE t_employees;

DROP TABLE t_kindergarten;

DROP TABLE t_groups;

DROP TABLE t_types;

DROP TABLE t_services_scd;

DROP TABLE t_services;
--drop table  T_ATTENDANCES;
DROP TABLE t_links_kid_groups;

DROP TABLE t_links_service_types;

DROP SEQUENCE dw_kindergarten_id_seq;

DROP SEQUENCE dw_type_id_seq;

DROP SEQUENCE dw_children_id_seq;

DROP SEQUENCE dw_group_id_seq;

DROP SEQUENCE dw_employee_id_seq;

DROP SEQUENCE dw_service_id_seq;

CREATE TABLE t_children (
    child_id           NUMBER NOT NULL,
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
    phone_number       NVARCHAR2(50) NULL,
    insert_dt          TIMESTAMP NOT NULL,
    update_dt          TIMESTAMP NOT NULL,
    CONSTRAINT dw_child_pkey PRIMARY KEY ( child_id )
)
TABLESPACE dw_ts_data;

CREATE TABLE t_employees (
    employee_id   NUMBER NOT NULL,
    contract_num  NUMBER NOT NULL,
    first_name    NVARCHAR2(50) NOT NULL,
    last_name     NVARCHAR2(50) NOT NULL,
    phone_number  NVARCHAR2(50) NULL,
    email         NVARCHAR2(50) NULL,
    insert_dt     TIMESTAMP NOT NULL,
    update_dt     TIMESTAMP NOT NULL,
    CONSTRAINT dw_employee_pkey PRIMARY KEY ( employee_id )
)
TABLESPACE dw_ts_data;

CREATE TABLE t_kindergarten (
    kindergarten_id    NUMBER NOT NULL,
    kindergarten_desc  NVARCHAR2(50) NOT NULL, --kindergarten
    insert_dt          TIMESTAMP NOT NULL,
    update_dt          TIMESTAMP NOT NULL,
    CONSTRAINT dw_group_pkey PRIMARY KEY ( kindergarten_id )
)
TABLESPACE dw_ts_data;

CREATE TABLE t_groups (
    group_id     NUMBER NOT NULL,
    group_num    NUMBER NOT NULL,
    group_desc   NVARCHAR2(50) NOT NULL, --kindergarten_groups
    group_scale  NUMBER(*, 0) NOT NULL,
    insert_dt    TIMESTAMP NOT NULL,
    update_dt    TIMESTAMP NOT NULL,
    CONSTRAINT dw_groups_pkey PRIMARY KEY ( group_id )
)
TABLESPACE dw_ts_data;

CREATE TABLE t_addresses (
    address_id    NUMBER NOT NULL,
    address            NVARCHAR2(100) NOT NULL,
    city               NVARCHAR2(50) NOT NULL,
    country            NVARCHAR2(50) NOT NULL,
    insert_dt     TIMESTAMP NOT NULL,
    update_dt     TIMESTAMP NOT NULL
)
TABLESPACE dw_ts_data;

CREATE TABLE t_links_kind_addresses (
    address_id    NUMBER NOT NULL,
    kindergarten_id    NUMBER NOT NULL,
    insert_dt     TIMESTAMP NOT NULL,
    update_dt     TIMESTAMP NOT NULL
)
TABLESPACE dw_ts_data;

CREATE TABLE t_links_kid_groups (
    group_id         NUMBER NOT NULL,
    kindergarten_id  NUMBER NOT NULL,
    insert_dt        TIMESTAMP NOT NULL,
    update_dt        TIMESTAMP NOT NULL
)
TABLESPACE dw_ts_data;

CREATE TABLE t_types (
    type_id    NUMBER NOT NULL,
    type_desc  NVARCHAR2(50) NOT NULL,--type
    insert_dt  TIMESTAMP NOT NULL,
    update_dt  TIMESTAMP NOT NULL,
    CONSTRAINT de_service_scd_pkey PRIMARY KEY ( type_id )
)
TABLESPACE dw_ts_data;

CREATE TABLE t_services_scd (
    service_id    NUMBER NOT NULL,
    service_code  NUMBER NOT NULL,
    service_desc  NVARCHAR2(50) NOT NULL,--service
    service_cost  FLOAT NOT NULL,
    start_from    DATE NOT NULL,
    insert_dt     TIMESTAMP NOT NULL,
    update_dt     TIMESTAMP NOT NULL
)
TABLESPACE dw_ts_data;

CREATE TABLE t_links_service_types (
    service_id  NUMBER NOT NULL,
    type_id     NUMBER NOT NULL,
    start_from  DATE NOT NULL
)
TABLESPACE dw_ts_data;

CREATE TABLE t_services (
    service_id    NUMBER NOT NULL,
    service_code  NUMBER NOT NULL,
    insert_dt     TIMESTAMP NOT NULL,
    update_dt     TIMESTAMP NOT NULL
)
TABLESPACE dw_ts_data;

CREATE SEQUENCE dw_addresses_id_seq;

CREATE SEQUENCE dw_kindergarten_id_seq;

CREATE SEQUENCE dw_type_id_seq;

CREATE SEQUENCE dw_children_id_seq;

CREATE SEQUENCE dw_group_id_seq;

CREATE SEQUENCE dw_employee_id_seq;

CREATE SEQUENCE dw_service_id_seq;