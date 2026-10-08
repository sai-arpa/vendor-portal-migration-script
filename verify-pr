-- Verification Script for Purchase Request (Indent) Migration

WITH verification_data AS (
    -- 1. Purchase Request Main
    SELECT
        'Purchase Request Main' AS table_name,
        'Row Count' AS metric,
        (SELECT COUNT(1) FROM sqlserver_fdw.indentmain) AS source_value,
        (SELECT COUNT(1) FROM inventory.purchase_request_main) AS destination_value
    UNION ALL
    SELECT
        'Purchase Request Main',
        'Sum of net_amount',
        (SELECT COALESCE(SUM(NetAmount), 0) FROM sqlserver_fdw.indentmain),
        (SELECT COALESCE(SUM(net_amount), 0) FROM inventory.purchase_request_main)

    -- 2. Purchase Request Item Detail
    UNION ALL
    SELECT
        'Purchase Request Item Detail',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.indentitemdetail),
        (SELECT COUNT(1) FROM inventory.purchase_request_item_detail)
    UNION ALL
    SELECT
        'Purchase Request Item Detail',
        'Sum of required_qty',
        (SELECT COALESCE(SUM(RequiredQty), 0) FROM sqlserver_fdw.indentitemdetail),
        (SELECT COALESCE(SUM(required_qty), 0) FROM inventory.purchase_request_item_detail)
    UNION ALL
    SELECT
        'Purchase Request Item Detail',
        'Sum of pr_qty',
        (SELECT COALESCE(SUM(IndentQty), 0) FROM sqlserver_fdw.indentitemdetail),
        (SELECT COALESCE(SUM(pr_qty), 0) FROM inventory.purchase_request_item_detail)
    UNION ALL
    SELECT
        'Purchase Request Item Detail',
        'Sum of po_qty',
        (SELECT COALESCE(SUM(POQty), 0) FROM sqlserver_fdw.indentitemdetail),
        (SELECT COALESCE(SUM(po_qty), 0) FROM inventory.purchase_request_item_detail)
    UNION ALL
    SELECT
        'Purchase Request Item Detail',
        'Average of rate',
        (SELECT COALESCE(AVG(Rate), 0) FROM sqlserver_fdw.indentitemdetail),
        (SELECT COALESCE(AVG(rate), 0) FROM inventory.purchase_request_item_detail)
    UNION ALL
    SELECT
        'Purchase Request Item Detail',
        'Sum of amount',
        (SELECT COALESCE(SUM(BasicAmount), 0) FROM sqlserver_fdw.indentitemdetail),
        (SELECT COALESCE(SUM(amount), 0) FROM inventory.purchase_request_item_detail)
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
    
    
    -------------------------------------------------------------------------------------------------------------
    ---verify
    
    select * from inventory.purchase_request_main prm 
    left join  utility.approval_process_main apm
    on prm.id = apm.doc_id  and apm.form_id =6
    where apm.id is null and prm.approval_setup_id is not null

    select * from inventory.purchase_request_main prm 
    inner join  utility.approval_process_main apm
    on prm.id = apm.doc_id  and apm.form_id =6
    where prm.approval_setup_id is null
    
    ---fixes
    update inventory.purchase_request_main prm 
    set approval_setup_id=null
    where id=85548
    
    
-- PrMain NetAmount must match PrItemDetail amount sum

select count(*) from (
select 
	prm.id as prmid, 
	sum(prid.amount),
	prm.net_amount
from inventory.purchase_request_main prm
inner join inventory.purchase_request_item_detail prid 
on prid.pur_req_id = prm.id
group by prm.id 
having sum(prid.amount)!=prm.net_amount
)

-- PrItemDetail qty*rate != amount
select 
	prid.pr_qty,
	prid.rate, 
	prid.amount  
from inventory.purchase_request_item_detail prid
where 
	prid.pr_qty * prid.rate <> prid.amount;

------
---Make wise count comparision
SELECT 
    COALESCE(prid.make_id, i.makeno) AS make_id,
    COALESCE(prid.prid_count, 0) AS purchase_request_count,
    COALESCE(i.indent_count, 0) AS indent_item_count,
    COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) AS difference
FROM (
    SELECT prid.make_id, COUNT(1) AS prid_count 
    FROM inventory.purchase_request_item_detail prid
    GROUP BY prid.make_id
) prid
FULL OUTER JOIN (
    SELECT i.makeno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.indentitemdetail i 
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
    FROM inventory.purchase_request_item_detail prid
    GROUP BY prid.item_id
) prid
FULL OUTER JOIN (
    SELECT i.itemno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.indentitemdetail i 
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
    FROM inventory.purchase_request_item_detail prid
    GROUP BY prid.unit_id
) prid
FULL OUTER JOIN (
    SELECT i.unitno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.indentitemdetail i 
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
    FROM inventory.purchase_request_item_detail prid
    GROUP BY prid.cost_Center_id
) prid
FULL OUTER JOIN (
    SELECT i.costCenterno, COUNT(1) AS indent_count 
    FROM sqlserver_fdw.indentitemdetail i 
    GROUP BY i.costCenterno
) i 
ON coalesce(prid.cost_center_id,0) = coalesce(i.costCenterno,0)
where COALESCE(prid.prid_count, 0) - COALESCE(i.indent_count, 0) > 0 
ORDER BY costCenter_id;

--- Division Wise count
select a.division_id, a.count, b.divisionno , b.count  from
(select prm.division_id, count(1) from inventory.purchase_request_main prm 
group by prm.division_id ) a
full outer join 
(select i.divisionno, count(1) from sqlserver_fdw.indentmain i 
group by i.divisionno ) b
on a.division_id = b.divisionno 
where a.count - b.count > 0

----Department wise count
select a.department_id, a.count, b.deptno , b.count  from
(select prm.department_id, count(1) from inventory.purchase_request_main prm 
group by prm.department_id ) a
full outer join 
(select i.deptno , count(1) from sqlserver_fdw.indentmain i 
group by i.deptno ) b
on a.department_id = b.deptno 
where a.count - b.count > 0

---Company Wise Count
select a.company_id, a.count, b.companyno , b.count  from
(select prm.company_id, count(1) from inventory.purchase_request_main prm 
group by prm.company_id ) a
full outer join 
(select i.companyno , count(1) from sqlserver_fdw.indentmain i 
group by i.companyno ) b
on a.company_id = b.companyno 
where a.count - b.count > 0

------------------------------------------------------------------------------------


