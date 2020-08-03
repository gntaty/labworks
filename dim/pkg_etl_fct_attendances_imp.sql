CREATE OR REPLACE PACKAGE BODY pkg_etl_fct_attendances AS procedure etl_fct as merge into fct_attendances_dd a_dd
        USING (
                  SELECT DISTINCT
    time.event_dt,
    child_id,
    employee_id,
    scd.service_id,
    start_from,
    k_group_id,
    location_id,
    cnt_services,
    tot_amoumt_services,
    visit_ratio
                  FROM
                      t_fct_attendances fct
                        inner join t_services_scd  scd on scd.service_id=fct.service_id
                        inner join dim_locations loc on loc.address_id=fct.address_id
                        inner join dim_time_day time on time.time_id=fct.event_dt
              )
        cls ON (cls.event_dt=a_dd.event_dt
    and cls.child_id=a_dd.child_id
    and cls.employee_id=a_dd.employee_id
    and cls.k_group_id=a_dd.k_group_id
    and cls.location_id=a_dd.location_id )
        WHEN MATCHED THEN
        update 
        set    a_dd.cnt_services=cls.cnt_services ,
                a_dd.tot_amoumt_services=cls.tot_amoumt_services,
                 a_dd.visit_ratio=cls.visit_ratio,
                 a_dd.update_dt = current_timestamp
WHEN NOT MATCHED THEN
INSERT (
    event_dt,
    child_id,
    employee_id,
    service_surr_id,
    k_group_id,
    location_id,
    cnt_services,
    tot_amoumt_services,
    visit_ratio,
    insert_dt,
    update_dt )
VALUES
    ( cls.event_dt,
      cls.child_id,
      cls.employee_id,
    service_surr_id_seq.NEXTVAL,
      cls.k_group_id,
      cls.location_id,
      cls.cnt_services,
      cls.tot_amoumt_services,
    cls.visit_ratio || '%',
      current_timestamp,
      current_timestamp );

      --Commit Resulst
       COMMIT;
END etl_fct;
END pkg_etl_fct_attendances;