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

spool &ns.osstatcpu.log

drop table myoscpu;

create table myoscpu as
select
busy_v.SNAP_ID,
busy_v.VALUE AVG_BUSY_TIME,
idle_v.VALUE AVG_IDLE_TIME,
load_v.VALUE LOAD
from 
DBA_HIST_OSSTAT busy_v,
DBA_HIST_OSSTAT idle_v,
DBA_HIST_OSSTAT load_v
where
busy_v.SNAP_ID = idle_v.SNAP_ID AND
busy_v.DBID = idle_v.DBID AND
busy_v.INSTANCE_NUMBER = idle_v.INSTANCE_NUMBER AND
load_v.SNAP_ID = idle_v.SNAP_ID AND
load_v.DBID = idle_v.DBID AND
load_v.INSTANCE_NUMBER = idle_v.INSTANCE_NUMBER AND
busy_v.STAT_NAME = 'AVG_BUSY_TIME' AND
idle_v.STAT_NAME = 'AVG_IDLE_TIME' AND
load_v.STAT_NAME = 'LOAD';

select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
(100*AVG_BUSY_TIME)/(AVG_BUSY_TIME+AVG_IDLE_TIME) HOST_CPU_PERCENT_USED,
LOAD HOST_CPU_LOAD
from 
myoscpu my,
DBA_HIST_SNAPSHOT sn
where 
my.SNAP_ID = sn.SNAP_ID
order by my.SNAP_ID;

spool off
