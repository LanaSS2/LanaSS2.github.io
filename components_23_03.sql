=(E258-E114-E93-E120-E122)+E129+E147+E156*D312+E164+E197*D311+E206+E215+E219 --стаб пасс брут
=(E258-E120-E122)+E129+E147+E156*D312+E164+E197*D311+E206+E215+E219 --стаб пасс нет

BEGIN

DECLARE @Date_fuib1 date = '2020-12-01'
--'"+Format(Parameters!d1.Value, "yyyy-MM-dd")+"';
DECLARE @Date_fuib2 date = '2021-01-01'
--'"+Format(Parameters!d2.Value, "yyyy-MM-dd")+"';


SELECT  SUM(CASE WHEN  OrderN = 2 THEN FCY
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
END) AS '69'  ,
 CASE WHEN month(ReportDate)=1 THEN 12 WHEN month(ReportDate)=2 THEN 1 WHEN month(ReportDate)=3 THEN 2
      WHEN month(ReportDate)=4 THEN 3 WHEN month(ReportDate)=5 THEN 4 WHEN month(ReportDate)=6 THEN 5
      WHEN month(ReportDate)=7 THEN 6 WHEN month(ReportDate)=8 THEN 7 WHEN month(ReportDate)=9  THEN 8
      WHEN month(ReportDate)=10 THEN 9 WHEN month(ReportDate)=11 THEN 10 WHEN month(ReportDate)=12 THEN 11
END AS 'D169',
         reportdate,
         EDRPOU INTO #consolidated_balance_FCY
FROM sb_bio.tb_xmlf02_balance_uror
WHERE 1=1
    AND EDRPOU = '14360570'
    ---'" + Parameters!EDRPOU.Value + "'
    AND ReportDate >= @Date_fuib1
    AND ReportDate <= @Date_fuib2
GROUP BY  reportdate,
         EDRPOU;
COMMIT;
  
