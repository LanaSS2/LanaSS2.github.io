USE [Detail]
GO

/****** Object:  StoredProcedure [dbo].[Report_Priority_v2]    Script Date: 07/04/2017 16:17:44 ******/
---SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 ALTER procedure [dbo].[Report_Priority_v2]
       @method  int
      ,@DateFrom date 
      ,@DateTo  date 
      ,@contract nvarchar(100) 
      ,@department_no varchar(max)='%|CEH1|%'     
as
begin
--declare  @QtyRoutStructFact varchar(20)
--declare  @QtyRoutStructPlan varchar(20) 			             
--declare  @t_Report_Priority_RoutCost table varchar(20)  
--declare  @t_Report_Priority_Cost_110Cost varchar(20) 
 declare 
      -- @DateFrom date /*= DateAdd(m,-1,DateAdd(d,1-Day(getdate()),getdate()))*/
      --,@DateTo  date  /*=  DateAdd(d,0-Day(getdate()),getdate())*/
       @YEAR_FROM  nvarchar(4) /*= Year(DateAdd(d,0-Day(@DateFrom),@DateFrom)) */--need  convert
      ,@YEAR_TO  nvarchar(4)  /* = Year(DateAdd(d,0-Day(@DateTo),@DateTo))*/	--need  convert
      ,@PERIOD_FROM nvarchar(2)/* = Month(@DateFrom)*/						--need  convert
      ,@PERIOD_TO  nvarchar(2)  /*= Month(@DateTo)	*/						--need  convert 
    --  ,@contract nvarchar(10)   
     -- ,@department_no nvarchar(max)   
      ,@QueryText   varchar(MAX)
declare	 
     @YEAR_FROM_str nvarchar(4) = convert(nvarchar(4),@YEAR_FROM,112)
    ,@YEAR_TO_str nvarchar(4) = convert(nvarchar(4),@YEAR_TO,112)
    ,@PERIOD_FROM_str nvarchar(2) = convert(nvarchar(2),@PERIOD_FROM,112)
    ,@PERIOD_TO_str nvarchar(2) = convert(nvarchar(2),@PERIOD_TO,112)   
    ,@Date_FROM_str nvarchar(8) = convert(nvarchar(8),@DateFrom,112)
    ,@Date_To_str nvarchar(8) = convert(nvarchar(8),@DateTo,112)
	,@linkedserver  nvarchar(25) = 'PROD75'   
	
if @method=1 
begin
    set nocount on
set    @DateFrom  = DateAdd(m,-1,DateAdd(d,1-Day(getdate()),getdate()))
set    @DateTo  = DateAdd(d,0-Day(getdate()),getdate())
set    @YEAR_FROM  = Year(DateAdd(d,0-Day(@DateFrom),@DateFrom))           
set    @YEAR_TO    = Year(DateAdd(d,0-Day(@DateTo),@DateTo))	
set    @PERIOD_FROM = Month(@DateFrom)						
set    @PERIOD_TO   = Month(@DateTo)
set	   @contract ='02'''',''''09'''',''''16'''',''''17'
--set	   @department_no ='CEH1'
                                        
 set  @YEAR_FROM_str = convert(nvarchar(4),@YEAR_FROM,112)
 set  @YEAR_TO_str = convert(nvarchar(4),@YEAR_TO,112)
 set  @PERIOD_FROM_str  = convert(nvarchar(2),@PERIOD_FROM,112)
 set  @PERIOD_TO_str = convert(nvarchar(2),@PERIOD_TO,112)   
 set  @Date_FROM_str  = convert(nvarchar(8),@DateFrom,112)
 set  @Date_To_str  = convert(nvarchar(8),@DateTo,112)   
                                                                  
--Create table t_Report_Priority_QtyRoutStructFact (insert_date datetime,A_F_type nvarchar(10),qty_fact float,contract_f nvarchar(10),department_no nvarchar(20),A_F_alternative nvarchar(10),
--alternative_description nvarchar(100),A_F_PART_NO nvarchar(100), part_description nvarchar(100),eng_chg_level nvarchar(10),year_period_f nvarchar(10),period_no_f nvarchar(10))
  
--Create table t_Report_Priority_QtyRoutStructPlan (insert_date datetime,A_P_type nvarchar(10),version_no nvarchar(10),contract_p nvarchar(10),A_P_PART_NO nvarchar(100),
--				part_description nvarchar(100),year_period_p nvarchar(10), period_no_p nvarchar(10), 
--				eng_chg_level nvarchar(10),A_P_alternative nvarchar(10),qty_plan float,rn int)						
																
-- Create table t_Report_Priority_RoutCost (insert_date datetime,LaborCost float,contract_f nvarchar(10),PART_NO nvarchar(100),routing_alternative nvarchar(10),year_period nvarchar(10),period_no nvarchar(10))
 
-- Create table t_Report_Priority_Cost_110Cost(insert_date datetime,rowtype nvarchar(10), C_All float, cost_star float, cost_buck float, contract_f nvarchar(10),department_no nvarchar(20),PART_NO nvarchar(100),eng_chg_level nvarchar(10),
--structure_alternative nvarchar(10),year_period nvarchar(10),period_no nvarchar(10))


/*[insert_date] [datetime] NULL*/

truncate table t_Report_Priority_QtyRoutStructFact
truncate table t_Report_Priority_QtyRoutStructPlan 
truncate table t_Report_Priority_RoutCost
truncate table t_Report_Priority_Cost_110Cost
end
 
if @method=2
begin
set    @YEAR_FROM  = Year(DateAdd(d,0-Day(@DateFrom),@DateFrom)) 
set    @YEAR_TO    = Year(DateAdd(d,0-Day(@DateTo),@DateTo))	
set    @PERIOD_FROM = Month(@DateFrom)						
set    @PERIOD_TO   = Month(@DateTo)     
--set	   @contract ='02'  
--set	   @department_no ='CEH1'

 set  @YEAR_FROM_str = convert(nvarchar(4),@YEAR_FROM,112)
 set  @YEAR_TO_str = convert(nvarchar(4),@YEAR_TO,112)
 set  @PERIOD_FROM_str  = convert(nvarchar(2),@PERIOD_FROM,112)
 set  @PERIOD_TO_str = convert(nvarchar(2),@PERIOD_TO,112)   
 set  @Date_FROM_str  = convert(nvarchar(8),@DateFrom,112)
 set  @Date_To_str  = convert(nvarchar(8),@DateTo,112)  
 
	   --set    @QtyRoutStructFact='#QtyRoutStructFact'
