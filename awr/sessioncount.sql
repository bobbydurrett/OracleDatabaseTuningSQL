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

spool &ns.sessioncount.log

-- get the hourly session count
-- from the AWR views

set define off

select 
to_char(snap.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') SNAP_TIME,
stat.value session_count
from
DBA_HIST_SYSSTAT stat,
DBA_HIST_SNAPSHOT snap
where
stat.SNAP_ID = snap.SNAP_ID and
stat.DBID = snap.DBID and
stat.INSTANCE_NUMBER = snap.INSTANCE_NUMBER and
stat.STAT_NAME = 'logons current'
order by 
to_char(snap.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS');

spool off
                 
        