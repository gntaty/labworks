CREATE OR REPLACE PACKAGE BODY pkg_load_dw_addresses AS

    PROCEDURE load_dw_address AS
     declare
        CURSOR ls_at IS
         SELECT distinct 
                address,
                city,
                country
   FROM
                dw_ls_groups;
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE t_addresses';
      --Extract data
        FOR i IN ls_at LOOP
            INSERT INTO t_addresses (
            address_id,
            address,
            city,
            country,
            insert_dt,
            update_dt
        )
            VALUES ( 
                dw_addresses_id_seq.NEXTVAL,
                i.address,
                i.city,
                i.country,
                current_timestamp,
                current_timestamp);
            
            EXIT WHEN ls_at%notfound;
        END LOOP;
      --Commit Data
                                    COMMIT;
    END load_dw_address;

PROCEDURE load_dw_links_kind_ad AS
    BEGIN
            DELETE FROM t_links_kind_addresses lng
        WHERE
            lng.address_id NOT IN (
                SELECT
                    address_id
                FROM
                    t_addresses
            )
            and lng.kindergarten_id not in(
            select 
            kindergarten_id
            from t_kindergarten);

        MERGE INTO t_links_kind_addresses trg
        USING (
                   SELECT DISTINCT
                              address_id,
                              kindergarten_id
                          FROM
                                   dw_ls_groups cl
                              INNER JOIN t_kindergarten  tk ON upper(cl.kindergarten_desc) = upper(tk.kindergarten_desc)
                              INNER JOIN t_addresses  ta ON UPPER(ta.address) = upper(cl.address) and upper(cl.country)=upper(ta.country)
                      ) 
                
        kk ON ( trg.address_id = kk.address_id
        and trg.kindergarten_id=kk.kindergarten_id)
        WHEN NOT MATCHED THEN
        INSERT (
            address_id,
            kindergarten_id,
            insert_dt,
            update_dt )
        VALUES
            ( kk.address_id,
              kk.kindergarten_id,
              current_timestamp,
              current_timestamp );

END load_dw_links_kind_ad;

END pkg_load_dw_addresses;