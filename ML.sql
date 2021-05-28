
--сли нужны просто операции по кассе, можно из билсов выбрать по счетам кассы
select USER_NAME(creator) as cr,
       proc_name
   , isnull(source,proc_defn) as source
FROM sys.sysprocedure
where USER_NAME(creator)='sb_bio'

select top 10 *
from sb_bio.tb_ML_ds_Rates

exec sp_helptext 'tb_ML_ds_Rates'


select *
from sb_bio.tb_ML_ds_Rates
where brca='U23'

/*select  b.RC,
        b.BRCA,
        b.Code,
        g.FullAdress,
        g.City,
        g.Longitude,
        g.Latitude
from DFC.tb_dfc_geodata g
join DFC.tb_dfc_Branch b on b.BranchId=g.PointId
where b.typ in ('Отделение','РЦ') and b.RC not in ('SEL','DON')*/


select top 10 *
from dbo.tb_cnb_mtTransactions

select top 10 *
from dbo.tb_cnb_Rates

select top 10 *
from  dbo. tb_cnb_Accounts

select top 10 *
from dbo.tb_cnb_Users

select top 10 *
from  dbo.tb_cnb_ConnotationList

select top 10 *
from dbo.tb_cnb_cnbDocumentCodes

select top 10 *
from dbo.tb_cnb_BillGroups

select top 10 *
from dbo.tb_cnb_mtClientDocuments

select top 10 *
from dbo.tb_cnb_Operations

select   *
FROM DFC.tb_cnb_CashBills c join  dbo.tb_cnb_mtTransactions t on c.id=t.scroogebillid

 where t.scroogebillid=1820845355

 c.transid=68432

cast(Created as date)='2021-05-26' and
68432
select top 100 *
from dbo.tb_cnb_Rates where "CurrencyTag"='USD' and cast( daydate_fuib as date)='2021-05-26'
------------------------
select * from dbo.tb_sc_vTopics where id/100 = 10
---------------------
506358
select  top 10 *
from dbo.tb_cnb_mtTransactions
select   top 10 *
FROM DFC.tb_cnb_CashBills

select top 100 *
from dbo.tb_cnb_Rates where "CurrencyTag"='USD' and cast( daydate_fuib as date)>='2021-05-20' and cast( daydate_fuib as date)<='2021-05-26'
and actionid = 304 /* and "Changed"='2021-05-26 16:32:17.000000' */ and ProfileId=2412 order by  Created
-- actionid,count(*)
-- 303 =321
-- 304 =322
      = 9022
      = 9021
select top 100 * from

DFC.tb_sc_vRates  where "CurrencyTag"='USD'  and  daydate_fuib>='2021-05-20' and daydate_fuib<='2021-05-26'
and actionid=322 and "BranchId" =1000587 order by  Created

maxnum='27550000'
 ---and "Changed"='2021-05-26 16:32:17.000000'


select top 10 *
from DFC.tb_sc_vBills b where actionid=9021 and  daydate_fuib>='2021-05-20' and daydate_fuib<='2021-05-26'
where

select  count(*)
from  dbo. tb_cnb_Accounts

select  count(*)
from dbo.tb_cnb_Users

select count(*)
from  dbo.tb_cnb_ConnotationList

select  count(*)
from dbo.tb_cnb_cnbDocumentCodes

select  count(*)
from dbo.tb_cnb_BillGroups

select  count(*)
from dbo.tb_cnb_mtClientDocuments

select  count(*)
from dbo.tb_cnb_Operations


select   count(*)
FROM DFC.tb_cnb_CashBills

-----------------
---------------------------------------

  BEGIN
--
-- declare local temporary table ltb_PL(RC   varchar(4),
--                                      BRCA varchar(4),
--                                      YYYY_MM date,
--                                      Trade_Income_Buy money,
--                                      Trade_Income_Sell money,
--                                      Trade_Income money
--                                      )on commit preserve rows;

declare @DateFrom date;
declare @DateInto date;
set @DateFrom='2021-03-01'; --@DayDate_ot
set @DateInto='2021-03-01'; --@DayDate_do

--insert into ltb_PL(YYYY_MM, RC, BRCA, Trade_Income_Buy, Trade_Income_Sell, Trade_Income) --PL

