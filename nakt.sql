/*Specifications and technological routes in production*/
/*Parameters: cost_set - type of calculation, contract - type of site in production, ReportDate, type_code_db - type TMC*/
/*cost_set=2 - plan type of cost calculation, cost_set=6 - fact type of cost calculation. */

select
          :cost_set,
          case when :cost_set=2 then m.stateSpec2  when :cost_set=6 then m.stateSpec6 else null end  as  stateSpec,
          case when :cost_set=2 then m.EFF_PHASE_IN_DATE2  when :cost_set=6 then m.EFF_PHASE_IN_DATE6 else null end as  EFF_PHASE_IN_DATE,
          case when  :cost_set=2  then m.EFF_PHASE_out_DATE2  when :cost_set=6 then m.EFF_PHASE_out_DATE6 else null end as  EFF_PHASE_out_DATE,
          case when  :cost_set=2  then m.stateRout2  when  :cost_set=6 then m.stateRout6 else null end  as stateRout,            
          case when  :cost_set=2  then  m.PHASE_IN_DATE2 when  :cost_set=6   then m.PHASE_IN_DATE6 else null end as  PHASE_IN_DATE,
          case when  :cost_set=2   then  m.PHASE_out_DATE2  when  :cost_set=6   then  m.PHASE_out_DATE6 else null end as  PHASE_out_DATE,
 
       m.contract,
       m.part_no,
       m.part_desc,
       case
         when mspsa.part_no is not null then
          'ВУ'
         else 
          'НЕ ВУ'
       end vu,       
       case
         when mspsa1.component_part is not null then
          'Компонент'
         else
          'Не компонент'
       end komp,  
       
---- department from work_center by the last operation_no and phase_in_date where phase_out_date is null or phase_out_date >= :ReportDate)
 (SELECT RoutWorkC.department_no
       FROM(SELECT 
            ro.contract,
            ro.part_no,
            wc.department_no
        ,max(ro.phase_in_date)        
          FROM IFSAPP.ROUTING_OPERATION ro          
          LEFT JOIN IFSAPP.Work_Center wc
            on wc.contract = ro.contract
           and wc.work_center_no = ro.work_center_no           
          LEFT JOIN IFSAPP.ROUTING_ALTERNATE ra
            on ra.contract = ro.contract
           and ra.part_no = ro.part_no
           and ra.routing_revision = ro.routing_revision
           and ra.bom_type_db = ro.bom_type_db
           and ra.alternative_no = ro.alternative_no
           and ra.objstate = 'Buildable'
           
         WHERE ro.contract = :contract
           and ro.bom_type_db = 'M'
           and ro.alternative_no = '*'
           and (ro.phase_out_date is null or ro.phase_out_date >= :ReportDate)
            and ro.operation_no =
               (SELECT max(ro1.operation_no)               
                  FROM IFSAPP.ROUTING_OPERATION ro1                  
                 WHERE ro.contract = ro1.contract
                   and ro.part_no = ro1.part_no
                   and ro.bom_type_db = ro1.bom_type_db
                   and ro.alternative_no = ro1.alternative_no)       
           group by  ro.contract, ro.part_no, wc.department_no)RoutWorkC  
           WHERE RoutWorkC.contract = m.contract
           and RoutWorkC.part_no = m.part_no) department,
           
           m.status_desc,
           m.unit_meas,
           m.type_code,
           m.account_desc,
           m.part_cost_group_id,
           m.group_desc,
           m.create_date,
          ppss.currPrice

