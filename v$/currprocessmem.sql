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

spool &ns.currprocessmem.log

select
count(*) num_processes,
sum(totalloc)/(1024*1024*1024) total_gig,
avg(totalloc)/(1024*1024) avg_meg,
max(totalloc)/(1024*1024) max_meg,
min(totalloc)/(1024*1024) min_meg
from
(select 
pid,
sum(allocated) totalloc
from V$PROCESS_MEMORY
group by pid);

spool off
