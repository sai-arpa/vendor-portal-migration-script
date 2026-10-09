CREATE FOREIGN TABLE sqlserver_fdw.fipl_inventory_item_process_detail (
    indentitemdetailno INTEGER,
    indentno INTEGER,
    itemno INTEGER,
    makeno SMALLINT,
    indentitemlineno NUMERIC(10, 3),
    indentqty NUMERIC(10, 3),
    statusno SMALLINT,  -- SQL Server tinyint maps to PostgreSQL SMALLINT
    statusname VARCHAR(15),
    authorizedpoqty NUMERIC(38, 3),
    poqty NUMERIC(38, 3),
    calstatus VARCHAR(4)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'dbo',
    table_name 'FIPL_Inventory_Item_Process_Detail'
);



--------------------------------------------------- RFQ Item DEtail ------------------------------------------------------------------------------------------------------
-- Update CS Booking Qty

WITH CSBooking AS
(
    /* Item-wise CS */
    SELECT
        qid.rfq_item_detail_id,
        SUM(cqd.qty) AS booking_qty
    FROM purchase.cs_main cm
    INNER JOIN purchase.cs_quotation_detail cqd
        ON cqd.cs_id = cm.id
    INNER JOIN purchase.quotation_item_detail qid
        ON qid.id = cqd.quotation_item_detail_id
    WHERE cm.ref_doc_type_no = 7
      AND cqd.quotation_item_detail_id IS NOT NULL
    GROUP BY qid.rfq_item_detail_id
    UNION ALL
    /* Overall CS */
    SELECT
        qid.rfq_item_detail_id,
        SUM(qid.qty) AS booking_qty
    FROM purchase.cs_main cm
    INNER JOIN purchase.cs_quotation_detail cqd
        ON cqd.cs_id = cm.id
    INNER JOIN purchase.quotation_item_detail qid
        ON qid.quotation_id = cqd.quotation_id
    INNER JOIN purchase.pur_rfq_item_detail rfq
        ON rfq.id = qid.rfq_item_detail_id
       AND rfq.item_id = qid.item_id
       AND COALESCE(rfq.make_id, 0) = COALESCE(qid.make_id, 0)
    WHERE cm.ref_doc_type_no = 7
      AND cqd.quotation_item_detail_id IS NULL
    GROUP BY qid.rfq_item_detail_id
),
CSBookingFinal AS
(
    SELECT
        rfq.id AS rfq_item_detail_id,
        COALESCE(SUM(cb.booking_qty), 0) AS cs_booking_qty
    FROM purchase.pur_rfq_item_detail rfq
    LEFT JOIN CSBooking cb
        ON cb.rfq_item_detail_id = rfq.id
    GROUP BY rfq.id
)
UPDATE purchase.pur_rfq_item_detail rfq
SET cs_booking_qty = cb.cs_booking_qty
FROM CSBookingFinal cb
WHERE rfq.id = cb.rfq_item_detail_id;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Pr Item Detail
    
-- Update PO Qty    
UPDATE inventory.purchase_request_item_detail
SET po_qty = 0;

UPDATE inventory.purchase_request_item_detail pr
SET po_qty = x.po_qty
FROM (
    SELECT
        popr.pr_item_detail_id,
        SUM(popr.po_qty) AS po_qty
    FROM purchase.purchase_order_pr_item_detail popr
    INNER JOIN purchase.purchase_order_main pom
        ON pom.id = popr.po_id
    WHERE pom.ref_doc_type_id IN (3, 4)
      AND pom.amendment_no = (
          SELECT MAX(pom2.amendment_no)
          FROM purchase.purchase_order_main pom2
          WHERE pom2.main_po_id = pom.main_po_id
      )
    GROUP BY popr.pr_item_detail_id
) x
WHERE pr.id = x.pr_item_detail_id;

-- Update Direct PO Qty
UPDATE inventory.purchase_request_item_detail
SET direct_po_qty = 0;

