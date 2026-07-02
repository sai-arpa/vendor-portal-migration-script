CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.changepostatusindentdetails
(
    ChangePOStatusIndentDetailsNo INTEGER,
    ChangePOStatusNo INTEGER,
    IndentNo INTEGER,
    POItemNo INTEGER,
    POMakeNo SMALLINT,
    IndentItemLineNo NUMERIC(10,3),
    CancelQty NUMERIC(15,3)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'ChangePOStatusIndentDetails'
);

INSERT INTO purchase.po_cancellation_pr_detail
(
    id,
    po_cancellation_id,
    po_cancellation_item_detail_id,
    pr_item_detail_id,
    po_item_detail_id,
    pr_cancel_qty,
    purchase_order_cancellation_item_detail_id
)
OVERRIDING SYSTEM VALUE
SELECT
    cpsid.ChangePOStatusIndentDetailsNo,
    pcm.id,
    pcid.id,
    prid.id,
    poid.id,
    COALESCE(cpsid.CancelQty,0),
    pcid.id
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsid.ChangePOStatusNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = pcm.po_id
   AND poid.item_id = cpsid.POItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
INNER JOIN purchase.po_cancellation_item_detail pcid
    ON pcid.po_cancellation_id = pcm.id
   AND pcid.po_item_detail_id = poid.id;
