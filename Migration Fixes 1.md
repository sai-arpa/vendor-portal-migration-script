# Migration Fixes

## USER MASTER
- `NULL` and `0` values are replaced with `1`.

## DIVISION MASTER
- Query to fix duplicate division codes:

```sql
WITH cte AS
(
    SELECT
        divisionno,
        divisioncode,
        ROW_NUMBER() OVER (
            PARTITION BY divisioncode
            ORDER BY divisionno
        ) AS rn
    FROM masterdata.mdivisionmaster
)
UPDATE masterdata.mdivisionmaster d
SET divisioncode = cte.divisioncode + cte.rn
FROM cte
WHERE d.divisionno = cte.divisionno
  AND cte.rn > 1;
```

## GROUP MASTER 
- Updated the code for 27 groups 
```sql
;WITH CTE AS
(
    SELECT
        GroupNo, -- Primary Key
        ROW_NUMBER() OVER
        (
            PARTITION BY CategoryNo
            ORDER BY GroupNo
        ) AS RN
    FROM masterdata.mgroupmaster
    WHERE LEN(code) > 2
)
UPDATE GM
SET code = RIGHT('00' + CAST(CTE.RN AS VARCHAR(2)), 2)
FROM masterdata.mgroupmaster GM
INNER JOIN CTE
    ON GM.GroupNo = CTE.GroupNo;

```

## SUBGROUP MASTER
- Updated code for 23 Subgroups

```sql
;WITH CTE AS
(
    SELECT
        SubGroupNo, -- Primary Key
        ROW_NUMBER() OVER
        (
            PARTITION BY GroupNo
            ORDER BY SubGroupNo
        ) AS RN
    FROM masterdata.mSubGroupMaster
    WHERE LEN(code) > 2
)
UPDATE SGM
SET code = RIGHT('00' + CAST(CTE.RN AS VARCHAR(2)), 2)
FROM masterdata.mSubGroupMaster SGM
INNER JOIN CTE
    ON SGM.SubGroupNo = CTE.SubGroupNo;

```

## Lcoation Master
- Find duplicate and rank according to usage and update

```sql

select *
From (
Select LM.LocationName,LM.LocationNo,fl.cnt flcnt ,tl.cnt tlcnt
,DENSE_RANK() over (Partition By LM.LocationName Order By isnull(fl.cnt,0) + Isnull(tl.cnt,0) desc,EL.CNT desc , LM.LocationNo ) SNo
from RealDeals16062026.MAsterdata.mLocationMaster LM
Left Join ( 
		Select P.FromLocationNo,COUNT(1) cnt 
From RealDeals16062026.Purchase.POAmendmentMain P Where P.FromLocationNo is not null Group by P.FromLocationNo
		) fl on fl.FromLocationNo=LM.LocationNo
Left Join ( 
		Select P.TOLocationNo,COUNT(1) cnt From RealDeals16062026.Purchase.POAmendmentMain P Where P.TOLocationNo is not null Group by P.TOLocationNo
		) TL on tl.TOLocationNo=LM.LocationNo	
Left Join ( 
		Select P.LocationNo,COUNT(1) cnt From RealDeals16062026.erpMaster.eLocationMaster P Where P.LocationNo is not Null Group By P.LocationNo
		) EL on EL.LocationNo=LM.LocationNo	
)tt
Where tt.Sno>1

```

## Doc Type 
- Enter for general 
```sql
INSERT INTO masterdata.doc_type_master
(
    code,
    doc_type_alias,
    doc_type_name,
    form_id,
    status_id,
    created_date,
    modified_date,
    created_by_id
)
VALUES
(
    'DT0001',
    'PRG',
    'General Purchase Request',
    6,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0002',
    'CSG',
    'General Comparative Statement',
    8,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0003',
    'POG',
    'General Purchase Order',
    10,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0004',
    'RQG',
    'General Request For Quotation',
    7,
    1,
    Now(),
    Now(),
    1
);

```

## Tax Group Master
- Insert data from globaldata.tax_group

```sql
INSERT INTO masterdata.tax_group_master
(
    code,
    gb_tax_group_id,
    tax_group_name,
    tax_category_id,
    formula,
    seq_no,
    is_charge_on_order_applicable,
    is_charge_on_item_applicable,
    is_nature_perc_applicable,
    is_nature_amount_applicable,
    is_nature_unit_applicable,
    default_charge_on_id,
    default_nature_id,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
	modified_date
)
SELECT
    tg.code,
    tg.id,
    tg.tax_group_name,
    tg.tax_category_id,
    tg.formula,
    tg.seq_no,
    tg.is_charge_on_order_applicable,
    tg.is_charge_on_item_applicable,
    tg.is_nature_perc_applicable,
    tg.is_nature_amount_applicable,
    tg.is_nature_unit_applicable,
    tg.default_charge_on_id,
    tg.default_nature_id,
    1,
    NULL,
    1,
    NOW(),
	NOW()
FROM globaldata.tax_group tg
WHERE NOT EXISTS
(
    SELECT 1
    FROM masterdata.tax_group_master mt
    WHERE mt.gb_tax_group_id = tg.id
);
```

## Tax Master
- Always check the tax_group pk 

