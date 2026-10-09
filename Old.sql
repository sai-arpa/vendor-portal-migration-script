---- revisedQuotationItemDetail (item, make) duplicates in quotatioNo 
--- 1
SELECT
    RevisedQuotationNo ,
    itemNo,
    COALESCE(rfqmakeNo, 0) AS make_id,
    COUNT(*) AS cnt
FROM purchase.RevisedQuotationItemDetail
GROUP BY
    RevisedQuotationNo ,
    itemNo,
    COALESCE(rfqmakeNo, 0)
HAVING COUNT(*) > 1
ORDER BY cnt DESC;


---- Check IndentItem and RFQIndent
SELECT
    cd.RFQIndentDetailNo ,
    cd.IndentNo,
    cd.IndentItemLineNo,
    cd.ItemNo  AS CD_ItemNo,
    iid.ItemNo AS IID_ItemNo,
    cd.MakeNo  AS CD_MakeNo,
    iid.MakeNo AS IID_MakeNo
FROM purchase.RFQIndentDetail cd
INNER JOIN inventory.IndentItemDetail iid
    ON iid.IndentNo = cd.IndentNo
    AND iid.IndentItemLineNo = cd.IndentItemLineNo
WHERE
    cd.ItemNo <> iid.ItemNo
    OR ISNULL(cd.MakeNo, '') <> ISNULL(iid.MakeNo, '');

--- Check qty rfqIndentDetail and rfqItemDEtail
select count(*) from (
SELECT
    I.RFQNo,
    I.ItemNo,
    I.MakeNo,
    I.Qty,
    ISNULL(D.TotalRFQQty, 0) AS TotalRFQQty,
    I.Qty - ISNULL(D.TotalRFQQty, 0) AS Difference
FROM Purchase.RFQItemDetail I
LEFT JOIN
(
    SELECT
        RFQNo,
        ItemNo,
        MakeNo,
        SUM(RFQQty) AS TotalRFQQty
    FROM Purchase.RFQIndentDetail
    GROUP BY
        RFQNo,
        ItemNo,
        MakeNo
) D
    ON D.RFQNo = I.RFQNo
    AND D.ItemNo = I.ItemNo
    AND ISNULL(D.MakeNo, 0) = ISNULL(I.MakeNo, 0)
WHERE
    I.Qty <> ISNULL(D.TotalRFQQty, 0)
) x;

--- Check email and contactNo with multivalues
SELECT mvc.VendorContactNo 
FROM purchase.RFQVendorDetail mvc
WHERE mvc.VendorContactNo LIKE '%,%' or mvc.VendorContactNo LIKE '%;%' or mvc.VendorContactNo LIKE '%/%';


SELECT mvc.ContactEmail, mvc.CreatedDate 
FROM purchase.RFQMain mvc
WHERE LEN(ContactEmail) - LEN(REPLACE(ContactEmail, '@', '')) >= 2
order by mvc.Createddate desc;


--- check tables that has columns in condition
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'purchase'
  AND (
        LOWER(COLUMN_NAME) LIKE '%mail%'
        OR LOWER(COLUMN_NAME) LIKE '%contactno%'
        OR LOWER(COLUMN_NAME) LIKE '%mobileno%'
        OR LOWER(COLUMN_NAME) LIKE '%phoneno%'
      )
ORDER BY TABLE_NAME, ORDINAL_POSITION;


----Po amendment indent detail , (indentNo,indentItemLineNo) duplicates
SELECT
    pid.POAmendmentIndentDetailNo,
    pid.IndentNo,
    pid.IndentItemLineNo,
    COUNT(*) AS duplicate_count
FROM purchase.POAmendmentIndentDetail pid
GROUP BY
    pid.POAmendmentIndentDetailNo,
    pid.IndentNo,
    pid.IndentItemLineNo
HAVING COUNT(*) > 1
ORDER BY
    pid.POAmendmentIndentDetailNo,
    pid.IndentNo,
    pid.IndentItemLineNo;

---- Every PoAmendmentIndentDetail must match to one and only one record in indentItemDetail
SELECT
    pid.POAmendmentIndentDetailNo,
    pid.IndentNo,
    pid.IndentItemLineNo,
    COALESCE(i.iid_count, 0) AS iid_count
FROM purchase.POAmendmentIndentDetail pid
LEFT JOIN
(
    SELECT
        IndentNo,
        IndentItemLineNo,
        COUNT(*) AS iid_count
    FROM inventory.IndentItemDetail
    GROUP BY
        IndentNo,
        IndentItemLineNo
) i
    ON i.IndentNo = pid.IndentNo
    AND i.IndentItemLineNo = pid.IndentItemLineNo
WHERE COALESCE(i.iid_count, 0) <> 1
ORDER BY
    pid.POAmendmentIndentDetailNo,
    pid.IndentNo,
    pid.IndentItemLineNo;


--- Po Item and indent Detail Check
select * from purchase.POAmendmentIndentDetail pid
left join from purchase.


---- IndetItemDetail duplicated check  (962 duplicates, but they have differe indentItemLineNo)
SELECT
    pid.IndentNo,
    pid.itemNo,
    pid.MakeNo,
    COUNT(*) AS duplicate_count
FROM inventory.indentItemDetail pid
GROUP BY
	pid.IndentNo,
    pid.itemNo,
    pid.MakeNo
HAVING COUNT(*) > 1
ORDER BY
    pid.IndentNo,
    pid.itemNo,
    pid.MakeNo;

--- PoAmendmentIndentDetail and PoAmendmentItemDetail Check (Every row in poAmendmentIndentDetail should match one row in poAmendmentItemDetail)
select count(*)
from purchase.POAmendmentIndentDetail pid 
left join purchase.POAmendmentItemDetail pid2 
on pid.POAmendmentNo = pid2.POAmendmentNo 
and pid.ItemNo = pid2.ItemNo 
and coalesce(pid.makeNo,0) = coalesce(pid2.makeNo,0)
where pid.POAmendmentNo is null

----------- CS Checks

-- check if CsIndentDetail has duplicate (indentNo, indentItemLineNo)
select
	cd.CSIndentDetailNo,
	cd.IndentNo ,
	cd.IndentItemLineNo,
	count(*) as cnt
from purchase.CSIndentDetail cd
left join inventory.IndentItemDetail iid 
	on iid.IndentNo = cd.IndentNo 
	and iid.IndentItemLineNo =cd.IndentItemLineNo 
group by 
	cd.CSIndentDetailNo,
	cd.IndentNo ,
	cd.IndentItemLineNo 
having count(*)>1

--- Check CsIndent and indentItem (existence)
SELECT
    count(*)