from (

SELECT 
         
       ip.contract         as contract,
       ip.part_no          as part_no, 
       ip.DESCRIPTION      as part_desc,     
       IFSAPP.Inventory_Part_Status_Par_API.Get_Description(ip.part_status) as  status_desc,
       ip.unit_meas                                                         as unit_meas,
       ip.type_code                                                         as type_code,
       IFSAPP.Accounting_Group_API.Get_Description(ip.accounting_group)     as account_desc,
       ip.part_cost_group_id                                                as part_cost_group_id ,
       pcg.description                                                      as group_desc,
       ip.create_date                                                       as create_date ,
       spec2.state                                                          as stateSpec2,
       spec6.state                                                          as stateSpec6,
       route2.state                                                         as stateRout2,
       route6.state                                                         as stateRout6,      
       spec2.EFF_PHASE_IN_DATE                                              as EFF_PHASE_IN_DATE2,  
       spec2.EFF_PHASE_out_DATE                                             as EFF_PHASE_out_DATE2, 
       spec6.EFF_PHASE_IN_DATE                                              as EFF_PHASE_IN_DATE6,
       spec6.EFF_PHASE_out_DATE                                             as EFF_PHASE_out_DATE6,
       route2.PHASE_IN_DATE                                                 as PHASE_IN_DATE2,
       route2.PHASE_out_DATE                                                as PHASE_out_DATE2,       
       route6.PHASE_IN_DATE                                                 as PHASE_IN_DATE6,
       route6.PHASE_out_DATE                                                as PHASE_out_DATE6
       
  FROM IFSAPP.inventory_part ip
  
  LEFT JOIN ifsapp.part_cost_group pcg
    on pcg.contract = ip.contract
   and pcg.part_cost_group_id = ip.part_cost_group_id

  LEFT JOIN (  
  SELECT mss7.contract,
         mss7.part_no,
         psa8.state,
         mss7.EFF_PHASE_IN_DATE,
         mss7.EFF_PHASE_out_DATE                
    FROM (SELECT mss5.contract,
                 mss5.part_no,
                 mss5.EFF_PHASE_IN_DATE,
                 mss5.EFF_PHASE_out_DATE,
                 max(mss5.eng_chg_level)  as  eng_chg_level
          
            FROM IFSAPP.prod_structure_head mss5          
           WHERE mss5.contract=:contract
             and mss5.bom_type_db = 'M'
             --and mss5.alternative_no = '*'      
             and mss5.eff_phase_out_date is null                  
           group by mss5.contract,                    
                    mss5.part_no,
                    mss5.EFF_PHASE_IN_DATE,
                    mss5.EFF_PHASE_out_DATE           
                    ) mss7,   
                          
         IFSAPP.PROD_STRUCT_ALTERNATE psa8
   WHERE psa8.contract = mss7.contract
     and psa8.part_no = mss7.part_no
     and psa8.eng_chg_level = mss7.eng_chg_level      
     and psa8.bom_type_db = 'M'
     and psa8.alternative_no = '*'    
                       ) spec2   --for 2 route type
              on   spec2.contract = ip.contract 
              and  spec2.part_no = ip.part_no
              
   LEFT JOIN (
  SELECT mss9.contract,
         mss9.part_no,
         psa9.state,
         mss9.EFF_PHASE_IN_DATE,
         mss9.EFF_PHASE_out_DATE                
    FROM (SELECT mss6.contract,
                 mss6.part_no,
                 mss6.EFF_PHASE_IN_DATE,
                 mss6.EFF_PHASE_out_DATE,
                 max(mss6.eng_chg_level) as eng_chg_level
          
            FROM IFSAPP.prod_structure_head mss6          
           WHERE mss6.contract = :contract
             and mss6.bom_type_db = 'M'
            -- and mss6.alternative_no = '*'
             and mss6.eff_phase_in_date<=:ReportDate
             and (mss6.eff_phase_out_date is null or
                            mss6.eff_phase_out_date >= :ReportDate)                 
           group by mss6.contract,                    
                    mss6.part_no,
                    mss6.EFF_PHASE_IN_DATE,
                    mss6.EFF_PHASE_out_DATE ) mss9,         
         IFSAPP.PROD_STRUCT_ALTERNATE psa9
   WHERE  psa9.contract = mss9.contract
      and psa9.part_no = mss9.part_no
      and psa9.eng_chg_level = mss9.eng_chg_level        
      and psa9.bom_type_db = 'M'
      and psa9.alternative_no = '*'
                ) spec6   --6 type of cost price calculation
              on  spec6.contract = ip.contract 
              and spec6.part_no = ip.part_no
              
    LEFT JOIN (  
  SELECT roo3.contract,
         roo3.part_no,
         ra4.state,
         roo3.PHASE_IN_DATE,
         roo3.PHASE_out_DATE  
              
    FROM (
    SELECT       ro3.contract,
                 ro3.part_no,             
                 ro3.PHASE_IN_DATE,
                 ro3.PHASE_out_DATE,
                 max(ro3.routing_revision) as  routing_revision                 
            FROM IFSAPP.ROUTING_HEAD ro3               
             WHERE 
                  ro3.contract=:contract             
              and ro3.bom_type_db = 'M'                 
              and ro3.phase_out_date is null
              group by 
                    ro3.contract,                    
                    ro3.part_no,
                    ro3.PHASE_IN_DATE,
                    ro3.PHASE_out_DATE           
                    ) roo3,  
              
         IFSAPP.ROUTING_ALTERNATE ra4      
         
   WHERE ra4.contract = roo3.contract
     and ra4.part_no = roo3.part_no
     and ra4.routing_revision = roo3.routing_revision     
     and ra4.bom_type_db = 'M'
     and ra4.alternative_no = '*'    
                       ) route2   --for the 2 route type 
              on   route2.contract = ip.contract 
              and  route2.part_no = ip.part_no            
              
       LEFT JOIN (  
  SELECT roo5.contract,
         roo5.part_no,
         ra6.state,
         roo5.PHASE_IN_DATE,
         roo5.PHASE_out_DATE  
              
    FROM (
    SELECT       ro5.contract,
                 ro5.part_no,             
                 ro5.PHASE_IN_DATE,
                 ro5.PHASE_out_DATE,
                 max(ro5.routing_revision) as  routing_revision
                 
            FROM IFSAPP.ROUTING_HEAD ro5              
             WHERE 
                 ro5.contract=:contract             
             and ro5.bom_type_db = 'M'      
             and ro5.phase_in_date<=:ReportDate          
             and (ro5.phase_out_date is null or
                            ro5.phase_out_date >= :ReportDate)
              group by 
                    ro5.contract,                    
                    ro5.part_no,
                    ro5.PHASE_IN_DATE,
                    ro5.PHASE_out_DATE           
                    ) roo5,  
                    
         IFSAPP.ROUTING_ALTERNATE ra6      
    WHERE ra6.contract = roo5.contract
     and ra6.part_no = roo5.part_no
     and ra6.routing_revision = roo5.routing_revision     
     and ra6.bom_type_db = 'M'
     and ra6.alternative_no = '*'    
                       ) route6   --6 route type 
              on   route6.contract = ip.contract 
              and  route6.part_no = ip.part_no              
         
WHERE ip.contract = :contract
and  ip.type_code_db   in  (:type_code_db) 

minus
      select   
       ip2.contract         as contract,
       ip2.part_no          as part_no, 
       ip2.DESCRIPTION      as part_desc,     
       IFSAPP.Inventory_Part_Status_Par_API.Get_Description(ip2.part_status) as  status_desc,
       ip2.unit_meas                                                         as unit_meas,
       ip2.type_code                                                         as type_code ,
       IFSAPP.Accounting_Group_API.Get_Description(ip2.accounting_group)     as account_desc,
       ip2.part_cost_group_id                                                as part_cost_group_id ,
       pcg2.description                                                      as group_desc,
       ip2.create_date                                                       as create_date ,
       spec22.state                                                          as stateSpec2,
       spec66.state                                                          as stateSpec6,
       route22.state                                                         as stateRout2,
       route66.state                                                         as stateRout6,
       
       spec22.EFF_PHASE_IN_DATE                                              as EFF_PHASE_IN_DATE2,  
       spec22.EFF_PHASE_out_DATE                                             as EFF_PHASE_out_DATE2, 
       spec66.EFF_PHASE_IN_DATE                                              as EFF_PHASE_IN_DATE6,
       spec66.EFF_PHASE_out_DATE                                             as EFF_PHASE_out_DATE6,
       route22.PHASE_IN_DATE                                                 as PHASE_IN_DATE2,
       route22.PHASE_out_DATE                                                as PHASE_out_DATE2,       
       route66.PHASE_IN_DATE                                                 as PHASE_IN_DATE6,
       route66.PHASE_out_DATE                                                as PHASE_out_DATE6
             
       FROM IFSAPP.inventory_part ip2  
  LEFT JOIN ifsapp.part_cost_group pcg2
    on pcg2.contract = ip2.contract
   and pcg2.part_cost_group_id = ip2.part_cost_group_id
          
     LEFT JOIN (  
  SELECT mss77.contract,
         mss77.part_no,
         psa88.state,
         mss77.EFF_PHASE_IN_DATE,
         mss77.EFF_PHASE_out_DATE              
    FROM (SELECT mss55.contract,
                 mss55.part_no,
                 mss55.EFF_PHASE_IN_DATE,
                 mss55.EFF_PHASE_out_DATE,
                 max(mss55.eng_chg_level)  as  eng_chg_level                     
            FROM IFSAPP.prod_structure_head mss55          
           WHERE mss55.contract=:contract
             and mss55.bom_type_db = 'M'
            -- and mss55.alternative_no = '*'      
             and mss55.eff_phase_out_date is null                  
           group by mss55.contract,                    
                    mss55.part_no,
                    mss55.EFF_PHASE_IN_DATE,
                    mss55.EFF_PHASE_out_DATE           
                    ) mss77,                             
         IFSAPP.PROD_STRUCT_ALTERNATE psa88
   WHERE psa88.contract = mss77.contract
     and psa88.part_no = mss77.part_no
     and psa88.eng_chg_level = mss77.eng_chg_level      
     and psa88.bom_type_db = 'M'
     and psa88.alternative_no = '*'    
                       ) spec22   --2 type cost price calculation
              on   spec22.contract = ip2.contract 
              and  spec22.part_no = ip2.part_no              
   LEFT JOIN (
  SELECT mss99.contract,
         mss99.part_no,
         psa99.state,
         mss99.EFF_PHASE_IN_DATE,
         mss99.EFF_PHASE_out_DATE                
    FROM (SELECT mss66.contract,
                 mss66.part_no,
                 mss66.EFF_PHASE_IN_DATE,
                 mss66.EFF_PHASE_out_DATE,
                 max(mss66.eng_chg_level) as eng_chg_level                                               
            FROM IFSAPP.prod_structure_head mss66          
           WHERE mss66.contract = :contract
             and mss66.bom_type_db = 'M'
           --  and mss66.alternative_no = '*'
             and mss66.eff_phase_in_date<=:ReportDate 
             and (mss66.eff_phase_out_date is null or
                            mss66.eff_phase_out_date >= :ReportDate)                  
           group by mss66.contract,                    
                    mss66.part_no,
                    mss66.EFF_PHASE_IN_DATE,
                    mss66.EFF_PHASE_out_DATE) mss99,         
         IFSAPP.PROD_STRUCT_ALTERNATE psa99
   WHERE  psa99.contract = mss99.contract
      and psa99.part_no = mss99.part_no
      and psa99.eng_chg_level = mss99.eng_chg_level        
      and psa99.bom_type_db = 'M'
      and psa99.alternative_no = '*'
                ) spec66   --6 type cost price calculation
              on  spec66.contract = ip2.contract 
              and spec66.part_no = ip2.part_no              
    LEFT JOIN (  
  SELECT roo33.contract,
         roo33.part_no,
         ra44.state,
         roo33.PHASE_IN_DATE,
         roo33.PHASE_out_DATE  
              
    FROM (
    SELECT       ro33.contract,
                 ro33.part_no,             
                 ro33.PHASE_IN_DATE,
                 ro33.PHASE_out_DATE,
                 max(ro33.routing_revision) as  routing_revision
              
            FROM IFSAPP.ROUTING_HEAD ro33               
             WHERE 
                  ro33.contract=:contract             
              and ro33.bom_type_db = 'M'                 
              and ro33.phase_out_date is null
              group by 
                    ro33.contract,                    
                    ro33.part_no,
                    ro33.PHASE_IN_DATE,
                    ro33.PHASE_out_DATE           
                    ) roo33,  
                    
         IFSAPP.ROUTING_ALTERNATE ra44
              
   WHERE ra44.contract = roo33.contract
     and ra44.part_no = roo33.part_no
     and ra44.routing_revision = roo33.routing_revision     
     and ra44.bom_type_db = 'M'
     and ra44.alternative_no = '*'    
                       ) route22   --2 route type
              on   route22.contract = ip2.contract 
              and  route22.part_no = ip2.part_no  
          
       LEFT JOIN (  
  SELECT roo55.contract,
         roo55.part_no,
         ra66.state,
         roo55.PHASE_IN_DATE,
         roo55.PHASE_out_DATE  
              
    FROM (
    SELECT       ro55.contract,
                 ro55.part_no,             
                 ro55.PHASE_IN_DATE,
                 ro55.PHASE_out_DATE,
                 max(ro55.routing_revision) as  routing_revision
                 
            FROM IFSAPP.ROUTING_HEAD ro55              
             WHERE 
                 ro55.contract=:contract             
             and ro55.bom_type_db = 'M'      
             and ro55.phase_in_date<=:ReportDate         
             and (ro55.phase_out_date is null or
                            ro55.phase_out_date >= :ReportDate)
              group by 
                    ro55.contract,                    
                    ro55.part_no,
                    ro55.PHASE_IN_DATE,
                    ro55.PHASE_out_DATE           
                    ) roo55,  
                    
         IFSAPP.ROUTING_ALTERNATE ra66
                 
   WHERE ra66.contract = roo55.contract
     and ra66.part_no = roo55.part_no
     and ra66.routing_revision = roo55.routing_revision     
     and ra66.bom_type_db = 'M'
     and ra66.alternative_no = '*'    
                       ) route66   --6 route type
              on   route66.contract = ip2.contract 
              and  route66.part_no = ip2.part_no 
   
   where ip2.contract = '02'
   and  ip2.type_code_db='1'  
   and (ip2.part_status='N' or ip2.part_status='A')
       and nvl(ip2.part_cost_group_id,0) not in ('NEW','NAKT','0')
   
    and (spec22.state='Действующее' and spec66.state='Действующее' and route22.state='Действующее' and route66.state='Действующее') 
    and (spec22.EFF_PHASE_out_DATE is null and route22.PHASE_out_DATE is null)   
    and (spec66.EFF_PHASE_IN_DATE <=:ReportDate and (spec66.EFF_PHASE_out_DATE is null or spec66.EFF_PHASE_out_DATE >=:ReportDate))  
    and (route66.PHASE_IN_DATE <=:ReportDate and (route66.PHASE_out_DATE is null or route66.PHASE_out_DATE >=:ReportDate))  
    )m


  LEFT JOIN (SELECT ms1.contract, ms1.part_no, max(ms1.eng_chg_level)
               FROM (SELECT ms.contract,
                            ms.part_no,
                            ms.bom_type_db,
                            ms.alternative_no,
                            ms.eng_chg_level
                            
                       FROM IFSAPP.MANUF_STRUCTURE ms
                       
                      WHERE   ms.contract = :contract
                         and  ms.bom_type_db = 'M'
                         and  ms.alternative_no = '*'
                         and (ms.eff_phase_out_date is null or
                            ms.eff_phase_out_date >= :ReportDate)
                      group by ms.contract,
                               ms.part_no,
                               ms.bom_type_db,
                               ms.alternative_no,
                               ms.eng_chg_level) ms1,
                               
                    IFSAPP.PROD_STRUCT_ALTERNATE psa
                    
              WHERE psa.contract = ms1.contract
                and psa.part_no = ms1.part_no
                and psa.eng_chg_level = ms1.eng_chg_level
                and psa.bom_type_db = ms1.bom_type_db
                and psa.alternative_no = ms1.alternative_no
                and psa.objstate = 'Buildable'
              group by ms1.contract, ms1.part_no) mspsa

    on mspsa.contract = m.contract
    and mspsa.part_no = m.part_no

  LEFT JOIN (SELECT mss1.contract,
                    mss1.component_part,
                    max(mss1.eng_chg_level)
             
               FROM (SELECT mss.contract,
                            mss.component_part,
                            mss.part_no,
                            mss.eng_chg_level,
                            mss.bom_type_db,
                            mss.alternative_no
                            
                       FROM IFSAPP.prod_structure mss
                     
                      WHERE mss.contract = :contract
                        and mss.bom_type_db = 'M'
                        and mss.alternative_no = '*'
                        and (mss.eff_phase_out_date is null or
                            mss.eff_phase_out_date >= :ReportDate)
                      group by mss.contract,
                               mss.component_part,
                               mss.part_no,
                               mss.eng_chg_level,
                               mss.bom_type_db,
                               mss.alternative_no) mss1,
                    
                    IFSAPP.PROD_STRUCT_ALTERNATE psa
              WHERE psa.contract = mss1.contract
                and psa.part_no = mss1.part_no
                and psa.eng_chg_level = mss1.eng_chg_level
                and psa.bom_type_db = mss1.bom_type_db
                and psa.alternative_no = mss1.alternative_no
                and psa.objstate = 'Buildable'
              group by mss1.contract, mss1.component_part) mspsa1

    on mspsa1.contract = m.contract
   and mspsa1.component_part = m.part_no

     LEFT JOIN (SELECT pps.contract,
                    pps.part_no,
                    /*cf*/
                    pps.currency_code,
                    nvl(pps.list_price, 0) list_price,
                    nvl(pps.list_price, 0) *
                    nvl(lc.currency_rate / lc.conv_factor, 1) CurrPrice
             
               FROM IFSAPP.PURCHASE_PART_SUPPLIER pps
                
               join ifsapp.site s
                 on s.contract = pps.contract
                and s.contract = :contract
               LEFT JOIN ifsapp.LATEST_CURRENCY_RATES lc               
                 on lc.company = /*cf*/
                    s.company
                and lc.currency_code = /*cf*/
                    pps.currency_code
                and lc.currency_type = '1'
                and lc.valid_FROM <= :ReportDate                
              WHERE pps.primary_vendor_db = 'Y') ppss       ---Price according to currency rate
    on  ppss.contract = m.contract
   and  ppss.part_no = m.part_no
--WHERE m.contract = :contract and  m.type_code_db   in  (:type_code_db) 

   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
