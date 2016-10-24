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

spool &ns.fmstosqlid.log

select ss.sql_id,count(*) entries
from DBA_HIST_SQLSTAT ss
where ss.FORCE_MATCHING_SIGNATURE = 2145581403433541363
group by sql_id
order by entries desc;

spool off
