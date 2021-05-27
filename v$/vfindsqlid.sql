set linesize 1000
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
set serveroutput on size 1000000

spool &ns.vfindsqlid.log

select
distinct sql_id
from
V$SQL
where
upper(SQL_FULLTEXT) like '%SOMETEXT%'
order by sql_id;

spool off
