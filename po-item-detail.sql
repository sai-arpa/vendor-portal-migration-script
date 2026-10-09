CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.poamendmentitemdetail
(
    POAmendmentItemDetailNo INTEGER,
    POAmendmentNo INTEGER,
    POItemLineNo SMALLINT,
    ItemNo INTEGER,
    MakeNo SMALLINT,
    TechSpecification VARCHAR(1000),
    Quantity NUMERIC(10,3),
    UnitNo SMALLINT,
    Rate NUMERIC(19,4),
    BasicAmount NUMERIC(19,4),
    NetAmount NUMERIC(19,4),
    Remark VARCHAR(500),
    StatusNo SMALLINT,
    ToleranceBasisNo SMALLINT,
    TolerancePlus NUMERIC(12,3),
    ToleranceMinus NUMERIC(12,3),
    CostCenterNo INTEGER,
    HSNSACCode VARCHAR(8),
    CSNo INTEGER,
    ERPItemCode VARCHAR(50)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'POAmendmentItemDetail'
);

INSERT INTO purchase.purchase_order_item_detail
(
    id,
    line_no,
    po_id,
    item_id,
    hsn_code,
    make_id,
    tech_specification,
    unit_id,
    cs_quotation_detail_id,
    quotation_item_detail_id,
    qty,
    rate,
    basic_amount,
    tax_amount,
    net_amount,
    cost_center_id,
    tolerance_type,
    tolerance_plus,
    tolerance_minus,
    remarks,
    status_id,
    discount_amount,
    discount_per_qty,
    discount_rate,
    rate_after_discount
)
OVERRIDING SYSTEM VALUE
SELECT
    poid.POAmendmentItemDetailNo,
    10,
    poid.POAmendmentNo,
    poid.ItemNo,
    LEFT(
        TRIM(COALESCE(poid.HSNSACCode,'')),
        20
    ) AS hsn_code,
    poid.MakeNo,
    LEFT(
        TRIM(COALESCE(poid.TechSpecification,'')),
        1000
    ) AS tech_specification,
    poid.UnitNo,
    NULL AS cs_quotation_detail_id,
    NULL AS quotation_item_detail_id,
    COALESCE(poid.Quantity,0),
    COALESCE(poid.Rate,0),
    COALESCE(poid.BasicAmount,0),
    COALESCE(poid.NetAmount,0) - COALESCE(poid.BasicAmount,0) AS tax_amount,
    COALESCE(poid.NetAmount,0),
    poid.CostCenterNo,
    poid.ToleranceBasisNo,
    poid.TolerancePlus,
    poid.ToleranceMinus,
    LEFT(
        TRIM(COALESCE(poid.Remark,'')),
        300
    ) AS remarks,
    COALESCE(sm.new_status_id,1) AS status_id,
    0 AS discount_amount,
    NULL AS discount_per_qty,
    NULL AS discount_rate,
    COALESCE(poid.Rate,0) AS rate_after_discount
FROM sqlserver_fdw.poamendmentitemdetail poid
LEFT JOIN migration.status_mapping sm
    ON sm.old_status_id = poid.StatusNo;


 
WITH cte AS
(
    SELECT
        id,
        (ROW_NUMBER() OVER (
            PARTITION BY po_id
            ORDER BY id
        ) * 1) AS new_line_no
    FROM purchase.purchase_order_item_detail
)
UPDATE purchase.purchase_order_item_detail qid
SET line_no = cte.new_line_no
FROM cte
WHERE qid.id = cte.id;


--update item status=authorize if doc status=authorize but status=draft
UPDATE purchase.purchase_order_item_detail poid
SET status_id = 9
FROM purchase.purchase_order_main pom 
WHERE pom.id = poid.po_id 
  AND poid.status_id = 7 
  AND pom.document_status_id = 30;

UPDATE purchase.purchase_order_main pom
SET status_id = 9
WHERE pom.status_id = 7
  AND pom.document_status_id =30;


--- checks

select poid.id, poid.status_id, pom.document_status_id  from purchase.purchase_order_item_detail poid
left join purchase .purchase_order_main pom 
on pom.id=poid.po_id 
where pom.document_status_id=10 and poid.status_id not in (7,14)

