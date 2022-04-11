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

spool &ns.librarycachelocks.log

set define off

drop table library_cache_lock_waits;

create table library_cache_lock_waits
(
 SOURCETABLE    VARCHAR2(30),
 BLOCKER        VARCHAR2(1),
 SAMPLE_TIME    DATE,
 INST_ID        NUMBER,
 SID            NUMBER,
 USERNAME       VARCHAR2(30),
 STATUS         VARCHAR2(8),
 OSUSER         VARCHAR2(30),
 MACHINE        VARCHAR2(64),
 PROGRAM        VARCHAR2(48),
 LOGON_TIME     DATE,
 LAST_CALL_ET   NUMBER,
 KGLLKHDL       RAW(8),
 KGLLKREQ       NUMBER,
 USER_NAME      VARCHAR2(30),
 KGLNAOBJ       VARCHAR2(60),
 SQL_ID         VARCHAR2(13),
 RESOURCE_NAME1 VARCHAR2(30),
 RESOURCE_NAME2 VARCHAR2(30),
 SQL_FULLTEXT   CLOB
);

-- join gv$session to itself showing sessions waiting on library cache locks
-- and their blockers.  Only works where the blocking session info is filled
-- in which it isn't always.

drop table lcl_blockers;

create table lcl_blockers as
select distinct
s.INST_ID,
s.SID,
s.USERNAME,
s.STATUS,
s.OSUSER,
s.MACHINE,
s.PROGRAM,
s.LOGON_TIME,
s.LAST_CALL_ET,
s.sql_id
from
gv$session s, 
gv$session s2
where
s2.FINAL_BLOCKING_INSTANCE=s.INST_ID and
s2.FINAL_BLOCKING_SESSION=s.SID and
s2.event='library cache lock';

truncate table library_cache_lock_waits;

insert into library_cache_lock_waits
(
SOURCETABLE,
BLOCKER,
SAMPLE_TIME,
INST_ID,
SID,
USERNAME,
STATUS,
OSUSER,
MACHINE,
PROGRAM,
LOGON_TIME,
LAST_CALL_ET,
sql_id,
SQL_FULLTEXT
)
select
'GV$SESSION',
'Y',
sysdate,
s.INST_ID,
s.SID,
s.USERNAME,
s.STATUS,
s.OSUSER,
s.MACHINE,
s.PROGRAM,
s.LOGON_TIME,
s.LAST_CALL_ET,
s.sql_id,
q.SQL_FULLTEXT
from 
lcl_blockers s, gv$sql q
where
s.sql_id=q.sql_id(+) and
s.INST_ID=q.INST_ID(+) and
q.child_number(+)=0;

commit;

drop table ges_blocked;

create table ges_blocked as
select
s.INST_ID,
s.SID,
s.USERNAME,
s.STATUS,
s.OSUSER,
s.MACHINE,
s.PROGRAM,
s.LOGON_TIME,
s.LAST_CALL_ET,
s.sql_id,
s.process,
p.spid,
e.RESOURCE_NAME1,
e.RESOURCE_NAME2
from
gv$session s, 
gv$process p,
gv$ges_blocking_enqueue e
where
s.event='library cache lock' and 
s.inst_id=p.inst_id and
s.paddr=p.addr and
p.inst_id=e.inst_id and
p.spid=e.pid and
e.blocked > 0;

-- join gv$ges_blocking_enqueue, gv$session, gv$process to show cross node
-- library cache lock blockers.  Blocked session will have 
-- event=library cache lock.
-- union with

drop table ges_blocked_blocker;

create table ges_blocked_blocker as
(select distinct
'N' blocker,
s.INST_ID,
s.SID,
s.USERNAME,
s.STATUS,
s.OSUSER,
s.MACHINE,
s.PROGRAM,
s.LOGON_TIME,
s.LAST_CALL_ET,
s.sql_id,
s.process,
p.spid,
e.RESOURCE_NAME1,
e.RESOURCE_NAME2
from
gv$session s, 
gv$process p,
gv$ges_blocking_enqueue e
where
s.event='library cache lock' and 
s.inst_id=p.inst_id and
s.paddr=p.addr and
p.inst_id=e.inst_id and
p.spid=e.pid and
e.blocked > 0)
union
(select distinct
'Y',
s.INST_ID,
s.SID,
s.USERNAME,
s.STATUS,
s.OSUSER,
s.MACHINE,
s.PROGRAM,
s.LOGON_TIME,
s.LAST_CALL_ET,
s.sql_id,
s.process,
p.spid,
e.RESOURCE_NAME1,
e.RESOURCE_NAME2
from
gv$session s, 
gv$process p,
ges_blocked b,
gv$ges_blocking_enqueue e
where
s.inst_id=p.inst_id and
s.paddr=p.addr and
p.inst_id=e.inst_id and
p.spid=e.pid and
b.RESOURCE_NAME1=e.RESOURCE_NAME1 and
b.RESOURCE_NAME2=e.RESOURCE_NAME2 and
e.blocker > 0);

insert into library_cache_lock_waits
(
SOURCETABLE,
BLOCKER,
SAMPLE_TIME,
INST_ID,
SID,
USERNAME,
STATUS,
OSUSER,
MACHINE,
PROGRAM,
LOGON_TIME,
LAST_CALL_ET,
sql_id,
SQL_FULLTEXT,
RESOURCE_NAME1,
RESOURCE_NAME2
)
select
'GV$GES_BLOCKING_ENQUEUE',
s.blocker,
sysdate,
s.INST_ID,
s.SID,
s.USERNAME,
s.STATUS,
s.OSUSER,
s.MACHINE,
s.PROGRAM,
s.LOGON_TIME,
s.LAST_CALL_ET,
s.sql_id,
q.SQL_FULLTEXT,
s.RESOURCE_NAME1,
s.RESOURCE_NAME2
from 
ges_blocked_blocker s, gv$sql q
where
s.sql_id=q.sql_id(+) and
s.INST_ID=q.INST_ID(+) and
q.child_number(+)=0
order by s.INST_ID,s.sid;

commit;

drop table lcl_blockers;
drop table ges_blocked;
drop table ges_blocked_blocker;

select
SOURCETABLE,
BLOCKER,
to_char(SAMPLE_TIME,'YYYY-MM-DD HH24:MI:SS') "Sample Time",
INST_ID,
SID,
USERNAME,
STATUS,
OSUSER,
MACHINE,
PROGRAM,
to_char(LOGON_TIME,'YYYY-MM-DD HH24:MI:SS') "Logon Time",
LAST_CALL_ET,
KGLLKHDL,
KGLLKREQ,
USER_NAME,
KGLNAOBJ,
SQL_ID,
RESOURCE_NAME1,
RESOURCE_NAME2
from library_cache_lock_waits
where blocker='Y'
order by sample_time;

spool off
