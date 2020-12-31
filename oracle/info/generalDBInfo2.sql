--GENERAL INFO

--Database Information

select 	NAME,
	CREATED,
	LOG_MODE,
	CHECKPOINT_CHANGE#,
	ARCHIVE_CHANGE#
from 	v$database;


--Size

select 	FILE_NAME,
	d.TABLESPACE_NAME,
	d.BYTES datafile_size,
	nvl(sum(e.BYTES),0) bytes_used,
	round(nvl(sum(e.BYTES),0) / (d.BYTES), 4) * 100 percent_used,
	d.BYTES - nvl(sum(e.BYTES),0) bytes_free
from 	DBA_EXTENTS e,
	DBA_DATA_FILES d
where  	d.FILE_ID = e.FILE_ID (+)
group  	by FILE_NAME,d.TABLESPACE_NAME, d.FILE_ID, d.BYTES, STATUS
order  	by d.TABLESPACE_NAME,d.FILE_ID;

--Files

select 	'Archived Log Directory' "Filename",
	value "Location"
from 	v$parameter
where 	name = 'log_archive_dest'
UNION
select 	'Control Files' "Filename",
	value "Location"
from 	v$parameter
where  	name = 'control_files'
UNION
select 	'Datafile' "Filename",
	name "Location"
from   	v$datafile
UNION
select 	'LogFile Member' "Filename",
	member "Location"
from  	v$logfile;


--init.ora

select	NAME,
	VALUE,
	ISDEFAULT,
	ISSES_MODIFIABLE,
	ISMODIFIED
from 	v$parameter
order  	by NAME;


--License

select	SESSIONS_MAX,
	SESSIONS_WARNING,
	SESSIONS_CURRENT,
	SESSIONS_HIGHWATER,
	USERS_MAX
from	v$license;

--Version

select	BANNER product_versions
from	v$version;
