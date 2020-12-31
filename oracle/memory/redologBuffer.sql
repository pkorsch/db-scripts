--Redo Log Buffer
--Contention

select 	NAME,
	GETS,
	MISSES,
	SLEEPS,
	IMMEDIATE_GETS,
	IMMEDIATE_MISSES
from 	v$latch
where 	NAME in ('redo allocation','redo copy');

--Statistics

select 	NAME,
	VALUE
from 	v$sysstat
where  	NAME like 'redo%'                     
and  	VALUE > 0;

