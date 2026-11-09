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

spool &ns.ashdump2.log

-- join to dba_users

set define off

column USERNM format a10
column EVNT format a30
column mchne format a30

select 
to_char(a.sample_time,'YYYY-MM-DD HH24:MI:SS') smpltm,
u.username usernm,
a.EVENT evnt,
a.machine mchne
from 
DBA_HIST_ACTIVE_SESS_HISTORY a,
DBA_users u
where
a.user_id=u.user_id and
a.SAMPLE_TIME > to_date('2026-11-07 01:00:00','YYYY-MM-DD HH24:MI:SS') and
a.machine like 'mymachine%'
union
select 
to_char(a.sample_time,'YYYY-MM-DD HH24:MI:SS'),
u.username,
a.EVENT,
a.machine
from 
V$ACTIVE_SESSION_HISTORY a,
DBA_users u
where
a.user_id=u.user_id and
a.SAMPLE_TIME > to_date('2026-11-07 01:00:00','YYYY-MM-DD HH24:MI:SS') and
a.machine like 'mymachine%'
order by
smpltm,
usernm;


spool off
exit