Create table #QtyRoutStructFact (insert_date datetime,A_F_type nvarchar(10),qty_fact float,contract_f nvarchar(10),department_no nvarchar(20),A_F_alternative nvarchar(10),alternative_description nvarchar(100),A_F_PART_NO nvarchar(100),
								 part_description nvarchar(100),eng_chg_level nvarchar(10),year_period_f nvarchar(10),period_no_f nvarchar(10))

Create table #QtyRoutStructPlan (insert_date datetime,A_P_type nvarchar(10),version_no nvarchar(10),contract_p nvarchar(10),A_P_PART_NO nvarchar(100),
				part_description nvarchar(100),year_period_p nvarchar(10),period_no_p nvarchar(10),eng_chg_level nvarchar(10), 
				A_P_alternative nvarchar(10),qty_plan float,rn int)																						
Create table #RoutCost (insert_date datetime,LaborCost float, contract_f nvarchar(10),PART_NO nvarchar(100),routing_alternative nvarchar(10),year_period nvarchar(10),period_no nvarchar(10))
Create table #Cost_110Cost (insert_date datetime,rowtype nvarchar(10), C_All float, cost_star float, cost_buck float, contract_f nvarchar(10),department_no nvarchar(20),PART_NO nvarchar(100),
							structure_alternative nvarchar(10),eng_chg_level nvarchar(10),year_period nvarchar(10),period_no nvarchar(10))
