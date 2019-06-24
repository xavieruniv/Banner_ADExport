define FILENAME='&1';

spool &FILENAME;

prompt Remove all records from the stage table
prompt that have not changed.
select count(xuadstg_dn)
from xuadstg
where exists(select 'x'
             from xuadusr
             where xuadusr_dn = xuadstg_dn
               and xuadusr_samaccountname = xuadstg_samaccountname
               and nvl(xuadusr_whenchanged, to_date('31-DEC-2099','DD-MON-YYYY')) = to_date(replace(lower(xuadstg_whenchanged),'.0z',null),'YYYYMMDDHH24MISS'))
/

delete
from xuadstg
where exists(select 'x'
             from xuadusr
             where xuadusr_dn = xuadstg_dn
               and xuadusr_samaccountname = xuadstg_samaccountname
               and nvl(xuadusr_whenchanged, to_date('31-DEC-2099','DD-MON-YYYY')) = to_date(replace(lower(xuadstg_whenchanged),'.0z',null),'YYYYMMDDHH24MISS'))
/

commit
/

prompt update xuadstg_pidm
prompt where xuadstg_samaccountname begin with and not = ('adm-','ops-','tst-')
update xuadstg set
  xuadstg_pidm = (
  select gobtpac_pidm
  from gobtpac
  where lower(trim(gobtpac_external_user)) = lower(trim(xuadstg_samaccountname)))
where substr(lower(xuadstg_samaccountname),1,4) not in ('adm-','ops-','tst-')
  and exists (
   select 'x'
   from gobtpac
   where lower(trim(gobtpac_external_user)) = lower(trim(xuadstg_samaccountname)))
/

prompt update xuadstg_pidm
prompt where xuadstg_samaccountname begin with ('adm-','ops-','tst-')
prompt query against gobtpac
update xuadstg set
  xuadstg_pidm = (
  select gobtpac_pidm
  from gobtpac
   where lower(trim(gobtpac_external_user)) = substr(lower(trim(xuadstg_samaccountname)),5,30))
where substr(lower(xuadstg_samaccountname),1,4) in ('adm-','ops-','tst-')
  and exists (
   select 'x'
   from gobtpac
   where lower(trim(gobtpac_external_user)) = substr(lower(trim(xuadstg_samaccountname)),5,30))
/

prompt update xuadstg_pidm
prompt where xuadstg_samaccountname begin with ('adm-','ops-','tst-')
prompt query against gorpaud
update xuadstg set
  xuadstg_pidm = (
  select distinct gorpaud_pidm
  from gorpaud
  where lower(trim(gorpaud_external_user)) = lower(trim(xuadstg_samaccountname)))
where xuadstg_pidm is null
  and substr(lower(xuadstg_samaccountname),1,4) not in ('adm-','ops-','tst-')
  and exists (
   select 'x'
   from gorpaud
   where lower(trim(gorpaud_external_user)) = lower(trim(xuadstg_samaccountname)))
/

prompt assign 1 to xuadstg_pidm
prompt where xuadstg_samaccountname begin with ('iusr_','iwam_')
update xuadstg set
  xuadstg_pidm = 1
where substr(lower(xuadstg_samaccountname),1,5) in ('iusr_','iwam_')
  and xuadstg_pidm is null
/

prompt assign 1 to xuadstg_pidm
prompt where xuadstg_samaccountname begin with ('ils_','svc-','svc_')
update xuadstg set
  xuadstg_pidm = 1
where substr(lower(xuadstg_samaccountname),1,4) in ('ils_','svc-','svc_')
  and xuadstg_pidm is null
/

prompt assign 1 to xuadstg_pidm
prompt where xuadstg_samaccountname begin with $
update xuadstg set
  xuadstg_pidm = 1
where xuadstg_samaccountname like '%$%'
  and xuadstg_pidm is null
/

prompt remove .0z xuadstg_whencreated and xuadstg_whenchanged
update xuadstg set
  xuadstg_whencreated = replace(lower(xuadstg_whencreated),'.0z',null),
  xuadstg_whenchanged = replace(lower(xuadstg_whenchanged),'.0z',null)
/

prompt update all changes from xuadstg into the xuadusr table
update xuadusr set
( xuadusr_dn,
  xuadusr_whencreated,
  xuadusr_whenchanged,
  xuadusr_pidm,
  xuadusr_useraccountcontrol,
  xuadusr_accountexpires,
  xuadusr_activity_date) = (
     select distinct
       xuadstg_dn,
       to_date(xuadstg_whencreated,'YYYYMMDDHH24MISS') xuadstg_whencreated,
       to_date(xuadstg_whenchanged,'YYYYMMDDHH24MISS') xuadstg_whenchanged,
       nvl(xuadstg_pidm,'0') PIDM,
       nvl(xuadstg_useraccountcontrol,0) ACCOUNT_CONTROL,
       xuadstg_accountexpires,
       to_date(xuadstg_whenchanged,'YYYYMMDDHH24MISS') xuadstg_activity_date
      from xuadstg
      where lower(trim(xuadusr_samaccountname)) = lower(trim(xuadstg_samaccountname))
        and lower(trim(xuadusr_dn)) = lower(trim(xuadstg_dn)))
