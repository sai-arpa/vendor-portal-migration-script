CREATE FOREIGN TABLE sqlserver_fdw.changeindentstatusitemdetail
(
    changeindentstatusitemdetailno integer,
    changeindentstatusno integer,
    indentitemlineno numeric(10,3),
    itemno integer,
    makeno smallint,
    statusno smallint,
    reason varchar(500),
    cancelqty numeric(15,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'ChangeIndentStatusItemdetail'
);



INSERT
	INTO
	utility.purchase_request_cancellation_item_detail (
id,
	line_no,
	pr_cancellation_id,
	pr_item_detail_id,
	status_id,
	cancel_qty,
	reason
)
OVERRIDING SYSTEM VALUE
SELECT
	cid.changeindentstatusitemdetailno AS id,
	cid.indentitemlineno AS line_no,
	cid.changeindentstatusno AS pr_cancellation_id,
	pid.id AS pr_item_detail_id,
	sm.new_status_id AS status_id,
	cid.cancelqty,
	cid.reason
FROM
	sqlserver_fdw.ChangeIndentStatusItemDetail cid
INNER JOIN utility.purchase_request_cancellation_main pcm
ON
	cid.changeindentstatusno = pcm.id
INNER JOIN inventory.purchase_request_item_detail pid
ON
	pid.pur_req_id = pcm.pr_id
	AND pid.line_no = cid.indentitemlineno
INNER JOIN migration.status_mapping sm
ON
	cid.statusno = sm.old_status_id;
