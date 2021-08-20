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

spool &ns.columnstats.log

column table_name format a30
column column_name format a30
column lo format a30
column hi format a30
column data_default format a60

select tc.table_name,column_name,
decode(data_type,'NUMBER',to_char(utl_raw.cast_to_number(low_value))
,'VARCHAR2',utl_raw.cast_to_varchar2(low_value)
,'CHAR',utl_raw.cast_to_varchar2(low_value)
,'DATE',
(to_number(substr( low_value, 1, 2 ), 'xx')-100)*100+
(to_number(substr( low_value, 3, 2 ), 'xx' )-100)|| '/' ||
to_number(substr( low_value, 5, 2 ), 'xx' ) || '/' ||
to_number(substr( low_value, 7, 2 ), 'xx' ) || ' ' ||
(to_number(substr( low_value, 9, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( low_value,11, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( low_value,13, 2 ), 'xx' )-1)
,'Hi') lo,
decode(data_type,'NUMBER',to_char(utl_raw.cast_to_number(high_value))
,'VARCHAR2',utl_raw.cast_to_varchar2(high_value)
,'CHAR',utl_raw.cast_to_varchar2(high_value)
,'DATE',
(to_number(substr( high_value, 1, 2 ), 'xx')-100)*100+
(to_number(substr( high_value, 3, 2 ), 'xx' )-100)|| '/' ||
to_number(substr( high_value, 5, 2 ), 'xx' ) || '/' ||
to_number(substr( high_value, 7, 2 ), 'xx' ) || ' ' ||
(to_number(substr( high_value, 9, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( high_value,11, 2 ), 'xx' )-1) || ':' ||
(to_number(substr( high_value,13, 2 ), 'xx' )-1)
,'Hi') hi,
num_distinct,num_buckets,density,NUM_NULLS,AVG_COL_LEN,
to_char(last_analyzed,'YYYY-MM-DD HH24:MI:SS') "LAST_ANALYZED",
sample_size,data_default
from DBA_TAB_COLS tc, tablelist t 
where tc.owner = t.table_owner and 
tc.table_name = t.table_name
order by tc.table_name,column_id;
spool off
