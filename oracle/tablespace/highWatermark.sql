select a.tablespace_name, a.file_name, a.bytes/1024/1024 file_size_MB,
       (b.block_id+b.blocks-1)*d.db_block_size/1024/1024 highwater
from dba_data_files a        ,
     (select file_id,block_id,blocks
	  from
		(select file_id,block_id,blocks,row_number() over (partition by file_id order by block_id desc) num
		 from dba_extents)
	  where num=1) b,
      (select value db_block_size          
       from v$parameter          
       where name='db_block_size') d 
where a.file_id  = b.file_id 
order by a.tablespace_name,a.file_name;