select top 100
       b.id,
       b.DayDate,
       b.DayDate_fuib,
       b.created,
       b.changed,
       b1.RC as RC,
       b1.brca as brca,
     --  t.MainAmount,
       b.MainAmount as bills_MainAmount,
       b.CrncyAmount,
       b.Debitname,
       b.Creditname,
       b.Purpose,
      -- t.info,
       r.*


--        round(sum(case when b.ActionId=321 then (CAST(r.MinNum as numeric(18,4))/r.MinDen*b.CrncyAmount)  else 0 end),2) as Amount_Buy,
--
--        round(sum(case when b.ActionId=322 then (CAST(r.MinNum as numeric(18,4))/r.MinDen*b.CrncyAmount) else 0 end),2) as Amount_Sell,
--
--        round(sum(case when b.ActionId=321 then (CAST(r.MinNum as numeric(18,4))/r.MinDen*b.CrncyAmount) - t.MainAmount) else 0 end),2) as Trade_Income_Buy,
--       -- round(sum(case when b.ActionId=322 then (t.MainAmount -(CAST(r.MinNum as numeric(18,4))/r.MinDen*b.CrncyAmount) else 0 end),2) as Trade_Income_Sell,
--
--        round(sum(case when b.ActionId = 322 t.MainAmount - (CAST(r.MinNum as numeric(18,4))/r.MinDen*b.CrncyAmount)
--                       when b.ActionId = 321  then (CAST(r.MinNum as numeric(18,4))/r.MinDen*b.CrncyAmount) - t.MainAmount
--                       else 0 end),2) as Trade_Income,
--
--        r.created as created_Reats,
--        r.changed as changed_Reats,
--        r.MinNum,
--        r.MinDen,
--        r.ActionId as ActionId_Reats --???

from DFC.tb_sc_vBills b
-- left join DFC.tb_sc_vTransfers t on t.BillId=b.id
--                                  and t.CurrencyTag=''
--                                  and t.kind<> 0
join DFC.tb_sc_vRates r on r.DayDate=b.DayDate
                             and r.CurrencyTag=b.CurrencyTag
                            -- and r.ActionId=888  ---??
join DFC.tb_dfc_Branch b1 on b1.BranchId=b.BranchId and b1.BranchId=r.BranchId
where b.ActionId in (321,322) and b.ProcessFlag&3=3
      and b.DayDate_fuib>=@DateFrom
      and b.DayDate_fuib<=@DateInto
      and b.CurrencyTag='USD'
and b.id=5768764300
--5774608042
      ;end; commit;

------------------
--insert into ltb_Vol_Count (YYYY_MM, RC, BRCA, CrncyAmount_Buy, Count_Buy, CrncyAmount_Sell, Count_Sell) -- Объем и К-во
select --dateformat(a.DayDate_fuib,'YYYY-MM') as YYYY_MM,
       dateformat(a.created,'HH:MM')as HH_MI,
       a.created,
       b.RC, b.BRCA,
       sum(case when a.ActionId=321 then a.CrncyAmount else 0 end) as CrncyAmount_Buy,
       sum(case when a.ActionId=321 then 1 else 0 end) as Count_Buy,
       sum(case when a.ActionId=322 then a.CrncyAmount else 0 end) as CrncyAmount_Sell,
       sum(case when a.ActionId=322 then 1 else 0 end) as Count_Sell
    -- into #ltb_Vol_Count
from DFC.tb_sc_vBills a
join dfc.tb_sc_vToday t  on a.DayDate_fuib = t.DayDate_fuib  and t.kind = 1
left join DFC.tb_dfc_Branch b on b.BranchId=a.BranchId
where a.ActionId in (321,322)
      and a.ProcessFlag&3=3
      and a.DayDate_fuib>='2021-03-01'
      and a.DayDate_fuib<='2021-03-31'
      and a.CurrencyTag='USD'
    --  and a.id=5768764300
group by HH_MI, a.created, RC, BRCA; commit;

---cast(' 09:00:00.00' AS time) !!!???

select
RC, BRCA,
sum(CrncyAmount_Buy),
count(Count_Buy),
sum(CrncyAmount_Sell),
count(Count_Sell),
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
else null end as HH_MI_range
from  #ltb_Vol_Count as b
group by RC, BRCA, HH_MI_range;






---------------
  select *
from  DFC.tb_sc_vRates r where "DayDate_fuib"='2021-03-01' and actionid=0

"CurrencyTag"='USD' group by "actionid",branchid
  select top 7 *
from
DFC.tb_sc_vRates r
[11:10] Гаврилов Вадим Олександрович
    select top 100 a.*
from dbo.tb_sc_Actions a
where a.Id = 888



------------------------

select top 6 * from

DFC.tb_sc_vRates r where  r.ActionId=888

select top 60 * from
DFC.tb_sc_vTransfers t

select top 60 *
from DFC.tb_sc_vBills b where b.ActionId in (321,322)

select top 6 * from
dbo.tb_dfc_Encashment_Client_Torn a

SELECT Id,
     BranchId,
     Code,
     CurrencyTag,
     AccPurpose,
     Name,
     PermitFlag,
     Stamp,
     CreatorId,
     Created,
     ChangerId,
     Changed,
     ShortName,
     FullName
FROM DFC.tb_cnb_Accounts

SELECT Id,
     LaborId,
     PackNo,
     FormFlag,
     Code,
     TransId,
     SenderCode,
     SenderName,
     SenderState,
     SenderAddr,
     SenderAcc,
     CreditName,
     CreditState,
     CreditCode,
     TargetCode,
     RecvId,
     Amount,
     NDS,
     AdditionalCommission,
     Ctrls,
     PurposeCode,
     Purpose,
     KOD_SEP,
     Note,
     Period,
     PeriodBegin,
     PeriodEnd,
     VidCommPlat,
     CounterBegin,
     CounterEnd,
     TaxKind,
     TaxCode,
     PassDoc,
     PassSer,
     PassNum,
     PassVid,
     PassBD,
     PassDV,
     AddrCode,
     CurrencyTag,
     Flag,
     ifLoad,
     PermitFlag,
     TreatFlag,
     Stamp,
     CreatorId,
     Created,
     ChangerId,
     Changed,
     RemoveReason,
     ServiceId,
     BirthPlace
FROM DFC.tb_cnb_CashBills



SELECT Id,
     OwnerId,
     Task,
     SystemId,
     Status,
     ProfileId,
     BankProfit,
     SystemProfit,
     TotalProfitInUAH,
     ProfitSchemaId,
     DistrSchemaId,
     Flag,
     ProcessFlag,
     PermitFlag,
     ScroogeBillId,
     FileName,
     CreatorId,
     Created,
     ChangerId,
     Changed
FROM dbo.tb_cnb_mtTransactions

SELECT top 100 Id,
     ParamCode,
     RefferCode,
     Kind,
     Length,
     TaskCode,
     DefaultValue,
     Name,
     Mask,
     Deleted,
     Flag,
     GroupId,
     "No",
     BranchId,
     Stamp,
     CreatorId,
     Created,
     ChangerId,
     Changed
FROM dbo.tb_cnb_ConnotationList
WHERE Id = ::Id

SELECT top 100 Id,
     ListId,
     "Value",
     Flag,
     Stamp,
     CreatorId,
     Created,
     ChangerId,
     Changed,
     OwnerId
FROM dbo.tb_cnb_ConnotationValues


SELECT top 100 Id,
     DayDate,
     OrgDate,
     "No",
     UserId,
     ProfileId,
     AccountId,
     TransId,
     NopTransId,
     ProfitId,
     Amount,
     CheckBalanceDate,
     Flag,
     BillCode,
     PermitFlag,
     Stamp,
     CreatorId,
     Created,
     ChangerId,
     Changed,
     OpenerType
FROM dbo.tb_cnb_Labors where cast( "Created" as date)='2021-05-26'

SELECT top 100  * from  dbo.tb_cnb_CashBills b
left join dbo.tb_cnb_mtTransactions t on b.transid = t.id

left join  dbo.tb_cnb_Labors as lb on
b.LaborId = lb.id
    -- lb.ProfileId,
     lb.AccountId,
    --- lb.TransId = t.id

 where b.transid  = 74365
and
 "LaborId"=985175



select * from dbo.tb_sc_vBills where id=
610747464

Прочая дебит. задолж. по опер. с клиентами банка        Прочая кредиторская задолженность по операциям с к      Выплата перевода по системе Вестерн Юнион
SELECT top 100  * from
dbo.tb_cnb_mtTransactions where scroogebillid=
610747464
SELECT top 100  * from  dbo.tb_cnb_CashBills b where b.transid=74365
