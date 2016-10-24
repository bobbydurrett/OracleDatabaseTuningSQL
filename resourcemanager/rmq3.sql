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

spool &ns.rmq3.log

set define off

select * from DBA_HIST_RSRC_CONSUMER_GROUP ;
select * from DBA_HIST_RSRC_PLAN ;

set linesize 80

describe DBA_HIST_RSRC_CONSUMER_GROUP 
describe DBA_HIST_RSRC_PLAN 

spool off