FROM purchase.CSIndentDetail cd
INNER JOIN inventory.IndentItemDetail iid
    ON iid.IndentNo = cd.IndentNo
    AND iid.IndentItemLineNo = cd.IndentItemLineNo
WHERE
    iid.IndentNo is null

--- Check CsIndent and IndentItem (item, make)
SELECT
    cd.CSIndentDetailNo,
    cd.IndentNo,
    cd.IndentItemLineNo,
    cd.ItemNo  AS CD_ItemNo,
    iid.ItemNo AS IID_ItemNo,
    cd.MakeNo  AS CD_MakeNo,
    iid.MakeNo AS IID_MakeNo
FROM purchase.CSIndentDetail cd
INNER JOIN inventory.IndentItemDetail iid
    ON iid.IndentNo = cd.IndentNo
    AND iid.IndentItemLineNo = cd.IndentItemLineNo
WHERE
    cd.ItemNo <> iid.ItemNo
    OR ISNULL(cd.MakeNo, '') <> ISNULL(iid.MakeNo, '');

--- Check CsIndent and RfqIndent (item, make)
SELECT
    cd.CSIndentDetailNo,
    cd.IndentNo,
    cd.IndentItemLineNo,
    cd.ItemNo  AS CD_ItemNo,
    iid.ItemNo AS IID_ItemNo,
    cd.MakeNo  AS CD_MakeNo,
    iid.MakeNo AS IID_MakeNo
FROM purchase.CSIndentDetail cd
INNER JOIN purchase.RFQIndentDetail iid
    ON iid.IndentNo  = cd.IndentNo
    AND iid.IndentItemLineNo = cd.IndentItemLineNo
WHERE
    cd.ItemNo <> iid.ItemNo
    OR ISNULL(cd.MakeNo, '') <> ISNULL(iid.MakeNo, '');
--
--CSIndentDetailNo	IndentNo	IndentItemLineNo	CD_ItemNo	IID_ItemNo	CD_MakeNo	IID_MakeNo
--7818	             9571	        2.000	            32030	   32030		         669
--16810	             15491	        3.000	            11130	   11130		         669
--16821	             15492	        1.000	            11130	   11130       669	
--37197	             32605	        13.000	            58315	   58315 	   669	


---- Check CSQuotationDetail---

select count(*) from Purchase.CSQuotationDetail cd 
left join purchase.RevisedQuotationItemDetail rqid
on rqid.RevisedQuotationNo = cd.RevisedQuotationNo 
and rqid.ItemNo = cd.ItemNo 
and isNUll(rqid.rfqmakeNo,0) =isNUll(cd.makeNo,0)




---- QUotation Amount/tax Verification -----

---- Item Quantity × Rate should equal TotalAmount (857)
select count(*) from (
SELECT
    RevisedQuotationItemNo,
    RevisedQuotationNo,
    ItemNo,
    MakeNo,
    Quantity,
    Rate,
    TotalAmount,
    ROUND(Quantity * Rate, 4) AS CalculatedTotalAmount,
    ROUND(TotalAmount - (Quantity * Rate), 4) AS Difference
FROM Purchase.RevisedQuotationItemDetail
WHERE
    TotalAmount <> ROUND(Quantity * Rate, 4)
    OR (TotalAmount IS NULL AND Rate IS NOT NULL)
    OR (TotalAmount IS NOT NULL AND Rate IS NULL)
) x;

---RevisedQuotationMain.BasicAmount vs sum of item TotalAmount (127)
select count(*) from (
SELECT
    RQM.RevisedQuotationNo,
    RQM.BasicAmount,
    ISNULL(I.TotalAmount, 0) AS CalculatedBasicAmount,
    ROUND(
        RQM.BasicAmount - ISNULL(I.TotalAmount, 0),
        4
    ) AS Difference
FROM Purchase.RevisedQuotationMain RQM
LEFT JOIN
(
    SELECT
        RevisedQuotationNo,
        SUM(TotalAmount) AS TotalAmount
    FROM Purchase.RevisedQuotationItemDetail
    GROUP BY RevisedQuotationNo
) I
    ON I.RevisedQuotationNo = RQM.RevisedQuotationNo
WHERE
    RQM.BasicAmount <> ISNULL(I.TotalAmount, 0)
    OR (RQM.BasicAmount IS NULL AND ISNULL(I.TotalAmount, 0) <> 0)
    OR (RQM.BasicAmount IS NOT NULL AND I.TotalAmount IS NULL)
) x;

--- Header Tax vs Item Tax bifurcation (59)
select count(*) from (
SELECT
    H.RevisedQuotationNo,
    H.MiscChargeNo,
    H.TotalValue AS HeaderTotalValue,
    ISNULL(I.TotalAmount, 0) AS ItemTotalAmount,
    ROUND(
        H.TotalValue - ISNULL(I.TotalAmount, 0),
        4
    ) AS Difference
FROM
(
    SELECT
        RevisedQuotationNo,
        MiscChargeNo,
        SUM(TotalValue) AS TotalValue
    FROM Purchase.RevisedQuotationTaxDetail
    GROUP BY
        RevisedQuotationNo,
        MiscChargeNo
) H
LEFT JOIN
(
    SELECT
        RevisedQuotationNo,
        MiscChargeNo,
        SUM(TotalAmount) AS TotalAmount
    FROM Purchase.RevisedQuotationItemTaxDetail
    GROUP BY
        RevisedQuotationNo,
        MiscChargeNo
) I
    ON I.RevisedQuotationNo = H.RevisedQuotationNo
    AND I.MiscChargeNo = H.MiscChargeNo
WHERE
    H.TotalValue <> ISNULL(I.TotalAmount, 0)
    OR (H.TotalValue IS NULL AND ISNULL(I.TotalAmount, 0) <> 0)
) x;


--- Header Other Charge vs Item Other Charge bifurcation (1347)
select count(*) from (
SELECT
    H.RevisedQuotationNo,
    H.OtherChargeNo,
    H.Amount AS HeaderAmount,
    ISNULL(I.Amount, 0) AS ItemAmount,
    ROUND(
        H.Amount - ISNULL(I.Amount, 0),
        4
    ) AS Difference
FROM
(
    SELECT
        RevisedQuotationNo,
        OtherChargeNo,
        SUM(Amount) AS Amount
    FROM Purchase.RevisedQuotationOtherChargeDetail
    GROUP BY
        RevisedQuotationNo,
        OtherChargeNo
) H
LEFT JOIN
(
    SELECT
        RevisedQuotationNo,
        OtherChargeNo,
        SUM(Amount) AS Amount
    FROM Purchase.RevisedQuotationItemOtherChargeDetail
    GROUP BY
        RevisedQuotationNo,
        OtherChargeNo
) I
    ON I.RevisedQuotationNo = H.RevisedQuotationNo
    AND I.OtherChargeNo = H.OtherChargeNo
WHERE
    H.Amount <> ISNULL(I.Amount, 0)
    OR (H.Amount IS NULL AND ISNULL(I.Amount, 0) <> 0)
) x;


