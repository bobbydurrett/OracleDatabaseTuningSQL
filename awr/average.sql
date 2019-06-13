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

spool &ns.average.log

-- average execution time by plan
-- over all of the AWR history

select
ss.sql_id,
ss.plan_hash_value,
sum(ss.ELAPSED_TIME_DELTA)/
(1000000*case sum(ss.executions_delta) when 0 then 1 else sum(ss.executions_delta) end) avg_elapsed_seconds
from DBA_HIST_SQLSTAT ss
where 
ss.sql_id = '5crdk2jjaw300'
group by
ss.sql_id,
ss.plan_hash_value;


spool off
