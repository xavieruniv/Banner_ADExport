-- BEGIN: Xavier Email Data Extraction
-- Filename: xm_extract_create.sql
-- Date Creation: Feb 23, 2017
-- Date Revised:
-- Release: 2017-1.2.001

-- FYI: Release format: YYYY-Quarter.Month.QuarterChangeCounter

column a1 new_value filename_user;
column a2 new_value filename_xps;
column b1 new_value fileloc_unc;
column b2 new_value fileloc_localp;
column b3 new_value fileloc_localt;
column c new_value rel_ver;

select
  'ldap_'||to_char(sysdate, 'YYYYMMDDHH24MISS')||'U.new.txt' a1,
  'ldap_'||to_char(sysdate, 'YYYYMMDDHH24MISS')||'XPS.new.txt' a2,
  '\\xavier.xula.local\DFS\ITC-Library\ITC-Applications-Support\ITCPA\DepartmentShares\itc\email\production' b1,
  'D:\sched_jobs\idm\output\email\production' b2,
  'D:\sched_jobs\idm\output\email\test' b3,
  'Release: 2017-1.2.001' c
from dual;

set pagesize 0 linesize 999 trimspool on feed off verify off;

spool &fileloc_localp.\&filename_user;

select
--  'Employee' "UserType",
--  GLBEXTR.GLBEXTR_USER_ID "UserAccountStatus",
--  GLBEXTR.GLBEXTR_ACTIVITY_DATE "ActivityDate",
  trim(to_char(XVW_GENPERS.GENPERS_PIDM) ||':'||
  nvl(XVW_GENPERS.GENPERS_NAME_PREFIX,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_FIRST_NAME,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_MI,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_LAST_NAME,'NA')||':'||
  nvl(XVW_GENPERS.GENPERS_NAME_SUFFIX,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_GOBTPAC_USERNAME, 'NA')||':'||
  decode(XVW_GENPERS.GENPERS_GOBTPAC_USERNAME, null, 'NA', XVW_GENPERS.GENPERS_GOBTPAC_USERNAME || '@xula.edu')||':'||
  substr(XVW_GENPERS.GENPERS_ID, 5,5)||':'||
  'active'||':'||
  'NA:NA:NA:NA:NA:NA:NA:NA:NA:NA:'|| 'NBBPOSN_TITLE' ||':NA:NA:NA:'||
  nvl(AP_EMPLOYEE.HOME_ORGANIZATION,'NA')||':'||
  nvl(AP_EMPLOYEE.HOME_ORGANIZATION_DESC,'NA')||':'||nvl(XEMP_PHXU.SPRTELE_PHONE_NUMBER, XEMP_PHOR.SPRTELE_PHONE_NUMBER)||':'||XEMP_PHFX.SPRTELE_PHONE_NUMBER||':0:NA:NA'||':'||
  (case
    when AP_EMPLOYEE.EMPLOYEE_CLASS in ('06','13') then 'Faculty'
    else 'Staff'
   end)||':'||
  (case
    when GLBEXTR.GLBEXTR_USER_ID = 'CREATE' then 'add'
    else 'nomod'
   end)||':'||'NA:NA:'||
   '628044'||rpad(nvl(XVW_GENPERS.GENPERS_ID,'100000000'),9,1)||'00') "Convergence"
from GENERAL.GUBSRVY GUBSRVY,
     GENERAL.GLBEXTR GLBEXTR,
     OPERA.XVW_GENPERS XVW_GENPERS,
     BANINST1.AP_EMPLOYEE AP_EMPLOYEE,
     OPERA.XVW_SPRTELE XEMP_PHXU,
     OPERA.XVW_SPRTELE XEMP_PHOR,
     OPERA.XVW_SPRTELE XEMP_PHFX
where ( GUBSRVY.GUBSRVY_EXTR_APPLICATION = GLBEXTR.GLBEXTR_APPLICATION
  and GUBSRVY.GUBSRVY_EXTR_SELECTION = GLBEXTR.GLBEXTR_SELECTION
  and GUBSRVY.GUBSRVY_EXTR_CREATOR_ID = GLBEXTR.GLBEXTR_CREATOR_ID
  and GLBEXTR.GLBEXTR_USER_ID = 'CREATE'
  and GLBEXTR.GLBEXTR_KEY = XVW_GENPERS.GENPERS_PIDM
  and XVW_GENPERS.GENPERS_PIDM = AP_EMPLOYEE.PERSON_UID
  and XVW_GENPERS.GENPERS_PIDM = XEMP_PHXU.SPRTELE_PIDM (+)
  and XVW_GENPERS.GENPERS_PIDM = XEMP_PHOR.SPRTELE_PIDM (+)
  and XVW_GENPERS.GENPERS_PIDM = XEMP_PHFX.SPRTELE_PIDM (+) )
  and ( GUBSRVY.GUBSRVY_NAME = 'UACCT_XMAIL'
  and AP_EMPLOYEE.EMPLOYEE_STATUS <> 'T'
--  and :uacct_btn_PROCESS = 1
  and 'XEMP_PHXU' = XEMP_PHXU.GTVSDAX_INTERNAL_CODE (+)
  and 'XEMP_PHOR' = XEMP_PHOR.GTVSDAX_INTERNAL_CODE (+)
  and 'XEMP_PHFX' = XEMP_PHFX.GTVSDAX_INTERNAL_CODE (+)
  and AP_EMPLOYEE.EMPLOYEE_CLASS NOT IN ('08','12','14') )
  and not exists(
                 select 'x'
                 from glbextr p
                 where p.glbextr_application = 'ITC'
                   and p.glbextr_selection   = 'UACCT_XMAIL'
                   and p.glbextr_creator_id  = 'SVCJOBSUB'
                   and p.glbextr_user_id     = 'PROCESSING'
                   and p.glbextr_key         = XVW_GENPERS.GENPERS_PIDM);

