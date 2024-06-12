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

spool &ns.processmem.log

column END_INTERVAL_TIME format a25

select 
sn.END_INTERVAL_TIME,
sum(pm.USED_TOTAL)/(1024*1024) used_meg,
sum(pm.ALLOCATED_TOTAL)/(1024*1024) allocated_meg
from DBA_HIST_PROCESS_MEM_SUMMARY pm,DBA_HIST_SNAPSHOT sn
where 
pm.snap_id=sn.snap_id and
pm.INSTANCE_NUMBER=sn.INSTANCE_NUMBER and
pm.DBID=sn.DBID 
group by sn.END_INTERVAL_TIME
order by sn.END_INTERVAL_TIME;

spool off
