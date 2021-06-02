BEGIN

declare local temporary table ltb_V_C (Created datetime,HH_MI varchar(20),DayDate int,DayDate_fuib date,ActionId int,CurrencyTag varchar(4),CrncyAmount_Buy money,MainAmount_Buy money,
                                               Count_Buy int,CrncyAmount_Sell money,MainAmount_Sell money,
                                               Count_Sell int,RC varchar(4),BRCA varchar(4),BranchId int) on commit preserve rows;

declare local temporary table ltb_cnb_SubRates (DayDate int,DayDate_fuib date,CurrencyTag varchar(4),Rate_Buy money,Rate_Sell money,BRCA varchar(4),HH_MI varchar(20),daydate_time datetime)  on commit preserve rows;

declare local temporary table ltb_Cluster_BRCA (RC varchar(4),BRCA varchar(4),Cluster int,coun int) on commit preserve rows;

declare local temporary table ltb_V_C_range   (HH_MI_range varchar(20),Cluster int,RC varchar(4),BRCA varchar(4),
                                              Sum_CrncyAmount_Buy money,Sum_MainAmount_Buy money,Count_Buy int, Sum_CrncyAmount_Sell money,
                                              Sum_MainAmount_Sell money,Count_Sell int,Count_Buy_Div_Count_Sell money) on commit preserve rows;

declare local temporary table ltb_Rate_range (Min_Rate_Buy money, Max_Rate_Buy money, Min_Rate_Sell money, Max_Rate_Sell money, BRCA  varchar(4),HH_MI_range varchar(20),DrankBuy int,DrankSell int) on commit preserve rows;




declare @DateFrom date;
declare @DateInto date;
set @DateFrom='2020-02-01';
set @DateInto='2020-03-02';

--insert into ltb_Cluster_BRCA (RC,BRCA,Cluster,coun)
--Select RC,BRCA,Cluster, count(1) from sb_bio.tb_ML_ds_Rates group by RC,BRCA,Cluster; commit; /*0.Кластеры*/

insert into ltb_V_C (Created,HH_MI,DayDate,DayDate_fuib,ActionId,CurrencyTag,CrncyAmount_Buy,MainAmount_Buy,Count_Buy,
                     CrncyAmount_Sell,MainAmount_Sell,Count_Sell,RC,BRCA,BranchId)    /*1.объемы и кол-во операций*/

select     a.Created
,dateformat(a.created,'HH:MM') as HH_MI
           ,a.DayDate
           ,a.DayDate_fuib
           ,a.ActionId
           ,a.CurrencyTag
       ,sum(case when a.ActionId=321 then a.CrncyAmount else 0 end) as CrncyAmount_Buy
       ,sum(case when a.ActionId=321 then a.MainAmount  else 0 end) as MainAmount_Buy
       ,sum(case when a.ActionId=321 then 1 else 0 end) as Count_Buy
       ,sum(case when a.ActionId=322 then a.CrncyAmount else 0 end) as CrncyAmount_Sell
       ,sum(case when a.ActionId=322 then a.MainAmount  else 0 end) as MainAmount_Sell
       ,sum(case when a.ActionId=322 then 1 else 0 end) as Count_Sell
       ,b.RC
       ,b.BRCA
       ,b.BranchId
from DFC.tb_sc_vBills a
join DFC.tb_sc_vToday t on a.DayDate_fuib = t.DayDate_fuib  and t.kind = 0
left join DFC.tb_dfc_Branch b on a.BranchId=b.BranchId
where a.ActionId in (321,322)
      and a.ProcessFlag&3=3
      and a.DayDate_fuib>=@DateFrom
      and a.DayDate_fuib<=@DateInto
      and a.CurrencyTag='USD'
      /*and a.id=5765855393*/
group by a.Created,HH_MI,a.DayDate,a.DayDate_fuib,a.ActionId,a.CurrencyTag,b.RC,b.BRCA,b.BranchId;commit;

 --select * from  ltb_V_C;
-- end*/

insert into ltb_V_C_range (HH_MI_range,/*Cluster,*/RC,BRCA,Sum_CrncyAmount_Buy,Sum_MainAmount_Buy,Count_Buy,Sum_CrncyAmount_Sell,
                                Sum_MainAmount_Sell,Count_Sell,Count_Buy_Div_Count_Sell)
                                                                /*2.объемы и кол-во операций при дельте 15 мин 08:17 - 20:46*/

