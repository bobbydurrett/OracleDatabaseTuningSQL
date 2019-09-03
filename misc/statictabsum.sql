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

spool &ns.statictabsum.log

set timing on

UNDEFINE DAYSOLD
UNDEFINE TABSCHEMA

-- Finds tables and indexes in the TABSCHEMA schema whose last analyzed date is more than
-- DAYSOLD before today's date. 
-- Use this information to create a report with this format:
-- TABLE_NAME MIN_TAB_PARTITION MAX_TAB_PARTITION MIN_LAST_ANALYZE MAX_LAST_ANALYZED TOTAL_GIGABYTES
-- Global indexes will have their own partition names but not be listed. The size of their older
-- partitions and subpartitions will be included in the overall table size.

-- from statictables.sql

-- get a list of all the tables in TABSCHEMA

drop table schematabs;

create table schematabs as
select table_name
from dba_tables
where owner='&&TABSCHEMA';

-- get a list of the segments associated with each table

drop table tabsegs;

create table tabsegs as
select
t.table_name,
s.SEGMENT_TYPE,
s.PARTITION_NAME,
s.bytes
from
schematabs t,
dba_segments s
where
s.owner='&&TABSCHEMA' and
s.segment_name = t.table_name and
s.segment_type in ('TABLE','TABLE PARTITION','TABLE SUBPARTITION');

-- add last analyzed for each segment type

drop table withlastanalyzed;

create table withlastanalyzed 
(
table_name VARCHAR2(30),
partition_name VARCHAR2(30),
subpartition_name VARCHAR2(30),
bytes number,
last_analyzed date
);

-- tables

insert into withlastanalyzed
select
s.table_name,
NULL,
NULL,
s.bytes,
t.last_analyzed
from
tabsegs s,
dba_tables t
where
s.table_name = t.table_name and
s.segment_type = 'TABLE' and
t.owner = '&&TABSCHEMA';

commit;

-- partitions

insert into withlastanalyzed
select
s.table_name,
s.partition_name,
NULL,
s.bytes,
t.last_analyzed
from
tabsegs s,
dba_tab_partitions t
where
s.table_name = t.table_name and
s.partition_name = t.partition_name and
s.segment_type = 'TABLE PARTITION' and
t.table_owner = '&&TABSCHEMA';

commit;

-- subpartitions

drop table subs;

create table subs as
select
table_name,
partition_name,
subpartition_name,
last_analyzed
from
dba_tab_subpartitions
where 
table_owner = '&&TABSCHEMA';

insert into withlastanalyzed
select
s.table_name,
t.partition_name,
t.subpartition_name,
s.bytes,
t.last_analyzed
from
tabsegs s,
subs t
where
s.table_name = t.table_name and
s.partition_name = t.subpartition_name and
s.segment_type = 'TABLE SUBPARTITION';

commit;

-- get a list of all the indexes in TABSCHEMA

drop table schemainds;

create table schemainds as
select table_name,index_name
from dba_indexes
where owner='&&TABSCHEMA';

-- get a list of the segments associated with each index

drop table indsegs;

create table indsegs as
select
i.table_name,
i.index_name,
s.SEGMENT_TYPE,
s.PARTITION_NAME,
s.bytes
from
schemainds i,
dba_segments s
where
s.owner='&&TABSCHEMA' and
s.segment_name = i.index_name and
s.segment_type in ('INDEX','INDEX PARTITION','INDEX SUBPARTITION');

-- add last analyzed for each segment type

-- indexes

insert into withlastanalyzed
select
s.table_name,
NULL,
NULL,
s.bytes,
i.last_analyzed
from
indsegs s,
dba_indexes i
where
s.index_name = i.index_name and
s.segment_type = 'INDEX' and
i.owner = '&&TABSCHEMA';

commit;

-- partitions

insert into withlastanalyzed
select
s.table_name,
NULL,
NULL,
s.bytes,
i.last_analyzed
from
indsegs s,
dba_ind_partitions i
where
s.index_name = i.index_name and
s.partition_name = i.partition_name and
s.segment_type = 'INDEX PARTITION' and
i.index_owner = '&&TABSCHEMA';

commit;

-- subpartitions

drop table subs;

create table subs as
select
index_name,
subpartition_name,
last_analyzed
from
dba_ind_subpartitions
where 
index_owner = '&&TABSCHEMA';

insert into withlastanalyzed
select
s.table_name,
NULL,
NULL,
s.bytes,
i.last_analyzed
from
indsegs s,
subs i
where
s.index_name = i.index_name and
s.partition_name = i.subpartition_name and
s.segment_type = 'INDEX SUBPARTITION';

commit;

-- report on rows older than DAYSOLD

column min_last_analyzed format a17
column max_last_analyzed format a17

select
table_name,
min(partition_name) min_tab_partition,
max(partition_name) max_tab_partition,
to_char(min(last_analyzed),'YYYY-MM-DD') min_last_analyzed,
to_char(max(last_analyzed),'YYYY-MM-DD') max_last_analyzed,
sum(bytes)/(1024*1024*1024) total_gigabytes
from withlastanalyzed
where
last_analyzed < sysdate - &&DAYSOLD
group by 
table_name
order by
total_gigabytes desc;

-- total TB older than DAYSOLD

select sum(bytes)/(1024*1024*1024*1024) total_tb
from withlastanalyzed
where
last_analyzed < sysdate - &&DAYSOLD;

-- total NULL last_analyzed

select sum(bytes)/(1024*1024*1024*1024) total_tb
from withlastanalyzed
where
last_analyzed is null;

-- total TB newer than DAYSOLD

select sum(bytes)/(1024*1024*1024*1024) total_tb
from withlastanalyzed
where
last_analyzed >= sysdate - &&DAYSOLD;

-- cleanup
-- leave combined to query further

drop table indsegs;
drop table schemainds;
drop table schematabs;
drop table subs;
drop table tabsegs;

spool off

exit

