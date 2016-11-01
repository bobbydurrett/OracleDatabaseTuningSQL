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

spool &ns.longestexecution.log

set define off

-- list out the SQL statement ids by 
-- max run time

select
sql_id,
max(elapsed_interval) max_interval 
from
(select
sql_id,
SQL_EXEC_ID,
max(sample_time)-min(sample_time) elapsed_interval
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('28-OCT-2016 08:00:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('28-OCT-2016 11:00:00','DD-MON-YYYY HH24:MI:SS')
and sql_id is not null
group by sql_id,SQL_EXEC_ID)
group by sql_id
order by max_interval desc;

spool off
                 
        