```sql
INSERT INTO masterdata.tax_master
(
    id,
    tax_group_id,
    code,
    tax_name,
    rate,
    calc_nature_id,
    display_name,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
VALUES
--CGST--
(92, 1, 'MC00091', 'CGST @ 0%', 0.0000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),
(101, 1, 'MC00096', 'CGST @1.5%', 1.5000, 1, 'CGST', 1, NULL, 1, NOW(), NULL, NOW()),
(73, 1, 'MC00073', 'CGST @ 2.5%', 2.5000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),
(78, 1, 'MC00078', 'CGST @6%', 6.0000, 1, 'CGST', 2, 'Deprecated', 1, NOW(), 1, NOW()),
(74, 1, 'MC00074', 'CGST @ 9%', 9.0000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),
(80, 1, 'MC00080', 'CGST @14%', 14.0000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),

--DISCOUNT--
(8, 6, 'MC00008', 'DISC', 0.0000, 2, 'DISC', 1, NULL, 1, NOW(), 1, NOW()),

--IGST--
(94, 3, 'MC00093', 'IGST @0%', 0.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),
(100, 3, 'MC00095', 'IGST @3%', 3.0000, 1, 'IGST', 1, NULL, 1, NOW(), NULL, NOW()),
(85, 3, 'MC00085', 'IGST @5%', 5.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),
(86, 3, 'MC00086', 'IGST @12%', 12.0000, 1, 'IGST', 2, 'Deprecated', 1, NOW(), NULL, NOW()),
(81, 3, 'MC00081', 'IGST @18', 18.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),
(84, 3, 'MC00084', 'IGST @28', 28.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),

--SGST--
(93, 2, 'MC00092', 'SGST @ 0%', 0.0000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),
(102, 2, 'MC00097', 'SGST @1.5%', 1.5000, 1, 'SGST', 1, NULL, 1, NOW(), NULL, NOW()),
(76, 2, 'MC00076', 'SGST @ 2.5%', 2.5000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),
(82, 2, 'MC00082', 'SGST @ 6%', 6.0000, 1, 'SGST', 2, 'Deprecated', 1, NOW(), 1, NOW()),
(75, 2, 'MC00075', 'SGST @ 9%', 9.0000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),
(83, 2, 'MC00083', 'SGST @ 14%', 14.0000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),

--UGST--
(95, 4, 'MC00094', 'UTGST @ 0%', 0.0000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),
(88, 4, 'MC00087', 'UTGST @ 2.5%', 2.5000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),
(89, 4, 'MC00088', 'UTGST @ 6%', 6.0000, 1, 'UTGST', 2, 'Deprecated', 1, NOW(), 1, NOW()),
(90, 4, 'MC00089', 'UTGST @ 9%', 9.0000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),
(91, 4, 'MC00090', 'UTGST @ 14%', 14.0000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),

--OTHER--
(103, 9, 'MC00103', 'Freight (Taxable)', 0.0000, 1, 'Freight', 1, NULL, 1, NOW(), NULL, NOW()),
(104, 7, 'MC00104', 'Other Charges (+)', 0.0000, 1, 'Other Charges', 1, NULL, 1, NOW(), NULL, NOW()),
(105, 15, 'MC00105', 'Loading/Unloading', 0.0000, 1, 'Loading/Unloading', 1, NULL, 1, NOW(), NULL, NOW());

```

## Tax Group Dependent 
- Check with the formula before running the script
```sql
insert into masterdata.tax_group_dpendent 
(tax_group_id, dep_tax_group_id)
values 
(1,6),
(1,9),
(2,6),
(2,9),
(3,6),
(3,9),
(4,6),
(4,9),
(9,6),
(10,6);

```

## City Master 
- Updated the duplicate city Name
- Updated the city linked to wrong state

## Status Mapping 

```sql
-- Create table
CREATE TABLE migration.status_mapping (
    old_status_id   INT,
    old_status_name VARCHAR(100),
    new_status_id   INT,
    new_status_name VARCHAR(100)
);

-- Insert data
INSERT INTO migration.status_mapping (
    old_status_id,
    old_status_name,
    new_status_id,
    new_status_name
)
VALUES
(1,  'Authorized',  9,  'Authorize'),
(2,  'Completed',   11, 'Completed'),
(3,  'Hold',        17, 'Hold'),
(4,  'Cancel',      15, 'Cancelled'),
(5,  'Initial',     7,  'Draft'),
(6,  'Release',     1,  'Active'),
(7,  'Short Close', 16, 'Short Closed'),
(8,  'In Progress', 10, 'In Progress'),
(9,  'Reject',      13, 'Rejected'),
(10, 'Fixed',       12, 'Approved'),
(11, 'Open',        1,  'Active'),
(12, 'Accept',      12, 'Approved'),
(13, 'Approve',     12, 'Approved'),
(14, 'Pending',     3,  'Pending'),
(15, 'Live',        1,  'Active'),
(16, 'Expired',     5,  'Expired'),
(17, 'Skipped',     19, 'Skipped');

```

## Purchase Request (Indent)

```sql
INSERT INTO inventory.purchase_request_main
(
    id,
    fy_id,
    company_id,
    division_id,
    doc_type_id,
    doc_no_yearly,
    doc_date,
    doc_series_id,
    display_doc_no_yearly,
    document_status_id,
    department_id,
    expenditure_type_id,
    ref_doc_no,
    ref_doc_date,
    requested_by,
    requested_by_contact_no,
    requested_by_contact_no_county_id,
    requested_by_email,
    net_amount,
    erp_serial_no_id,
    remarks,
    approval_setup_id,
    status_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    authorized_by_id,
    authorized_date,
    is_inserted_into_erp
)
OVERRIDING SYSTEM VALUE
SELECT
    im.IndentNo,

    im.YearNo,

    im.CompanyNo,

    im.DivisionNo,

    2,

    COALESCE(NULLIF(TRIM(im.PortalDocumentNoYearly), ''), TRIM(im.DocumentNoYearly)),

    COALESCE(
        migration.parse_sqlserver_datetime(im.DocumentDate)::date,
        CURRENT_DATE
    ),

    NULL,

    TRIM(im.DocumentNoYearly),

    im.DocumentStatusNo,

    im.DeptNo,

	 CASE im.IndentTypeNo
        WHEN 1 THEN 1
        WHEN 2 THEN 2
		WHEN 3 THEN 3
        WHEN 7 THEN 7
    END,

    NULLIF(TRIM(im.ReferenceNo), ''),

    migration.parse_sqlserver_datetime(im.ReferenceDate)::date,

    NULLIF(TRIM(im.RequestedBy), ''),

    NULLIF('+91' || LEFT(TRIM(im.RequstedByContactNo), 12), '+91'),

    CASE
        WHEN NULLIF(TRIM(im.RequstedByContactNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,

    NULLIF(TRIM(im.RequstedByEmailId), ''),

    COALESCE(im.NetAmount, 0),

    im.DocumentSerialNo,

    NULLIF(TRIM(im.Remark), ''),

    im.AuthGrpRevisionNo,

    sm.new_status_id,

    COALESCE(im.CreatedBy, 1),

    COALESCE(
        migration.parse_sqlserver_datetime(im.CreatedDate),
        now()
    ),

    im.ModifiedBy,

    COALESCE(
        migration.parse_sqlserver_datetime(im.ModifiedDate),
        migration.parse_sqlserver_datetime(im.CreatedDate),
        now()
    ),

    im.AuthorizedBy,

    migration.parse_sqlserver_datetime(im.AuthorizedDate),

    TRUE
FROM sqlserver_fdw.indentmain im
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = im.StatusNo;
```

