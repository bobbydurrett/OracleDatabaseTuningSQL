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

spool &ns.vsqlarea.log

-- Performance information for one SQL_ID or
-- one FORCE_MATCHING_SIGNATURE
-- from V$SQLAREA
--
-- Can use SQL_ID = 'your sql id' or
-- FORCE_MATCHING_SIGNATURE = your force matching signature

column FORCE_MATCHING_SIGNATURE format 99999999999999999999

select
to_char(LAST_ACTIVE_TIME,'YYYY-MM-DD HH24:MI:SS') LAST_ACTIVE,
SQL_ID,
PLAN_HASH_VALUE,
FORCE_MATCHING_SIGNATURE
from V$SQLAREA
where FORCE_MATCHING_SIGNATURE = 3600919928426669859
order by LAST_ACTIVE_TIME desc;

spool off
