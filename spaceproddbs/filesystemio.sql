set linesize 1000
set pagesize 1000
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
spool &ns.filesystemio.log
select 
substr(d.FILE_NAME,1,20) Filesystem,
sum(v.PHYRDS) "Physical Reads",         
sum(v.PHYWRTS) "Physical Writes",        
sum(v.PHYBLKRD)"Phys Blk Reads",       
sum(v.PHYBLKWRT) "Phys Blk Writes",
sum(v.READTIM) "Read Time",        
sum(v.WRITETIM) "Write Time",       
(sum(v.WRITETIM)+sum(v.READTIM))/(sum(v.PHYRDS)+sum(v.PHYWRTS)) "Ave IO Time"       
from 
dba_data_files d,v$filestat v
where
d.FILE_ID = v.FILE#
group by substr(d.FILE_NAME,1,20)
order by substr(d.FILE_NAME,1,20);
                       
spool off
