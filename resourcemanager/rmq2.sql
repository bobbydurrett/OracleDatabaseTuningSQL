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

spool &ns.rmq2.log

set define off

select * from V$RSRC_CONS_GROUP_HISTORY ;
select * from V$RSRC_CONSUMER_GROUP ;
select * from V$RSRC_CONSUMER_GROUP_CPU_MTH ;
select * from V$RSRC_PLAN ;
select * from V$RSRC_PLAN_CPU_MTH ;
select * from V$RSRC_PLAN_HISTORY ;
select * from V$RSRC_SESSION_INFO ;
select * from V$RSRCMGRMETRIC ;
select * from V$RSRCMGRMETRIC_HISTORY ;

set linesize 80

describe V$RSRC_CONS_GROUP_HISTORY 
describe V$RSRC_CONSUMER_GROUP 
describe V$RSRC_CONSUMER_GROUP_CPU_MTH 
describe V$RSRC_PLAN 
describe V$RSRC_PLAN_CPU_MTH 
describe V$RSRC_PLAN_HISTORY 
describe V$RSRC_SESSION_INFO 
describe V$RSRCMGRMETRIC 
describe V$RSRCMGRMETRIC_HISTORY 

spool off
