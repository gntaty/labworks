DROP TABLE t_fct_attendances;

--create a fact table on the DW-layer

CREATE TABLE t_fct_attendances (
    attendance_id        NUMBER NOT NULL,
    event_dt             DATE NOT NULL,
    child_id             NUMBER NOT NULL,
    employee_id          NUMBER NOT NULL,
    service_id           NUMBER NOT NULL,
    k_group_id           NUMBER NOT NULL,
    address_id           NUMBER NOT NULL,
    cnt_services         NUMBER NOT NULL,
    tot_amoumt_services  NUMBER NOT NULL,
    visit_ratio          NUMBER NOT NULL,
    insert_dt            DATE NOT NULL,
    update_dt            DATE NOT NULL
)
TABLESPACE dw_ts_fact;

create SEQUENCE t_fct_attendances_id_seq;