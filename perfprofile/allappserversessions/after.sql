set termout on
set echo on

column d new_value ds noprint;
 
select to_char(sysdate,'YYYYMMDDHH24MISS') d from dual;


spool &ds.after.log

SELECT after.sid,substr(AFTER.TIMESOURCE,1,30) Timesource, 
AFTER.SECONDS-BEFORE.SECONDS ELAPSED_SECONDS,client_info 
FROM 
(
SELECT s.SID,EVENT TIMESOURCE,(TIME_WAITED/100) SECONDS,' ' client_info
FROM V$SESSION_EVENT se,v$session s  
WHERE s.client_info like '%PSAPPSRV%' and
se.sid=s.sid
UNION
SELECT s.SID,'CPU' TIMESOURCE,(VALUE/100) SECONDS,' ' client_info 
FROM V$SESSTAT ss,v$session s
WHERE s.client_info like '%PSAPPSRV%' and
ss.sid=s.sid
AND STATISTIC#=(SELECT STATISTIC# FROM V$STATNAME WHERE NAME='CPU used by this session')
UNION
SELECT SID,
'REALELAPSED' TIMESOURCE,
(SYSDATE-TO_DATE('01/01/1900','MM/DD/YYYY'))*24*60*60 SECONDS,client_info
FROM V$SESSION WHERE client_info like '%PSAPPSRV%'
) AFTER,
BEFOREOTHERSESSION BEFORE
WHERE
BEFORE.SID=AFTER.SID AND
AFTER.TIMESOURCE=BEFORE.TIMESOURCE
ORDER BY after.sid,ELAPSED_SECONDS DESC;

DROP TABLE BEFOREOTHERSESSION;

spool off
