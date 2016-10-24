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

spool &ns.maxactive.log

-- list instances that have the maximum number of allowed active sessions per
-- consumer group

select
act.inst_id,act.resource_consumer_group,act.num_active,
pd.active_sess_pool_p1 max_active
from
(select inst_id,resource_consumer_group,count(*) num_active
from gv$session 
where status='ACTIVE' and
type='USER' and
program not like '%(P%)'
group by inst_id,resource_consumer_group) act,
DBA_RSRC_PLAN_DIRECTIVES pd,
gv$rsrc_plan pl
where
pd.plan=pl.name and
act.inst_id=pl.inst_id and
pl.is_top_plan='TRUE' and
act.resource_consumer_group=pd.group_or_subplan and
act.num_active > pd.active_sess_pool_p1;

spool off