select
case
when b.HH_MI>='08:15' and b.HH_MI<'08:30' then '08:15_08:30'
when b.HH_MI>='08:30' and b.HH_MI<'08:45' then '08:30_08:45'
when b.HH_MI>='08:45' and b.HH_MI<'09:00' then '08:45_09:00'

when b.HH_MI>='09:00' and b.HH_MI<'09:15' then '09:00_09:15'
when b.HH_MI>='09:15' and b.HH_MI<'09:30' then '09:15_09:30'
when b.HH_MI>='09:30' and b.HH_MI<'09:45' then '09:30_09:45'
when b.HH_MI>='09:45' and b.HH_MI<'10:00' then '09:45_10:00'

when b.HH_MI>='10:00' and b.HH_MI<'10:15' then '10:00_10:15'
when b.HH_MI>='10:15' and b.HH_MI<'10:30' then '10:15_10:30'
when b.HH_MI>='10:30' and b.HH_MI<'10:45' then '10:30_10:45'
when b.HH_MI>='10:45' and b.HH_MI<'11:00' then '10:45_11:00'

when b.HH_MI>='11:00' and b.HH_MI<'11:15' then '11:00_11:15'
when b.HH_MI>='11:15' and b.HH_MI<'11:30' then '11:15_11:30'
when b.HH_MI>='11:30' and b.HH_MI<'11:45' then '11:30_11:45'
when b.HH_MI>='11:45' and b.HH_MI<'12:00' then '11:45_12:00'

when b.HH_MI>='12:00' and b.HH_MI<'12:15' then '12:00_12:15'
when b.HH_MI>='12:15' and b.HH_MI<'12:30' then '12:15_12:30'
when b.HH_MI>='12:30' and b.HH_MI<'12:45' then '12:30_12:45'
when b.HH_MI>='12:45' and b.HH_MI<'13:00' then '12:45_13:00'

when b.HH_MI>='13:00' and b.HH_MI<'13:15' then '13:00_13:15'
when b.HH_MI>='13:15' and b.HH_MI<'13:30' then '13:15_13:30'
when b.HH_MI>='13:30' and b.HH_MI<'13:45' then '13:30_13:45'
when b.HH_MI>='13:45' and b.HH_MI<'14:00' then '13:45_14:00'

when b.HH_MI>='14:00' and b.HH_MI<'14:15' then '14:00_14:15'
when b.HH_MI>='14:15' and b.HH_MI<'14:30' then '14:15_14:30'
when b.HH_MI>='14:30' and b.HH_MI<'14:45' then '14:30_14:45'
when b.HH_MI>='14:45' and b.HH_MI<'15:00' then '14:45_15:00'

when b.HH_MI>='15:00' and b.HH_MI<'15:15' then '15:00_15:15'
when b.HH_MI>='15:15' and b.HH_MI<'15:30' then '15:15_15:30'
when b.HH_MI>='15:30' and b.HH_MI<'15:45' then '15:30_15:45'
when b.HH_MI>='15:45' and b.HH_MI<'16:00' then '15:45_16:00'

when b.HH_MI>='16:00' and b.HH_MI<'16:15' then '16:00_16:15'
when b.HH_MI>='16:15' and b.HH_MI<'16:30' then '16:15_16:30'
when b.HH_MI>='16:30' and b.HH_MI<'16:45' then '16:30_16:45'
when b.HH_MI>='16:45' and b.HH_MI<'17:00' then '16:45_17:00'

when b.HH_MI>='17:00' and b.HH_MI<'17:15' then '17:00_17:15'
when b.HH_MI>='17:15' and b.HH_MI<'17:30' then '17:15_17:30'
when b.HH_MI>='17:30' and b.HH_MI<'17:45' then '17:30_17:45'
when b.HH_MI>='17:45' and b.HH_MI<'18:00' then '17:45_18:00'

when b.HH_MI>='18:00' and b.HH_MI<'18:15' then '18:00_18:15'
when b.HH_MI>='18:15' and b.HH_MI<'18:30' then '18:15_18:30'
when b.HH_MI>='18:30' and b.HH_MI<'18:45' then '18:30_18:45'
when b.HH_MI>='18:45' and b.HH_MI<'19:00' then '18:45_19:00'

