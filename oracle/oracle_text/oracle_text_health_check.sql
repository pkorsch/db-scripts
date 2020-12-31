REM srdc_Text_Health_Check.sql - collect Oracle Text Health Check information
define SRDCNAME='Text_Health_Check'
SET MARKUP HTML ON PREFORMAT ON
set TERMOUT off FEEDBACK off VERIFY off TRIMSPOOL on HEADING off
COLUMN SRDCSPOOLNAME NOPRINT NEW_VALUE SRDCSPOOLNAME
select 'SRDC_'||upper('&&SRDCNAME')||'_'||upper(instance_name)||'_'||
        to_char(sysdate,'YYYYMMDD_HH24MISS') SRDCSPOOLNAME from v$instance;
set TERMOUT on MARKUP html preformat on
REM
spool &&SRDCSPOOLNAME..txt
select '+----------------------------------------------------+' from dual
union all
select '| Diagnostic-Name: '||'&&SRDCNAME' from dual
union all
select '| Timestamp:       '||
        to_char(systimestamp,'YYYY-MM-DD HH24:MI:SS TZH:TZM') from dual
union all
select '| Machine:         '||host_name from v$instance
union all
select '| Version:         '||version from v$instance
union all
select '| DBName:          '||name from v$database
union all
select '| Instance:        '||instance_name from v$instance
union all
select '+----------------------------------------------------+' from dual
/
set HEADING on MARKUP html OFF preformat off
REM === -- end of standard header -- ===
REM
SET LINESIZE 90;
SET SERVEROUTPUT ON FORMAT WRAP;
DECLARE
 db_name     VARCHAR2(30);
 db_version  VARCHAR2(30);
 v_count     NUMBER := 0;
 ctx_check   NUMBER := 0;
 v_ver_dict  VARCHAR2(10);
 v_ver_code  VARCHAR2(10);
 v_dri_ver   VARCHAR2(10);
 v_stmt VARCHAR2 (250);

 CURSOR c_feat IS SELECT comp_name,status,version
   FROM dba_registry ORDER BY comp_id;
 CURSOR c_inval IS SELECT * FROM dba_objects
   WHERE status !='VALID' AND OWNER = 'CTXSYS' ORDER BY object_type, object_name;
 CURSOR c_other_objects IS SELECT owner, object_name, object_type, status FROM dba_objects
   WHERE owner = 'SYS'
     AND (object_name like 'CTX_%' or object_name like 'DRI%')
   ORDER BY 2,3;
 CURSOR c_count_obj IS SELECT object_type, count(*) count FROM dba_objects
   WHERE owner='CTXSYS' GROUP BY object_type ORDER BY 1;
 CURSOR c_text_indexes IS
   SELECT c.*, i.status,i.domidx_status,i.domidx_opstatus
   FROM ctxsys.ctx_indexes c, dba_indexes i
   WHERE c.idx_owner = i.owner
     AND c.idx_name = i.index_name
   ORDER BY 2,3;
 CURSOR c_dba_errors IS SELECT owner, name, type, line, position, text
  FROM dba_errors
  WHERE owner = 'CTXSYS'
      OR (owner = 'SYS' AND (name like 'CTX_%' or name like 'DRI%'))
  ORDER BY owner, name, sequence;
 CURSOR c_errors IS SELECT * FROM ctxsys.ctx_index_errors
   ORDER BY err_timestamp DESC, err_index_owner, err_index_name;

 PROCEDURE display_banner
 IS
 BEGIN
   DBMS_OUTPUT.PUT_LINE( '**********************************************************************');
 END display_banner;

