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

spool &ns.pagingout.log

-- VM_OUT_BYTES
-- Bytes paged out due to virtual memory swapping 
-- V$OSSTAT

set define off

select
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
trunc((after.value-before.value)/(1024*1024)) megabytes_paged_out
from 
DBA_HIST_OSSTAT before,
DBA_HIST_OSSTAT after,
DBA_HIST_SNAPSHOT sn
where 
before.STAT_NAME = 'VM_OUT_BYTES' and
before.STAT_NAME = after.STAT_NAME and
before.INSTANCE_NUMBER = 1 and
before.INSTANCE_NUMBER = sn.INSTANCE_NUMBER and
before.INSTANCE_NUMBER = after.INSTANCE_NUMBER and
before.SNAP_ID = sn.SNAP_ID and
before.SNAP_ID + 1 = after.SNAP_ID and
before.DBID = sn.DBID and
before.DBID = after.DBID and
after.value >= before.value and
sn.END_INTERVAL_TIME >= to_date('2020-01-01','YYYY-MM-DD') and
sn.END_INTERVAL_TIME <= to_date('2020-05-01','YYYY-MM-DD')
order by sn.SNAP_ID;

spool off
