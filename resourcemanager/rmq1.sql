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

spool &ns.rmq1.log

set define off

select * from DBA_RSRC_CATEGORIES ;
select * from DBA_RSRC_CONSUMER_GROUP_PRIVS order by GRANTEE, GRANTED_GROUP;
select * from DBA_RSRC_CONSUMER_GROUPS order by CONSUMER_GROUP_ID;
select * from DBA_RSRC_GROUP_MAPPINGS order by ATTRIBUTE, CONSUMER_GROUP, VALUE;
select * from DBA_RSRC_IO_CALIBRATE ;
select * from DBA_RSRC_MANAGER_SYSTEM_PRIVS order by GRANTEE;
select * from DBA_RSRC_MAPPING_PRIORITY ;
select * from DBA_RSRC_PLAN_DIRECTIVES order by PLAN, TYPE, GROUP_OR_SUBPLAN;
select * from DBA_RSRC_PLANS order by PLAN_ID;

set linesize 80

describe DBA_RSRC_CATEGORIES 
describe DBA_RSRC_CONSUMER_GROUP_PRIVS
describe DBA_RSRC_CONSUMER_GROUPS
describe DBA_RSRC_GROUP_MAPPINGS
describe DBA_RSRC_IO_CALIBRATE 
describe DBA_RSRC_MANAGER_SYSTEM_PRIVS
describe DBA_RSRC_MAPPING_PRIORITY 
describe DBA_RSRC_PLAN_DIRECTIVES
describe DBA_RSRC_PLANS

spool off
