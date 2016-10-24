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

set timing on
set time on
set autotrace on
set serveroutput on size 1000000

-- Defaults for SET AUTOTRACE EXPLAIN report

COLUMN id_plus_exp FORMAT 990 HEADING i
COLUMN parent_id_plus_exp FORMAT 990 HEADING p
COLUMN plan_plus_exp FORMAT a2000
COLUMN object_node_plus_exp FORMAT a8
COLUMN other_tag_plus_exp FORMAT a29
COLUMN other_plus_exp FORMAT a44

whenever sqlerror exit rollback

spool &ns.logfilename.log

set define off

-- alter session set current_schema = SYSADM;

-- stuff to do

spool off