where exists(
      select 'x'
      from xuadstg
      where lower(trim(xuadusr_samaccountname)) = lower(trim(xuadstg_samaccountname))
        and lower(trim(xuadusr_dn)) = lower(trim(xuadstg_dn)))
/

prompt insert all changes from xuadstg into the xuadusr table
insert into xuadusr(
  xuadusr_dn,
  xuadusr_samaccountname,
  xuadusr_whencreated,
  xuadusr_whenchanged,
  xuadusr_pidm,
  xuadusr_useraccountcontrol,
  xuadusr_accountexpires,
  xuadusr_activity_date)
(select distinct
  xuadstg_dn,
  xuadstg_samaccountname,
  to_date(xuadstg_whencreated,'YYYYMMDDHH24MISS') xuadstg_whencreated,
  to_date(xuadstg_whenchanged,'YYYYMMDDHH24MISS') xuadstg_whenchanged,
  nvl(xuadstg_pidm,'0') PIDM,
  nvl(xuadstg_useraccountcontrol,0) ACCOUNT_CONTROL,
  xuadstg_accountexpires,
  to_date(xuadstg_whenchanged,'YYYYMMDDHH24MISS') xuadstg_activity_date
 from xuadstg
 where not exists(
   select 'x'
   from xuadusr
   where lower(trim(xuadusr_samaccountname)) = lower(trim(xuadstg_samaccountname))
     and lower(trim(xuadusr_dn)) = lower(trim(xuadstg_dn))))
/

commit
/

prompt update xuadusr table from the custom crosswalk table UPDPIDM
update xuadusr a set
  a.xuadusr_pidm = (
            select
              b.pidm
            from updpidm b
            where trim(b.samaccountname) = trim(a.xuadusr_samaccountname))
where exists(
            select 'x'
            from updpidm b
            where trim(b.samaccountname) = trim(a.xuadusr_samaccountname));

commit;

prompt remove non-user OU records from XUADUSR
delete
from xuadusr
where ( lower(trim(xuadusr_dn)) like lower('%CN=Computers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Application Servers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Application Terminal Servers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Database Servers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Domain Controllers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=File Servers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Home Page force Test%')
   or lower(trim(xuadusr_dn)) like lower('%OU=InactiveComputers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Laptop Computers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=MACS%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Member Servers (Pre Migration)%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Migration Monitoring%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Print Servers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Printers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Profile not needed%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Special Event Wireless Access%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Systems%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Systems Management Servers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Unallocated Computers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Web Servers%')
   or lower(trim(xuadusr_dn)) like lower('%OU=Windows Server 2003')
   or lower(trim(xuadusr_dn)) like lower('%OU=Xavier Computers%'));

commit;

prompt update all records from xuadstg into the xuruapp table where column xuruapp_apps_code = 'ACTD'
declare

  cursor ActiveDirAccountStatus_c
    is
    select
      xuadstg_pidm,
      substr(
      (case
         when lower(xtvuacc_desc) like '%enable%' then '01'
         when lower(xtvuacc_desc) like '%disable%' then '03'
         else null
       end),1,2) xuruapp_astat_code,
       to_date(xuadstg_whenchanged, 'YYYYMMDDHH24MISS') xuruapp_astat_timestamp,
       xuadstg_useraccountcontrol,
       xtvuacc_code
    from xuadstg
     join xtvuacc on xuadstg_useraccountcontrol = xtvuacc_code
    where exists(
      select 'x'
      from xuruapp
       join gobtpac on xuruapp_pidm = gobtpac_pidm
      where xuruapp_pidm = xuadstg_pidm
        and gobtpac_external_user is not null);

begin

  for u1 in ActiveDirAccountStatus_c loop

    update xuruapp a set
      a.xuruapp_astat_code = nvl(u1.xuruapp_astat_code, a.xuruapp_astat_code),
      a.xuruapp_astat_timestamp = nvl(u1.xuruapp_astat_timestamp, a.xuruapp_astat_timestamp),
      a.xuruapp_user_id = decode(u1.xuruapp_astat_code,null,a.xuruapp_user_id, USER)
    where a.xuruapp_pidm = u1.xuadstg_pidm
      and a.xuruapp_apps_code = 'ACTD';

  end loop;

end;
/

commit
/

-- prompt truncate table xuadstg;
-- truncate table xuadstg;

spool off;

exit
