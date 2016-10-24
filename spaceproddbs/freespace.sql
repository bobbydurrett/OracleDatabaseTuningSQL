set linesize 1000
set pagesize 1000
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
spool &ns.freespace.log

select 
substr(TABLESPACE_NAME,1,20) Tablespace,                        
round(sum(BYTES)/(1024*1024)) TotalMeg,
round(min(BYTES)/(1024*1024)) MinMeg,
round(max(BYTES)/(1024*1024)) MaxMeg,
round(avg(BYTES)/(1024*1024)) AvgMeg,
count(BYTES) Num
from dba_free_space
group by tablespace_name
order by sum(BYTES)/(1024*1024) desc
;

spool off
