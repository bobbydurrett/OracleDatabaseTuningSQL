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

spool &ns.spaceused.log

-- List by tablespace the space used by the table and its indexes.

UNDEFINE TABOWNER
UNDEFINE TABNAME



select tablespace_name,
sum(bytes) Bytes,
sum(bytes)/(1024*1024) Megabytes,
sum(bytes)/(1024*1024*1024) Gigabytes
from
(select tablespace_name,bytes
from dba_segments
where 
(owner,segment_name) in 
(('&&TABOWNER','&&TABNAME')) and
segment_type in ('TABLE','TABLE PARTITION','TABLE SUBPARTITION')
union all
select s.tablespace_name,s.bytes
from dba_segments s, dba_indexes i
where 
(i.table_owner,i.table_name) in 
(('&&TABOWNER','&&TABNAME'))
and
i.owner=s.owner and
i.index_name=s.segment_name
and
segment_type in ('INDEX','INDEX PARTITION','INDEX SUBPARTITION')
)
group by tablespace_name
order by tablespace_name;

spool off
