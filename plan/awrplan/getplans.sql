set linesize 32000
set pagesize 1000
set long 2000000000
set longchunksize 1000
set trimspool on

set head off;
set verify off;
set termout off;
 
column u new_value us noprint;
column n new_value ns noprint;
 
select name n from v$database;
select user u from dual;
set sqlprompt &ns:&us>

set head off
set echo off
set termout off
set feedback off
set serveroutput on size 1000000

-- gets the plans from the awr tables for the given SQL_ID
-- outputs them by snaptime
-- pass SQL_ID as parameter

UNDEFINE PLAN_SQL_ID

spool allplans.sql

DECLARE 
    CURSOR PLAN_CURSOR IS 
        SELECT
            MAX(SNAP_ID) MAX_SNAP_ID,
            PLAN_HASH_VALUE
        FROM DBA_HIST_SQLSTAT
        WHERE SQL_ID='&&1'
        GROUP BY PLAN_HASH_VALUE
        ORDER BY MAX_SNAP_ID,PLAN_HASH_VALUE;
    PLAN_REC PLAN_CURSOR%ROWTYPE;

BEGIN
    OPEN PLAN_CURSOR;
LOOP
    FETCH PLAN_CURSOR INTO PLAN_REC;
    EXIT WHEN PLAN_CURSOR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('SELECT TO_CHAR(max(END_INTERVAL_TIME),''YYYY-MM-DD HH24:MI:SS'') '||
      'FROM DBA_HIST_SNAPSHOT WHERE SNAP_ID = ' ||
      PLAN_REC.MAX_SNAP_ID||';');
    DBMS_OUTPUT.PUT_LINE('select * from table(DBMS_XPLAN.DISPLAY_AWR('||
      '''&&1'','''||
      PLAN_REC.PLAN_HASH_VALUE||''',NULL,''OUTLINE''));');
END LOOP;
CLOSE PLAN_CURSOR;
END;
/

spool off

set markup html preformat on

spool &&1.&ns.getplans.log

@allplans.sql

spool off

exit