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

spool &ns.ashcount.log

set define off

select 
sample_time,count(*) active
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('11-MAR-2016 00:00:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('15-MAR-2016 00:00:00','DD-MON-YYYY HH24:MI:SS')
group by sample_time
order by sample_time;

spool off
                 
        