--select count(*) from purchase.RevisedQuotationMain 
--- RevisedQuotationMain.TaxAmount validation (160978)
select count(*) from (
SELECT
    RQM.RevisedQuotationNo,
    RQM.TaxAmount,
    ISNULL(T.TaxAmount, 0) + ISNULL(O.OtherChargeAmount, 0) AS CalculatedTaxAmount,
    ROUND(
        RQM.TaxAmount
        - (
            ISNULL(T.TaxAmount, 0)
            + ISNULL(O.OtherChargeAmount, 0)
        ),
        4
    ) AS Difference
FROM Purchase.RevisedQuotationMain RQM
LEFT JOIN
(
    SELECT
        RQT.RevisedQuotationNo,
        SUM(
            CASE
                WHEN MC.CalculationNature = 1
                    THEN RQT.TotalValue
                WHEN MC.CalculationNature = 2
                    THEN -RQT.TotalValue
                ELSE RQT.TotalValue
            END
        ) AS TaxAmount
    FROM Purchase.RevisedQuotationTaxDetail RQT
    INNER JOIN masterdata.mMiscCharges MC
        ON MC.MiscChargeNo = RQT.MiscChargeNo
    GROUP BY
        RQT.RevisedQuotationNo
) T
    ON T.RevisedQuotationNo = RQM.RevisedQuotationNo
LEFT JOIN
(
    SELECT
        RQO.RevisedQuotationNo,
        SUM(
            CASE
                WHEN QOC.CalculationNature = 1
                    THEN RQO.Amount
                WHEN QOC.CalculationNature = 2
                    THEN -RQO.Amount
                ELSE RQO.Amount
            END
        ) AS OtherChargeAmount
    FROM Purchase.RevisedQuotationOtherChargeDetail RQO
    INNER JOIN GlobalData.QuotationOtherCharges QOC
        ON QOC.QuotationOtherChargesNo = RQO.OtherChargeNo
    GROUP BY
        RQO.RevisedQuotationNo
) O
    ON O.RevisedQuotationNo = RQM.RevisedQuotationNo
WHERE
    RQM.TaxAmount <>
        (
            ISNULL(T.TaxAmount, 0)
            + ISNULL(O.OtherChargeAmount, 0)
        )
) x;


--- NetAmount validation from underlying details
select count(*) from (
SELECT
    RQM.RevisedQuotationNo,
    RQM.NetAmount,
    ISNULL(I.BasicAmount, 0)
    + ISNULL(T.TaxAmount, 0)
    + ISNULL(O.OtherChargeAmount, 0)
        AS CalculatedNetAmount,
    ROUND(
        RQM.NetAmount
        - (
            ISNULL(I.BasicAmount, 0)
            + ISNULL(T.TaxAmount, 0)
            + ISNULL(O.OtherChargeAmount, 0)
        ),
        4
    ) AS Difference
FROM Purchase.RevisedQuotationMain RQM
LEFT JOIN
(
    SELECT
        RevisedQuotationNo,
        SUM(TotalAmount) AS BasicAmount
    FROM Purchase.RevisedQuotationItemDetail
    GROUP BY RevisedQuotationNo
) I
    ON I.RevisedQuotationNo = RQM.RevisedQuotationNo
LEFT JOIN
(
    SELECT
        RQT.RevisedQuotationNo,
        SUM(
            CASE
                WHEN MC.CalculationNature = 1
                    THEN RQT.TotalValue
                WHEN MC.CalculationNature = 2
                    THEN -RQT.TotalValue
                ELSE 0
            END
        ) AS TaxAmount
    FROM Purchase.RevisedQuotationTaxDetail RQT
    INNER JOIN masterdata.mMiscCharges MC
        ON MC.MiscChargeNo = RQT.MiscChargeNo
    GROUP BY RQT.RevisedQuotationNo
) T
    ON T.RevisedQuotationNo = RQM.RevisedQuotationNo
LEFT JOIN
(
    SELECT
        RQO.RevisedQuotationNo,
        SUM(
            CASE
                WHEN QOC.CalculationNature = 1
                    THEN RQO.Amount
                WHEN QOC.CalculationNature = 2
                    THEN -RQO.Amount
                ELSE 0
            END
        ) AS OtherChargeAmount
    FROM Purchase.RevisedQuotationOtherChargeDetail RQO
    INNER JOIN GlobalData.QuotationOtherCharges QOC
        ON QOC.QuotationOtherChargesNo = RQO.OtherChargeNo
    GROUP BY RQO.RevisedQuotationNo
) O
    ON O.RevisedQuotationNo = RQM.RevisedQuotationNo
WHERE
    RQM.NetAmount <>
        (
            ISNULL(I.BasicAmount, 0)
            + ISNULL(T.TaxAmount, 0)
            + ISNULL(O.OtherChargeAmount, 0)
        )
) x;


