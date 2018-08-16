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

spool &ns.fmstopsql.log

column FORCE_MATCHING_SIGNATURE format 99999999999999999999

-- top queries by FORCE_MATCHING_SIGNATURE in a given
-- date and time range
-- date and time range is for the end of the awr snapshot interval
-- so for example if you want the 14:00:09 hourly snapshot
-- you could do before of 13:53:00 and after of 14:02:00 to bracket it.

select 
ss.FORCE_MATCHING_SIGNATURE,
sum(ss.executions_delta) total_executions,
sum(ELAPSED_TIME_DELTA)/1000000 total_seconds,
sum(ELAPSED_TIME_DELTA)/(sum(ss.executions_delta)*1000) "Elapsed Average ms",
sum(CPU_TIME_DELTA)/(sum(ss.executions_delta)*1000) "CPU Average ms",
sum(IOWAIT_DELTA)/(sum(ss.executions_delta)*1000) "IO Average ms",
sum(CLWAIT_DELTA)/(sum(ss.executions_delta)*1000) "Cluster Average ms",
sum(APWAIT_DELTA)/(sum(ss.executions_delta)*1000) "Application Average ms",
sum(CCWAIT_DELTA)/(sum(ss.executions_delta)*1000) "Concurrency Average ms",
sum(BUFFER_GETS_DELTA)/sum(ss.executions_delta) "Average buffer gets",
sum(DISK_READS_DELTA)/sum(ss.executions_delta) "Average disk reads",
sum(ROWS_PROCESSED_DELTA)/sum(ss.executions_delta) "Average rows processed"
from DBA_HIST_SQLSTAT ss,DBA_HIST_SNAPSHOT sn
where 
ss.snap_id=sn.snap_id
and ss.FORCE_MATCHING_SIGNATURE <> 0
and executions_delta > 0
and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER
and sn.END_INTERVAL_TIME
between 
to_date('08-AUG-2018 13:53:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('08-AUG-2018 14:02:00','DD-MON-YYYY HH24:MI:SS')
group by ss.FORCE_MATCHING_SIGNATURE
order by total_seconds desc;

spool off
