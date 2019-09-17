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

spool &ns.directwritepercent.log

-- get percent of ASH time spent on 
-- direct write waits
-- this is an estimate of the time that
-- force logging will add

select
total_sample_count,
dw_sample_count,
100*dw_sample_count/total_sample_count dw_sample_pct
from
(select 
count(*) total_sample_count
from DBA_HIST_ACTIVE_SESS_HISTORY
where 
sql_id = 'cq433j04qgb18') all_samples,
(select 
count(*) dw_sample_count
from DBA_HIST_ACTIVE_SESS_HISTORY
where 
sql_id = 'cq433j04qgb18' and
event = 'direct path write') dw_samples
where
total_sample_count > 0;

spool off
                 