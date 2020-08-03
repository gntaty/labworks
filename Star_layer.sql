DROP TABLE dim_children CASCADE CONSTRAINTS;

DROP TABLE dim_employees CASCADE CONSTRAINTS;

DROP TABLE dim_gen_services_scd CASCADE CONSTRAINTS;

DROP TABLE dim_groups CASCADE CONSTRAINTS;

DROP TABLE dim_time_day CASCADE CONSTRAINTS;

DROP TABLE dim_locations CASCADE CONSTRAINTS;

DROP TABLE fct_attendances_dd CASCADE CONSTRAINTS;

DROP TABLE dim_gen_services_act CASCADE CONSTRAINTS;

CREATE TABLE dim_children (
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
    insert_dt          DATE NOT NULL,
    update_dt          DATE NOT NULL,
    CONSTRAINT child_pkey PRIMARY KEY ( child_id )
)
TABLESPACE dw_ts_dims;

CREATE TABLE dim_groups (
    group_id           NUMBER NOT NULL,
    group_desc         NVARCHAR2(50) NOT NULL,
    group_scale        NUMBER(*, 0) NOT NULL,
    kindergarten_id    NUMBER NOT NULL,
    kindergarten_desc  NVARCHAR2(50) NOT NULL,
    insert_dt          DATE NOT NULL,
    update_dt          DATE NOT NULL,
    CONSTRAINT group_pkey PRIMARY KEY ( group_id )
)
TABLESPACE dw_ts_dims;

CREATE TABLE dim_employees (
    employee_id   NUMBER NOT NULL,
    contract_num  NUMBER NOT NULL,
    first_name    NVARCHAR2(50) NOT NULL,
    last_name     NVARCHAR2(50) NOT NULL,
    phone_number  NVARCHAR2(50) NULL,
    email         NVARCHAR2(50) NULL,
    insert_dt     DATE NOT NULL,
    update_dt     DATE NOT NULL,
    CONSTRAINT employee_pkey PRIMARY KEY ( employee_id )
)
TABLESPACE dw_ts_dims;

CREATE TABLE dim_gen_services_scd (
    service_surr_id  NUMBER NOT NULL,
    service_id       NUMBER NOT NULL,
    service_desc     NVARCHAR2(50) NOT NULL,
    type_id          NUMBER NOT NULL,
    type_desc        NVARCHAR2(50) NOT NULL,
    service_cost     FLOAT NOT NULL,
    valid_from       DATE NOT NULL,
    valid_to         DATE NOT NULL,
    is_active        VARCHAR2(4) NOT NULL,
    CONSTRAINT gen_service_pkey PRIMARY KEY ( service_surr_id )
)
TABLESPACE dw_ts_dims;

CREATE TABLE dim_locations (
    location_id       NUMBER NOT NULL,
    address_id        NUMBER NULL,
    street            NVARCHAR2(100) NULL,
    city              VARCHAR2(50) NULL,
    country_id        NUMBER NOT NULL,
    country_code      VARCHAR2(50) NULL,
    country_desc      NVARCHAR2(100) NOT NULL,
    sub_c_group_id    NUMBER NULL,
    sub_c_group_code  VARCHAR2(50) NULL,
    sub_c_group_desc  VARCHAR2(50) NULL,
    c_group_id        NUMBER NULL,
    c_group_code      VARCHAR2(50) NULL,
    c_group_desc      VARCHAR2(50) NULL,
    region_id         NUMBER NOT NULL,
    region_code       VARCHAR2(50) NULL,
    region_desc       VARCHAR2(50) NOT NULL,
    part_id           NUMBER NOT NULL,
    part_code         VARCHAR2(50) NULL,
    part_desc         VARCHAR2(50) NOT NULL,
    insert_dt         DATE NOT NULL,
    update_dt         DATE NOT NULL,
    CONSTRAINT location_pkey PRIMARY KEY ( location_id )
)
TABLESPACE dw_ts_dims;

CREATE TABLE fct_attendances_dd ( -- create facts table 
         event_dt             NUMBER NOT NULL,
    child_id             NUMBER NOT NULL,
    employee_id          NUMBER NOT NULL,
    service_surr_id      NUMBER NOT NULL,
    k_group_id           NUMBER NOT NULL,
    location_id          NUMBER NOT NULL,
    cnt_services         NUMBER NOT NULL,
    tot_amoumt_services  NUMBER NOT NULL,
    visit_ratio          VARCHAR2(50) NOT NULL,
    insert_dt            DATE NOT NULL,
    update_dt            DATE NOT NULL
)
TABLESPACE dw_ts_fact; 

-- add foreing key references
ALTER TABLE fct_attendances_dd
    ADD CONSTRAINT child_id_fkey FOREIGN KEY ( child_id )
        REFERENCES dim_children ( child_id )
            ON DELETE CASCADE;

ALTER TABLE fct_attendances_dd
    ADD CONSTRAINT group_id_fkey FOREIGN KEY ( t_group_id )
        REFERENCES dim_groups ( group_id )
            ON DELETE CASCADE;

ALTER TABLE fct_attendances_dd
    ADD CONSTRAINT employee_id_fkey FOREIGN KEY ( employee_id )
        REFERENCES dim_employees ( employee_id )
            ON DELETE CASCADE;

ALTER TABLE fct_attendances_dd
    ADD CONSTRAINT surr_service_fkey FOREIGN KEY ( service_surr_id )
        REFERENCES dim_gen_services_scd ( service_surr_id )
            ON DELETE CASCADE;

ALTER TABLE fct_attendances_dd
    ADD CONSTRAINT location_id_fkey FOREIGN KEY ( location_id )
        REFERENCES dim_locations ( location_id )
            ON DELETE CASCADE;

ALTER TABLE fct_attendances_dd
    ADD CONSTRAINT date_id_fkey FOREIGN KEY ( event_dt )
        REFERENCES dim_time_day ( event_dt )
            ON DELETE CASCADE;

CREATE SEQUENCE children_id_seq;

CREATE SEQUENCE group_id_seq;

CREATE SEQUENCE employee_id_seq;

CREATE SEQUENCE service_surr_id_seq;

CREATE SEQUENCE loc_id_seq;

CREATE OR REPLACE VIEW dim_gen_services_act (
    service_surr_id,
    service_id,
    service_desc,
    type_id,
    type_desc,
    service_cost,
    valid_from,
    valid_to,
    is_active
) AS
    SELECT
        t.service_surr_id,
        t.service_id,
        t.service_desc,
        t.type_id,
        t.type_desc,
        t.service_cost,
        t.valid_from,
        t.valid_to,
        t.is_active
    FROM
        dim_gen_services_scd t
    WHERE
        t.valid_to = TO_DATE('31/12/9999', 'DD/MM/YYYY');