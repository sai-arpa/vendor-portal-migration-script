CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.rfqvendordetail
(
    RFQVendorDetailNo INTEGER,
    RFQNo INTEGER,
    VendorNo INTEGER,
    VendorLocationNo INTEGER,
    VendorContactNo INTEGER,
    IsOpend BIT,
    IsRegret BIT,
    LastEmailSentDate TEXT
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'RFQVendorDetail'
);

INSERT INTO purchase.pur_rfq_vendor_detail
(
    id,
    rfq_id,
    public_id,
    is_guest_vendor,
    user_id,
    vendor_location_id,
    guest_vendor_email,
    guest_vendor_name,
    quotation_status_id,
    created_by_id,
    created_date,
    last_mail_sent_on
)
OVERRIDING SYSTEM VALUE
SELECT
    rvd.RFQVendorDetailNo,
    rvd.RFQNo,
    gen_random_uuid(),
    FALSE,
    NULL AS user_id,
    rvd.VendorLocationNo,
    NULL AS guest_vendor_email,
    NULL AS guest_vendor_name,
    CASE
        WHEN rvd.IsRegret = B'1'
            THEN 22::smallint
        WHEN rvd.IsOpend = B'1'
            THEN 23::smallint
        ELSE NULL
    END AS quotation_status_id,
    rfq.created_by_id,
    rfq.created_date,
    migration.parse_sqlserver_datetime(rvd.LastEmailSentDate)
FROM sqlserver_fdw.rfqvendordetail rvd
INNER JOIN purchase.pur_rfq_main rfq
    ON rfq.id = rvd.RFQNo;



-- quotation status update

UPDATE purchase.pur_rfq_vendor_Detail rvd
SET quotation_status_id = 8
WHERE EXISTS (
    SELECT 1
    FROM purchase.quotation_main qm
    WHERE qm.rfq_vendor_Detail_id = rvd.id
      AND qm.document_status_id = 30
);



--- to be done after quotation_main is migrated
---Insert the missing RFQ vendor details which is referenced in quotation_main

INSERT INTO purchase.pur_rfq_vendor_detail
(
    rfq_id,
    public_id,
    is_guest_vendor,
    user_id,
    vendor_location_id,
    guest_vendor_email,
    guest_vendor_name,
    quotation_status_id,
    created_by_id,
    created_date,
    last_mail_sent_on
)
SELECT
    rqm.rfqno,
    gen_random_uuid(),
    false,
    NULL,
    rqm.vendorlocationno,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
FROM purchase.quotation_main qm
INNER JOIN sqlserver_fdw.revisedquotationmain rqm
    ON rqm.revisedquotationno = qm.id
LEFT JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = rqm.rfqno
   AND rvd.vendor_location_id = rqm.vendorlocationno
WHERE qm.is_auction = false
  AND qm.rfq_vendor_detail_id IS NULL
  AND rvd.id IS NULL;

--- Update missing rfq_vendor_detail_id in quotation_main
UPDATE purchase.quotation_main qm
SET rfq_vendor_detail_id = rvd.id
FROM sqlserver_fdw.revisedquotationmain rqm
INNER JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = rqm.rfqno
   AND rvd.vendor_location_id = rqm.vendorlocationno
WHERE rqm.revisedquotationno = qm.id
  AND qm.is_auction = false
  AND qm.rfq_vendor_detail_id IS NULL;

----- Verification ----


select count(*) from purchase.pur_rfq_vendor_detail prvd 
where prvd.quotation_status_id is null


