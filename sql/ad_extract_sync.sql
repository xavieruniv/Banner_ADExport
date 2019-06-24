-- BEGIN: Banner to Active Directory Sync Data Extraction
-- Filename: ad_extract_sync.sql
-- Date Creation: Mar 08, 2017
-- Date Revised:
-- Release: 2017-1.2

-- FYI: Release format: YYYY-Quarter.Month

column a2 new_value filename_new;
column b2 new_value fileloc_new;
column b4 new_value fileloc_localt;
column c new_value rel_ver;

select
  'actdir_'||to_char(sysdate, 'YYYYMMDDHH24MISS')||'.csv' a2,
  '\\xavier.xula.local\DFS\ITC-Library\ITC-Applications-Support\ITCPA\\DepartmentShares\itc\actdir\test' b2,
  'D:\sched_jobs\idm\output\actdir\test' b4,
  'Release: 2017-1' c
from dual;

set pagesize 0 linesize 999 trimspool on feed off verify off;

spool &fileloc_localt.\&filename_new;

select
  '"AccountStatus","Objectguid","Enabled","Samaccountname","Employeeid","EmployeeNumber","Userprincipalname","Mail","DisplayName","Name","Givenname","SN", "Initials","Description","EmployeeType","Department","Title","Manager","ProfilePath"'  datastream
from dual;

select
   XUADSTG_ACCOUNTSTATUS           ||',"'||
   trim(XUADSTG_OBJECTGUID)        ||'",'||
   trim(XUADSTG_ENABLED)           ||','||
   trim(XUADSTG_SAMACCOUNTNAME)    ||','||
   trim(XUADSTG_EMPLOYEEID)        ||',"'||
   trim(XUADSTG_EMPLOYEENUMBER)    ||'",'||
   trim(XUADSTG_USERPRINCIPALNAME) ||','||
   trim(XUADSTG_MAIL)              ||',"'||
   trim(XUADSTG_DISPLAYNAME)       ||'","'||
   trim(XUADSTG_NAME)              ||'","'||
   trim(XUADSTG_GIVENNAME)         ||'","'||
   trim(XUADSTG_SN)                ||'","'||
   trim(XUADSTG_INITIALS)          ||'","'||
   trim(XUADSTG_DESCRIPTION)       ||'",'||
   trim(XUADSTG_EMPLOYEETYPE)      ||',"'||
   trim(XUADSTG_DEPARTMENT)        ||'","'||
   trim(XUADSTG_TITLE)             ||'","'||
   trim(XUADSTG_MANAGER)           ||'",'||
   trim(XUADSTG_PROFILEPATH)       data_extract
from xuadstg
where XUADSTG_EXTRACT_DATE is null;

spool off;

update xuadstg set
  xuadstg_extract_date = sysdate
where xuadstg_extract_date is null;

commit;

host dir /b /s &fileloc_localt.\&filename_new>>D:\sched_jobs\idm\data\idmfile_ext.txt
host echo Y | move &fileloc_localt.\&filename_new &fileloc_new

quit;

-- END: Banner to Active Directory Sync Data Extraction
