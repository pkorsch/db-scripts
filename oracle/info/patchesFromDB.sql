--Patches info from DB

set serverout on
exec dbms_qopatch.get_sqlpatch_status;


set pagesize 0
set long 1000000 

--Where's my home and inventory?
select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) "Home and Inventory" from dual;

--Has a specific patch been applied?
select xmltransform(dbms_qopatch.is_patch_installed('&patchnumber'), dbms_qopatch.get_opatch_xslt) "Patch installed?" from dual;

--The equivalent of opatch lsinventory -detail
select xmltransform(dbms_qopatch.get_opatch_lsinventory, dbms_qopatch.get_opatch_xslt) from dual; 


--fixed bugs
select xmltransform(dbms_qopatch.get_opatch_bugs, dbms_qopatch.get_opatch_xslt) from dual;

select owner, directory_name, directory_path from dba_directories where directory_name like 'OPATCH%' order by 2;
