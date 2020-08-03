--create tablespaces for diferent DW level 
drop tablespace ts_sa_attendances  INCLUDING CONTENTS AND DATAFILES;
drop tablespace ts_cleansing  INCLUDING CONTENTS AND DATAFILES;
drop tablespace dw_ts_fact  INCLUDING CONTENTS AND DATAFILES;
drop tablespace dw_ts_data  INCLUDING CONTENTS AND DATAFILES;
drop tablespace dw_ts_dims  INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE ts_sa_attendances 
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_tgnezdilova/ts_p_attendances.dat'
SIZE 300M
 AUTOEXTEND ON NEXT 100M
 SEGMENT SPACE MANAGEMENT AUTO;
 
CREATE TABLESPACE ts_cleansing
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_tgnezdilova/ts_cleansing.dat'
SIZE 150M
 AUTOEXTEND ON NEXT 50M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 CREATE TABLESPACE dw_ts_fact
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_tgnezdilova/dw_ts_fact.dat'
SIZE 700M
 AUTOEXTEND ON NEXT 200M
 SEGMENT SPACE MANAGEMENT AUTO; 
 
 CREATE TABLESPACE dw_ts_data
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_tgnezdilova/dw_ts_data.dat'
SIZE 500M
 AUTOEXTEND ON NEXT 200M
 SEGMENT SPACE MANAGEMENT AUTO;
 
  CREATE TABLESPACE  dw_ts_dims
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_tgnezdilova/ts_dims.dat'
SIZE 400M
 AUTOEXTEND ON NEXT 100M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 