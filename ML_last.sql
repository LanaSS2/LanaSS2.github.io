BEGIN
declare local temporary table ltb_V_C(HH_MI varchar(10),RC varchar(4),BRCA varchar(4),CrncyAmount_Buy money,MainAmount_Buy money,
                                              Amount_Buy_Rate money,Rate_Buy money,Count_Buy int,CrncyAmount_Sell money,MainAmount_Sell money,Amount_Sell_Rate money,Rate_Sell money, Count_Sell int)on commit preserve rows;

declare @DateFrom date;
declare @DateInto date;
set @DateFrom='2021-03-01'; --@DayDate_ot
set @DateInto='2021-03-01'; --@DayDate_do

------------------
insert into ltb_V_C (HH_MI, RC, BRCA, CrncyAmount_Buy,MainAmount_Buy, Amount_Buy_Rate,Rate_Buy, Count_Buy, CrncyAmount_Sell,MainAmount_Sell,Amount_Sell_Rate,Rate_Sell, Count_Sell)  -- Îבתול ט Ê-גמ

select dateformat(a.created,'HH:MM')as HH_MI,
       b.RC,
       b.BRCA,
       sum(case when a.ActionId=321 then a.CrncyAmount else 0 end) as CrncyAmount_Buy,
       sum(case when a.ActionId=321 then a.MainAmount  else 0 end) as MainAmount_Buy,
       sum(case when a.ActionId=321 then (CAST(r.MinNum as numeric(18,4))/r.MinDen )*a.CrncyAmount  else 0 end) as Amount_Buy_Rate,
       case when a.ActionId=321 then (CAST(r.MinNum as numeric(18,4))/r.MinDen) else 0 end as Rate_Buy,
       sum(case when a.ActionId=321 then 1 else 0 end) as Count_Buy,
       sum(case when a.ActionId=322 then a.CrncyAmount else 0 end) as CrncyAmount_Sell,
       sum(case when a.ActionId=322 then a.MainAmount  else 0 end) as MainAmount_Sell,
       sum(case when a.ActionId=322 then (CAST(r.MinNum as numeric(18,4))/r.MinDen )*a.CrncyAmount else 0 end) as Amount_Sell_Rate,
       case when a.ActionId=322 then (CAST(r.MinNum as numeric(18,4))/r.MinDen ) else 0 end as Rate_Sell,
       sum(case when a.ActionId=322 then 1 else 0 end) as Count_Sell

   --into #ltb_Vol_Count
from DFC.tb_sc_vBills a
join dfc.tb_sc_vToday t  on a.DayDate_fuib = t.DayDate_fuib  and t.kind = 0
left join DFC.tb_dfc_Branch b on a.BranchId=b.BranchId
left join DFC.tb_sc_vRates r on a.DayDate=r.DayDate
     and a.BranchId=r.BranchId
     and a.CurrencyTag=r.CurrencyTag
     and a.ActionId = r.ActionId
where a.ActionId in (321,322)
      and a.ProcessFlag&3=3
      and a.DayDate_fuib>=@DateFrom
      and a.DayDate_fuib<= @DateInto
      and a.CurrencyTag='USD'
      --and a.id=5765855393
group by HH_MI, RC, BRCA, r.MinDen,r.MinNum, a.ActionId; commit;

select * from  ltb_V_C;
-- end
-- 
-- select top 6 * from
-- 
-- DFC.tb_sc_vBills

---cast(' 09:00:00.00' AS time) !!!???

--  select cast(changed as date), BranchId, count(*) from DFC.tb_sc_vRates
-- where "ActionId" = 321  and "DayDate_fuib">='2021-01-01' and "DayDate_fuib"<='2021-05-01' and  CurrencyTag='USD' group by cast(changed as date), "BranchId"  having count(*)>2
-- --
--  select cast(changed as date),profileid , count(*)
--  from dbo.tb_cnb_Rates where "CurrencyTag"='USD'  and "DayDate_fuib">='2021-01-01' and "DayDate_fuib"<='2021-05-01' and profileid is not null
--  and actionid = 304 group by cast(changed as date),profileid  having count(*)>2
-- 
-- 
-- select top 5 *
-- from dbo.tb_cnb_Rates where "CurrencyTag"='USD'  and "DayDate_fuib">='2021-02-25' and "DayDate_fuib"<='2021-03-01' and profileid is not null
-- and actionid = 304 and profileid = 2314
--
-- select  top 5 * from DFC.tb_sc_vRates
--  where "ActionId" = 321  and "DayDate_fuib">='2021-02-25' and "DayDate_fuib"<='2021-03-01' and  CurrencyTag='USD' and BranchId= 1000120
-- 

select
case
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
else null end as HH_MI_range,
RC, BRCA,
case when sum(Count_Buy) =0 then  0 else sum(Rate_Buy)/sum(Count_Buy) end ,
sum(CrncyAmount_Buy),
sum(MainAmount_Buy),
sum(Count_Buy),
case when sum(Count_Sell)=0 then 0 else sum(Rate_Sell)/sum(Count_Sell) end,
sum(CrncyAmount_Sell),
sum(MainAmount_Sell),
sum(Count_Sell),
case when sum(Count_Sell)=0 then 0 else sum(Count_Buy)*1.00/sum(Count_Sell) end
from  ltb_V_C as b
group by HH_MI_range, RC, BRCA; end