- Line No. Fix 

```sql
Use RealDeals16062026;
 
; With CTE as (
Select 
IID.IndentNo
,IId.IndentItemLineNo
,IND.DocumentNoYearly
,Convert(Varchar,INd.DocumentDate) DocumentDateText
,INd.DocumentDate
,IID.ItemNo 
From Inventory.IndentItemDetail IID
Inner Join Inventory.IndentMain IND on IND.IndentNo=IID.IndentNo 
Group by IID.IndentNo,IId.IndentItemLineNo,IND.DocumentNoYearly,INd.DocumentDate,IID.ItemNo 
Having count(1)>1
)
 
Select C.IndentNo
,C.IndentItemLineNo
,C.DocumentNoYearly
,C.DocumentDateText
,C.DocumentDate
,C.ItemNo ,Sum(Po.cnt),Sum(rq.cnt),sum(eind.cnt)
from CTE C
Inner Join Inventory.IndentItemDetail PDD on PDD.IndentNo=C.IndentNo and PDD.ItemNo=C.ItemNo
Outer Apply (Select Count(1) cnt From Purchase.POAmendmentIndentDetail PId Where PId.IndentNo=C.IndentNo and PID.IndentItemLineNo=C.IndentItemLineNo) PO
Outer Apply (Select Count(1) cnt From Purchase.RFQIndentDetail PId Where PId.IndentNo=C.IndentNo and PID.IndentItemLineNo=C.IndentItemLineNo) RQ
Outer Apply (Select Count(1) cnt From Customize.RealIndentBody PId Where PID.PortalIndentItemDetailNo=PDD.IndentItemDetailNo) eIND
Group By  C.IndentNo
,C.IndentItemLineNo
,C.DocumentNoYearly
,C.DocumentDateText
,C.DocumentDate
,C.ItemNo
 
 
; With CTE as (
Select 
IID.IndentNo
,IId.IndentItemLineNo
,IND.DocumentNoYearly
,Convert(Varchar,INd.DocumentDate) DocumentDateText
,INd.DocumentDate
,IID.ItemNo 
From Inventory.IndentItemDetail IID
Inner Join Inventory.IndentMain IND on IND.IndentNo=IID.IndentNo 
Group by IID.IndentNo,IId.IndentItemLineNo,IND.DocumentNoYearly,INd.DocumentDate,IID.ItemNo 
Having count(1)>1
)
 
Select PDD.*
from CTE C
Inner Join Inventory.IndentItemDetail PDD on PDD.IndentNo=C.IndentNo and PDD.ItemNo=C.ItemNo
Order by IndentNo

```

## RFQ 
- line No. fix

```sql
Use RealDeals16062026;

update RID set RID.ItemlineNo= tt.SNo*10

From (

Select  RID.IndentItemDetailNo, Dense_Rank() Over (Partition By RID.RFQNo ORder By RID.IndentItemDetailNo) SNo

from Purchase.rfqitemDetail RID

)tt

Inner Join Purchase.rfqitemDetail RID on RID.IndentItemDetailNo=tt.IndentItemDetailNo
 
```

## RFQ Vendor Detail 
- Some contact persons are linked to duplicate vendors so map them to a single vendor and then delete duplicate vendor detail row.

```sql 

WITH duplicate_map AS (
    SELECT id AS old_id,
           MIN(id) OVER (
               PARTITION BY rfq_id, vendor_location_id
           ) AS keep_id
    FROM purchase.pur_rfq_vendor_detail
)
UPDATE purchase.pur_rfq_vendor_contact_person_detail c
SET rfq_vendor_detail_id = d.keep_id
FROM duplicate_map d
WHERE c.rfq_vendor_detail_id = d.old_id
  AND d.old_id <> d.keep_id;



DELETE FROM purchase.pur_rfq_vendor_detail
WHERE id IN (
    SELECT id
    FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY rfq_id, vendor_location_id
                   ORDER BY id
               ) AS rn
        FROM purchase.pur_rfq_vendor_detail
    ) t
    WHERE rn > 1
);

```