when b.HH_MI>='18:00' and b.HH_MI<'18:15' then '18:00_18:15'
when b.HH_MI>='18:15' and b.HH_MI<'18:30' then '18:15_18:30'
when b.HH_MI>='18:30' and b.HH_MI<'18:45' then '18:30_18:45'
when b.HH_MI>='18:45' and b.HH_MI<'19:00' then '18:45_19:00'

when b.HH_MI>='19:00' and b.HH_MI<'19:15' then '19:00_19:15'
when b.HH_MI>='19:15' and b.HH_MI<'19:30' then '19:15_19:30'
when b.HH_MI>='19:30' and b.HH_MI<'19:45' then '19:30_19:45'
when b.HH_MI>='19:45' and b.HH_MI<'20:00' then '19:45_20:00'

when b.HH_MI>='20:00' and b.HH_MI<'20:15' then '20:00_20:15'
when b.HH_MI>='20:15' and b.HH_MI<'20:30' then '20:15_20:30'
when b.HH_MI>='20:30' and b.HH_MI<'20:45' then '20:30_20:45'
when b.HH_MI>='20:45' and b.HH_MI<'21:00' then '20:45_21:00'

else  '21:00_08:14:59' end as HH_MI_range,
-- mlr.Cluster,
 b.RC, b.BRCA,
 --case when sum(b.Count_Buy)=0 then 0 else sum(b.Rate_Buy)/sum(b.Count_Buy) end as Avarage_Rate_Buy,
 sum(b.CrncyAmount_Buy)                                                        as Sum_CrncyAmount_Buy,
 sum(b.MainAmount_Buy)                                                         as Sum_MainAmount_Buy,
 sum(b.Count_Buy)                                                              as Count_Buy,
 --case when sum(b.Count_Sell)=0 then 0 else sum(b.Rate_Sell)/sum(b.Count_Sell) end as Avarage_Rate_Sell,
 sum(b.CrncyAmount_Sell)                                                          as Sum_CrncyAmount_Sell,
 sum(b.MainAmount_Sell)                                                           as Sum_MainAmount_Sell,
 sum(b.Count_Sell)                                                                as Count_Sell,
 case when sum(b.Count_Sell)=0 then 0 else sum(b.Count_Buy)*1.00/sum(b.Count_Sell) end as Count_Buy_Div_Count_Sell
from ltb_V_C as b
--left join ltb_Cluster_BRCA as mlr on b.RC = mlr.RC and b.BRCA = mlr.BRCA
group by HH_MI_range,/*mlr.Cluster,*/b.RC,b.BRCA; commit;

--Select * from ltb_V_C_range;


insert into ltb_cnb_SubRates (DayDate,DayDate_fuib,CurrencyTag,Rate_Buy,Rate_Sell,BRCA,HH_MI,daydate_time) /*3.истории курсов*/
select
 r.DayDate
,r.DayDate_fuib
,r.CurrencyTag
,case when r.ActionId=303 then CAST(sr.IniNum as numeric(18,4))/sr.IniDen else null end as Rate_Buy
,case when r.ActionId=304 then CAST(sr.IniNum as numeric(18,4))/sr.IniDen else null end as Rate_Sell
--,case when r.ActionId = 303 then 321  when r.ActionId = 304 then 322 end as Action
--,CAST(r.IniNum as numeric(18,4))/r.IniDen as Rate
,p.Code as BRCA
,cast(dateformat(sr.Time_fuib,'HH:MM') as varchar(20)) as HH_MI
,r.daydate_fuib + sr.Time_fuib as daydate_time
from  DFC.tb_cnb_Rates r
join  DFC.tb_cnb_SubRates  sr on r.Id=sr.rateid
join  DFC.tb_cnb_profiles p on r.profileid=p.id
where r.ActionId in (303,304) and r.daydate_fuib>=@DateFrom and r.daydate_fuib<=@DateInto and r.CurrencyTag='USD' /*and cast(dateformat(sr.Time_fuib,'HH:MM') as varchar(20))<>'00:00' ?*/
order by r.daydate_fuib;commit;

--select * from  ltb_cnb_SubRates;

