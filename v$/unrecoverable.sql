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

spool &ns.unrecoverable.log

-- includes ideas from http://www.dba-oracle.com/t_unrecoverable_data_file.htm

UNDEFINE DAYSOLD

column TABLESPACE_NAME format a30
column LATEST_UNRECOVERABLE_TIME format a30

select
ts.NAME TABLESPACE_NAME,
to_char(max(UNRECOVERABLE_TIME),'YYYY-MM-DD HH24:MI:SS') LATEST_UNRECOVERABLE_TIME,
count(df.FILE#) NUMBER_UNRECOVERABLE_DATAFILES
from 
v$datafile df, 
v$tablespace ts
where 
df.UNRECOVERABLE_CHANGE# <> 0 and
df.TS# = ts.TS# and
sysdate - UNRECOVERABLE_TIME < &&DAYSOLD
group by ts.name
order by LATEST_UNRECOVERABLE_TIME desc;

spool off
