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

spool &ns.trace.log

drop table test;
drop table blah;

create table test (a number,b number);
create table blah (b number,c number);

insert into test select blocks,blocks from dba_tables;
insert into blah select blocks,blocks from dba_tables;

commit;

create index testindex on test(a);
create index blahindex on blah(b);

execute dbms_stats.gather_table_stats('MYUSER','TEST',cascade=>True);
execute dbms_stats.gather_table_stats('MYUSER','BLAH',cascade=>True);

-- 10053 trace won't work if plan is already in shared pool.
-- on my laptop flush shared pool.  On unix box alter a table in the sql or modify the sql
-- slightly.
-- alter system flush shared_pool;
-- alter table test nomonitoring;
-- alter table test monitoring;

alter session set max_dump_file_size = unlimited;
ALTER SESSION SET tracefile_identifier = 'bobbydurrett';
ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

-- set to 12 if you want bind variables

ALTER SESSION SET EVENTS '10046 trace name context forever, level 8';

select c from test,blah where a=100 and test.b=blah.b;

ALTER SESSION SET EVENTS '10053 trace name context OFF';
ALTER SESSION SET EVENTS '10046 trace name context OFF';

spool off
exit