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

spool &ns.space.log

-- get the hourly tablespace size and used space
-- from the AWR views
-- With input from https://mydbaspace.wordpress.com/2013/03/08/unit-size-in-dba_hist_tbspc_space_usage/

set define off

select 
snap.END_INTERVAL_TIME,
sum(tsu.TABLESPACE_SIZE*dt.BLOCK_SIZE)/(1024*1024*1024) total_gigabytes,
sum(tsu.TABLESPACE_USEDSIZE*dt.BLOCK_SIZE)/(1024*1024*1024) used_gigabytes
from
DBA_HIST_TBSPC_SPACE_USAGE tsu,
DBA_HIST_SNAPSHOT snap,
V$TABLESPACE vt,
DBA_TABLESPACES dt
where
tsu.SNAP_ID = snap.SNAP_ID and
tsu.DBID = snap.DBID and
snap.instance_number = 1 and
tsu.TABLESPACE_ID = vt.TS# and
vt.NAME = dt.TABLESPACE_NAME
group by snap.END_INTERVAL_TIME
order by snap.END_INTERVAL_TIME;

spool off
                 
        