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

column WINDOW_NAME format a18
column REPEAT_INTERVAL format a54
column DURATION format a13
column ACTIVE format a6

spool &ns.schedulerwindows.log

select WINDOW_NAME,REPEAT_INTERVAL,DURATION,ACTIVE from DBA_SCHEDULER_WINDOWS
where 
ENABLED='TRUE';

spool off
