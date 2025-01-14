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

spool &ns.redologsperhour.log

select 
to_char(FIRST_TIME,'YYYY-MM-DD HH24') ,
count(*) num_logs
from 
v$archived_log
group by 
to_char(FIRST_TIME,'YYYY-MM-DD HH24') 
order by 
to_char(FIRST_TIME,'YYYY-MM-DD HH24') ;

spool off
