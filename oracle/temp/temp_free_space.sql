select
	tablespace_name,
	curr_size,
	max_size,
	free_size,
	curr_size-free_size used_size,
	pct_free,
	round(((max_size-(curr_size-free_size))/max_size)*100,2) pct_free_total
from
	(select 
		ts.tablespace_name,
		round(dbf.bytes/1024/1024,2) curr_size,
		round(dbf.maxbytes/1024/1024) max_size,
		nvl(round(fs.bytes/1024/1024),0) free_size,
		round((nvl(fs.bytes,0)/dbf.bytes)*100,2) pct_free
	 from
		dba_tablespaces ts,
		(select
			tablespace_name,
			sum(bytes) bytes, 
			sum(greatest(maxbytes,bytes)) maxbytes
		 from
			(select tablespace_name,bytes,maxbytes from dba_temp_files)
		 group by tablespace_name
		) dbf,
		(select
			tablespace_name,
			free_space bytes
		 from dba_temp_free_space
		) fs
	 where ts.tablespace_name=dbf.tablespace_name
	   and ts.tablespace_name=fs.tablespace_name(+)
	)
order by pct_free desc;
