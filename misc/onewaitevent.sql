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

UNDEFINE WAITNAME
UNDEFINE MINIMUMWAITS

spool "&ns.&&WAITNAME..log"

column END_INTERVAL_TIME format a26

select sn.END_INTERVAL_TIME,
(after.total_waits-before.total_waits) "number of waits",
(after.time_waited_micro-before.time_waited_micro)/(after.total_waits-before.total_waits) "ave microseconds",
before.event_name "wait name"
from DBA_HIST_SYSTEM_EVENT before, DBA_HIST_SYSTEM_EVENT after,DBA_HIST_SNAPSHOT sn
where before.event_name='&&WAITNAME' and
after.event_name=before.event_name and
after.snap_id=before.snap_id+1 and
after.instance_number=1 and
before.instance_number=after.instance_number and
after.snap_id=sn.snap_id and
after.instance_number=sn.instance_number and
(after.total_waits-before.total_waits) > &&MINIMUMWAITS
order by after.snap_id;

spool off
