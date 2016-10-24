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
spool &ns.segments.log

select 
substr(owner,1,20) Owner,
substr(SEGMENT_NAME,1,25) Name,
substr(PARTITION_NAME,1,25) Partition,
substr(SEGMENT_TYPE,1,20) Type,
tablespace_name,
((blocks*8192)/(1024*1024)) Meg,
EXTENTS,        
MAX_EXTENTS,
NEXT_EXTENT,    
PCT_INCREASE
from dba_segments 
where blocks is not null and
((blocks*8192)/(1024*1024)) > 100
order by blocks desc;

spool off
