set linesize 1000
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

spool &ns.ashplans.log

column SQL_PLAN_OPERATION format a30
column SQL_PLAN_OPTIONS format a30

SELECT
    ash.sql_plan_hash_value,
    ash.sql_plan_line_id,
    ash.sql_plan_operation,
    ash.sql_plan_options,
    COUNT(*)                           AS sample_count
FROM
    dba_hist_active_sess_history ash
WHERE
    ash.sql_id = 'b4rj0h8hh0sxf' and
    sample_time 
    between 
    to_date('01-JUL-2026 00:00:00','DD-MON-YYYY HH24:MI:SS')
    and 
    to_date('09-JUL-2026 00:00:00','DD-MON-YYYY HH24:MI:SS')
GROUP BY
    ash.sql_plan_hash_value,
    ash.sql_plan_line_id,
    ash.sql_plan_operation,
    ash.sql_plan_options
ORDER BY
    ash.sql_plan_hash_value,
    ash.sql_plan_line_id,
    ash.sql_plan_operation,
    ash.sql_plan_options;

spool off
                 