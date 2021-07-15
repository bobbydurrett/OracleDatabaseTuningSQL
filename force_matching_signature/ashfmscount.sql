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

spool &ns.ashfmscount.log


column FORCE_MATCHING_SIGNATURE format 99999999999999999999

select 
FORCE_MATCHING_SIGNATURE,
count(*) active
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
SESSION_ID = 994 and
SESSION_SERIAL# = 42827 and
program like '%PSAESRV%' and
sample_time 
between 
to_date('05-JUL-2021 05:02:42','DD-MON-YYYY HH24:MI:SS')
and 
to_date('05-JUL-2021 07:15:36','DD-MON-YYYY HH24:MI:SS')
group by
FORCE_MATCHING_SIGNATURE
order by 
active desc;

spool off
                 
        