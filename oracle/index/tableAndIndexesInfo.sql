--Tables/Indexes

--Tabs w/ Questionable Inds


select 	TABLE_OWNER,
	TABLE_NAME,
	COLUMN_NAME
from  	dba_ind_columns 
where  	COLUMN_POSITION=1
and  	TABLE_OWNER not in ('SYS','SYSTEM')
group  	by TABLE_OWNER, TABLE_NAME, COLUMN_NAME
having  count(*) > 1 ;


--Tabs With More Than 5 Inds

select 	OWNER,
	TABLE_NAME,
	COUNT(*) index_count
from  	dba_indexes 
where  	OWNER not in ('SYS','SYSTEM')
group  	by OWNER, TABLE_NAME 
having  COUNT(*) > 5 
order 	by COUNT(*) desc, OWNER, TABLE_NAME;


--Tables With No Indexes


select 	OWNER,
	TABLE_NAME
from 
(
select 	OWNER, 
	TABLE_NAME 
from 	dba_tables
minus
select 	TABLE_OWNER, 
	TABLE_NAME 
from 	dba_indexes
)
orasnap_noindex
where	OWNER not in ('SYS','SYSTEM')
order 	by OWNER,TABLE_NAME;



--Tables With No PK



select  OWNER,
	TABLE_NAME
from    dba_tables dt
where   not exists (
        select  'TRUE'
        from    dba_constraints dc
        where   dc.TABLE_NAME = dt.TABLE_NAME
        and     dc.CONSTRAINT_TYPE='P')
and 	OWNER not in ('SYS','SYSTEM')
order	by OWNER, TABLE_NAME;



--Disabled Constraints


select  OWNER,
        TABLE_NAME,
        CONSTRAINT_NAME,
        decode(CONSTRAINT_TYPE, 'C','Check',
                                'P','Primary Key',
                                'U','Unique',
                                'R','Foreign Key',
                                'V','With Check Option') type,
        STATUS 
from 	dba_constraints
where 	STATUS = 'DISABLED'
order 	by OWNER, TABLE_NAME, CONSTRAINT_NAME;




--FK Constraints


select 	c.OWNER,
	c.TABLE_NAME,
	c.CONSTRAINT_NAME,
	cc.COLUMN_NAME,
	r.TABLE_NAME,
	rc.COLUMN_NAME,
	cc.POSITION
from 	dba_constraints c, 
	dba_constraints r, 
	dba_cons_columns cc, 
	dba_cons_columns rc
where 	c.CONSTRAINT_TYPE = 'R'
and 	c.OWNER not in ('SYS','SYSTEM')
and 	c.R_OWNER = r.OWNER
and 	c.R_CONSTRAINT_NAME = r.CONSTRAINT_NAME
and 	c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
and 	c.OWNER = cc.OWNER
and 	r.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
and 	r.OWNER = rc.OWNER
and 	cc.POSITION = rc.POSITION
order 	by c.OWNER, c.TABLE_NAME, c.CONSTRAINT_NAME, cc.POSITION;



--FK Index Problems



select 	acc.OWNER,
	acc.CONSTRAINT_NAME,
	acc.COLUMN_NAME,
	acc.POSITION,
	'No Index' Problem
from   	dba_cons_columns acc, 
	dba_constraints ac
where  	ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME
and   	ac.CONSTRAINT_TYPE = 'R'
and     acc.OWNER not in ('SYS','SYSTEM')
and     not exists (
        select  'TRUE' 
        from    dba_ind_columns b
        where   b.TABLE_OWNER = acc.OWNER
        and     b.TABLE_NAME = acc.TABLE_NAME
        and     b.COLUMN_NAME = acc.COLUMN_NAME
        and     b.COLUMN_POSITION = acc.POSITION)
order   by acc.OWNER, acc.CONSTRAINT_NAME, acc.COLUMN_NAME, acc.POSITION;


--Inconsistent Column Names


select 	OWNER,
	COLUMN_NAME,
	TABLE_NAME,
	decode(DATA_TYPE, 'NUMBER', DATA_PRECISION, DATA_LENGTH) datatype
from 	dba_tab_columns 
where  	(COLUMN_NAME, OWNER) in
		(select	COLUMN_NAME, 
			OWNER
	 	 from 	dba_tab_columns
	 	 group	by COLUMN_NAME, OWNER
	  	 having	min(decode(DATA_TYPE, 'NUMBER', DATA_PRECISION, DATA_LENGTH)) <
		 	max(decode(DATA_TYPE, 'NUMBER', DATA_PRECISION, DATA_LENGTH)) )
and 	OWNER not in ('SYS', 'SYSTEM')
order	by COLUMN_NAME,DATA_TYPE ;



--Object Extent Warning


select 	OWNER,
	SEGMENT_NAME,
	SEGMENT_TYPE,
	TABLESPACE_NAME,
	NEXT_EXTENT
