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

spool &ns.indpartstats.log

column index_name format a30
column table_name format a30
column partition_name format a20

select i.table_name,ip.index_name,ip.partition_name,ip.num_rows,ip.SAMPLE_SIZE,ip.CLUSTERING_FACTOR,
to_char(ip.last_analyzed,'YYYY-MM-DD HH24:MI:SS') "LAST_ANALYZED",
ip.LEAF_BLOCKS,ip.DISTINCT_KEYS,ip.AVG_LEAF_BLOCKS_PER_KEY,ip.AVG_DATA_BLOCKS_PER_KEY,
ip.BLEVEL
from DBA_IND_PARTITIONS ip, DBA_INDEXES i, tablelist t
where i.table_owner=t.table_owner and 
i.table_name = t.table_name
and i.owner=ip.index_owner
and i.index_name=ip.index_name
order by i.table_name,ip.index_name,ip.PARTITION_POSITION;

spool off
