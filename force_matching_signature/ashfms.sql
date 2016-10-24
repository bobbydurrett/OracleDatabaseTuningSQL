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

spool &ns.ashfms.log

set define off

column FORCE_MATCHING_SIGNATURE format 99999999999999999999

select 
force_matching_signature,count(*) active
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('16-JUN-2016 08:00:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('16-JUN-2016 17:00:00','DD-MON-YYYY HH24:MI:SS')
and (
machine like 'mymachine1%' or
machine like 'mymachine2%'
)
group by force_matching_signature
order by active desc;

spool off
                 
        