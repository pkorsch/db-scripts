set linesize 200
set pagesize 500

col "DISK_NAME"   format a30
col group_number heading GROUP|NUMBER
col header_status format a15
col "GROUP_NAME"  format a10
col path          format a40

select
   g.name "GROUP_NAME",
   g.group_number,
   d.header_status,
   sum(d.total_mb) "TOTAL_MB",
   sum(d.free_mb) "FREE_MB",
   sum(d.total_mb)-sum(d.free_mb) "USED_MB",
  (sum(d.total_mb)-sum(d.free_mb)) / sum(d.total_mb) * 100 "PERCENT_USED"
from
   v$asm_disk d,
   v$asm_diskgroup g
where
   d.group_number = g.group_number (+)
and
   d.header_status = 'MEMBER'
group by
   g.name,
   g.group_number,
   d.header_status
order by
   g.name;
