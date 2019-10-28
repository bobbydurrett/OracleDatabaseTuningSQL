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

spool &ns.sqlstatsumday.log

column END_INTERVAL_TIME format a25

select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD') "Day",
ss.sql_id,
ss.plan_hash_value,
sum(ss.executions_delta) "Executions",
sum(ELAPSED_TIME_DELTA)/((sum(executions_delta)+1)*1000) "Elapsed Average ms",
sum(CPU_TIME_DELTA)/((sum(executions_delta)+1)*1000) "CPU Average ms",
sum(IOWAIT_DELTA)/((sum(executions_delta)+1)*1000) "IO Average ms",
sum(CLWAIT_DELTA)/((sum(executions_delta)+1)*1000) "Cluster Average ms",
sum(APWAIT_DELTA)/((sum(executions_delta)+1)*1000) "Application Average ms",
sum(CCWAIT_DELTA)/((sum(executions_delta)+1)*1000) "Concurrency Average ms",
sum(BUFFER_GETS_DELTA)/(sum(executions_delta)+1) "Average buffer gets",
sum(DISK_READS_DELTA)/(sum(executions_delta)+1) "Average disk reads",
sum(ROWS_PROCESSED_DELTA)/(sum(executions_delta)+1) "Average rows processed"
from DBA_HIST_SQLSTAT ss,DBA_HIST_SNAPSHOT sn
where ss.sql_id = '6mcqczrk3k5wm'
and ss.snap_id=sn.snap_id
and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER
group by 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD'),
ss.sql_id,
ss.plan_hash_value
order by
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD'),
ss.sql_id,
ss.plan_hash_value;

spool off
