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
busy_v.VALUE BUSY_TIME,
idle_v.VALUE IDLE_TIME,
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
busy_v.STAT_NAME = 'BUSY_TIME' AND
idle_v.STAT_NAME = 'IDLE_TIME' AND
load_v.STAT_NAME = 'LOAD';

drop table myoscpudiff;

create table myoscpudiff as
select
after.SNAP_ID,
(after.BUSY_TIME - before.BUSY_TIME) BUSY_TIME,
(after.IDLE_TIME - before.IDLE_TIME) IDLE_TIME,
after.LOAD 
from 
myoscpu before,
myoscpu after
where before.SNAP_ID + 1 = after.SNAP_ID
order by before.SNAP_ID;

select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
(100*BUSY_TIME)/(BUSY_TIME+IDLE_TIME) HOST_CPU_PERCENT_USED,
LOAD HOST_CPU_LOAD
from 
myoscpudiff my,
DBA_HIST_SNAPSHOT sn
where 
my.SNAP_ID = sn.SNAP_ID
order by my.SNAP_ID;

spool off