## RFQ Indent Detail
- Find RFQ Item that doesn't match 
```sql
SELECT
    rid.
    iid.indentNo,
    rid.rfqNo,

    CONVERT(VARCHAR(20), im.documentDate, 120) AS IndentDate,
    CONVERT(VARCHAR(20), rm.documentDate, 120) AS RFQDate,

    iid.itemNo AS [Indent Item],
    iim.itemName AS [Indent Item Name],

    rid.itemNo AS [RFQ Item],
    rim.itemName AS [RFQ Item Name],

    rid.IndentItemLineNo
FROM purchase.rfqIndentDetail rid
LEFT JOIN inventory.indentItemDetail iid
    ON rid.IndentNo = iid.IndentNo
   AND rid.IndentItemLineNo = iid.IndentItemLineNo

LEFT JOIN inventory.IndentMain im
    ON iid.indentNo = im.indentNo

LEFT JOIN purchase.RFQMain rm
    ON rid.rfqNo = rm.rfqNo

LEFT JOIN masterdata.mItemMaster iim
    ON iid.itemNo = iim.itemNo

LEFT JOIN masterdata.mItemMaster rim
    ON rid.itemNo = rim.itemNo

WHERE rid.itemNo <> iid.itemNo;


----find quotaiton against-------

SELECT
    rid.rfqNo,
    rid.IndentItemLineNo,
    iid.itemNo AS IndentItem,
    rid.itemNo AS RFQItem,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM purchase.quotationMain q
            INNER JOIN purchase.quotationItemDetail qid
                ON qid.quotationNo = q.quotationNo
               AND qid.ItemNo = rid.ItemNo
            WHERE q.rfqNo = rid.rfqNo
        )
        THEN 'Quotation Present'
        ELSE 'Quotation Missing'
    END AS QuotationStatus,
    (
        SELECT STRING_AGG(CAST(q.quotationNo AS VARCHAR(50)), ', ')
        FROM purchase.quotationMain q
        INNER JOIN purchase.quotationItemDetail qid
            ON qid.quotationNo = q.quotationNo
           AND qid.ItemNo = rid.ItemNo
        WHERE q.rfqNo = rid.rfqNo
    ) AS QuotationNos
FROM purchase.rfqIndentDetail rid
JOIN inventory.indentItemDetail iid
    ON rid.IndentNo = iid.IndentNo
   AND rid.IndentItemLineNo = iid.IndentItemLineNo
WHERE rid.itemNo <> iid.itemNo
ORDER BY rid.rfqNo, rid.IndentItemLineNo;

```

## Approval Process 
- One Indent was not having authorization group no. checked for that approval_setup_id = 120.

