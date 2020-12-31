--Tablespace Information

select	TABLESPACE_NAME,
	INITIAL_EXTENT,
	NEXT_EXTENT,
	MIN_EXTENTS,
	MAX_EXTENTS,
	PCT_INCREASE,
	STATUS,
	CONTENTS
from 	dba_tablespaces
order 	by TABLESPACE_NAME ;

--Coalesced Exts

select	TABLESPACE_NAME,
	TOTAL_EXTENTS,
	EXTENTS_COALESCED,
	PERCENT_EXTENTS_COALESCED,
	TOTAL_BYTES,
	BYTES_COALESCED,
	TOTAL_BLOCKS,
	BLOCKS_COALESCED,
	PERCENT_BLOCKS_COALESCED
from 	dba_free_space_coalesced
order 	by TABLESPACE_NAME;

--Usage

select	a.TABLESPACE_NAME,
	a.BYTES bytes_used,
	b.BYTES bytes_free,
	b.largest,
	round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) percent_used
from 	
	(
		select 	TABLESPACE_NAME,
			sum(BYTES) BYTES 
		from 	dba_data_files 
		group 	by TABLESPACE_NAME
	)
	a,
	(
		select 	TABLESPACE_NAME,
			sum(BYTES) BYTES ,
			max(BYTES) largest 
		from 	dba_free_space 
		group 	by TABLESPACE_NAME
	)
	b
where 	a.TABLESPACE_NAME=b.TABLESPACE_NAME
order 	by ((a.BYTES-b.BYTES)/a.BYTES) desc;



--Users default

select 	USERNAME,
	CREATED,
	PROFILE,
	DEFAULT_TABLESPACE,
	TEMPORARY_TABLESPACE
from 	dba_users
order 	by USERNAME
;


--Objects in SYSTEM TS

select	OWNER,
	SEGMENT_NAME,
	SEGMENT_TYPE,
	TABLESPACE_NAME,
	BYTES
from 	dba_segments
where	TABLESPACE_NAME = 'SYSTEM'
and	OWNER not in ('SYS','SYSTEM')
order 	by OWNER, SEGMENT_NAME;

--Freespace/Largest Ext

select 	TABLESPACE_NAME,
	sum(BYTES) Total_free_space,
   	max(BYTES) largest_free_extent
from 	dba_free_space
group 	by TABLESPACE_NAME;
