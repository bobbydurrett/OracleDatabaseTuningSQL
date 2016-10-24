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

spool &ns.histograms.log

column table_name format a30
column column_name format a30
column endpoint_actual_value format a30
column data_default format a30


select tc.histogram,h.table_name,h.column_name,h.endpoint_number,h.endpoint_value,h.endpoint_actual_value,
tc.data_default
from DBA_TAB_HISTOGRAMS h, tablelist t, dba_tab_cols tc
where h.owner=t.table_owner and 
h.table_name = t.table_name and
h.owner = tc.owner and
h.table_name = tc.table_name and
h.column_name = tc.column_name and
tc.HISTOGRAM <> 'NONE'
order by h.owner,h.table_name,column_name,endpoint_number;

spool off
