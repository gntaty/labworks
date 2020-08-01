CREATE OR REPLACE PACKAGE BODY pkg_load_dw_kinder AS procedure load_dw_kinder as
   BEGIN DELETE FROM t_kindergarten lng
WHERE
    lng.kindergarten_desc NOT IN (
        SELECT DISTINCT
            upper(kindergarten_desc)
        FROM
            dw_ls_groups
    );MERGE INTO t_kindergarten k USING ( SELECT DISTINCT
    upper(kindergarten_desc) AS k_desc
FROM
    dw_ls_groups order BY k_desc) ck
              ON ( k.kindergarten_desc = ck.k_desc )
      WHEN NOT MATCHED THEN
         INSERT            ( KINDERGARTEN_ID
                           , kindergarten_desc
                           ,INSERT_DT    
                            ,UPDATE_DT)
             VALUES ( DW_KINDERGARTEN_ID_seq.NEXTVAL
                    ,ck.k_desc
                    ,CURRENT_TIMESTAMP
                    ,CURRENT_TIMESTAMP);
      --Commit Data
      COMMIT;
   END load_dw_kinder;
   
PROCEDURE load_dw_groups
AS
 BEGIN
    DECLARE
        TYPE var_cur IS TABLE OF varchar2(50);
        TYPE num_cur IS TABLE OF number;
        TYPE all_cur is REF CURSOR;
        ls_at all_cur; 
        
            GROUP_NUM num_cur;
            GROUP_DESC var_cur;
            GROUP_SCALE num_cur;
       BEGIN
       open ls_at   FOR
        SELECT DISTINCT
            GROUP_NUM,
            GROUP_DESC,
            GROUP_SCALE
        FROM dw_ls_groups
        WHERE
         group_num IS NOT NULL
         AND GROUP_DESC IS NOT NULL
         AND group_scale IS NOT NULL;
       fetch  ls_at
       BULK COLLECT INTO GROUP_NUM,GROUP_DESC,GROUP_SCALE;
       close ls_at;
        
         
        forall i IN group_num.FIRST..group_num.LAST
	         INSERT INTO T_GROUPS (GROUP_ID,
                                GROUP_NUM,
                                GROUP_DESC,
                                GROUP_SCALE,
                                INSERT_DT,    
                                UPDATE_DT)
        VALUES ( dw_group_id_seq.NEXTVAL
	                     , GROUP_NUM(i)
                            ,group_desc(i)
                            ,group_scale(i)
                            ,current_timestamp
                            ,current_timestamp );   
                            COMMIT;
--END IF;
	  -- END loop;
    end;
END load_dw_groups;

procedure load_dw_kinder_link as
   BEGIN MERGE INTO T_LINKS_KID_GROUPS trg
           USING (SELECT distinct GROUP_ID 
                       , KINDERGARTEN_ID 
                    FROM 
                       dw_ls_groups lg
                       , t_kindergarten tk
                       ,t_groups tg
                   WHERE GROUP_ID IS NOT NULL
                     AND  upper(lg.kindergarten_desc)=tk.kindergarten_desc
                     AND tg.group_num=lg.group_num) kk
                     ON ( trg.GROUP_ID = kk.GROUP_ID
              AND trg.KINDERGARTEN_ID = kk.KINDERGARTEN_ID )
      WHEN NOT MATCHED THEN
         INSERT            ( GROUP_ID,
                            KINDERGARTEN_ID,
                            INSERT_DT, 
                            UPDATE_DT)
             VALUES ( kk.GROUP_ID,
                    kk.KINDERGARTEN_ID,
                    current_timestamp,
                    current_timestamp );
      COMMIT;
   END load_dw_kinder;
END pkg_load_dw_kinder;


