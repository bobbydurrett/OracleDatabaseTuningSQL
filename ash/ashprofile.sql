set linesize 1000
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

spool &ns.ashprofile.log

-- shows a profile of a sql statement's
-- ASH time including CPU and waits.

select 
case SESSION_STATE
when 'WAITING' then event
else SESSION_STATE
end TIME_CATEGORY,
(count(*)*10) seconds
from DBA_HIST_ACTIVE_SESS_HISTORY
where 
sql_id = 'cq433j04qgb18'
group by SESSION_STATE,EVENT
order by seconds desc;

spool off
                 