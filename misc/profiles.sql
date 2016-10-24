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

spool &ns.profiles.log

set define off

select distinct 
p.name sql_profile_name,
s.sql_id
from 
dba_sql_profiles p,
DBA_HIST_SQLSTAT s
where
p.name=s.sql_profile(+);

spool off
