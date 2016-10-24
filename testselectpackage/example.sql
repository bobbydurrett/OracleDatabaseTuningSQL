set linesize 32000
set pagesize 1000
set long 2000000000
set longchunksize 1000
set echo on
set termout on
set trimspool on
set serveroutput on size 1000000

spool example.log

-- show database version

select * from v$version;

-- create example users
-- produser - represents prod schema on prod database
-- testuser - test user on test database
-- for this test is one database but works with two.

create user produser identified by produser;

grant create session to produser;
grant select any dictionary to produser;
grant resource to produser;
grant select any table to produser;
grant execute any procedure to produser;
grant create procedure to produser;
grant execute on SYS.dbms_workload_repository to produser;

create user testuser identified by testuser;

grant create session to testuser;
grant select any dictionary to testuser;
grant resource to testuser;
grant select any table to testuser;
grant execute any procedure to testuser;
grant create procedure to testuser;
grant create database link to testuser;

connect produser/produser

-- create table and load it with data

create table test_table as select * from dba_tables;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

insert /*+append */ into test_table select * from test_table
where table_name <> 'DUAL';
commit;

execute dbms_stats.gather_table_stats('PRODUSER','TEST_TABLE');

execute dbms_workload_repository.create_snapshot;

-- query that would benefit from an index

select blocks from produser.test_table where owner='SYS' and table_name='DUAL';

-- query that wouldn't benefit from an index

select sum(blocks) from produser.test_table;

execute dbms_workload_repository.create_snapshot;

-- install package

drop table plan_table;

@$ORACLE_HOME/rdbms/admin/utlxplan.sql

@tables.sql
@package.sql

begin

TEST_SELECT.collect_select_statements(
   max_number_selects=>100,
   include_pattern1=> '%produser.test_table%');

end;
/

select * from select_statements order by sqlnumber;

connect testuser/testuser

-- install package

drop table plan_table;

@$ORACLE_HOME/rdbms/admin/utlxplan.sql

@tables.sql
@package.sql

-- create dblink to produser
-- assumes tnsnames.ora entry
-- is orcl

drop database link mylink;

create database link mylink
connect to produser 
identified by produser
using 'orcl';

select * from dual@mylink;

-- copy select statements from produser
-- and dump out to show they are there.

execute TEST_SELECT.copy_select_statements('MYLINK');

select * from select_statements order by sqlnumber;

-- get plans for the select statements - no index

execute TEST_SELECT.get_explain_plans('NOINDEX');

select * from test_results;

-- add index

connect produser/produser

create index test_index on test_table (owner,table_name);

execute dbms_stats.gather_index_stats('PRODUSER','TEST_INDEX');

-- get plans for the select statements - index in place

connect testuser/testuser

execute TEST_SELECT.get_explain_plans('INDEX');

select * from test_results;

-- execute only the queries whose plans are different - with index

execute TEST_SELECT.execute_diff_plans('INDEX','NOINDEX');

-- drop index and reexecute same queries with different plans
-- with no index.

connect produser/produser

drop index test_index;

connect testuser/testuser

execute TEST_SELECT.execute_diff_plans('NOINDEX','INDEX');

select * from test_results;

-- show comparison

set serveroutput on size 1000000

execute TEST_SELECT.display_results('NOINDEX','INDEX');

-- run all queries no index

execute TEST_SELECT.execute_all('NOINDEX');

-- put the index back and rerun all with the index

-- add index

connect produser/produser

create index test_index on test_table (owner,table_name);

execute dbms_stats.gather_index_stats('PRODUSER','TEST_INDEX');

connect testuser/testuser
 
execute TEST_SELECT.execute_all('INDEX');

select * from test_results;

set serveroutput on size 1000000

execute TEST_SELECT.display_results('NOINDEX','INDEX');

-- update select statements to make them error

execute TEST_SELECT.update_select_statements('sum(blocks)','WRONG');

execute TEST_SELECT.execute_all('INDEX');

select * from test_results;

-- fix errors and rerun the ones that errored only.

execute TEST_SELECT.update_select_statements('WRONG','sum(blocks)');

execute TEST_SELECT.reexecute_errored('INDEX');

select * from test_results;

-- show the plans - explained and executed

select 
TEST_SELECT.show_explained_plan('NOINDEX',1)
from dual;

set serveroutput on size 1000000

execute test_select.show_executed_plan('NOINDEX',1);

spool off
