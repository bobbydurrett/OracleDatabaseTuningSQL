select after.TIMESOURCE, after.SECONDS-before.seconds elapsed_seconds from 
(select SID,event TIMESOURCE,(TIME_WAITED_MICRO/1000000) seconds from v$session_event 
where sid=&&MONITORED_SID
union
select SID,'CPU' TIMESOURCE,(VALUE/100) seconds from v$sesstat where sid=&&MONITORED_SID
and statistic#=(select statistic# from v$statname where name='CPU used by this session')
union
select sid,'OSWASTED' TIMESOURCE,sum(value)/100 seconds
from v$sesstat where sid=&&MONITORED_SID
and statistic# in
(select statistic# from v$statname where name in 
('OS Text page fault sleep time',        
'OS Data page fault sleep time',        
'OS Kernel page fault sleep time',
'OS Wait-cpu (latency) time'))
group by sid
union
select sid,'OSCPU' TIMESOURCE,sum(value)/100 seconds
from v$sesstat where sid=&&MONITORED_SID
and statistic# in
(select statistic# from v$statname where name in 
('OS User level CPU time',
'OS System call CPU time',
'OS Other system trap CPU time'))
group by sid
union
SELECT sid,
'REALELAPSED' TIMESOURCE,
(sysdate-to_date('01/01/1900','MM/DD/YYYY'))*24*60*60 seconds
from v$session where sid=&&MONITORED_SID
) after,
beforeothersession before
where
before.SID=after.SID and
after.timesource=before.timesource
order by elapsed_seconds desc
;
drop table beforeothersession;
alter system set timed_os_statistics=0 scope=memory;

     
