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

spool &ns.byexecution.log

set define off

select 
SQL_EXEC_ID,
to_char(SQL_EXEC_START,'YYYY-MM-DD HH24:MI:SS') sql_start,
to_char(min(sample_time),'YYYY-MM-DD HH24:MI:SS') first_sample,
to_char(max(sample_time),'YYYY-MM-DD HH24:MI:SS') last_sample,
max(sample_time)-min(sample_time) elapsed_seconds
from V$ACTIVE_SESSION_HISTORY a
where 
sample_time 
between 
to_date('07-NOV-2016 07:00:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('07-NOV-2016 09:00:00','DD-MON-YYYY HH24:MI:SS') and
SQL_EXEC_ID is not null and
sql_id='0gt3cjptk68vw'
group by SQL_EXEC_ID,SQL_EXEC_START
order by SQL_EXEC_START,SQL_EXEC_ID;

spool off
                 
        