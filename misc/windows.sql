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

spool &ns.windows.log

column window_name format a20
column duration format a20
column repeat_interval format a60

select window_name,
       duration,
       repeat_interval
from dba_scheduler_windows
where 
window_name like '%WINDOW' and
enabled = 'TRUE'
order by NEXT_START_DATE;

spool off