insert into ltb_Rate_range (Min_Rate_Buy,Max_Rate_Buy,Min_Rate_Sell,Max_Rate_Sell,BRCA,HH_MI_range,DrankBuy,DrankSell) /*4.изменения курсов при дельте 15 мин*/
select
  Min(tsr.Rate_Buy)  as Min_Rate_Buy
, Max(tsr.Rate_Buy)  as Max_Rate_Buy
, Min(tsr.Rate_Sell) as Min_Rate_Sell
, Max(tsr.Rate_Sell) as Max_Rate_Sell
,tsr.BRCA
,case
-- when tsr.HH_MI>='08:15' and tsr.HH_MI<'08:30' then '08:15_08:30'
-- when tsr.HH_MI>='08:30' and tsr.HH_MI<'08:45' then '08:30_08:45'
-- when tsr.HH_MI>='08:45' and tsr.HH_MI<'09:00' then '08:45_09:00'
--
when tsr.HH_MI>='09:00' and tsr.HH_MI<'09:15' then '09:00_09:15'
when tsr.HH_MI>='09:15' and tsr.HH_MI<'09:30' then '09:15_09:30'
when tsr.HH_MI>='09:30' and tsr.HH_MI<'09:45' then '09:30_09:45'
when tsr.HH_MI>='09:45' and tsr.HH_MI<'10:00' then '09:45_10:00'

when tsr.HH_MI>='10:00' and tsr.HH_MI<'10:15' then '10:00_10:15'
when tsr.HH_MI>='10:15' and tsr.HH_MI<'10:30' then '10:15_10:30'
when tsr.HH_MI>='10:30' and tsr.HH_MI<'10:45' then '10:30_10:45'
when tsr.HH_MI>='10:45' and tsr.HH_MI<'11:00' then '10:45_11:00'

when tsr.HH_MI>='11:00' and tsr.HH_MI<'11:15' then '11:00_11:15'
when tsr.HH_MI>='11:15' and tsr.HH_MI<'11:30' then '11:15_11:30'
when tsr.HH_MI>='11:30' and tsr.HH_MI<'11:45' then '11:30_11:45'
when tsr.HH_MI>='11:45' and tsr.HH_MI<'12:00' then '11:45_12:00'

when tsr.HH_MI>='12:00' and tsr.HH_MI<'12:15' then '12:00_12:15'
when tsr.HH_MI>='12:15' and tsr.HH_MI<'12:30' then '12:15_12:30'
when tsr.HH_MI>='12:30' and tsr.HH_MI<'12:45' then '12:30_12:45'
when tsr.HH_MI>='12:45' and tsr.HH_MI<'13:00' then '12:45_13:00'

when tsr.HH_MI>='13:00' and tsr.HH_MI<'13:15' then '13:00_13:15'
when tsr.HH_MI>='13:15' and tsr.HH_MI<'13:30' then '13:15_13:30'
when tsr.HH_MI>='13:30' and tsr.HH_MI<'13:45' then '13:30_13:45'
when tsr.HH_MI>='13:45' and tsr.HH_MI<'14:00' then '13:45_14:00'

when tsr.HH_MI>='14:00' and tsr.HH_MI<'14:15' then '14:00_14:15'
when tsr.HH_MI>='14:15' and tsr.HH_MI<'14:30' then '14:15_14:30'
when tsr.HH_MI>='14:30' and tsr.HH_MI<'14:45' then '14:30_14:45'
when tsr.HH_MI>='14:45' and tsr.HH_MI<'15:00' then '14:45_15:00'

when tsr.HH_MI>='15:00' and tsr.HH_MI<'15:15' then '15:00_15:15'
when tsr.HH_MI>='15:15' and tsr.HH_MI<'15:30' then '15:15_15:30'
when tsr.HH_MI>='15:30' and tsr.HH_MI<'15:45' then '15:30_15:45'
when tsr.HH_MI>='15:45' and tsr.HH_MI<'16:00' then '15:45_16:00'

