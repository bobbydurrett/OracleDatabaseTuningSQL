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

spool &ns.tablesizes.log

UNDEFINE TABSCHEMA

-- order the tables in schema TABSCHEMA in descending order by
-- total size. Prompts for TABSCHEMA.

drop table schematabs;

create table schematabs as
select table_name
from dba_tables
where owner='&&TABSCHEMA';

drop table schemainds;

create table schemainds as
select
t.table_name,i.owner index_owner,i.index_name
from
schematabs t,
dba_indexes i
where
i.table_owner = '&&TABSCHEMA' and
i.table_name = t.table_name;

drop table tabsize;

create table tabsize as
select
t.table_name,
sum(s.bytes) total_bytes
from
schematabs t,
dba_segments s
where
s.owner='&&TABSCHEMA' and
s.segment_name = t.table_name and
s.segment_type in ('TABLE','TABLE PARTITION','TABLE SUBPARTITION')
group by t.table_name;

drop table indsize;

create table indsize as
select
i.table_name,
sum(s.bytes) total_bytes
from
schemainds i,
dba_segments s
where
s.owner = i.index_owner and
s.segment_name = i.index_name
group by i.table_name;

-- list tables in descending size

select
t.table_name,
(t.total_bytes + i.total_bytes)/(1024 * 1024 * 1024) total_gigs
from
tabsize t,
indsize i
where
t.table_name = i.table_name
order by total_gigs desc;

-- total terabytes

select
sum(t.total_bytes + i.total_bytes)/(1024 * 1024 * 1024 * 1024) total_tb
from
tabsize t,
indsize i
where
t.table_name = i.table_name;

drop table schematabs;
drop table schemainds;
drop table tabsize;
drop table indsize;

spool off

exit