```sql
SELECT b.AuthGrpRevisionNo, a.*
FROM inventory.IndentAuthorizationDetail a
LEFT JOIN inventory.IndentMain b
    ON a.IndentNo = b.IndentNo
WHERE b.AuthGrpRevisionNo IS NULL;

--- Insert Main ---- (Indent)

WITH action_cte AS (
    SELECT DISTINCT ON (iad.IndentNo)
        iad.IndentNo,
        iad.ModifiedBy      AS action_by_id,
        migration.parse_sqlserver_datetime(iad.ModifiedDate) AS action_date
    FROM sqlserver_fdw.indentauthorizationdetail iad
    WHERE iad.ModifiedBy IS NOT NULL
      AND iad.ModifiedDate IS NOT NULL
    ORDER BY iad.IndentNo, iad.LevelNo DESC
)
INSERT INTO utility.approval_process_main (
    form_id,
    doc_id,
    approval_setup_id,
    revision_no,
    is_current,
    status_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    max_approver_level_no,
    current_approved_level_no,
    approval_start_date,
    action_by_id,
    action_date,
    company_id,
    division_id,
    department_id,
    doc_type_id,
    is_audit,
    audit_entry_id
)
OVERRIDING SYSTEM VALUE
SELECT
    6                                                           AS form_id,
    pr.id                                                       AS doc_id,
    COALESCE(pr.approval_setup_id,120)                          AS approval_setup_id,
    0                                                           AS revision_no,
    true                                                        AS is_current,
    CASE
    WHEN pr.document_status_id = 30 THEN 9
    WHEN pr.document_status_id = 10
         AND EXISTS (
             SELECT 1
             FROM sqlserver_fdw.indentauthorizationdetail iad2
             WHERE iad2.IndentNo = pr.id
               AND iad2.StatusNo = 1
         ) THEN 14
    WHEN pr.document_status_id = 10 THEN 7
    END                                                         AS status_id,
    pr.created_by_id                                            AS created_by_id,
    pr.created_date         AS created_date,
    pr.modified_by_id                                           AS modified_by_id,
    pr.modified_date       AS modified_date,
    MAX(iad.LevelNo)                                            AS max_approver_level_no,
    MAX(CASE WHEN iad.IsReady = true THEN iad.LevelNo END)      AS current_approved_level_no,
    COALESCE(migration.parse_sqlserver_datetime(MIN(iad.AssignDate)), Now())     AS approval_start_date,
    ac.action_by_id                                             AS action_by_id,
    ac.action_date                                              AS action_date,
    pr.company_id                                               AS company_id,
    pr.division_id                                              AS division_id,
    pr.department_id                                            AS department_id,
    pr.doc_type_id                                              AS doc_type_id,
    false                                                       AS is_audit,
    NULL                                                        AS audit_entry_id
FROM inventory.purchase_request_main pr
JOIN sqlserver_fdw.indentauthorizationdetail iad
    ON iad.IndentNo = pr.id
LEFT JOIN action_cte ac
    ON ac.IndentNo = pr.id
GROUP BY
    pr.id,
    pr.approval_setup_id,
    pr.created_by_id,
    pr.created_date,
    pr.modified_by_id,
    pr.modified_date,
    pr.company_id,
    pr.division_id,
    pr.department_id,
    pr.doc_type_id,
	ac.action_by_id,
    ac.action_date;


--- Insert Detail ---- (Indent)

INSERT INTO utility.approval_process_detail (
    approval_process_id,
    user_id,
    role_id,
    level_no,
    assigned_date,
    modified_date,
    modified_by,
    status_id,
    status_remarks,
    approval_rule_id,
    is_next_level_selection_allowed,
	printing_caption
)
OVERRIDING SYSTEM VALUE
SELECT
    apm.id                                                          AS approval_process_id,
    iad.LoginNo                                                     AS user_id,
    NULL                                                            AS role_id,
    iad.LevelNo                                                     AS level_no,
    migration.parse_sqlserver_datetime(iad.AssignDate)              AS assigned_date,
    migration.parse_sqlserver_datetime(
        COALESCE(iad.ModifiedDate, iad.LastModifiedDate)
    )                                                               AS modified_date,
    iad.ModifiedBy                                                  AS modified_by,
    CASE
	WHEN iad.StatusNo = 1 THEN 12
	WHEN iad.StatusNo = 5 THEN 3 
	END                                                             AS status_id,
    COALESCE(
        NULLIF(TRIM(iad.Comment), ''),
        NULLIF(TRIM(iad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
	COALESCE(alm.printing_caption, 'Approved By')
FROM sqlserver_fdw.indentauthorizationdetail iad
JOIN utility.approval_process_main apm
    ON apm.doc_id = iad.IndentNo
    AND apm.form_id = 6
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = iad.StatusNo
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
	AND alm.level_no = iad.levelNo;


----- Insert Main ---- (po)
WITH action_cte AS (
    SELECT DISTINCT ON (pad.POAmendmentNo)
        pad.POAmendmentNo,
        pad.ModifiedBy                                          AS action_by_id,
        migration.parse_sqlserver_datetime(pad.ModifiedDate)    AS action_date
    FROM sqlserver_fdw.poamendmentauthorizationdetail pad
    WHERE pad.ModifiedBy IS NOT NULL
      AND pad.ModifiedDate IS NOT NULL
    ORDER BY pad.POAmendmentNo, pad.LevelNo DESC
)
INSERT INTO utility.approval_process_main (
    form_id,
    doc_id,
    approval_setup_id,
    revision_no,
    is_current,
    status_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    max_approver_level_no,
    current_approved_level_no,
    approval_start_date,
    action_by_id,
    action_date,
    company_id,
    division_id,
    department_id,
    doc_type_id,
    is_audit,
    audit_entry_id
)
OVERRIDING SYSTEM VALUE
SELECT
    10                                                              AS form_id,
    pom.id                                                          AS doc_id,
    pom.approval_setup_id                                           AS approval_setup_id,
    0                                                               AS revision_no,
    true                                                            AS is_current,
    CASE
    WHEN pom.document_status_id = 30 THEN 9
    WHEN pom.document_status_id = 10
         AND EXISTS (
             SELECT 1
             FROM sqlserver_fdw.poamendmentauthorizationdetail pad2
             WHERE pad2.poAmendmentNo = pom.id
               AND pad2.StatusNo = 1
         ) THEN 14
    WHEN pom.document_status_id = 10 THEN 7
    END                                                             AS status_id,
    pom.created_by_id                                               AS created_by_id,
    pom.created_date                                                AS created_date,
    pom.modified_by_id                                              AS modified_by_id,
    pom.modified_date                                               AS modified_date,
    MAX(pad.LevelNo)                                                AS max_approver_level_no,
    MAX(CASE WHEN pad.IsReady = true THEN pad.LevelNo END)          AS current_approved_level_no,
    COALESCE(migration.parse_sqlserver_datetime(MIN(pad.AssignDate)), NOW()) AS approval_start_date,
    ac.action_by_id                                                 AS action_by_id,
    ac.action_date                                                  AS action_date,
    pom.company_id                                                  AS company_id,
    pom.division_id                                                 AS division_id,
    pom.department_id                                               AS department_id,
    pom.doc_type_id                                                 AS doc_type_id,
    false                                                           AS is_audit,
    NULL                                                            AS audit_entry_id
FROM purchase.purchase_order_main pom
JOIN sqlserver_fdw.poamendmentauthorizationdetail pad
    ON pad.POAmendmentNo = pom.id
	AND  pom.approval_setup_id IS NOT NULL
LEFT JOIN action_cte ac
    ON ac.POAmendmentNo = pom.id
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = pom.status_id
GROUP BY
    pom.id,
    pom.approval_setup_id,
    pom.created_by_id,
    pom.created_date,
    pom.modified_by_id,
    pom.modified_date,
    pom.company_id,
    pom.division_id,
    pom.department_id,
    pom.doc_type_id,
    ac.action_by_id,
    ac.action_date;


---- Insert Detail ---- (PO)

INSERT INTO utility.approval_process_detail (
    approval_process_id,
    user_id,
    role_id,
    level_no,
    assigned_date,
    modified_date,
    modified_by,
    status_id,
    status_remarks,
    approval_rule_id,
    is_next_level_selection_allowed,
    printing_caption
)
OVERRIDING SYSTEM VALUE
SELECT
    apm.id                                                          AS approval_process_id,
    pad.LoginNo                                                     AS user_id,
    NULL                                                            AS role_id,
    pad.LevelNo                                                     AS level_no,
    migration.parse_sqlserver_datetime(pad.AssignDate)              AS assigned_date,
    migration.parse_sqlserver_datetime(
        COALESCE(pad.ModifiedDate, pad.LastModifiedDate)
    )                                                               AS modified_date,
    pad.ModifiedBy                                                  AS modified_by,
	CASE
	WHEN pad.StatusNo = 1 THEN 12
	WHEN pad.StatusNo = 5 THEN 3 
	END                                                             AS status_id,
    COALESCE(
        NULLIF(TRIM(pad.Comment), ''),
        NULLIF(TRIM(pad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
    COALESCE(alm.printing_caption, 'Approved By')                   AS printing_caption
FROM sqlserver_fdw.poamendmentauthorizationdetail pad
JOIN utility.approval_process_main apm
    ON apm.doc_id = pad.POAmendmentNo
    AND apm.form_id = 10
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
    AND alm.level_no = pad.LevelNo;


```

- Approval Detail Status Updates

```sql
--- Update the Approved by peer and Rejected by peer

UPDATE utility.approval_process_detail apd
SET status_id = CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM utility.approval_process_detail x
                        WHERE x.approval_process_id = apd.approval_process_id
                          AND x.level_no = apd.level_no
                          AND x.status_id = 12
                    ) THEN 21

                    WHEN EXISTS (
                        SELECT 1
                        FROM utility.approval_process_detail x
                        WHERE x.approval_process_id = apd.approval_process_id
                          AND x.level_no = apd.level_no
                          AND x.status_id = 13
                    ) THEN 29
                END
WHERE apd.status_id NOT IN (12, 13)
  AND EXISTS (
        SELECT 1
        FROM utility.approval_process_detail x
        WHERE x.approval_process_id = apd.approval_process_id
          AND x.level_no = apd.level_no
        GROUP BY x.approval_process_id, x.level_no
        HAVING COUNT(*) > 1
  )
  AND (
        EXISTS (
            SELECT 1
            FROM utility.approval_process_detail x
            WHERE x.approval_process_id = apd.approval_process_id
              AND x.level_no = apd.level_no
              AND x.status_id = 12
        )
        OR
        EXISTS (
            SELECT 1
            FROM utility.approval_process_detail x
            WHERE x.approval_process_id = apd.approval_process_id
              AND x.level_no = apd.level_no
              AND x.status_id = 13
        )
      );

```