spool off;

spool &fileloc_localp.\&filename_xps;

select
--   'ProspectStudent',
--   XPS_EMAIL.GLBEXTR_USER_ID,
--   XPS.GLBEXTR_ACTIVITY_DATE,
  trim(to_char(XVW_GENPERS.GENPERS_PIDM) ||':'||
  nvl(XVW_GENPERS.GENPERS_NAME_PREFIX,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_FIRST_NAME,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_MI,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_LAST_NAME,'NA')||':'||
  nvl(XVW_GENPERS.GENPERS_NAME_SUFFIX,'NA') ||':'||
  nvl(XVW_GENPERS.GENPERS_GOBTPAC_USERNAME, 'NA')||':'||
  decode(XVW_GENPERS.GENPERS_GOBTPAC_USERNAME, null, 'NA', XVW_GENPERS.GENPERS_GOBTPAC_USERNAME || '@xula.edu')||':'||
  substr(XVW_GENPERS.GENPERS_ID, 5,5)||':'||
  'active'||':'||
  'NA:NA:NA:NA:NA:NA:NA:NA:NA:NA:NA:NA:MAJOR1:MAJOR2:NA:NA:::0:NA:NA'||':Prospect:'||
  (case
    when XPS_EMAIL.GLBEXTR_USER_ID in ('CREATE','PENDING') then 'add'
    else 'nomod'
   end)||':'||'NA:NA:'||
   '628044'||rpad(nvl(XVW_GENPERS.GENPERS_ID,'100000000'),9,1)||'00')
from GENERAL.GUBSRVY GUBSRVY,
     GENERAL.GLBEXTR XPS,
     OPERA.XVW_GENPERS XVW_GENPERS,
     GENERAL.GLBEXTR XPS_EMAIL
where ( GUBSRVY.GUBSRVY_EXTR_APPLICATION = XPS.GLBEXTR_APPLICATION
  and GUBSRVY.GUBSRVY_EXTR_SELECTION = XPS.GLBEXTR_SELECTION
  and GUBSRVY.GUBSRVY_EXTR_CREATOR_ID = XPS.GLBEXTR_CREATOR_ID
  and XPS.GLBEXTR_KEY = XVW_GENPERS.GENPERS_PIDM
  and XPS.GLBEXTR_KEY = XPS_EMAIL.GLBEXTR_KEY )
  and ( GUBSRVY.GUBSRVY_NAME = 'XJS001'
-- and :uacct_btn_PROCESS = 1
  and XPS_EMAIL.GLBEXTR_APPLICATION = 'ITC'
  and XPS_EMAIL.GLBEXTR_SELECTION   = 'UACCT_XMAILP'
  and XPS_EMAIL.GLBEXTR_CREATOR_ID  = 'SVCJOBSUB'
  and XPS_EMAIL.GLBEXTR_USER_ID     = 'CREATE'
  and not exists ( select 'X' "PlaceHolder"
                   from GENERAL.GURSRVQ GURSRVQ,
                        SATURN.SFBETRM SFBETRM
                   where GURSRVQ.GURSRVQ_NAME = 'XSJ001_TERMCODE'
                     and GURSRVQ.GURSRVQ_QUESTION_NO = 1
                     and SFBETRM.SFBETRM_PIDM = XPS_EMAIL.GLBEXTR_KEY
                     and SFBETRM.SFBETRM_TERM_CODE IN (GURSRVQ.GURSRVQ_RESPONSE_1_TEXT, GURSRVQ.GURSRVQ_RESPONSE_2_TEXT, GURSRVQ.GURSRVQ_RESPONSE_3_TEXT, GURSRVQ.GURSRVQ_RESPONSE_4_TEXT, GURSRVQ.GURSRVQ_RESPONSE_5_TEXT)
                     and SFBETRM.SFBETRM_AR_IND <> 'N' ) );


spool off;

-- User (Employee/Student) update and Prospect student update
update glbextr set
  glbextr_user_id = 'PROCESSING',
  glbextr_activity_date = sysdate
where glbextr_application = 'ITC'
  and glbextr_selection  in ('UACCT_XMAIL', 'UACCT_XMAILP')
  and glbextr_creator_id  = 'SVCJOBSUB'
  and glbextr_user_id     = 'CREATE';

commit;

REM REMOVE ANY EMPTY OUTPUT FILES HERE!
host D:\bin\isFileEmpty.bat &fileloc_localp.\&filename_xps;
host D:\bin\isFileEmpty.bat &fileloc_localp.\&filename_user;
host dir /b /s &fileloc_localp.\&filename_xps>>D:\sched_jobs\idm\data\idmfile_ext.txt
host dir /b /s &fileloc_localp.\&filename_user>>D:\sched_jobs\idm\data\idmfile_ext.txt
host echo Y | move &fileloc_localp.\&filename_xps &fileloc_unc
host echo Y | move &fileloc_localp.\&filename_user &fileloc_unc

quit;

-- END: Xavier Email Data Extraction
