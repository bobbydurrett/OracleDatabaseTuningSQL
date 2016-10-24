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
spool &ns.fileio.log
select 
substr(d.TABLESPACE_NAME,1,20) Tablespace,
substr(d.FILE_NAME,1,60) Datafilename,
v.PHYRDS,         
v.PHYWRTS,        
v.PHYBLKRD,       
v.PHYBLKWRT,
v.READTIM,        
v.WRITETIM,       
v.AVGIOTIM,       
v.LSTIOTIM,       
v.MINIOTIM,       
v.MAXIORTM,       
v.MAXIOWTM       
from 
dba_data_files d,v$filestat v
where
d.FILE_ID = v.FILE#
order by d.tablespace_name,d.file_name;
                       
spool off
