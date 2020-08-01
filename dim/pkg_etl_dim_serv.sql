CREATE OR REPLACE PACKAGE BODY pkg_etl_dim_serv AS

    PROCEDURE etl_dim_serv AS
    BEGIN
       DELETE FROM dim_gen_services_scd lng
        WHERE
            service_id NOT IN (
                SELECT DISTINCT
                    service_id
                FROM
                    T_SERVICES
            );

        MERGE INTO dim_gen_services_scd k
        USING (
                  SELECT DISTINCT
                      tls.service_id,
                      service_desc,
                      service_cost,
                      tls.type_id,
                      type_desc
                  FROM
                           t_links_service_types tls
                      JOIN t_types t on t.type_id=tls.type_id
                      JOIN t_services_scd scd on scd.service_id=scd.service_id
              )
        ck ON ( k.service_id = ck.service_id )
        WHEN MATCHED THEN UPDATE
        SET k.is_active = 0,
            k.valid_to = current_timestamp
        WHEN NOT MATCHED THEN
        INSERT (
            service_surr_id,
            service_id,
            service_desc,
            service_cost,
            type_id,
            type_desc,
            valid_from,
            valid_to,
            is_active )
        VALUES
            ( service_surr_id_seq.nextval,
            ck.service_id,
              ck.service_desc,
              ck.service_cost,
              ck.type_id,
              ck.type_desc,
              current_timestamp,
              to_date ('31/12/9999','dd/mm/yyyy'),
              1    );
      --Commit Data
                              COMMIT;
    END etl_dim_serv;
    
    
    PROCEDURE etl_dim_serv_cor
    AS
 BEGIN
    DECLARE
        TYPE var_cur IS TABLE OF varchar2(50);
        TYPE num_cur IS TABLE OF number;
        TYPE date_cur IS TABLE OF date;
         TYPE float_cur IS TABLE OF date;
        TYPE all_cur is REF CURSOR;
        ls_at all_cur; 
        service_surr_id num_cur;
            service_id num_cur;
            service_desc var_cur;
            service_cost float_cur;
            type_id num_cur;
            type_desc var_cur;
            valid_from date_cur;
            valid_to date_cur;
            is_active var_cur;
        
          BEGIN
      open ls_at for 
      SELECT DISTINCT
      service_surr_id,
            service_id,
            service_desc,
            service_cost,
            type_id,
            type_desc,
            valid_from,
            valid_to,
            is_active
            FROM DIM_GEN_SERVICES_SCD;
      FETCH ls_at
	   BULK COLLECT into service_surr_id,
            service_id,
            service_desc,
            service_cost,
            type_id,
            type_desc,
            valid_from,
            valid_to,
            is_active;
            close ls_at;
     FOR i IN service_surr_id.FIRST .. service_surr_id.LAST LOOP
     IF ( service_id ( i )<> service_id ( i+1 )) THEN
	         UPDATE dim_gen_services_scd
	            SET is_active = 0,
                    valid_to = current_timestamp
	          WHERE dim_gen_services_scd.service_id = service_id ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
       end;
    END etl_dim_serv_cor;
END pkg_etl_dim_serv;


