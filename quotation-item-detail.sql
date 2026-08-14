BEGIN;
 CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.revisedquotationitemdetail
 (
     RevisedQuotationItemNo INTEGER,
     RevisedQuotationNo INTEGER,
     RFQItemLineNo SMALLINT,
     ItemNo INTEGER,
     RFQMakeNo SMALLINT,
     MakeNo SMALLINT,
     TechSpecification VARCHAR(1000),
     UnitNo SMALLINT,
     Quantity NUMERIC(18,3),
     Rate NUMERIC(19,4),
     DeliveryDays SMALLINT,
     TotalAmount NUMERIC(19,4),
     StatusNo SMALLINT,
     Remarks VARCHAR(1000),
     HSNSACCode VARCHAR(8),
     OtherMake VARCHAR(100)
 )
 SERVER sqlserver_fdw
 OPTIONS
 (
     schema_name 'Purchase',
     table_name 'RevisedQuotationItemDetail'
 );

 INSERT INTO purchase.quotation_item_detail
 (
     id,
     quotation_id,
     line_no,
     rfq_item_detail_id,
     item_id,
     hsn_code,
     rfq_make_id,
     make_id,
     other_make_name,
     qty,
     unit_id,
     rate,
     tax_amount,
     delivery_days,
     basic_amount,
     net_amount,
     tech_spec,
     remarks,
     discount_amount,
     discount_per_qty,
     discount_rate,
     rate_after_discount
 )
 OVERRIDING SYSTEM VALUE
SELECT
    rqid.RevisedQuotationItemNo,
    rqid.RevisedQuotationNo,
    rqid.RFQItemLineNo,
    COALESCE(rfqi.id,275703),
    rqid.ItemNo,
    LEFT(TRIM(COALESCE(rqid.HSNSACCode,'')),10),
    rqid.RFQMakeNo,
    rqid.MakeNo,
    LEFT(TRIM(COALESCE(rqid.OtherMake,'')),100),
    COALESCE(rqid.Quantity,0),
    rqid.UnitNo,
    COALESCE(rqid.Rate,0),
    0,
    COALESCE(rqid.DeliveryDays,0),
    COALESCE(rqid.TotalAmount,0),
    COALESCE(rqid.TotalAmount,0),
    LEFT(TRIM(COALESCE(rqid.TechSpecification,'')),1000),
    LEFT(TRIM(COALESCE(rqid.Remarks,'')),500),
    0,
    0,
    0,
    COALESCE(rqid.Rate,0)
FROM sqlserver_fdw.revisedquotationitemdetail rqid
INNER JOIN purchase.quotation_main qm
    ON qm.id = rqid.RevisedQuotationNo
LEFT JOIN purchase.pur_rfq_item_detail rfqi
    ON rfqi.rfq_id = qm.rfq_id
   AND rfqi.line_no = rqid.RFQItemLineNo;
 
WITH cte AS
(
    SELECT
        id,
        (ROW_NUMBER() OVER (
            PARTITION BY quotation_id
            ORDER BY id
        ) * 10) AS new_line_no
    FROM purchase.quotation_item_detail
)
UPDATE purchase.quotation_item_detail qid
SET line_no = cte.new_line_no
FROM cte
WHERE qid.id = cte.id;
COMMIT;


--- Check for rfq_item_detail_id 
UPDATE purchase.quotation_item_detail qid
SET rfq_item_detail_id = rid.id
FROM purchase.quotation_main qm
JOIN purchase.pur_rfq_item_detail rid
    ON rid.rfq_id = qm.rfq_id
WHERE qid.quotation_id = qm.id
  AND qm.rfq_id IS NOT NULL
  AND rid.item_id = qid.item_id
  AND rid.make_id IS NOT DISTINCT FROM qid.rfq_make_id;
