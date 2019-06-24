-- Program Name: xavldap_xfer3w.sql
-- Revised date: Sept 6, 2007
set echo off verify off head off;

-- Comments:
-- AUDIT TRAIL: 6.0
--      Date: April 23, 2006
--   1. Removed the dynamic shell script from this script and made it a permanent file (/home/oracle/bin/checkFile.shl)
--   2. Made the email message more user friendly
--      - Each column value is on its own line
--      - Supervisors full name and email address appear
--      - Display services IT will automatically activate
--      - Display services that have to be requested 
--   3. In the checkFile.shl created a clean up empty files routine for output files produced by this script.
--   4. Added the column g new_value filename for global use. This will reduce redundant coding
-- 
-- AUDIT TRAIL: 6.1
--    Date: June 28, 2006
--    Added individual Student report to the email report section
-- 
-- AUDIT TRAIL: 7.0
--    Date: March 10, 2007
-- 
-- AUDIT TRAIL: End Audit Trail
-- 

set verify on head on;

column a new_value b;
column c new_value d;
column e new_value f;
column g new_value filename;
column h new_value email_date;
column i new_value wrk_dbname;
column filenameStore new_value filename_store;

select to_char(sysdate, 'yyyymmddhh24mi') a,
       to_char(sysdate, 'ddmonyy') c,
       to_char(sysdate, 'Month dd, YYYY HH24:MI:SS') h
from dual
/

select
 serial# e
from v$session 
where username = USER;

select
  lower(name) i
from v$database
/

select
  'e:\idm\data\activeDir_&b..new' g,
  'activeDir_&b..new' filenameStore
from dual
/

prompt Begin Data Extraction Here!
set head off feed off verify off trimspool on pagesize 0 linesize 350;

--  XAVLDAP_FILE_NAME
-- UNIX data extraction Introduced November 6, 2006 06:50
--

spool &filename..txt;
SELECT
  trim(XAVLDAP_PIDM ||':'||
  nvl(XAVLDAP_PREFIX,'NA') ||':'||
  nvl(XAVLDAP_FIRST_NAME,'NA') ||':'||
  nvl(XAVLDAP_MI,'NA') ||':'||
  nvl(XAVLDAP_LAST_NAME,'NA')||':'||
  nvl(XAVLDAP_SUFFIX,'NA') ||':'||
  nvl(XAVLDAP_USER_IDENTITY, XAVLDAP_ORGN_IDENTITY)||':'||
  nvl(XAVLDAP_EMAIL,'NA')||':'||
  'Xav'||XAVLDAP_PASSWD||':'|| 
  'active'||':'||
--  nvl(XAVLDAP_STREET_ADDRESS1,'NA')||':'||
--  nvl(XAVLDAP_STREET_ADDRESS2,'NA')||':'||
--  nvl(XAVLDAP_STREET_ADDRESS3,'NA')||':'||
--  nvl(XAVLDAP_CITY,'NA') ||':'||
--  nvl(XAVLDAP_STATE,'NA')||':'||
--  nvl(XAVLDAP_ZIP,'NA')||':'||
--  nvl(XAVLDAP_ATYPE_CODE,'NA') ||':'||
--  nvl(XAVLDAP_BLDG_CODE,'NA')||':'||
--  nvl(XAVLDAP_BLDG_DESC,'NA')||':'||
--  nvl(XAVLDAP_ROOM_NUMBER,'NA')||':'||
  nvl(XAVLDAP_POSITION1,'NA')||':'||
--  nvl(XAVLDAP_POSITION2,'NA')||':'||
  nvl(XAVLDAP_MAJOR1,'NA') ||':'||
--  nvl(XAVLDAP_MAJOR2,'NA') ||':'||
  nvl(XAVLDAP_ORGN_CODE,'NA')||':'||
  nvl(XAVLDAP_ORGN_TITLE,'NA')||':'|| 
  nvl(XAVLDAP_CAMPUS_PHONE_NUMBER,'5209999')||':'||
  nvl(XAVLDAP_DEPT_FAX_NUMBER,'NA')||':'||
  nvl(XAVLDAP_SUPERVISOR_PIDM,'0')||':'||
  nvl(XAVLDAP_SUPERVISOR_POSN,'NA')||':'||
  nvl(XAVLDAP_SUPERVISOR_SUFF,'NA')||':'||
  decode(XAVLDAP_USER_TYPE_1,'Xavorg','Person',
                    'Alumni','Person',
                    'Consultant','Person',XAVLDAP_USER_TYPE_1)||':'||
  XAVLDAP_ACTDIR_MODIFY_IND||':'||
  nvl(XAVLDAP_STU_CLASSIFICATION,'NA')||':'||
  nvl(XAVLDAP_COLL_CODE,'NA'))  MY_DATA
FROM KKIRK.XAVLDAP
WHERE XAVLDAP_ACTDIR_MODIFY_IND = 'add'
  and XAVLDAP_ACTDIR_IND is null
/
spool off;

-- Batch New User
insert into KKIRK.XAVLDAP_BATCH (
  XAVLDAP_PIDM,
  XAVLDAP_OUTPUT_FILE,
  XAVLDAP_BATCH_DATE,
  XAVLDAP_COMPLETE_DATE,
  XAVLDAP_ACTIVITY_DATE,
  XAVLDAP_USER)
 (SELECT
    XAVLDAP_PIDM,
    '&filename_store',
    to_date('&email_date','Month dd, YYYY HH24:MI:SS'),
    null,
    sysdate,
    USER
  FROM KKIRK.XAVLDAP
  WHERE XAVLDAP_ACTDIR_MODIFY_IND = 'add'
    and XAVLDAP_ACTDIR_IND is null)
/

insert into OPERA.FILEPEN(
   FILEPEN_FILENAME,
   FILEPEN_NOTIFICATION_IND,
   FILEPEN_STATUS_CODE,
   FILEPEN_EFT_FILENAME,
   FILEPEN_CHG_IND,
   FILEPEN_TRANSFER_TIMESTAMP,
   FILEPEN_ACTIVITY_DATE,
   FILEPEN_USER,
   FILEPEN_SOURCE)
 (select distinct
   '&filename_store',
   null,
   'A',
   null,
   null,
   null,
   sysdate,
   USER,
   'XAVLDAP'
  FROM KKIRK.XAVLDAP
  WHERE XAVLDAP_ACTDIR_MODIFY_IND = 'add'
    and XAVLDAP_ACTDIR_IND is null)
/

COMMIT;

-- End Data Extraction Here!


prompt BEGIN EMAIL NOTIFICATION HERE!
prompt END EMAIL NOTIFICATION HERE!

-- ACTIVATE RECORD
UPDATE KKIRK.XAVLDAP set
  XAVLDAP_ACTIVE_IND = 'active',
  XAVLDAP_TRANSFER_DATE = SYSDATE,
  XAVLDAP_ACTDIR_MODIFY_IND = null
WHERE XAVLDAP_ACTDIR_MODIFY_IND = 'add'
/

commit
/

exit;

