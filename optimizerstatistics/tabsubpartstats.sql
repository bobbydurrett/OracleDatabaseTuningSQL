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

drop table part_info;

create table part_info as
select tp.table_owner,tp.table_name,tp.partition_name,tp.PARTITION_POSITION
from tablelist t, dba_tab_partitions tp
where
tp.table_owner=t.table_owner and
tp.table_name=t.table_name;


select tsp.table_owner,tsp.table_name,tsp.PARTITION_NAME,tsp.subpartition_name,tsp.num_rows,tsp.BLOCKS,tsp.AVG_ROW_LEN,tsp.SAMPLE_SIZE,
to_char(tsp.last_analyzed,'YYYY-MM-DD HH24:MI:SS') "LAST_ANALYZED", tsp.HIGH_VALUE      
from DBA_TAB_SUBPARTITIONS tsp, part_info pi
where 
tsp.table_owner=pi.table_owner and
tsp.table_name=pi.table_name and
tsp.partition_name=pi.partition_name
order by tsp.table_name,pi.PARTITION_POSITION,tsp.SUBPARTITION_POSITION;

spool off