---- Update createdBy, modifiedBy, AuthorizedBy of quotation (set 1 if they don't exist in login)
UPDATE qm
SET qm.CreatedBy = 1
FROM Purchase.RevisedQuotationMain qm
LEFT JOIN security.Login l
    ON l.LoginNo = qm.CreatedBy
WHERE qm.CreatedBy IS NOT NULL
  AND l.LoginNo IS NULL;


UPDATE qm
SET qm.AuthorizedBy = 1
FROM Purchase.RevisedQuotationMain qm
LEFT JOIN security.Login l
    ON l.LoginNo = qm.AuthorizedBy
WHERE qm.AuthorizedBy IS NOT NULL
  AND l.LoginNo IS NULL;


UPDATE qm
SET qm.ModifiedBy = 1
FROM Purchase.RevisedQuotationMain qm
LEFT JOIN security.Login l
    ON l.LoginNo = qm.ModifiedBy
WHERE qm.ModifiedBy IS NOT NULL
  AND l.LoginNo IS NULL;


---- po pr detail and po item detail join verification (98)

---po pr and po item multiple match check
SELECT
    paid.POAmendmentIndentDetailNo ,
    paid.POAmendmentNo,
--    paid.IndentNo,
--    paid.IndentItemLineNo,
    paid.ItemNo,
    paid.MakeNo,
    COUNT(*) AS MatchingPOItemCount
FROM purchase.POAmendmentIndentDetail paid
INNER JOIN purchase.POAmendmentItemDetail poid
    ON poid.POAmendmentNo  = paid.POAmendmentNo
    AND poid.itemNo = paid.ItemNo
    AND COALESCE(poid.makeNo, 0) = COALESCE(paid.MakeNo, 0)
GROUP BY
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
--    paid.IndentNo,
--    paid.IndentItemLineNo,
    paid.ItemNo,
    paid.MakeNo
HAVING COUNT(*) > 1
ORDER BY
    MatchingPOItemCount DESC;


-- po item detail duplicate check
select poid.poamendmentNo, poid.itemNo,
    poid.makeNo ,count(*)
from purchase.POAmendmentItemDetail poid 
group by 
    poid.POAmendmentNo ,
    poid.itemNo,
    poid.makeNo
having count(*)>1


-- popr and po item exisistence check

select count(*)
from purchase.POAmendmentIndentDetail pid
left join purchase.POAmendmentItemDetail pid2 
on pid.POAmendmentNo = pid2.POAmendmentNo 
and pid.itemNo =pid2.itemNo
and coalesce(pid.makeNo,0)=coalesce(pid2.makeNo,0)
where pid2.POAmendmentItemDetailNo is null


--- Auction related

select distinct am.BasePriceSettingNo   from purchase.AuctionMain am;


---- Approval Process Related

--Indent 

SELECT b.AuthGrpRevisionNo, a.*
FROM inventory.IndentAuthorizationDetail a
LEFT JOIN inventory.IndentMain b
    ON a.IndentNo = b.IndentNo
WHERE b.AuthGrpRevisionNo IS NULL;

update Inventory.IndentMain
set AuthGrpRevisionNo =120
where IndentNo =87582

select * from Inventory.indentMain iad 
where iad.IndentNo =87582

select distinct statusNo from Inventory.IndentAuthorizationDetail iad 

select a.IndentNo, s.StatusName , a.* FROM inventory.IndentAuthorizationDetail a
left join GlobalData.Status s
on s.StatusNo = a.StatusNo 
where s.StatusNo =9
order by a.IndentNo

select count(*) from inventory.indentMain where AuthGrpRevisionNo is not null

select count(*) FROM inventory.IndentAuthorizationDetail a

---check if each level is sequential or not
WITH DistinctLevels AS
(
    SELECT DISTINCT
        IndentNo,
        LevelNo
    FROM Inventory.IndentAuthorizationDetail
    WHERE IndentNo IS NOT NULL
      AND LevelNo IS NOT NULL
),
LevelCheck AS
(
    SELECT
        IndentNo,
        LevelNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY IndentNo
            ORDER BY LevelNo
        ) AS ExpectedLevelNo
    FROM DistinctLevels
)
SELECT
    IndentNo,
    LevelNo,
    ExpectedLevelNo
FROM LevelCheck
WHERE LevelNo <> ExpectedLevelNo
ORDER BY
    IndentNo,
    LevelNo;

-- check if isReady is true, then all statusNo is 5
SELECT
    IndentNo,
    LevelNo,
    COUNT(*) AS TotalApprovers,
    SUM(CASE WHEN StatusNo = 5 THEN 1 ELSE 0 END) AS Status5Count,
    SUM(CASE WHEN StatusNo <> 5 OR StatusNo IS NULL THEN 1 ELSE 0 END) AS InvalidStatusCount
FROM Inventory.IndentAuthorizationDetail
WHERE IsReady = 1
GROUP BY
    IndentNo,
    LevelNo
HAVING
    SUM(CASE WHEN StatusNo <> 5 OR StatusNo IS NULL THEN 1 ELSE 0 END) > 0
ORDER BY
    IndentNo,
    LevelNo;



--- Purchase Order

---check if each level is sequential or not
WITH DistinctLevels AS
(
    SELECT DISTINCT
        POAmendmentNo ,
        LevelNo
    FROM purchase.poamendmentauthorizationdetail
    WHERE POAmendmentNo  IS NOT NULL
      AND LevelNo IS NOT NULL
),
LevelCheck AS
(
    SELECT
        POAmendmentNo ,
        LevelNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY POAmendmentNo 
            ORDER BY LevelNo
        ) AS ExpectedLevelNo
    FROM DistinctLevels
)
SELECT
    POAmendmentNo ,
    LevelNo,
    ExpectedLevelNo
FROM LevelCheck
WHERE LevelNo <> ExpectedLevelNo
ORDER BY
    POAmendmentNo ,
    LevelNo;

-- check if isReady is true, then all statusNo is 5
SELECT
    POAmendmentNo,
    LevelNo,
    COUNT(*) AS TotalApprovers,
    SUM(CASE WHEN StatusNo = 5 THEN 1 ELSE 0 END) AS Status5Count,
    SUM(CASE WHEN StatusNo <> 5 OR StatusNo IS NULL THEN 1 ELSE 0 END) AS InvalidStatusCount
FROM purchase.poamendmentauthorizationdetail
WHERE IsReady = 1
GROUP BY
    POAmendmentNo ,
    LevelNo
HAVING
    SUM(CASE WHEN StatusNo <> 5 OR StatusNo IS NULL THEN 1 ELSE 0 END) > 0
ORDER BY
    POAmendmentNo ,
    LevelNo;


select distinct statusNo from purchase.poamendmentauthorizationdetail


--------------------------------------- Rough Work ----------------------------------------------

select * from masterdata.mItemMaster mim where mim.itemNo=4711;
 
select * from GlobalData.POPurchaseCategory pc 

select sum(netAmount) from inventory.indentMain

--- QUotation revision -----
WITH Revision0 AS (
    SELECT
        m.QuotationNo,
        COUNT(d.RevisedQuotationItemNo) AS ItemCount
    FROM purchase.revisedquotationmain m
    JOIN purchase.revisedquotationitemdetail d
        ON d.RevisedQuotationNo = m.RevisedQuotationNo
    WHERE m.RevisedNo = 0
    GROUP BY m.QuotationNo
),
LaterRevisions AS (
    SELECT
        m.QuotationNo,
        m.RevisedQuotationNo,
        COUNT(d.RevisedQuotationItemNo) AS ItemCount
    FROM purchase.revisedquotationmain m
    JOIN purchase.revisedquotationitemdetail d
        ON d.RevisedQuotationNo = m.RevisedQuotationNo
    WHERE m.RevisedNo > 0
    GROUP BY
        m.QuotationNo,
        m.RevisedQuotationNo
)
SELECT DISTINCT
    r.QuotationNo
