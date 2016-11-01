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
UNDEFINE INTERVALSECONDS

spool "&ns.&&WAITNAME.diff.log"

drop table waitdiff;

create table waitdiff as
select * from v$system_event
where event='&&WAITNAME';

host sleep &&INTERVALSECONDS

select 
s.event,
(s.TOTAL_WAITS-d.TOTAL_WAITS) "Number of waits",
(s.TIME_WAITED_MICRO-d.TIME_WAITED_MICRO)/
(s.TOTAL_WAITS-d.TOTAL_WAITS) "Avg microseconds"
from
waitdiff d,
v$system_event s
where 
d.event=s.event and
(s.TOTAL_WAITS-d.TOTAL_WAITS) > 0;

spool off
