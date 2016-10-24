set termout on
set echo on
spool &ns.getsql.log
SELECT b.SQL_TEXT
FROM v$SESSION a,v$SQLTEXT b
where a.SQL_HASH_VALUE = b.HASH_VALUE 
and a.SID=&MONITORED_SID
ORDER BY b.PIECE;
spool off
