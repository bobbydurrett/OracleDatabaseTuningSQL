set linesize 1000
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
set serveroutput on size 1000000

spool &ns.dumpsql.log

-- 0xdhgfzfz5hnf
-- 1cas85dwbyckb
-- 2vcz2a68pkm26
-- 37kc1a98qcmt2
-- 3pnxxdpbbf38t
-- 5vhy4xm9vcsv1
-- 6svwbs20bj36k
-- 84amr0m8m7d55
-- 8cm6cx5qpdk8m
-- aahxfqwkbrta4
-- dqjugc3x5d472
-- gvu38800qggb9


-- edit the where clause of the TEXT_CURSOR so you search the SQL_TEXT clob for text that
-- is in the SQL you want to find in the AWR

set define off

select
SQL_ID,
SQL_TEXT
FROM DBA_HIST_SQLTEXT 
where
sql_id in
('0xdhgfzfz5hnf',
'1cas85dwbyckb',
'2vcz2a68pkm26',
'37kc1a98qcmt2',
'3pnxxdpbbf38t',
'5vhy4xm9vcsv1',
'6svwbs20bj36k',
'84amr0m8m7d55',
'8cm6cx5qpdk8m',
'aahxfqwkbrta4',
'dqjugc3x5d472',
'gvu38800qggb9')
order by sql_id;


spool off