BEGIN
 DBMS_OUTPUT.ENABLE(900000);
 SELECT name INTO db_name FROM v$database;
 SELECT version INTO db_version FROM v$instance;

 DBMS_OUTPUT.PUT_LINE( 'Oracle Text Health Check Tool ' || TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
 DBMS_OUTPUT.PUT_LINE('.');
 display_banner;
 DBMS_OUTPUT.PUT_LINE('Database:');
 display_banner;
 DBMS_OUTPUT.PUT_LINE ('--> name:                    ' || db_name );
 DBMS_OUTPUT.PUT_LINE ('--> version:                 ' || db_version );
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Database Components:');
 display_banner;
 FOR v_feat IN c_feat LOOP
   DBMS_OUTPUT.PUT_LINE( '--> ' || rpad(v_feat.comp_name, 35) || ' '
     || rpad(v_feat.version, 10) || '   ' || rpad(v_feat.status, 10));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Oracle Text Status and Version:');
 display_banner;
 SELECT * INTO v_ver_dict, v_ver_code FROM ctxsys.ctx_version;
 DBMS_OUTPUT.PUT_LINE('.. CTXSYS data dictionary version (Ver Dict) : '||
  v_ver_dict);
 DBMS_OUTPUT.PUT_LINE('.. Linked-in code version (Ver Code) : '||
  v_ver_code);
 SELECT substr(ctxsys.dri_version,1,10) INTO v_dri_ver FROM dual;
 DBMS_OUTPUT.PUT_LINE('.. DRI Version : '|| v_dri_ver);
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Invalid Objects in CTXSYS Schema:');
 display_banner;
 FOR v_inval IN c_inval LOOP
   DBMS_OUTPUT.PUT_LINE( '.. CTXSYS.' || rpad(v_inval.object_name,30) ||
     ' -  ' || v_inval.object_type );
   v_count := c_inval%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no invalid objects in the CTXSYS schema');
   DBMS_OUTPUT.PUT_LINE ('.');
 END IF;

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Possible Text-related Objects under the SYS schema:');
 display_banner;
 v_count := 0;
 FOR v_other_objects IN c_other_objects LOOP
   DBMS_OUTPUT.PUT_LINE( '.. ' || v_other_objects.owner || '.' ||
    v_other_objects.object_name || ' -  ' || v_other_objects.object_type ||
    ' -  ' || v_other_objects.status );
   v_count := c_other_objects%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no Text-related Objects under the SYS schema');
 ELSE
   DBMS_OUTPUT.PUT_LINE ('  ');
   DBMS_OUTPUT.PUT_LINE('If objects are listed above, review the following notes:');
   DBMS_OUTPUT.PUT_LINE('  Note 1313273.1 - Invalid SYS-Owned Text Objects / How To Remove');
   DBMS_OUTPUT.PUT_LINE('      Text Objects From The SYS Schema When Text Is Installed/In Use?');
   DBMS_OUTPUT.PUT_LINE('  Note 558894.1  - Invalid Oracle Text Object Under User SYS Even');
   DBMS_OUTPUT.PUT_LINE('      When Oracle Text is not Installed');
   DBMS_OUTPUT.PUT_LINE('If Oracle Text is invalid, open a Service Request.');
   DBMS_OUTPUT.PUT_LINE('  Support, see INTERNAL Note.746970.1.');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');
 
 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Compilation errors of invalid Text-related objects under');
 DBMS_OUTPUT.PUT_LINE (' CTXSYS and SYS schemas:');
 display_banner;
 v_count := 0;
 FOR v_dba_errors IN c_dba_errors LOOP
   EXIT WHEN (c_dba_errors%NOTFOUND);
   DBMS_OUTPUT.PUT_LINE( '.. ' || v_dba_errors.type || ' ' || 
   v_dba_errors.owner || '.' || v_dba_errors.name );
   DBMS_OUTPUT.PUT_LINE( '.... at Line/Col: ' || TO_CHAR(v_dba_errors.line) || '/' || 
   TO_CHAR(v_dba_errors.position) );
   DBMS_OUTPUT.PUT_LINE('.... ' || v_dba_errors.text);
   v_count := c_dba_errors%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no errors from Text-related objects under');
   DBMS_OUTPUT.PUT_LINE(' CTXSYS and SYS schemas');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Summary count of CTXSYS schema objects:');
 display_banner;
 FOR v_count_obj IN c_count_obj LOOP
   DBMS_OUTPUT.PUT_LINE('.. ' || rpad(v_count_obj.object_type,14) ||
                        '   ' || lpad(v_count_obj.count,3));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Text Indexes:');
 display_banner;
 v_count := 0;
 FOR v_text_indexes IN c_text_indexes LOOP
 DBMS_OUTPUT.PUT('.. ' || v_text_indexes.idx_owner ||
   '.' || v_text_indexes.idx_name || ' is ');
 IF (v_text_indexes.status != 'VALID' OR
     v_text_indexes.domidx_status != 'VALID' OR
     v_text_indexes.domidx_opstatus != 'VALID') THEN
   DBMS_OUTPUT.PUT_LINE('INVALID');
   DBMS_OUTPUT.PUT_LINE('.... INDEX STATUS => '||v_text_indexes.status);
   DBMS_OUTPUT.PUT_LINE('.... DOMAIN INDEX STATUS => '||v_text_indexes.domidx_status);
   DBMS_OUTPUT.PUT_LINE('.... DOMAIN INDEX OPERATION STATUS => '
     ||v_text_indexes.domidx_opstatus);
 ELSE
   DBMS_OUTPUT.PUT_LINE('VALID');
 END IF;
 DBMS_OUTPUT.PUT('.... Table: ' || v_text_indexes.idx_table_owner
   || '.' || v_text_indexes.idx_table);
 DBMS_OUTPUT.PUT_LINE(', Indexed Column: ' || v_text_indexes.idx_text_name);
 DBMS_OUTPUT.PUT_LINE('.... Index Type: ' || v_text_indexes.idx_type);
 v_count := c_text_indexes%ROWCOUNT;
 END LOOP;
 IF v_count = 0 then
   DBMS_OUTPUT.PUT_LINE('There are no Text indexes');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Ten (10) most recent text index errors (ctx_index_errors):');
 display_banner;
 v_count := 0;
 FOR v_errors IN c_errors LOOP
   EXIT WHEN (c_errors%NOTFOUND) OR (c_errors%ROWCOUNT > 9);
   DBMS_OUTPUT.PUT_LINE(to_char(v_errors.ERR_TIMESTAMP,'Dy Mon DD HH24:MI:SS YYYY'));
   DBMS_OUTPUT.PUT_LINE('.. Index name: ' || v_errors.err_index_owner
     || '.' || v_errors.err_index_name || '     Rowid: ' || v_errors.err_textkey);
   DBMS_OUTPUT.PUT_LINE('.. Error: ');
   DBMS_OUTPUT.PUT_LINE('   '||
     rtrim(replace(v_errors.err_text,chr(10),chr(10)||'   '),chr(10)||'   '));
   v_count := c_errors%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no errors logged in CTX_INDEX_ERRORS');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Testing Text Index Creation:');
 display_banner;
 -- Create text_healthcheck user
 SELECT COUNT (1) INTO v_count FROM dba_users
  WHERE username = 'TEXT_HEALTHCHECK';
 IF v_count != 0 THEN
  DBMS_OUTPUT.PUT_LINE ('..Dropping user TEXT_HEALTHCHECK');
  EXECUTE IMMEDIATE ('DROP USER text_healthcheck CASCADE');
  DBMS_OUTPUT.PUT_LINE ('....User TEXT_HEALTHCHECK dropped successfully');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('..Creating user TEXT_HEALTHCHECK');
 v_stmt := 'GRANT connect,resource,ctxapp TO text_healthcheck IDENTIFIED BY zexz_healthcheck';
 EXECUTE IMMEDIATE (v_stmt);
 v_stmt := 'alter user text_healthcheck default tablespace sysaux quota unlimited on sysaux';
 EXECUTE IMMEDIATE (v_stmt);
 DBMS_OUTPUT.PUT_LINE ('....User TEXT_HEALTHCHECK created successfully');
 -- Create context index
 DBMS_OUTPUT.PUT_LINE ('..Testing creation of Text index type CONTEXT');
 v_stmt :=
     'CREATE TABLE text_healthcheck.text_hc_tab (quick_id NUMBER '
   || 'constraint text_hc_pk PRIMARY KEY, '
   || 'text VARCHAR2(80))';
 DBMS_OUTPUT.PUT_LINE('....Creating table TEXT_HC_TAB');
 EXECUTE IMMEDIATE(v_stmt);
 DBMS_OUTPUT.PUT_LINE('....Inserting test data');
 v_stmt :=
      'INSERT INTO text_healthcheck.text_hc_tab VALUES (1,'
   || '''The cat sat on the mat'')';
 EXECUTE IMMEDIATE(v_stmt);
 v_stmt :=
      'INSERT INTO text_healthcheck.text_hc_tab VALUES (2,'
   || '''The quick brown fox jumps over the lazy dog'')';
 EXECUTE IMMEDIATE(v_stmt);
 EXECUTE IMMEDIATE('COMMIT');
 v_stmt :=
      'CREATE INDEX text_healthcheck.text_hc_idx '
   || 'ON text_healthcheck.text_hc_tab(text) INDEXTYPE IS CTXSYS.CONTEXT';
 DBMS_OUTPUT.PUT_LINE('....Creating text index TEXT_HC_IDX');
 EXECUTE IMMEDIATE(v_stmt);
 DBMS_OUTPUT.PUT_LINE ('....Text index TEXT_HC_IDX created successfully');
 DBMS_OUTPUT.PUT_LINE ('  ');
 DBMS_OUTPUT.PUT_LINE ('..Dropping user TEXT_HEALTHCHECK');
 EXECUTE IMMEDIATE ('DROP USER text_healthcheck CASCADE');
 DBMS_OUTPUT.PUT_LINE ('....User TEXT_HEALTHCHECK dropped successfully');
 DBMS_OUTPUT.PUT_LINE ('  ');
 DBMS_OUTPUT.PUT_LINE ('Text Index Creation Test complete');
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;

 EXCEPTION
  WHEN OTHERS THEN
   DBMS_OUTPUT.PUT('....');
   DBMS_OUTPUT.PUT_LINE (SQLERRM);
   display_banner;

END;
/
SET SERVEROUTPUT OFF
spool off
exit
