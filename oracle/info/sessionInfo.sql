--Session Info

--Session I/O By User

select	nvl(ses.USERNAME,'ORACLE PROC') username,
	OSUSER os_user,
	PROCESS pid,
	ses.SID sid,
	SERIAL#,
	PHYSICAL_READS,
	BLOCK_GETS,
	CONSISTENT_GETS,
	BLOCK_CHANGES,
	CONSISTENT_CHANGES
from	v$session ses, 
	v$sess_io sio
where 	ses.SID = sio.SID
order 	by PHYSICAL_READS, ses.USERNAME;


--CPU Usage By Session

select 	nvl(ss.USERNAME,'ORACLE PROC') username,
	se.SID,
	VALUE cpu_usage
from 	v$session ss, 
	v$sesstat se, 
	v$statname sn
where  	se.STATISTIC# = sn.STATISTIC#
and  	NAME like '%CPU used by this session%'
and  	se.SID = ss.SID
order  	by VALUE desc;


--Resource Usage By User

select 	ses.SID,
	nvl(ses.USERNAME,'ORACLE PROC') username,
	sn.NAME statistic,
	sest.VALUE
from 	v$session ses, 
	v$statname sn, 
	v$sesstat sest
where 	ses.SID = sest.SID
and 	sn.STATISTIC# = sest.STATISTIC#
and 	sest.VALUE is not null
and 	sest.VALUE != 0            
order 	by ses.USERNAME, ses.SID, sn.NAME;


--Session Stats By Session

select  nvl(ss.USERNAME,'ORACLE PROC') username,
	se.SID,
	sn.NAME stastic,
	VALUE usage
from 	v$session ss, 
	v$sesstat se, 
	v$statname sn
where  	se.STATISTIC# = sn.STATISTIC#
and  	se.SID = ss.SID
and	se.VALUE > 0
order  	by sn.NAME, se.SID, se.VALUE desc;

--Cursor Usage By Session

select 	user_process username,
	"Recursive Calls",
	"Opened Cursors",
	"Current Cursors"
from  (
	select 	nvl(ss.USERNAME,'ORACLE PROC')||'('||se.sid||') ' user_process, 
			sum(decode(NAME,'recursive calls',value)) "Recursive Calls",
			sum(decode(NAME,'opened cursors cumulative',value)) "Opened Cursors",
			sum(decode(NAME,'opened cursors current',value)) "Current Cursors"
	from 	v$session ss, 
		v$sesstat se, 
		v$statname sn
	where 	se.STATISTIC# = sn.STATISTIC#
	and 	(NAME  like '%opened cursors current%'
	or 	 NAME  like '%recursive calls%'
	or 	 NAME  like '%opened cursors cumulative%')
	and 	se.SID = ss.SID
	and 	ss.USERNAME is not null
	group 	by nvl(ss.USERNAME,'ORACLE PROC')||'('||se.SID||') '
)
orasnap_user_cursors
order 	by USER_PROCESS,"Recursive Calls";

--User Hit Ratios

select	USERNAME,
	CONSISTENT_GETS,
        BLOCK_GETS,
        PHYSICAL_READS,
        ((CONSISTENT_GETS+BLOCK_GETS-PHYSICAL_READS) / (CONSISTENT_GETS+BLOCK_GETS)) Ratio
from 	v$session, v$sess_io
where 	v$session.SID = v$sess_io.SID
and 	(CONSISTENT_GETS+BLOCK_GETS) > 0
and 	USERNAME is not null
order	by ((CONSISTENT_GETS+BLOCK_GETS-PHYSICAL_READS) / (CONSISTENT_GETS+BLOCK_GETS));
