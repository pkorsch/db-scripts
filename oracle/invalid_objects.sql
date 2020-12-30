Set heading off;
set feedback off;
set echo off;
Set lines 999;

Spool run_invalid.sql

select
   'ALTER ' || OBJECT_TYPE || ' ' ||
   OWNER || '.' || OBJECT_NAME || ' COMPILE;'
from
   dba_objects
where
   status = 'INVALID'
and
   object_type in ('PACKAGE','FUNCTION','PROCEDURE')
;

spool off;

set heading on;
set feedback on;
set echo on;

@run_invalid.sql
