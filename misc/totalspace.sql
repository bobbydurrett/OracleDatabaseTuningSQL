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

spool &ns.totalspace.log

select sum(bytes)/(1024*1024*1024) Gigabytes from
(select bytes from dba_data_files
union all
select bytes from dba_temp_files
union all
select bytes from v$log);
                       
spool off
