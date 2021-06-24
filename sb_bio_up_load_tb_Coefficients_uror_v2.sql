--tb_Coefficients_uror
--call sb_bio.up_sp_ddl('up_load_tb_Coefficients_uror','create','(in @d_date date default(getdate()))

begin

 DECLARE @d_date date = '2021-01-26';

  if DAY(@d_date) in (26,30,31) then  ---уточнить график загрузки?
BEGIN
 declare @Date_fuib1 date = (select dateadd(dd,-(day(@d_date)-1),@d_date) from iq_dummy);

-- DECLARE @Date_fuib1 date = '2021-01-01';
-- --'"+Format(Parameters!d1.Value, "yyyy-MM-dd")+"';
-- DECLARE @Date_fuib2 date =  '2021-01-01';
-- --'"+Format(Parameters!d2.Value, "yyyy-MM-dd")+"';
--
SELECT t.DayDate_fuib     INTO #Calendar
FROM dfc.tb_sc_vToday t
WHERE day(t.DayDate_fuib) = 1
    AND t.DayDate_fuib = @Date_fuib1
   -- AND t.DayDate_fuib <= @Date_fuib1
GROUP BY t.DayDate_fuib ;COMMIT;

SELECT
           reportdate  ,
       EDRPOU  ,
       CASE WHEN OrderN=44 THEN 'CURRENT accounts FL'   WHEN OrderN=49 THEN 'CURRENT accounts CorpCl'
END AS OrdN ,
       SUM(isnull(mUAH,0)) AS 'mUAH' ,
       SUM(isnull(mUSD,0)) AS 'mUSD' ,
       SUM(isnull(mEUR,0)) AS 'mEUR'   INTO #xmlf02_balance
FROM sb_bio.tb_xmlf02_balance_uror
WHERE OrderN IN (44,49)
   -- AND  EDRPOU ='" + Parameters!EDRPOU.Value + "'    ---по всем банкам
    AND reportdate>DATEADD(year,-1,@Date_fuib1)
    AND reportdate<=@Date_fuib1
GROUP BY reportdate,
       EDRPOU,
       OrderN
ORDER BY reportdate;COMMIT;

SELECT  reportdate  ,
       EDRPOU  ,
       OrdN ,
       SUM(isnull(mUAH,0)) AS 'mUAH'         INTO #xmlf02_balance_pol
FROM #xmlf02_balance
WHERE reportdate>DATEADD(month,-6,@Date_fuib1)
    AND reportdate<=@Date_fuib1
GROUP BY reportdate,
       EDRPOU,
       OrdN;COMMIT;

SELECT  MIN( mUAH) AS polmUAH ,
       OrdN ,
       EDRPOU,
       t.DayDate_fuib  INTO #xmlf02_balance_pol_min
FROM #xmlf02_balance_pol   cross join #Calendar t
WHERE  t.DayDate_fuib>=reportdate
    AND  reportdate>DATEADD(month,-6,t.DayDate_fuib)
GROUP BY  OrdN ,
       EDRPOU,
       t.DayDate_fuib
ORDER BY  OrdN ,
        t.DayDate_fuib;COMMIT;

                /*максимальная величина остатка по текущим счетам на анализируемом периоде (в основном на годовом интервале)*/
SELECT MAX(aa.FL_UAH_fiz) AS F_UAH ,
       MAX(aa.FL_UAH_jur) AS L_UAH ,
       aa.EDRPOU,
       aa.DayDate_fuib                             INTO #FL_COEFF
FROM(
SELECT  CASE WHEN xb.OrdN='CURRENT accounts FL'
    AND isnull((MAX(xb.mUAH)-stddev_pop(xb.mUAH)),0)=0 THEN 0   WHEN xb.OrdN='CURRENT accounts FL'
    AND isnull((MAX(xb.mUAH)-stddev_pop(xb.mUAH)),0)<>0 THEN round((MIN(xb.mUAH)/(MAX(xb.mUAH)-stddev_pop(xb.mUAH))),2)
END AS FL_UAH_fiz ,
                CASE WHEN xb.OrdN='CURRENT accounts CorpCl'
    AND isnull((MAX(xb.mUAH)-stddev_pop(xb.mUAH)),0)=0 THEN 0   WHEN xb.OrdN='CURRENT accounts CorpCl'
    AND isnull((MAX(xb.mUAH)-stddev_pop(xb.mUAH)),0)<>0 THEN round((MIN(xb.mUAH)/(MAX(xb.mUAH)-stddev_pop(xb.mUAH))),2)
END AS FL_UAH_jur ,
                xb.OrdN ,xb.EDRPOU,  t.DayDate_fuib
FROM #xmlf02_balance AS xb   cross join #Calendar t
WHERE  t.DayDate_fuib>=reportdate
    AND  reportdate>DATEADD(year,-1,t.DayDate_fuib)
GROUP BY  xb.OrdN ,xb.EDRPOU, t.DayDate_fuib
UNION
SELECT  CASE WHEN bpm.OrdN='CURRENT accounts FL'
    AND isnull(xb.mUAH,0)=0 THEN 0   WHEN bpm.OrdN='CURRENT accounts FL'
    AND isnull(xb.mUAH,0)<>0 THEN round((bpm.polmUAH/xb.mUAH),2)
END AS FL_UAH_fiz ,
                CASE WHEN bpm.OrdN='CURRENT accounts CorpCl'
    AND isnull(xb.mUAH,0)=0 THEN 0   WHEN bpm.OrdN='CURRENT accounts CorpCl'
    AND isnull(xb.mUAH,0)<>0 THEN round((bpm.polmUAH/xb.mUAH),2)
END AS FL_UAH_jur ,
                bpm.OrdN,
                bpm.EDRPOU,
                bpm.DayDate_fuib
FROM #xmlf02_balance_pol_min AS bpm
        left join #xmlf02_balance AS xb ON bpm.EDRPOU = xb.EDRPOU
    AND  bpm.OrdN = xb.OrdN
    AND bpm.DayDate_fuib = xb.reportdate   ) AS aa
GROUP BY aa.EDRPOU,
     aa.DayDate_fuib;COMMIT;

SELECT
      SUM(CASE WHEN  OrderN = 2 THEN FCY
END) AS '2' ,
       SUM(CASE WHEN  OrderN = 3 THEN FCY
END) AS '3' ,
       SUM(CASE WHEN  OrderN = 4 THEN FCY
END) AS '4' ,
       SUM(CASE WHEN  OrderN = 5 THEN FCY
END) AS '5' ,
       SUM(CASE WHEN  OrderN = 9 THEN FCY
END) AS '9' ,
       SUM(CASE WHEN  OrderN = 10 THEN FCY
END) AS '10' ,
       SUM(CASE WHEN  OrderN = 11 THEN FCY
END) AS '11' ,
       SUM(CASE WHEN  OrderN = 13 THEN FCY
END) AS '13' ,
       SUM(CASE WHEN  OrderN = 14 THEN FCY
END) AS '14' ,
       SUM(CASE WHEN  OrderN = 15 THEN FCY
END) AS '15' ,
       SUM(CASE WHEN  OrderN = 19 THEN FCY
END) AS '19' ,
       SUM(CASE WHEN  OrderN = 20 THEN FCY
END) AS '20' ,
       SUM(CASE WHEN  OrderN = 21 THEN FCY
END) AS '21' ,
       SUM(CASE WHEN  OrderN = 26 THEN FCY
END) AS '26' ,
       SUM(CASE WHEN  OrderN = 29 THEN FCY
END) AS '29' ,
       SUM(CASE WHEN  OrderN = 34 THEN FCY
END) AS '34' ,
       SUM(CASE WHEN  OrderN = 37 THEN FCY
END) AS '37' ,
        SUM(CASE WHEN  OrderN = 39 THEN FCY
END) AS '39' ,
       SUM(CASE WHEN  OrderN = 41 THEN FCY
END) AS '41' ,
       SUM(CASE WHEN  OrderN = 42 THEN FCY
END) AS '42' ,
       SUM(CASE WHEN  OrderN = 44 THEN FCY
END) AS '44' ,
       SUM(CASE WHEN  OrderN = 45 THEN FCY
END) AS '45' ,
       SUM(CASE WHEN  OrderN = 46 THEN FCY
END) AS '46' ,
       SUM(CASE WHEN  OrderN = 49 THEN FCY
END) AS '49' ,
       SUM(CASE WHEN  OrderN = 50 THEN FCY
END) AS '50' ,
       SUM(CASE WHEN  OrderN = 52 THEN FCY
END) AS '52' ,
       SUM(CASE WHEN  OrderN = 53 THEN FCY
END) AS '53' ,
       SUM(CASE WHEN  OrderN = 54 THEN FCY
END) AS '54' ,
       SUM(CASE WHEN  OrderN = 55 THEN FCY
END) AS '55' ,
       SUM(CASE WHEN  OrderN = 56 THEN FCY
END) AS '56' ,
       SUM(CASE WHEN  OrderN = 59 THEN FCY
END) AS '59' ,
       SUM(CASE WHEN  OrderN = 61 THEN FCY
END) AS '61' ,
       SUM(CASE WHEN  OrderN = 67 THEN FCY
END) AS '67' ,
       SUM(CASE WHEN  OrderN = 69 THEN FCY
END) AS '69'  ,
        reportdate  ,
       EDRPOU INTO #consolidated_balance_FCY
FROM sb_bio.tb_xmlf02_balance_uror
WHERE 1=1
   -- AND EDRPOU ='" + Parameters!EDRPOU.Value + "'  --по всем банкам
    AND ReportDate = @Date_fuib1
  --  AND ReportDate <= @Date_fuib2
GROUP BY  reportdate,
       EDRPOU;COMMIT;

SELECT     (isnull(slg.[67],0)-isnull(slg.[20],0)-isnull(slg.[19],0)-isnull(slg.[26],0)-isnull(slg.[29],0))+  isnull(slg.[37],0)+isnull(slg.[42],0)+isnull(slg.[44],0)*fl.F_UAH+isnull(slg.[46],0)+isnull(slg.[49],0)*fl.L_UAH+  isnull(slg.[50],0)+isnull(slg.[53],0)+isnull(slg.[54],0) AS stable_liab_gross,
       isnull(slg.[10],0)+ isnull(slg.[11],0)+ isnull(slg.[15],0)+ isnull(slg.[4],0)*fl.L_UAH AS working_assets_gross  ,
       (isnull(slg.[67],0)-isnull(slg.[26],0)-isnull(slg.[29],0))+  isnull(slg.[37],0)+isnull(slg.[42],0)+isnull(slg.[44],0)*fl.F_UAH+isnull(slg.[46],0)+isnull(slg.[49],0)*fl.L_UAH+     isnull(slg.[50],0)+isnull(slg.[53],0)+isnull(slg.[54],0) AS stable_liab_net  ,
       CASE WHEN isnull(slg.[69],0)=0 THEN 0
ELSE ((isnull(slg.[67],0)-isnull(slg.[26],0)-isnull(slg.[29],0))+  isnull(slg.[37],0)+isnull(slg.[42],0)+isnull(slg.[44],0)*fl.F_UAH+isnull(slg.[46],0)+isnull(slg.[49],0)*fl.L_UAH+ isnull(slg.[50],0)+isnull(slg.[53],0)+isnull(slg.[54],0))/(isnull(slg.[69],0))
END AS stab_liab_net_dev,
       isnull(slg.[10],0)+ isnull(slg.[21],0)+ isnull(slg.[13],0)+ isnull(slg.[4],0)*fl.L_UAH AS working_assets_net,
        CASE WHEN isnull(slg.[69],0)=0 THEN 0
ELSE (isnull(slg.[10],0)+ isnull(slg.[21],0)+ isnull(slg.[13],0)+ isnull(slg.[4],0)*fl.L_UAH)/(isnull(slg.[69],0))
END AS work_ass_net_dev,
       isnull(slg.[2],0)+ isnull(slg.[3],0) + isnull(slg.[4],0) + isnull(slg.[5],0) AS Liquid_assets,
        CASE WHEN isnull(slg.[69],0)=0 THEN 0
ELSE (isnull(slg.[2],0)+ isnull(slg.[3],0) + isnull(slg.[4],0) + isnull(slg.[5],0))/(isnull(slg.[69],0))
END AS Liquid_assets_dev,
       fl.F_UAH ,
       fl.L_UAH ,
       slg.EDRPOU ,
       slg.reportdate,
       CASE WHEN stable_liab_gross = 0 THEN 0
ELSE  working_assets_gross/stable_liab_gross
END AS Loan_portfolio_fund,
       CASE WHEN (isnull(slg.[39],0) + isnull(slg.[44],0) + isnull(slg.[49],0)) = 0 THEN 0
ELSE Liquid_assets/(isnull(slg.[39],0) + isnull(slg.[44],0) + isnull(slg.[49],0))
END AS Instant_liquidity,
        CASE WHEN (isnull(slg.[14],0) - isnull(slg.[52],0))>0 THEN (isnull(slg.[14],0) - isnull(slg.[52],0))
ELSE 0
END AS [1452],
        CASE WHEN (isnull(slg.[61],0) - isnull(slg.[54],0) - isnull(slg.[55],0) - isnull(slg.[56],0)  - isnull(slg.[59],0)) = 0 THEN 0
ELSE (isnull(slg.[2],0) + isnull(slg.[3],0)  + isnull(slg.[9],0) + isnull(slg.[10],0))/(isnull(slg.[61],0) - isnull(slg.[54],0) - isnull(slg.[55],0) - isnull(slg.[56],0)  - isnull(slg.[59],0))
END  AS Current_liquidity,
         CASE WHEN (isnull(slg.[61],0) - isnull(slg.[54],0) - (isnull(slg.[55],0) + isnull(slg.[56],0) + isnull(slg.[59],0)) + [1452] - isnull(slg.[52],0)) = 0 THEN 0
ELSE ((isnull(slg.[2],0) + isnull(slg.[3],0) + (isnull(slg.[9],0) - isnull(slg.[41],0))+ isnull(slg.[10],0))/  (isnull(slg.[61],0) - isnull(slg.[54],0) - (isnull(slg.[55],0) + isnull(slg.[56],0) + isnull(slg.[59],0)) +  [1452] - isnull(slg.[52],0)))
END AS Current_liquidity_MBK,
         CASE WHEN isnull(slg.[34],0) = 0 THEN 0
ELSE (isnull(slg.[9],0) - isnull(slg.[41],0))/isnull(slg.[34],0)
END AS Saldo_interb_tran_Assets,
         isnull(slg.[39],0) AS bancacc,
         isnull(slg.[44],0) AS accfl,
         isnull(slg.[49],0) AS acccorp
FROM #consolidated_balance_FCY AS slg LEFT JOIN #FL_COEFF AS fl ON slg.EDRPOU = fl.EDRPOU
    AND  slg.reportdate = fl.DayDate_fuib
ORDER BY slg.reportdate,
         slg.EDRPOU;
		 
---ROA_ROE start
SELECT SUM(CASE WHEN  New_OrderN = 14 THEN inFCY1
END) AS '14_PL',
           SUM(CASE WHEN  New_OrderN = 28 THEN inFCY1
END) AS '28_PL',
           SUM(CASE WHEN  New_OrderN = 29 THEN inFCY1
END) AS '29_PL',
            SUM(CASE WHEN  New_OrderN = 39 THEN inFCY1
END) AS '39_PL',
            SUM(CASE WHEN  New_OrderN = 52 THEN inFCY1
END) AS '52_PL',
            SUM(CASE WHEN  New_OrderN = 56 THEN inFCY1
END) AS '56_PL',
           SUM(CASE WHEN  New_OrderN = 62 THEN inFCY1
END) AS '62_PL',
           SUM(CASE WHEN  New_OrderN = 92 THEN inFCY1
END) AS '92_PL',
           SUM(CASE WHEN  New_OrderN = 95 THEN inFCY1
END) AS '95_PL',
            ReportDate,
            EDRPOU   INTO #ltb_dohidnost_pl
FROM  sb_bio.tb_xmlf02_PL_uror
WHERE ReportDate = @Date_fuib1
  --  AND ReportDate <= @Date_fuib2
  --  AND EDRPOU = '" + Parameters!EDRPOU.Value + "' --по всем банкам
GROUP BY ReportDate, EDRPOU;COMMIT;

SELECT   SUM(CASE WHEN  OrderN = 4 THEN FCY
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
            SUM(CASE WHEN  OrderN = 53 THEN FCY
END) AS '53' ,
            SUM(CASE WHEN  OrderN = 54 THEN FCY
END) AS '54' ,
            SUM(CASE WHEN  OrderN = 63 THEN FCY
END) AS '63' ,
            SUM(CASE WHEN  OrderN = 64 THEN FCY
END) AS '64' ,
            SUM(CASE WHEN  OrderN = 65 THEN FCY
END) AS '65' ,
            SUM(CASE WHEN  OrderN = 66 THEN FCY
END) AS '66' ,
            SUM(CASE WHEN  OrderN = 67 THEN FCY
END) AS '67' ,
            SUM(CASE WHEN  OrderN = 68 THEN FCY
END) AS '68' ,
            SUM(CASE WHEN  OrderN = 69 THEN FCY
END) AS '69',
            CASE WHEN month(ReportDate)=1 THEN 12 WHEN month(ReportDate)=2 THEN 1 WHEN month(ReportDate)=3  THEN 2 WHEN month(ReportDate)=4 THEN 3 WHEN month(ReportDate)=5 THEN 4 WHEN month(ReportDate)=6  THEN 5 WHEN month(ReportDate)=7 THEN 6 WHEN month(ReportDate)=8 THEN 7 WHEN month(ReportDate)=9  THEN 8 WHEN month(ReportDate)=10 THEN 9 WHEN month(ReportDate)=11 THEN 10 WHEN month(ReportDate)=12  THEN 11
END AS 'D169',
            reportdate  ,
            EDRPOU INTO #consolidated_bal
FROM sb_bio.tb_xmlf02_balance_uror
WHERE 1=1
   --- AND EDRPOU = '" + Parameters!EDRPOU.Value + "'  -- по всем
    AND ReportDate = @Date_fuib1
    --AND ReportDate <= @Date_fuib2
GROUP BY  reportdate, EDRPOU ;COMMIT;

---update sb_bio.tb_Coefficients_uror   set

SELECT CASE WHEN isnull(slg.[69],0)=0 THEN 0
ELSE (isnull(slg.[63],0)/isnull(slg.[69],0))*(12.00/slg.[D169])
END AS  Profit_assets,
           CASE WHEN (isnull(slg.[64],0)+isnull(slg.[65],0)+isnull(slg.[66],0))=0 THEN 0  WHEN isnull(slg.[69],0)=0 THEN 0
ELSE  ((isnull(slg.[63],0)/(isnull(slg.[64],0)+isnull(slg.[65],0)+isnull(slg.[66],0)))*(12.00/slg.[D169]))
END AS  Profit_capital,
            CASE WHEN  isnull(pl.[62_PL],0)=0 THEN 0
ELSE  -isnull(pl.[92_PL],0)/isnull(pl.[62_PL],0)
END AS Oper_exp_inc,
           CASE WHEN  isnull(pl.[62_PL],0)=0 THEN 0
ELSE -isnull(pl.[95_PL],0)/isnull(pl.[62_PL],0)
END AS Contr_credit_risk_income,
           CASE WHEN  (isnull(slg.[4],0)+isnull(slg.[5],0)+isnull(slg.[6],0)+isnull(slg.[7],0)+isnull(slg.[10],0)+   isnull(slg.[11],0)+isnull(slg.[15],0)+isnull(slg.[26],0))=0 THEN 0  WHEN isnull(slg.[69],0)=0 THEN 0
ELSE (isnull(pl.[14_PL],0)/(isnull(slg.[4],0)+isnull(slg.[5],0)+isnull(slg.[6],0)+isnull(slg.[7],0)+isnull(slg.[10],0)+   isnull(slg.[11],0)+isnull(slg.[15],0)+isnull(slg.[26],0)))*(12.00/slg.[D169])
END AS Av_rate_assets,
           CASE WHEN (isnull(slg.[37],0)+isnull(slg.[42],0)+isnull(slg.[41],0)+isnull(slg.[47],0)+isnull(slg.[51],0)+ isnull(slg.[53],0)+ isnull(slg.[54],0))=0 THEN 0  WHEN isnull(slg.[69],0)=0 THEN 0
ELSE (isnull(pl.[28_PL],0)/(isnull(slg.[37],0)+isnull(slg.[42],0)+isnull(slg.[41],0)+isnull(slg.[47],0)+isnull(slg.[51],0)+ isnull(slg.[53],0)+ isnull(slg.[54],0)))*(12.00/slg.[D169])
END AS Av_rate_pass,
           CASE WHEN isnull(slg.[34],0)=0 THEN 0  WHEN isnull(slg.[69],0)=0 THEN 0
ELSE  (isnull(pl.[29_PL],0)/isnull(slg.[34],0))*(12.00/slg.[D169])
END AS Interest_margin,
            CASE WHEN isnull(pl.[62_PL],0)=0 THEN 0
ELSE  isnull(pl.[29_PL],0)/isnull(pl.[62_PL],0)
END AS NetInterestInc_TotalInc,
            CASE WHEN isnull(pl.[62_PL],0)=0 THEN 0
ELSE  isnull(pl.[39_PL],0)/isnull(pl.[62_PL],0)
END AS Netfeecommiss_Totalinc,
           CASE WHEN isnull(pl.[62_PL],0)=0 THEN 0
ELSE  (isnull(pl.[52_PL],0) + isnull(pl.[56_PL],0))/isnull(pl.[62_PL],0)
END AS Otherinc_Totalinc,
            slg.reportdate,
            slg.EDRPOU
FROM #consolidated_bal AS slg LEFT JOIN #ltb_dohidnost_pl AS pl ON slg.EDRPOU = pl.EDRPOU
    AND slg.ReportDate = pl.ReportDate
ORDER BY slg.reportdate, slg.EDRPOU; COMMIT;		 
---ROA_ROE  end
---quality_kp start
SELECT SUM(CASE WHEN  New_OrderN = 5 THEN inFCY1
END) AS '5_PL',
      reportdate,
      EDRPOU INTO #5_PL
FROM  sb_bio.tb_xmlf02_PL_uror
WHERE ReportDate = @Date_fuib1
    --AND ReportDate <= @Date_fuib2
   -- AND EDRPOU = '" + Parameters!EDRPOU.Value + "'
GROUP BY reportdate,
      EDRPOU;COMMIT;
	  
SELECT SUM(CASE WHEN OrderN = 15 THEN FCY
END) AS '15_ST' ,
       SUM(CASE WHEN OrderN = 31 THEN FCY
END) AS '31_ST' ,
      reportdate,
      EDRPOU INTO #5_ST
FROM  sb_bio.tb_xmlf02_balance_uror
WHERE  reportdate = cast((year(reportdate)||'-01-01') AS date)
   -- AND ReportDate <= @Date_fuib2
   AND ReportDate = @Date_fuib1
   -- AND EDRPOU = '" + Parameters!EDRPOU.Value + "'
GROUP BY reportdate, EDRPOU;COMMIT;

SELECT SUM(CASE WHEN OrderN = 15 THEN FCY
END) AS '15_ST' ,
      SUM(CASE WHEN OrderN = 31 THEN FCY
END) AS '31_ST' ,
      reportdate,
      EDRPOU   INTO #5_ST_Dec
FROM  sb_bio.tb_xmlf02_balance_uror
WHERE  reportdate=cast(((year(getdate())-1)||'-12-01') AS date)
    --AND ReportDate <= @Date_fuib2
	AND ReportDate = @Date_fuib1
   -- AND EDRPOU = '" + Parameters!EDRPOU.Value + "'
GROUP BY reportdate, EDRPOU ;COMMIT;

SELECT a.[15],
      a.[19],
      a.[20],
      a.[31],
      a.[D169],
      a.[5_PL],
      a.[15_ST],
      a.[31_ST],
      a.ReportDate,
      a.EDRPOU INTO #quality_kp
FROM (
SELECT  SUM(CASE WHEN  bu.OrderN = 15 THEN bu.FCY
END) AS '15' ,   SUM(CASE WHEN  bu.OrderN = 19 THEN bu.FCY
END) AS '19' ,   SUM(CASE WHEN  bu.OrderN = 20 THEN bu.FCY
END) AS '20' ,   SUM(CASE WHEN  bu.OrderN = 31 THEN bu.FCY
END) AS '31' ,   CASE WHEN month(bu.ReportDate)=1 THEN 12 WHEN month(bu.ReportDate)=2 THEN 1 WHEN month(bu.ReportDate)=3 THEN 2   WHEN month(bu.ReportDate)=4 THEN 3  
WHEN month(bu.ReportDate)=5 THEN 4   WHEN month(bu.ReportDate)=6 THEN 5 WHEN month(bu.ReportDate)=7 THEN 6   WHEN month(bu.ReportDate)=8 THEN 7 
WHEN month(bu.ReportDate)=9  THEN 8   WHEN month(bu.ReportDate)=10 THEN 9   WHEN month(bu.ReportDate)=11 THEN 10 WHEN month(bu.ReportDate)=12 THEN 11
END AS 'D169',   pu.[5_PL],   ps.[15_ST],   ps.[31_ST],   bu.ReportDate,   bu.EDRPOU
FROM sb_bio.tb_xmlf02_balance_uror AS bu left join #5_PL AS pu ON bu.EDRPOU = pu.EDRPOU
    AND bu.ReportDate = pu.ReportDate left join #5_ST AS ps ON bu.EDRPOU = ps.EDRPOU
    AND year(bu.reportdate) = year(ps.reportdate)
WHERE   bu.reportdate <> cast((year(bu.reportdate)||'-01-01') AS date)
    AND bu.ReportDate = @Date_fuib1
   ---AND bu.ReportDate <= @Date_fuib2
   -- AND bu.EDRPOU = '" + Parameters!EDRPOU.Value + "'
GROUP BY pu.[5_PL],  ps.[15_ST],  ps.[31_ST],  bu.ReportDate,  bu.EDRPOU
UNION ALL
SELECT  SUM(CASE WHEN  bu.OrderN = 15 THEN bu.FCY
END) AS '15' ,   SUM(CASE WHEN  bu.OrderN = 19 THEN bu.FCY
END) AS '19' ,   SUM(CASE WHEN  bu.OrderN = 20 THEN bu.FCY
END) AS '20' ,   SUM(CASE WHEN  bu.OrderN = 31 THEN bu.FCY
END) AS '31' ,   CASE WHEN month(bu.ReportDate)=1 THEN 12 WHEN month(bu.ReportDate)=2 THEN 1 WHEN month(bu.ReportDate)=3 THEN 2   WHEN month(bu.ReportDate)=4 THEN 3 WHEN month(bu.ReportDate)=5 THEN 4   WHEN month(bu.ReportDate)=6 THEN 5 WHEN month(bu.ReportDate)=7 THEN 6 WHEN month(bu.ReportDate)=8 THEN 7   WHEN month(bu.ReportDate)=9  THEN 8   WHEN month(bu.ReportDate)=10 THEN 9   WHEN month(bu.ReportDate)=11 THEN 10 WHEN month(bu.ReportDate)=12 THEN 11
END AS 'D169',   pu.[5_PL],   ps.[15_ST],   ps.[31_ST],   bu.ReportDate,   bu.EDRPOU
FROM sb_bio.tb_xmlf02_balance_uror AS bu left join #5_PL AS pu ON bu.EDRPOU = pu.EDRPOU
    AND bu.ReportDate = pu.ReportDate left join #5_ST_Dec AS ps ON bu.EDRPOU = ps.EDRPOU
    AND year(bu.reportdate) = year(ps.reportdate)+1
WHERE   bu.reportdate = cast((year(bu.reportdate)||'-01-01') AS date)
    AND bu.ReportDate = @Date_fuib1
    --AND bu.ReportDate <= @Date_fuib2
    --AND bu.EDRPOU = '" + Parameters!EDRPOU.Value + "'
GROUP BY pu.[5_PL],  ps.[15_ST],  ps.[31_ST],  bu.ReportDate,  bu.EDRPOU) a
ORDER BY a.reportdate,
       a.EDRPOU   ;COMMIT;
	
---update sb_bio.tb_Coefficients_uror   set   
SELECT [15],
       [15_ST],
       [19],
       [20],
       [31],
       [31_ST],
       [5_PL],
       [D169],
       ((isnull([5_PL],0)-(isnull([31],0)-isnull([31_ST],0)))/((isnull([15_ST],0)+isnull([15],0))/2))*(12/isnull([D169],0))  AS Real_profit,
         -(isnull([19],0)+isnull([20],0))/(isnull([15],0)+isnull([31],0))  AS Provis_grossloan,
       reportdate,
       EDRPOU
FROM #quality_kp
ORDER BY reportdate,
      EDRPOU; COMMIT;
	  ---quality_kp end
		 
 end
  end if
; end
