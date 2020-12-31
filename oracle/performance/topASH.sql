-- TOP events
select event,
sum(wait_time +time_waited) ttl_wait_time
from v$active_session_history 
where sample_time between sysdate - 60/2880 and sysdate
group by event
order by 2 ;

-- Top sessions
select sesion.sid,
sesion.username,
sum(ash.wait_time + ash.time_waited)/1000000/60 ttl_wait_time_in_minutes
from v$active_session_history ash, v$session sesion
where sample_time between sysdate - 60/2880 and sysdate
and ash.session_id = sesion.sid
group by sesion.sid, sesion.username
order by 3 desc;

--Top queries
SELECT active_session_history.user_id,
dba_users.username,
sqlarea.sql_text,
SUM(active_session_history.wait_time +
active_session_history.time_waited)/1000000 ttl_wait_time_in_seconds
FROM v$active_session_history active_session_history,
v$sqlarea sqlarea,
dba_users
WHERE active_session_history.sample_time BETWEEN SYSDATE - 1 AND SYSDATE
AND active_session_history.sql_id = sqlarea.sql_id
AND active_session_history.user_id = dba_users.user_id
and dba_users.username <>'SYS'
GROUP BY active_session_history.user_id,sqlarea.sql_text, dba_users.username
ORDER BY 4 DESC;

-- Top segments
SELECT dba_objects.object_name,
dba_objects.object_type,
active_session_history.event,
SUM(active_session_history.wait_time +
active_session_history.time_waited) ttl_wait_time
FROM v$active_session_history active_session_history,
dba_objects
WHERE active_session_history.sample_time BETWEEN SYSDATE - 1 AND SYSDATE
AND active_session_history.current_obj# = dba_objects.object_id
GROUP BY dba_objects.object_name, dba_objects.object_type, active_session_history.event
ORDER BY 4 DESC;

-- Most IO
SELECT sql_id, COUNT(*)
FROM gv$active_session_history ash, gv$event_name evt
WHERE ash.sample_time > SYSDATE - 1/24
AND ash.session_state = 'WAITING'
AND ash.event_id = evt.event_id
AND evt.wait_class = 'User I/O'
GROUP BY sql_id
ORDER BY COUNT(*) DESC;

SELECT * FROM TABLE(dbms_xplan.display_cursor(&SQL_ID)); 

-- Top 10 CPU consumers in last 60 minutes
select * from
(
select session_id, session_serial#, count(*)
from v$active_session_history
where session_state= 'ON CPU' and
 sample_time > sysdate - interval '60' minute
group by session_id, session_serial#
order by count(*) desc
)
where rownum <= 10;

-- Top 10 waiting sessions in last 60 minutes
select * from
(
select session_id, session_serial#,count(*)
from v$active_session_history
where session_state='WAITING'  and
 sample_time >  sysdate - interval '60' minute
group by session_id, session_serial#
order by count(*) desc
)
where rownum <= 10;

-- Find session detail of top sid by passing sid
select  serial#,
 username,
 osuser,
 machine,
 program,
 resource_consumer_group,
 client_info
from v$session where sid=&sid;


-- Find different sql_ids of queries executed in above  top session by-passing sid
select distinct sql_id, session_serial# from v$active_session_history
where sample_time >  sysdate - interval '60' minute 
and session_id=&sid

--Find full sqltext (CLOB) of above sql
select sql_fulltext from v$sql where sql_id='&sql_id'

--find session wait history of above found top sessionselect * from v$session_wait_history where sid=&sid

--find all wait events for above top session
select event, total_waits, time_waited/100/60 time_waited_minutes,
       average_wait*10 aw_ms, max_wait/100 max_wait_seconds
from v$session_event
where sid=&sid 
order by 5 desc;

--session statistics for above particular top session :
select s.sid,s.username,st.name,se.value
from v$session s, v$sesstat se, v$statname st
where s.sid=se.SID and se.STATISTIC#=st.STATISTIC# 
--and st.name ='CPU used by this session' 
--and s.username='&USERNAME' 
and s.sid='&SID'
order by s.sid,se.value desc;
