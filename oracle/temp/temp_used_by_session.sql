### SESSIONS USED TEMP
col hash_value for a40
col tablespace for a10
col username for a15
set linesize 132 pagesize 1000

SELECT s.sid, s.username, u.tablespace, s.sql_hash_value||'/'||u.sqlhash hash_value, u.segtype, u.contents, u.blocks
FROM v$session s, v$tempseg_usage u
WHERE s.saddr=u.session_addr
order by u.blocks;
