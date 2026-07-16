GO

/****** Object:  View [Finance].[vw_ai_PurchaseBillItemDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--================================================
-- Author : Alok
-- Create Date : 03 Jul 2027
-- Description : Purchase Bill Item Detail for AI
--================================================
CREATE view [Finance].[vw_ai_PurchaseBillItemDetail]
As
Select PID.PurchaseBillItemDetailNo,PID.PurchaseBillNo
,PID.GRNNo,PID.POAmendmentNo,PID.ItemNo,PID.MakeNo,PID.ChallanQty,PID.Qty,PID.BasicAmount
,IM.ItemDescription,MM.MakeName,MW.WareHouseName,MW.WareHouseNo,PM.PONo 
From   Finance.PurchaseBillItemDetail  PID
Inner Join masterdata.mItemMaster IM On IM.ItemNo = PID.ItemNo 
Left Join masterdata.mMakeMaster MM On MM.MakeNo = PID.MakeNo 
Left Join masterdata.mWarehouse MW On MW.WareHouseNo = PID.WarehouseNo 
Left Join Purchase .POAmendmentMain POAM On POAM.POAmendmentNo = PID.POAmendmentNo 
Left Join Purchase.POMain PM On PM.PONo = POAM.PONo
GO

/****** Object:  View [Finance].[vw_ai_PurchaseBillMain]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
-- =============================================
-- Author:	Alok
-- Description:	Purchase Bill View Created For AI Sql Experiment
-- Date : 02 Jul 2026
-- =============================================
CREATE view [Finance].[vw_ai_PurchaseBillMain] as
Select PBM.CompanyNo
,CM.AliasName [CompanyAlias]
,FB.FBNo
,FB.FinanceBookName
,PBM.PurchaseBillNo
,Mf.YearNo  [YearNo]
,Mf.YearName [YearName]
,PBM.DocumentNoYearly
,PBM.DocumentDate
,VLD.VendorNo,VLD.VendorLocationNo
,VLD.VendorName,VLD.FullAddress
,PBM.VendorbillNo,PBM.VendorBillDate 
,PBM.NetAmount  ,PBM.VendorBillAmount,PM.PaymentMode,PS.DueDate
	,PBM.CreatedBy  
	,PBM.CreatedDate
	,SL.LoginID [CreatedByLoginId]
	,SL.PrintingName [CreatedByPrintingName]
	,PBM.AuthorizedBy
	,PBM.AuthorizedDate
	,SLI.LoginID [AuthorizedByLoginId]
	,SLI.PrintingName [AuthorizedByPrintingName],PBm.DocumentStatusNo,DS.DocumentStatusName
from  Finance.PurchaseBillMain PBM 
Inner Join Globaldata.PaymentMode PM On PM.PaymentModeNo= PBM.PaymentModeNo
Inner Join masterdata.mCompanyMaster CM On CM.CompanyNo = PBM.CompanyNo  
Inner Join Masterdata.mFBMain FB on FB.FBNo=pbm.FBNo
inner Join  masterdata.mVendorLocationDetail VLD On VLD.VendorLocationNo = PBM.VendorLocationNo 
Left Join Finance.PaymentSchedule  PS On PS.DocumentNo= PBM.PurchaseBillNo And PS.DocumentType  ='PBPB' 
Inner Join Security.Login SL On SL.LoginNo = PBM.CreatedBy 
Left Join Security.Login SLI On SLI.LoginNo = PBM.AuthorizedBy 
Inner Join GlobalData.DocumentStatus DS on DS.DocumentStatusNo=PBM.DocumentStatusNo
Inner Join Masterdata.mFYear MF on MF.YearNo=PBM.YearNo


GO

/****** Object:  View [Inventory].[vw_ai_GRNItemDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Alok
-- Description:	GRN Item View Created For AI Sql Experiment
-- Date : 07 Jul 2026
-- =============================================
CREATE view [Inventory].[vw_ai_GRNItemDetail] as
Select  
 GID.GRNItemDetailNo,GID.GRNNo,GID.POAmendmentNo,PA.PONo,POID.POItemDetailNo,
 GID.GateEntryNo,GID.ItemNo,IM.ItemDescription
 ,GID.MakeNo,MM.MakeName
 ,GID.UnitNo
 ,UM.Alias [UnitName]
 ,gID.TechnicalSpecification
 ,GID.ChallanQty,GID.ReceivedQty,GID.RejectedQty,GID.AcceptedQty,GID.FOCQty,GID.Rate,gID.FirstCF,GID.SecondCF
 ,GID.WareHouseNo,GID.RouteIdentity,GID.InvStockTransferNo,GID.ItemFlowNo 
 From Inventory.GRNItemDetail GID
 Inner Join Inventory.GRNMain  gm on GM.GRNNo=GID.GRNNo
 Left Join Purchase.POAmendmentMain PA on PA.POAmendmentNo=GId.POAmendmentNo
 Left Join Purchase.POAmendmentItemDetail PID on PID.POAmendmentNo=GID.POAmendmentNo 
											   And PID.ItemNo=GID.ItemNo
											   And ((PID.MakeNo=GID.MakeNo) Or (PID.MakeNo is null and GID.MakeNo is null ))
											   And ((PID.TechnicalGradeNo=GID.TechnicalGradeNo) Or (PID.TechnicalGradeNo is null and GID.TechnicalGradeNo is null ))
 Left Join Purchase.POItemDetail POID on POID.PONo=PA.PONo
										And POID.ItemNo=PID.ItemNo
										And ((POID.MakeNo=PID.MakeNo) Or (POID.MakeNo is null and PID.MakeNo is null ))
										And ((POID.TechnicalGradeNo=PID.TechnicalGradeNo) Or (POID.TechnicalGradeNo is null and PID.TechnicalGradeNo is null ))
 Inner Join Masterdata.mUnitMaster UM on UM.UnitNo=GID.UnitNo
 Inner Join Masterdata.mItemMaster im on im.ItemNo=GID.ItemNo
 LEft Join Masterdata.mMakeMaster MM on MM.MakeNo=gID.MakeNo
  
GO

/****** Object:  View [Inventory].[vw_ai_GRNItemIndentDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Alok
-- Description:	GRN Item View Created For AI Sql Experiment
-- Date : 07 Jul 2026
-- =============================================
CREATE view [Inventory].[vw_ai_GRNItemIndentDetail] as
Select  
GIND.GRNIndentDetailNo,GIND.GRNNo,GIND.IndentNo,GIND.AcceptedQty,GIND.RejectedQty,GIND.WareHouseNo,WH.WareHouseName
, GIND.GRNItemDetailNo,GIND.IndentMakeNo,GIND.IMSTInvLotSummaryNo,gIND.SCReqNo,GIND.[UID]
 From Inventory.GRNItemIndentDetail GIND
 Left Join Masterdata.mWarehouse WH on WH.WareHouseNo=GIND.WareHouseNo
GO

/****** Object:  View [Inventory].[vw_ai_GrnMain]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
-- =============================================
-- Author:	Alok
-- Description:	GRN Main View Created For AI Sql Experiment
-- Date : 02 Jul 2026
-- =============================================
CREATE view [Inventory].[vw_ai_GrnMain] as

Select  
gm.GRNNo
,GM.CompanyNo,CM.AliasName [CompanyAlias]
,gM.DivisionNo,Div.DivisionName
,Gm.GRNTypeNo
,gm.FormCode
,
(case When gm.GRNTypeNo=1 and FormCode='IGRN' Then 'MRN'
              When gm.GRNTypeNo=2 and FormCode='IGRN' Then 'MRA'
			  When FormCode ='SCMR' Then 'SRN' end
) As DocumentType
,Vld.VendorNo,VLD.VendorLocationNo
,Mf.YearNo  [YearNo]
,Mf.YearName [YearName]
,gm.DocumentNoYearly ,
gm.DocumentDate  
,gm.VendorBillNo as VendorBillNo ,
gm.VendorBilldate ,
gm.ChallanNo ,
gm.ChallanDate,
gm.GRNSourceNo,grns.SourceDocument ,FT.FreightType,FT.FreightTypeNo
,GM.DocumentStatusNo,DS.DocumentStatusName
,GM.InspectionRequired
 From Inventory.GRNMain  gm
Inner Join Masterdata.mFYear MF on MF.YearNo=gm.YearNo
 Inner Join Masterdata.mVendorLocationDetail VLD on VLd.VendorLocationNo=GM.VendorLocationNo
 Inner Join masterdata.mCompanyMaster CM on CM.CompanyNo=gm.CompanyNo
 Inner Join GlobalData.GRNSourceDcoument GRNs on GRNS.GRNSourceNo=gm.GRNSourceNo
 Left Join payroll.tblDivisionMaster Div on Div.DivisionNo=gm.DivisionNo 
 Left Join Security.login sl on sl.loginNo = gm.CreatedBy
 Left Join Security.login s2 on s2.loginNo = gm.AuthorizedBy 
 Left Join payroll.tblDeptMaster dm on dm.DeptNo = gm.DeptNo
 Left Join masterdata.mLocationMaster FLM on FLM.LocationNo = gm.FromLocationNo 
 Left Join masterdata.mLocationMaster TLM on TLM.LocationNo = gm.ToLocationNo 
 Left Join GlobalData.FreightType FT on FT.FreightTypeNo = gm.FreightTypeNo
 Inner Join GlobalData.DocumentStatus DS on DS.DocumentStatusNo=gm.DocumentStatusNo

GO

/****** Object:  View [Inventory].[vw_ai_IndentItemDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 

-- ===================================================
-- Author:	Alok
-- Description:	Created For AI Experiment
-- Date : 02 July 2026
-- ===================================================
 
CREATE view  [Inventory].[vw_ai_IndentItemDetail] 
as 
  Select 
   IID.IndentItemDetailNo,
   IID.IndentNo,
   IID.ItemNo,
   mim.ItemDescription,
   IID.MakeNo,mmk.MakeName,iid.TechnicalGradeNo,
   IID.UnitNo,
   mum1.Alias [UnitAlias],
   iid.RequiredQty,
   iid.IndentQty,
   iid.Rate ,
   iid.IndentQty * iid.Rate [Amount],
   mccm.CostCenterNo,mccm.CostCenterName,
   iid.POQty,
   GRN.GRNQty [TotalGRNQty],
   GRN.FirstGRNDate,
   GRN.LastGRNDate,
   GRN.GRNCount ,IId.StatusNo,ST.StatusName
  From  Inventory.IndentItemDetail iid  
  Inner Join masterdata.mitemmaster mim on iid.ItemNo= mim.ItemNo	
  Left Join GlobalData.TechnicalGrade TG  On TG.TechnicalGradeNo = iid.TechnicalGradeNo 
  Inner Join masterdata.mUnitmaster mum1 on iid.UnitNo=mum1.UnitNo
  Left Join masterdata.mCostCenterMaster mccm on iid.CostCenterNo=mccm.CostCenterNo
  Left Join masterdata.mMakeMaster mmk on iid.MakeNo=mmk.MakeNo 
  Inner Join GlobalData.[Status] ST on ST.StatusNo=IId.StatusNo
  Left Join (
			   Select GIID.IndentNo
			   ,GID.ItemNo
			   ,piid.IndentMakeNo 
			   , GID.TechnicalGradeNo
			   ,SUM(GIID.AcceptedQty) as GRNQty
			   ,MAX(grn.DocumentDate) FirstGRNDate
			   ,MAX(grn.DocumentDate) LastGRNDate
			   ,Count(Distinct GID.GRNNo) GRNCount
			   from Inventory.GRNItemIndentDetail GIID 			   
			   Inner Join Inventory.GRNItemDetail GID On GID.GRNItemDetailNo = GIID.GRNItemDetailNo
			   INNER  join Inventory.GRNMain grn on grn.GRNNo = GID.GRNNo 
			   left join Purchase.POAmendmentIndentDetail piid on piid.POAmendmentNo = GID.POAmendmentNo 
							And piid.IndentNo=GIID.IndentNo
							And piid.ItemNo = GID.ItemNo 
							And (piid.MakeNo  =  GID.MakeNo or (piid.Makeno is null and gid.makeNo is null) )
			   Group by GIID.IndentNo,GID.ItemNo,piid.IndentMakeNo,GID.TechnicalGradeNo
			   having SUM(GIID.AcceptedQty) >0
             )GRN on GRN.IndentNo=iid.IndentNo 
			 and GRN.ItemNo=iid.ItemNo
			 and (GRN.IndentMakeNo = iid.MakeNo  or (grn.IndentMakeNo is null and iid.MakeNo is null))
GO

/****** Object:  View [Inventory].[vw_ai_IndentMain]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
-- =============================================
-- Author:	Alok
-- Description:	Purchase Indent View Created For AI Sql Experiment
-- Date : 02 Jul 2026
-- =============================================
CREATE view [Inventory].[vw_ai_IndentMain] 
as
	Select im.IndentNo
	,im.CompanyNo
	,mcm.AliasName [CompanyAlias]
	,im.DivisionNo 
	,div.DivisionCode 
	,Mf.YearNo  [YearNo]
	,Mf.YearName [YearName]
	, im.DocumentNoYearly 
	, im.DocumentDate 
	,Dept.DeptCode
	,Dept.DeptName
	,SD.IndentAgainstNo
	,SD.IndentAgainst
	,IT.IndentTypeNo
	,IT.IndentType
	,WH.WareHouseNo,WH.WareHouseName
	,IM.CreatedBy  
	,IM.CreatedDate
	,L1.LoginID [CreatedByLoginId]
	,L1.PrintingName [CreatedByPrintingName]
	,IM.ReleasedBy 
	,IM.ReleasedDate
	,L2.LoginID [ReleasedByLoginId]
	,L2.PrintingName [ReleasedByPrintingName]
	,IM.AuthorizedBy
	,IM.AuthorizedDate
	,L3.LoginID [AuthorizedByLoginId]
	,L3.PrintingName [AuthorizedByPrintingName]
	,IM.StatusNo,ST.StatusName
	,IM.DocumentStatusNo,DS.DocumentStatusName
  from inventory.indentmain IM
  Inner join  masterdata.mCompanyMaster mcm on mcm.CompanyNo=im.CompanyNo
  Left join payroll.tbldivisionmaster div on Im.divisionno = div.divisionno
  Inner Join Masterdata.mFYear MF on Mf.YearNo=Im.YearNo
  Inner join payroll.tbldeptmaster dept On Im.deptno = dept.deptno  
  Inner join GlobalData.IndentAgainst SD on sd.indentagainstno = im.indentagainstno
  Inner join globaldata.indenttype it on it.indenttypeno = im.indenttypeno
  Left join Security.login L1 on im.CreatedBy =L1.loginNo
  Left join Security.login L2 on im.ReleasedBy =L2.loginNo
  Left join Security.login L3 on im.AuthorizedBy  =L3.loginNo
  Left Join masterdata.mWarehouse WH on WH.WareHouseNo = IM.WareHouseNo 
  Inner Join GlobalData.DocumentStatus DS on DS.DocumentStatusNo=Im.DocumentStatusNo
  Inner Join GlobalData.Status ST on ST.StatusNo=Im.StatusNo
GO

/****** Object:  View [Inventory].[vw_ai_IssueItemDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Author      := Alok
-- Date        := 07 July 2026
-- Description := Material Issue Item Detail view for AI
-- =============================================================
CREATE View [Inventory].[vw_ai_IssueItemDetail]
As
Select 
MID.IssueItemDetailNo,MID.IssueNo ,IM.ItemNo,IM.ItemDescription,IM.FullCode ItemCode,MID.MakeNo,MM.MakeName
,MID.IssuedQty,MID.IssuedRate,MID.CostCenterNo,CC.CostCenterName
From Inventory.MaterialIssueItemDetail MID
Inner Join Masterdata.mItemMaster IM on IM.ItemNo=MID.ItemNo
Left Join Masterdata.mMakeMaster MM on MM.MakeNo=MID.MakeNo
Inner Join Masterdata.mUnitMaster UM on UM.UnitNo=IM.UnitNo
Left Join MAsterdata.mCostCenterMaster CC on CC.CostCenterNo=MID.CostCenterNo 
GO

/****** Object:  View [Inventory].[vw_ai_IssueMain]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
 
-- ============================================================
-- Author      := Alok
-- Date        := 07 July 2026
-- Description := Material Issue view for AI
-- =============================================================
CREATE View [Inventory].[vw_ai_IssueMain]
As
Select 
  IMIM.IssueNo   
   ,IMIM.CompanyNo
	,CM.AliasName [CompanyAlias]
	,IMIM.DivisionNo 
	,DM.DivisionCode 
	,Mf.YearNo  [YearNo]
	,Mf.YearName [YearName]
	, IMIM.DocumentNoYearly 
	, IMIM.DocumentDate  ,PDM.DeptNo ,PDM.DeptName
	,IMIM.IndentTypeNo IssueTypeNo
	,IDT.IndentType IssueTypeName
	,WM.WareHouseNo,WM.WareHouseName
	,IMIM.CreatedBy  
	,IMIM.CreatedDate
	,lgCr.LoginID [CreatedByLoginId]
	,lgCr.PrintingName [CreatedByPrintingName]
	,IMIM.ReleasedBy 
	,IMIM.ReleasedDate
	,lgRe.LoginID [ReleasedByLoginId]
	,lgRe.PrintingName [ReleasedByPrintingName]
	,IMIM.AuthorizedBy
	,IMIM.AuthorizedDate
	,lgAu.LoginID [AuthorizedByLoginId]
	,lgAu.PrintingName [AuthorizedByPrintingName]
	,IMIM.DocumentStatusNo,DS.DocumentStatusName
	,ISD.IssueSourceNo SourceDocumentNo,ISD.DocumentSource SourceDocumentName
	,IMIM.IsNonReturnable,IMIM.IsNonChargeable,ISL.IssueLabelNo,ISL.IssueLabelName,IMIM.IsOwnerShip
	,IMIM.VoucherNo
   From  Inventory.MaterialIssueMain IMIM
   Left Join payroll.tblDivisionMaster DM On DM.DivisionNo=IMIM.DivisionNo   
   Inner Join payroll.tblDeptMaster PDM On PDM.DeptNo=IMIM.DeptNo
   Inner Join Masterdata.mFYear MF on MF.YearNo=IMIM.YearNo
   Left Join masterdata.mWarehouse WM On WM.WarehouseNo=IMIM.WarehouseNo
   inner Join masterdata.mCompanyMaster CM On CM.CompanyNo =IMIM.CompanyNo 
   Inner Join GlobalData.IndentType IDT on IDT.IndentTypeNo = IMIM.IndentTypeNo
   Left Join Masterdata.mIssueLabelMaster ISL on ISL.IssueLabelNo=IMIM.IssueLabelNo
   Left Join Security.login lgCr on lgCr.LoginNo = IMIM.CreatedBy 
   Left Join Security.login lgRe on lgRe.LoginNo = IMIM.ReleasedBy 
   Left Join Security.login lgAu on lgAu.LoginNo = IMIM.AuthorizedBy 
   Inner Join GlobalData.MaterialIssueDocumentSource ISD on ISD.IssueSourceNo=IMIM.IssueSourceNo
   Inner Join GlobalData.DocumentStatus DS on DS.DocumentStatusNo=IMIM.DocumentStatusNo
GO

/****** Object:  View [Inventory].[vw_ai_MaterialReturnItemDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Author      := Alok
-- Date        := 07 July 2026
-- Description := Material Issue Item Detail view for AI
-- =============================================================
CREATE View [Inventory].[vw_ai_MaterialReturnItemDetail]
As
Select 
MID.ReturnItemDetailNo
,MID.ReturnNo 
,IM.ItemNo
,IM.ItemDescription
,IM.FullCode ItemCode
,MID.MakeNo
,MM.MakeName
,MID.Quantity
,MID.Rate
,MID.CostCenterNo
,CC.CostCenterName
,MID.IssueNo
From Inventory.MaterialReturnItemDetail MID
Inner Join Masterdata.mItemMaster IM on IM.ItemNo=MID.ItemNo
Left Join Masterdata.mMakeMaster MM on MM.MakeNo=MID.MakeNo
Inner Join Masterdata.mUnitMaster UM on UM.UnitNo=IM.UnitNo
Left Join masterdata.mCostCenterMaster CC on CC.CostCenterNo=MID.CostCenterNo 
GO

/****** Object:  View [Inventory].[vw_ai_MaterialReturnMain]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
-- ============================================================
-- Author      := Alok
-- Date        := 07 July 2026
-- Description := Material Return view for AI
-- =============================================================
CREATE View [Inventory].[vw_ai_MaterialReturnMain]
As
Select 
  MRM.ReturnNo   
   ,MRM.CompanyNo
	,CM.AliasName [CompanyAlias]
	,MRM.DivisionNo 
	,DM.DivisionCode 
	,Mf.YearNo  [YearNo]
	,Mf.YearName [YearName]
	, MRM.DocumentNoYearly 
	, MRM.DocumentDate  
	,PDM.DeptNo ,PDM.DeptName
	,WM.WareHouseNo,WM.WareHouseName
	,MRM.CreatedBy  
	,MRM.CreatedDate
	,lgCr.LoginID [CreatedByLoginId]
	,lgCr.PrintingName [CreatedByPrintingName]
	,MRM.ReleasedBy 
	,MRM.ReleasedDate
	,lgRe.LoginID [ReleasedByLoginId]
	,lgRe.PrintingName [ReleasedByPrintingName]
	,MRM.AuthorizedBy
	,MRM.AuthorizedDate
	,lgAu.LoginID [AuthorizedByLoginId]
	,lgAu.PrintingName [AuthorizedByPrintingName]
	,MRM.DocumentStatusNo,DS.DocumentStatusName
	,ISD.ReturnSourceNo SourceDocumentNo,ISD.SourceDocument SourceDocumentName
	,MRM.IsScrapReturn,MRM.ReturnInZeroValue
	,MRM.VoucherNo
   From  Inventory.MaterialReturnMain MRM
   Left Join payroll.tblDivisionMaster DM On DM.DivisionNo=MRM.DivisionNo   
   Inner Join payroll.tblDeptMaster PDM On PDM.DeptNo=MRM.DeptNo
   Inner Join Masterdata.mFYear MF on MF.YearNo=MRM.YearNo
   Left Join masterdata.mWarehouse WM On WM.WarehouseNo=MRM.WarehouseNo
   inner Join masterdata.mCompanyMaster CM On CM.CompanyNo =MRM.CompanyNo 
   Left Join Security.login lgCr on lgCr.LoginNo = MRM.CreatedBy 
   Left Join Security.login lgRe on lgRe.LoginNo = MRM.ReleasedBy 
   Left Join Security.login lgAu on lgAu.LoginNo = MRM.AuthorizedBy 
   Inner Join GlobalData.MaterialReturnSourceDocument ISD on ISD.ReturnSourceNo=MRM.ReturnSourceNo
   Inner Join GlobalData.DocumentStatus DS on DS.DocumentStatusNo=MRM.DocumentStatusNo
GO

/****** Object:  View [masterdata].[vw_ai_ItemMaster]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--================================================
-- Author : Alok
-- Create Date : 03 Jul 2027
-- Description : Item Master for AI
--================================================
CREATE view [masterdata].[vw_ai_ItemMaster]
As
SELECT    
IM.ItemNo,IM.ItemDescription,IM.FullCode ItemCode,Im.UnitNo,UM.Alias[UnitName]
,INA.Nature [ItemNature],Im.ItemNatureNo,Im.ItemTypeNo,IT.[Type] ItemTypeName
,SG.SubGroupName,Gm.GroupName,Cat.CategoryName
,SG.SubGroupNo,Gm.GroupNo,Cat.CategoryNo
,IOI.LeadTime
FROM masterdata.mItemMaster AS IM 
INNER JOIN GlobalData.ItemNature AS INA ON IM.ItemNatureNo = INA.ItemNatureNo 
INNER JOIN masterdata.mItemOtherInformation AS IOI ON IM.ItemNo = IOI.ItemNo 
INNER JOIN masterdata.mUnitMaster AS UM ON IM.UnitNo = UM.UnitNo 
INNER JOIN GlobalData.ItemType AS IT ON IM.ItemTypeNo = IT.ItemTypeNo
Inner Join Masterdata.mSubGroupMaster SG on SG.SubGroupNo=IM.SubGroupNo
Inner Join Masterdata.mGroupMaster GM on GM.GroupNo=SG.GroupNo
Inner Join Masterdata.mCategoryMaster Cat on Cat.CategoryNo=GM.CategoryNo
GO

/****** Object:  View [Purchase].[vw_ai_POIndentItemDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Alok
-- Description:	Purchase Order Indent Detail View Created For AI Sql Experiment
-- Date : 02 Jul 2026
-- =============================================
CREATE View [Purchase].[vw_ai_POIndentItemDetail]
As
Select 
PID.POIndentDetailNo,
PID.PONo,
PID.IndentNo,
PID.ItemNo,
PID.MakeNo,
PID.IndentMakeNo,
PID.TechnicalGradeNo,
PID.POQty,
PID.POUnitNo,
PID.FirstCF,
PID.SecondCF,PId.PORate,IID.IndentItemDetailNo
From Purchase.POIndentDetail PID
Inner Join Purchase.POItemDetail POID on PID.PONo=PID.PONo and PID.ItemNo=POID.ItemNo 
								      And (PID.MakeNo = POID.MakeNo And (PID.MakeNo is null and POID.MakeNo is Null ))
									  And (PID.TechnicalGradeNo = POID.TechnicalGradeNo And (PID.TechnicalGradeNo is null and POID.TechnicalGradeNo is Null ))
Inner Join inventory.indentItemDetail IID on IID.IndentNo=PID.IndentNo
									And IID.Itemno=PID.ItemNo
									And (IID.MakeNo=PID.MakeNo And ( IID.MakeNo is null and PID.MakeNo is null ))
									And (IID.TechnicalGradeNo=PID.TechnicalGradeNo And ( IID.TechnicalGradeNo is null and PID.TechnicalGradeNo is null ))
GO

/****** Object:  View [Purchase].[vw_ai_POItemDetail]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Alok
-- Description:	Purchase Order Item View Created For AI Sql Experiment
-- Date : 02 Jul 2026
-- =============================================
-- Select * from [Purchase].[vwdpPoitem] 
CREATE view [Purchase].[vw_ai_POItemDetail] as 

Select PID.POItemDetailNo,PID.PONo
,PID.ItemNo
,MIM.ItemDescription
,PID.MakeNo
,MM.MakeName
,PId.TechnicalGradeNo
,PID.UnitNo
,MUM.Alias [Unit]
,PID.Quantity
,PID.Rate
,PID.BasicAmount
,PID.NetAmount
,PID.StatusNo,St.StatusName
,CCM.CostCenterNo,CCM.CostCenterName
,GRN.ChallanQty,GRN.ReceivedQty,GRN.AcceptedQty,GRN.GRNCount
,PID.ToleranceBasisNo,PID.TolerancePlus,PId.ToleranceMinus
From Purchase.POItemDetail PID
Inner Join masterdata.mitemMaster MIM On MIM.ItemNo = PID.ItemNo
left join masterdata.mmakemaster MM On MM.MakeNo= PID.MakeNo
Inner Join masterdata.mUnitmaster MUM On MUM.UnitNo=PID.UnitNo
Inner Join GlobalData.Status ST on ST.StatusNo=PID.StatusNo
Left Join masterdata.mCostCenterMaster CCM on CCM.CostCenterNo = PID.CostCenterNo 
Left Join (
			Select PA.PONo,GID.ItemNo,GID.MakeNo,GID.TechnicalGradeNo
			,Sum(GId.ChallanQty) ChallanQty
			,Sum(GID.ReceivedQty) ReceivedQty
			,Sum(GID.AcceptedQty) AcceptedQty
			,Count(distinct GID.GRNNo) GRNCount
			From Inventory.GRNItemDetail GID
			Inner Join Purchase.POAmendmentMain PA on PA.POAmendmentNo=GID.POAmendmentNo
			Where (PA.IsTransportationRouteApplicable=1 And GID.RouteIdentity% 0.1=0)
			Or (PA.IsTransportationRouteApplicable=0)
			Group By  PA.PONo,GID.ItemNo,GID.MakeNo,GID.TechnicalGradeNo	 

           )GRN on GRN.PONo=PID.PONo
		   and GRN.ItemNo=PID.ItemNo
		   and (GRN.MakeNo=PID.MakeNo or (GRN.MakeNo is null or PID.MakeNo is Null))
		   And (GRN.TechnicalGradeNo=PID.TechnicalGradeNo Or (GRN.TechnicalGradeNo is null and PID.TechnicalGradeNo is null))
GO

/****** Object:  View [Purchase].[vw_ai_POMain]    Script Date: 11-07-2026 20:11:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
-- =============================================
-- Author:	Alok
-- Description:	Purchase Order View Created For AI Sql Experiment
-- Date : 02 Jul 2026
-- =============================================
CREATE View  [Purchase].[vw_ai_POMain]   as
Select 
PO.PONo
,PO.CompanyNo
,CM.AliasName [CompanyAlias]
,PO.DivisionNo 
,DM.DivisionCode 
,Mf.YearNo  [YearNo]
,Mf.YearName [YearName]
,PO.DocumentNoYearly 
,PO.DocumentDate 
,PAM.AmendmentNo [CurrentAmendmentNo]
,mcm.CurrencyNo
,mcm.[Name] [CurrencyName]
,GFT.FreightTypeNo,GFT.FreightType 
,PO.IndentTypeNo PurchaseTypeNo
,IT.IndentType PurchaseTypeName
,PO.CreatedBy
,PO.CreatedDate
,L1.LoginID CreatedByLoginId
,L1.PrintingName CreatedByPrintingName
,PO.AuthorizedBy
,PO.AuthorizedDate	
,L2.LoginId AuthorizedByLoginId
,L2.PrintingName AuthorizedByPrintingName
,PM.PaymentModeNo,PM.PaymentMode,PRD.PORefDocumentTypeNo,PRD.RefDocumentType PORefDocumentType
,PPC.POPurchaseCategoryNo,PPC.PurchaseCategory POPurchaseCategory
,GS.StatusNo,GS.StatusName,DST.DocumentStatusNo,DST.DocumentStatusName
,dmp.DeptNo,dmp.DeptName
,VLD.VendorNo,VLD.VendorLocationNo,VLD.VendorName
,VLD.FullAddress VendorFullAddress
,CNT.CountryNo VendorCountryNo,CNT.CountryName VendorCountryName
,ST1.StateNo VendorStateNo  ,ST1.StateName VendorStateName
,CT1.CityNo VendorCityNo ,CT1.CityName VendorCityName
,PO.ValidityDate,PO.NetAmount 
From    Purchase.POmain PO
Inner Join masterdata.mVendorLocationDetail VLD ON VLD.VendorLocationNo = PO.VendorLocationNo
Left Join Masterdata.mCountryMaster Cnt on Cnt.CountryNo=VLD.CountryNo
Left Join Masterdata.mStateMaster ST1 on ST1.StateNo=VLD.StateNo
Left Join Masterdata.mCityMaster CT1 on CT1.CityNo=VLD.CityNo
Inner Join Purchase.POAmendmentMain PAM on PAM.PONo=PO.PONo and PAM.AmendmentNo=PO.AmendmentNo												
Inner Join masterdata.mCompanymaster CM On CM.CompanyNo = PO.CompanyNo
left Join payroll.tblDivisionMaster DM On DM.DivisionNo = Po.DivisionNo
Inner Join Masterdata.mFYear MF on MF.YearNo=PO.YearNo
Inner Join masterdata.mCurrencyConversion CC On CC.CurrencyConversionNo = PO.CurrencyConversionNo 
inner Join  masterdata.mCurrencyMaster MCM On MCM.CurrencyNo = CC.ExchangeCurrencyNo  
Left Join GlobalData.FreightType GFT On GFT.FreightTypeNo = PO.FreightTypeNo 
left Join Security.login L1 on L1.loginNo=PO.createdBy
left Join Security.login L2 on L2.loginNo=PO.AuthorizedBy
Inner Join GlobalData.PaymentMode PM on PM.PaymentModeNo =PO.PaymentModeNo
Inner Join GlobalData.Status GS on GS.StatusNo=PO.StatusNo
Inner Join GlobalData.DocumentStatus DST on dST.DocumentStatusNo=PO.DocumentStatusNo
left JOin  payroll.tblDeptMaster DMP on DMP.DeptNo=PO.DeptNo
Left Join masterdata.mLocationMaster LM on LM.LocationNo=PO.FromLocationNo
Inner Join GlobalData.PORefDocumentType PRD on PRD.PORefDocumentTypeNo=PO.PORefDocumentTypeNo
Inner Join GlobalData.POPurchaseCategory PPC on PPC.POPurchaseCategoryNo=PO.POPurchaseCategoryNo
Inner Join GlobalData.IndentType IT On IT.IndentTypeNo = PO.IndentTypeNo
GO