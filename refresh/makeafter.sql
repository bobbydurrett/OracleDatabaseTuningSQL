set echo off
set termout off
set heading off
set verify off
set feedback off
set newpage none
set linesize 1000
set trimspool on

drop table lines;
create table lines(lineno number,line varchar2(1000));
drop sequence linesseq;
create sequence linesseq;

insert into lines values (linesseq.nextval,'connect &1/&2');

set define off

insert into lines values (linesseq.nextval,'set linesize 1000');
insert into lines values (linesseq.nextval,'set pagesize 1000');
insert into lines values (linesseq.nextval,'set head off;');
insert into lines values (linesseq.nextval,'set verify off;');
insert into lines values (linesseq.nextval,'set termout off;');
insert into lines values (linesseq.nextval,' ');
insert into lines values (linesseq.nextval,'column u new_value us noprint;');
insert into lines values (linesseq.nextval,'column n new_value ns noprint;');
insert into lines values (linesseq.nextval,' ');
insert into lines values (linesseq.nextval,'select name n from v$database;');
insert into lines values (linesseq.nextval,'select user u from dual;');
insert into lines values (linesseq.nextval,'set sqlprompt &ns:&us>');
insert into lines values (linesseq.nextval,' ');
insert into lines values (linesseq.nextval,'set head on');
insert into lines values (linesseq.nextval,'set echo on');
insert into lines values (linesseq.nextval,'set termout on');
insert into lines values (linesseq.nextval,'set trimspool on');
insert into lines values (linesseq.nextval,' ');
insert into lines values (linesseq.nextval,'spool &ns.after.log');

commit;

--  compress tables and partitions that were compressed before the refresh

insert into lines
select linesseq.nextval, line
from (select 'alter table '||t.owner||'.'||t.table_name||' compress;' line
from dba_tables t, tablelist l
where
t.owner = l.table_owner and
t.table_name = l.table_name and
t.partitioned='NO' and
t.compression='ENABLED'
union
select 'alter table '||tp.table_owner||'.'||tp.table_name||' move partition '||tp.partition_name||' compress;' line
from dba_tab_partitions tp, tablelist l
where
tp.table_owner = l.table_owner and
tp.table_name = l.table_name and
(tp.partition_name = l.partition_name or l.partition_name is null) and
tp.compression='ENABLED');

-- reenable all referential constraints on the table(s) novalidate

insert into lines
select linesseq.nextval, line
from (select distinct 'alter table '||c.owner||'.'||c.table_name||
' modify constraint '||constraint_name||'  enable novalidate;' line
from dba_constraints c, tablelist l
where 
constraint_type='R' and
c.owner=l.table_owner and
c.table_name=l.table_name);

-- reenable all ref constraints that point to the tables novalidate

insert into lines
select linesseq.nextval, line
from (select distinct 'alter table '||orig.owner||'.'||orig.table_name||
' modify constraint '||orig.constraint_name||' enable novalidate;' line
from dba_constraints orig, dba_constraints refer, tablelist l
where
orig.constraint_type='R' and
refer.owner = l.table_owner and
refer.table_name = l.table_name and
orig.r_owner=refer.owner and
orig.R_CONSTRAINT_NAME=refer.CONSTRAINT_NAME);

commit;

-- enable triggers after import

insert into lines
select linesseq.nextval, line
from (select 'alter trigger '||t.owner||'.'||t.trigger_name||' enable;' line
from dba_triggers t, tablelist l
where
t.table_owner = l.table_owner and
t.table_name = l.table_name );

commit;

-- rebuild non-partitioned indexes or partitions of partitioned indexes parallel nologging
-- if table or partition is compressed comment out NONUNIQUE conditions on the rebuild because compression
-- will make all the indexes unusable.  Only disable NONUNIQUE indexes for the loads.  
-- Need PK and unique indexes in place during the load.

insert into lines
select linesseq.nextval, line
from (select 'alter index '||i.owner||'.'||i.index_name||' rebuild parallel 4 nologging;' line
from dba_indexes i, tablelist l
where
i.table_owner = l.table_owner and
i.table_name = l.table_name and
partitioned='NO' 
and uniqueness='NONUNIQUE'
union
select 'alter index '||i.owner||'.'||i.index_name||' rebuild partition '||ip.partition_name||' parallel 4 nologging;' line
from dba_indexes i, dba_ind_partitions ip, tablelist l
where
i.table_owner = l.table_owner and
i.table_name = l.table_name and
(ip.partition_name = l.partition_name or l.partition_name is null) and
i.partitioned='YES' and
i.owner=ip.index_owner and
i.index_name=ip.index_name 
and uniqueness='NONUNIQUE');

-- set rebuilt indexes back to noparallel logging and partitions to logging

insert into lines
select linesseq.nextval, line
from (select 'alter index '||i.owner||'.'||i.index_name||' noparallel logging;' line
from dba_indexes i, tablelist l
where
i.table_owner = l.table_owner and
i.table_name = l.table_name and
partitioned='NO' 
and uniqueness='NONUNIQUE'
union
select 'alter index '||i.owner||'.'||i.index_name||' modify partition '||ip.partition_name||' logging;' line
from dba_indexes i, dba_ind_partitions ip, tablelist l
where
i.table_owner = l.table_owner and
i.table_name = l.table_name and
(ip.partition_name = l.partition_name or l.partition_name is null) and
i.partitioned='YES' and
i.owner=ip.index_owner and
i.index_name=ip.index_name and
uniqueness='NONUNIQUE');

commit;

insert into lines values (linesseq.nextval,'spool off');
insert into lines values (linesseq.nextval,'exit');

commit;

spool after.sql

select line from lines order by lineno;

spool off

exit
