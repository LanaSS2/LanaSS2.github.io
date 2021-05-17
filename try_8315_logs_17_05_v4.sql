begin
declare @date_beg date;
declare @date_end date;
declare @set_group int;
set @date_beg='2020-01-01';
set @date_end= '2020-03-10';

/* Issues log */
select
i.Id,
i.created,
i.resolutiondate,
ci.newstring,
ob.label,
cast(null as varchar(250)) as assignee,
cast(null as varchar(250)) as status
into #issues_log
from
DFC.tb_jira_jiraissue i
join DFC.tb_jira_changegroup g on i.Id=g.issueid
join DFC.tb_jira_changeitem ci on ci.groupid=g.id and ci.newstring='[GG-U-jirasd-OPPS]' and ci.field='Group Executors'
--and ci.field='assignee'
--ci.newvalue='10205' (--and ci.newstring='2L: Resolved')
join   dbo.tb_jira_AO_8542F1_IFJ_OBJ_JIRAISSUE j on j.jira_issue_id=i.Id
join   dbo.tb_jira_AO_8542F1_IFJ_OBJ ob on ob.id=j.object_id and ob.label in ('Автокасса', 'VEGA', 'Sirius ЭЦП', 'Foss DocMail', 'SWIFT', 'Sirius\Webbank', 'Liga', 'VegaNet')
--newstring='2L: Resolved' or  newvalue=10205
where cast(i.resolutiondate as date)>=@date_beg and cast(i.resolutiondate as date)<=@date_end; commit;
select distinct il.* into #issues_log_unic from #issues_log as il; commit;

select * from #issues_log_unic;

select
il.Id,
ci.fieldtype,
ci.oldvalue,
ci.oldstring ,
ci.newvalue,
ci.newstring
into #issues_log_status
from
#issues_log_unic il
join DFC.tb_jira_changegroup g on il.Id=g.issueid
join DFC.tb_jira_changeitem ci on ci.groupid=g.id  and ci.field='status'
and ci.newvalue='10205'

; commit;
--
-- 
-- fieldtype       field   oldvalue        oldstring       newvalue        newstring
-- jira            status  10202           2L: In Progress 10205          2L: Resolved
-- jira            status  10202           2L: In Progress 10205          2L: Resolved
-- 
select * from #issues_log_status;
end


select
il.Id,
ci.fieldtype,
ci.oldvalue,
ci.oldstring ,
ci.newvalue,
ci.newstring
into #issues_log_assignee
from
#issues_log_unic il
join DFC.tb_jira_changegroup g on il.Id=g.issueid
join DFC.tb_jira_changeitem ci on ci.groupid=g.id  and ci.field='assignee'; commit;

select * from #issues_log_assignee;
end


fieldtype       field   oldvalue        oldstring       newvalue              newstring
jira    assignee                        kapichni        Капічніков Сергій Леонідович
jira    assignee                        kapichni        Капічніков Сергій Леонідович




    ---j.custom_field_id=11101  ----???
    --  and p.pkey not in ('ATMINC','ERP','JSDCHM','SEC','TEMP')  ----????
      --  and
       i.Id =686175
       -- 654204
      --686175
     --685798

        --in (313741, 13227, 148852) */
       --  and ci.newstring like '%GG-U-jirasd-OPPS%'
         --ci.oldstring  like '%2L: Resolved%' --???
         end
--environment
--2-я линия
--where i.project=10102--10902
--issuetype=10000--1001
 652394
     653052
     654204
     --create dttm index indx_datetime_issues_log on #issues_log(datetime);
--create HG index indx_issueid_issues_log on #issues_log(issueid);

update #issues_log_unic as i
       set i.assignee = ob.label
from   #timing a
join   dbo.tb_jira_AO_8542F1_IFJ_OBJ_JIRAISSUE j on j.jira_issue_id=a.issueid
join   dbo.tb_jira_AO_8542F1_IFJ_OBJ ob on ob.id=j.object_id and ob.label in ('Автокасса', 'VEGA', 'Sirius ЭЦП', 'Foss DocMail', 'SWIFT', 'Sirius\Webbank', 'Liga', 'VegaNet')
where  j.custom_field_id=11101  ----???


join DFC.tb_jira_changeitem ci
fieldtype       field   oldvalue        oldstring       newvalue        newstring
jira    assignee                        kapichni        Капічніков Сергій Леонідович
jira    assignee                        kapichni        Капічніков Сергій Леонідович



DFC.tb_jira_changeitem:
6093830
-- fieldtype       field   oldvalue        oldstring       newvalue        newstring  --???
-- jira    status  10205   2L: Resolved    6       Closed
-- jira    status  10205   2L: Resolved    6       Closed

fieldtype       field   oldvalue        oldstring       newvalue        newstring
jira            status  10202           2L: In Progress 10205          2L: Resolved
jira            status  10202           2L: In Progress 10205          2L: Resolved

fieldtype       field   oldvalue        oldstring       newvalue        newstring
jira    assignee                        kapichni        Капічніков Сергій Леонідович
jira    assignee                        kapichni        Капічніков Сергій Леонідович

fieldtype       field   oldvalue        oldstring       newvalue        newstring
custom  Group Executors         [GG-U-jirasd-helpdesk]          [GG-U-jirasd-OPPS]
custom  Group Executors         [GG-U-jirasd-helpdesk]          [GG-U-jirasd-OPPS]

fieldtype       field   oldvalue        oldstring       newvalue        newstring
custom  Group Executors         [GG-U-jirasd-helpdesk]          [GG-U-jirasd-OPPS]

field   oldvalue        oldstring       newvalue        newstring
status  10202   2L: In Progress 10205   2L: Resolved

fieldtype       field   oldvalue        oldstring       newvalue        newstring
jira    assignee                        bryukhai        Брюханов Ігор Генадійович


SELECT top 600 ID,
     SEQUENCE,
     pname,
     pstyle,
     DESCRIPTION,
     ICONURL,
     AVATAR,
     daydate_update
FROM dbo.tb_jiraIT_issuetype

