CREATE OR REPLACE PACKAGE BODY pkg_etl_dim_groups AS

    PROCEDURE etl_dim_group AS
    BEGIN
        DELETE FROM dim_groups lng
        WHERE
            group_id NOT IN (
                SELECT DISTINCT
                    group_id
                FROM
                    t_links_kid_groups
            );

        MERGE INTO dim_groups k
        USING (
                  SELECT DISTINCT
                      group_id,
                      group_desc,
                      group_scale,
                      kindergarten_id,
                      kindergarten_desc
                  FROM
                           t_links_kid_groups
                      JOIN t_groups USING ( group_id )
                      JOIN t_kindergarten USING ( kindergarten_id )
              )
        ck ON ( k.group_id = ck.group_id
                AND k.kindergarten_id = ck.kindergarten_id )
        WHEN NOT MATCHED THEN
        INSERT (
            group_id,
            group_desc,
            group_scale,
            kindergarten_id,
            kindergarten_desc,
            insert_dt,
            update_dt )
        VALUES
            ( ck.group_id,
              ck.group_desc,
              ck.group_scale,
              ck.kindergarten_id,
              ck.kindergarten_desc,
              current_timestamp,
              current_timestamp );
      --Commit Data
                      COMMIT;
    END etl_dim_group;

END pkg_etl_dim_groups;