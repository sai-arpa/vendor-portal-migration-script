SELECT 
    IM.DocumentNoYearly AS [Issue No.],
    IM.DocumentDate AS [Issue Date],
    IM.DeptName,
    IM.WareHouseName,
    IID.ItemDescription,
    IID.IssuedQty,
    IID.IssuedRate,
    IID.CostCenterName
FROM Inventory.vw_ai_IssueItemDetail IID
JOIN Inventory.vw_ai_IssueMain IM ON IID.IssueNo = IM.IssueNo
JOIN masterdata.vw_ai_ItemMaster IMST ON IID.ItemNo = IMST.ItemNo
WHERE IM.DocumentStatusName = 'Authorized'
AND IMST.CategoryName = 'Revenue'
AND IM.DocumentDate >= DATEADD(year, -1, GETDATE());