 PROCEDURE etl_dim_serv_cor
    AS
 BEGIN
    DECLARE
        TYPE var_cur IS TABLE OF varchar2(50);
        TYPE num_cur IS TABLE OF number;
        TYPE date_cur IS TABLE OF date;
         TYPE float_cur IS TABLE OF float;
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
           is_active num_cur;
    type t__listOfTerms is table of c_my_cursor%rowtype index by binary_integer;    
          BEGIN
      open ls_at for 
      SELECT 
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
	   BULK COLLECT into ser;
            close ls_at;
     FOR i IN ser.FIRST .. ser.LAST LOOP
     IF ( service_id ( i )<> service_id ( i+1 )) THEN
	         UPDATE dim_gen_services_scd
	            SET is_active = 0,
                    valid_to = sysdate
	          WHERE dim_gen_services_scd.service_id = service_id ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
       end;
    END etl_dim_serv_cor;
    
    
    DECLARE


   -- Declare the cursor explicitly.
   cursor c_my_cursor is
     SELECT apl.awdp_acad_terms 
       FROM fa_years fay 
       JOIN award_periods_ls apl
         ON apl.award_periods_id = fay.award_periods_id 
      WHERE ( SELECT b.awdp_fa_year as faYear 
                FROM award_periods_ls a 
                JOIN coll18_test.fa_years b 
                  ON a.award_periods_id = b.award_periods_id 
               WHERE awdp_acad_terms = v_ug_term ) = fay.awdp_fa_year
      ORDER BY apl.awdp_acad_terms DESC;



   -- Create a-user defined type that is the same as a single row in the cursor.
   type t__listOfTerms is table of c_my_cursor%rowtype index by binary_integer;
   -- Initialise a variable that is of data-type t__listofterms.
   t_listofterms t__listofterms;



BEGIN



   open c_my_cursor;
   fetch c_my_cursor bulk collect into t_listofterms;
   close c_my_cursor;



END;