## CS Quotation Participation Detail 
- With Auction

```sql
INSERT INTO purchase.cs_quotation_participation_detail
(
    id,
    cs_id,
    quotation_id,
    remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    cqd.QQuotationNo,

    cqd.CSNo,

    cqd.RevisedQuotationNo,

    NULL

FROM sqlserver_fdw.csquotationdetail cqd
INNER JOIN  sqlserver_fdw.csmain csm
ON csm.csNo = cqd.csNo;

```

## CS Quotation Detail
- With Auction

```sql
INSERT INTO purchase.cs_quotation_detail
(
    id,
    cs_id,
    quotation_id,
    quotation_item_detail_id,
    qty
)
OVERRIDING SYSTEM VALUE
SELECT
    cqd.QQuotationNo AS id,
    cqd.CSNo AS cs_id,
    cqd.RevisedQuotationNo AS quotation_id,
    CASE WHEN cqd.itemNo IS NOT NULL THEN qid.id ELSE NULL END AS quotation_item_detail_id,
    CASE WHEN cqd.itemNo IS NOT NULL THEN cqd.Quantity ELSE NULL END AS qty
FROM sqlserver_fdw.csquotationdetail cqd
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = cqd.itemNo 
    AND COALESCE(cqd.makeNo,0) = COALESCE(qid.rfq_make_id,0)
    AND qid.quotation_id = cqd.RevisedQuotationNo
WHERE cqd.isSelected IS TRUE
  AND cqd.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = cqd.RevisedQuotationNo
  );

```

## CS Rank Detail

```sql

CREATE FOREIGN TABLE sqlserver_fdw.csl1detail
(
    CSL1DetailNo        integer,
    CSNo                integer,
    ItemNo              integer,
    MakeNo              smallint,
    RFQMakeNo           smallint,
    RevisedQuotationNo  integer,
    Rate                numeric(18,4),
    BasicAfterDiscount  numeric(18,4),
    RFQItemDetailNo     integer,
    AuctionItemDetailNo integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSL1Detail'
);

INSERT INTO purchase.cs_rank_detail
(
    id,
    cs_id,
    is_item_detail,
    rfq_item_detail_id,
    quotation_id,
    quotation_item_detail_id,
    rate,
    basic_rate_after_discount,
    net_amount
)
OVERRIDING SYSTEM VALUE
SELECT
    csl.CSL1DetailNo AS id,
    csl.CSNo AS cs_id,
    CASE WHEN csm.vendor_selection_basis_id = 1 THEN TRUE ELSE FALSE END AS isItemDetail,
    csl.RFQItemDetailNo AS rfq_item_detail_id,
    csl.RevisedQuotationNo AS quotation_id,
    qid.id AS quotation_item_detail_id,
    csl.Rate AS rate,
    csl.Rate AS basic_rate_after_discount,
    0 AS net_amount
FROM sqlserver_fdw.csl1detail csl
INNER JOIN purchase.cs_main csm
    ON csm.id = csl.CSNo
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = csl.ItemNo
    AND COALESCE(qid.rfq_make_id,0) = COALESCE(csl.MakeNo,0)
    AND qid.quotation_id = csl.RevisedQuotationNo
WHERE csl.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = csl.RevisedQuotationNo
  );
```

## PR Cancellation

```sql
INSERT INTO utility.purchase_request_cancellation_main (
id,
pr_id,
doc_no_yearly,
doc_date,
doc_type_id,
division_id,
doc_series_id,
document_status_id,
company_id,
fy_id,
remarks,
created_by_id,
created_date,
modified_by_id,
modified_date,
authorized_by_id,
authorized_date
)
OVERRIDING SYSTEM VALUE
select 
changeindentstatusno as id,
prc.indentNo as pr_id,
prc.documentnoyearly as doc_no_yearly,
migration.parse_sqlserver_datetime(prc.documentdate) as doc_date,
5 as doc_type_id,
prc.divisionno as division_id,
NULL,
prc.documentstatusno,
prc.companyno as company_id,
prc.yearno as fy_id,
prc.reason as remarks,
prc.createdby,
migration.parse_sqlserver_datetime(prc.createddate),
prc.modifiedby,
COALESCE(migration.parse_sqlserver_datetime(prc.modifieddate), migration.parse_sqlserver_datetime(prc.createddate)),
prc.authorizedby,
migration.parse_sqlserver_datetime(prc.authorizeddate)
FROM sqlserver_fdw.ChangeIndentStatusMain prc;


INSERT INTO utility.purchase_request_cancellation_item_detail (
id,
line_no,
pr_cancellation_id,
pr_item_detail_id,
status_id,
cancel_qty,
reason
)
OVERRIDING SYSTEM VALUE
select 
cid.changeindentstatusitemdetailno as id,
cid.indentitemlineno as line_no,
cid.changeindentstatusno as pr_cancellation_id,
pid.id as pr_item_detail_id,
sm.new_status_id as status_id,
cid.cancelqty,
cid.reason
FROM sqlserver_fdw.ChangeIndentStatusItemDetail cid
INNER JOIN utility.purchase_request_cancellation_main pcm
ON cid.changeindentstatusno = pcm.id
INNER JOIN inventory.purchase_request_item_detail pid
ON pid.pur_req_id = pcm.pr_id AND pid.line_no = cid.indentitemlineno
INNER JOIN migration.status_mapping sm
ON cid.statusno = sm.old_status_id;


```

## RFQ PR Detail 
- There are items that are not matching the indent's item (31) No changes we are moving as it is.
- There are entries in which item and make are not matching with rfq_item_detail's 
- There are entries in which IndentNo is null
- There are entries in which lineNo doesn't exist for IndentNo.

