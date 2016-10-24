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

spool &ns.locks.log

select INST_ID, SID, TYPE, ID1, ID2, LMODE, REQUEST, CTIME, BLOCK 
from gv$lock where (ID1,ID2,TYPE) in 
(select ID1,ID2,TYPE from gv$lock where request>0)
order by type,id1,id2,request; 

spool off
