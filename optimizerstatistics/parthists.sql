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

spool &ns.parthists.log

column table_name format a30
column column_name format a30
column endpoint_actual_value format a30
column data_default format a30


select tc.histogram,ph.table_name,ph.partition_name,ph.column_name,ph.bucket_number,
ph.endpoint_value,ph.endpoint_actual_value,tc.data_default
from DBA_PART_HISTOGRAMS ph, tablelist t, dba_tab_cols tc 
where ph.owner=t.table_owner and 
ph.table_name = t.table_name and
ph.owner = tc.owner and
ph.table_name = tc.table_name and
ph.column_name = tc.column_name and
tc.HISTOGRAM <> 'NONE'
order by ph.owner,ph.table_name,column_name,bucket_number;

spool off
