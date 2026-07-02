CREATE FOREIGN TABLE if not exists sqlserver_fdw.changepostatusitemdetails
(
    changepostatusitemdetailsno integer,
    changepostatusno integer,
    itemno integer,
    makeno integer,
    statusno smallint,
    reason varchar(500),
    isreleaseindent bit,
    technicalgradeno integer,
    cancelqty numeric(15,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'ChangePOStatusItemDetails'
);

INSERT INTO purchase.po_cancellation_item_detail
(
	id,
    line_no,
    po_cancellation_id,
    po_item_detail_id,
    cancel_qty,
    is_release_pr_quantity,
    status_id,
    remarks
)
overriding system value
select
	cpsi.changepostatusitemdetailsno,
    poi.line_no,
    pcm.id,
    poi.id,
    cpsi.cancelqty,
	COALESCE(cpsi.isreleaseindent, B'0') = B'0',
    sm.new_status_id,
    cpsi.reason
FROM sqlserver_fdw.changepostatusitemdetails cpsi
INNER JOIN sqlserver_fdw.changepostatusmain cpsm
    ON cpsm.changepostatusno = cpsi.changepostatusno
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.po_id = cpsm.poamendmentno
INNER JOIN purchase.purchase_order_item_detail poi
    ON poi.po_id = cpsm.poamendmentno
   AND poi.item_id = cpsi.itemno
   AND COALESCE(poi.make_id,0) = COALESCE(cpsi.makeno,0)
LEFT JOIN migration.status_mapping sm
    ON sm.old_status_id = cpsi.statusno;


-- remove duplicates po_cancellation_id and po_item_detail_id
WITH duplicate_groups AS
(
    SELECT
        po_cancellation_id,
        po_item_detail_id,
        MIN(id) AS keep_id,
        SUM(cancel_qty) AS total_cancel_qty
    FROM purchase.po_cancellation_item_detail
    GROUP BY
        po_cancellation_id,
        po_item_detail_id
    HAVING COUNT(*) > 1
)
UPDATE purchase.po_cancellation_item_detail pcid
SET cancel_qty = dg.total_cancel_qty
FROM duplicate_groups dg
WHERE pcid.id = dg.keep_id;


DELETE FROM purchase.po_cancellation_item_detail pcid
WHERE pcid.id IN
(
    SELECT pcid2.id
    FROM purchase.po_cancellation_item_detail pcid2
    INNER JOIN
    (
        SELECT
            po_cancellation_id,
            po_item_detail_id,
            MIN(id) AS keep_id
        FROM purchase.po_cancellation_item_detail
        GROUP BY
            po_cancellation_id,
            po_item_detail_id
        HAVING COUNT(*) > 1
    ) dg
        ON dg.po_cancellation_id = pcid2.po_cancellation_id
       AND dg.po_item_detail_id = pcid2.po_item_detail_id
    WHERE pcid2.id <> dg.keep_id
);