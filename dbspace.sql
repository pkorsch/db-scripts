set pagesize 1000 linesize 180
tti 'Tablespace Usage Status'
col "TOTAL(MB)" for 99,999,999.999
col "USAGE(MB)" for 99,999,999.999
col "FREE(MB)" for 99,999,999.999 
col "EXTENSIBLE(MB)" for 99,999,999.999 
col "FREE PCT %" for 999.99
col "USED PCT OF MAX %" for 999.99
col "NOTO" for 9999
col "OTO" for 999
select d.tablespace_name "NAME", 
d.contents "TYPE",
nvl(a.bytes /1024/1024,0) "TOTAL(MB)",
nvl(a.bytes - nvl(f.bytes,0),0)/1024/1024 "USAGE(MB)",
nvl(f.bytes,0)/1024/1024 "FREE(MB)",
nvl((a.bytes - nvl(f.bytes,0))/a.bytes * 100,0) "FREE PCT %",
nvl(a.ARTACAK,0)/1024/1024 "EXTENSIBLE(MB)",
nvl((a.bytes - nvl(f.bytes,0))/ (a.bytes + nvl(a.ARTACAK,0)) * 100,0) "USED PCT OF MAX %",
a.NOTO, a.OTO
from sys.dba_tablespaces d,
(select tablespace_name, sum(bytes) bytes,
sum(decode(autoextensible,'YES',MAXbytes - bytes,0 )) ARTACAK,
count(decode(autoextensible,'NO',0)) NOTO,
count(decode(autoextensible,'YES',0)) OTO
from dba_data_files
group by tablespace_name) a,
(select tablespace_name, sum(bytes) bytes
from dba_free_space
group by tablespace_name) f
where d.tablespace_name = a.tablespace_name(+)
and d.tablespace_name = f.tablespace_name(+)
and NOT (d.extent_management like 'LOCAL'and d.contents like 'TEMPORARY')
UNION ALL
select d.tablespace_name "NAME",
d.contents "TYPE",
nvl(a.bytes /1024/1024,0) "TOTAL(MB)",
nvl(t.bytes,0)/1024/1024 "USAGE(MB)",
nvl(a.bytes - nvl(t.bytes,0),0)/1024/1024 "FREE(MB)",
nvl(t.bytes/a.bytes * 100,0) "FREE PCT %",
nvl(a.ARTACAK,0)/1024/1024 "EXTENSIBLE(MB)",
nvl(t.bytes/(a.bytes + nvl(a.ARTACAK,0)) * 100,0) "USED PCT OF MAX %", a.NOTO, a.OTO
from sys.dba_tablespaces d,
(select tablespace_name, sum(bytes) bytes,
sum(decode(autoextensible,'YES',MAXbytes - bytes,0 )) ARTACAK,
count(decode(autoextensible,'NO',0)) NOTO,
count(decode(autoextensible,'YES',0)) OTO
from dba_temp_files
group by tablespace_name) a,
(select tablespace_name, sum(bytes_used) bytes 
from v$temp_extent_pool
group by tablespace_name) t
where d.tablespace_name = a.tablespace_name(+)
and d.tablespace_name = t.tablespace_name(+)
and d.extent_management like 'LOCAL'
and d.contents like 'TEMPORARY%'
order by 3 desc;
exit;
