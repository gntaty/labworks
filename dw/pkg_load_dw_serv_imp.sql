CREATE OR REPLACE PACKAGE BODY pkg_load_dw_serv 
AS 

procedure load_dw_serv as
   BEGIN DELETE FROM t_services lng
WHERE
    lng.SERVICE_DESC NOT IN (
        SELECT DISTINCT
            upper(service_desc) 
        FROM
            dw_ls_groups
    );MERGE INTO T_SERVICES k USING ( SELECT DISTINCT
    upper(service_desc) AS s_desc
FROM
    dw_ls_services) ck
              ON ( k.service_desc = ck.s_desc )
      WHEN NOT MATCHED THEN
         INSERT            ( SERVICE_ID
                            ,SERVICE_DESC 
                           ,INSERT_DT    
                            ,UPDATE_DT)
             VALUES ( DW_service_id_seq.NEXTVAL
                    ,ck.s_desc
                    ,CURRENT_TIMESTAMP
                    ,CURRENT_TIMESTAMP);
      --Commit Data
      COMMIT;
   END load_dw_serv;
   
PROCEDURE load_dw_types as
   BEGIN DELETE FROM t_types lng
WHERE
    lng.type_DESC NOT IN (
        SELECT DISTINCT
            upper(type_desc) 
        FROM
            dw_ls_groups
    );MERGE INTO T_TYPES k USING ( SELECT DISTINCT
    upper(type_desc) AS t_desc
FROM
    dw_ls_services) ck
              ON ( k.type_desc = ck.t_desc )
      WHEN NOT MATCHED THEN
         INSERT            ( TYPE_ID
                            ,TYPE_DESC 
                           ,INSERT_DT    
                            ,UPDATE_DT)
             VALUES ( DW_TYPE_ID_seq.NEXTVAL
                    ,ck.t_desc
                    ,CURRENT_TIMESTAMP
                    ,CURRENT_TIMESTAMP);
      --Commit Data
      COMMIT;
   END load_dw_types;
   
procedure load_dw_serv_link as
   BEGIN 
   DELETE FROM T_LINKS_SERVICE_TYPES lng
WHERE
    lng.SERVICE_ID NOT IN (
        SELECT SERVICE_ID
        FROM   t_services)
and lng.TYPE_ID not in(select distinct TYPE_ID  from t_types);
   MERGE INTO T_LINKS_SERVICE_TYPES trg
           USING (SELECT distinct SERVICE_ID 
                       , TYPE_ID
                       ,start_date
                    FROM 
                       dw_ls_services ls
                       ,t_services ts
                       ,t_types tt
                   WHERE TYPE_ID IS NOT NULL
                     AND  upper(ls.service_desc)=ts.service_desc
                     AND  upper(ls.type_desc)=tt.type_desc) kk
                     ON ( trg.SERVICE_ID = kk.SERVICE_ID
              AND trg.TYPE_ID = kk.TYPE_ID )
      WHEN NOT MATCHED THEN
         INSERT ( SERVICE_ID,
                TYPE_ID,
                START_FROM)
             VALUES ( kk.SERVICE_ID,
                    kk.TYPE_ID,
                    start_date );
      COMMIT;
   END load_dw_serv_link;
 
procedure load_dw_serv_scd 
as   
   BEGIN 
   DELETE FROM T_SERVICES_SCD lng
WHERE
    lng.SERVICE_ID NOT IN (
        SELECT SERVICE_ID
        FROM   t_services)
and lng.TYPE_ID not in(select TYPE_ID  from t_types);
   MERGE INTO T_SERVICES_SCD trg
           USING (SELECT distinct ts.SERVICE_ID,
                                ts.SERVICE_DESC,
                                cl.SERVICE_COST,
                                cl.start_date
                    FROM 
                       t_services ts
                       ,dw_ls_services cl
                   WHERE 
                     upper(cl.service_desc)=ts.service_desc) kk
                     ON ( trg.SERVICE_ID = kk.SERVICE_ID
                     and trg.START_FROM=kk.start_date)
      WHEN NOT MATCHED THEN
         INSERT ( SERVICE_ID,
                                SERVICE_DESC,
                                SERVICE_COST,
                                START_FROM,
                                INSERT_DT,
                                UPDATE_DT)
             VALUES ( kk.SERVICE_ID,
                    kk.SERVICE_DESC,
                    kk.SERVICE_COST,
                    kk.start_date, 
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP);
END load_dw_serv_scd;   
   
   
END pkg_load_dw_serv;






/*AS
 BEGIN
     EXECUTE IMMEDIATE 'TRUNCATE TABLE T_GROUPS';
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
   BEGIN 
   DELETE FROM T_LINKS_KID_GROUPS lng
WHERE
    lng.KINDERGARTEN_ID NOT IN (
        SELECT KINDERGARTEN_ID
        FROM   t_kindergarten)
and lng.GROUP_ID not in(select distinct group_id  from t_groups);
   MERGE INTO T_LINKS_KID_GROUPS trg
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
   END load_dw_kinder_link;
END pkg_load_dw_serv;*/