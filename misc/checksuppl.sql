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

spool &ns.checksuppl.log


select * from dba_users where username='AWSDMS';
select * from dba_role_privs where grantee='AWSDMS';
select * from dba_sys_privs where grantee='AWSDMS';
select * from dba_tab_privs where grantee='AWSDMS';

SELECT 
LOG_MODE,
SUPPLEMENTAL_LOG_DATA_MIN MIN, 
SUPPLEMENTAL_LOG_DATA_PK PK, 
SUPPLEMENTAL_LOG_DATA_UI UI, 
SUPPLEMENTAL_LOG_DATA_ALL ALL_LOG 
FROM V$DATABASE;


select 
table_name
from 
dba_tables
WHERE owner = 'CASADM'
AND table_name in
(
'CMPLY_REB_SLS_DTL'
)
order by table_name;

SELECT *
FROM dba_log_groups
WHERE owner = 'CASADM'
AND table_name in
(
'CMPLY_REB_SLS_DTL'
)
order by table_name;

select * from
dba_tab_privs
where
OWNER = 'CASADM'
AND table_name in
(
'CMPLY_REB_SLS_DTL'
) and
GRANTEE = 'AWSDMS'
and
PRIVILEGE = 'SELECT'
order by table_name;

SELECT *
FROM ALL_CONSTRAINTS
WHERE owner = 'CASADM'
AND table_name in
(
'CMPLY_REB_SLS_DTL'
)
AND constraint_type='P'
order by table_name;

spool off
