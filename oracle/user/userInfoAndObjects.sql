--User Information

--User Objects

select 	USERNAME,
	count(decode(o.TYPE#, 2,o.OBJ#,'')) Tabs,
	count(decode(o.TYPE#, 1,o.OBJ#,'')) Inds,
	count(decode(o.TYPE#, 5,o.OBJ#,'')) Syns,
	count(decode(o.TYPE#, 4,o.OBJ#,'')) Views,
	count(decode(o.TYPE#, 6,o.OBJ#,'')) Seqs,
	count(decode(o.TYPE#, 7,o.OBJ#,'')) Procs,
	count(decode(o.TYPE#, 8,o.OBJ#,'')) Funcs,
	count(decode(o.TYPE#, 9,o.OBJ#,'')) Pkgs,
	count(decode(o.TYPE#,12,o.OBJ#,'')) Trigs,
	count(decode(o.TYPE#,10,o.OBJ#,'')) Deps
from 	obj$ o,
	dba_users u
where 	u.USER_ID = o.OWNER# (+)
group	by USERNAME
order	by USERNAME;

--Invalid Objects

select 	OWNER,
	OBJECT_TYPE,
	OBJECT_NAME,
	STATUS
from 	dba_objects
where 	STATUS = 'INVALID'
order 	by OWNER, OBJECT_TYPE, OBJECT_NAME;

--Object Modification

select 	OWNER,
	OBJECT_NAME,
	OBJECT_TYPE,
	to_char(LAST_DDL_TIME,'MM/DD/YYYY HH24:MI:SS') last_modified,
	to_char(CREATED,'MM/DD/YYYY HH24:MI:SS') created,
	STATUS
from   	dba_objects
where  	(SYSDATE - LAST_DDL_TIME) < 7
order 	by LAST_DDL_TIME DESC;

--User Privileges

select 	rp.GRANTEE,
	GRANTED_ROLE,
	rp.ADMIN_OPTION,
	DEFAULT_ROLE,
	PRIVILEGE
from   	dba_role_privs rp, dba_sys_privs sp
where  	rp.GRANTEE = sp.GRANTEE
and	rp.GRANTEE not in ('SYS','SYSTEM','DBA')
order  	by  rp.GRANTEE, GRANTED_ROLE, PRIVILEGE;

