-----------------------------------------
--
-- Top 10 CPU consumers in last 5 minutes
--
-----------------------------------------
SQL> select * from
(
select session_id, session_serial#, count(*)
from v$active_session_history
where session_state= 'ON CPU' and
 sample_time > sysdate - interval '5' minute
group by session_id, session_serial#
order by count(*) desc
)
where rownum <= 10;
--------------------------------------------
--
-- Top 10 waiting sessions in last 5 minutes
--
--------------------------------------------
SQL> select * from
(
select session_id, session_serial#,count(*)
from v$active_session_history
where session_state='WAITING'  and
 sample_time >  sysdate - interval '5' minute
group by session_id, session_serial#
order by count(*) desc
)
where rownum <= 10;
