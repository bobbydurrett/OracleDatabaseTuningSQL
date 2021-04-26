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

spool &ns.noprofile.log

-- based on findsql.sql and profiles.sql
-- search for a string or strings to define a 
-- group of sql statements that you want to have
-- sql profiles and exclude any that already have
-- sql profiles.

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
            upper(SQL_TEXT) like '%MY_TABLE%' and
            (upper(SQL_TEXT) like 'SELECT%' or
             upper(SQL_TEXT) like 'WITH%') and
            upper(SQL_TEXT) not like '%DS_SVC%' and
            upper(SQL_TEXT) not like '%DBMS_METADATA%' and
            upper(SQL_TEXT) not like '%SYS.%' and
            upper(SQL_TEXT) not like '%DBMS_STATS%' and
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

drop table noprofiles;

create table noprofiles as
select 
f.SQL_ID
from 
findsqlresults f
minus
select 
f.SQL_ID
from 
findsqlresults f,
dba_sql_profiles p
where
p.name like 'coe_'||f.SQL_ID||'%';


select 
* 
from 
findsqlresults
where sql_id in
(select 
SQL_ID
from 
noprofiles);

select 
sql_id,
plan_hash_value,
END_INTERVAL_TIME,
executions_delta,
ELAPSED_TIME_DELTA/(nonzeroexecutions*1000) "Elapsed Average ms",
CPU_TIME_DELTA/(nonzeroexecutions*1000) "CPU Average ms",
IOWAIT_DELTA/(nonzeroexecutions*1000) "IO Average ms",
CLWAIT_DELTA/(nonzeroexecutions*1000) "Cluster Average ms",
APWAIT_DELTA/(nonzeroexecutions*1000) "Application Average ms",
CCWAIT_DELTA/(nonzeroexecutions*1000) "Concurrency Average ms",
BUFFER_GETS_DELTA/nonzeroexecutions "Average buffer gets",
DISK_READS_DELTA/nonzeroexecutions "Average disk reads",
trunc(PHYSICAL_WRITE_BYTES_DELTA/(1024*1024*nonzeroexecutions)) "Average disk write megabytes",
ROWS_PROCESSED_DELTA/nonzeroexecutions "Average rows processed"
from
(select 
ss.snap_id,
ss.sql_id,
ss.plan_hash_value,
sn.END_INTERVAL_TIME,
ss.executions_delta,
case ss.executions_delta when 0 then 1 else ss.executions_delta end nonzeroexecutions,
ELAPSED_TIME_DELTA,
CPU_TIME_DELTA,
IOWAIT_DELTA,
CLWAIT_DELTA,
APWAIT_DELTA,
CCWAIT_DELTA,
BUFFER_GETS_DELTA,
DISK_READS_DELTA,
PHYSICAL_WRITE_BYTES_DELTA,
ROWS_PROCESSED_DELTA
from DBA_HIST_SQLSTAT ss,DBA_HIST_SNAPSHOT sn,noprofiles np
where ss.sql_id = np.sql_id
and ss.snap_id=sn.snap_id
and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER)
where ELAPSED_TIME_DELTA > 0
order by sql_id,snap_id;

spool off
