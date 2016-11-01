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

spool &ns.filesystemquery.log

set define off

select substr(df.name,1,20) filesystem,10*sum(fs.readtim)/sum(fs.phyrds) "avg read (ms)",sum(fs.phyrds) reads
from v$filestat fs, v$datafile df
where fs.file#=df.file#
group by substr(df.name,1,20)
order by substr(df.name,1,20);

spool off
