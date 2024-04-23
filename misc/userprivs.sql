set linesize 32000
set pagesize 50000
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
column table_name format a80

spool &ns.&&1.userprivs.log

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('**************************************************************************************');
execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('Privileges granted directly to user '||'&&1');

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('Role privileges for user '||'&&1');

select distinct GRANTED_ROLE
from dba_role_privs 
where grantee='&&1'
order by GRANTED_ROLE;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('System privileges for user '||'&&1');

select distinct privilege
from dba_sys_privs 
where grantee='&&1'
order by privilege;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('Summarized table privileges for user '||'&&1');

select owner,privilege,count(*)
from dba_tab_privs 
where grantee='&&1'
group by owner,privilege
order by owner,privilege;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('Detailed table privileges for user '||'&&1');

select distinct privilege,owner,table_name
from dba_tab_privs 
where grantee='&&1'
order by privilege,owner,table_name;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('**************************************************************************************');


execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('Privileges granted through a role or directly to user '||'&&1');

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('System privileges for user '||'&&1');

select * from my_sys_privs
order by privilege;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('Summarized table privileges for user '||'&&1');

select owner,privilege,count(*)
from my_tab_privs
group by owner,privilege
order by owner,privilege;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('Detailed table privileges for user '||'&&1');

select privilege,owner,table_name
from my_tab_privs
order by privilege,owner,table_name;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('**************************************************************************************');
execute dbms_output.put_line(chr(9));

execute dbms_output.put_line('Account status, profile, last password change for user '||'&&1');

column account_status format a15
column profile format a10

select 
du.account_status,
du.profile,
to_char(u.ptime,'YYYY-MM-DD HH24:MI:SS') last_password_chng
from 
dba_users du, 
sys.user$ u
where 
du.username='&&1' and
du.username=u.name;

execute dbms_output.put_line(chr(9));
execute dbms_output.put_line('**************************************************************************************');
execute dbms_output.put_line(chr(9));


execute dbms_output.put_line('Role named '||'&&1');

select
role
from
dba_roles
where
role = '&&1';

spool off
exit
