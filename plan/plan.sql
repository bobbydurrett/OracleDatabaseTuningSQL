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
spool &ns.plan.log

set define off

-- this version only works on 9.2 or higher - gets full plan table details from display()

truncate table plan_table;

explain plan into plan_table for 
select * from dual
/

set markup html preformat on

select * from table(dbms_xplan.display('PLAN_TABLE',NULL,'ADVANCED'));

select object_name from plan_table;

spool off
