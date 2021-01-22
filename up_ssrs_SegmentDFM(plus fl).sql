-----call sb_pbi.up_sp_ddl('up_ssrs_ChannelIncom_CashDeposit','alter','( in @DateFrom date,in @DateTo date,in @Typerep integer,in @Amount money ) 
 --begin
  --if @Typerep = 1 then...
 -- ....
  --  elseif @Typerep = 2 then
--    commit work
 -- end if;
 
 
---Из-за большого кол-ва данных необходимо предусмотреть возможность выбора по сегменту и/или  уровню риска.

---="call sb_bio.up_ssrs_SegmentDFM (  @StateCode_out = '" & Parameters!StateCode.Value & "',  @Date_fuib_out = '" & Format(Parameters!Month.Value, "yyyy-MM-dd") & "' )"

create procedure sb_bio.up_ssrs_SegmentDFM ( 
  in @StateCode_out varchar(32) default '',
  in @Date_fuib_out date,in @Count_month_out smallint default 3 ) 
  ---+  in @Segment varchar(32) default '',
  --  in @RiskFlag smallint
begin

  declare local temporary table ltb_Clients(
    ClientId integer null iq unique(65535),
    ExtId varchar(32) null iq unique(65535),
    ClientCode varchar(32) null iq unique(65535),
    Name varchar(80) null iq unique(65535),
    StateCode varchar(32) null iq unique(65535),
    Segment varchar(5) null iq unique(255),
    SegmentDesc varchar(5) null iq unique(255),
    RiskVal integer null iq unique(255),
    RiskFlag integer null,
    RiskDesc varchar(64) null iq unique(255),
    IsOpenAcc integer null iq unique(255),
    RC varchar(5) null iq unique(255),
    N_0 decimal(18,2) null iq unique(65535),
    N_2 decimal(18,2) null iq unique(65535),
    N_3 decimal(18,2) null iq unique(65535),
    N_4 decimal(18,2) null iq unique(65535),
    N_full decimal(18,2) null iq unique(65535),) on commit preserve rows;
	
  declare local temporary table ltb_Treaty(
    TreatyId integer null iq unique(65535),
    ClientId integer null iq unique(65535),
    RC varchar(5) null iq unique(255),
    SystemId integer null iq unique(255),
    Portfolio varchar(32) null iq unique(255),
    MainAmount decimal(18,2) null iq unique(65535),
    MainLimit decimal(18,2) null iq unique(65535),) on commit preserve rows;
	
  declare local temporary table ltb_Acc(
    ClientId integer null iq unique(65535),
    AccountId integer null iq unique(65535),
    TopicId integer null iq unique(255),
    AdvCode varchar(6) null iq unique(255),) on commit preserve rows;
	
  declare local temporary table ltb_TurnOut(
    ClientId integer null iq unique(65535),
    BillId bigint null iq unique(65535),
    N_month integer null iq unique(255),
    YM varchar(6) null iq unique(255),
    AmountOut decimal(18,2) null iq unique(65535),
    Purpose varchar(150) null iq unique(65535),) on commit preserve rows;
	
  declare local temporary table ltb_Bills(
    ClientId integer null iq unique(65535),
    BillId bigint null iq unique(65535),
    DayDate integer null iq unique(65535),
    DayDate_fuib date null iq unique(65535),
    DebitId bigint null iq unique(65535),
    DebitTopic integer null iq unique(65535),
    DebitTopic2 integer null iq unique(65535),
    DebitCode varchar(32) null iq unique(65535),
    DebitState varchar(32) null iq unique(65535),
    CreditId integer null iq unique(65535),
    CreditTopic integer null iq unique(65535),
    CreditCode varchar(32) null iq unique(65535),
    CreditState varchar(32) null iq unique(65535),
    MainAmount decimal(18,2) null iq unique(65535),
    SourceCode varchar(32) null iq unique(65535),
    TargetCode varchar(32) null iq unique(65535),
    IsOtherBank integer null iq unique(255),
    Purpose varchar(150) null iq unique(65535),
    ExclusionType varchar(100) null iq unique(65535),
    Flag integer null iq unique(255),) on commit preserve rows;
	
  declare local temporary table ltb_Calender(
    DayDate integer null iq unique(65535),
    DayDate_fuib date null iq unique(65535),
    YM varchar(6) null iq unique(255),
    Count_YM integer null iq unique(255),
    N_month integer null iq unique(255),
    kind integer null iq unique(255),) on commit preserve rows;
	
  declare @StateCode varchar(32);
  declare @DebugMode integer;
  declare @Count_month smallint;
  declare @Avg_int integer;
  declare @Date_fuib date;
  declare @Date_int integer;
  declare @Date_from date;
  declare @Date_until date;
  
  create hg index indx_ltb_Bills_ClientId on ltb_Bills(ClientId);
  create hg index indx_ltb_TurnOut_ClientId on ltb_TurnOut(ClientId);
  
  select 0 into @DebugMode from dbo.iq_dummy;  
  select @Count_month_out into @Count_month from dbo.iq_dummy;
  select @StateCode_out into @StateCode from dbo.iq_dummy;
  select @Date_fuib_out into @Date_fuib from dbo.iq_dummy;
  
  select DATEADD(month,-@Count_month,@Date_fuib)
    into @Date_from
    from dbo.iq_dummy;
	
  select min(t.DayDate_fuib)
    into @Date_from
    from DFC.tb_sc_vToday as t
    where datepart(mm,t.DayDate_fuib) = datepart(mm,@Date_from)
    and datepart(yy,t.DayDate_fuib) = datepart(yy,@Date_from);
	
  select max(t.DayDate_fuib)
    into @Date_until
    from DFC.tb_sc_vToday as t
    where datepart(mm,t.DayDate_fuib) = datepart(mm,@Date_fuib)
    and datepart(yy,t.DayDate_fuib) = datepart(yy,@Date_fuib)
    and t.DayDate_fuib < (select today() from dbo.iq_dummy);
	
  select datediff(day,'1900-01-01',@Date_until)
    into @Date_int
    from dbo.iq_dummy;
	
  if @DebugMode <> 0 then select getdate() as Timer_ltb_Calender from dbo.iq_dummy end if;
  insert into ltb_Calender (DayDate,DayDate_fuib,YM,Count_YM,N_month,kind ) 
    select t.DayDate,
      t.DayDate_fuib,
      string(datepart(yy,t.DayDate_fuib),right(string('0',datepart(mm,t.DayDate_fuib)),2)) as YM,
      count(t.DayDate) over(partition by YM) as Count_YM,
      dense_rank() over(order by datepart(yy,t.DayDate_fuib) desc,datepart(mm,t.DayDate_fuib) desc) as N_month,
      t.kind
      from DFC.tb_sc_vToday as t
      where 1 = 1
      and t.kind = 0
      and t.DayDate_fuib >= @Date_from
      and t.DayDate_fuib <= @Date_until
      order by t.DayDate asc;
  commit work;
  
  if @DebugMode <> 0 then select getdate() as Timer_ltb_Clients from dbo.iq_dummy end if;
  select count(1) into @Avg_int from ltb_Calender;
  
  select a.Act_lev,
    a.Segment,
    a.lower_bound,
    a.upper_bound,
    a.RiskFlag,
    a.Segment_DFM
    into #ltb_segment_dfm
    from (select 1 as Act_lev,
        '1001' as Segment,
        0 as lower_bound,
        5000 as upper_bound,
        0 as RiskFlag,
        'неактивный низко-рисковый (НАнр)' as Segment_DFM
        from dbo.iq_dummy union all
      select 1,'1002',0,10000,0,'неактивный низко-рисковый (НАнр)' from dbo.iq_dummy union all
      select 1,'1003',0,15000,0,'неактивный низко-рисковый (НАнр)' from dbo.iq_dummy union all
      select 1,'1004',0,20000,0,'неактивный низко-рисковый (НАнр)' from dbo.iq_dummy union all
      select 1,'1005',0,10000,0,'неактивный низко-рисковый (НАнр)' from dbo.iq_dummy union all
      select 1,'1001',0,5000,1,'неактивный средне-рисковый (НАср)' from dbo.iq_dummy union all
      select 1,'1002',0,10000,1,'неактивный средне-рисковый (НАср)' from dbo.iq_dummy union all
      select 1,'1003',0,15000,1,'неактивный средне-рисковый (НАср)' from dbo.iq_dummy union all
      select 1,'1004',0,20000,1,'неактивный средне-рисковый (НАср)' from dbo.iq_dummy union all
      select 1,'1005',0,10000,1,'неактивный средне-рисковый (НАср)' from dbo.iq_dummy union all
      select 1,'1001',0,5000,2,'неактивный высоко-рисковый (НАвр)' from dbo.iq_dummy union all
      select 1,'1002',0,10000,2,'неактивный высоко-рисковый (НАвр)' from dbo.iq_dummy union all
      select 1,'1003',0,15000,2,'неактивный высоко-рисковый (НАвр)' from dbo.iq_dummy union all
      select 1,'1004',0,20000,2,'неактивный высоко-рисковый (НАвр)' from dbo.iq_dummy union all
      select 1,'1005',0,10000,2,'неактивный высоко-рисковый (НАвр)' from dbo.iq_dummy union all
      select 2,'1001',5000,400000,0,'малоактивный низко-рисковый (МАнр)' from dbo.iq_dummy union all
      select 2,'1002',10000,1000000,0,'малоактивный низко-рисковый (МАнр)' from dbo.iq_dummy union all
      select 2,'1003',15000,2000000,0,'малоактивный низко-рисковый (МАнр)' from dbo.iq_dummy union all
      select 2,'1004',20000,4000000,0,'малоактивный низко-рисковый (МАнр)' from dbo.iq_dummy union all
      select 2,'1005',10000,1000000,0,'малоактивный низко-рисковый (МАнр)' from dbo.iq_dummy union all
      select 2,'1001',5000,400000,1,'малоактивный средне-рисковый (МАср)' from dbo.iq_dummy union all
      select 2,'1002',10000,1000000,1,'малоактивный средне-рисковый (МАср)' from dbo.iq_dummy union all
      select 2,'1003',15000,2000000,1,'малоактивный средне-рисковый (МАср)' from dbo.iq_dummy union all
      select 2,'1004',20000,4000000,1,'малоактивный средне-рисковый (МАср)' from dbo.iq_dummy union all
      select 2,'1005',10000,1000000,1,'малоактивный средне-рисковый (МАср)' from dbo.iq_dummy union all
      select 2,'1001',5000,400000,2,'малоактивный высоко-рисковый (МАвр)' from dbo.iq_dummy union all
      select 2,'1002',10000,1000000,2,'малоактивный высоко-рисковый (МАвр)' from dbo.iq_dummy union all
      select 2,'1003',15000,2000000,2,'малоактивный высоко-рисковый (МАвр)' from dbo.iq_dummy union all
      select 2,'1004',20000,4000000,2,'малоактивный высоко-рисковый (МАвр)' from dbo.iq_dummy union all
      select 2,'1005',10000,1000000,2,'малоактивный высоко-рисковый (МАвр)' from dbo.iq_dummy union all
      select 3,'1001',400000,1500000,0,'приемлемо-активный низко-рисковый (ПАнр)' from dbo.iq_dummy union all
      select 3,'1002',1000000,10000000,0,'приемлемо-активный низко-рисковый (ПАнр)' from dbo.iq_dummy union all
      select 3,'1003',2000000,30000000,0,'приемлемо-активный низко-рисковый (ПАнр)' from dbo.iq_dummy union all
      select 3,'1004',4000000,100000000,0,'приемлемо-активный низко-рисковый (ПАнр)' from dbo.iq_dummy union all
      select 3,'1005',1000000,10000000,0,'приемлемо-активный низко-рисковый (ПАнр)' from dbo.iq_dummy union all
      select 3,'1001',400000,1500000,1,'приемлемо-активный средне-рисковый (ПАср)' from dbo.iq_dummy union all
      select 3,'1002',1000000,10000000,1,'приемлемо-активный средне-рисковый (ПАср)' from dbo.iq_dummy union all
      select 3,'1003',2000000,30000000,1,'приемлемо-активный средне-рисковый (ПАср)' from dbo.iq_dummy union all
      select 3,'1004',4000000,100000000,1,'приемлемо-активный средне-рисковый (ПАср)' from dbo.iq_dummy union all
      select 3,'1005',1000000,10000000,1,'приемлемо-активный средне-рисковый (ПАср)' from dbo.iq_dummy union all
      select 3,'1001',400000,1500000,2,'приемлемо-активный высоко-рисковый (ПАвр)' from dbo.iq_dummy union all
      select 3,'1002',1000000,10000000,2,'приемлемо-активный высоко-рисковый (ПАвр)' from dbo.iq_dummy union all
      select 3,'1003',2000000,30000000,2,'приемлемо-активный высоко-рисковый (ПАвр)' from dbo.iq_dummy union all
      select 3,'1004',4000000,100000000,2,'приемлемо-активный высоко-рисковый (ПАвр)' from dbo.iq_dummy union all
      select 3,'1005',1000000,10000000,2,'приемлемо-активный высоко-рисковый (ПАвр)' from dbo.iq_dummy union all
      select 4,'1001',1500000,999999999999,0,'гипер-активный низко-рисковый (ГАнр)' from dbo.iq_dummy union all
      select 4,'1002',10000000,999999999999,0,'гипер-активный низко-рисковый (ГАнр)' from dbo.iq_dummy union all
      select 4,'1003',30000000,999999999999,0,'гипер-активный низко-рисковый (ГАнр)' from dbo.iq_dummy union all
      select 4,'1004',100000000,999999999999,0,'гипер-активный низко-рисковый (ГАнр)' from dbo.iq_dummy union all
      select 4,'1005',10000000,999999999999,0,'гипер-активный низко-рисковый (ГАнр)' from dbo.iq_dummy union all
      select 4,'1001',1500000,999999999999,1,'гипер-активный средне-рисковый (ГАср)' from dbo.iq_dummy union all
      select 4,'1002',10000000,999999999999,1,'гипер-активный средне-рисковый (ГАср)' from dbo.iq_dummy union all
      select 4,'1003',30000000,999999999999,1,'гипер-активный средне-рисковый (ГАср)' from dbo.iq_dummy union all
      select 4,'1004',100000000,999999999999,1,'гипер-активный средне-рисковый (ГАср)' from dbo.iq_dummy union all
      select 4,'1005',10000000,999999999999,1,'гипер-активный средне-рисковый (ГАср)' from dbo.iq_dummy union all
      select 4,'1001',1500000,999999999999,2,'гипер-активный высоко-рисковый (ГАвр)' from dbo.iq_dummy union all
      select 4,'1002',10000000,999999999999,2,'гипер-активный высоко-рисковый (ГАвр)' from dbo.iq_dummy union all
      select 4,'1003',30000000,999999999999,2,'гипер-активный высоко-рисковый (ГАвр)' from dbo.iq_dummy union all
      select 4,'1004',100000000,999999999999,2,'гипер-активный высоко-рисковый (ГАвр)' from dbo.iq_dummy union all
      select 4,'1005',10000000,999999999999,2,'гипер-активный высоко-рисковый (ГАвр)' from dbo.iq_dummy) as a;
  commit work;
  
  
  -------------------------------
  ---for fiz liz start ---Segment??
  ----------------------------
   select a.Act_lev,
    a.Segment,
    a.lower_bound,
    a.upper_bound,
    a.RiskFlag,
    a.Segment_DFM
    into #ltb_segment_dfm
    from(  --- не зависимо от сегмента???  'Неприемлемо высокий уровень риска--нет такого?
	  select 1 as Act_lev,'' as Segment /*!!????*/, 0 as lower_bound,50000 as upper_bound, 0 as RiskFlag,'неактивный низко-рисковый (НАнр)' as Segment_DFM   from dbo.iq_dummy union all  
	  
      select 1,'',0,50000,1,'неактивный средне-рисковый (НАср)' from dbo.iq_dummy union all
     
      select 1,'',0,50000,2,'неактивный высоко-рисковый (НАвр)' from dbo.iq_dummy union all      
	  
      select 2,'',50000,400000,0,'малоактивный низко-рисковый (МАнр)' from dbo.iq_dummy union all
      
      select 2,'',50000,400000,1,'малоактивный средне-рисковый (МАср)' from dbo.iq_dummy union all
     	 
      select 2,'',50000,400000,2,'малоактивный высоко-рисковый (МАвр)' from dbo.iq_dummy union all
      	  
      select 3,'',400000,1000000,0,'приемлемо-активный низко-рисковый (ПАнр)' from dbo.iq_dummy union all
	      
      select 3,'',400000,1000000,1,'приемлемо-активный средне-рисковый (ПАср)' from dbo.iq_dummy union all
     	  
      select 3,'',400000,1000000,2,'приемлемо-активный высоко-рисковый (ПАвр)' from dbo.iq_dummy union all
      	  
      select 4,'',1000000,9999999999999,0,'гипер-активный низко-рисковый (ГАнр)' from dbo.iq_dummy union all
      
      select 4,'',1000000,9999999999999,1,'гипер-активный средне-рисковый (ГАср)' from dbo.iq_dummy union all
      
      select 4,'',1000000,9999999999999,2,'гипер-активный высоко-рисковый (ГАвр)' from dbo.iq_dummy) as a;
      
  commit work;
  ------------------------------
    ---for fiz liz end
  --------------------
  
  
  insert into ltb_Clients( ClientId,ExtId,ClientCode,Name,StateCode,Segment,SegmentDesc,RC ) 
    select c.Id,
      cast(c.Id as varchar(32)),
      c.Code,
      c.Name,
      c.StateCode,
      cv.Code,
      case when cv.code = '1001' then 'Микро'
      when cv.code = '1002' then 'МКК'
      when cv.code = '1003' then 'СКК'
      when cv.code = '1004' then 'ККК'
      when cv.code = '1005' then 'ГК'
      else 'N/A'
      end as SegmentDesc,    -----для фл другой
      brca.RC
      from DFC.tb_sc_vClients as c
        join DFC.tb_sc_vTreaty as t on c.Id = t.ClientID
        and((t.Closed = 0 and t.ProcessFlag in( 1,3 ) ) or (t.Closed > @Date_int and t.ProcessFlag in( 2 ) ))
        and(t.OrgDate = 0 or t.OrgDate <= @Date_int)
        left outer join DFC.tb_sc_vConnotationValues as cv on c.Id = cv.OwnerId and cv.Kind = 917
        left outer join DFC.tb_dfc_Branch as brca on c.BranchId = brca.BranchId
      where 1 = 1
      and(@StateCode = '' or c.StateCode = @StateCode)
      and(c.Closed = 0 or (c.Closed <= @Date_int and c.DeleteFlag <> 1)
      or (c.Closed >= @Date_int and c.DeleteFlag = 1))
      and c.StateFlag in ( 1,2,64,128,1024,2048 )                                          
      and(cv.code in ( '0','1001','1002','1003','1004','1005','' ) or cv.code is null)    
      and c.Id <> 424537
      group by c.Id,
      c.Code,
      c.Name,
      c.StateCode,
      cv.code,
      brca.RC;
  commit work;
  
  ---------------------------------
    ---for fiz liz start
  ---------------------------------
    insert into ltb_Clients( ClientId,ExtId,ClientCode,Name,StateCode,Segment,SegmentDesc,RC ) 
    select c.Id,
      cast(c.Id as varchar(32)),
      c.Code,
      c.Name,
      c.StateCode,
     --cv.Code,
  , case when c.kind in (1,4,5,7) then isnull(cv.code,case when DATEDIFF(DD,dateformat(c.Created,'YYYY-MM-DD'),'2018-10-31')<45 then '1002' else '1004' end)
            when c.kind in (6) then isnull(cv.code,'1005')
            when c.kind in (2) then isnull(cv.code,'1')
             else null end as Segment,	 
   , case when sc.code='7' then 'Группа'
            when sc.info='УРКК' then 'Группа'
            when Segment='1004' then 'KKK'
            when Segment='1001' then 'Mикро'
            when Segment='1002' then 'MKK'
            when Segment='1003' then 'CKK'
            when Segment='1005' then 'ГК'
            when Segment in ('2','3','4','5','14','15','16','17','18') then 'VIP'
            when Segment in ('10','19','20','21','22','23') then 'Affluent'
            when Segment in ('7','8','9','24','25','26','27','28') then 'Middle'
            when Segment in ('29','30','31','32','33') then 'LowMid'
            when Segment in ('1','34','35','36','37','38') then 'Mass'
               else null end as SegmentDesc,    
      brca.RC
      from DFC.tb_sc_vClients as c
        join DFC.tb_sc_vTreaty as t on c.Id = t.ClientID
        and((t.Closed = 0 and t.ProcessFlag in( 1,3 ) ) or (t.Closed > @Date_int and t.ProcessFlag in( 2 ) ))
        and(t.OrgDate = 0 or t.OrgDate <= @Date_int)
        left outer join DFC.tb_sc_vConnotationValues as cv on c.Id = cv.OwnerId and cv.Kind = 917
        left outer join DFC.tb_dfc_Branch as brca on c.BranchId = brca.BranchId
      where 1 = 1
      and(@StateCode = '' or c.StateCode = @StateCode)
	  and(@Segment = '' or Segment = @Segment)  ----- new param!!
	 
      and(c.Closed = 0 or (c.Closed <= @Date_int and c.DeleteFlag <> 1)
      or (c.Closed >= @Date_int and c.DeleteFlag = 1))
      and c.StateFlag in (4,8,4096, 8192,16,256,1,64)  
--	  ( 1,2,64,128,1024,2048 )                                          
      --and(cv.code in ( '0','1001','1002','1003','1004','1005','' ) or cv.code is null)     
      and c.Id <> 424537
      group by c.Id,
      c.Code,
      c.Name,
      c.StateCode,
      cv.code,
      brca.RC;
  commit work;
  -----------------------
      ---for fiz liz end
  ---------------
    
  
  update ltb_Clients as c
    set c.RiskVal = cr.Value,
    c.RiskFlag = cv.Flag,
    c.RiskDesc = case when cv.Flag = 0 then 'Низкий уровень риска (' || cr.Value || ')'
    when cv.Flag = 1 then 'Средний уровень риска (' || cr.Value || ')'
    when cv.Flag = 2 then 'Высокий уровень риска (' || cr.Value || ')'
    when cv.Flag = 3 then 'Неприемлемо высокий уровень риска (' || cr.Value || ')'
    else null
    end from ltb_Clients as c
    join dfc.tb_sc_vconnotationvalues as cv on c.ClientId = cv.OwnerId and cv.Kind = 243  and cv.Flag in (@RiskFlag)
    join dfc.tb_wb_cfExternalClients as exc on c.ExtId = exc.ExtId and exc.status = 1
    join dfc.tb_wb_cfClientRisk as cr on exc.clientid = cr.clientid
    and cr.status = 1
    and cr.clienttypeid = exc.ExtTypeId
	
	--where c.RiskFlag = @RiskFlag  ----- new param!!
	---and(@RiskFlag = '' or c.RiskFlag = @RiskFlag)
	;  commit work;
  
  if @DebugMode <> 0 then select getdate() as Timer_ltb_Treaty from dbo.iq_dummy end if;
  insert into ltb_Acc ( ClientId,AccountId,TopicId,AdvCode ) 
    select a.ClientId,
      a.Id,
      a.TopicId,
      a.AdvCode
      from ltb_Clients as t
        join DFC.tb_sc_vAccounts as a on t.ClientID = a.ClientId
        and a.subcount = 0
        and a.TopicId in( 2600,2650 )   ----для фл!!
        and(a.Closed = 0 or a.Closed >= @Date_int)
      group by a.Id,a.ClientId,a.TopicId,a.AdvCode;
  commit work;
    
  
 ---------------------------------
    ---for fiz liz start
---------------------------------  
  if @DebugMode <> 0 then select getdate() as Timer_ltb_Treaty from dbo.iq_dummy end if;
  insert into ltb_Acc ( ClientId,AccountId,TopicId,AdvCode ) 
    select a.ClientId,
      a.Id,
      a.TopicId,
      a.AdvCode
      from ltb_Clients as t
        join DFC.tb_sc_vAccounts as a on t.ClientID = a.ClientId
        and a.subcount = 0
        and a.TopicId=2620   
        and(a.Closed = 0 or a.Closed >= @Date_int)
      group by a.Id,a.ClientId,a.TopicId,a.AdvCode;
  commit work;
 -----------------------
      ---for fiz liz end
  ---------------
     
  
  
  create hg index ltb_Acc_AccountId on ltb_Acc(AccountId);
  create hg index ltb_Acc_ClientId on ltb_Acc(ClientId);
  
  update ltb_Clients as c
    set isOpenAcc = 1 from
    ltb_Clients as c
    join ltb_Acc as a on c.ClientID = a.ClientId and a.TopicId in( 2600,2650 ) ;  ----для фл!!
  commit work;
  
 ---------------------------------
    ---for fiz liz start
---------------------------------  
   update ltb_Clients as c
    set isOpenAcc = 1 from
    ltb_Clients as c
    join ltb_Acc as a on c.ClientID = a.ClientId and a.TopicId=2620  ;  ----для фл!!
  commit work; 
  -----------------------
      ---for fiz liz end
  ---------------
      
  
  
  if @DebugMode <> 0 then select getdate() as Timer_Insert_ltb_Bills from dbo.iq_dummy end if;
  insert into ltb_Bills( ClientId,BillId,DayDate_fuib,DebitId,
    DebitTopic,DebitCode,DebitState,CreditId,CreditTopic,CreditCode,
    CreditState,MainAmount,SourceCode,TargetCode,IsOtherBank,Purpose,ExclusionType,flag ) 
    select a.ClientID,
      b.BillId,
      b.DayDate_fuib,
      b.DebitId,
      left(b.DebitCode,4) as DebitTopic,
      b.DebitCode,
      b.DebitState,
      b.CreditId,
      left(b.CreditCode,4) as CreditTopic,
      b.CreditCode,
      b.CreditState,
      b.MainAmount,
      b.SourceCode,
      b.TargetCode,
      1,
      b.Purpose,
      b.ExclusionType,
      1
      from ltb_Acc as a
        join dfc.tb_dfc_cb_bills as b on a.AccountID = b.CreditID
        and b.DayDate_fuib >= @Date_from
        and b.DayDate_fuib <= @Date_fuib
        and(b.DT_CT = 'CT' or b.DT_CT = '')
      where 1 = 1;
  commit work;
  
  update ltb_Bills as b
    set b.DayDate = d.DayDate from
    ltb_Bills as b
    left outer join ltb_Calender as d on d.DayDate_fuib = b.DayDate_fuib;
  commit work;
  
  if @DebugMode <> 0 then select getdate() as Timer_Insert_TurnIn from dbo.iq_dummy end if;
  
  select b.ClientID,
    c.N_month,
    c.YM,
    Sum(isnull(MainAmount,0.0)) as AmountIn
    into #TurnIn
    from ltb_Bills as b
      left outer join ltb_Calender as c on b.DayDate = c.DayDate
    group by b.ClientID,c.N_month,c.YM;
  commit work;
  
  update ltb_Bills as b
    set b.flag = 0 from
    ltb_Bills as b
    where b.DebitState = b.CreditState
    and b.DebitTopic in ( 2600,2610,2650,2651 )   
    and b.CreditTopic in ( 2600,2610,2650,2651 ) ;  
  commit work;
  
  update ltb_Bills as b
    set b.flag = 0 from
    ltb_Bills as b
    where 1 = 1
    and b.DebitTopic=2900  
    and(right(b.DebitCode,3) <> 'UAH'
    or b.SourceCode = '334851');
  commit work;
  
  
  
   ---------------------------------
    ---for fiz liz start
---------------------------------  
    update ltb_Bills as b
    set b.flag = 0 from
    ltb_Bills as b
    where b.DebitState = b.CreditState
    and b.DebitTopic in (2620,2630,2635)  
    and b.CreditTopic in (2620,2630,2635) ;  
  commit work;
    
  update ltb_Bills as b
    set b.flag = 0 from
    ltb_Bills as b
    where 1 = 1
    and b.DebitTopic = 2900  ----для фл!! ???валютные счета исключать? 
    and(right(b.DebitCode,3) <> 'UAH'
    or b.SourceCode = '334851');
  commit work;
    -----------------------
      ---for fiz liz end
  ---------------
      
  
  
  insert into ltb_TurnOut( ClientID,N_month,YM,AmountOut ) 
    select b.ClientID,
      c.N_month,
      c.YM,
      sum(MainAmount) as AmountOut
      from ltb_Bills as b
        join ltb_Calender as c on b.DayDate = c.DayDate
      where b.flag = 0
      group by b.ClientID,
      c.N_month,
      c.YM;
  commit work;
  
  if @DebugMode <> 0 then select getdate() as Timer_update_Clients from dbo.iq_dummy end if;
  
  update ltb_Clients as cl
    set cl.N_0 = d._Turnover,
    cl.N_2 = d._Turnover2,
    cl.N_3 = d._Turnover3,
    cl.N_4 = d._Turnover4 from
    ltb_Clients as cl
    join(select i.ClientId,
      max(case when i.N_month = 1 then(isnull(AmountIn,0.0)-isnull(o.AmountOut,0.0)) end) as _Turnover,
      max(case when i.N_month = 2 then(isnull(AmountIn,0.0)-isnull(o.AmountOut,0.0)) end) as _Turnover2,
      max(case when i.N_month = 3 then(isnull(AmountIn,0.0)-isnull(o.AmountOut,0.0)) end) as _Turnover3,
      max(case when i.N_month = 4 then(isnull(AmountIn,0.0)-isnull(o.AmountOut,0.0)) end) as _Turnover4
      from #TurnIn as i
        left outer join ltb_TurnOut as o on i.ClientId = o.ClientId and i.N_month = o.N_month
      group by i.ClientId) as d on cl.ClientId = d.ClientId;
  commit work;
  
  select b.ClientID,sum(b.AmountIn) as MainAmount
    into #Summ
    from #TurnIn as b
    where N_month in( 1,2,3 ) 
    group by b.ClientID;
  commit work;
  
  select @Date_from as D1,
    @Date_fuib as D2,
    c.ClientId,
    c.ExtId,
    c.ClientCode,
    c.Name,
    c.StateCode,
    c.Segment,
    c.RiskFlag,
    c.RiskDesc,
    c.IsOpenAcc,
    max(isnull(c.N_0,0.0)) as Month_N,
    max(isnull(c.N_2,0.0)) as Month_N_2,
    max(isnull(c.N_3,0.0)) as Month_N_3,
    max(isnull(c.N_4,0.0)) as Month_N_4,
    convert(decimal(18,2),(Month_N_2+Month_N_3+Month_N_4)/3) as AvgMonth,
    convert(decimal(18,2),isnull(Month_N/nullif(AvgMonth,0),0.0)) as perc,
    s.MainAmount as Sum_all_3month
    into #ltb_result
    from ltb_Clients as c
      left outer join #Summ as s on s.ClientId = c.ClientId
    group by c.ClientId,
    c.ExtId,
    c.ClientCode,
    c.Name,
    c.RC,
    c.StateCode,
    c.Segment,
    c.RiskDesc,
    c.RiskFlag,
    c.IsOpenAcc,
    s.MainAmount
    order by c.ClientId asc;
  commit work;
  
  if @DebugMode <> 0 then select getdate() as Timer_END from dbo.iq_dummy end if;
  
  select r.D1,
    r.D2,
    r.ClientId,
    r.ExtId,
    r.ClientCode,
    r.Name,
    r.StateCode,
    r.Segment,
    r.RiskFlag,
    r.RiskDesc,
    r.IsOpenAcc,
    r.Month_N,
    r.Month_N_2,
    r.Month_N_3,
    r.Month_N_4,
    r.AvgMonth,
    r.perc,
    r.Sum_all_3month,
    dfm.Act_lev,
    dfm.Segment_DFM
    from #ltb_result as r
      left outer join #ltb_segment_dfm as dfm on dfm.segment = r.segment
      and dfm.RiskFlag = r.riskflag
      and dfm.lower_bound <= r.AvgMonth
      and dfm.upper_bound > r.AvgMonth
end