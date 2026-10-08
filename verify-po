-- Verification Script for Purchase Order Migration

WITH verification_data AS (
    -- 1. Purchase Order Main
    SELECT
        'Purchase Order Main' AS table_name,
        'Row Count' AS metric,
        (SELECT COUNT(1) FROM sqlserver_fdw.poamendmentmain) AS source_value,
        (SELECT COUNT(1) FROM purchase.purchase_order_main) AS destination_value
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
        (SELECT COUNT(1) FROM sqlserver_fdw.poamendmentitemdetail),
        (SELECT COUNT(1) FROM purchase.purchase_order_item_detail)
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
            (SELECT COUNT(1) FROM sqlserver_fdw.poamendmenttaxdetail WHERE EXISTS (SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = POAmendmentNo)) +
            (SELECT COUNT(1) FROM sqlserver_fdw.poamendmentotherchargedetail WHERE EXISTS (SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = POAmendmentNo))
        ),
        (SELECT COUNT(1) FROM purchase.purchase_order_tax_detail)
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
            SELECT COUNT(1) 
            FROM sqlserver_fdw.poamendmentindentdetail paid
            INNER JOIN inventory.purchase_request_item_detail prid ON prid.pur_req_id = paid.IndentNo AND prid.line_no = paid.IndentItemLineNo
            INNER JOIN purchase.purchase_order_item_detail poid ON poid.po_id = paid.POAmendmentNo AND poid.item_id = paid.ItemNo AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
        ),
        (SELECT COUNT(1) FROM purchase.purchase_order_pr_item_detail)
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

    
    
    
SELECT
    id,
    qty,
    rate,
    basic_amount,
    ROUND(qty * rate, 2) AS calculated_basic_amount
FROM purchase.purchase_order_item_detail
WHERE basic_amount <> ROUND(qty * rate, 2)
order by id;




------
---Make wise count comparision
SELECT 
    COALESCE(prid.make_id, i.makeno) AS make_id,
    COALESCE(prid.prid_count, 0) AS purchase_request_count,
    COALESCE(i.indent_count, 0) AS indent_item_count,
    COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) AS difference
FROM (
    SELECT prid.make_id, COUNT(1) AS prid_count 
    FROM purchase.purchase_order_item_detail prid
    GROUP BY prid.make_id
) prid
FULL OUTER JOIN (
    SELECT i.makeno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.poamendmentitemdetail i 
    GROUP BY i.makeno
) i 
ON coalesce(prid.make_id,0) = coalesce(i.makeno,0)
where COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) > 0 
ORDER BY make_id;

--item wise count comparision
SELECT 
    COALESCE(prid.item_id, i.itemno) AS item_id,
    COALESCE(prid.prid_count, 0) AS purchase_request_count,
    COALESCE(i.indent_count, 0) AS indent_item_count,
    COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) AS difference
FROM (
    SELECT prid.item_id, COUNT(1) AS prid_count 
    FROM purchase.purchase_order_item_detail prid
    GROUP BY prid.item_id
) prid
FULL OUTER JOIN (
    SELECT i.itemno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.poamendmentitemdetail i 
    GROUP BY i.itemno
) i 
ON coalesce(prid.item_id,0) = coalesce(i.itemno,0)
where COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) > 0 
ORDER BY item_id;

--unit wise count cmaprision
SELECT 
    COALESCE(prid.unit_id, i.unitno) AS unit_id,
    COALESCE(prid.prid_count, 0) AS purchase_request_count,
    COALESCE(i.indent_count, 0) AS indent_unit_count,
    COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) AS difference
FROM (
    SELECT prid.unit_id, COUNT(1) AS prid_count 
    FROM purchase.purchase_order_item_detail prid
    GROUP BY prid.unit_id
) prid
FULL OUTER JOIN (
    SELECT i.unitno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.poamendmentitemdetail i 
    GROUP BY i.unitno
) i 
ON coalesce(prid.unit_id,0) = coalesce(i.unitno,0)
where COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) > 0 
ORDER BY unit_id;

---cost center wise count comparision
SELECT 
    COALESCE(prid.cost_center_id, i.costCenterno) AS costCenter_id,
    COALESCE(prid.prid_count, 0) AS purchase_request_count,
    COALESCE(i.indent_count, 0) AS indent_costCenter_count,
    COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) AS difference
FROM (
    SELECT prid.cost_center_id, COUNT(1) AS prid_count 
    FROM purchase.purchase_order_item_detail prid
    GROUP BY prid.cost_Center_id
) prid
FULL OUTER JOIN (
    SELECT i.costCenterno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.poamendmentitemdetail i 
    GROUP BY i.costCenterno
) i 
ON coalesce(prid.cost_center_id,0) = coalesce(i.costCenterno,0)
where COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) > 0 
ORDER BY costCenter_id;

--- Division Wise count
select a.division_id, a.count, b.divisionno , b.count  from
(select prm.division_id, count(1) from purchase.purchase_order_main prm 
group by prm.division_id ) a
full outer join 
(select i.divisionno, count(1) from sqlserver_fdw.poamendmentmain i 
group by i.divisionno ) b
on a.division_id = b.divisionno 
where a.count - b.count > 0

----Department wise count
select a.department_id, a.count, b.deptno , b.count  from
(select prm.department_id, count(1) from purchase.purchase_order_main prm 
group by prm.department_id ) a
full outer join 
(select i.deptno , count(1) from sqlserver_fdw.poamendmentmain i 
group by i.deptno ) b
on a.department_id = b.deptno 
where a.count - b.count > 0

---Company Wise Count
select a.company_id, a.count, b.companyno , b.count  from
(select prm.company_id, count(1) from purchase.purchase_order_main prm 
group by prm.company_id ) a
full outer join 
(select i.companyno , count(1) from sqlserver_fdw.poamendmentmain i 
group by i.companyno ) b
on a.company_id = b.companyno 
where a.count - b.count > 0

