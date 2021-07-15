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

spool &ns.ashtopelapsed.log

set timing on

column FORCE_MATCHING_SIGNATURE format 99999999999999999999

drop table topsigs;

create table topsigs as
select 
FORCE_MATCHING_SIGNATURE,
count(*) active
from DBA_HIST_ACTIVE_SESS_HISTORY a
where 
sample_time 
between 
to_date('05-JUL-2021 05:02:42','DD-MON-YYYY HH24:MI:SS')
and 
to_date('05-JUL-2021 07:15:36','DD-MON-YYYY HH24:MI:SS')
group by
FORCE_MATCHING_SIGNATURE;

drop table sigtoid;

create table sigtoid as
select
t.FORCE_MATCHING_SIGNATURE,
max(ss.sql_id) sql_id
from 
topsigs t, dba_hist_sqlstat ss
where t.FORCE_MATCHING_SIGNATURE = ss.FORCE_MATCHING_SIGNATURE
group by 
t.FORCE_MATCHING_SIGNATURE
order by 
t.FORCE_MATCHING_SIGNATURE;

drop table idtotext;

create table idtotext as
select
i.sql_id,
st.sql_text
from
sigtoid i,
DBA_HIST_SQLTEXT st
where
i.sql_id = st.sql_id;

-- output results

select
t.active,
t.FORCE_MATCHING_SIGNATURE,
i.sql_id example_sql_id,
x.sql_text
from
topsigs t,
sigtoid i,
idtotext x
where
t.FORCE_MATCHING_SIGNATURE = i.FORCE_MATCHING_SIGNATURE and
i.sql_id = x.sql_id
order by active desc;


spool off
                 
        