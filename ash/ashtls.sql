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

spool &ns.ashtls.log

set define off

select 
TOP_LEVEL_SQL_ID,count(*) cnt
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('13-APR-2019 12:00:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('14-APR-2019 23:59:59','DD-MON-YYYY HH24:MI:SS') and
sql_id ='g0v5p7v7cdjc5' and TOP_LEVEL_SQL_ID <> sql_id
group by TOP_LEVEL_SQL_ID;
order by cnt desc;

spool off
                 
        