FROM Revision0 r
JOIN LaterRevisions lr
    ON lr.QuotationNo = r.QuotationNo
WHERE lr.ItemCount <> r.ItemCount
ORDER BY r.QuotationNo;


--- find count of quotations
WITH Revision0 AS (
    SELECT
        m.QuotationNo,
        COUNT(d.RevisedQuotationItemNo) AS ItemCount
    FROM purchase.revisedquotationmain m
    JOIN purchase.revisedquotationitemdetail d
        ON d.RevisedQuotationNo = m.RevisedQuotationNo
    WHERE m.RevisedNo = 0
    GROUP BY m.QuotationNo
),
LaterRevisions AS (
    SELECT
        m.QuotationNo,
        m.RevisedQuotationNo,
        COUNT(d.RevisedQuotationItemNo) AS ItemCount
    FROM purchase.revisedquotationmain m
    JOIN purchase.revisedquotationitemdetail d
        ON d.RevisedQuotationNo = m.RevisedQuotationNo
    WHERE m.RevisedNo > 0
    GROUP BY
        m.QuotationNo,
        m.RevisedQuotationNo
),
MismatchedQuotations AS (
    SELECT DISTINCT
        r.QuotationNo
    FROM Revision0 r
    JOIN LaterRevisions lr
        ON lr.QuotationNo = r.QuotationNo
    WHERE lr.ItemCount <> r.ItemCount
)
SELECT COUNT(*) AS MismatchedQuotationCount
FROM MismatchedQuotations;



select count(*) 
from purchase.revisedQuotationItemTaxDetail ritd
left join purchase.revisedQuotationItemDetail rid
on ritd.revisedQuotationNo = rid.revisedQuotationNo
and ritd.itemNo = rid.itemNo
and coalesce(ritd.makeNo,0) = coalesce(rid.makeNo,0)
where rid.revisedQuotationNo is null




select distinct dueDate from inventory.indentItemDetail

select rfqd.IndentItemDetailNo , count(1) FROM purchase.rfqItemDetail rfqd
group by rfqd.IndentItemDetailNo
having count(1)>1


select distinct qm.createdBy  from purchase.RevisedQuotationMain qm
left join security.Login l
on l.LoginNo  = qm.createdBY
where l.loginNo is null

select distinct qm.authorizedBy  from purchase.RevisedQuotationMain qm
left join security.Login l
on l.LoginNo  = qm.authorizedBy
where l.loginNo is null

select distinct qm.modifiedBY  from purchase.RevisedQuotationMain qm
left join security.Login l
on l.LoginNo  = qm.modifiedBY
where l.loginNo is null



select cpm.DocumentNoYearly, cpm.createdDate from purchase.ChangePOStatusMain cpm 
order by cpm.DocumentNoYearly desc


select distinct usertype from [Security].[Login] l;

select count(*) from [Security].[Login] l 
where l.UserType =1

SELECT COUNT(DISTINCT l.LoginNo)
FROM security.login l
INNER JOIN security.loginvendorlocationdetail supplier
    ON supplier.LoginNo = l.LoginNo;

























---------------------------------------------------- PO Item Duplicate Work -------------------------------------------------------------
Select PO.PONo,PID.ItemNo,PID.MakeNo,PO.DocumentDate,PO.PORefDocumentTypeNo,po.RefDocumentNo, count(distinct quantity) as isQtySame, Count(1)
from Purchase.poItemDetaiL PID
Inner Join Purchase.poMain PO on PO.PONo=PID.PONo
where PO.PORefDocumentTypeNo=3
Group by PO.PONo,PID.ItemNo,PID.MakeNo,PO.DocumentDate,PO.PORefDocumentTypeNo,po.RefDocumentNo
Having count(1)=2
and count(distinct quantity)=1
order by 1
 
 
Select PO.POAmendmentNo,PID.ItemNo,PID.MakeNo,PO.DocumentDate,PO.PORefDocumentTypeNo,po.RefDocumentNo, count(distinct quantity) as isQtySame, Count(1)
from Purchase.POAmendmentItemDetaiL PID
Inner Join Purchase.POAmendmentMain PO on PO.POAmendmentNo=PID.POAmendmentNo
where PO.PORefDocumentTypeNo=3
Group by PO.POAmendmentNo,PID.ItemNo,PID.MakeNo,PO.DocumentDate,PO.PORefDocumentTypeNo,po.RefDocumentNo
Having count(1)>1
and count(distinct quantity)=1
order by 1


select poAmendmentItemDetailNo, poamendmentNo, itemNo, makeNo, techspecification, quantity, rate from purchase.poamendmentItemDetail
where poamendmentNo=21400 and
itemNo=32659;

--select * from purchase.poamendmentIndentDetail
--where poamendmentNo=20398 and
--itemNo=6820

select poAmendmentItemOtherChargeNo, poamendmentNo, itemNo, makeNo, amount from purchase.poamendmentItemOtherChargeDetail
where poamendmentNo=20398 and
itemNo=6820

select poAmendmentItemTaxNo, poamendmentNo, itemNo, makeNo, totalAMount from purchase.poamendmentItemTaxDetail
where poamendmentNo=20398 and
itemNo=6820

select poAmendmentISDetailNo, poamendmentNo, itemNo, makeNo, scheduleQty from purchase.poamendmentItemScheduleDetail
where poamendmentNo=20398 and
itemNo=6820


update purchase.poamendmentItemDetail
set makeNo=669
where poamendmentItemDetailNo=68802

update purchase.poamendmentItemOtherChargeDetail
set makeNo=669
where poamendmentitemOtherChargeNo=

update purchase.poamendmentItemTaxDetail
set makeNo=669
where poamendmentitemTaxNo=144092

update purchase.poamendmentItemScheduleDetail
set makeNo=669
where poamendmentISDetailNo=83867


update purchase.poItemDetail
set makeNo=669
where poItemDetailNo=68802

update purchase.poItemOtherChargeDetail
set makeNo=669
where poitemOtherChargeNo=

update purchase.poItemTaxDetail
set makeNo=669
where poitemTaxNo=144092

update purchase.poItemScheduleDetail
set makeNo=669
where POItemScheduleDetailNo =83867





-----------------------------------------------------------------------------------------------------

BEGIN TRANSACTION;

IF OBJECT_ID('tempdb..#PODuplicates') IS NOT NULL
    DROP TABLE #PODuplicates;

SELECT
    PID.PONo,
    PID.ItemNo,
    PID.MakeNo
INTO #PODuplicates
FROM Purchase.POItemDetail PID
INNER JOIN Purchase.POMain PO
    ON PO.PONo = PID.PONo
