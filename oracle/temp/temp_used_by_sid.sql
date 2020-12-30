 SELECT   s.sid "SID",
         s.username "User",
         s.program "Program",
         u.tablespace "Tablespace",
         u.contents "Contents",
         u.extents "Extents",
         u.blocks * 8 / 1024 "Used Space in MB",
         q.sql_text "SQL TEXT",
         a.object "Object",
         k.bytes / 1024 / 1024 "Temp File Size"
  FROM   v$session s,
         v$sort_usage u,
         v$access a,
         dba_temp_files k,
         v$sql q
 WHERE       s.saddr = u.session_addr
         AND s.sql_address = q.address
         AND s.sid = a.sid
         AND u.tablespace = k.tablespace_name;