```sql
INSERT INTO purchase.pur_rfq_pr_detail
(
    id,
    rfq_id,
    rfq_item_detail_id,
    pr_item_detail_id,
    item_id,
    make_id,
    rfq_make_id,
    unit_id,
    rfq_unit_id,
    first_cf,
    second_cf,
    rfq_qty
)
OVERRIDING SYSTEM VALUE
SELECT
    rid.RFQIndentDetailNo,

    rid.RFQNo,

    rfqid.id,

    prid.id,

    rid.ItemNo,

    rid.MakeNo,

    rid.RFQMakeNo,

    rid.UnitNo,

    rid.UnitNo,

    COALESCE(rid.FirstCF, 0),

    COALESCE(rid.SecondCF, 0),

    COALESCE(rid.RFQQty, 0)
FROM sqlserver_fdw.rfqindentdetail rid

INNER JOIN purchase.pur_rfq_item_detail rfqid
    ON rfqid.rfq_id = rid.RFQNo
   AND rfqid.item_id = rid.ItemNo
   AND COALESCE(rfqid.make_id, 0) = COALESCE(rid.RFQMakeNo, 0)

INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = rid.IndentNo
   AND prid.line_no = rid.IndentItemLineNo;

```

## CS PR Detail
- 3 Indent's line no.'s are not matching the cs pr detail line no.
```sql
--query to find those indent--
select * FROM sqlserver_fdw.csindentdetail
EXCEPT
select cid.* FROM sqlserver_fdw.csindentdetail cid
INNER JOIN sqlserver_fdw.csmain csm
    ON csm.csNo = cid.CSNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cid.IndentNo
    AND prid.line_no = cid.IndentItemLineNo
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = cid.ItemNo
    AND COALESCE(qid.rfq_make_id,0) = COALESCE(cid.MakeNo,0)
    AND qid.quotation_id = cid.RevisedQuotationNo
WHERE cid.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = cid.RevisedQuotationNo
  );
```

```sql

CREATE FOREIGN TABLE sqlserver_fdw.csindentdetail
(
    CSIndentDetailNo      integer,
    IndentNo              integer,
    ItemNo                integer,
    MakeNo                smallint,
    RevisedQuotationNo    integer,
    Qty                   numeric(10,3),
    CSNo                  integer,
    IndentItemLineNo      numeric(10,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSIndentDetail'
);

INSERT INTO purchase.cs_pr_detail
(
    id,
    cs_id,
    pr_item_detail_id,
    quotation_id,
    quotation_item_detail_id,
    quotation_item_id,
    quotation_make_id,
    qty,
    balance_qty,
    po_qty,
    status_id
)
OVERRIDING SYSTEM VALUE
SELECT
    cid.CSIndentDetailNo AS id,
    cid.CSNo AS cs_id,
    prid.id AS pr_item_detail_id,
    cid.RevisedQuotationNo AS quotation_id,
    qid.id AS quotation_item_detail_id,
    cid.ItemNo AS quotation_item_id,
    cid.MakeNo AS quotation_make_id,
    cid.Qty AS qty,
    cid.Qty AS balance_qty,
    0 AS po_qty,
    9 AS status_id
FROM sqlserver_fdw.csindentdetail cid
INNER JOIN sqlserver_fdw.csmain csm
    ON csm.csNo = cid.CSNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cid.IndentNo
    AND prid.line_no = cid.IndentItemLineNo
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = cid.ItemNo
    AND COALESCE(qid.rfq_make_id,0) = COALESCE(cid.MakeNo,0)
    AND qid.quotation_id = cid.RevisedQuotationNo
WHERE cid.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = cid.RevisedQuotationNo
  );

  ```

  ## PO CS Exemption

  ```sql
  CREATE FOREIGN TABLE sqlserver_fdw.poexcludedvendormain
(
    POExcludedVendorNo integer,
    Code varchar(50),
    CreatedBy integer,
    CreatedDate text,
    ModifiedBy integer,
    ModifiedDate text,
    POExcludedVendorName varchar(500),
    Description varchar(4000),
    VendorType smallint,
    ItemType smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'utility',
    table_name 'POExcludedVendorMain'
);

INSERT INTO utility.po_cs_exemption_master
(
    id,
    code,
    exemption_name,
    doc_type_selection_type,
    vendor_location_selection_type,
    item_selection_type,
    description,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    POExcludedVendorNo as id,
    LEFT(TRIM(Code), 8) as code,
    LEFT(TRIM(POExcludedVendorName), 600) as exemption_name,
	1 as doc_type_selection_type,
    VendorType as vendor_location_selection_type,
    ItemType as item_selection_type,
    LEFT(TRIM(Description), 300),
    1,
    NULL,
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    )
FROM sqlserver_fdw.poexcludedvendormain;

```

```sql
CREATE FOREIGN TABLE sqlserver_fdw.poexcludedvendorcompanydetail
(
    POExcludedVendorNo integer,
    CompanyNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'utility',
    table_name 'POExcludedVendorCompanyDetail'
);

INSERT INTO utility.po_cs_exemption_company_detail
(
    exemption_id,
    company_id
)
SELECT
    POExcludedVendorNo,
    CompanyNo
FROM sqlserver_fdw.poexcludedvendorcompanydetail;

```

```sql
CREATE FOREIGN TABLE sqlserver_fdw.poexcludedvendoritemdetail
(
    POExcludedVendorItemDetailNo integer,
    POExcludedVendorNo integer,
    ItemNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'utility',
    table_name 'POExcludedVendorItemDetail'
);

INSERT INTO utility.po_cs_exemption_item_detail
(
    id,
    exemption_id,
    item_id
)
OVERRIDING SYSTEM VALUE
SELECT
    POExcludedVendorItemDetailNo,
    POExcludedVendorNo,
    ItemNo
FROM sqlserver_fdw.poexcludedvendoritemdetail;

```