end
/*+*//* ~min 4*/
---/*INSERT INTO  '+ @QtyRoutStructFact +' (A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,year_period_f,period_no_f)*/
set @QueryText = 'select getdate(),''rout'' as AF_type,* from OpenQuery('+@linkedserver+',''select round(sum(case ii.TRANSACTION_CODE when ''''OOREC'''' 
then nvl(ii.quantity,0) when ''''SUNREC'''' then -1*nvl(ii.quantity,0) end),10) as qty_fact,ii.contract as contract_f,wc.department_no as department_no,ii.Routing_alternative as A_F_alternative
,ra.alternative_description as alternative_description
,ii.PART_NO as A_F_PART_NO
,ip.description	as part_description
,null as eng_chg_level
,EXTRACT(YEAR FROM ii.DATE_APPLIED)	as year_period_f
,EXTRACT(MONTH FROM ii.DATE_APPLIED) as period_no_f
from (select ith.TRANSACTION_CODE,ith.quantity,ith.contract,so.Routing_alternative,ith.PART_NO,ith.DATE_APPLIED,ith.release_no,ith.sequence_no,ith.order_no,so.routing_revision
      from ifsapp.inventory_transaction_hist ith 
      inner join ifsapp.SHOP_ORD so on 1=1 and ith.contract in (''''02'''',''''16'''',''''09'''',''''17'''')
      and ith.TRANSACTION_CODE in (''''OOREC'''',''''SUNREC'''') 
      and ith.ORDER_TYPE_DB=''''SHOP ORDER''''
      and ith.DATE_APPLIED between to_date(''''' + CONVERT(varchar(8),@DateFrom,112) + ''''',''''YYYYMMDD'''') and to_date(''''' + CONVERT(varchar(8),@DateTo,112) + ''''',''''YYYYMMDD'''')
      and so.PART_NO=ith.PART_NO 
      and so.CONTRACT=ith.CONTRACT 
      and so.ORDER_NO=ith.ORDER_NO 
      and so.RELEASE_NO=ith.RELEASE_NO 
      and so.SEQUENCE_NO=ith.SEQUENCE_NO 
      and so.contract in (''''02'''',''''16'''',''''09'''',''''17'''')) ii
join IFSAPP.SHOP_ORDER_OPERATION soo 
    on ii.order_no=soo.order_no 
      and ii.release_no=soo.release_no 
      and ii.sequence_no=soo.sequence_no 
      and ii.contract=soo.contract 
      and ii.part_no=soo.part_no 
      and soo.OPERATION_NO=(select min(soo1.OPERATION_NO) from IFSAPP.SHOP_ORDER_OPERATION soo1 where soo1.order_no=soo.order_no and soo1.release_no=soo.release_no and soo1.sequence_no=soo.sequence_no and soo1.contract=soo.contract and soo1.part_no=soo.part_no) 
join IFSAPP.ROUTING_ALTERNATE ra 
    on ra.contract=ii.contract 
    and ra.part_no=ii.part_no 
    and ra.routing_revision=ii.routing_revision 
    and ra.alternative_no=ii.Routing_alternative 
    and ra.bom_type_db=''''M''''
    and ra.objstate=''''Buildable'''' 
join IFSAPP.Work_Center wc 
      on soo.work_center_no=wc.work_center_no 
      and soo.contract=wc.contract 
      and wc.department_no is not null 
left join IFSAPP.INVENTORY_PART ip 
    on ii.contract=ip.contract 
    and ii.part_no=ip.part_no 
group by ii.contract,wc.department_no,ii.Routing_alternative,ra.alternative_description,ii.PART_NO,ip.description,EXTRACT(YEAR FROM ii.DATE_APPLIED),EXTRACT(MONTH FROM ii.DATE_APPLIED)'')'
									 
if @method=1 
begin  	
INSERT INTO  t_Report_Priority_QtyRoutStructFact(insert_date,A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f)
-- SELECT A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f
--from  t_Report_Priority_QtyRoutStructFact  
exec (@QueryText)
end	
--else
if @method=2
begin
INSERT INTO  #QtyRoutStructFact(insert_date,A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f)
--SELECT A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f
--	from  #QtyRoutStructFact 
exec (@QueryText)
end
  
--/*+  min 1 */
set @QueryText = 'select getdate(),''struc'' as AF_type,* from OpenQuery('+@linkedserver+', '' 
   select  round(sum (case ii.TRANSACTION_CODE when ''''OOREC'''' then nvl(ii.quantity,0) when ''''SUNREC'''' then -1*nvl(ii.quantity,0) end),10) as qty_fact
,ii.contract as contract_f
,wc.department_no as department_no
,ii.structure_alternative as A_F_alternative
,psa.ALTERNATIVE_DESCRIPTION as alternative_description
,ii.PART_NO as A_F_PART_NO
,ip.description as part_description
,ii.eng_chg_level
,EXTRACT(YEAR FROM ii.DATE_APPLIED) as year_period_f
,EXTRACT(MONTH FROM ii.DATE_APPLIED)as period_no_f
from (select ith.TRANSACTION_CODE,ith.quantity,ith.contract,so.structure_alternative,ith.PART_NO,ith.DATE_APPLIED,ith.release_no,ith.sequence_no,ith.order_no,so.eng_chg_level
      from ifsapp.inventory_transaction_hist ith 
      inner join ifsapp.SHOP_ORD so 
      on 1=1 and ith.contract in (''''02'''',''''16'''',''''09'''',''''17'''') 
      and ith.TRANSACTION_CODE in (''''OOREC'''',''''SUNREC'''') 
      and ith.ORDER_TYPE_DB=''''SHOP ORDER''''
      and ith.DATE_APPLIED between to_date(''''' + CONVERT(varchar(8),@DateFrom,112) + ''''',''''YYYYMMDD'''') and to_date(''''' + CONVERT(varchar(8),@DateTo,112) + ''''',''''YYYYMMDD'''')
      and so.PART_NO=ith.PART_NO 
      and so.CONTRACT=ith.CONTRACT 
      and so.ORDER_NO=ith.ORDER_NO 
      and so.RELEASE_NO=ith.RELEASE_NO 
      and so.SEQUENCE_NO=ith.SEQUENCE_NO 
      and so.contract in (''''02'''',''''16'''',''''09'''',''''17'''')) ii
join IFSAPP.SHOP_ORDER_OPERATION soo 
     on ii.order_no=soo.order_no 
      and ii.release_no=soo.release_no 
      and ii.sequence_no=soo.sequence_no 
      and ii.contract=soo.contract 
      and ii.part_no=soo.part_no 
      and soo.OPERATION_NO=(select min(soo1.OPERATION_NO) from IFSAPP.SHOP_ORDER_OPERATION soo1 where soo1.order_no=soo.order_no and soo1.release_no=soo.release_no and soo1.sequence_no=soo.sequence_no and soo1.contract=soo.contract and soo1.part_no=soo.part_no) 
join IFSAPP.PROD_STRUCT_ALTERNATE psa on psa.contract = ii.contract
                     and psa.part_no = ii.part_no and psa.eng_chg_level = ii.eng_chg_level
                     and psa.alternative_no = ii.structure_alternative
                     and psa.bom_type_db=''''M'''' and psa.objstate =''''Buildable''''     
join IFSAPP.Work_Center wc 
      on soo.work_center_no=wc.work_center_no 
      and soo.contract=wc.contract 
      and wc.department_no is not null 
left join IFSAPP.INVENTORY_PART ip 
    on ii.contract=ip.contract 
    and ii.part_no=ip.part_no 
group by ii.contract,wc.department_no,ii.structure_alternative,psa.alternative_description,ii.PART_NO,ii.eng_chg_level,ip.description,EXTRACT(YEAR FROM ii.DATE_APPLIED),EXTRACT(MONTH FROM ii.DATE_APPLIED) '')'

if @method=1 
begin  	
INSERT INTO  t_Report_Priority_QtyRoutStructFact(insert_date,A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f)
-- SELECT A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f
--from  t_Report_Priority_QtyRoutStructFact  
exec (@QueryText)
end	

if @method=2
begin
INSERT INTO  #QtyRoutStructFact(insert_date,A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f)
--SELECT A_F_type,qty_fact,contract_f,department_no,A_F_alternative,alternative_description,A_F_PART_NO,part_description,eng_chg_level,year_period_f,period_no_f
--	from  #QtyRoutStructFact 
exec (@QueryText)
end
	
--		/*+*//* ~min 1*/
	set @QueryText = 'select getdate(),''rout'' AP_type,* from OpenQuery('+@linkedserver+','' 
						select * from (select L2.version_no,L2.contract contract_p,L2.part_no A_P_PART_NO,L2.part_desc  part_description,L2.year_period year_period_p,L2.period_no  period_no_p,                                 
                                   null as eng_chg_level,pab.alternative_no A_P_alternative,round(pab.planned_qty,10) qty_plan,
                                   ROW_NUMBER()OVER(PARTITION BY L2.part_no,L2.year_period,L2.period_no ORDER BY pab.alternative_no) rn
                            FROM (SELECT L1.version_no,L1.contract,L1.part_no,L1.year_period,L1.period_no,L1.production_line,L1.production_line_desc,L1.part_desc,
                                         L1.planned_qty,ipc.attr_value inapl_attr
                                  FROM (SELECT pp.version_no,pp.contract,ppp.part_no,ppp.year_period,ppp.period_no,plp.production_line,
                                               pl.description production_line_desc,ip.description part_desc,SUM(nvl(ppp.planned_qty,0)) planned_qty
                                        FROM IFSAPP.UA_PRODUCTION_PLAN pp,IFSAPP.UA_PROD_PLAN_PART ppp,IFSAPP.PRODUCTION_LINE_PART plp,IFSAPP.PRODUCTION_LINE pl,IFSAPP.INVENTORY_PART ip
                                    ,(select extract(year from add_months (TO_DATE('''''+@Date_FROM_str+''''',''''YYYYMMDD''''), level-1)) y
									,extract(month from add_months (TO_DATE('''''+@Date_From_str+''''',''''YYYYMMDD''''), level-1))  m 
									from dual connect by level< =  MONTHS_BETWEEN(TO_DATE('''''+@Date_To_str+''''',''''YYYYMMDD''''),TO_DATE('''''+@Date_FROM_str+''''',''''YYYYMMDD''''))+1) d
                                   WHERE ip.contract=pp.contract         
                                   AND pp.date_start =TO_DATE('''''+@Date_FROM_str+''''',''''YYYYMMDD'''') 
                                   AND ppp.year_period  = d.y AND ppp.period_no = d.m AND pp.objstate in(''''Smoothed'''' ,''''Calculated'''' ,''''Approved'''') AND UPPER(pp.note) like ''''%рейсыхи%''''
                                              AND ppp.version_no=pp.version_no
                                              AND ppp.part_no=ip.part_no                                             
                                              AND pl.contract=pp.contract
                                              AND plp.contract=pl.contract
                                              AND plp.production_line=pl.production_line
                                              AND plp.part_no=ppp.part_no
                                        GROUP BY pp.version_no,
                                                 pp.contract,
                                                 ppp.part_no,
                                                 ppp.year_period,
                                                 ppp.period_no,
                                                 plp.production_line,
                                                 pl.description,
                                                 ip.description) L1,
                                       IFSAPP.INVENTORY_PART_CHAR_ALL ipc
                                  WHERE ipc.characteristic_code=''''INAPL''''
                                        AND ipc.contract=L1.contract
                                        AND ipc.part_no=L1.part_no) L2,
                                 IFSAPP.UA_PLAN_ALTER_BASE pab
                            WHERE pab.version_no=L2.version_no
                                  AND pab.year_period=L2.year_period
                                  AND pab.period_no=L2.period_no
                                  AND pab.contract=L2.contract
                                  AND pab.part_no=L2.part_no)where rn=1 '')'

if @method=1 
begin  	
INSERT INTO  t_Report_Priority_QtyRoutStructPlan(insert_date,A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn)
-- 			SELECT A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn
--from t_Report_Priority_QtyRoutStructPlan 
exec (@QueryText)
end	

if @method=2
begin
INSERT INTO  #QtyRoutStructPlan(insert_date,A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn)
-- 			SELECT A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn
--from #QtyRoutStructPlan 
exec (@QueryText)
end
		
--		/*+*//* ~min 2*/
if @method=1 
	set @QueryText='select getdate(),''struc'' AP_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,null as eng_chg_level,''*'' as A_P_alternative,round(convert(float,QTY_PLAN),10) as qty_plan,rn from OpenQuery('+@linkedserver+',''     
				select * from (select L2.version_no,L2.contract contract_p,L2.part_no A_P_PART_NO,L2.part_desc part_description,L2.year_period year_period_p,L2.period_no period_no_p,round(pab.planned_qty,10) qty_plan,      
                        ROW_NUMBER()OVER(PARTITION BY L2.part_no,L2.year_period,L2.period_no ORDER BY pab.routing_revision,pab.alternative_no) rn
                 FROM (SELECT L1.version_no,
                              L1.contract,
                              L1.part_no,
                              L1.year_period,
                              L1.period_no,
                              L1.production_line,
                              L1.production_line_desc,
                              L1.part_desc,
                              L1.planned_qty,
                              ipc.attr_value inapl_attr
                       FROM (SELECT pp.version_no,
                                    pp.contract,
                                    ppp.part_no,
                                    ppp.year_period,
                                    ppp.period_no,
                                    plp.production_line,
                                    pl.description production_line_desc,
                                    ip.description part_desc,
                                    SUM(nvl(ppp.planned_qty,0)) planned_qty
                             FROM IFSAPP.UA_PRODUCTION_PLAN   pp,
                                  IFSAPP.UA_PROD_PLAN_PART    ppp,
                                  IFSAPP.PRODUCTION_LINE_PART plp,
                                  IFSAPP.PRODUCTION_LINE      pl,
                                  IFSAPP.INVENTORY_PART       ip
                                  ,(select extract(year from add_months (TO_DATE('''''+@Date_FROM_str+''''',''''YYYYMMDD''''),level-1)) y
									,extract(month from add_months (TO_DATE('''''+@Date_From_str+''''',''''YYYYMMDD''''),level-1))  m 
									from dual connect by level< =  MONTHS_BETWEEN(TO_DATE('''''+@Date_To_str+''''',''''YYYYMMDD''''),TO_DATE('''''+@Date_FROM_str+''''',''''YYYYMMDD''''))+1 ) d
                                   WHERE ip.contract=pp.contract         
                                   AND pp.date_start =TO_DATE('''''+@Date_FROM_str+''''',''''YYYYMMDD'''') 
                                   AND ppp.year_period  = d.y AND ppp.period_no = d.m AND pp.objstate in(''''Smoothed'''' ,''''Calculated'''',''''Approved'''') AND UPPER(pp.note) like ''''%рейсыхи%''''
                                   AND ppp.version_no=pp.version_no AND ppp.part_no=ip.part_no AND pl.contract=pp.contract AND plp.contract=pl.contract AND plp.production_line=pl.production_line AND plp.part_no=ppp.part_no
                             GROUP BY pp.version_no, pp.contract,ppp.part_no,ppp.year_period,ppp.period_no,plp.production_line,pl.description,ip.description) L1,
                            IFSAPP.INVENTORY_PART_CHAR_ALL ipc
                       WHERE ipc.characteristic_code=''''INAPL''''
                             AND ipc.contract=L1.contract
                             AND ipc.part_no=L1.part_no) L2,
                      IFSAPP.UA_PLAN_ALTER_BASE pab
                 WHERE pab.version_no=L2.version_no
                       AND pab.year_period=L2.year_period
                       AND pab.period_no=L2.period_no
                       AND pab.contract=L2.contract
                       AND pab.part_no=L2.part_no)where rn=1 '')'		
	
if @method=1 
begin  	
INSERT INTO  t_Report_Priority_QtyRoutStructPlan(insert_date,A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn)
-- 			SELECT A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn
--from t_Report_Priority_QtyRoutStructPlan 
exec 	(@QueryText)
end	

if @method=2
begin
INSERT INTO  #QtyRoutStructPlan(insert_date,A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn)
-- 			SELECT A_P_type,version_no,contract_p,A_P_PART_NO,part_description,year_period_p,period_no_p,eng_chg_level,A_P_alternative,qty_plan,rn
--from #QtyRoutStructPlan 
exec 	(@QueryText)
end
		
--	/*+*//* ~min 2*/
	set @QueryText = 'select getdate(),* from OpenQuery('+@linkedserver+',''
	  SELECT (nvl(x.RoutNotStar,0)-nvl(x.RoutStar,0)) LaborCost,
                  x.contract,
                  x.part_no,                  
                  x.Routing_alternative,
                  x.year_period,
                  x.period_no  
           from (SELECT (SELECT round(SUM((labor_setup_time+labor_run_factor)*ro.crew_size*labor_class_rate),10) AltStar
                         FROM ifsapp.routing_operation ro,
                              ifsapp.labor_class_cost lcr
                         WHERE ro.alternative_no=''''*''''
                               AND ro.part_no=so.part_no
                               AND ro.contract=so.contract
                               AND ro.routing_revision=so.routing_revision
                               AND ro.contract=lcr.contract
                               AND ro.labor_class_no=lcr.labor_class_no
                               AND lcr.cost_set=''''2''''
                               AND so.need_date BETWEEN lcr.start_date AND
                               lcr.end_date) RoutStar,                                
                      (SELECT round(SUM((labor_setup_time + labor_run_factor) *
                                    ro.crew_size * labor_class_rate),10) as FactAlt
                         FROM ifsapp.routing_operation ro,
                              ifsapp.labor_class_cost  lcr
                         WHERE ro.alternative_no=so.Routing_alternative
                               AND ro.part_no=so.part_no
                               AND ro.contract=so.contract
                               AND ro.routing_revision=so.routing_revision
                               AND ro.contract=lcr.contract
                               AND ro.labor_class_no=lcr.labor_class_no
                               AND lcr.cost_set=''''2''''
                               AND so.need_date BETWEEN lcr.start_date AND
                               lcr.end_date) RoutNotStar,
                        so.contract,
                        so.part_no,
                        so.Routing_alternative,
                        EXTRACT(YEAR FROM so.need_date) year_period,
                        EXTRACT(MONTH FROM so.need_date) period_no 
                 FROM ifsapp.shop_ord so
                 WHERE  so.need_date between to_date(''''' + CONVERT(varchar(8),@DateFrom,112) + ''''',''''YYYYMMDD'''') and to_date(''''' + CONVERT(varchar(8),@DateTo,112) + ''''',''''YYYYMMDD'''') 
                        and so.contract in (''''02'''',''''16'''',''''09'''',''''17'''')) x    where 1=1
           group by x.RoutNotStar,
                    x.RoutStar,
                    x.contract,
                    x.part_no,                  
                    x.Routing_alternative,
                    x.year_period,
                    x.period_no  '')'

if @method=1 
begin  	
INSERT INTO  t_Report_Priority_RoutCost(insert_date,LaborCost,contract_f,PART_NO,routing_alternative,year_period,period_no)
-- 			SELECT LaborCost,contract_f,PART_NO,routing_alternative,year_period,period_no
--from t_Report_Priority_RoutCost 
exec (@QueryText)
end	

if @method=2
begin
INSERT INTO  #RoutCost(insert_date,LaborCost,contract_f,PART_NO,routing_alternative,year_period,period_no)
-- 			SELECT LaborCost,contract_f,PART_NO,routing_alternative,year_period,period_no
--from #RoutCost

exec (@QueryText)
end
	
--/*+*//* ~min 2*/	


set @QueryText='select getdate(),''all'' as rowtype,C_All,0 as cost_star,round(convert(float,cost_buck),10) as cost_buck,contract_f,department_no,part_no,eng_chg_level,structure_alternative,year_period,period_no
from OpenQuery('+@linkedserver+',''
	select round(nvl(C_All.C_All,0),10) C_All,round(nvl(C_St_Buck.C_St_Buck,0),10) cost_buck,C_All.contract_f,
C_All.department_no,C_All.PART_NO,C_All.eng_chg_level,C_All.structure_alternative,C_All.year_period,C_All.period_no
	FROM (select sum(nvl(ii.unit_cost,0)*nvl(ii.quantity,0)) C_All,ii.contract contract_f,wc.department_no,ii.PART_NO,ii.eng_chg_level,ii.Structure_alternative,
EXTRACT(YEAR FROM ii.DATE_APPLIED) year_period,EXTRACT(MONTH FROM ii.DATE_APPLIED) period_no
	from(select ith.TRANSACTION_CODE,ith.quantity,ith.contract,so.Structure_alternative,ith.PART_NO,so.eng_chg_level,ith.DATE_APPLIED,ith.release_no,ith.sequence_no,ith.order_no,ith.transaction_id,itc.unit_cost
	FROM ifsapp.inventory_transaction_hist ith
    inner join ifsapp.inventory_transaction_cost itc
on 1=1 and ith.contract in (''''02'''',''''16'''',''''09'''',''''17'''')
and ith.TRANSACTION_CODE in (''''OOREC'''',''''SUNREC'''')
and ith.ORDER_TYPE_DB=''''SHOP ORDER''''
and ith.DATE_APPLIED between to_date('''''+ CONVERT(varchar(8),@DateFrom,112)+''''',''''YYYYMMDD'''') and to_date('''''+ CONVERT(varchar(8),@DateTo,112)+''''',''''YYYYMMDD'''') 
and itc.cost_bucket_id=''''110''''
and ith.transaction_id=itc.transaction_id
	INNER JOIN ifsapp.SHOP_ORD so
on 1=1 and so.PART_NO=ith.PART_NO
and so.CONTRACT=ith.CONTRACT
and so.ORDER_NO=ith.ORDER_NO
and so.RELEASE_NO=ith.RELEASE_NO
and so.SEQUENCE_NO=ith.SEQUENCE_NO) ii
	JOIN IFSAPP.SHOP_ORDER_OPERATION soo
on ii.order_no=soo.order_no
and ii.release_no=soo.release_no
and ii.sequence_no=soo.sequence_no
and ii.contract=soo.contract
and ii.part_no=soo.part_no
and soo.OPERATION_NO=(select min(soo1.OPERATION_NO)from IFSAPP.SHOP_ORDER_OPERATION soo1
WHERE soo1.order_no=soo.order_no
and soo1.release_no=soo.release_no
and soo1.sequence_no=soo.sequence_no
and soo1.contract=soo.contract
and soo1.part_no=soo.part_no)
	JOIN IFSAPP.Work_Center wc
on soo.work_center_no=wc.work_center_no
and soo.contract=wc.contract
and wc.department_no is not null
GROUP BY ii.contract,wc.department_no,ii.part_no,ii.eng_chg_level,ii.Structure_alternative,EXTRACT(YEAR FROM ii.date_applied),EXTRACT(MONTH FROM ii.date_applied))C_All
	LEFT JOIN (SELECT nvl((SELECT NVL(pcb.bucket_accum_cost,0)
FROM ifsapp.part_cost_bucket pcb
WHERE pcb.part_no=k.part_no
AND pcb.contract=k.contract_f
AND pcb.cost_set=''''6''''
AND pcb.cost_bucket_id=''''110''''
AND pcb.alternative_no=''''*''''
AND ROWNUM=1),0) C_St_Buck,
k.contract_f,k.part_no,k.eng_chg_level,
EXTRACT(YEAR FROM k.date_applied) year_period,
EXTRACT(MONTH FROM k.date_applied) period_no
FROM(SELECT ith.contract contract_f,ith.part_no,so.eng_chg_level,TRUNC(ith.date_applied,''''mm'''') date_applied
FROM ifsapp.inventory_transaction_hist ith
	INNER JOIN ifsapp.shop_ord so
ON 1=1 and so.part_no=ith.part_no
AND so.contract=ith.contract
AND so.order_no=ith.order_no
AND so.release_no=ith.release_no
AND so.sequence_no=ith.sequence_no
AND ith.transaction_code IN(''''OOREC'''',''''SUNREC'''')
AND ith.contract in (''''02'''',''''16'''',''''09'''',''''17'''')
AND ith.order_type_db=''''SHOP ORDER''''
and ith.DATE_APPLIED between to_date('''''+ CONVERT(varchar(8),@DateFrom,112)+''''',''''YYYYMMDD'''') and to_date('''''+ CONVERT(varchar(8),@DateTo,112)+''''',''''YYYYMMDD'''') 
join IFSAPP.PROD_STRUCT_ALTERNATE psa on so.contract=psa.contract and so.part_no=psa.part_no and so.eng_chg_level=psa.eng_chg_level and so.structure_alternative=psa.alternative_no
and psa.objstate=''''Buildable''''
GROUP BY ith.contract,ith.part_no,so.eng_chg_level,TRUNC(ith.date_applied,''''mm''''))k) C_St_Buck
on C_All.contract_f=C_St_Buck.contract_f
and C_All.PART_NO=C_St_Buck.PART_NO and C_All.eng_chg_level=C_St_Buck.eng_chg_level
and C_All.year_period=C_St_Buck.year_period
and C_All.period_no=C_St_Buck.period_no '')'

if @method=1 
begin  	
INSERT INTO  t_Report_Priority_Cost_110Cost(insert_date,rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no)
-- 			SELECT rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no 
--from t_Report_Priority_Cost_110Cost
exec (@QueryText)
end	

if @method=2
begin
INSERT INTO  #Cost_110Cost(insert_date,rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no)
-- 			SELECT rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no 
--from #Cost_110Cost
exec (@QueryText)
end
		
--	/* 5 min*/		
		set @QueryText = 'select getdate(),''star'' as rowtype,convert(float,0.0) as C_All,round(CONVERT(float,cost_star),10) as cost_star,convert(float,0.0) as cost_buck,contract as contract_f,department_no,part_no,eng_chg_level,''*'' as structure_alternative,year_period, period_no
       from OpenQuery('+@linkedserver+', ''
	   select round(MAX(NVL(ii.unit_cost,0)),10) cost_star,
       ii.contract,wc.department_no,ii.PART_NO,ii.eng_chg_level,
       EXTRACT(YEAR FROM ii.date_applied) year_period,
       EXTRACT(MONTH FROM ii.date_applied) period_no
FROM (select ith.TRANSACTION_CODE, ith.contract, so.structure_alternative,ith.PART_NO,ith.DATE_APPLIED,ith.release_no, ith.sequence_no, ith.order_no,so.eng_chg_level,ith.transaction_id,itc.unit_cost
      from ifsapp.inventory_transaction_hist ith 
		inner join ifsapp.inventory_transaction_cost itc
			on 1=1 and ith.contract in (''''02'''',''''16'''',''''09'''',''''17'''')
			and ith.TRANSACTION_CODE in (''''OOREC'''',''''SUNREC'''')
			and ith.ORDER_TYPE_DB=''''SHOP ORDER''''
			and ith.DATE_APPLIED between to_date('''''+ CONVERT(varchar(8),@DateFrom,112)+''''',''''YYYYMMDD'''') and to_date('''''+ CONVERT(varchar(8),@DateTo,112)+''''',''''YYYYMMDD'''') 
			and itc.cost_bucket_id=''''110''''
			and ith.transaction_id=itc.transaction_id
		INNER JOIN ifsapp.SHOP_ORD so
		on 1=1 and so.PART_NO=ith.PART_NO 
		and so.CONTRACT=ith.CONTRACT 
		and so.ORDER_NO=ith.ORDER_NO 
		and so.RELEASE_NO=ith.RELEASE_NO 
		and so.SEQUENCE_NO=ith.SEQUENCE_NO 
		and so.contract in (''''02'''',''''16'''',''''09'''',''''17'''')) ii
 join IFSAPP.SHOP_ORDER_OPERATION soo 
      on ii.order_no=soo.order_no 
      and ii.release_no=soo.release_no 
      and ii.sequence_no=soo.sequence_no 
      and ii.contract=soo.contract 
      and ii.part_no=soo.part_no 
      and soo.OPERATION_NO=(select min(soo1.OPERATION_NO) from IFSAPP.SHOP_ORDER_OPERATION soo1 
      where soo1.order_no=soo.order_no and soo1.release_no=soo.release_no and soo1.sequence_no=soo.sequence_no and soo1.contract=soo.contract and soo1.part_no=soo.part_no) 
join IFSAPP.Work_Center wc 
      on soo.work_center_no=wc.work_center_no 
      and soo.contract=wc.contract 
      and wc.department_no is not null 
join IFSAPP.PROD_STRUCT_ALTERNATE psa on ii.contract=psa.contract and ii.part_no=psa.part_no and ii.eng_chg_level=psa.eng_chg_level and ii.structure_alternative=psa.alternative_no
and psa.objstate=''''Buildable''''         
WHERE ii.structure_alternative=''''*''''      
GROUP BY ii.contract,wc.department_no,ii.part_no,ii.eng_chg_level,EXTRACT(YEAR FROM ii.date_applied),EXTRACT(MONTH FROM ii.date_applied) '') '
if @method=1 
begin  	
INSERT INTO  t_Report_Priority_Cost_110Cost(insert_date,rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no)
-- 			SELECT rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no 
--from t_Report_Priority_Cost_110Cost
exec (@QueryText)
end	

if @method=2
begin
INSERT INTO  #Cost_110Cost(insert_date,rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no)
-- 			SELECT rowtype,C_All,cost_star,cost_buck,contract_f,department_no,PART_NO,eng_chg_level,structure_alternative,year_period,period_no 
--from #Cost_110Cost
exec (@QueryText)
end



	if @method=2 
begin 
  
  -- set @department_no ='%|' + 'CEH4' + '|%' 
   -- ="|"+Join(Parameters!department_no.Value,"|,|")+"|"
  
select   
       LaborRout.contract_f,
       LaborRout.department_no,
       LaborRout.PART_NO,
       LaborRout.PART_NO_desc,
       LaborRout.Routing_alternative,
       LaborRout.Rout_alternative_description,
       LaborRout.Structure_alternative,
       LaborRout.Struc_ALTERNATIVE_DESCRIPTION,
       LaborRout.Otclon_rout,
       LaborRout.Labor_LaborCost, 
       LaborRout.Otclon_rout_Cost,
       LaborRout.Otclon_struct,
       LaborRout.Otclon_struct_Cost110,
       LaborRout.year_period_f,
       LaborRout.period_no_f,
       LaborRout.version_no      
     from ( 
  select                          
             R.contract_f,
             R.department_no,
             R.R_A_F_PART_NO				PART_NO,
             R.PART_NO_desc,
             R.QtyPlan_PART_NO				Plan_PART_NO,
             R.R_A_F_Routing_alternative	Routing_alternative,
             R.alternative_description		Rout_alternative_description,
             R.QtyPlan_alternative_no		QtyPlan_alternative_no,
             Labor.Routing_alternative		Labor_Routing_alternative,
             isnull(R.otclon_rout,0)		Otclon_rout, 
             isnull(Labor.LaborCost,0)		Labor_LaborCost,
             isnull(R.otclon_rout,0) * isnull(Labor.LaborCost,0) Otclon_rout_Cost, 
             null  Structure_alternative,
             null  Struc_ALTERNATIVE_DESCRIPTION,
             0  Otclon_struct,
             0  Otclon_struct_Cost110,
             R.year_period_f,
             R.period_no_f,
             R.version_no
         
         from (select 
				   Rout.qty_rout_fact,
                   Rout.qty_rout_plan,
                   Rout.sum_qty_rout_plan,
                   Rout.sum_qty_rout_fact,
                   (case when isnull(qty_rout_fact,0)>isnull(qty_rout_plan,0) and
                           (sum_qty_rout_fact-isnull(qty_rout_fact,0))<
                           (sum_qty_rout_plan-isnull(qty_rout_plan,0)) and
                           sum_qty_rout_fact<=sum_qty_rout_plan and
                           R_A_F_Routing_alternative<>'*' then
                     isnull(qty_rout_fact,0)-isnull(qty_rout_plan,0) else null end) as otclon_rout,
                   Rout.contract_f,
                   Rout.department_no,
                   Rout.R_A_F_Routing_alternative,
                   Rout.alternative_description,
                   Rout.QtyPlan_alternative_no,
                   Rout.R_A_F_PART_NO,
                   Rout.PART_NO_desc,
                   Rout.QtyPlan_PART_NO,
                   Rout.year_period_p,
                   Rout.year_period_f,
                   Rout.period_no_p,
                   Rout.version_no,
                   Rout.period_no_f
 
    from (  select       R_A_F.qty_fact						qty_rout_fact,
                         isnull(QtyPlan.qty_plan,0)			qty_rout_plan,
                         sum(isnull(QtyPlan.qty_plan,0)) OVER(PARTITION BY isnull(QtyPlan.A_P_PART_NO, R_A_F.A_F_PART_NO),isnull(QtyPlan.year_period_p,R_A_F.year_period_f),isnull(QtyPlan.period_no_p,R_A_F.period_no_f) )	sum_qty_rout_plan,
                         sum(isnull(R_A_F.qty_fact,0))  OVER(PARTITION BY R_A_F.A_F_PART_NO, R_A_F.year_period_f,R_A_F.period_no_f)			sum_qty_rout_fact,
                         R_A_F.contract_f,
                         QtyPlan.contract_p,
                         R_A_F.department_no,
                         R_A_F.A_F_alternative			R_A_F_Routing_alternative,
                         R_A_F.alternative_description,
                         QtyPlan.A_P_alternative		QtyPlan_alternative_no,
                         R_A_F.A_F_PART_NO				R_A_F_PART_NO,
                         R_A_F.part_description			PART_NO_desc,
                         QtyPlan.A_P_PART_NO			QtyPlan_PART_NO,
                         QtyPlan.year_period_p,
                         R_A_F.year_period_f,
                         QtyPlan.period_no_p,
                         QtyPlan.version_no, 
                         R_A_F.period_no_f  
                         
   from    #QtyRoutStructFact R_A_F

   left  join #QtyRoutStructPlan QtyPlan
					 on	QtyPlan.contract_p = R_A_F.contract_f                    
                     and QtyPlan.A_P_alternative = R_A_F.A_F_alternative	
                     and QtyPlan.A_P_PART_NO = R_A_F.A_F_PART_NO
                     and QtyPlan.year_period_p = R_A_F.year_period_f
                     and QtyPlan.period_no_p = R_A_F.period_no_f
					 and QtyPlan.A_P_type='rout'
					-- and QtyPlan.version_no = @version_no
					 where 1 = 1 and R_A_F.A_F_type='rout')  Rout ) R
					 
   left join    #RoutCost  Labor
         on     R.contract_f = Labor.contract_f
         and R.R_A_F_PART_NO = Labor.part_no        
         and R.R_A_F_Routing_alternative = Labor.routing_alternative
         and R.year_period_f = Labor.year_period
         and R.period_no_f = Labor.period_no
        where 1 = 1 )LaborRout    
        where
      -- LaborRout.Routing_alternative <> '*' and
      LaborRout.Otclon_rout <> '0'
      and LaborRout.Otclon_rout_Cost <> '0'  and 
      LaborRout.contract_f = @contract 
     and @department_no like '%|'+LaborRout.department_no+'|%'
					 and LaborRout.year_period_f between @YEAR_FROM and @YEAR_TO
					 and LaborRout.period_no_f between @PERIOD_FROM and @PERIOD_TO      
   union all
select 
       Struc.contract_f,
       Struc.department_no,
       Struc.PART_NO,
       Struc.PART_NO_desc,
       Struc.routing_alternative,
       Struc.Rout_alternative_description,
       Struc.structure_alternative,
       Struc.Struc_ALTERNATIVE_DESCRIPTION,
       Struc.Otclon_rout,
       Struc.Labor_LaborCost,
       Struc.Otclon_rout_Cost,
       Struc.Otclon_struct,
       Struc.Otclon_struct_Cost110,
       Struc.year_period_f,
       Struc.period_no_f,
       Struc.version_no
       
from (
select D.contract_f		contract_f,
             D.department_no	department_no,
             D.S_A_F_PART_NO	PART_NO,
             D.PART_NO_desc		PART_NO_desc,
             D.QtyPlan_PART_NO	Plan_PART_NO,
             null as			routing_alternative,
             null as			Rout_alternative_description,
             null as			QtyPlan_alternative_no,
             null as			Labor_routing_alternative,
             0 as				Otclon_rout,
             0 as				Labor_LaborCost,
             0 as				Otclon_rout_Cost,
             D.S_A_F_structure_alternative		structure_alternative,
             D.ALTERNATIVE_DESCRIPTION			Struc_ALTERNATIVE_DESCRIPTION,
             D.otclon_struct					Otclon_struct,
             Cost110_110.Cost110					 Cost110,
             Cost110_110.Cost1C_All -  D.otclon_struct * Cost110_110.Cost110    Otclon_struct_Cost110,
             D.year_period_f					year_period_f,
             D.period_no_f						period_no_f,
             D.version_no
      from (select  isnull(S_A_F.qty_fact,0) qty_struct_fact,
                    isnull(QtyPlan.qty_plan,0) qty_struct_plan,
                   (case
                      when  isnull(S_A_F.qty_fact,0) > '0' and
                           S_A_F.A_F_alternative <> '*' then
                        isnull(S_A_F.qty_fact,0)
                      else
                       null
                   end)							otclon_struct,
                    
                   S_A_F.contract_f,
                   QtyPlan.contract_p,
                   S_A_F.department_no,
                   S_A_F.A_F_alternative		S_A_F_structure_alternative,
                   S_A_F.alternative_description,
                   '*' QtyPlan_structure_no,
                   S_A_F.A_F_PART_NO			S_A_F_PART_NO,
                   S_A_F.part_description		PART_NO_desc,
                   QtyPlan.A_P_PART_NO			QtyPlan_PART_NO,
                   QtyPlan.year_period_p,
                   S_A_F.year_period_f,
                   QtyPlan.period_no_p,
                   QtyPlan.version_no,
                   S_A_F.period_no_f
                   
            from   #QtyRoutStructFact S_A_F  
            
             left  join #QtyRoutStructPlan QtyPlan
	            on QtyPlan.contract_p = S_A_F.contract_f
               and QtyPlan.A_P_alternative  = S_A_F.A_F_alternative
               and QtyPlan.A_P_PART_NO = S_A_F.A_F_PART_NO
               and QtyPlan.year_period_p = S_A_F.year_period_f
               and QtyPlan.period_no_p = S_A_F.period_no_f 
			   and QtyPlan.A_P_type='struc' 
			   --and  QtyPlan.version_no=@version_no
	           where 1 = 1 and S_A_F.A_F_type='struc' ) D
	
	 left  join 
	(select
							 isnull(Cost1.C_All,0) as Cost1C_All,
                             isnull(Cost2.cost_star,Cost1.cost_buck) as  Cost110,
                             Cost1.contract_f,
                             Cost1.department_no,
                             Cost1.PART_NO,
                             Cost1.structure_alternative,
                             Cost1.year_period,
                             Cost1.period_no
                             		  
	from #Cost_110Cost  Cost1
   left  join  #Cost_110Cost   Cost2
	on  Cost1.contract_f = Cost2.contract_f  
	and Cost1.PART_NO = Cost2.PART_NO
	and Cost1.year_period = Cost2.year_period 
	and Cost1.period_no = Cost2.period_no
	and Cost2.rowtype = 'star'
	where  1 = 1 and Cost1.rowtype='all'
						group by Cost1.C_All,
                               Cost2.cost_star,
                               Cost1.cost_buck,
                               Cost1.contract_f,
                               Cost1.department_no,
                               Cost1.PART_NO,
                               Cost1.structure_alternative,
                               Cost1.year_period,
                               Cost1.period_no )Cost110_110
	
      on Cost110_110.contract_f = D.contract_f
         and Cost110_110.department_no = D.department_no
         and Cost110_110.PART_NO = D.S_A_F_PART_NO
         and Cost110_110.year_period = D.year_period_f
         and Cost110_110.period_no = D.period_no_f
         and Cost110_110.structure_alternative = D.S_A_F_structure_alternative where 1 = 1 
         ) Struc

      where 
      --Struc.structure_alternative <> '*'  and
          Struc.Otclon_struct <> '0'
        and Struc.Otclon_struct_Cost110 <> '0'	and
       Struc.contract_f=@contract 
       and @department_no like '%|'+Struc.department_no+'|%'
      and Struc.year_period_f between  @YEAR_FROM and @YEAR_TO 
      and  Struc.period_no_f between  @PERIOD_FROM  and @PERIOD_TO
    /*  and Struc.version_no=@version_no*/
         
	DROP TABLE #QtyRoutStructFact
	DROP TABLE #QtyRoutStructPlan
	DROP TABLE #RoutCost
	DROP TABLE #Cost_110Cost  
  end        
     end 

GO


