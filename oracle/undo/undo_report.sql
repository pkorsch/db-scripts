set markup html on spool on 
SPOOL DB_Info.HTML 
set pagesize 200 
set echo on 

select * from v$version; 

show parameter fast_start_parallel_rollback 

alter session set nls_date_format='dd-mon-yyyy hh24:mi:ss'; 
select sysdate from dual; 

select usn, state, undoblockstotal "Total", undoblocksdone "Done", undoblockstotal-undoblocksdone "ToDo", 
decode(cputime,0,'unknown',sysdate+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400)) "Estimated time to complete" 
from v$fast_start_transactions; 

select ktuxeusn USN, ktuxeslt Slot, ktuxesqn Seq, ktuxesta State, ktuxesiz Undo 
from x$ktuxe 
where ktuxesta <> 'INACTIVE' 
and ktuxecfl like '%DEAD%' 
order by ktuxesiz asc; 

select useg.segment_name, useg.segment_id, useg.tablespace_name, useg.status 
from dba_rollback_segs useg 
where useg.segment_id in (select unique ktuxeusn 
from x$ktuxe 
where ktuxesta <> 'INACTIVE' 
and ktuxecfl like '%DEAD%'); 

exec dbms_lock.sleep(120); 

select usn, state, undoblockstotal "Total", undoblocksdone "Done", undoblockstotal-undoblocksdone "ToDo", 
decode(cputime,0,'unknown',sysdate+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400)) "Estimated time to complete" 
from v$fast_start_transactions; 

exec dbms_lock.sleep(120); 

select ktuxeusn USN, ktuxeslt Slot, ktuxesqn Seq, ktuxesta State,ktuxesiz Undo from x$ktuxe where ktuxesta <> 'INACTIVE' and ktuxecfl like '%DEAD%' order by ktuxesiz asc; 

select usn, state, undoblockstotal "Total", undoblocksdone "Done", undoblockstotal-undoblocksdone "ToDo", decode(cputime,0,'unknown',sysdate+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400)) 
"Estimated time to complete" from v$fast_start_transactions; 

select * from v$fast_start_servers; 

select ktuxeusn, to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') "Time", ktuxesiz, ktuxesta from x$ktuxe where ktuxecfl = 'DEAD'; 

spool off 
set markup html off spool off 
