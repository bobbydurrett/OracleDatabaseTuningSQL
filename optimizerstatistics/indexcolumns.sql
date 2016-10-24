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

spool &ns.indexcolumns.log

column table_name format a30
column index_name format a30
column column_name format a30
column column_expression format a30

select 
ic.table_name,
ic.INDEX_NAME,
ic.column_name,
ie.COLUMN_EXPRESSION
from DBA_IND_COLUMNS ic, tablelist t,DBA_IND_EXPRESSIONS ie
where ic.table_owner=t.table_owner and 
ic.table_name = t.table_name and
ie.index_owner(+)=ic.index_owner and
ie.index_name(+)=ic.index_name and
ie.column_position(+)=ic.column_position
order by ic.table_name,ic.index_name,ic.column_position;

spool off
