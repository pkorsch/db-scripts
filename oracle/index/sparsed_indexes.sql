set pagesize 10000
set verify off
set feedback off
set linesize 1000
set trim on
set trimspool on
set arraysize 1

column owner format a15
column index_name format a50
column index_part_name format a20
column index_subpart_name format a20
column last_ddl_time  format a13
column x noprint new_value x
column last_analyzed format a13
column index_status format a15

set term off

select decode(user,'SYS','x','x_') x from sys.dual
/

alter session set nls_date_format='dd.mm.yyyy'
/

set term on

define density='&density'

define obj = 'nvl(isp.obj#, nvl(ip.obj#,i.obj#))'
define objp = 'nvl(ip.obj#,i.obj#)'
define rowcnt = 'decode(&obj, isp.obj#, isp.rowcnt, ip.obj#, ip.rowcnt, i.rowcnt)'
define leafcnt = 'decode(&obj, isp.obj#, isp.leafcnt, ip.obj#, ip.leafcnt, i.leafcnt)'
define pctf = 'decode(&obj, isp.obj#, isp.pctfree$, ip.obj#, ip.pctfree$, i.pctfree$)'
define initr = 'decode(&obj, isp.obj#, isp.initrans, ip.obj#, ip.initrans, i.initrans)'
define last_analyzed = 'nvl(decode(&obj, isp.obj#, isp.analyzetime, ip.obj#, ip.analyzetime, i.analyzetime),to_date(''01.01.1900'',''dd.mm.yyyy''))'
define status = 'decode(bitand(decode(&obj, isp.obj#, isp.flags, ip.obj#, ip.flags, i.flags), 1), 1, ''UNUSABLE'', ''USABLE'')'


select /*+ ordered */
  u.name owner,
  o.name  index_name,
  op.subname index_part_name,
  decode(&obj, isp.obj#, o.subname, '') index_subpart_name,
  to_char(100*(1 - floor( &leafcnt -
    &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
  )/&leafcnt),'999.00') ||'%' density,
  floor( &leafcnt -
  &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
  ) extra_blocks,
  decode(max(&last_analyzed),to_date('01.01.1900','dd.mm.yyyy'),'not analyzed',max(&last_analyzed)) last_analyzed,
  &status index_status
from
  sys.ind$  i,
  sys.icol$  ic,
  ( select obj#, part#, bo#, ts#, rowcnt, leafcnt, initrans, pctfree$, analyzetime, flags from sys.indpart$
    union all
    select obj#, part#, bo#, defts#, rowcnt, leafcnt, definitrans, defpctfree, analyzetime, flags from sys.indcompart$ ) ip,
  sys.indsubpart$ isp,
  ( select ts#, blocksize value
    from sys.ts$
      )  p,
  sys.hist_head$  h,
  sys.obj$  o,
  sys.user$  u,
  sys.obj$  op
where
  i.obj# = ip.bo#(+) and
  ip.obj# = isp.pobj#(+) and
  &leafcnt > 1 and
  i.type# in (1) and -- exclude special types
  i.pctthres$ is null and -- exclude IOT secondary indexes
  decode(&obj, isp.obj#, isp.ts#, ip.obj#, ip.ts#, i.ts#) = p.ts# and
  ic.obj# = i.obj# and
  h.obj# = i.bo# and
  h.intcol# = ic.intcol# and
  o.obj# = &obj and
  o.owner# != 0 and
  u.user# = o.owner# and
  op.obj# = &objp
group by
  u.name,
  o.name,
  op.subname,
  decode(&obj, isp.obj#, o.subname, ''),
  &rowcnt,
  &leafcnt,
  &initr,
  &pctf,
  p.value
  ,&status
  having
    100*(1 - floor( &leafcnt -
    &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
    )/&leafcnt) <= nvl('&density','75') and
    floor( &leafcnt -
      &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
    ) > 0
order by
 1,5,4,3,2
/


set linesize 80

undefine rowcnt
undefine leafcnt
undefine pctf
undefine initr
undefine last_analyzed
undefine compress
undefine obj
define density
