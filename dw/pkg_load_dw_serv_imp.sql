CREATE OR REPLACE PACKAGE BODY pkg_load_dw_serv AS

    PROCEDURE load_dw_serv AS
    BEGIN
        DELETE FROM t_services lng
        WHERE
            lng.service_code NOT IN (
                SELECT DISTINCT
                    service_code
                FROM
                    dw_ls_groups
            );

        MERGE INTO t_services k
        USING (
                  SELECT DISTINCT
                      service_code AS s_desc
                  FROM
                      dw_ls_services
              )
        ck ON ( k.service_code = ck.s_desc )
        WHEN NOT MATCHED THEN
        INSERT (
            service_id,
            service_code,
            insert_dt,
            update_dt )
        VALUES
            ( dw_service_id_seq.NEXTVAL,
            ck.s_desc,
            current_timestamp,
            current_timestamp );
      --Commit Data
              COMMIT;
    END load_dw_serv;

    PROCEDURE load_dw_types AS
    BEGIN
        DELETE FROM t_types lng
        WHERE
            lng.type_desc NOT IN (
                SELECT DISTINCT
                    upper(type_desc)
                FROM
                    dw_ls_groups
            );

        MERGE INTO t_types k
        USING (
                  SELECT DISTINCT
                      upper(type_desc) AS t_desc
                  FROM
                      dw_ls_services
              )
        ck ON ( k.type_desc = ck.t_desc )
        WHEN NOT MATCHED THEN
        INSERT (
            type_id,
            type_desc,
            insert_dt,
            update_dt )
        VALUES
            ( dw_type_id_seq.NEXTVAL,
            ck.t_desc,
            current_timestamp,
            current_timestamp );
      --Commit Data
              COMMIT;
    END load_dw_types;
    
        PROCEDURE load_dw_serv_scd AS
    BEGIN
        DELETE FROM t_services_scd lng
        WHERE
            lng.service_id NOT IN (
                SELECT
                    service_id
                FROM
                    t_services
            );

        MERGE INTO t_services_scd trg
        USING (
                  SELECT
                      service_id,
                      service_code,
                      service_desc,
                      service_cost,
                      MIN(start_date) start_date
                  FROM
                      (
                          SELECT DISTINCT
                              ts.service_id,
                              ts.service_code,
                              service_desc,
                              service_cost,
                              type_desc,
                              cl.date_attendance start_date
                          FROM
                                   dw_ls_attendances cl
                              INNER JOIN t_services      ts ON cl.service_code = ts.service_code
                              INNER JOIN dw_ls_services  ls ON ls.service_code = ts.service_code
                      ) t1
                  GROUP BY
                      service_id,
                      service_code,
                      service_desc,
                      service_cost,
                      type_desc
              )
        kk ON ( trg.service_id = kk.service_id )
        WHEN MATCHED THEN UPDATE
        SET start_from = current_timestamp
        WHEN NOT MATCHED THEN
        INSERT (
            service_id,
            service_code,
            service_desc,
            service_cost,
            start_from,
            insert_dt,
            update_dt )
        VALUES
            ( kk.service_id,
              kk.service_code,
              kk.service_desc,
              kk.service_cost,
              kk.start_date,
              current_timestamp,
              current_timestamp );

    END load_dw_serv_scd;

    PROCEDURE load_dw_serv_link AS
    BEGIN
        DELETE FROM t_links_service_types lng
        WHERE
            lng.service_id NOT IN (
                SELECT
                    service_id
                FROM
                    t_services
            )
            AND lng.type_id NOT IN (
                SELECT DISTINCT
                    type_id
                FROM
                    t_types
            );

        MERGE INTO t_links_service_types trg
        USING (
                  SELECT DISTINCT
                      service_id,
                      type_id,
                      start_from
                      
                  FROM
                      dw_ls_services  ls,
                      t_services_scd      ts,
                      t_types         tt
                  WHERE
                      type_id IS NOT NULL
                      AND ls.service_code = ts.service_code
                      AND upper(ls.type_desc) = tt.type_desc
              )
        kk ON ( trg.service_id = kk.service_id
                AND trg.type_id = kk.type_id )
        WHEN NOT MATCHED THEN
        INSERT (
            service_id,
            type_id,
            start_from )
        VALUES
            ( kk.service_id,
              kk.type_id,
              kk.start_from );

        COMMIT;
    END load_dw_serv_link;

END pkg_load_dw_serv;