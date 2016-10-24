set termout on
set echo on
spool profile.log

VARIABLE monitored_sid number;

begin

SELECT sid into :monitored_sid from v$session where audsid=USERENV('SESSIONID');

end;
/

SELECT SID, substr(USERNAME,1,12) Username, substr(TIMESOURCE,1,30), SECONDS, 
ROUND(SECONDS/(SELECT ROUND((SYSDATE-LOGON_TIME)*24*60*60,0) FROM V$SESSION WHERE SID= :monitored_sid),2)*100 
AS PERCENTAGE
FROM
(SELECT logon_time, SID, username, 'TOTAL_TIME' TIMESOURCE,
ROUND((SYSDATE-LOGON_TIME)*24*60*60,0) SECONDS
FROM V$SESSION 
WHERE SID= :monitored_sid
UNION ALL
SELECT a.logon_time, a.SID,a.USERNAME,'CPU' TIMESOURCE,
ROUND((VALUE/100),0) SECONDS
FROM V$SESSION a, V$SESSTAT b
where a.SID = b.SID
and a.SID = :monitored_sid
and b.STATISTIC# = (SELECT STATISTIC# FROM V$STATNAME WHERE NAME='CPU used by this session')
UNION ALL
SELECT b.logon_time, a.SID,b.USERNAME,a.EVENT TIMESOURCE,
ROUND((TIME_WAITED/100),0) SECONDS
FROM V$SESSION_EVENT a, V$SESSION b
WHERE a.SID = b.SID
AND a.SID= :monitored_sid
UNION ALL
select b.logon_time, a.sid, b.username, 'UNACCOUNTED_TIME' TIMESOURCE,
ROUND(MAX(SYSDATE-LOGON_TIME)*24*60*60,0)-(ROUND(SUM((TIME_WAITED/100)),0)+ROUND(MAX(VALUE/100),0)) 
as UNACCOUNTED_FOR_TIME
FROM V$SESSION_EVENT a, V$SESSION b, V$SESSTAT c
WHERE a.SID = b.SID
AND b.sid = c.sid
and c.STATISTIC# = (SELECT STATISTIC# FROM V$STATNAME WHERE NAME='CPU used by this session')
AND a.SID= :monitored_sid
group by b.logon_time, a.sid, b.username)
order by SECONDS desc;

spool off
