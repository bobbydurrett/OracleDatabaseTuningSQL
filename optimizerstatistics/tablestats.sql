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

spool &ns.tablestats.log

column owner format a20
column table_name format a30

select dt.owner,dt.table_name,num_rows,BLOCKS,AVG_ROW_LEN,SAMPLE_SIZE,
to_char(last_analyzed,'YYYY-MM-DD HH24:MI:SS') "LAST_ANALYZED", degree, instances     
from DBA_TABLES dt, tablelist t
where dt.owner=t.table_owner and 
dt.table_name = t.table_name
order by dt.owner,dt.table_name;

spool off
