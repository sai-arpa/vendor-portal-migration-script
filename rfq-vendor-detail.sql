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
