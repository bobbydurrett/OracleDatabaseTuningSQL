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

spool &ns.nologging.log

-- Estimate of the amount of NOLOGGING I/O in between two snapshots.
-- Idea is that DBWR + Direct Writes write I/O minus the LGWR write I/O
-- roughly corresponds to the amount of NOLOGGING I/O through something 
-- like an insert with append hint

select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
(adirect.SMALL_WRITE_MEGABYTES+adirect.LARGE_WRITE_MEGABYTES-bdirect.SMALL_WRITE_MEGABYTES-bdirect.LARGE_WRITE_MEGABYTES)+
(adbwr.SMALL_WRITE_MEGABYTES+adbwr.LARGE_WRITE_MEGABYTES-bdbwr.SMALL_WRITE_MEGABYTES-bdbwr.LARGE_WRITE_MEGABYTES)-
(algwr.SMALL_WRITE_MEGABYTES+algwr.LARGE_WRITE_MEGABYTES-blgwr.SMALL_WRITE_MEGABYTES-blgwr.LARGE_WRITE_MEGABYTES) NOLOGGING_MEGABYTES
from 
DBA_HIST_IOSTAT_FUNCTION bdirect, 
DBA_HIST_IOSTAT_FUNCTION adirect,
DBA_HIST_IOSTAT_FUNCTION bdbwr, 
DBA_HIST_IOSTAT_FUNCTION adbwr,
DBA_HIST_IOSTAT_FUNCTION blgwr, 
DBA_HIST_IOSTAT_FUNCTION algwr,
DBA_HIST_SNAPSHOT sn
where 
adirect.snap_id=bdirect.snap_id+1 and
adirect.snap_id=adbwr.snap_id and
adirect.snap_id=algwr.snap_id and
bdirect.snap_id=bdbwr.snap_id and
bdirect.snap_id=blgwr.snap_id and
bdirect.instance_number=adirect.instance_number and
bdbwr.instance_number=adbwr.instance_number and
blgwr.instance_number=algwr.instance_number and
adirect.snap_id=sn.snap_id and
adirect.instance_number=sn.instance_number and
adirect.instance_number=1 and
adirect.FUNCTION_NAME = 'Direct Writes' and
bdirect.FUNCTION_NAME = adirect.FUNCTION_NAME and
adbwr.FUNCTION_NAME = 'DBWR' and
bdbwr.FUNCTION_NAME = adbwr.FUNCTION_NAME and
algwr.FUNCTION_NAME = 'LGWR' and
blgwr.FUNCTION_NAME = algwr.FUNCTION_NAME and
(adirect.SMALL_WRITE_MEGABYTES+adirect.LARGE_WRITE_MEGABYTES-bdirect.SMALL_WRITE_MEGABYTES-bdirect.LARGE_WRITE_MEGABYTES)+
(adbwr.SMALL_WRITE_MEGABYTES+adbwr.LARGE_WRITE_MEGABYTES-bdbwr.SMALL_WRITE_MEGABYTES-bdbwr.LARGE_WRITE_MEGABYTES)-
(algwr.SMALL_WRITE_MEGABYTES+algwr.LARGE_WRITE_MEGABYTES-blgwr.SMALL_WRITE_MEGABYTES-blgwr.LARGE_WRITE_MEGABYTES) >= 0
order by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS');

spool off
