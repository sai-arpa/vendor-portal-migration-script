INSERT INTO purchase.purchase_order_pr_item_process_detail
(
    main_po_id,
    pr_item_detail_id,
    item_id,
    make_id,
    po_qty,
    grn_qty,
    cancel_qty,
    balance_qty,
    po_min_tolerance_qty,
    po_max_tolerance_qty
)
SELECT
    popr.po_id AS main_po_id,
    popr.pr_item_detail_id,
    popr.item_id,
    popr.po_make_id AS make_id,
    COALESCE(SUM(popr.po_qty),0) AS po_qty,
    0 AS grn_qty,
    COALESCE(SUM(pocpd.pr_cancel_qty),0) AS cancel_qty,
    COALESCE(SUM(popr.po_qty),0)
        - COALESCE(SUM(pocpd.pr_cancel_qty),0) AS balance_qty,
    CASE
        WHEN MAX(poid.tolerance_type) = 1
            THEN MAX(poid.tolerance_minus)
        WHEN MAX(poid.tolerance_type) = 2
            THEN
                (
                    COALESCE(SUM(popr.po_qty),0)
                    * MAX(poid.tolerance_minus)
                ) / 100
        ELSE NULL
    END AS po_min_tolerance_qty,
    CASE
        WHEN MAX(poid.tolerance_type) = 1
            THEN MAX(poid.tolerance_plus)
        WHEN MAX(poid.tolerance_type) = 2
            THEN
                (
                    COALESCE(SUM(popr.po_qty),0)
                    * MAX(poid.tolerance_plus)
                ) / 100
        ELSE NULL
    END AS po_max_tolerance_qty
FROM purchase.purchase_order_pr_item_detail popr
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.id = popr.po_item_detail_id
LEFT JOIN purchase.po_cancellation_pr_detail pocpd
    ON pocpd.po_item_detail_id = popr.po_item_detail_id
   AND pocpd.pr_item_detail_id = popr.pr_item_detail_id
GROUP BY
    popr.po_id,
    popr.pr_item_detail_id,
    popr.item_id,
    popr.po_make_id;