WHERE PO.PORefDocumentTypeNo = 3
GROUP BY
    PID.PONo,
    PID.ItemNo,
    PID.MakeNo
HAVING COUNT(1) > 1
   AND COUNT(DISTINCT PID.Quantity) = 1;


IF OBJECT_ID('tempdb..#POItemsToUpdate') IS NOT NULL
    DROP TABLE #POItemsToUpdate;

SELECT
    X.POItemDetailNo,
    X.PONo,
    X.ItemNo,
    X.MakeNo
INTO #POItemsToUpdate
FROM
(
    SELECT
        PID.POItemDetailNo,
        PID.PONo,
        PID.ItemNo,
        PID.MakeNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY PID.PONo, PID.ItemNo, PID.MakeNo
            ORDER BY PID.POItemDetailNo
        ) AS RN
    FROM Purchase.POItemDetail PID
    INNER JOIN #PODuplicates D
        ON D.PONo = PID.PONo
       AND D.ItemNo = PID.ItemNo
       AND D.MakeNo = PID.MakeNo
) X
WHERE X.RN = 1;

UPDATE PID
SET MakeNo = 669
FROM Purchase.POItemDetail PID
INNER JOIN #POItemsToUpdate U
    ON U.POItemDetailNo = PID.POItemDetailNo;

;WITH CTE AS
(
    SELECT
        OCD.POItemOtherChargeNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                OCD.PONo,
                OCD.ItemNo,
                OCD.MakeNo
            ORDER BY OCD.POItemOtherChargeNo
        ) AS RN
    FROM Purchase.POItemOtherChargeDetail OCD
    INNER JOIN #POItemsToUpdate U
        ON U.PONo = OCD.PONo
       AND U.ItemNo = OCD.ItemNo
       AND U.MakeNo = OCD.MakeNo
)
UPDATE OCD
SET MakeNo = 669
FROM Purchase.POItemOtherChargeDetail OCD
INNER JOIN CTE C
    ON C.POItemOtherChargeNo = OCD.POItemOtherChargeNo
WHERE C.RN = 1;

;WITH CTE AS
(
    SELECT
        TD.POItemTaxNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                TD.PONo,
                TD.ItemNo,
                TD.MakeNo
            ORDER BY TD.POItemTaxNo
        ) AS RN
    FROM Purchase.POItemTaxDetail TD
    INNER JOIN #POItemsToUpdate U
        ON U.PONo = TD.PONo
       AND U.ItemNo = TD.ItemNo
       AND U.MakeNo = TD.MakeNo
)
UPDATE TD
SET MakeNo = 669
FROM Purchase.POItemTaxDetail TD
INNER JOIN CTE C
    ON C.POItemTaxNo = TD.POItemTaxNo
WHERE C.RN = 1;

;WITH CTE AS
(
    SELECT
        SD.POItemScheduleDetailNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                SD.PONo,
                SD.ItemNo,
                SD.MakeNo
            ORDER BY SD.POItemScheduleDetailNo
        ) AS RN
    FROM Purchase.POItemScheduleDetail SD
    INNER JOIN #POItemsToUpdate U
        ON U.PONo = SD.PONo
       AND U.ItemNo = SD.ItemNo
       AND U.MakeNo = SD.MakeNo
)
UPDATE SD
SET MakeNo = 669
FROM Purchase.POItemScheduleDetail SD
INNER JOIN CTE C
    ON C.POItemScheduleDetailNo = SD.POItemScheduleDetailNo
WHERE C.RN = 1;




----------


IF OBJECT_ID('tempdb..#POAmendmentDuplicates') IS NOT NULL
    DROP TABLE #POAmendmentDuplicates;

SELECT
    PID.POAmendmentNo,
    PID.ItemNo,
    PID.MakeNo
INTO #POAmendmentDuplicates
FROM Purchase.POAmendmentItemDetail PID
INNER JOIN Purchase.POAmendmentMain PO
    ON PO.POAmendmentNo = PID.POAmendmentNo
WHERE PO.PORefDocumentTypeNo = 3
GROUP BY
    PID.POAmendmentNo,
    PID.ItemNo,
    PID.MakeNo
HAVING COUNT(1) > 1
   AND COUNT(DISTINCT PID.Quantity) = 1;

IF OBJECT_ID('tempdb..#POAmendmentItemsToUpdate') IS NOT NULL
    DROP TABLE #POAmendmentItemsToUpdate;

SELECT
    X.POAmendmentItemDetailNo,
    X.POAmendmentNo,
    X.ItemNo,
    X.MakeNo
INTO #POAmendmentItemsToUpdate
FROM
(
    SELECT
        PID.POAmendmentItemDetailNo,
        PID.POAmendmentNo,
        PID.ItemNo,
        PID.MakeNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                PID.POAmendmentNo,
                PID.ItemNo,
                PID.MakeNo
            ORDER BY PID.POAmendmentItemDetailNo
        ) AS RN
    FROM Purchase.POAmendmentItemDetail PID
    INNER JOIN #POAmendmentDuplicates D
        ON D.POAmendmentNo = PID.POAmendmentNo
       AND D.ItemNo = PID.ItemNo
       AND D.MakeNo = PID.MakeNo
) X
WHERE X.RN = 1;

UPDATE PID
SET MakeNo = 669
FROM Purchase.POAmendmentItemDetail PID
INNER JOIN #POAmendmentItemsToUpdate U
    ON U.POAmendmentItemDetailNo = PID.POAmendmentItemDetailNo;

;WITH CTE AS
(
    SELECT
        OCD.POAmendmentItemOtherChargeNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                OCD.POAmendmentNo,
                OCD.ItemNo,
                OCD.MakeNo
            ORDER BY OCD.POAmendmentItemOtherChargeNo
        ) AS RN
    FROM Purchase.POAmendmentItemOtherChargeDetail OCD
    INNER JOIN #POAmendmentItemsToUpdate U
        ON U.POAmendmentNo = OCD.POAmendmentNo
       AND U.ItemNo = OCD.ItemNo
       AND U.MakeNo = OCD.MakeNo
)
UPDATE OCD
SET MakeNo = 669
FROM Purchase.POAmendmentItemOtherChargeDetail OCD
INNER JOIN CTE C
    ON C.POAmendmentItemOtherChargeNo = OCD.POAmendmentItemOtherChargeNo
WHERE C.RN = 1;

