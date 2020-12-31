SELECT 
	trx.trx_id
	,trx.trx_started
	,trx.trx_mysql_thread_id
FROM INFORMATION_SCHEMA.INNODB_TRX AS trx
INNER JOIN INFORMATION_SCHEMA.PROCESSLIST AS pl 
	ON trx.trx_mysql_thread_id = pl.id
WHERE trx.trx_started < CURRENT_TIMESTAMP - INTERVAL 59 SECOND
  AND pl.user <> 'system_user';
