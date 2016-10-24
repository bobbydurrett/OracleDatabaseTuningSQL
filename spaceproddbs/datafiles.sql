set linesize 1000
set pagesize 1000
set head off;
set verify off;
set termout off;
 
column u new_value us noprint;
column n new_value ns noprint;
 
select name n from v$database;
select user u from dual;
set sqlprompt &ns:&us>

set head on
set echo on
set termout on
set trimspool on
spool &ns.datafiles.log
select 
substr(TABLESPACE_NAME,1,20) Tablespace,
substr(FILE_NAME,1,60) Datafilename,
(BYTES/(1024*1024)) Meg,
AUTOEXTENSIBLE,
(MAXBYTES/(1024*1024)) MaxMeg
from 
dba_data_files
order by tablespace_name,file_name;
                       
spool off
