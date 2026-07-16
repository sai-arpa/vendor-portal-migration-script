-- Verification Script for Purchase Order Migration

WITH verification_data AS (
-- 1. Purchase Order Main
SELECT
'Purchase Order Main' AS table_name,
'Row Count' AS metric,
(SELECT COUNT(*) FROM sqlserver_fdw.poamendmentmain) AS source_value,
(SELECT COUNT() FROM purchase.purchase_order_main) AS destination_value
UNION ALL
SELECT
'Purchase Order Main',
'Sum of net_amount',
(SELECT COALESCE(SUM(NetAmount), 0) FROM sqlserver_fdw.poamendmentmain),
(SELECT COALESCE(SUM(net_amount), 0) FROM purchase.purchase_order_main)
UNION ALL
SELECT
'Purchase Order Main',
'Sum of basic_amount',
(SELECT COALESCE(SUM(BasicAmount), 0) FROM sqlserver_fdw.poamendmentmain),
(SELECT COALESCE(SUM(basic_amount), 0) FROM purchase.purchase_order_main)
UNION ALL
SELECT
'Purchase Order Main',
'Sum of freight_amount',
(SELECT COALESCE(SUM(FreightAmount), 0) FROM sqlserver_fdw.poamendmentmain),
(SELECT COALESCE(SUM(freight_amount), 0) FROM purchase.purchase_order_main)

-- 2. Purchase Order Item Detail
UNION ALL
SELECT
    'Purchase Order Item Detail',
    'Row Count',
    (SELECT COUNT(*) FROM sqlserver_fdw.poamendmentitemdetail),
    (SELECT COUNT(*) FROM purchase.purchase_order_item_detail)
UNION ALL
SELECT
    'Purchase Order Item Detail',
    'Sum of qty',
    (SELECT COALESCE(SUM(Quantity), 0) FROM sqlserver_fdw.poamendmentitemdetail),
    (SELECT COALESCE(SUM(qty), 0) FROM purchase.purchase_order_item_detail)
UNION ALL
SELECT
    'Purchase Order Item Detail',
    'Average of rate',
    (SELECT COALESCE(AVG(Rate), 0) FROM sqlserver_fdw.poamendmentitemdetail),
    (SELECT COALESCE(AVG(rate), 0) FROM purchase.purchase_order_item_detail)
UNION ALL
SELECT
    'Purchase Order Item Detail',
    'Sum of basic_amount',
    (SELECT COALESCE(SUM(BasicAmount), 0) FROM sqlserver_fdw.poamendmentitemdetail),
    (SELECT COALESCE(SUM(basic_amount), 0) FROM purchase.purchase_order_item_detail)
UNION ALL
SELECT
    'Purchase Order Item Detail',
    'Sum of net_amount',
    (SELECT COALESCE(SUM(NetAmount), 0) FROM sqlserver_fdw.poamendmentitemdetail),
    (SELECT COALESCE(SUM(net_amount), 0) FROM purchase.purchase_order_item_detail)

-- 3. Purchase Order Schedule Detail
UNION ALL
SELECT
    'Purchase Order Schedule Detail',
    'Sum of qty',
    (SELECT COALESCE(SUM(ScheduleQty), 0) FROM sqlserver_fdw.poamendmentitemscheduledetail),
    (SELECT COALESCE(SUM(qty), 0) FROM purchase.purchase_order_schedule_detail)

-- 4. Purchase Order Tax Detail
UNION ALL
SELECT
    'Purchase Order Tax Detail',
    'Row Count',
    (
        (SELECT COUNT(*) FROM sqlserver_fdw.poamendmenttaxdetail WHERE EXISTS (SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = POAmendmentNo)) +
        (SELECT COUNT(*) FROM sqlserver_fdw.poamendmentotherchargedetail WHERE EXISTS (SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = POAmendmentNo))
    ),
    (SELECT COUNT(*) FROM purchase.purchase_order_tax_detail)
UNION ALL
SELECT
    'Purchase Order Tax Detail',
    'Sum of amount',
    (
        (SELECT COALESCE(SUM(TotalValue), 0) FROM sqlserver_fdw.poamendmenttaxdetail WHERE EXISTS (SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = POAmendmentNo)) +
        (SELECT COALESCE(SUM(Amount), 0) FROM sqlserver_fdw.poamendmentotherchargedetail WHERE EXISTS (SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = POAmendmentNo))
    ),
    (SELECT COALESCE(SUM(amount), 0) FROM purchase.purchase_order_tax_detail)

-- 5. Purchase Order PR Item Detail
UNION ALL
SELECT
    'Purchase Order PR Item Detail',
    'Row Count',
    (
        SELECT COUNT(*) 
        FROM sqlserver_fdw.poamendmentindentdetail paid
        INNER JOIN inventory.purchase_request_item_detail prid ON prid.pur_req_id = paid.IndentNo AND prid.line_no = paid.IndentItemLineNo
        INNER JOIN purchase.purchase_order_item_detail poid ON poid.po_id = paid.POAmendmentNo AND poid.item_id = paid.ItemNo AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
    ),
    (SELECT COUNT(*) FROM purchase.purchase_order_pr_item_detail)
UNION ALL
SELECT
    'Purchase Order PR Item Detail',
    'Sum of po_qty',
    (
        SELECT COALESCE(SUM(paid.POQty), 0)
        FROM sqlserver_fdw.poamendmentindentdetail paid
        INNER JOIN inventory.purchase_request_item_detail prid ON prid.pur_req_id = paid.IndentNo AND prid.line_no = paid.IndentItemLineNo
        INNER JOIN purchase.purchase_order_item_detail poid ON poid.po_id = paid.POAmendmentNo AND poid.item_id = paid.ItemNo AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
    ),
    (SELECT COALESCE(SUM(po_qty), 0) FROM purchase.purchase_order_pr_item_detail)
UNION ALL
SELECT
    'Purchase Order PR Item Detail',
    'Sum of po_rate',
    (
        SELECT COALESCE(SUM(paid.PORate), 0)
        FROM sqlserver_fdw.poamendmentindentdetail paid
        INNER JOIN inventory.purchase_request_item_detail prid ON prid.pur_req_id = paid.IndentNo AND prid.line_no = paid.IndentItemLineNo
        INNER JOIN purchase.purchase_order_item_detail poid ON poid.po_id = paid.POAmendmentNo AND poid.item_id = paid.ItemNo AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
    ),
    (SELECT COALESCE(SUM(po_rate), 0) FROM purchase.purchase_order_pr_item_detail)

)
SELECT
table_name AS "Table Name",
metric AS "Metric",
source_value AS "Source Value (SQL Server)",
destination_value AS "Destination Value (PostgreSQL)",
CASE
WHEN source_value = destination_value THEN 'MATCH'
WHEN ABS(source_value - destination_value) < 0.01 THEN 'MATCH (Rounding)'
ELSE 'MISMATCH'
END AS "Status"
FROM verification_data
ORDER BY
table_name,
metric;