UPDATE inventory.purchase_request_item_detail pr
SET direct_po_qty = x.direct_po_qty
FROM (
    SELECT
        popr.pr_item_detail_id,
        SUM(popr.po_qty) AS direct_po_qty
    FROM purchase.purchase_order_pr_item_detail popr
    INNER JOIN purchase.purchase_order_main pom
        ON pom.id = popr.po_id
    WHERE pom.ref_doc_type_id = 3
      AND pom.amendment_no = (
          SELECT MAX(pom2.amendment_no)
          FROM purchase.purchase_order_main pom2
          WHERE pom2.main_po_id = pom.main_po_id
      )
    GROUP BY popr.pr_item_detail_id
) x
WHERE pr.id = x.pr_item_detail_id;

-- Upodate PR Cancel Qty
UPDATE inventory.purchase_request_item_detail
SET pr_cancel_qty = 0;

UPDATE inventory.purchase_request_item_detail pr
SET pr_cancel_qty = x.pr_cancel_qty
FROM (
    SELECT
        prcid.pr_item_detail_id,
        SUM(prcid.cancel_qty) AS pr_cancel_qty
    FROM utility.purchase_request_cancellation_item_detail prcid
    INNER JOIN utility.purchase_request_cancellation_main prcm
        ON prcm.id = prcid.pr_cancellation_id
    WHERE prcm.document_status_id = 30
    GROUP BY prcid.pr_item_detail_id
) x
WHERE pr.id = x.pr_item_detail_id;


--- Update PO Release Qty
UPDATE inventory.purchase_request_item_detail
SET po_release_qty = 0;

UPDATE inventory.purchase_request_item_detail pr
SET po_release_qty = x.po_release_qty
FROM (
    SELECT
        pcpd.pr_item_detail_id,
        SUM(pcpd.pr_cancel_qty) AS po_release_qty
    FROM purchase.po_cancellation_pr_detail pcpd
    INNER JOIN purchase.po_cancellation_item_detail pcid
        ON pcid.id = pcpd.po_cancellation_item_detail_id
    WHERE pcid.is_release_pr_quantity = TRUE
    GROUP BY pcpd.pr_item_detail_id
) x
WHERE pr.id = x.pr_item_detail_id;


-- Update Balance Qty
UPDATE inventory.purchase_request_item_detail
SET balance_qty =
      pr_qty
    - COALESCE(po_qty, 0)
    - COALESCE(pr_cancel_qty, 0)
    + COALESCE(po_release_qty, 0);

-- Update RFQ Qty
UPDATE inventory.purchase_request_item_detail
SET rfq_qty = 0;

UPDATE inventory.purchase_request_item_detail pr
SET rfq_qty = x.rfq_qty
FROM (
    SELECT
        prd.pr_item_detail_id,
        SUM(prd.rfq_qty) AS rfq_qty
    FROM purchase.pur_rfq_pr_detail prd
    GROUP BY prd.pr_item_detail_id
) x
WHERE pr.id = x.pr_item_detail_id;

-- Update RFQ Release Qty
UPDATE inventory.purchase_request_item_detail
SET rfq_release_qty = 0;

UPDATE inventory.purchase_request_item_detail pr
SET rfq_release_qty = x.rfq_release_qty
FROM (
    SELECT
        rld.pr_item_detail_id,
        SUM(rld.rfq_qty) AS rfq_release_qty
    FROM purchase.pur_rfq_pr_item_removal_log_detail rld
    GROUP BY rld.pr_item_detail_id
) x
WHERE pr.id = x.pr_item_detail_id;


-- Update RFQ Balance Qty
UPDATE inventory.purchase_request_item_detail
SET rfq_balance_qty =
      pr_qty
    - COALESCE(rfq_qty, 0)
    + COALESCE(rfq_release_qty, 0);

-----------------------------------------------------------------------------------------------
--PR Item Detail balance and status tally


