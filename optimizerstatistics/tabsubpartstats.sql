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

spool &ns.tabsubpartstats.log

column owner format a20
column table_name format a30

select tp.table_owner,tp.table_name,tp.subpartition_name,tp.num_rows,tp.BLOCKS,tp.AVG_ROW_LEN,tp.SAMPLE_SIZE,
to_char(tp.last_analyzed,'YYYY-MM-DD HH24:MI:SS') "LAST_ANALYZED"      
from DBA_TAB_SUBPARTITIONS tp, tablelist t
where tp.table_owner=t.table_owner and
tp.table_name = t.table_name
order by tp.table_name,tp.subpartition_name;

spool off
