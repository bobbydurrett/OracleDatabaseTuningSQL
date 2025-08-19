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

spool &ns.tempsegments.log

column USERNAME format A20

select
u.username,
u.session_num, 
u.sql_id,
u.tablespace,
u.segtype,
(u.blocks * t.block_size)/(1024*1024*1024) gigabytes
from 
V$TEMPSEG_USAGE u,
dba_tablespaces t
where
u.tablespace=t.tablespace_name and
username is not null
order by blocks desc;

spool off
