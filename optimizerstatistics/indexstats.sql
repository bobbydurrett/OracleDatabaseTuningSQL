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

spool &ns.indexstats.log

column index_name format a30
column table_name format a30
column table_owner format a30

select i.table_owner,i.table_name,index_name,num_rows,SAMPLE_SIZE,CLUSTERING_FACTOR,
to_char(last_analyzed,'YYYY-MM-DD HH24:MI:SS') "LAST_ANALYZED",
LEAF_BLOCKS,DISTINCT_KEYS,AVG_LEAF_BLOCKS_PER_KEY,AVG_DATA_BLOCKS_PER_KEY,
BLEVEL,INDEX_TYPE
from DBA_INDEXES i, tablelist t
where i.table_owner= t.table_owner and 
i.table_name = t.table_name
order by i.table_owner,i.table_name,index_name;

spool off
