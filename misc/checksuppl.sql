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

SELECT SUPPLEMENTAL_LOG_DATA_MIN,LOG_MODE FROM V$DATABASE;

select 
table_name
from 
dba_tables
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'AUDIT_LOG',
'CDMR',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_ACLINE',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_LINE',
'CDMR_ADJ_NONINVOICE',
'CDMR_INVOICE_LINE',
'CDMR_MOREINFO',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE',
'CDMR_REQ_APPROVERS',
'CMDR_COMMENTS',
'REQUISITION'
)
order by table_name;

SELECT *
FROM dba_log_groups
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'AUDIT_LOG',
'CDMR',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_ACLINE',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_LINE',
'CDMR_ADJ_NONINVOICE',
'CDMR_INVOICE_LINE',
'CDMR_MOREINFO',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE',
'CDMR_REQ_APPROVERS',
'CMDR_COMMENTS',
'REQUISITION'
)
order by table_name;

select * from
dba_tab_privs
where
OWNER = 'WMCOMMADM'
AND table_name in
(
'AUDIT_LOG',
'CDMR',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_ACLINE',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_LINE',
'CDMR_ADJ_NONINVOICE',
'CDMR_INVOICE_LINE',
'CDMR_MOREINFO',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE',
'CDMR_REQ_APPROVERS',
'CMDR_COMMENTS',
'REQUISITION') and
GRANTEE = 'FIVETRAN'
and
PRIVILEGE = 'SELECT'
order by table_name;

SELECT *
FROM ALL_CONSTRAINTS
WHERE owner = 'WMCOMMADM'
AND table_name in
(
'AUDIT_LOG',
'CDMR',
'CDMR_ADJ_ACHEADER',
'CDMR_ADJ_ACLINE',
'CDMR_ADJ_CANOINVOICE',
'CDMR_ADJ_HEADER',
'CDMR_ADJ_LINE',
'CDMR_ADJ_NONINVOICE',
'CDMR_INVOICE_LINE',
'CDMR_MOREINFO',
'CDMR_MOREINFO_ITEMS',
'CDMR_REASONCODE',
'CDMR_REQ_APPROVERS',
'CMDR_COMMENTS',
'REQUISITION')
AND constraint_type='P'
order by table_name;

spool off
