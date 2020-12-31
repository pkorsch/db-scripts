SET LINESIZE 200

COLUMN owner FORMAT A20
COLUMN elapsed_time FORMAT A30

SELECT owner,
       job_name,
       running_instance,
       elapsed_time,
       session_id
FROM   dba_scheduler_running_jobs
ORDER BY owner, job_name;
