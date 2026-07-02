INSERT INTO purchase.purchase_order_item_process_detail
(
    main_po_id,
    line_no,
    item_id,
    make_id,
    po_qty,
    grn_process_qty,
    cancel_qty,
    balance_qty,
    po_min_tolerance_qty,
    po_max_tolerance_qty,
    excess_qty,
    status_id
)
SELECT
    pom.main_po_id,
    poid.line_no,
    poid.item_id,
    poid.make_id,
    COALESCE(poid.qty,0) AS po_qty,
    0 AS grn_process_qty,
    COALESCE(poc.cancel_qty,0) AS cancel_qty,
    (
        COALESCE(poid.qty,0)
        - 0
        - COALESCE(poc.cancel_qty,0)
    ) AS balance_qty,
    CASE
        WHEN poid.tolerance_type = 1
        THEN COALESCE(poid.tolerance_minus,0)
        WHEN poid.tolerance_type = 2
        THEN
        (
            COALESCE(poid.qty,0)
            * COALESCE(poid.tolerance_minus,0)
            / 100
        )
        ELSE 0
    END AS po_min_tolerance_qty,
    CASE
        WHEN poid.tolerance_type = 1
        THEN COALESCE(poid.tolerance_plus,0)
        WHEN poid.tolerance_type = 2
        THEN
        (
            COALESCE(poid.qty,0)
            * COALESCE(poid.tolerance_plus,0)
            / 100
        )
        ELSE 0
    END AS po_max_tolerance_qty,
    0 AS excess_qty,
    poid.status_id
FROM purchase.purchase_order_item_detail poid
INNER JOIN purchase.purchase_order_main pom
    ON pom.id = poid.po_id
LEFT JOIN
(
    SELECT
        po_item_detail_id,
        SUM(COALESCE(cancel_qty,0)) AS cancel_qty
    FROM purchase.po_cancellation_item_detail
    GROUP BY po_item_detail_id
) poc
    ON poc.po_item_detail_id = poid.id
WHERE pom.main_po_id IS NOT NULL;