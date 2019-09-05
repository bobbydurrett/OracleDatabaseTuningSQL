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

spool &ns.directwrites.log

-- Shows the amount of Direct Write I/O
-- This should correspond to insert /*+append */ inserts or other nologging operations

select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
after.SMALL_WRITE_MEGABYTES+after.LARGE_WRITE_MEGABYTES-before.SMALL_WRITE_MEGABYTES-before.LARGE_WRITE_MEGABYTES "Direct Write(MB)"
from DBA_HIST_IOSTAT_FUNCTION before, DBA_HIST_IOSTAT_FUNCTION after,DBA_HIST_SNAPSHOT sn
where 
after.snap_id=before.snap_id+1 and
before.instance_number=after.instance_number and
after.snap_id=sn.snap_id and
after.instance_number=sn.instance_number and
after.FUNCTION_NAME = 'Direct Writes' and
before.FUNCTION_NAME = after.FUNCTION_NAME and
before.SMALL_WRITE_MEGABYTES+before.LARGE_WRITE_MEGABYTES <= after.SMALL_WRITE_MEGABYTES+after.LARGE_WRITE_MEGABYTES
order by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS');

spool off
