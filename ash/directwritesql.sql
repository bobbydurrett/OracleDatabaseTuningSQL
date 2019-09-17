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

spool &ns.directwritesql.log

-- shows all of the sql_ids with direct path write waits
-- over all of the ASH history

select 
sql_id,count(*) active
from DBA_HIST_ACTIVE_SESS_HISTORY a
where
event = 'direct path write'
group by sql_id
order by active desc;

spool off
                 
        