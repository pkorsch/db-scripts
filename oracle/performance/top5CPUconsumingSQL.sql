--TOP 5 CPU consuming SQL's in timeframe between 2 hours f.e. begin = 8 end = 9
select * from (
select
SQL_ID,
 sum(CPU_TIME_DELTA),
sum(DISK_READS_DELTA),
count(*)
from
DBA_HIST_SQLSTAT a, dba_hist_snapshot s
where
s.snap_id = a.snap_id
and s.begin_interval_time > sysdate -1
and EXTRACT(HOUR FROM S.END_INTERVAL_TIME) between &begin_hour and &end_hour
group by
SQL_ID
order by
sum(CPU_TIME_DELTA) desc)
where rownum < 5;
