CREATE OR REPLACE PACKAGE BODY pkg_etl_dw_fact AS
    PROCEDURE etl_dw_fact AS
    BEGIN
        DECLARE
            TYPE cur_int IS
                TABLE OF INT;
            TYPE cur_num IS
                TABLE OF NUMBER;
            TYPE cur_date IS
                TABLE OF DATE;
            TYPE big_cur IS REF CURSOR;
            total_inf            big_cur;
            child_id             cur_int;
            employee_id          cur_int;
            k_group_id           cur_int;
            service_id           cur_int;
            date_attendance      cur_date;
            address_id           cur_int;
            cnt_services         cur_int;
            tot_amoumt_services  cur_num;
            visit_ratio          cur_num;
            attendance_num cur_int;
            attendance_id cur_int;
        BEGIN
            OPEN total_inf FOR select t2.*,attendance_id
                               from (SELECT DISTINCT
                                 attendance_num,
                                 date_attendance,
                                 child_id,
                                 employee_id,
                                 g.group_id k_group_id,
                                 address_id,
                                 service_id,
                                 COUNT(DISTINCT service_id)                         cnt_services,
                                 COUNT(DISTINCT service_id) * st.service_cost       tot_amoumt_services,
                                 round(COUNT(DISTINCT child_id)
                                       OVER(PARTITION BY g.group_id, date_attendance) / group_scale * 100,
                                       2)                                            visit_ratio
                                                              
                             FROM
                                      dw_ls_attendances lsa
                                 INNER JOIN t_children              ch ON lsa.child_contract = ch.contract_num
                                 INNER JOIN t_employees             emp ON emp.contract_num = lsa.emp_contract
                                 INNER JOIN t_groups                g ON g.group_num = lsa.group_num
                                 INNER JOIN t_services_scd          st ON st.service_code = lsa.service_code
                                 INNER JOIN t_links_kid_groups      tlkg ON tlkg.group_id = g.group_id
                                 INNER JOIN t_links_kind_addresses  tlka ON tlka.kindergarten_id = tlkg.kindergarten_id
                                 
                             GROUP BY
                                 attendance_num,
                                 date_attendance,
                                 child_id,
                                 employee_id,
                                 g.group_id,
                                 tlka.address_id,
                                 service_id,
                                 st.service_cost,
                                 group_scale)t2
                                 left join t_fct_attendances fct on t2.attendance_num=fct.attendance_id;

            FETCH total_inf BULK COLLECT INTO
                attendance_num,
                date_attendance,
                child_id,
                employee_id,
                k_group_id,
                address_id,
                service_id,
                cnt_services,
                tot_amoumt_services,
                visit_ratio,
                attendance_id;
            CLOSE total_inf;
            
            FOR i IN attendance_num.first..attendance_num.last
            LOOP
            if( attendance_id( i )is null) THEN
            INSERT INTO t_fct_attendances fct
            (attendance_id,
    event_dt,
    child_id,
    employee_id,
    service_id,
    k_group_id,
    address_id,
    cnt_services,
    tot_amoumt_services,
    visit_ratio,
    insert_dt,
    update_dt)
    values(attendance_num(i),
                date_attendance(i),
                child_id(i),
                employee_id(i),
                service_id(i),
                k_group_id(i),
                address_id(i),
                cnt_services(i),
                tot_amoumt_services(i),
                visit_ratio(i),
                current_timestamp,
                current_timestamp
                
    );
    commit;
    else
    update t_fct_attendances fct
    set  event_dt = date_attendance(i),
    child_id=child_id(i),
    employee_id=employee_id(i),
    service_id=service_id(i),
    k_group_id=k_group_id(i),
    address_id=address_id(i),
    cnt_services=cnt_services(i),
    tot_amoumt_services=tot_amoumt_services(i),
    visit_ratio=visit_ratio(i),
    update_dt=current_timestamp
    where fct.attendance_id =attendance_num( i );
            commit;
            end if;
            end loop;
  END;
  end etl_dw_fact;
END pkg_etl_dw_fact;