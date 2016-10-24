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

spool &ns.tablelist.log

-- insert list of table owners and names

drop table tablelist;

create table tablelist as select table_owner,table_name,partition_name from dba_tab_partitions where 1=2;

insert into tablelist values ('MYOWNER','MYTABLE',NULL);
insert into tablelist values ('MYOWNER','MYTABLE','MYPARTITION');

commit;

spool off

exit
