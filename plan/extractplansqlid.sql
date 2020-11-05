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
spool &ns.extractplansqlid.log

-- extracts the plan for a given sql_id from v$ views

set markup html preformat on

select * from table(DBMS_XPLAN.DISPLAY_CURSOR(
'9m8yb6rayqaxq',
NULL,
'ALL'));

spool off

exit