-- when tsr.HH_MI>='16:00' and tsr.HH_MI<'16:15' then '16:00_16:15'
-- when tsr.HH_MI>='16:15' and tsr.HH_MI<'16:30' then '16:15_16:30'
-- when tsr.HH_MI>='16:30' and tsr.HH_MI<'16:45' then '16:30_16:45'
-- when tsr.HH_MI>='16:45' and tsr.HH_MI<'17:00' then '16:45_17:00'
-- 
-- when tsr.HH_MI>='17:00' and tsr.HH_MI<'17:15' then '17:00_17:15'
-- when tsr.HH_MI>='17:15' and tsr.HH_MI<'17:30' then '17:15_17:30'
-- when tsr.HH_MI>='17:30' and tsr.HH_MI<'17:45' then '17:30_17:45'
-- when tsr.HH_MI>='17:45' and tsr.HH_MI<'18:00' then '17:45_18:00'
-- 
-- when tsr.HH_MI>='18:00' and tsr.HH_MI<'18:15' then '18:00_18:15'
-- when tsr.HH_MI>='18:15' and tsr.HH_MI<'18:30' then '18:15_18:30'
-- when tsr.HH_MI>='18:30' and tsr.HH_MI<'18:45' then '18:30_18:45'
-- when tsr.HH_MI>='18:45' and tsr.HH_MI<'19:00' then '18:45_19:00'
--
-- when tsr.HH_MI>='18:00' and tsr.HH_MI<'18:15' then '18:00_18:15'
-- when tsr.HH_MI>='18:15' and tsr.HH_MI<'18:30' then '18:15_18:30'
-- when tsr.HH_MI>='18:30' and tsr.HH_MI<'18:45' then '18:30_18:45'
-- when tsr.HH_MI>='18:45' and tsr.HH_MI<'19:00' then '18:45_19:00'
-- 
-- when tsr.HH_MI>='19:00' and tsr.HH_MI<'19:15' then '19:00_19:15'
-- when tsr.HH_MI>='19:15' and tsr.HH_MI<'19:30' then '19:15_19:30'
-- when tsr.HH_MI>='19:30' and tsr.HH_MI<'19:45' then '19:30_19:45'
-- when tsr.HH_MI>='19:45' and tsr.HH_MI<'20:00' then '19:45_20:00'
-- 
-- when tsr.HH_MI>='20:00' and tsr.HH_MI<'20:15' then '20:00_20:15'
-- when tsr.HH_MI>='20:15' and tsr.HH_MI<'20:30' then '20:15_20:30'
-- when tsr.HH_MI>='20:30' and tsr.HH_MI<'20:45' then '20:30_20:45'
-- when tsr.HH_MI>='20:45' and tsr.HH_MI<'21:00' then '20:45_21:00'
else  '16:00_08:59:59' end as HH_MI_range,
DENSE_RANK() over(order by Max_Rate_Buy),
DENSE_RANK() over(order by Max_Rate_Sell)
--mlr.Cluster,
from ltb_cnb_SubRates as tsr
where tsr.daydate_fuib>=@DateFrom and tsr.daydate_fuib<=@DateInto
--left join ltb_Cluster_BRCA as mlr on tsr.BRCA = mlr.BRCA
group by  tsr.BRCA, HH_MI_range;commit;

select * from ltb_Rate_range;


select * from ltb_Rate_range left join  from ltb_Rate_range where 

-- create index HH_MI_range
-- create index BRCA
--+Clusters
-- create HG index IXltb_V_C_range_HH_MI_range  on ltb_V_C_range(HH_MI_range);
-- create HG index IXltb_Rate_range_HH_MI_range on ltb_Rate_range(HH_MI_range);
-- create HG index IXltb_V_C_range_BRCA         on ltb_V_C_range(BRCA);
-- create HG index IXltb_Rate_range_BRCA        on ltb_Rate_range(BRCA);

-- Select lr.HH_MI_range,vcr.RC,vcr.BRCA,vcr.Sum_CrncyAmount_Buy,vcr.Sum_MainAmount_Buy,vcr.Count_Buy,lr.Min_Rate_Buy,lr.Max_Rate_Buy,vcr.Sum_CrncyAmount_Sell,
--        vcr.Sum_MainAmount_Sell,vcr.Count_Sell,vcr.Count_Buy_Div_Count_Sell, lr.Min_Rate_Sell, lr.Max_Rate_Sell
-- 
-- from ltb_V_C_range vcr
-- join ltb_Rate_range lr on vcr.HH_MI_range = lr.HH_MI_range and vcr.BRCA = lr.BRCA
-- order by lr.HH_MI_range, vcr.RC,vcr.BRCA;

end

