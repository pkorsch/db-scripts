### TEMP TABLESPACE USAGE
select b.Total_MB,
       b.Total_MB - round(a.used_blocks*8/1024) Current_Free_MB,
       round(used_blocks*8/1024)                Current_Used_MB,
      round(max_used_blocks*8/1024)             Max_used_MB
from v$sort_segment a,
 (select round(sum(bytes)/1024/1024) Total_MB from dba_temp_files ) b;
