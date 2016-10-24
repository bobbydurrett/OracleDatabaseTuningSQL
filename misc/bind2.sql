set termout on 
set echo on
set linesize 32000
set pagesize 1000
set trimspool on

column NAME format a3
column VALUE_STRING format a17

spool bind2.log

select * from 
(select distinct
to_char(sb.LAST_CAPTURED,'YYYY-MM-DD HH24:MI:SS') DATE_TIME,
sb.NAME,
sb.VALUE_STRING 
from 
DBA_HIST_SQLBIND sb
where 
sb.sql_id='gxk0cj3qxug85' and
sb.WAS_CAPTURED='YES')
order by 
DATE_TIME,
NAME;

spool off
