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

spool &ns.sqlstat2.log

column END_INTERVAL_TIME format a25

select ss.sql_id,
ss.plan_hash_value,
sn.END_INTERVAL_TIME,
ss.executions_delta,
ELAPSED_TIME_DELTA,
CPU_TIME_DELTA,
IOWAIT_DELTA,
CLWAIT_DELTA,
APWAIT_DELTA,
CCWAIT_DELTA,
BUFFER_GETS_DELTA,
DISK_READS_DELTA,
ROWS_PROCESSED_DELTA
from DBA_HIST_SQLSTAT ss,DBA_HIST_SNAPSHOT sn
where ss.sql_id in ('fnsrpftx0wx0r','5g9z6j8tbac19','7qr2b85d6v9qu')
and ss.snap_id=sn.snap_id
and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER
order by ss.sql_id,ss.snap_id;

spool off
