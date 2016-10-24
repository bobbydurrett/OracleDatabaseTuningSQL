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

spool &ns.ashdump.log

set define off

select 
*
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('02-FEB-2012 15:06:37','DD-MON-YYYY HH24:MI:SS')
and 
to_date('02-FEB-2012 15:06:47','DD-MON-YYYY HH24:MI:SS');

spool off
                 
        