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

spool &ns.optstat2.log

-- dbms_stats operations

column OPERATION format a30
column TARGET format a90
column TARGET_TYPE format a20
column STATUS format a20

select
TARGET,
TARGET_TYPE,
to_char(START_TIME,'YYYY-MM-DD HH24:MI:SS') starttm,
to_char(END_TIME,'YYYY-MM-DD HH24:MI:SS') endtm,
STATUS
from 
DBA_OPTSTAT_OPERATION_TASKS
where start_time > sysdate - 3
order by OPID;

spool off
