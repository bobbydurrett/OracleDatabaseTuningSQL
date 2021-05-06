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
spool &ns.tables.log

select 
t.owner,
t.table_name,
t.tablespace_name,
((t.blocks*s.block_size)/(1024*1024)) Meg,
t.num_rows
from 
dba_tables t,
dba_tablespaces s
where t.blocks is not null and
((t.blocks*s.block_size)/(1024*1024)) > 100 and
t.tablespace_name=s.tablespace_name and
t.owner <> 'SYS'
order by t.blocks desc;

spool off
