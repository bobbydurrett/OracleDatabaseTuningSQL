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

set timing on

spool &ns.undo.log

select 
tablespace_name,
sum(bytes)/(1024*1024*1024) gigabytes
from dba_data_files
where 
tablespace_name like 'UNDO%'
group by tablespace_name
order by tablespace_name;

select 
substr(TABLESPACE_NAME,1,20) Tablespace,                        
round(sum(BYTES)/(1024*1024)) TotalMeg,
round(min(BYTES)/(1024*1024)) MinMeg,
round(max(BYTES)/(1024*1024)) MaxMeg,
round(avg(BYTES)/(1024*1024)) AvgMeg,
count(BYTES) Num
from dba_free_space
where tablespace_name like 'UNDO%'
group by tablespace_name
order by sum(BYTES)/(1024*1024) desc
;

select
INST_ID,
to_char(BEGIN_TIME,'YYYY-MM-DD HH24:MI:SS'),
UNDOBLKS,
MAXQUERYID,
NOSPACEERRCNT,
ACTIVEBLKS
from gV$UNDOSTAT
where 
to_char(begin_time,'YYYY-MM-DD') = '2021-05-15'
order by
INST_ID,
BEGIN_TIME;


spool off


