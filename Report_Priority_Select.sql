USE [Detail]
GO

/****** Object:  StoredProcedure [dbo].[Report_Priority_Select]    Script Date: 07/04/2017 16:16:32 ******/
--SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 ALTER PROCEDURE [dbo].[Report_Priority_Select]
   
	  @YEAR_FROM   nvarchar(4)
	 ,@YEAR_TO     nvarchar(4)
	 ,@PERIOD_FROM nvarchar(2)
	 ,@PERIOD_TO   nvarchar(2)
	 ,@contract    nvarchar(10)
     ,@department_no varchar(max)
     ,@version_no nvarchar(10)

as

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
 
    from (  select       R_A_F.qty_fact					qty_rout_fact,
                         isnull(QtyPlan.qty_plan,0)			qty_rout_plan,
                         sum(isnull(QtyPlan.qty_plan,0)) OVER(PARTITION BY isnull(QtyPlan.A_P_PART_NO, R_A_F.A_F_PART_NO),isnull(QtyPlan.year_period_p,R_A_F.year_period_f),isnull(QtyPlan.period_no_p,R_A_F.period_no_f) )	sum_qty_rout_plan,
                         sum(isnull(R_A_F.qty_fact,0))  OVER(PARTITION BY R_A_F.A_F_PART_NO, R_A_F.year_period_f,R_A_F.period_no_f)			sum_qty_rout_fact,
                         R_A_F.contract_f,
                         QtyPlan.contract_p,
                         R_A_F.department_no,
                         R_A_F.A_F_alternative			R_A_F_Routing_alternative,
                         R_A_F.alternative_description,
                         QtyPlan.A_P_alternative		QtyPlan_alternative_no,                         
                         R_A_F.A_F_PART_NO			R_A_F_PART_NO,
                         R_A_F.part_description			PART_NO_desc,
                         QtyPlan.A_P_PART_NO			QtyPlan_PART_NO,
                         QtyPlan.year_period_p,
                         R_A_F.year_period_f,
                         QtyPlan.period_no_p,
                         QtyPlan.version_no, 
                         R_A_F.period_no_f  
                         
   from    t_Report_Priority_QtyRoutStructFact R_A_F

   left  join  t_Report_Priority_QtyRoutStructPlan QtyPlan
					 on	QtyPlan.contract_p = R_A_F.contract_f                    
                     and QtyPlan.A_P_alternative = R_A_F.A_F_alternative	
                     and QtyPlan.A_P_PART_NO = R_A_F.A_F_PART_NO
                     and QtyPlan.year_period_p = R_A_F.year_period_f
                     and QtyPlan.period_no_p = R_A_F.period_no_f
					 and QtyPlan.A_P_type='rout' 
					 and QtyPlan.version_no = @version_no
					 where 1 = 1 and R_A_F.A_F_type='rout')  Rout ) R
					 
   left join    t_Report_Priority_RoutCost  Labor
         on     R.contract_f = Labor.contract_f
         and R.R_A_F_PART_NO = Labor.part_no        
         and R.R_A_F_Routing_alternative = Labor.routing_alternative
         and R.year_period_f = Labor.year_period
         and R.period_no_f = Labor.period_no
	 where 1 = 1 )						LaborRout    
      
      where
      -- LaborRout.Routing_alternative <> '*' and
      LaborRout.Otclon_rout <> '0'
      and LaborRout.Otclon_rout_Cost <> '0'  and 
      LaborRout.contract_f = @contract 
      and @department_no like '%|' + LaborRout.department_no + '|%'
					 and LaborRout.year_period_f between @YEAR_FROM and @YEAR_TO
					 and LaborRout.period_no_f between @PERIOD_FROM and @PERIOD_TO
					 
					  group by 
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
             Cost110_110.Cost1C_All -  D.otclon_struct * Cost110_110.Cost110    Otclon_struct_Cost110, --from 04.07.2016
            -- D.otclon_struct * Cost110_110.Cost110 Otclon_struct_Cost110, 
             D.year_period_f					year_period_f,
             D.period_no_f					period_no_f,
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
                   S_A_F.eng_chg_level			eng_chg_level,
                   QtyPlan.A_P_PART_NO			QtyPlan_PART_NO,
                   QtyPlan.year_period_p,
                   S_A_F.year_period_f,
                   QtyPlan.period_no_p,
                   QtyPlan.version_no,
                   S_A_F.period_no_f
                   
            from    t_Report_Priority_QtyRoutStructFact S_A_F  
            
       left  join t_Report_Priority_QtyRoutStructPlan QtyPlan
	            on QtyPlan.contract_p = S_A_F.contract_f
               and QtyPlan.A_P_alternative  = S_A_F.A_F_alternative
               and QtyPlan.A_P_PART_NO = S_A_F.A_F_PART_NO
               and QtyPlan.year_period_p = S_A_F.year_period_f
               and QtyPlan.period_no_p = S_A_F.period_no_f 
			   and QtyPlan.A_P_type='struc' 
			   and  QtyPlan.version_no=@version_no
	           where 1 = 1 and S_A_F.A_F_type='struc' ) D
	
	    left  join 
	(select	isnull(Cost1.C_All,0) as Cost1C_All,
    isnull(Cost2.cost_star,Cost1.cost_buck) as  Cost110,
                             Cost1.contract_f,
                             Cost1.department_no,
                             Cost1.PART_NO,
                             Cost1.eng_chg_level,
                             Cost1.structure_alternative,
                             Cost1.year_period,
                             Cost1.period_no		  
	from t_Report_Priority_Cost_110Cost  Cost1
      left join  t_Report_Priority_Cost_110Cost   Cost2
	on  Cost1.contract_f = Cost2.contract_f  
	and Cost1.PART_NO = Cost2.PART_NO
	and Cost1.eng_chg_level = Cost2.eng_chg_level 
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
                               Cost1.eng_chg_level,
                               Cost1.structure_alternative,
                               Cost1.year_period,
                               Cost1.period_no )Cost110_110
	
      on Cost110_110.contract_f = D.contract_f
         and Cost110_110.department_no = D.department_no
         and Cost110_110.PART_NO = D.S_A_F_PART_NO
         and Cost110_110.eng_chg_level = D.eng_chg_level
         and Cost110_110.year_period = D.year_period_f
         and Cost110_110.period_no = D.period_no_f
         and Cost110_110.structure_alternative = D.S_A_F_structure_alternative where 1 = 1 
         ) Struc

      where 
       -- Struc.structure_alternative <> '*'  and
       -- Struc.PART_NO='P04301-548-000X' and  
        Struc.Otclon_struct <> '0'
        and Struc.Otclon_struct_Cost110 <> '0'	and
       Struc.contract_f=@contract 
       and @department_no like '%|' + Struc.department_no + '|%'
       and Struc.year_period_f between  @YEAR_FROM and @YEAR_TO 
       and  Struc.period_no_f between  @PERIOD_FROM  and @PERIOD_TO
    /*  and Struc.version_no=@version_no*/
   
   group by     

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

GO
