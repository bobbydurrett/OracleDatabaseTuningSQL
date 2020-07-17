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

spool &ns.sqlstatwritesweekdays.log

-- find top writing (updating) sql ids for the week days

column END_INTERVAL_TIME format a25

select 
ss.sql_id,
sum(PHYSICAL_WRITE_BYTES_DELTA)/(1024*1024) write_megabytes
from DBA_HIST_SQLSTAT ss,DBA_HIST_SNAPSHOT sn
where ss.snap_id=sn.snap_id
and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER
and to_char(sn.END_INTERVAL_TIME,'DAY') in
('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY')
and to_char(sn.END_INTERVAL_TIME,'HH24') > 12
and PHYSICAL_WRITE_BYTES_DELTA > 0
group by ss.sql_id
order by WRITE_MEGABYTES desc;

spool off
