SELECT 
	pl.id 'PROCESS ID'
	,trx.trx_started
	,esh.event_name 'EVENT NAME'
	,esh.sql_text 'SQL'
FROM information_schema.innodb_trx AS trx
INNER JOIN information_schema.processlist pl 
	ON trx.trx_mysql_thread_id = pl.id
INNER JOIN performance_schema.threads th 
	ON th.processlist_id = trx.trx_mysql_thread_id
INNER JOIN performance_schema.events_statements_history esh 
	ON esh.thread_id = th.thread_id
WHERE trx.trx_started < CURRENT_TIME - INTERVAL 59 SECOND
  AND pl.user <> 'system_user'
ORDER BY esh.EVENT_ID;
