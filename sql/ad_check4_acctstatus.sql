-- BEGIN: Employee Active Directory Data Extraction
-- Filename: ad_check4_acctstatus.sql
-- Formerly: ad_check4_create.sql
-- Date Creation: Feb 18, 2017
-- Date Revised:  Mar 08, 2017
-- Release: 2017-1.2

-- FYI: Release format: YYYY-Quarter.Month.QuarterChangeCounter

define fileloc=D:\sched_jobs\idm;

column a1 new_value filename1;
column a2 new_value filename2;
column pc1 new_value rec_count1;
column pc2 new_value rec_count2;

select
  count(glbextr_key) pc1,
  (case
     when count(glbextr_key) > 0 then 'ad_process_create.txt'
     else 'ad_noprocess_create.txt'
   end) a1
from glbextr
where glbextr_application = 'ITC'
  and glbextr_selection   = 'UACCT_XACTD'
  and glbextr_creator_id  = 'SVCJOBSUB'
  and glbextr_user_id     = 'CREATE';

select
  count(xuadstg_samaccountname) pc2,
  (case
     when count(xuadstg_samaccountname) > 0 then 'ad_process_sync.txt'
     else 'ad_noprocess_sync.txt'
   end) a2
from xuadstg
where xuadstg_extract_date is null;

-- host echo Y | del &fileloc.\ad_*process_*.txt

set pagesize 0 linesize 999 trimspool on feed off verify off;

spool &fileloc.\&filename1;
prompt &rec_count1;
spool off;

spool &fileloc.\&filename2;
prompt &rec_count2;
spool off;

quit;
