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
set serveroutput on size 1000000

spool &ns.findsql.log

-- edit the where clause of the TEXT_CURSOR so you search the SQL_TEXT clob for text that
-- is in the SQL you want to find in the AWR

set define off

set timing on

alter session set db_securefile='PERMITTED';

drop table findsqlresults;

create table findsqlresults as select SQL_ID,
            SQL_TEXT
        FROM DBA_HIST_SQLTEXT 
        where 1=2;

DECLARE 
    CURSOR SQL_CURSOR IS 
        SELECT DISTINCT 
            SQL_ID,
            DBID
        FROM DBA_HIST_SQLSTAT; 
    SQL_REC SQL_CURSOR%ROWTYPE;
    CURSOR TEXT_CURSOR(SQL_ID_ARGUMENT VARCHAR2,DBID_ARGUMENT NUMBER) IS 
        SELECT  
            SQL_ID,
            SQL_TEXT
        FROM DBA_HIST_SQLTEXT
        WHERE 
            SQL_TEXT like '%a.FISC_WK_OF_Yr < to_number(to_char(sysdate+1, ''iW''))%' and
            SQL_ID = SQL_ID_ARGUMENT and
            DBID = DBID_ARGUMENT;
    TEXT_REC TEXT_CURSOR%ROWTYPE;
BEGIN
    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;

        OPEN TEXT_CURSOR(SQL_REC.SQL_ID,SQL_REC.DBID);
        LOOP
            FETCH TEXT_CURSOR INTO TEXT_REC;
            EXIT WHEN TEXT_CURSOR%NOTFOUND;
            insert into findsqlresults values (TEXT_REC.SQL_ID,TEXT_REC.SQL_TEXT);
            commit;
         END LOOP;
        CLOSE TEXT_CURSOR;
     END LOOP;
    CLOSE SQL_CURSOR;
END;
/
show errors

select * from findsqlresults;

spool off