SELECT 
      'working_assets_gross',	  
      /*брутто рабочие активы*/ --1 
	  isnull(slg.[10],0) AS '10',
      isnull(slg.[11],0) AS '11',
      isnull(slg.[15],0) AS '15',
      isnull(slg.[4],0) AS '4',
	  fl.L_UAH AS 'L_UAH',
	  
	  'stable_liab_gross',
	  /*брутто стабильные пассивы*/--2
	  isnull(slg.[67],0) AS '67',
      isnull(slg.[20],0) AS '20',
      isnull(slg.[19],0) AS '19',
      isnull(slg.[26],0) AS '26',
      isnull(slg.[29],0) AS '29',
      isnull(slg.[37],0) AS '37',
      isnull(slg.[42],0) AS '42',
      isnull(slg.[44],0) AS '44',
	  fl.F_UAH AS 'F_UAH',
      isnull(slg.[46],0) AS '46',
      isnull(slg.[49],0) AS '49',
	  fl.L_UAH AS 'L_UAH_1',
      isnull(slg.[50],0) AS '50',
      isnull(slg.[53],0) AS '53',
      isnull(slg.[54],0) AS '54',
	  
      'working_assets_net',
      /*нетто рабочие активы*/ --3
	  isnull(slg.[10],0) AS '10_2',
      isnull(slg.[21],0) AS '21',
      isnull(slg.[13],0) AS '13',
      isnull(slg.[4],0) AS '4_2',
      isnull(slg.[69],0) AS '69_2',
	  
       'stable_liab_net',
	   /*нетто стабильные пассивы*/--4
	  isnull(slg.[67],0) AS '67_1',
      isnull(slg.[26],0) AS '26_1',
      isnull(slg.[29],0) AS '29_1',
      isnull(slg.[37],0) AS '37_1',
      isnull(slg.[42],0) AS '42_1',
      isnull(slg.[44],0) AS '44_1',
	  fl.F_UAH AS 'F_UAH_1',
      isnull(slg.[46],0) AS '46_1',
      isnull(slg.[49],0) AS '49_1',
	  fl.L_UAH AS 'L_UAH_2',
      isnull(slg.[50],0) AS '50_1',
      isnull(slg.[53],0) AS '53_1',
      isnull(slg.[54],0) AS '54_1',
      isnull(slg.[69],0) AS '69_1',
	  
      'Liquid_assets',
        /*Ликвидные активы*/ --5
	  isnull(slg.[2],0) AS '2',
      isnull(slg.[3],0) AS '3',
      isnull(slg.[5],0) AS '5',
      isnull(slg.[69],0) AS '69_3',
	  	  
	'Off_balance_commitments',
	/*Внебансовые обязательства*/ --6
	sum(Fields!E296.Value, "zabalans"),
	sum(Fields!E305.Value, "zabalans"),

	'Loan_portfolio_fund',
	/*Фондирование кредитного портфеля*/ --7
	(Fields!working_assets_gross.Value,"Coefficients"),
	(Fields!stable_liab_gross.Value,"Coefficients"),

	'Instant_liquidity',
	/*Мгновенная ликвидность*/   --8
	isnull(slg.[39],0) AS '39',
	isnull(slg.[44],0) AS '44_2',
	isnull(slg.[49],0) AS '49_2',
	
	'Instant_Liquid_OFF_balance',
	/*Мгновенная ликвидность с учетом внебаланса*/ -- 9 
	(Fields!Liquid_assets.Value,"Coefficients"),
	(Fields!bancacc.Value,"Coefficients"),
	(Fields!accfl.Value,"Coefficients"),
	(Fields!acccorp.Value,"Coefficients"),
	(Fields!E296.Value, "zabalans"),
	(Fields!E305.Value, "zabalans"),

      'Current_liquidity', 
      /*Текущая ликвидность*/ --10
      isnull(slg.[2],0) AS '2_2',
      isnull(slg.[3],0) AS '3_2',
      isnull(slg.[4],0) AS '4_3',
      isnull(slg.[9],0) AS '9',
      isnull(slg.[10],0) AS '10_3',
      isnull(slg.[61],0) AS '61',
      isnull(slg.[54],0) AS '54_2',
      isnull(slg.[55],0) AS '55',
      isnull(slg.[56],0) AS '56',
      isnull(slg.[59],0) AS '59',
	  
 
      'Current_liquidity_MBK',
      /*Текущая ликвидность за вычетом МБК*/ --11
	  isnull(slg.[2],0) AS '2_3',
      isnull(slg.[3],0) AS '3_3',
      isnull(slg.[4],0) AS '4_4',
      isnull(slg.[9],0) AS '9_1',
      isnull(slg.[41],0) AS '41',
	  isnull(slg.[10],0) AS '10_4',
      isnull(slg.[61],0) AS '61_1',
      isnull(slg.[54],0) AS '54_3',
      isnull(slg.[55],0) AS '55_1',
      isnull(slg.[56],0) AS '56_1',
      isnull(slg.[59],0) AS '59_1',
      isnull(slg.[52],0) AS '52',
	  
      'Saldo_interb_tran_Assets',
      /*Сальдо межбанковских операций на дату / Активы*/ --12
      isnull(slg.[9],0) AS '9_2',
      isnull(slg.[41],0) AS '41_2',
      isnull(slg.[34],0) AS '34',

      'Profit_assets',
       /*Доходность активов*/ --13
      isnull(slg.[63],0) AS '63',
      isnull(slg.[69],0) AS '69_4',
	  isnull(slg.[D169],0) AS 'D169',
       'Profit_capital',
       /*Доходность капитала*/   --14
      isnull(slg.[63],0) AS '63_1',		   
	  isnull(slg.[64],0) AS '64',
      isnull(slg.[65],0) AS '65',
      isnull(slg.[66],0) AS '66',
	  isnull(slg.[D169],0) AS 'D169_1',
      reportdate,
      EDRPOU
FROM #consolidated_balance_FCY AS slg
ORDER BY reportdate,
         EDRPOU;
END
