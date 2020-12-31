--Shared Pool Information
--Quick Check

select 'You may need to increase the SHARED_POOL_RESERVED_SIZE' Description,
       'Request Failures = '||REQUEST_FAILURES  Logic
from 	v$shared_pool_reserved
where 	REQUEST_FAILURES > 0
and 	0 != (
	select 	to_number(VALUE) 
        from 	v$parameter 
        where 	NAME = 'shared_pool_reserved_size')
union
select 'You may be able to decrease the SHARED_POOL_RESERVED_SIZE' Description,
       'Request Failures = '||REQUEST_FAILURES Logic
from 	v$shared_pool_reserved
where 	REQUEST_FAILURES < 5
and 	0 != ( 
	select 	to_number(VALUE) 
	from 	v$parameter 
	where 	NAME = 'shared_pool_reserved_size');


--Memory Usage

select 	OWNER,
	NAME||' - '||TYPE object,
	SHARABLE_MEM
from 	v$db_object_cache
where 	SHARABLE_MEM > 10000 
and	type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE')
order 	by SHARABLE_MEM desc;

--Loads

select 	OWNER,
	NAME||' - '||TYPE object,
	LOADS
from 	v$db_object_cache
where 	LOADS > 3 
and 	type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE')
order 	by LOADS desc;

--Executions

select 	OWNER,
	NAME||' - '||TYPE object,
	EXECUTIONS
from 	v$db_object_cache
where 	EXECUTIONS > 100 
and 	type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE')
order 	by EXECUTIONS desc;

--Details

select	OWNER,
	NAME,
	DB_LINK,
	NAMESPACE,
	TYPE,
        SHARABLE_MEM,
        LOADS,
        EXECUTIONS,
        LOCKS,
        PINS
from 	v$db_object_cache
order 	by OWNER, NAME;

--Library Cache Statistics

select 	NAMESPACE,
	GETS,
	GETHITS,
	round(GETHITRATIO*100,2) gethit_ratio,
	PINS,
	PINHITS,
	round(PINHITRATIO*100,2) pinhit_ratio,
	RELOADS,
	INVALIDATIONS
from 	v$librarycache;

--Reserve Pool Settings

select 	NAME,
	VALUE
from 	v$parameter
where 	NAME like '%reser%';

--Pinned Objects

select 	NAME,
	TYPE,
	KEPT
from 	v$db_object_cache
where 	KEPT = 'YES';
