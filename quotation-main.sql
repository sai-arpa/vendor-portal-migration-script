CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.revisedquotationmain
(
    CompanyNo INTEGER,
    YearNo INTEGER,
    RevisedQuotationNo INTEGER,
    RevisedDate TEXT,
    DocumentNoYearly VARCHAR(30),
    DocumentDate TEXT,
    DocumentStatusNo INTEGER,
    RevisedNo INTEGER,
    QuotationNo INTEGER,
    RFQNo INTEGER,
    VendorNo INTEGER,
    VendorLocationNo INTEGER,
    VendorQuotationNo VARCHAR(25),
    VendorQuotedDate TEXT,
    ValidityDate TEXT,
    FreightTypeNo INTEGER,
    PaymentModeNo INTEGER,
    CreditDays INTEGER,
    Remarks VARCHAR(1000),
    StatusNo INTEGER,
    NetAmount NUMERIC(19,4),
    AuctionNo Integer,
    CreatedBy INTEGER,
    CreatedDate TEXT,
    ModifiedBy INTEGER,
    ModifiedDate TEXT,
    AuthorizedBy INTEGER,
    AuthorizedDate TEXT,
    BasicAmount NUMERIC(19,4),
    TaxAmount NUMERIC(19,4),
    ContactName VARCHAR(100),
    ContactNo VARCHAR(50),
    ContactEmail VARCHAR(300)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'RevisedQuotationMain'
);


INSERT INTO purchase.quotation_main
(
    id,
    rfq_id,
    rfq_vendor_detail_id,
    country_id,
    state_id,
    main_quotation_id,
    credit_days,
    validity_date,
    freight_type_id,
    payment_mode_id,
    basic_amount,
    discount_amount,
    tax_amount,
    net_amount,
    status_id,
    revision_no,
    is_current,
    currency_id,
    doc_no_yearly,
    doc_date,
    document_status_id,
    company_id,
    fy_id,
    remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    authorized_by_id,
    authorized_date
)
OVERRIDING SYSTEM VALUE
SELECT
    rqm.RevisedQuotationNo,
    rqm.RFQNo,
    case when rqm.auctionNo is not null then null else rvd.id end,
    NULL,
    NULL,
    NULL,
    COALESCE(rqm.CreditDays,0),
    migration.parse_sqlserver_datetime(rqm.ValidityDate),
    case
    	when rqm.freightTypeNo=1
    		then 2
    	else 1
    end,
    rqm.PaymentModeNo,
    COALESCE(rqm.BasicAmount,0),
    0,
    COALESCE(rqm.TaxAmount,0),
    COALESCE(rqm.NetAmount,0),
    1,
    COALESCE(rqm.RevisedNo,0),
    CASE
        WHEN rqm.RevisedNo =
        (
            SELECT MAX(r2.RevisedNo)
            FROM sqlserver_fdw.revisedquotationmain r2
            WHERE r2.QuotationNo = rqm.QuotationNo
        )
        THEN TRUE
        ELSE FALSE
    END,
    1,
    LEFT(TRIM(COALESCE(rqm.DocumentNoYearly,'')),20),
    migration.parse_sqlserver_datetime(rqm.DocumentDate),
    rqm.DocumentStatusNo,
    rqm.CompanyNo,
    rqm.YearNo,
    LEFT(TRIM(COALESCE(rqm.Remarks,'')),1000),
    1,
    COALESCE(
        migration.parse_sqlserver_datetime(rqm.CreatedDate),
        now()
    ),
    1,
    COALESCE(
        migration.parse_sqlserver_datetime(rqm.ModifiedDate),
        migration.parse_sqlserver_datetime(rqm.CreatedDate),
        now()
    ),
    CASE
        WHEN rqm.AuthorizedBy IS NULL THEN NULL
        ELSE 1
    END,
    migration.parse_sqlserver_datetime(rqm.AuthorizedDate)
FROM sqlserver_fdw.revisedquotationmain rqm
LEFT JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = rqm.RFQNo
   AND rvd.vendor_location_id = rqm.VendorLocationNo;


UPDATE purchase.quotation_main qm
SET main_quotation_id = x.main_quotation_id
FROM (
    SELECT
        RevisedQuotationNo,
        FIRST_VALUE(RevisedQuotationNo) OVER (
            PARTITION BY QuotationNo
            ORDER BY RevisedNo, RevisedQuotationNo
        ) AS main_quotation_id
    FROM sqlserver_fdw.revisedquotationmain
) x
WHERE qm.id = x.RevisedQuotationNo;

update purchase.quotation_main qm 
set qm.is_current=true
where qm.revision_no =0

UPDATE purchase.quotation_main pom
SET is_current = TRUE
FROM
(
    SELECT
        main_quotation_id ,
        MAX(revision_no ) AS max_amendment_no
    FROM purchase.quotation_main
    GROUP BY main_quotation_id 
) x
WHERE pom.main_quotation_id = x.main_quotation_id
  AND pom.revision_no = x.max_amendment_no;
