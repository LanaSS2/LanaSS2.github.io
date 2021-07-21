call sb_bio.up_sp_ddl('up_ML_ds_Rates_Range','alter','(in @DateFrom date, @DateInto date)
BEGIN
declare local temporary table ltb_V_C (BillId bigint, Created datetime,HH_MI time,DayDate int,DayDate_fuib date,ActionId int,CurrencyTag varchar(4),
                                               Count_Buy int,Count_Sell int,RC varchar(4),BRCA varchar(4)) on commit preserve rows;
declare local temporary table ltb_V_C_range   (DayDate int,DayDate_fuib date,min_HH_MI time,max_HH_MI time,HH_MI_range varchar(20),HH_MI_start time,HH_MI_end time,
                                               RC varchar(4),BRCA varchar(4),Sum_CrncyAmount_Buy money,Sum_MainAmount_Buy money,Count_Buy int,Sum_CrncyAmount_Sell money,
                                               Sum_MainAmount_Sell money,Count_Sell int) on commit preserve rows;
declare local temporary table ltb_SubRates (DayDate int,DayDate_fuib date,Rate_Buy money,Rate_Sell money,BRCA varchar(4),HH_MI time,daydate_time datetime) on commit preserve rows;
declare local temporary table ltb_cnb_SubRates (DayDate int,DayDate_fuib date,Rate_Buy money,Rate_Sell money,ex_Rate_Buy money,ex_Rate_Sell money,BRCA varchar(4),
                                                HH_MI time,till_HH_MI time,daydate_time datetime,rn int) on commit preserve rows;
declare local temporary table ltb_SubRates_main (DayDate int,DayDate_fuib date,avg_Rate_Buy money,avg_Rate_Sell money,BRCA varchar(4),HH_MI_change time,HH_MI_start time,
                                                HH_MI_end time,HH_MI_range varchar(20),Rate_Buy_out_start money,Rate_Buy_out money,Rate_Sell_out_start money,Rate_Sell_out money,Rate_Buy_input money,Rate_Sell_input money)
                                                on commit preserve rows;
declare local temporary table ltb_Cluster_BRCA (RC varchar(4),BRCA varchar(4),Cluster int,coun int) on commit preserve rows;
declare local temporary table ltb_RC_BRCA (RC varchar(4),BRCA varchar(4),code varchar(4),coun int) on commit preserve rows;
/*declare @DateFrom date;
declare @DateInto date;
set @DateFrom=''2021-03-01'';
set @DateInto=''2021-03-31'';*/

insert into ltb_Cluster_BRCA (RC,BRCA,Cluster,coun)
Select RC,BRCA,Cluster,count(1) as coun from sb_bio.tb_ML_ds_Rates group by RC,BRCA,Cluster; commit; /*0. кластеры*/

insert into ltb_RC_BRCA (RC,BRCA,code,coun)
select b.RC,b.BRCA,b.code,count(1) as coun from DFC.tb_dfc_Branch b where b.TYP in (''Отделение'',''РЦ'') group by b.RC,b.BRCA,b.code ;commit;/*0. подразделения и рц*/

insert into ltb_V_C (BillId,Created,HH_MI,DayDate,DayDate_fuib,ActionId,CurrencyTag,Count_Buy,Count_Sell,RC,BRCA) /*1.кол-во операций*/
select      a.Id
           ,a.Created
,dateformat(a.created,''HH:MM'') as HH_MI
           ,a.DayDate
           ,a.DayDate_fuib
           ,a.ActionId
           ,a.CurrencyTag
,case when a.ActionId=321 then 1 else 0 end as Count_Buy
,case when a.ActionId=322 then 1 else 0 end as Count_Sell
           ,b.RC
           ,b.code as BRCA
   from DFC.tb_sc_vBills a
  join DFC.tb_dfc_Branch b on a.BranchId=b.BranchId and b.TYP in (''Отделение'',''РЦ'')
where a.ActionId in (321,322)
      and a.ProcessFlag&3=3
      and a.DayDate_fuib>=@DateFrom
      and a.DayDate_fuib<=@DateInto
      and a.CurrencyTag=''USD'';commit;
/*select 1, * from ltb_V_C;*/
insert into ltb_V_C_range (DayDate,DayDate_fuib,min_HH_MI,max_HH_MI,HH_MI_range,HH_MI_start,HH_MI_end,RC,BRCA,Sum_CrncyAmount_Buy,
                           Sum_MainAmount_Buy,Count_Buy,Sum_CrncyAmount_Sell,Sum_MainAmount_Sell,Count_Sell)
                                                                /*2.объемы и кол-во операций при дельте 15 мин*/
select
 b.DayDate
,b.DayDate_fuib
,min(b.HH_MI) as  min_HH_MI
,max(b.HH_MI) as  max_HH_MI
,ra.HH_MI_range
,ra.HH_MI_start
,ra.HH_MI_end
,b.RC
,b.BRCA
,sum(case when b.ActionId = 321 and t.CurrencyTag=''USD'' then t.CrncyAmount else 0 end) as Sum_CrncyAmount_Buy
,sum(case when b.ActionId = 321 and t.CurrencyTag='''' then t.MainAmount else 0 end) as Sum_MainAmount_Buy
,sum(case when t.CurrencyTag=''USD'' then b.Count_Buy else 0 end) as Count_Buy
,sum(case when b.ActionId = 322 and t.CurrencyTag=''USD'' then t.CrncyAmount else 0 end) as Sum_CrncyAmount_Sell
,sum(case when b.ActionId = 322 and t.CurrencyTag='''' then t.MainAmount else 0 end) as Sum_MainAmount_Sell
,sum(case when t.CurrencyTag=''USD'' then b.Count_Sell else 0 end) as Count_Sell
/*,case when sum(b.Count_Sell)=0 then 0 else sum(b.Count_Buy)*1.00/sum(b.Count_Sell) end as Count_Buy_Div_Count_Sell*/
from ltb_V_C as b
left join DFC.tb_sc_vTransfers t on t.BillId=b.BillId and t.kind<>0
left join sb_bio.tb_ML_ds_Range ra on b.HH_MI>=ra.HH_MI_start and b.HH_MI<ra.HH_MI_end
group by b.RC,b.BRCA,b.DayDate,b.DayDate_fuib,ra.HH_MI_range,ra.HH_MI_start,ra.HH_MI_end order by b.BRCA,b.DayDate,ra.HH_MI_range;commit;
/*select 2, * from ltb_V_C_range; end*/
insert into ltb_SubRates (DayDate,DayDate_fuib,Rate_Buy,Rate_Sell,BRCA,HH_MI,daydate_time) /*3.истории курсов*/
select
 r.DayDate
,r.DayDate_fuib
,case when r.ActionId=303 then CAST(sr.IniNum as numeric(18,4))/sr.IniDen else null end as Rate_Buy
,case when r.ActionId=304 then CAST(sr.IniNum as numeric(18,4))/sr.IniDen else null end as Rate_Sell
,p.Code as BRCA
,dateformat(sr.Time_fuib,''HH:MM'') as HH_MI
,r.daydate_fuib + sr.Time_fuib as daydate_time
from  DFC.tb_cnb_Rates r
join  DFC.tb_cnb_SubRates  sr on r.Id=sr.rateid
join  DFC.tb_cnb_profiles p on r.profileid=p.id
join  DFC.tb_dfc_Branch br on p.Code=br.Code and br.TYP in (''Отделение'',''РЦ'')
where r.ActionId in (303,304) and r.daydate_fuib>=@DateFrom and r.daydate_fuib<=@DateInto and r.CurrencyTag=''USD''
order by p.Code,r.DayDate,HH_MI ;commit;

insert into ltb_cnb_SubRates (DayDate,DayDate_fuib,Rate_Buy,Rate_Sell,BRCA,HH_MI,daydate_time,rn)
select
 DayDate
,DayDate_fuib
,sum(Rate_Buy)
,sum(Rate_Sell)
,BRCA
,HH_MI
,daydate_time
,ROW_NUMBER() OVER(PARTITION BY BRCA ORDER BY daydate_time) as rn
from ltb_SubRates
group by
 DayDate
,DayDate_fuib
,BRCA
,HH_MI
,daydate_time
order by BRCA, daydate_time; commit;

update ltb_cnb_SubRates c
set   c.ex_Rate_Buy = (case when d.rn = c.rn-1 then d.Rate_Buy else null end ),
      c.ex_Rate_Sell = (case when d.rn = c.rn-1 then d.Rate_Sell else null end),
      c.till_HH_MI = (case when f.rn = c.rn+1 and f.HH_MI<>''00:00:00'' and f.HH_MI is not null then f.HH_MI else ''23:59:59'' end )
from ltb_cnb_SubRates c
left join ltb_cnb_SubRates d on c.BRCA = d.BRCA and d.rn = c.rn-1
left join ltb_cnb_SubRates f on c.BRCA = f.BRCA and f.rn = c.rn+1; commit;

create HG index IXltb_cnb_SubRates_till_HH_MI on ltb_cnb_SubRates(till_HH_MI);
create HG index IXltb_cnb_SubRates_HH_MI  on ltb_cnb_SubRates(HH_MI);

insert into ltb_SubRates_main (DayDate,DayDate_fuib,avg_Rate_Buy,avg_Rate_Sell,BRCA,HH_MI_change,HH_MI_start,HH_MI_end,HH_MI_range)
select su.DayDate,su.DayDate_fuib,avg(su.Rate_Buy) as avg_Rate_Buy ,avg(su.Rate_Sell) as avg_Rate_Sell,su.BRCA,max(su.HH_MI) as HH_MI_change,
       ra.HH_MI_start,ra.HH_MI_end,ra.HH_MI_range
from ltb_cnb_SubRates su
 left join sb_bio.tb_ML_ds_Range ra on
(ra.HH_MI_start < su.till_HH_MI and ra.HH_MI_start >=su.HH_MI) or (ra.HH_MI_end < su.till_HH_MI and ra.HH_MI_end >=su.HH_MI)
group by su.DayDate,su.DayDate_fuib,su.BRCA,ra.HH_MI_start,ra.HH_MI_end,ra.HH_MI_range
order by su.BRCA,su.DayDate,ra.HH_MI_range; commit;

update ltb_SubRates_main sm
set sm.Rate_Buy_out = su.Rate_Buy,
sm.Rate_Buy_out_start = (case when sm.HH_MI_change>=sm.HH_MI_start and sm.HH_MI_change<=sm.HH_MI_end then su.ex_Rate_Buy else su.Rate_Buy end),
sm.Rate_Sell_out = su.Rate_Sell,
sm.Rate_Sell_out_start = (case when sm.HH_MI_change>=sm.HH_MI_start and sm.HH_MI_change<=sm.HH_MI_end then su.ex_Rate_Sell else su.Rate_Sell end),
sm.Rate_Buy_input = su.ex_Rate_Buy,
sm.Rate_Sell_input =su.ex_Rate_Sell
from ltb_SubRates_main as sm
left join ltb_cnb_SubRates su on sm.DayDate=su.DayDate and sm.BRCA=su.BRCA and sm.HH_MI_change=su.HH_MI
order by sm.BRCA,sm.DayDate,sm.HH_MI_range; commit;

/*select * from ltb_SubRates_main; end*/

create HG index IXltb_V_C_range_HH_MI_range  on ltb_V_C_range(HH_MI_range);
create HG index IXltb_SubRates_main_HH_MI_range on ltb_SubRates_main(HH_MI_range);
create HG index IXltb_V_C_range_BRCA         on ltb_V_C_range(BRCA);
create HG index IXltb_SubRates_main_BRCA     on ltb_SubRates_main(BRCA);

delete
from  sb_bio.tb_ML_ds_Rates_Range a
where a.DayDate_fuib>=@DateFrom and DayDate_fuib<=@DateInto; commit;

insert into sb_bio.tb_ML_ds_Rates_Range (BRCA,DayDate_fuib,HH_MI_range,HH_MI_start,
HH_MI_end,Sum_CrncyAmount_Buy,Sum_MainAmount_Buy,Count_Buy,Sum_CrncyAmount_Sell,Sum_MainAmount_Sell,Count_Sell,avg_Rate_Buy,avg_Rate_Sell,HH_MI_change,
 Rate_Buy_input,Rate_Sell_input,Rate_Buy_out_start,Rate_Buy_out,Rate_Sell_out_start,Rate_Sell_out)

select sbr.BRCA,sbr.DayDate_fuib,sbr.HH_MI_range,sbr.HH_MI_start,sbr.HH_MI_end,vc.Sum_CrncyAmount_Buy,
        vc.Sum_MainAmount_Buy,vc.Count_Buy,vc.Sum_CrncyAmount_Sell,vc.Sum_MainAmount_Sell,vc.Count_Sell
              ,sbr.avg_Rate_Buy,sbr.avg_Rate_Sell,sbr.HH_MI_change,sbr.Rate_Buy_input,sbr.Rate_Sell_input,sbr.Rate_Buy_out_start,sbr.Rate_Buy_out,sbr.Rate_Sell_out_start,sbr.Rate_Sell_out
from ltb_SubRates_main sbr
left outer join ltb_V_C_range vc on vc.DayDate=sbr.DayDate and vc.BRCA=sbr.BRCA and vc.HH_MI_range=sbr.HH_MI_range
order by sbr.BRCA,sbr.DayDate_fuib,sbr.HH_MI_range;commit;

update sb_bio.tb_ML_ds_Rates_Range r
set r.RC=rb.RC,
r.BRCA=rb.BRCA
from sb_bio.tb_ML_ds_Rates_Range r
join ltb_RC_BRCA rb on r.BRCA=rb.code ;commit;

update sb_bio.tb_ML_ds_Rates_Range r
set r.Cluster = cl.Cluster
from sb_bio.tb_ML_ds_Rates_Range r
left join ltb_Cluster_BRCA cl on r.BRCA=cl.BRCA ;commit;

/*Select * from  sb_bio.tb_ML_ds_Rates_Range order by BRCA,DayDate_fuib,HH_MI_range ;*/
END
');