-- Case 1
--Draft PR — all items must be Draft
--If any item is 7, all items should be 7, and header should be 
	--document_status_id = 10, 
	--status_id = 7.
SELECT
    prm.id AS pr_id,
    prm.document_status_id,
    prm.status_id AS header_status_id,
    COUNT(*) AS total_items,
    COUNT(*) FILTER (WHERE prid.status_id = 7) AS draft_items
FROM inventory.purchase_request_main prm
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = prm.id
GROUP BY
    prm.id,
    prm.document_status_id,
    prm.status_id
HAVING
    COUNT(*) FILTER (WHERE prid.status_id = 7) > 0
    AND (
        COUNT(*) FILTER (WHERE prid.status_id <> 7) > 0
        OR prm.document_status_id <> 10
        OR prm.status_id <> 7
    )
ORDER BY prm.id;

-- Case 2 (164)
--Authorized PR — all items Authorized
--For a PR where all items are 9, header should be:
	--document_status_id = 30
	--status_id = 9

SELECT
    prm.id AS pr_id,
    prm.document_status_id,
    prm.status_id AS header_status_id,
    COUNT(*) AS total_items
FROM inventory.purchase_request_main prm
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = prm.id
GROUP BY
    prm.id,
    prm.document_status_id,
    prm.status_id
HAVING
    COUNT(*) FILTER (WHERE prid.status_id = 5) = 0
    AND COUNT(*) FILTER (WHERE prid.status_id = 9) = COUNT(*)
    AND (
        prm.document_status_id <> 30
        OR prm.status_id <> 9
    )
ORDER BY prm.id;

--update query
UPDATE inventory.purchase_request_main prm
SET
    document_status_id = 30,
    status_id = 9
WHERE prm.id IN (
    SELECT prid.pur_req_id
    FROM inventory.purchase_request_item_detail prid
    GROUP BY prid.pur_req_id
    HAVING
        COUNT(*) FILTER (WHERE prid.status_id = 5) = 0
        AND COUNT(*) FILTER (WHERE prid.status_id = 9) = COUNT(*)
);

-- Case 3 (7)
--In Progress PR
--If at least one item is In Progress (10), the header should be:
	--document_status_id = 30
	--status_id = 10
SELECT
    prm.id AS pr_id,
    prm.document_status_id,
    prm.status_id AS header_status_id,
    COUNT(*) AS total_items,
    COUNT(*) FILTER (WHERE prid.status_id = 10) AS in_progress_items
FROM inventory.purchase_request_main prm
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = prm.id
GROUP BY
    prm.id,
    prm.document_status_id,
    prm.status_id
HAVING
    COUNT(*) FILTER (WHERE prid.status_id = 5) = 0
    AND COUNT(*) FILTER (WHERE prid.status_id = 10) > 0
    AND (
        prm.document_status_id <> 30
        OR prm.status_id <> 10
    )
ORDER BY prm.id;

--update
UPDATE inventory.purchase_request_main prm
SET
    document_status_id = 30,
    status_id = 10
WHERE prm.id IN (
    SELECT prid.pur_req_id
    FROM inventory.purchase_request_item_detail prid
    GROUP BY prid.pur_req_id
    HAVING
        COUNT(*) FILTER (WHERE prid.status_id = 5) = 0
        AND COUNT(*) FILTER (WHERE prid.status_id = 10) > 0
)
AND (
    prm.document_status_id <> 30
    OR prm.status_id <> 10
);

-- Case 4 (273)
--Completed PR — all items Completed
--If all items are 11, header should be:
	--document_status_id = 30
	--status_id = 11
SELECT
    prm.id AS pr_id,
    prm.document_status_id,
    prm.status_id AS header_status_id,
    COUNT(*) AS total_items
FROM inventory.purchase_request_main prm
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = prm.id
GROUP BY
    prm.id,
    prm.document_status_id,
    prm.status_id