from (
	select 	seg.OWNER, 
		seg.SEGMENT_NAME,
			seg.SEGMENT_TYPE, 
		seg.TABLESPACE_NAME,
			t.NEXT_EXTENT
	from 	dba_segments seg,
			dba_tables t
	where 	(seg.SEGMENT_TYPE = 'TABLE'
	and  	 seg.SEGMENT_NAME = t.TABLE_NAME
	and  	 seg.owner = t.OWNER
	and    NOT EXISTS (
			select 	TABLESPACE_NAME
				from 	dba_free_space free
				where 	free.TABLESPACE_NAME = t.TABLESPACE_NAME
				and 	BYTES >= t.NEXT_EXTENT))
	union
	select 	seg.OWNER, 
		seg.SEGMENT_NAME,
			seg.SEGMENT_TYPE, 
		seg.TABLESPACE_NAME,
			c.NEXT_EXTENT
	from 	dba_segments seg,
			dba_clusters c 
	where  	(seg.SEGMENT_TYPE = 'CLUSTER'
	and    	 seg.SEGMENT_NAME = c.CLUSTER_NAME
	and    	 seg.OWNER = c.OWNER
	and    	NOT EXISTS (
			select 	TABLESPACE_NAME
			from 	dba_free_space free
			where 	free.TABLESPACE_NAME = c.TABLESPACE_NAME
			and 	BYTES >= c.NEXT_EXTENT))
	union
	select 	seg.OWNER, 
		seg.SEGMENT_NAME,
			seg.SEGMENT_TYPE, 
		seg.TABLESPACE_NAME,
			i.NEXT_EXTENT
	from 	dba_segments seg,
			dba_indexes  i
	where  	(seg.SEGMENT_TYPE = 'INDEX'
	and    	 seg.SEGMENT_NAME = i.INDEX_NAME
	and    	 seg.OWNER        = i.OWNER
	and    	 NOT EXISTS (
			select 	TABLESPACE_NAME
					from 	dba_free_space free
					where 	free.TABLESPACE_NAME = i.TABLESPACE_NAME
			and 	BYTES >= i.NEXT_EXTENT))
	union
	select 	seg.OWNER, 
		seg.SEGMENT_NAME,
			seg.SEGMENT_TYPE, 
		seg.TABLESPACE_NAME,
			r.NEXT_EXTENT
	from 	dba_segments seg,
			dba_rollback_segs r
	where  	(seg.SEGMENT_TYPE = 'ROLLBACK'
	and    	 seg.SEGMENT_NAME = r.SEGMENT_NAME
	and    	 seg.OWNER        = r.OWNER
	and    	 NOT EXISTS (
			select	TABLESPACE_NAME
					from 	dba_free_space free
					where 	free.TABLESPACE_NAME = r.TABLESPACE_NAME
                and 	BYTES >= r.NEXT_EXTENT))
)
orasnap_objext_warn
order 	by OWNER,SEGMENT_NAME;




--Segment Fragmentation


select 	OWNER,
	TABLESPACE_NAME,
	SEGMENT_NAME,
	SEGMENT_TYPE,
	BYTES,
	EXTENTS,
	MAX_EXTENTS,
	(EXTENTS/MAX_EXTENTS)*100 percentage
from 	dba_segments
where 	SEGMENT_TYPE in ('TABLE','INDEX')
and 	EXTENTS > MAX_EXTENTS/2
order 	by (EXTENTS/MAX_EXTENTS) desc;



--Extents reaching maximum


select owner "Owner",
       segment_name "Segment Name",
       segment_type "Type",
       tablespace_name "Tablespace",
       extents "Ext",
       max_extents "Max"
from dba_segments
where ((max_extents - extents) <= 3) 
and owner not in ('SYS','SYSTEM')
order by owner, segment_name;




--Analyzed Tables


select	OWNER,
	sum(decode(nvl(NUM_ROWS,9999), 9999,0,1)) analyzed,
	sum(decode(nvl(NUM_ROWS,9999), 9999,1,0)) not_analyzed,
	count(TABLE_NAME) total
from 	dba_tables
where 	OWNER not in ('SYS', 'SYSTEM')
group 	by OWNER;



--Recently Analyzed Tables


select 	OWNER,
	TABLE_NAME,
	to_char(LAST_ANALYZED,'MM/DD/YYYY HH24:MI:SS') last_analyzed
from 	dba_tab_columns
where 	OWNER not in ('SYS','SYSTEM')
and 	LAST_ANALYZED is not null
and	COLUMN_ID=1
and 	(SYSDATE-LAST_ANALYZED) < 30
order	by (SYSDATE-LAST_ANALYZED);


--Cached Tables


select 	OWNER,
	TABLE_NAME,
	CACHE
from dba_tables
where OWNER not in ('SYS','SYSTEM')
and CACHE like '%Y'
order by OWNER,TABLE_NAME;





