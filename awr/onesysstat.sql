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

spool &ns.onesysstat.log

set define off

-- show one system statistic
-- for instance 1 in RAC
-- one year
-- "bytes received via SQL*Net from client" statistic
select
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
after.value-before.value value_difference
from 
DBA_HIST_SYSSTAT before,
DBA_HIST_SYSSTAT after,
DBA_HIST_SNAPSHOT sn
where 
before.STAT_NAME = 'bytes received via SQL*Net from client' and
before.STAT_NAME = after.STAT_NAME and
before.INSTANCE_NUMBER = 1 and
before.INSTANCE_NUMBER = sn.INSTANCE_NUMBER and
before.INSTANCE_NUMBER = after.INSTANCE_NUMBER and
before.SNAP_ID = sn.SNAP_ID and
before.SNAP_ID + 1 = after.SNAP_ID and
before.DBID = sn.DBID and
before.DBID = after.DBID and
after.value >= before.value and
sn.END_INTERVAL_TIME >= to_date('2018-11-01','YYYY-MM-DD') and
sn.END_INTERVAL_TIME <= to_date('2018-12-21','YYYY-MM-DD')
order by sn.SNAP_ID;

spool off