select distinct pom.id from purchase.purchase_order_item_detail poid
left join purchase .purchase_order_main pom 
on pom.id=poid.po_id 
where pom.document_status_id in (10,20) and poid.status_id <> 7

select * from purchase.purchase_order_item_detail poid 
where poid.po_id =838

select pom.id, pom.main_po_id , poid.id, pom.document_status_id , pom.status_id, poid.status_id   from purchase.purchase_order_main pom 
inner join purchase.purchase_order_item_detail poid 
on poid.po_id =pom.id
where pom.document_status_id =30 and pom.status_id in (7,14)

select * from purchase.purchase_order_main pom 
where pom.document_status_id =20 and pom.status_id not in (7,14)

--- Cs detail id and quotation item detail id update

--WITH cte AS
--(
--    SELECT
--        1 AS case_no,
--        qid.quotation_id,
--        qid.item_id AS item_id,
--        qid.rfq_make_id,
--        qid.make_id,
--        qm.vendor_location_id,
--        cqd.cs_id,
--        cqd.quotation_id
--    FROM purchase.cs_quotation_detail cqd
--    INNER JOIN purchase.cs_main cs
--        ON cs.id = cqd.cs_id
--    INNER JOIN purchase.quotation_item_detail qid
--        ON qid.quotation_id = cqd.quotation_id
--    INNER JOIN purchase.quotation_main qm
--        ON qm.id = qid.quotation_id
--    WHERE cs.cs_type = 1
--      AND cqd.is_selected = true
--    UNION ALL
--    SELECT
--        2 AS case_no,
--        cqd.quotation_id AS revised_quotation_no,
--        cqd.item_id,
--        cqd.make_id AS rfq_make_id,
--        qid.make_id,
--        qm.vendor_location_id,
--        cqd.cs_id,
--        cqd.quotation_id
--    FROM purchase.cs_quotation_detail cqd
--    INNER JOIN purchase.cs_main cs
--        ON cs.id = cqd.cs_id
--    INNER JOIN purchase.quotation_item_detail qid
--        ON qid.quotation_id = cqd.quotation_id
--       AND qid.item_id = cqd.item_id
--       AND COALESCE(qid.rfq_make_id,0) = COALESCE(cqd.make_id,0)
--    INNER JOIN purchase.quotation_main qm
--        ON qm.id = qid.quotation_id
--    WHERE cs.cs_type = 2
--      AND cqd.is_selected = true
--),
--po_match AS
--(
--    SELECT
--        pid.id AS po_item_detail_id,
--        COALESCE(tt.quotation_id, tt2.quotation_id) AS quotation_id
--    FROM purchase.purchase_order_item_detail pid
--    INNER JOIN purchase.purchase_order_main pa
--        ON pa.id = pid.po_id
--    LEFT JOIN LATERAL
--    (
--        SELECT
--            c.quotation_id
--        FROM cte c
--        WHERE c.vendor_location_id = pa.vendor_location_id
--          AND c.item_id = pid.item_id
--          AND c.cs_id = pid.cs_id
--        LIMIT 1
--    ) tt
--        ON true
--    LEFT JOIN LATERAL
--    (
--        SELECT
--            c.quotation_id
--        FROM cte c
--        INNER JOIN masterdata.duplicate_item_group_detail gd
--            ON gd.item_id = c.item_id
--
--        WHERE c.vendor_location_id = pa.vendor_location_id
--          AND c.cs_id = pid.cs_id
--          AND gd.duplicate_item_group_id IN
--          (
--              SELECT d.duplicate_item_group_id
--              FROM masterdata.duplicate_item_group_detail d
--              WHERE d.item_id = pid.item_id
--          )
--        LIMIT 1
--    ) tt2
--        ON true
--
--    WHERE pid.cs_id IS NOT NULL
--)
----UPDATE purchase.purchase_order_item_detail pid
----SET
----    cs_quotation_detail_id = cqd.id,
----    quotation_item_detail_id = qid.id
--select cqd.id as cs_detail_id, qid.id as qid
--FROM po_match pm
--INNER JOIN purchase.cs_quotation_detail cqd
--    ON cqd.quotation_id = pm.quotation_id
--   AND cqd.cs_id = pid.cs_id
--INNER JOIN purchase.quotation_item_detail qid
--    ON qid.quotation_id = pm.quotation_id
--   AND qid.item_id = pid.item_id
--WHERE pid.id = pm.po_item_detail_id;
-- 
--
-----
--
--WITH CTE AS (
--    SELECT 
--        1 AS CaseNO, 
--        QID.RevisedQuotationNo, 
--        QID.ItemNO, 
--        QID.RFQMakeNo, 
--        QID.MakeNo, 
--        qm.VendorLocationNo, 
--        cqd.csno, 
--        cqd.QQuotationNo
--    FROM sqlserver_fdw.csquotationDetail AS CQD
--    INNER JOIN sqlserver_fdw.CsMain AS cs 
--        ON cs.csNo = cqd.csNo
--    INNER JOIN sqlserver_fdw.RevisedQuotationItemDetail AS QID 
--        ON QID.RevisedQuotationNo = CQD.RevisedQuotationNo
--    INNER JOIN sqlserver_fdw.RevisedQuotationMain AS qm 
--        ON qm.RevisedQuotationNo = QID.RevisedQuotationNo
--    WHERE cs.cstype = 1
--      AND CQD.IsSelected is True 
--    UNION ALL
--    SELECT 
--        2 AS CaseNO, 
--        cqd.RevisedQuotationno, 
--        cqd.itemno, 
--        cqd.MakeNo AS RFQMakeNO, 
--        qid.MakeNo, 
--        qm.VendorLocationNO, 
--        cqd.csno, 
--        cqd.QQuotationNo
--    FROM sqlserver_fdw.csquotationdetail AS CQD
--    INNER JOIN sqlserver_fdw.CsMain AS cs 
--        ON cs.csNo = cqd.csNo
--    INNER JOIN sqlserver_fdw.RevisedQuotationItemDetail AS qid 
--        ON qid.RevisedQuotationNo = cqd.RevisedQuotationNo 
--       AND qid.itemno = cqd.itemNO 
--       AND COALESCE(qid.rfqMakeNo, 0) = COALESCE(cqd.makeNO, 0)
--    INNER JOIN sqlserver_fdw.RevisedQuotationMain AS qm 
--        ON qm.RevisedQuotationNo = qid.RevisedQuotationNo
--    WHERE cs.cstype = 2
--      AND CQD.IsSelected is True 
--)
----update table purchase.purchase_order_item_detail poid
----set poid.cs_quotation_detail_id = c.QQuotationNo,
----poid.quotation_item_detail_id = qid.RevisedQuotationItemDetailNo
--select count(*)
--FROM sqlserver_fdw.poAmendmentITemDetail AS PID
--INNER JOIN sqlserver_fdw.poAmendmentMain AS PA 
--    ON PA.POAmendmentNO = PID.POAmendmentNo 
--LEFT JOIN LATERAL (
--    SELECT c.QquotationNo
--    FROM CTE AS c 
--    WHERE c.VendorLocationNo = PA.VendorLocationNo 
--      AND c.ItemNO = PID.itemno 
--      AND c.csNO = PID.csno
--    LIMIT 1
--) tt ON TRUE
--LEFT JOIN LATERAL (
--    SELECT c.QquotationNo
--    FROM CTE AS c 
--    INNER JOIN sqlserver_fdw.mDuplicateItemGroupDetail AS gd 
--        ON gd.ItemNo = c.ItemNo
--    WHERE c.VendorLocationNo = PA.VendorLocationNo 
--      AND c.csNO = PID.csno
--      AND gd.DItemGroupNo IN (
--          SELECT d.dItemGroupNo 
--          FROM sqlserver_fdw.mDuplicateItemGroupDetail AS d 
--          WHERE d.itemNo = PID.itemno
--      )
--    LIMIT 1
--) tt2 ON TRUE
--WHERE PID.csNo IS NOT null;
--
--










