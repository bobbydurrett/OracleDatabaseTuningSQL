set linesize 1000
set pagesize 1000
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
spool &ns.extractplan.log

-- extracts the plan for the current SQL for a given SID on the instance you are connected to.
-- 10.1 Oracle and up

UNDEFINE MONITORED_SID

set markup html preformat on

select * from table(DBMS_XPLAN.DISPLAY_CURSOR(
(SELECT SQL_ID from v$session where sid= &&MONITORED_SID),
(SELECT SQL_CHILD_NUMBER from v$session where sid= &&MONITORED_SID),
'ALL'));

spool off

exit