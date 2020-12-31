--Rollback Segments

--Segments

select 	SEGMENT_NAME,
	OWNER,
	TABLESPACE_NAME,
	SEGMENT_ID,
	FILE_ID,
	BLOCK_ID,
	INITIAL_EXTENT,
	NEXT_EXTENT,
	MIN_EXTENTS,
	MAX_EXTENTS,
	PCT_INCREASE,
	STATUS,
	INSTANCE_NUM
from 	dba_rollback_segs
order	by SEGMENT_NAME;

--Transactions

select NAME,
       VALUE
from   v$sysstat
where  name in (
       'consistent gets',
       'consistent changes',
       'transaction tables consistent reads - undo records applied',
       'transaction tables consistent read rollbacks',
       'data blocks consistent reads - undo records applied',
       'no work - consistent read gets',
       'cleanouts only - consistent read gets',
       'rollbacks only - consistent read gets',
       'cleanouts and rollbacks - consistent read gets')
order  by NAME;


--Contention

select 	b.NAME,
	a.USN seg#,
	GETS,
	WAITS,
	round(((GETS-WAITS)*100)/GETS,2) hit_ratio,
	XACTS active_transactions,
	WRITES
from	v$rollstat a,
	v$rollname b
where	a.USN = b.USN;

--Growth

select 	NAME,
	a.USN,
	RSSIZE,
	OPTSIZE,
	HWMSIZE,
	EXTENDS,
	WRAPS,
	SHRINKS,
	AVESHRINK,
	AVEACTIVE,
	STATUS
from 	v$rollstat a , 
	v$rollname b
where 	a.USN=b.USN
order	by NAME;

