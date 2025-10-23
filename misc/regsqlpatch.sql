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

spool &ns.regsqlpatch.log

column ID format 99
column ACTION_TIME format A30
column LOGFILE format A110

select 
INSTALL_ID ID,
PATCH_ID,
PATCH_TYPE,
ACTION,
STATUS,
ACTION_TIME,
DESCRIPTION,
LOGFILE
from 
DBA_REGISTRY_SQLPATCH;

spool off
