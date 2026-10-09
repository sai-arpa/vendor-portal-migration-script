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
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsi.changePoStatusNo
INNER JOIN purchase.purchase_order_item_detail poi
    ON poi.po_id = pcm.po_id
   AND poi.item_id = cpsi.itemno
   AND COALESCE(poi.make_id,0) = COALESCE(cpsi.makeno,0)
LEFT JOIN migration.status_mapping sm
    ON sm.old_status_id = cpsi.statusno;

