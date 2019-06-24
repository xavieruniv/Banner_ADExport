-- BEGIN: Employee Xavier Email Data Extraction
-- Filename: xm_check4_create.sql
-- Date Creation: Feb 23, 2017
-- Date Revised:
-- Release: 2017-1.2.001

-- FYI: Release format: YYYY-Quarter.Month.QuarterChangeCounter

column a new_value filename;
column b new_value fileloc;
column pc new_value rec_count;

select
  count(glbextr_key) pc,
  (case
     when count(glbextr_key) > 0 then 'xm_process_create.txt'
     else 'xm_noprocess_create.txt'
   end) a,
  'D:\sched_jobs\idm' b
from glbextr
where glbextr_application = 'ITC'
  and glbextr_selection  in ('UACCT_XMAIL','UACCT_XMAILP')
  and glbextr_creator_id  = 'SVCJOBSUB'
  and glbextr_user_id     = 'CREATE';

host echo Y | del &fileloc.\xm_*process_create.txt

set pagesize 0 linesize 999 trimspool on feed off verify off;

spool &fileloc.\&filename;
prompt &rec_count;
spool off;

quit;
