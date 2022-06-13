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

spool &ns.activeshared.log

set define off

-- average number of actived shared server
-- connections between two snapshots

select
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
(after.SAMPLED_ACTIVE_CONN-before.SAMPLED_ACTIVE_CONN)/(after.NUM_SAMPLES - before.NUM_SAMPLES) average_active
from 
DBA_HIST_SHARED_SERVER_SUMMARY before,
DBA_HIST_SHARED_SERVER_SUMMARY after,
DBA_HIST_SNAPSHOT sn
where 
before.INSTANCE_NUMBER = 1 and
before.INSTANCE_NUMBER = sn.INSTANCE_NUMBER and
before.INSTANCE_NUMBER = after.INSTANCE_NUMBER and
before.SNAP_ID = sn.SNAP_ID and
before.SNAP_ID + 1 = after.SNAP_ID and
before.DBID = sn.DBID and
before.DBID = after.DBID and
after.NUM_SAMPLES > before.NUM_SAMPLES and
after.SAMPLED_ACTIVE_CONN >= before.SAMPLED_ACTIVE_CONN and
sn.END_INTERVAL_TIME >= to_date('2022-05-01','YYYY-MM-DD') and
sn.END_INTERVAL_TIME <= to_date('2022-07-01','YYYY-MM-DD')
order by sn.SNAP_ID;

spool off
