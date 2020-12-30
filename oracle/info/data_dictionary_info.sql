--Data Dictionary Info
--Dictionary Cache

select	PARAMETER,
	GETS,
	GETMISSES,
	round(GETMISSES/GETS,2)*100 "% Cache Misses",
	COUNT,
	USAGE
from 	v$rowcache
where 	GETS > 0
order 	by (GETMISSES/GETS)*100 desc;

--Latch Gets/Misses

select	NAME,
	GETS,
	MISSES,
	round(((GETS-MISSES)*100) / GETS , 2) "Gets/Misses %",
	IMMEDIATE_GETS,
	IMMEDIATE_MISSES
from 	v$latch
where 	GETS != 0
or 	IMMEDIATE_MISSES > 0
order 	by ((GETS-MISSES) / GETS) desc;