```sql
CREATE FOREIGN TABLE sqlserver_fdw.poexcludedvendordetail
(
    POExcludedVendorDetailNo integer,
    POExcludedVendorNo integer,
    VendorLocationNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'utility',
    table_name 'POExcludedVendorDetail'
);

INSERT INTO utility.po_cs_exemption_vendor_detail
(
    id,
    exemption_id,
    vendor_location_id
)
OVERRIDING SYSTEM VALUE
SELECT
    POExcludedVendorDetailNo,
    POExcludedVendorNo,
    VendorLocationNo
FROM sqlserver_fdw.poexcludedvendordetail;

```

## Duplicate Item Group
- Updated the duplicate group names.

```sql
WITH CTE AS
(
    SELECT
        DItemGroupNo,
        ROW_NUMBER() OVER (
            PARTITION BY GroupName
            ORDER BY DItemGroupNo
        ) AS rn
    FROM masterdata.mduplicateitemgroup
)
UPDATE t
SET GroupName = CONCAT(t.GroupName, '_', c.rn)
FROM masterdata.mduplicateitemgroup t
JOIN CTE c
    ON t.DItemGroupNo = c.DItemGroupNo
WHERE c.rn > 1;

```

```sql
CREATE FOREIGN TABLE sqlserver_fdw.mduplicateitemgroup
(
    DItemGroupNo integer,
    Code varchar(8),
    GroupName varchar(600),
    InActive boolean,
    CreatedBy integer,
    CreatedDate text,
    ModifiedBy integer,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDuplicateItemGroup'
);

INSERT INTO utility.duplicate_item_group_main
(
    id,
    code,
    group_name,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    DItemGroupNo,
    TRIM(Code),
    TRIM(GroupName),
    CASE
        WHEN COALESCE(InActive, FALSE)
        THEN 2
        ELSE 1
    END,
    NULL,
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    )
FROM sqlserver_fdw.mduplicateitemgroup;

```

```sql

CREATE FOREIGN TABLE sqlserver_fdw.mduplicateitemgroupdetail
(
    DupDetailNo integer,
    DItemGroupNo integer,
    ItemNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDuplicateItemGroupDetail'
);

INSERT INTO utility.duplicate_item_group_detail
(
    id,
    group_id,
    item_id
)
OVERRIDING SYSTEM VALUE
SELECT
    DupDetailNo,
    DItemGroupNo,
    ItemNo
FROM sqlserver_fdw.mduplicateitemgroupdetail;

```

## DB Master
- May have to update the connection string

```sql

CREATE FOREIGN TABLE sqlserver_fdw.mdbmaster
(
    DBNo integer,
    Code varchar(10),
    DBDescription varchar(300),
    DBName varchar(100),
    Inactive boolean,
    DBConnectionName varchar(300),
    IndentFetchStartDate text,
    LastIndentFetchDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDBMaster'
);

INSERT INTO masterdata.db_master
(
    id,
    code,
    db_description,
    db_name,
    status_id,
    db_connection_name,
    first_indent_fetch_date,
    last_indent_fetch_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    DBNo,
    TRIM(Code),
    TRIM(DBDescription),
    TRIM(DBName),
    CASE
        WHEN COALESCE(Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    COALESCE(TRIM(DBConnectionName), TRIM(DBName)),
    migration.parse_sqlserver_datetime(IndentFetchStartDate),
    migration.parse_sqlserver_datetime(LastIndentFetchDate),
    1,
    now(),
    1,
    now()
FROM sqlserver_fdw.mdbmaster;

```

## Document Series

```sql
INSERT INTO masterdata.document_series_master
(
    code,
    padding,
    pattern,
    frequency_id,
    number_starts_from,
    effective_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
VALUES
(
    'DS0000001',
    5,
    'MMPR{{N}}',
    4, -- continuous
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 5)::INT), 0) + 1
        FROM inventory.purchase_request_main
        WHERE doc_no_yearly ~ '^MMPR[0-9]+$'
    ),
    (
        SELECT created_date
        FROM inventory.purchase_request_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(
    'DS0000002',
    5,
    '{{FY2}}{{N}}',
    3, -- yearly
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 5)::INT), 0) + 1
        FROM purchase.purchase_order_main
        WHERE doc_no_yearly ~ '^26Y[0-9]+$'
    ),
    (
        SELECT created_date
        FROM purchase.purchase_order_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(
    'DS0000003',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.pur_rfq_main
    ),
    (
        SELECT created_date
        FROM purchase.pur_rfq_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
);

INSERT INTO masterdata.document_series_form_detail
(
document_series_id,
form_id
)
VALUES
(1,6),
(2,10),
(3,7);

INSERT INTO masterdata.document_series_doc_type_detail
(
document_series_id,
document_type_id,
status_id
) VALUES
(1,(select id from masterdata.doc_type_master where form_id = 6),1),
(2,(select id from masterdata.doc_type_master where form_id = 10),1),
(3,(select id from masterdata.doc_type_master where form_id = 7),1);

INSERT INTO masterdata.document_series_company_detail
(
    document_series_id,
    company_id,
    status_id
)
SELECT
    ds.document_series_id,
    cm.id,
    1 AS status_id
FROM
    masterdata.company_master cm
CROSS JOIN
(
    SELECT 1 AS document_series_id
    UNION ALL
    SELECT 2
    UNION ALL
    SELECT 3
) ds; 

INSERT INTO masterdata.document_series_division_detail
(
    document_series_id,
    division_id,
    status_id
)
SELECT
    ds.document_series_id,
    dm.id,
    1 AS status_id
FROM
    masterdata.division_master dm
CROSS JOIN
(
    SELECT 1 AS document_series_id
    UNION ALL
    SELECT 2
    UNION ALL
    SELECT 3
) ds;

INSERT INTO masterdata.document_series_next_number 
(
document_series_id,
period,
next_number
) VALUES 
(1,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 1)),
(2,'2026',(select number_starts_from from masterdata.document_series_master where id = 2)),
(3,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 3));

```