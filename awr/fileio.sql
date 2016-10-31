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

spool &ns.fileio.log

select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
sum(after.PHYRDS+after.PHYWRTS-before.PHYWRTS-before.PHYRDS) "number of IOs",
trunc(10*sum(after.READTIM+after.WRITETIM-before.WRITETIM-before.READTIM)/
sum(1+after.PHYRDS+after.PHYWRTS-before.PHYWRTS-before.PHYRDS)) "ave IO time (ms)",
trunc((select value from v$parameter where name='db_block_size')*
sum(after.PHYBLKRD+after.PHYBLKWRT-before.PHYBLKRD-before.PHYBLKWRT)/
sum(1+after.PHYRDS+after.PHYWRTS-before.PHYWRTS-before.PHYRDS)) "ave IO size (bytes)"
from DBA_HIST_FILESTATXS before, DBA_HIST_FILESTATXS after,DBA_HIST_SNAPSHOT sn
where 
after.file#=before.file# and
after.snap_id=before.snap_id+1 and
before.instance_number=after.instance_number and
after.snap_id=sn.snap_id and
after.instance_number=sn.instance_number
group by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS')
order by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS');

spool off
