-- create imp parfile for each owner in tablelist
-- takes oracle userid and password as parameters
set echo off
set termout off
set heading off
set feedback off
set newpage none
set linesize 1000
set trimspool on
set verify off

spool allimp.sql

select distinct '@makeoneimp &1 &2 '||table_owner from tablelist;

spool off

@allimp

exit
