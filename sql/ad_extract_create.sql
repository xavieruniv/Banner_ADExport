-- BEGIN: Employee Active Directory Data Extraction
-- Filename: ad_extract_create.sql
-- Date Creation: Feb 18, 2017
-- Date Revised:
-- Release: 2017-1.2

-- FYI: Release format: YYYY-Quarter.Month

column a1 new_value filename_cur;
column a2 new_value filename_new;
column b1 new_value fileloc_cur;
column b2 new_value fileloc_new;
column b3 new_value fileloc_localp;
column b4 new_value fileloc_localt;
column c new_value rel_ver;

select
  'actdir_'||to_char(sysdate, 'YYYYMMDDHH24MISS')||'E.new.csv' a1,
  'actdir_'||to_char(sysdate, 'YYYYMMDDHH24MISS')||'.csv' a2,
  '\\xavier.xula.local\DFS\ITC-Library\ITC-Applications-Support\ITCPA\DepartmentShares\itc\actdir\production' b1,
  '\\xavier.xula.local\DFS\ITC-Library\ITC-Applications-Support\ITCPA\\DepartmentShares\itc\actdir\test' b2,
  'D:\sched_jobs\idm\output\actdir\production' b3,
  'D:\sched_jobs\idm\output\actdir\test' b4,
  'Release: 2017-1' c
from dual;

set pagesize 0 linesize 999 trimspool on feed off verify off;

spool &fileloc_localp.\&filename_cur;

select
  '"NewUserAttribute","DisplayName","Password","XavierUserAccountName","XavierID","XavierEmailAddress","FirstName","LastName","ActdirIdentifier1","ActdirIdentifier2","ActdirIdentifier3","ActdirIdentifier4","UserType","ActdirIdentifier5","OrgnDesc","UserAccountStatus"' header_record
from dual;

select
  'xavier.xula.local/New_users'                                ||',"'||
  XVW_GENPERS.GENPERS_DISPLAY_NAME                             ||'",'||
  'Xav'||substr(XVW_GENPERS.GENPERS_ID,5,5)                    ||','||
  XVW_GENPERS.GENPERS_GOBTPAC_USERNAME                         ||','||
  XVW_GENPERS.GENPERS_ID                                       ||','||
  XVW_GENPERS.GENPERS_GOBTPAC_USERNAME || '@xula.edu'          ||','||
  XVW_GENPERS.GENPERS_FIRST_NAME                               ||','||
  XVW_GENPERS.GENPERS_LAST_NAME                                ||','||
  NULL                                                         ||','||
  XVW_GENPERS.GENPERS_GOBTPAC_USERNAME || '@xavier.xula.local' ||','||
  'XAVIER\' || XVW_GENPERS.GENPERS_GOBTPAC_USERNAME            ||','||
  XVW_GENPERS.GENPERS_GOBTPAC_USERNAME                         ||','||
  (case
     when AP_EMPLOYEE.EMPLOYEE_CLASS in ('06','13') then 'Faculty'
     else 'Staff'
    end)                                                       ||',"'||
  XVW_GENPERS.GENPERS_DISPLAY_NAME                             ||'",'||
  AP_EMPLOYEE.HOME_ORGANIZATION_DESC                           ||','||
  GLBEXTR.GLBEXTR_USER_ID                                      DATA_STREAM
from GUBSRVY GUBSRVY
join GLBEXTR GLBEXTR on GUBSRVY.GUBSRVY_EXTR_APPLICATION = GLBEXTR.GLBEXTR_APPLICATION
                    and GUBSRVY.GUBSRVY_EXTR_SELECTION   = GLBEXTR.GLBEXTR_SELECTION
                    and GUBSRVY.GUBSRVY_EXTR_CREATOR_ID  = GLBEXTR.GLBEXTR_CREATOR_ID
join XVW_GENPERS XVW_GENPERS on GLBEXTR.GLBEXTR_KEY = XVW_GENPERS.GENPERS_PIDM
join AP_EMPLOYEE AP_EMPLOYEE on XVW_GENPERS.GENPERS_PIDM = AP_EMPLOYEE.PERSON_UID
where GUBSRVY.GUBSRVY_NAME    = 'UACCT_XACTD'
  and GLBEXTR.GLBEXTR_USER_ID = 'CREATE'
  and AP_EMPLOYEE.EMPLOYEE_CLASS NOT IN ('08','12','14');

