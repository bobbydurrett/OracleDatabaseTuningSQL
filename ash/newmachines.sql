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

spool &ns.newmachines.log

-- show machines that are active today 
-- but were not last week to see which
-- are new

set define off

select 
distinct machine
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('31-OCT-2016 00:00:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('31-OCT-2016 12:00:00','DD-MON-YYYY HH24:MI:SS')
minus
select 
distinct machine
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('24-OCT-2016 00:00:00','DD-MON-YYYY HH24:MI:SS')
and 
to_date('24-OCT-2016 23:00:00','DD-MON-YYYY HH24:MI:SS');


spool off
                 
        