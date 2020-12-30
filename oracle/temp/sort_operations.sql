select username, tablespace, blocks, CONTENTS,SEGTYPE from v$sort_usage;

SELECT   sl.sid,
           sl.serial#,
           SYSDATE,
           TO_CHAR (sl.start_time, 'DD-MON-YYYY:HH24:MI:SS') start_time,
           ROUND ( (sl.elapsed_seconds / 60), 2) min_elapsed,
           ROUND ( (sl.time_remaining / 60), 2) min_remaining,
           sl.opname,
           sl.MESSAGE
    FROM   v$session_longops sl, v$session s
   WHERE   s.sid = sl.sid AND s.serial# = sl.serial# AND sl.opname like 'Sort%'
ORDER BY   sl.start_time DESC, sl.time_remaining ASC;
