CREATE OR REPLACE PACKAGE BODY pkg_etl_dim_loc AS

           PROCEDURE etl_dim_loc AS
    BEGIN
      --truncate cleansing tables
                      EXECUTE IMMEDIATE 'TRUNCATE TABLE DIM_LOCATIONS';
        MERGE INTO dim_locations trg
        USING (
                  SELECT DISTINCT
                      address_id,
                      address,
                      city,
                      country_id,
                      country_code_a2,
                      country_code_a3,
                      country_desc,
                      region_id,
                      region_code,
                      region_desc,
                      part_id,
                      part_code,
                      part_desc,
                      sub_group_id,
                      sub_group_code,
                      sub_group_desc,
                      group_id,
                      group_code,
                      loc.group_desc
                  FROM
                      u_dw_references.location    loc
                      LEFT JOIN t_addresses cls ON upper(loc.country_desc) = upper(cls.country)
              )
        cls ON ( trg.country_id = cls.country_id)
        WHEN NOT MATCHED THEN
        INSERT (
            location_id,
            address_id,
            street,
            city,
            country_id,
            country_code,
            country_desc,
            sub_c_group_id,
            sub_c_group_code,
            sub_c_group_desc,
            c_group_id,
            c_group_code,
            c_group_desc,
            region_id,
            region_code,
            region_desc,
            part_id,
            part_code,
            part_desc,
            insert_dt,
            update_dt )
        VALUES
            ( loc_id_seq.NEXTVAL,
            cls.address_id,
            cls.address,
            cls.city,
            cls.country_id,
            cls.country_code_a2,
            cls.country_desc,
            cls.sub_group_id,
            cls.sub_group_code,
            cls.sub_group_desc,
            cls.group_id,
            cls.group_code,
            cls.group_desc,
            cls.region_id,
            cls.region_code,
            cls.region_desc,
            cls.part_id,
            cls.part_code,
            cls.part_desc,
            current_timestamp,
            current_timestamp );

      --Commit Resulst
                      COMMIT;
    END etl_dim_loc;

END pkg_etl_dim_loc;