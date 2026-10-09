CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.poamendmentindentdetail
(
    POAmendmentIndentDetailNo INTEGER,
    POAmendmentNo INTEGER,
    IndentNo INTEGER,
    ItemNo INTEGER,
    IndentMakeNo INTEGER,
    MakeNo INTEGER,
    FirstCF NUMERIC(7,3),
    POUnitNo INTEGER,
    SecondCF NUMERIC(7,3),
    POQty NUMERIC(10,3),
    PORate NUMERIC(19,4),
    ScheduleDate TEXT,
    IndentItemLineNo NUMERIC(10,3)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'POAmendmentIndentDetail'
);


INSERT INTO purchase.purchase_order_pr_item_detail
(
    id,
    po_id,
    po_item_detail_id,
    pr_item_detail_id,
    item_id,
    pr_qty,
    po_qty,
    po_rate,
    pr_make_id,
    po_make_id,
    pr_unit_id,
    po_unit_id,
    first_cf,
    second_cf
)
OVERRIDING SYSTEM VALUE
SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    poid.id,
    prid.id,
    paid.ItemNo,
    prid.pr_qty,
    COALESCE(paid.POQty,0),
    COALESCE(paid.PORate,0),
    paid.IndentMakeNo,
    paid.MakeNo,
    prid.unit_id,
    paid.POUnitNo,
    COALESCE(paid.FirstCF,0),
    COALESCE(paid.SecondCF,0)
FROM sqlserver_fdw.poamendmentindentdetail paid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = paid.IndentNo
   AND prid.line_no = paid.IndentItemLineNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0);



----- checks ------- 33

select * FROM sqlserver_fdw.poamendmentindentdetail paid
left JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
where poid.id is null


select count(*) FROM sqlserver_fdw.poamendmentindentdetail paid;


--- Qty Mismatch
select count(*) from (
select pi.poamendmentitemdetailno , pi.quantity as itemQty, sum(popr.poqty ) as poPrQty from sqlserver_fdw.poamendmentitemdetail pi
left join sqlserver_fdw.poamendmentindentdetail popr
on popr.poamendmentno = pi.poamendmentno 
and popr.itemno =pi.itemno 
and coalesce(popr.makeNo = coalesce(pi.makeNo,0)
group by pi.poamendmentitemdetailno, pi.quantity
having pi.quantity <> sum(popr.poqty )
) x










