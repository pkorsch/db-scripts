--Locks

--Lock Info

select	OS_USER_NAME os_user,
	PROCESS os_pid,
	ORACLE_USERNAME oracle_user,
	l.SID oracle_id,
	decode(TYPE,
		'MR', 'Media Recovery',
		'RT', 'Redo Thread',
		'UN', 'User Name',
		'TX', 'Transaction',
		'TM', 'DML',
		'UL', 'PL/SQL User Lock',
		'DX', 'Distributed Xaction',
		'CF', 'Control File',
		'IS', 'Instance State',
		'FS', 'File Set',
		'IR', 'Instance Recovery',
		'ST', 'Disk Space Transaction',
		'TS', 'Temp Segment',
		'IV', 'Library Cache Invalidation',
		'LS', 'Log Start or Switch',
		'RW', 'Row Wait',
		'SQ', 'Sequence Number',
		'TE', 'Extend Table',
		'TT', 'Temp Table', type) lock_type,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', lmode) lock_held,
	decode(REQUEST,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', request) lock_requested,
	decode(BLOCK,
		0, 'Not Blocking',
		1, 'Blocking',
		2, 'Global', block) status,
	OWNER,
	OBJECT_NAME
from	v$locked_object lo,
	dba_objects do,
	v$lock l
where 	lo.OBJECT_ID = do.OBJECT_ID
AND     l.SID = lo.SESSION_ID;


--SQL Lock Info

select	sn.USERNAME,
	m.SID,
	sn.SERIAL#,
	m.TYPE,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_type,
	decode(REQUEST,
		0, 'None', 
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)', 
		4, 'Share', 
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_requested,
	m.ID1,
	m.ID2,
	t.SQL_TEXT
from 	v$session sn, 
	v$lock m , 
	v$sqltext t
where 	t.ADDRESS = sn.SQL_ADDRESS 
and 	t.HASH_VALUE = sn.SQL_HASH_VALUE 
and 	((sn.SID = m.SID and m.REQUEST != 0) 
or 	(sn.SID = m.SID and m.REQUEST = 0 and LMODE != 4 and (ID1, ID2) in
        (select s.ID1, s.ID2 
         from 	v$lock S 
         where 	REQUEST != 0 
         and 	s.ID1 = m.ID1 
         and 	s.ID2 = m.ID2)))
order by sn.USERNAME, sn.SID, t.PIECE;

