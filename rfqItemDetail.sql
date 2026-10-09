
CREATE FOREIGN TABLE sqlserver_fdw.rfqitemdetail
(
    IndentItemDetailNo  integer,
    ItemLineNo          smallint,
    RFQNo               integer,
    ItemNo              integer,
    MakeNo              smallint,
    TechSpecification   varchar(1000),
    Qty                 numeric(9,3),
    RFQUnitNo           smallint,
    DeliveryDate        varchar(50),
    DrawingNo           varchar(50),
    Remark              varchar(1000),
    StatusNo            smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RFQItemDetail'
);

INSERT INTO purchase.pur_rfq_item_detail
(
    id,
    rfq_id,
    line_no,
    item_id,
    make_id,
    hsn_code,
    tech_specification,
    unit_id,
    qty,
    cs_booking_qty,
    balance_qty,
    remarks,
    status_id
)
OVERRIDING SYSTEM VALUE
SELECT
    rfqd.IndentItemDetailNo,
    rfqd.RFQNo,
    rfqd.ItemLineNo,
    rfqd.ItemNo,
    rfqd.MakeNo,
    im.hsn_sac_code,
    NULLIF(TRIM(rfqd.TechSpecification), ''),
    rfqd.RFQUnitNo,
    COALESCE(rfqd.Qty, 0),
    0,
    COALESCE(rfqd.Qty, 0),
    NULLIF(LEFT(TRIM(rfqd.Remark), 500), ''),
    sm.new_status_id
FROM sqlserver_fdw.rfqitemdetail rfqd
LEFT JOIN masterdata.item_master im
    ON im.id = rfqd.ItemNo
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = rfqd.StatusNo;