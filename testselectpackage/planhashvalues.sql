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

column TEST_NAME format a11

spool &ns.planhashvalues.log

set define off

select
test_name,
sqlnumber,
explain_plan_hash,
error_message
from test_results
order by 
sqlnumber,
test_name;

spool off
