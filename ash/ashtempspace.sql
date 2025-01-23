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

spool &ns.ashtempspace.log

-- top 100 users of tempspace in past 2 days

select
*
from
(select 
sql_id,
sum(TEMP_SPACE_ALLOCATED)/(1024*1024*1024) gig
from 
DBA_HIST_ACTIVE_SESS_HISTORY
where 
sample_time > sysdate-2 and
TEMP_SPACE_ALLOCATED is not null
group by sql_id
order by gig desc)
where
rownum < 100;

spool off
