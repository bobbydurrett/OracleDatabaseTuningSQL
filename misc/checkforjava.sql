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

spool &ns.checkforjava.log

SELECT comp_id, comp_name, version, status
FROM   dba_registry
WHERE  comp_id LIKE 'JAVAVM%';

SELECT owner, COUNT(*)
FROM   dba_objects
WHERE  object_type LIKE 'JAVA%'
GROUP  BY owner
ORDER  BY owner;

SELECT object_name, object_type
FROM   dba_objects
WHERE  object_name LIKE 'DBMS_JAVA%'
AND    owner = 'SYS';

SELECT dbms_java.longname('java.lang.String') FROM dual;

spool off