HAVING
    COUNT(*) FILTER (WHERE prid.status_id = 5) = 0
    AND COUNT(*) FILTER (WHERE prid.status_id = 11) = COUNT(*)
    AND (
        prm.document_status_id <> 30
        OR prm.status_id <> 11
    )
ORDER BY prm.id;

--update
UPDATE inventory.purchase_request_main prm
SET
    document_status_id = 30,
    status_id = 11
WHERE prm.id IN (
    SELECT prid.pur_req_id
    FROM inventory.purchase_request_item_detail prid
    GROUP BY prid.pur_req_id
    HAVING
        COUNT(*) FILTER (WHERE prid.status_id = 5) = 0
        AND COUNT(*) FILTER (WHERE prid.status_id = 11) = COUNT(*)
)
AND (
    prm.document_status_id <> 30
    OR prm.status_id <> 11
);

-------------------------------------------------------------------------------------------------------------
---tally with FIPL_Inventory_Item_Process_Detail provide by alok

--status tally
SELECT prid.id, prid.status_id , prid.pr_qty, prid.balance_qty, prid.po_qty, fiipd.*
FROM inventory.purchase_request_item_detail prid
INNER JOIN sqlserver_fdw.fipl_inventory_item_process_detail fiipd 
    ON prid.id = fiipd.indentitemdetailno
LEFT JOIN migration.status_mapping sm 
    ON sm.old_status_id = fiipd.statusno 
WHERE prid.status_id <> CASE fiipd.calstatus
    WHEN 'init' THEN 7
    WHEN 'Auth' THEN 9
    WHEN 'In P' THEN 10
    WHEN 'Comp' THEN 11
    WHEN 'Ex'   THEN 5
END;

--poQTy tally
SELECT prid.id, prid.status_id , prid.pr_qty, prid.balance_qty, prid.po_qty, fiipd.poqty, fiipd.calstatus 
FROM inventory.purchase_request_item_detail prid
INNER JOIN sqlserver_fdw.fipl_inventory_item_process_detail fiipd 
    ON prid.id = fiipd.indentitemdetailno
LEFT JOIN migration.status_mapping sm 
    ON sm.old_status_id = fiipd.statusno 
WHERE prid.po_qty  <> fiipd.poqty 


-- update wrong status in pr item detail
UPDATE inventory.purchase_request_item_detail prid
SET status_id = mapping.expected_status_id
FROM sqlserver_fdw.fipl_inventory_item_process_detail fiipd
JOIN (VALUES 
    ('init', 7),
    ('Auth', 9),
    ('In P', 10),
    ('Comp', 11),
    ('Ex',   5)
) AS mapping(calstatus, expected_status_id)
    ON fiipd.calstatus = mapping.calstatus
WHERE prid.id = fiipd.indentitemdetailno
  AND prid.status_id <> mapping.expected_status_id;



----------------------------------------------------------------------------------------------
--- PR Main Status Update


---checks
select  from inventory.purchase_request_main prm 
inner join inventory.purchase_request_item_detail prid 
on prm.id=prid.pur_req_id 
where prm.document_status_id in (10,20) and prid.status_id not in (7,14)

select * from inventory.purchase_request_main prm 
inner join inventory.purchase_request_item_detail prid 
on prm.id=prid.pur_req_id 
where prm.document_status_id in (30) and prid.status_id in (7,14)



------Updates
UPDATE inventory.purchase_request_main prm
SET document_status_id = 30
WHERE prm.document_status_id <> 30
  AND NOT EXISTS (
      SELECT 1 
      FROM inventory.purchase_request_item_detail prid
      WHERE prid.pur_req_id  = prm.id
        AND prid.status_id IN (7, 14)
  );

UPDATE inventory.purchase_request_main prm
SET status_id = 9
WHERE prm.status_id = 7
  AND prm.document_status_id =30;


-------------------------------------------------------------------------------------------------------------

