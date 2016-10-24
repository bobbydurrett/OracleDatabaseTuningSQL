alter system set timed_os_statistics=1 scope=memory;
drop table beforeothersession;
create table beforeothersession as
select SID,event TIMESOURCE,(TIME_WAITED_MICRO/1000000) seconds from v$session_event 
where sid=&&MONITORED_SID;
insert into beforeothersession select SID,'CPU' TIMESOURCE,(VALUE/100) seconds from v$sesstat 
where sid=&&MONITORED_SID
and statistic#=(select statistic# from v$statname where name='CPU used by this session');
commit;
insert into beforeothersession
select sid,'OSWASTED' TIMESOURCE,sum(value)/100 seconds
from v$sesstat where sid=&&MONITORED_SID
and statistic# in
(select statistic# from v$statname where name in 
('OS Text page fault sleep time',        
'OS Data page fault sleep time',        
'OS Kernel page fault sleep time',
'OS Wait-cpu (latency) time'))
group by sid;
commit;
insert into beforeothersession
select sid,'OSCPU' TIMESOURCE,sum(value)/100 seconds
from v$sesstat where sid=&&MONITORED_SID
and statistic# in
(select statistic# from v$statname where name in 
('OS User level CPU time',
'OS System call CPU time',
'OS Other system trap CPU time'))
group by sid;
commit;
insert into beforeothersession
SELECT sid,
'REALELAPSED' TIMESOURCE,
(sysdate-to_date('01/01/1900','MM/DD/YYYY'))*24*60*60 seconds
from v$session where sid=&&MONITORED_SID;
commit;