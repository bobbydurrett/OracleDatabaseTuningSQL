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
set echo off
set termout off
set trimspool on
set feedback off

set serveroutput on size 1000000

-- Pass the name of the user as the first argument
-- to this script. Will report on that users system
-- and table privileges.

-- create tables for procedure

drop table my_sys_privs;
drop table my_tab_privs;
drop table my_role_privs;

create table my_sys_privs as 
select privilege
from dba_sys_privs where 1=2;

create table my_tab_privs as
select owner,table_name,privilege
from dba_tab_privs where 1=2;

create table my_role_privs as
select granted_role
from dba_role_privs where 1=2;

DECLARE
  user_name varchar2(2000);
  curr_role varchar2(2000);
BEGIN

-- set to name of user that you want to find all
-- system and table privileges for
-- argument to script

  user_name := '&&1';

-- do initial load of tables with users privileges

-- empty tables

  delete from my_sys_privs;
  delete from my_tab_privs;
  delete from my_role_privs;
  commit;
  
-- insert into tables

  insert into my_sys_privs
  select distinct privilege
  from dba_sys_privs 
  where grantee=user_name;

  insert into my_tab_privs
  select distinct owner,table_name,privilege
  from dba_tab_privs 
  where grantee=user_name;

  insert into my_role_privs
  select distinct granted_role
  from dba_role_privs 
  where grantee=user_name;
  
  commit;
  
-- loop through roles filling out sys and tab privs 
-- until all roles are removed

  LOOP
  
-- get a role if any exist and remove from list of roles

    select min(granted_role) into curr_role from my_role_privs;
    EXIT WHEN (curr_role is null);
    delete from my_role_privs where granted_role=curr_role;
    commit;
    
-- add sys,tab,and role privs from that role
-- if they are not already in tables
    
    insert into my_sys_privs
    select distinct privilege
    from dba_sys_privs 
    where grantee=curr_role and
    privilege not in
    (select privilege 
     from my_sys_privs);
  
    insert into my_tab_privs
    select distinct owner,table_name,privilege
    from dba_tab_privs 
    where grantee=curr_role and
    (owner,table_name,privilege) not in
    (select owner,table_name,privilege 
     from my_tab_privs);
  
    insert into my_role_privs
    select distinct granted_role
    from dba_role_privs 
    where grantee=curr_role and
    granted_role not in
    (select granted_role 
     from my_role_privs);
     
    commit;
    
  END LOOP;
  
END;
/
show errors

column owner format a20
column privilege format a40
column granted_role format a20

spool &ns.&&1.userprivs.log

execute dbms_output.put_line('System privileges for user '||'&&1');

select * from my_sys_privs
order by privilege;

execute dbms_output.put_line('---------------------------------');
execute dbms_output.put_line('Table privileges for user '||'&&1');

select owner,privilege,count(*)
from my_tab_privs
group by owner,privilege
order by owner,privilege;

spool off
exit
