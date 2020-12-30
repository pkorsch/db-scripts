set lines 160
col SEGMENT_NAME for a40

select * from 
    (select segment_name, segment_type, bytes/1024/1024 MB 
     from dba_segments where tablespace_name = 'SYSAUX' order by 3 desc)
where rownum< 30;


select 'alter index '||segment_name||' rebuild online;'
FROM dba_segments 
where tablespace_name = 'SYSAUX' 
      AND segment_type = 'INDEX' 
        AND segment_name like '%OPTSTAT%' 
        AND  bytes/1024/1024 > 1
order by bytes asc;
