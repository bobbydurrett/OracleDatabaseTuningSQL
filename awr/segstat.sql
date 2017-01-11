set linesize 32000
set pagesize 1000
set long 2000000000
set longchunksize 1000
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

spool &ns.segstat.log

column END_INTERVAL_TIME format a25

select 
sn.END_INTERVAL_TIME,
ss.LOGICAL_READS_DELTA,
ss.BUFFER_BUSY_WAITS_DELTA,
ss.DB_BLOCK_CHANGES_DELTA,
ss.PHYSICAL_READS_DELTA,
ss.PHYSICAL_WRITES_DELTA,
ss.PHYSICAL_READS_DIRECT_DELTA,
ss.PHYSICAL_WRITES_DIRECT_DELTA,
ss.ITL_WAITS_DELTA,
ss.ROW_LOCK_WAITS_DELTA,
ss.GC_CR_BLOCKS_SERVED_DELTA,
ss.GC_CU_BLOCKS_SERVED_DELTA,
ss.GC_BUFFER_BUSY_DELTA,
ss.GC_CR_BLOCKS_RECEIVED_DELTA,
ss.GC_CU_BLOCKS_RECEIVED_DELTA,
ss.SPACE_USED_DELTA,
ss.SPACE_ALLOCATED_DELTA,
ss.TABLE_SCANS_DELTA,
ss.CHAIN_ROW_EXCESS_DELTA,
ss.PHYSICAL_READ_REQUESTS_DELTA,
ss.PHYSICAL_WRITE_REQUESTS_DELTA,
ss.OPTIMIZED_PHYSICAL_READS_DELTA
from DBA_HIST_SEG_STAT ss,DBA_HIST_SNAPSHOT sn,DBA_HIST_SEG_STAT_OBJ so
where 
so.OWNER='MYOWNER' and
so.OBJECT_NAME='MYSEGMENT' and
so.SUBOBJECT_NAME is NULL and
so.OBJECT_TYPE='MYSEGTYPE' and
so.DBID = ss.DBID and
so.TS# = ss.TS# and
so.OBJ# = ss.OBJ# and
so.DATAOBJ# = ss.DATAOBJ# and
ss.snap_id=sn.snap_id and
ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER
order by ss.snap_id;

spool off
