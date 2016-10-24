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

spool &ns.findsql.log

select address,hash_value,SQL_TEXT  from v$sqltext outer
where (address,hash_value) in 
(select address,hash_value from v$sqltext inner
where SQL_TEXT like '%&SEARCHSTRING%')
order by address,hash_value,piece;

spool off