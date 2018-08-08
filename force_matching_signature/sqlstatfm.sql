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

spool &ns.sqlstatfm.log

column END_INTERVAL_TIME format a25
column FORCE_MATCHING_SIGNATURE format 99999999999999999999

select ss.sql_id,
ss.FORCE_MATCHING_SIGNATURE,
ss.plan_hash_value,
sn.END_INTERVAL_TIME,
ss.executions_delta,
ELAPSED_TIME_DELTA/(executions_delta*1000) "Elapsed Average ms",
CPU_TIME_DELTA/(executions_delta*1000) "CPU Average ms",
IOWAIT_DELTA/(executions_delta*1000) "IO Average ms",
CLWAIT_DELTA/(executions_delta*1000) "Cluster Average ms",
APWAIT_DELTA/(executions_delta*1000) "Application Average ms",
CCWAIT_DELTA/(executions_delta*1000) "Concurrency Average ms",
BUFFER_GETS_DELTA/executions_delta "Average buffer gets",
DISK_READS_DELTA/executions_delta "Average disk reads",
ROWS_PROCESSED_DELTA/executions_delta "Average rows processed"
from DBA_HIST_SQLSTAT ss,DBA_HIST_SNAPSHOT sn
where ss.sql_id = '5bdqs1m23a422'
and ss.snap_id=sn.snap_id
and executions_delta > 0
and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER
order by ss.snap_id,ss.sql_id;

spool off
