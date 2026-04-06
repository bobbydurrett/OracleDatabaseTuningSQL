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


select * from dba_users where username='FIVETRAN';
select * from dba_role_privs where grantee='FIVETRAN';
select * from dba_sys_privs where grantee='FIVETRAN';
select * from dba_tab_privs where grantee='FIVETRAN';

SELECT 
LOG_MODE,
FORCE_LOGGING,
SUPPLEMENTAL_LOG_DATA_MIN MIN, 
SUPPLEMENTAL_LOG_DATA_PK PK, 
SUPPLEMENTAL_LOG_DATA_UI UI, 
SUPPLEMENTAL_LOG_DATA_ALL ALL_LOG 
FROM V$DATABASE;


select 
table_name
from 
dba_tables
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'REQUISITION',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_NONINVOICE',
'CMDR_COMMENTS',
'CDMR',
'CDMR_INVOICE_LINE',
'AUDIT_LOG',
'CDMR_REQ_APPROVERS',
'CDMR_MOREINFO',
'CDMR_ADJ_LINE',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE'
)
order by table_name;

SELECT *
FROM dba_log_groups
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'REQUISITION',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_NONINVOICE',
'CMDR_COMMENTS',
'CDMR',
'CDMR_INVOICE_LINE',
'AUDIT_LOG',
'CDMR_REQ_APPROVERS',
'CDMR_MOREINFO',
'CDMR_ADJ_LINE',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE'
)
order by table_name;

select * from
dba_tab_privs
where
OWNER = 'WMCOMMADM'
AND table_name in
(
'REQUISITION',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_NONINVOICE',
'CMDR_COMMENTS',
'CDMR',
'CDMR_INVOICE_LINE',
'AUDIT_LOG',
'CDMR_REQ_APPROVERS',
'CDMR_MOREINFO',
'CDMR_ADJ_LINE',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE'
) and
GRANTEE = 'FIVETRAN'
and
PRIVILEGE = 'SELECT'
order by table_name;

SELECT *
FROM ALL_CONSTRAINTS
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'REQUISITION',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_NONINVOICE',
'CMDR_COMMENTS',
'CDMR',
'CDMR_INVOICE_LINE',
'AUDIT_LOG',
'CDMR_REQ_APPROVERS',
'CDMR_MOREINFO',
'CDMR_ADJ_LINE',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE'
)
AND constraint_type='P'
order by table_name;

-- alter statements

SELECT 
'ALTER TABLE '||OWNER||'.'||TABLE_NAME||' ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;'
FROM ALL_CONSTRAINTS
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'REQUISITION',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_NONINVOICE',
'CMDR_COMMENTS',
'CDMR',
'CDMR_INVOICE_LINE',
'AUDIT_LOG',
'CDMR_REQ_APPROVERS',
'CDMR_MOREINFO',
'CDMR_ADJ_LINE',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE'
)
AND constraint_type='P'
order by table_name;

select
'ALTER TABLE '||OWNER||'.'||TABLE_NAME||' ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;'
from
(select 
owner,
table_name
from 
dba_tables
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'REQUISITION',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_NONINVOICE',
'CMDR_COMMENTS',
'CDMR',
'CDMR_INVOICE_LINE',
'AUDIT_LOG',
'CDMR_REQ_APPROVERS',
'CDMR_MOREINFO',
'CDMR_ADJ_LINE',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE'
)
minus
SELECT 
owner,
table_name
FROM ALL_CONSTRAINTS
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'REQUISITION',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_NONINVOICE',
'CMDR_COMMENTS',
'CDMR',
'CDMR_INVOICE_LINE',
'AUDIT_LOG',
'CDMR_REQ_APPROVERS',
'CDMR_MOREINFO',
'CDMR_ADJ_LINE',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE'
)
AND constraint_type='P')
order by
table_name;

-- directories for binary log reader

column directory_path format a80

select directory_name,directory_path
from
dba_directories
where
directory_name in
(
'FIVETRAN_LOGDIR',
'FIVETRAN_ONLINE_LOGDIR1',
'FIVETRAN_ONLINE_LOGDIR2',
'FIVETRAN_ONLINE_LOGDIR',
'FIVETRAN_ASM_STG_DIR'
)
order by
directory_name;

spool off
