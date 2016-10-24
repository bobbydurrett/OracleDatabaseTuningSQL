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

spool &ns.colpartstats.log

column table_name format a30
column column_name format a30
column lo format a30
column hi format a30
column data_default format a30

select pc.table_name,pc.partition_name,pc.column_name,
decode(c.data_type,'NUMBER',to_char(utl_raw.cast_to_number(pc.low_value))
,'VARCHAR2',utl_raw.cast_to_varchar2(pc.low_value)
,'CHAR',utl_raw.cast_to_varchar2(pc.low_value)
,'DATE',
(to_number(substr( pc.low_value, 1, 2 ), 'xx')-100)*100+
(to_number(substr( pc.low_value, 3, 2 ), 'xx' )-100)|| '/' ||
to_number(substr( pc.low_value, 5, 2 ), 'xx' ) || '/' ||
to_number(substr( pc.low_value, 7, 2 ), 'xx' ) || ' ' ||
(to_number(substr( pc.low_value, 9, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( pc.low_value,11, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( pc.low_value,13, 2 ), 'xx' )-1)
,'Hi') lo,
decode(c.data_type,'NUMBER',to_char(utl_raw.cast_to_number(pc.high_value))
,'VARCHAR2',utl_raw.cast_to_varchar2(pc.high_value)
,'CHAR',utl_raw.cast_to_varchar2(pc.high_value)
,'DATE',
(to_number(substr( pc.high_value, 1, 2 ), 'xx')-100)*100+
(to_number(substr( pc.high_value, 3, 2 ), 'xx' )-100)|| '/' ||
to_number(substr( pc.high_value, 5, 2 ), 'xx' ) || '/' ||
to_number(substr( pc.high_value, 7, 2 ), 'xx' ) || ' ' ||
(to_number(substr( pc.high_value, 9, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( pc.high_value,11, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( pc.high_value,13, 2 ), 'xx' )-1)
,'Hi') hi,
pc.num_distinct,pc.num_buckets,pc.density,pc.NUM_NULLS,pc.AVG_COL_LEN,
to_char(pc.last_analyzed,'YYYY-MM-DD HH24:MI:SS') "LAST_ANALYZED",
pc.sample_size,c.data_default
from DBA_PART_COL_STATISTICS pc, DBA_TAB_COLS c, tablelist t
where pc.owner=t.table_owner and 
pc.table_name =t.table_name
and
pc.column_name=c.column_name and
pc.table_name=c.table_name and
pc.owner=c.owner
order by pc.owner,pc.table_name,pc.partition_name,c.column_id;
spool off