;WITH CTE AS
(
    SELECT
        TD.POAmendmentItemTaxNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                TD.POAmendmentNo,
                TD.ItemNo,
                TD.MakeNo
            ORDER BY TD.POAmendmentItemTaxNo
        ) AS RN
    FROM Purchase.POAmendmentItemTaxDetail TD
    INNER JOIN #POAmendmentItemsToUpdate U
        ON U.POAmendmentNo = TD.POAmendmentNo
       AND U.ItemNo = TD.ItemNo
       AND U.MakeNo = TD.MakeNo
)
UPDATE TD
SET MakeNo = 669
FROM Purchase.POAmendmentItemTaxDetail TD
INNER JOIN CTE C
    ON C.POAmendmentItemTaxNo = TD.POAmendmentItemTaxNo
WHERE C.RN = 1;

;WITH CTE AS
(
    SELECT
        SD.POAmendmentISDetailNo,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                SD.POAmendmentNo,
                SD.ItemNo,
                SD.MakeNo
            ORDER BY SD.POAmendmentISDetailNo
        ) AS RN
    FROM Purchase.POAmendmentItemScheduleDetail SD
    INNER JOIN #POAmendmentItemsToUpdate U
        ON U.POAmendmentNo = SD.POAmendmentNo
       AND U.ItemNo = SD.ItemNo
       AND U.MakeNo = SD.MakeNo
)
UPDATE SD
SET MakeNo = 669
FROM Purchase.POAmendmentItemScheduleDetail SD
INNER JOIN CTE C
    ON C.POAmendmentISDetailNo = SD.POAmendmentISDetailNo
WHERE C.RN = 1;


--COMMIT;
--ROLLBACK;

BEGIN TRANSACTION;

DROP TABLE IF EXISTS #POItemsToUpdate;

WITH DuplicateGroups AS
(
    SELECT
        PID.PONo,
        PID.ItemNo,
        PID.MakeNo
    FROM Purchase.POItemDetail PID
    INNER JOIN Purchase.POMain PO
        ON PO.PONo = PID.PONo
    WHERE PO.PORefDocumentTypeNo = 3
    GROUP BY
        PID.PONo,
        PID.ItemNo,
        PID.MakeNo
    HAVING COUNT(*) = 2
       AND COUNT(DISTINCT PID.Quantity) = 1
),
RankedRows AS
(
    SELECT
        PID.POItemDetailNo,
        PID.PONo,
        PID.ItemNo,
        PID.MakeNo,
        PID.Quantity,
        ROW_NUMBER() OVER
        (
            PARTITION BY PID.PONo, PID.ItemNo, PID.MakeNo
            ORDER BY PID.POItemDetailNo
        ) AS rn
    FROM Purchase.POItemDetail PID
    INNER JOIN DuplicateGroups D
        ON D.PONo = PID.PONo
       AND D.ItemNo = PID.ItemNo
       AND (
            D.MakeNo = PID.MakeNo
            OR (D.MakeNo IS NULL AND PID.MakeNo IS NULL)
       )
)
SELECT
    POItemDetailNo,
    PONo,
    ItemNo,
    MakeNo,
    Quantity
INTO #POItemsToUpdate
FROM RankedRows
WHERE rn = 1;


UPDATE PID
SET PID.MakeNo = 669
FROM Purchase.POItemDetail PID
INNER JOIN #POItemsToUpdate U
    ON U.POItemDetailNo = PID.POItemDetailNo;


UPDATE C
SET C.MakeNo = 669
FROM Purchase.poItemOtherChargeDetail C
INNER JOIN #POItemsToUpdate U
    ON U.PONo = C.PONo
   AND U.ItemNo = C.ItemNo
   AND (
        U.MakeNo = C.MakeNo
        OR (U.MakeNo IS NULL AND C.MakeNo IS NULL)
   );


UPDATE
	T
SET
	T.MakeNo = 669
FROM
	Purchase.poItemTaxDetail T
INNER JOIN #POItemsToUpdate U
    ON
	U.PONo = T.PONo
	AND U.ItemNo = T.ItemNo
	AND (
        U.MakeNo = T.MakeNo
		OR (U.MakeNo IS NULL
			AND T.MakeNo IS NULL)
   );


UPDATE S
SET S.MakeNo = 669
FROM Purchase.poItemScheduleDetail S
INNER JOIN #POItemsToUpdate U
    ON U.PONo = S.PONo
   AND U.ItemNo = S.ItemNo
   AND (
        U.MakeNo = S.MakeNo
        OR (U.MakeNo IS NULL AND S.MakeNo IS NULL)
   );



Select count(*)
From Purchase.RevisedQuotationItemDetail RID
Inner Join Purchase.RevisedQuotationMain RQ on RQ.RevisedQuotationNo= RID.RevisedQuotationNo
Where Not Exists (
					Select 1 
					From Purchase.RFQItemDetail RD
					Where RD.RFQNo=RQ.RFQNo
					And RD.Itemno=RID.ItemNo
					and isnull(Rd.MakeNo,0)=isnull(RId.rfqMakeNo,0)
				  )
	
				  
				  
				  
				  
SELECT
    COUNT(*) AS unmatched_rows,
    COUNT(DISTINCT RID.RevisedQuotationNo) AS affected_quotations,
    COUNT(DISTINCT RQ.RFQNo) AS affected_rfqs
FROM Purchase.RevisedQuotationItemDetail RID
INNER JOIN Purchase.RevisedQuotationMain RQ
    ON RQ.RevisedQuotationNo = RID.RevisedQuotationNo
WHERE NOT EXISTS
(
    SELECT 1
    FROM Purchase.RFQItemDetail RD
    WHERE RD.RFQNo = RQ.RFQNo
      AND RD.ItemNo = RID.ItemNo
      AND ISNULL(RD.MakeNo,0) = ISNULL(RID.RFQMakeNo,0)
);

SELECT TOP 100
    RQ.RFQNo,
    COUNT(*) AS unmatched_item_rows
FROM Purchase.RevisedQuotationItemDetail RID
INNER JOIN Purchase.RevisedQuotationMain RQ
    ON RQ.RevisedQuotationNo = RID.RevisedQuotationNo
WHERE NOT EXISTS
(
    SELECT 1
    FROM Purchase.RFQItemDetail RD
    WHERE RD.RFQNo = RQ.RFQNo
      AND RD.ItemNo = RID.ItemNo
      AND ISNULL(RD.MakeNo,0) = ISNULL(RID.RFQMakeNo,0)
)
GROUP BY RQ.RFQNo
ORDER BY COUNT(*) DESC;
				  
SELECT
    p2.poamendmentno,
    p2.levelno,
    p2.isready
FROM purchase.poamendmentauthorizationdetail p2
INNER JOIN purchase.poamendmentmain i
    ON i.poamendmentno = p2.poamendmentno
WHERE i.documentstatusno = 10
  AND i.isreadyforauthorization <> 1
  AND p2.isready=1
