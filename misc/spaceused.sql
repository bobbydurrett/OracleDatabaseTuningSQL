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

with target_tables as (
    select 'MYOWNER1' owner, 'MYTABLE1' table_name from dual
    union all select 'MYOWNER1', 'MYTABLE2'             from dual
),
segment_names as (
    -- Tables and table partitions
    select owner, table_name segment_name
    from target_tables
    union
    select p.table_owner owner, p.partition_name segment_name
    from dba_tab_partitions p
    join target_tables t
      on t.owner = p.table_owner
     and t.table_name = p.table_name
    -- Ordinary indexes and index partitions
    union
    select i.owner, i.index_name
    from dba_indexes i
    join target_tables t
      on t.owner = i.table_owner
     and t.table_name = i.table_name
    union
    select p.index_owner owner, p.partition_name segment_name
    from dba_ind_partitions p
    join dba_indexes i
      on i.owner = p.index_owner
     and i.index_name = p.index_name
    join target_tables t
      on t.owner = i.table_owner
     and t.table_name = i.table_name
    -- LOB segments and LOB indexes
    union
    select l.owner, l.segment_name
    from dba_lobs l
    join target_tables t
      on t.owner = l.owner
     and t.table_name = l.table_name
    union
    select l.owner, l.index_name
    from dba_lobs l
    join target_tables t
      on t.owner = l.owner
     and t.table_name = l.table_name
    -- Partitioned LOB segments and indexes
    union
    select p.table_owner owner, p.LOB_PARTITION_NAME segment_name
    from dba_lob_partitions p
    join target_tables t
      on t.owner = p.table_owner
     and t.table_name = p.table_name
    union
    select p.table_owner owner, p.LOB_INDPART_NAME segment_name
    from dba_lob_partitions p
    join target_tables t
      on t.owner = p.table_owner
     and t.table_name = p.table_name
)
select s.tablespace_name,
       s.segment_type,
       round(sum(s.bytes) / power(1024, 3), 2) gigabytes
from dba_segments s
join segment_names n
  on n.owner = s.owner
 and n.segment_name = s.segment_name
group by s.tablespace_name, s.segment_type
order by s.tablespace_name, s.segment_type;

spool off
