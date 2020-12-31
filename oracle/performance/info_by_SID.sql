--------------------
--
-- Who is that SID?
--
--------------------

set lines 200
col username for a10
col osuser for a10
col machine for a10
col program for a10
col resource_consumer_group for a10
col client_info for a10

SQL> select  serial#,
 username,
 osuser,
 machine,
 program,
 resource_consumer_group,
 client_info
from v$session where sid=&sid;

-------------------------
--
-- What did that SID do?
--
-------------------------

SQL> select distinct sql_id, session_serial# from v$active_session_history
where sample_time >  sysdate - interval '5' minute
and session_id=&sid;
----------------------------------------------
--
-- Retrieve the SQL from the Library Cache:
--
----------------------------------------------
col sql_text for a80
SQL> select sql_text from v$sql where sql_id='&sqlid';
