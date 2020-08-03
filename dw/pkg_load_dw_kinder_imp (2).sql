CREATE OR REPLACE PACKAGE BODY pkg_load_dw_kinder AS procedure load_dw_kinder as
   BEGIN DELETE FROM t_kindergarten lng
WHERE
    lng.kindergarten_desc NOT IN (
        SELECT DISTINCT
            upper(kindergarten_desc)
        FROM
            dw_ls_groups
    );MERGE INTO t_kindergarten k using (
    SELECT DISTINCT
        upper(kindergarten_desc) AS k_desc
    FROM
            dw_ls_groups
        order
    BY
        k_desc
) ck ON ( k.kindergarten_desc = ck.k_desc )
WHEN NOT MATCHED THEN
INSERT (
    kindergarten_id,
    kindergarten_desc,
    insert_dt,
    update_dt )
VALUES
    ( dw_kindergarten_id_seq.NEXTVAL,
    ck.k_desc,
    current_timestamp,
    current_timestamp );
      --Commit Data
     COMMIT;
END load_dw_kinder;
    PROCEDURE load_dw_groups AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE T_GROUPS';
        DECLARE
            TYPE var_cur IS
                TABLE OF VARCHAR2(50);
            TYPE num_cur IS
                TABLE OF NUMBER;
            TYPE all_cur IS REF CURSOR;
            ls_at        all_cur;
            group_num    num_cur;
            group_desc   var_cur;
            group_scale  num_cur;
        BEGIN
            OPEN ls_at FOR SELECT DISTINCT
                               group_num,
                               group_desc,
                               group_scale
                           FROM
                               dw_ls_groups
                           WHERE
                               group_num IS NOT NULL
                               AND group_desc IS NOT NULL
                                   AND group_scale IS NOT NULL;

            FETCH ls_at BULK COLLECT INTO
                group_num,
                group_desc,
                group_scale;
            CLOSE ls_at;
            FORALL i IN group_num.first..group_num.last
                INSERT INTO t_groups (
                    group_id,
                    group_num,
                    group_desc,
                    group_scale,
                    insert_dt,
                    update_dt
                ) VALUES (
                    dw_group_id_seq.NEXTVAL,
                    group_num(i),
                    group_desc(i),
                    group_scale(i),
                    current_timestamp,
                    current_timestamp
                );

            COMMIT;
--END IF;
	  -- END loop;
            END;

    END load_dw_groups;

    PROCEDURE load_dw_kinder_link AS
    BEGIN
        DELETE FROM t_links_kid_groups lng
        WHERE
            lng.kindergarten_id NOT IN (
                SELECT
                    kindergarten_id
                FROM
                    t_kindergarten
            )
            AND lng.group_id NOT IN (
                SELECT DISTINCT
                    group_id
                FROM
                    t_groups
            );

        MERGE INTO t_links_kid_groups trg
        USING (
                  SELECT DISTINCT
                      group_id,
                      kindergarten_id
                  FROM
                      dw_ls_groups    lg,
                      t_kindergarten  tk,
                      t_groups        tg
                  WHERE
                      group_id IS NOT NULL
                      AND upper(lg.kindergarten_desc) = tk.kindergarten_desc
                          AND tg.group_num = lg.group_num
              )
        kk ON ( trg.group_id = kk.group_id
                AND trg.kindergarten_id = kk.kindergarten_id )
        WHEN NOT MATCHED THEN
        INSERT (
            group_id,
            kindergarten_id,
            insert_dt,
            update_dt )
        VALUES
            ( kk.group_id,
              kk.kindergarten_id,
              current_timestamp,
              current_timestamp );

        COMMIT;
    END load_dw_kinder_link;

END pkg_load_dw_kinder;

