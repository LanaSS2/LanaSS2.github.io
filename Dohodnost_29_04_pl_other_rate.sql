BEGIN

DECLARE @Date_fuib1 date = '2021-01-01';
 --'"+Format(Parameters!d1.Value, "yyyy-MM-dd")+"';
DECLARE @Date_fuib2 date = '2021-03-01';
--'"+Format(Parameters!d2.Value, "yyyy-MM-dd")+"';
SELECT
SUM(CASE WHEN  New_OrderN = 14 THEN T070K2
END) AS '14_PL',
SUM(CASE WHEN  New_OrderN = 28 THEN T070K2
END) AS '28_PL',
SUM(CASE WHEN  New_OrderN = 62 THEN T070K2
END) AS '62_PL',
SUM(CASE WHEN  New_OrderN = 92 THEN T070K2
END) AS '92_PL',
SUM(CASE WHEN  New_OrderN = 95 THEN T070K2
END) AS '95_PL',

      ReportDate,
      EDRPOU
      INTO #ltb_dohidnost_pl

FROM  sb_bio.tb_xmlf02_PL_uror
WHERE ReportDate >= @Date_fuib1
    AND ReportDate <= @Date_fuib2
    AND EDRPOU = '00032129'
    --'" + Parameters!EDRPOU.Value + "'
GROUP BY ReportDate,
      EDRPOU;
COMMIT;

select * from #ltb_dohidnost_pl;

---------------------------

SELECT
              SUM(CASE WHEN  OrderN = 4 THEN FCY
END) AS '4' ,
              SUM(CASE WHEN  OrderN = 5 THEN FCY
END) AS '5' ,
              SUM(CASE WHEN  OrderN = 6 THEN FCY
END) AS '6' ,
              SUM(CASE WHEN  OrderN = 7 THEN FCY
END) AS '7' ,
              SUM(CASE WHEN  OrderN = 10 THEN FCY
END) AS '10' ,
              SUM(CASE WHEN  OrderN = 11 THEN FCY
END) AS '11' ,
              SUM(CASE WHEN  OrderN = 15 THEN FCY
END) AS '15' ,
              SUM(CASE WHEN  OrderN = 26 THEN FCY
END) AS '26' ,

        SUM(CASE WHEN  OrderN = 34 THEN FCY
END) AS '34' ,

        SUM(CASE WHEN  OrderN = 37 THEN FCY
END) AS '37' ,
              SUM(CASE WHEN  OrderN = 41 THEN FCY
END) AS '41' ,
              SUM(CASE WHEN  OrderN = 42 THEN FCY
END) AS '42' ,
              SUM(CASE WHEN  OrderN = 47 THEN FCY
END) AS '47' ,
              SUM(CASE WHEN  OrderN = 51 THEN FCY
END) AS '51' ,
              SUM(CASE WHEN  OrderN = 54 THEN FCY
END) AS '54' ,
CASE      WHEN month(ReportDate)=1 THEN 12
          WHEN month(ReportDate)=2 THEN 1
          WHEN month(ReportDate)=3 THEN 2
          WHEN month(ReportDate)=4 THEN 3
          WHEN month(ReportDate)=5 THEN 4
          WHEN month(ReportDate)=6 THEN 5
          WHEN month(ReportDate)=7 THEN 6
          WHEN month(ReportDate)=8 THEN 7
          WHEN month(ReportDate)=9  THEN 8
          WHEN month(ReportDate)=10 THEN 9
          WHEN month(ReportDate)=11 THEN 10
          WHEN month(ReportDate)=12 THEN 11
          END AS 'D169',
              ReportDate  ,
              EDRPOU
INTO #ltb_consolidated_bl_dohidn
FROM sb_bio.tb_xmlf02_balance_uror
WHERE 1=1
    AND EDRPOU = '00032129'
        --'" + Parameters!EDRPOU.Value + "'
    AND ReportDate >= @Date_fuib1
    AND ReportDate <= @Date_fuib2
GROUP BY  ReportDate, EDRPOU;
COMMIT;

select * from #ltb_consolidated_bl_dohidn;

SELECT

CASE WHEN  isnull(pl.[62_PL],0)=0 THEN 0 ELSE
 -isnull(pl.[92_PL],0)/isnull(pl.[62_PL],0) END as Oper_exp_inc,

CASE WHEN  isnull(pl.[62_PL],0)=0 THEN 0 ELSE -isnull(pl.[95_PL],0)/isnull(pl.[62_PL],0) END as Contr_credit_risk_income,

CASE WHEN  (isnull(cb.[4],0)+isnull(cb.[5],0)+isnull(cb.[6],0)+isnull(cb.[7],0)+isnull(cb.[10],0)+
            isnull(cb.[11],0)+isnull(cb.[15],0)+isnull(cb.[26],0))=0 THEN 0 ELSE
(isnull(pl.[14_PL],0)/(isnull(cb.[4],0)+isnull(cb.[5],0)+isnull(cb.[6],0)+isnull(cb.[7],0)+isnull(cb.[10],0)+
            isnull(cb.[11],0)+isnull(cb.[15],0)+isnull(cb.[26],0)))*(12.00/cb.[D169]) END as Av_rate_assets,
                         cb.EDRPOU,
                         cb.ReportDate

FROM #ltb_consolidated_bl_dohidn as cb
LEFT JOIN #ltb_dohidnost_pl as pl ON cb.EDRPOU = pl.EDRPOU AND cb.ReportDate = pl.ReportDate
ORDER BY cb.reportdate,
         cb.EDRPOU;
END