ORDER BY
    p2.poamendmentno,
    p2.levelno;

--
--update Purchase.CSMain
--set documentStatusNo=10

select * from Purchase.CSAuthorizationDetail cd 
where cd.CSNo  in (7379,7417,7420,8017,8056,8152,8476,9234,9282,9424,9445,10680,11223,11225,11483,11734,11823,12062,12346,14724,14746,15184,16275,16276,17013,17713,18632,24371,25111,26502,27991,30900,38146,40873,42832,53342)
--
--
--update Purchase.CSAuthorizationDetail cd 
--set statusNo=1, ModifiedDate 


;WITH LevelStatus AS (
    SELECT
        d.CSNo,
        d.LevelNo,
        SUM(CASE WHEN d.StatusNo = 1 THEN 1 ELSE 0 END) AS ApprovedCount
    FROM Purchase.csAuthorizationDetail d
    WHERE d.CSNo IN (
        7379, 8017, 8056, 8152, 8476, 9234, 9282, 9424,
        9445, 11223, 11225, 11483, 11734, 12062, 12346,
        14724, 14746, 15184, 16275, 16276, 17013, 17713,
        18632, 24371, 25111, 26502, 27991, 30900, 38146,
        40873, 42832, 53342
    )
    GROUP BY
        d.CSNo,
        d.LevelNo
),
FirstReady AS (
    SELECT
        d.CSAuthorizationDetailNo,
        d.CSNo,
        d.LevelNo,
        ROW_NUMBER() OVER (
            PARTITION BY d.CSNo, d.LevelNo
            ORDER BY d.CSAuthorizationDetailNo
        ) AS rn
    FROM Purchase.csAuthorizationDetail d
    INNER JOIN LevelStatus ls
        ON ls.CSNo = d.CSNo
       AND ls.LevelNo = d.LevelNo
    WHERE ls.ApprovedCount = 0
      AND d.IsReady = 1
),
FixRows AS (
    SELECT
        fr.CSAuthorizationDetailNo,
        fr.CSNo,
        fr.LevelNo,
        prev.ModifiedDate AS NewModifiedDate
    FROM FirstReady fr
    OUTER APPLY (
        SELECT TOP (1)
            d.ModifiedDate
        FROM Purchase.csAuthorizationDetail d
        WHERE d.CSNo = fr.CSNo
          AND d.LevelNo < fr.LevelNo
          AND d.StatusNo = 1
        ORDER BY
            d.LevelNo DESC,
            d.CSAuthorizationDetailNo DESC
    ) prev
    WHERE fr.rn = 1
)
UPDATE d
SET
    d.StatusNo = 1,
    d.ModifiedDate = f.NewModifiedDate
FROM Purchase.csAuthorizationDetail d
INNER JOIN FixRows f
    ON f.CSAuthorizationDetailNo = d.CSAuthorizationDetailNo;



----- tnc group code fix
WITH numbered AS (
    SELECT
        Code,
        ROW_NUMBER() OVER (ORDER BY TermsNConditionGroupNo) AS rn
    FROM masterdata.mtermsnconditiongroup
)
UPDATE numbered
SET Code = 'TG' + RIGHT('0000' + CAST(rn AS varchar(4)), 4);


----- State Master fix
update masterdata.mStateMaster
set code = 'ANA'
where StateNo = 61

update masterdata.mStateMaster
set code = 'ANB'
where StateNo = 62

update masterdata.mStateMaster
set code = 'LDI'
where StateNo = 28

update masterdata.mStateMaster
set code = 'ADA'
where StateNo = 60



select * from purchase.POAmendmentRejectionHistory prh 

select * from Purchase.POAmendmentAuthorizationDetail t 
where t.POAmendmentNo =68456

select * from masterdata.mDivisionMaster mdm 
where mdm.DivisionCode in ('AU', 'BD','SM')

--update masterdata.mDivisionMaster
--set DivisionCode = 'AU1'
--where DivisionNo =116
--
--update masterdata.mDivisionMaster
--set DivisionCode = 'BD1'
--where DivisionNo =118
--
--update masterdata.mDivisionMaster
--set DivisionCode = 'SM1'
--where DivisionNo =125

--975	    VC10848	VIJIT GAURAHA
--12309	VC10848	KUMAR TRADERS
--976  	VC10849	RAVISH (VENDOR)
--12310	VC10849	VRISA METALS INDUSTRIES
--576	    VC10850	CALCUTTA PIPE FITTINGS
--12311	VC10850	JAI MAA MAHA KALI FULES
--569	    VC10851	J_TEST
--12312	VC10851	R P METAL
--1019	VC10852	INDO SALES AGENCY
--12313	VC10852	PRIYADARSHI ENGINEERING
--
--
--12323

--
--update masterdata.mVendorCard
--set code = 'VC12324'
--where vendorNo = 12309
--
--update masterdata.mVendorCard
--set code = 'VC12325'
--where vendorNo = 12310
--
--update masterdata.mVendorCard
--set code = 'VC12326'
--where vendorNo = 12311
--
--update masterdata.mVendorCard
--set code = 'VC12327'
--where vendorNo = 12312
--
--update masterdata.mVendorCard
--set code = 'VC12328'
--where vendorNo = 12313


select * from purchase.POAmendmentIndentDetail pid 
where pid.IndentNo  in (93682, 93683);

select im.DocumentStatusNo  from Inventory.IndentMain im 
where im.IndentNo  in (93682, 93683);

select * from Purchase.CSIndentDetail cd 
where cd.IndentNo in (93682, 93683);

select top 1 * from masterdata.mDivisionMaster order by DivisionNo desc

update Inventory.IndentMain
set DivisionNo = 132
where IndentNo in (93682, 93683);

--update Purchase.revisedQuotationMain
--set authorizedBy=1
--where not exists (select 1 from security.login l where l.LoginNo = revisedQuotationNo)


UPDATE rqm
SET CreatedBy = 1
FROM Purchase.RevisedQuotationMain rqm
WHERE rqm.CreatedBy IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM Security.Login l
      WHERE l.LoginNo = rqm.CreatedBy
  );

UPDATE rqm
SET ModifiedBy = 1
FROM Purchase.RevisedQuotationMain rqm
WHERE rqm.ModifiedBy IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM Security.Login l
      WHERE l.LoginNo = rqm.ModifiedBy
  );


delete FROM  ERPMaster.eCostCenterMaster
where ERPCostCenterNo =1444


update ERPMaster.eVendorLocationDetail
set panNo=null
where ERPVendorLocationNo  =50826


update inventory.indentMain
set authgrprevisionno=120
where indentno =87582