spool off;

spool &fileloc_localt.\&filename_new;

select
  '"AccountStatus","Objectguid","Enabled","Samaccountname","Employeeid","EmployeeNumber","Userprincipalname","DisplayName","Name","Givenname","SN", "initials","Description","EmployeeType","Department","Title","Manager","ProfilePath"' header_record
from dual;

select
  GLBEXTR.GLBEXTR_USER_ID                                      ||','||
  NULL                                                         ||','||
  'True'                                                       ||','||
  XVW_GENPERS.GENPERS_GOBTPAC_USERNAME                         ||','||
  XVW_GENPERS.GENPERS_ID                                       ||','||
  GOBUMAP.GOBUMAP_UDC_ID                                       ||','||
  XVW_GENPERS.GENPERS_GOBTPAC_USERNAME || '@xavier.xula.local' ||',"'||
  XVW_GENPERS.GENPERS_DISPLAY_NAME                             ||'","'||
  XVW_GENPERS.GENPERS_SORT_NAME                                ||'",'||
  XVW_GENPERS.GENPERS_LAST_NAME                                ||','||
  XVW_GENPERS.GENPERS_FIRST_NAME                               ||','||
  XVW_GENPERS.GENPERS_MI                                       ||','||
  (case
     when AP_EMPLOYEE.EMPLOYEE_CLASS in ('06','13') then 'Faculty'
     else 'Staff'
    end)                                                       ||','||
  (case
     when AP_EMPLOYEE.EMPLOYEE_CLASS in ('06','13') then 'Faculty'
     else 'Staff'
    end)                                                       ||',"'||
  AP_EMPLOYEE.HOME_ORGANIZATION_DESC                           ||'",'||
  NULL                                                         ||',"'||
  f_format_name(mgr.manager_pidm, 'FML')                       ||'",'||
  NULL                                                         DATA_STREAM
from GUBSRVY GUBSRVY
join GLBEXTR GLBEXTR on GUBSRVY.GUBSRVY_EXTR_APPLICATION = GLBEXTR.GLBEXTR_APPLICATION
                    and GUBSRVY.GUBSRVY_EXTR_SELECTION   = GLBEXTR.GLBEXTR_SELECTION
                    and GUBSRVY.GUBSRVY_EXTR_CREATOR_ID  = GLBEXTR.GLBEXTR_CREATOR_ID
join XVW_GENPERS XVW_GENPERS on GLBEXTR.GLBEXTR_KEY = XVW_GENPERS.GENPERS_PIDM
join AP_EMPLOYEE AP_EMPLOYEE on XVW_GENPERS.GENPERS_PIDM = AP_EMPLOYEE.PERSON_UID
join (
      select
       to_number(glbextr_key) emp_pidm,
       to_number(glbextr_user_id) manager_pidm
      from glbextr
      where glbextr_application = 'ITC'
        and glbextr_selection   = 'NUACCTNOTE'
        and glbextr_creator_id  = 'SVCJOBSUB') mgr on XVW_GENPERS.GENPERS_PIDM = mgr.emp_pidm
left join GOBUMAP GOBUMAP on XVW_GENPERS.GENPERS_PIDM    = GOBUMAP.GOBUMAP_PIDM
where GUBSRVY.GUBSRVY_NAME    = 'UACCT_XACTD'
  and GLBEXTR.GLBEXTR_USER_ID = 'CREATE'
  and AP_EMPLOYEE.EMPLOYEE_CLASS NOT IN ('08','12','14');

spool off;

update glbextr set
  glbextr_user_id = 'PROCESSING',
  glbextr_activity_date = sysdate
where glbextr_application = 'ITC'
  and glbextr_selection   = 'UACCT_XACTD'
  AND glbextr_creator_id  = 'SVCJOBSUB'
  and glbextr_user_id     = 'CREATE';

host dir /b /s &fileloc_localp.\&filename_cur>>D:\sched_jobs\idm\data\idmfile_ext.txt
host dir /b /s &fileloc_localt.\&filename_new>>D:\sched_jobs\idm\data\idmfile_ext.txt
host echo Y | move &fileloc_localp.\&filename_cur &fileloc_cur
host echo Y | move &fileloc_localt.\&filename_new &fileloc_new

quit;

-- END: Employee Active Directory Data Extraction
