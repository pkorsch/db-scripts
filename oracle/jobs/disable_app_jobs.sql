-- -----------------------------------------------------------------------------------
-- File Name    : disable_jobs.sql
-- Author       : Peter Korsch
-- Contact      : peter.korsch@t-systems.com
-- Position     : DBA
-- Description  : Disable all scheduler jobs that not belongs to SYS / disable app jobs
-- Call Syntax  : @disable_jobs.sql
-- Requirements : SYSDBA role
-- Last Modified: 04/08/2018
-- -----------------------------------------------------------------------------------
col OWNER for a35
col JOB_NAME for a40
set lines 400
set pages 1000
set serveroutput on
set heading off
set feedback off
set termout off
SET SERVER OUTPUT ON
--set variable for logfile name and sql file name
col SQL_NAME new_value pk_SQL_NAME
select sys_context ('userenv','DB_NAME') SQL_NAME from dual;
DEFINE SQLFILE=disable_app_jobs_&&pk_SQL_NAME..sql
col LOG_NAME new_value pk_LOG_NAME
select sys_context ('userenv','DB_NAME') LOG_NAME from dual;
DEFINE LOGFILE=disable_app_jobs_&&pk_LOG_NAME..log
--spooling state before execution of disable script
spool &&LOGFILE
BEGIN
DBMS_OUTPUT.PUT_LINE('STATUS BEFORE EXECUTION');
DBMS_OUTPUT.PUT_LINE(SYSDATE);
DBMS_LOCK.SLEEP(3);
END;
/
select owner,job_name,enabled from dba_scheduler_jobs where owner <> 'SYS' and enabled='TRUE';
spool off
--create sql file for disable app jobs
spool &&SQLFILE
select 'execute dbms_scheduler.disable('||''''||owner||'.'||job_name||''''||');' from dba_scheduler_jobs where owner <> 'SYS' and enabled='TRUE';
spool off
--execution od sql file & spooling state after execution of disable script
spool &&LOGFILE append
@&&SQLFILE

BEGIN
DBMS_OUTPUT.PUT_LINE('STATUS AFTER EXECUTION');
DBMS_OUTPUT.PUT_LINE(SYSDATE);
DBMS_LOCK.SLEEP(3);
END;
/
select owner,job_name,enabled from dba_scheduler_jobs where owner <> 'SYS' and enabled='FALSE';
spool off
