INSERT INTO purchase.purchase_order_summary
(
    main_po_id,
    current_amendment_no,
    last_ack_amendment_no,
    last_ack_date,
    last_published_amendment_no,
    last_published_date,
    current_authorized_amendment_no
)
SELECT
    p.main_po_id,
    MAX(p.amendment_no) AS current_amendment_no,
    NULL AS last_ack_amendment_no,
    NULL AS last_ack_date,
    (
        SELECT p1.amendment_no
        FROM purchase.purchase_order_main p1
        WHERE p1.main_po_id = p.main_po_id
          AND p1.is_published = TRUE
        ORDER BY p1.amendment_no DESC
        LIMIT 1
    ) AS last_published_amendment_no,
    (
        SELECT p1.publication_modified_date
        FROM purchase.purchase_order_main p1
        WHERE p1.main_po_id = p.main_po_id
          AND p1.is_published = TRUE
        ORDER BY p1.amendment_no DESC
        LIMIT 1
    ) AS last_published_date,
    (
        SELECT MAX(p2.amendment_no)
        FROM purchase.purchase_order_main p2
        WHERE p2.main_po_id = p.main_po_id
          AND p2.document_status_id = 30
    ) AS current_authorized_amendment_no
FROM purchase.purchase_order_main p
GROUP BY p.main_po_id;