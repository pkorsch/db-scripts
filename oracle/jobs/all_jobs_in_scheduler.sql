SET LINESIZE 200

COLUMN owner FORMAT A20
COLUMN job_name FORMAT A30
COLUMN job_class FORMAT A30
COLUMN next_run_date FORMAT A36

SELECT owner,
       job_name,
       enabled,
       job_class,
       next_run_date
FROM   dba_scheduler_jobs
ORDER BY owner, job_name;
