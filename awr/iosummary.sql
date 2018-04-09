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

spool &ns.iosummary.log

select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
sum((after.PHYBLKRD - before.PHYBLKRD)*after.BLOCK_SIZE)/(1024*1024) megabytes_read,
sum((after.PHYBLKWRT - before.PHYBLKWRT)*after.BLOCK_SIZE)/(1024*1024) megabytes_written,
sum((after.PHYBLKRD - before.PHYBLKRD+after.PHYBLKWRT - before.PHYBLKWRT)*after.BLOCK_SIZE)/(1024*1024) total_megabytes,
trunc(10000*sum(after.READTIM-before.READTIM)/
sum(1+after.PHYRDS+-before.PHYRDS)) "ave read time (mu)",
trunc(10000*sum(after.WRITETIM-before.WRITETIM)/
sum(1+after.PHYWRTS+-before.PHYWRTS)) "ave write time (mu)"
from DBA_HIST_FILESTATXS before, DBA_HIST_FILESTATXS after,DBA_HIST_SNAPSHOT sn
where 
after.file#=before.file# and
after.snap_id=before.snap_id+1 and
before.instance_number=after.instance_number and
after.snap_id=sn.snap_id and
after.instance_number=sn.instance_number and
after.PHYBLKRD >= before.PHYBLKRD and
after.PHYBLKWRT >= before.PHYBLKWRT and
after.READTIM >= before.READTIM and
after.WRITETIM >= before.WRITETIM and
after.PHYRDS >= before.PHYRDS and
after.PHYWRTS >= before.PHYWRTS
group by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS')
order by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS');

spool off
