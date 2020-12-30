SELECT 'ALTER TABLE "' || a.table_name || '" DISABLE CONSTRAINT "' || a.constraint_name || '";'
FROM   dba_constraints a
WHERE  a.constraint_type = 'R'
AND    a.owner           = 'SCHEMA_NAME';
