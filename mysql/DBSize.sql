SELECT 
	table_schema AS Database_Name
	,ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS SizeInMB
FROM information_schema.tables
GROUP BY table_schema
