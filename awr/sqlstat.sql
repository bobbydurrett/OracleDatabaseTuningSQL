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

spool &ns.sqlstat.log

-- Replaces all the earlier versions of sqlstat.sql
-- including sqlstat2.sql and sqlstat3.sql

column END_INTERVAL_TIME format a25

-- g0wqzdhxy62mc

select 
sql_id,
plan_hash_value,
END_INTERVAL_TIME,
executions_delta,
ELAPSED_TIME_DELTA/(nonzeroexecutions*1000) "Elapsed Average ms",
CPU_TIME_DELTA/(nonzeroexecutions*1000) "CPU Average ms",
IOWAIT_DELTA/(nonzeroexecutions*1000) "IO Average ms",
CLWAIT_DELTA/(nonzeroexecutions*1000) "Cluster Average ms",
APWAIT_DELTA/(nonzeroexecutions*1000) "Application Average ms",
CCWAIT_DELTA/(nonzeroexecutions*1000) "Concurrency Average ms",
BUFFER_GETS_DELTA/nonzeroexecutions "Average buffer gets",
DISK_READS_DELTA/nonzeroexecutions "Average disk reads",
ROWS_PROCESSED_DELTA/nonzeroexecutions "Average rows processed"
from
(select 
ss.snap_id,
ss.sql_id,
ss.plan_hash_value,
sn.END_INTERVAL_TIME,
ss.executions_delta,
case ss.executions_delta when 0 then 1 else ss.executions_delta end nonzeroexecutions,
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
where ss.sql_id = 'g0wqzdhxy62mc'
and ss.snap_id=sn.snap_id
and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER)
where ELAPSED_TIME_DELTA > 0
order by snap_id,sql_id;

spool off
