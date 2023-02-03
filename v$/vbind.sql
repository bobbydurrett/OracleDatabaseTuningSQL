set termout on 
set echo on
set linesize 32000
set pagesize 1000
set trimspool on

column NAME format a3
column VALUE_STRING format a19

spool vbind.log

select * from 
(select distinct
to_char(sb.LAST_CAPTURED,'YYYY-MM-DD HH24:MI:SS') DATE_TIME,
sb.NAME,
sb.VALUE_STRING 
from 
V$SQL_BIND_CAPTURE sb
where 
sb.sql_id='db8ry89z6yv89' and
sb.WAS_CAPTURED='YES')
order by 
DATE_TIME,
NAME;

spool off
