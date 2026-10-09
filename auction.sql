---- Auction Main -------

--- to do
--- update generated rfq fk's

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.auctionmain
(
    AuctionNo INTEGER,
    DocumentNoYearly VARCHAR(30),
    DocumentDate TEXT,
    DocumentStatusNo INTEGER,
    CreatedBy INTEGER,
    CreatedDate TEXT,
    ModifiedBy INTEGER,
    ModifiedDate TEXT,
    AuthorizedBy INTEGER,
    AuthorizedDate TEXT,
    StatusNo INTEGER,
    AuctionTypeNo INTEGER,
    SourceDocument INTEGER,
    RefDocumentNo INTEGER,
    AuctionStartDate TEXT,
    AuctionEndDate TEXT,
    BiddingGap INTEGER,
    MinBidDiffTypeNo INTEGER,
    MinBidDifference NUMERIC(12,2),
    AuctionName VARCHAR(1000),
    MaxBidPerVendor INTEGER,
    ShowL1ToVendor BIT,
    BasePriceSettingNo INTEGER,
    BaseAmount NUMERIC(19,4)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'AuctionMain'
);

INSERT INTO purchase.auction_main
(
    id,
    division_id,
    ref_doc_type_id,
    rfq_id,
    generated_rfq_id,   ---to update
    status_id,
    auction_type_id,
    auction_name,
    start_at,
    end_at,
    bidding_gap_sec,
    max_bids_per_vendor,
    min_bid_difference_type_id,
    min_bid_difference_value,
    is_show_l1_to_vendor,
    base_price_setting_id,
    base_amount,
    mail_subject,
    contact_name,
    contact_no,
    contact_no_country_id,
    contact_email,
    tnc_group_id,
    approval_setup_id,
    doc_no_yearly,
    doc_date,
    doc_type_id,
    doc_series_id,
    doc_sequence_no,
    document_status_id,
    company_id,
    fy_id,
    remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    authorized_by_id,
    authorized_date,
    extension_duration,
    extension_window,
    maximum_extension
)
OVERRIDING SYSTEM VALUE
SELECT
    am.AuctionNo,
    NULL,
    11,   --- refDocType Against RFQ (no direct case exist in real)
    am.RefDocumentNo,
    NULL,
    sm.new_status_id,
    am.auctionTypeNo,
    LEFT(TRIM(COALESCE(am.AuctionName, '')), 300),
    migration.parse_sqlserver_datetime(am.AuctionStartDate),
    migration.parse_sqlserver_datetime(am.AuctionEndDate),
    am.BiddingGap,
    am.MaxBidPerVendor,
    COALESCE(am.MinBidDiffTypeNo, 1),
    COALESCE(am.MinBidDifference, 0),
    CASE
        WHEN am.ShowL1ToVendor = B'1' THEN TRUE
        ELSE FALSE
    END,
    case when am.BasePriceSettingNo=0 then 2 else COALESCE(am.BasePriceSettingNo, 1) end,
    am.BaseAmount,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    LEFT(TRIM(COALESCE(am.DocumentNoYearly, '')), 30),
    migration.parse_sqlserver_datetime(am.DocumentDate)::date,
    7,
    NULL,
    NULL,
    am.documentStatusNo,
    2,
    (select id from masterdata.fin_year where migration.parse_sqlserver_datetime(am.DocumentDate)::date between start_date and end_date limit 1),
    NULL,
    CASE
        WHEN am.CreatedBy = 0 THEN 1
        ELSE COALESCE(am.CreatedBy, 1)
    END,
    COALESCE(
        migration.parse_sqlserver_datetime(am.CreatedDate),
        now()
    ),
    CASE
        WHEN am.ModifiedBy = 0 THEN NULL
        ELSE am.ModifiedBy
    END,
    COALESCE(
	    migration.parse_sqlserver_datetime(am.modifiedDate),
        migration.parse_sqlserver_datetime(am.CreatedDate),
        now()
    ),
    CASE
        WHEN am.AuthorizedBy = 0 THEN 1
        ELSE am.AuthorizedBy
    END,
    migration.parse_sqlserver_datetime(am.AuthorizedDate),
    NULL,
    NULL,
    NULL
FROM sqlserver_fdw.auctionmain am
LEFT JOIN migration.status_mapping sm
    ON sm.old_status_id = am.StatusNo;


----- Auction Item Detail -------
    
    
CREATE FOREIGN TABLE if not exists sqlserver_fdw.auctionitemdetail
(
    AuctionItemDetailNo integer,
    AuctionNo            integer,
    ItemNo               integer,
    MakeNo               smallint,
    TechSpecification    varchar(1000),
    Qty                  numeric(10,3),
    AuctionUnitNo        smallint,
    ItemBasePrice        numeric(19,4)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'AuctionItemDetail'
);


INSERT INTO purchase.auction_item_detail 
(
    id,
    auction_id,
    line_no,
    rfq_item_detail_id,
    item_id,
    make_id,
    hsn_code,
    tech_specification,
    unit_id,
    qty,
    item_base_price,
    remarks,
    status_id,
    generated_rfq_item_detail_id
)
OVERRIDING SYSTEM VALUE
SELECT
    aid.AuctionItemDetailNo AS id,    
    aid.auctionNo,    
    ROW_NUMBER() OVER (
        PARTITION BY aid.AuctionNo
        ORDER BY aid.AuctionItemDetailNo
    )::smallint AS line_no,  -- Derived line number
    NULL AS rfq_item_detail_id,
    aid.itemNo,
    aid.makeNo, 
    NULL AS hsn_code,
    aid.TechSpecification,
    aid.auctionunitNo,
    aid.Qty,
    aid.ItemBasePrice,
    NULL AS remarks,
    NULL AS status_id,
    NULL AS generated_rfq_item_detail_id
FROM sqlserver_fdw.auctionitemdetail aid;

--- Update rfq_item_detail_id in auction item detail
UPDATE purchase.auction_item_detail aid
SET rfq_item_detail_id = rid.id
FROM purchase.auction_main am
INNER JOIN purchase.pur_rfq_item_detail rid
    ON rid.rfq_id = am.rfq_id
WHERE aid.auction_id = am.id
  AND aid.item_id = rid.item_id
  AND COALESCE(aid.make_id, 0) = COALESCE(rid.make_id, 0);


--- Auction Vendor Detail ---

CREATE FOREIGN table if not exists sqlserver_fdw.auctionvendordetail
(
    AuctionvendorDetailNo integer,
    AuctionNo             integer,
    VendorNo              integer,
    VendorLocationNo      integer,
    VendorContactNo       integer,
    RevisedQuotationNo    integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'AuctionVendorDetail'
);

INSERT INTO purchase.auction_vendor_detail
(
	id,
    auction_id,
    public_id,
    is_guest_vendor,
    user_id,
    vendor_location_id,
    rfq_vendor_detail_id,
    quotation_id,
    generated_rfq_vendor_detail_id,
    guest_vendor_email,
    guest_vendor_name,
    last_mail_sent_on,
    created_by_id,
    created_date
)
OVERRIDING SYSTEM VALUE
select
	avd.AuctionvendorDetailNo AS id,
    avd.AuctionNo AS auction_id,
    gen_random_uuid() AS public_id,
    false AS is_guest_vendor,
    NULL AS user_id,
    avd.VendorLocationNo AS vendor_location_id,
    NULL AS rfq_vendor_detail_id,
    avd.RevisedQuotationNo AS quotation_id,
    NULL AS generated_rfq_vendor_detail_id,
    NULL AS guest_vendor_email,
    NULL AS guest_vendor_name,
    NULL AS last_mail_sent_on,
    NULL AS created_by_id,
    NULL AS created_date
FROM sqlserver_fdw.auctionvendordetail avd;


--- Update rfq_vendor_detail_id in auction vendor detail
UPDATE purchase.auction_vendor_detail avd
SET rfq_vendor_detail_id = rvd.id
FROM purchase.auction_main am
INNER JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = am.rfq_id
WHERE avd.auction_id = am.id
  AND avd.vendor_location_id = rvd.vendor_location_id;


---- Auction Vendor Contact Person Detail
INSERT INTO purchase.auction_vendor_contact_person_detail
(
    auction_id,
    auction_vendor_detail_id,
    vendor_location_contact_person_id
)
SELECT
    avd.AuctionNo,
    avd.AuctionvendorDetailNo,
    avd.VendorContactNo
FROM sqlserver_fdw.auctionvendordetail avd
WHERE avd.VendorContactNo IS NOT NULL;


--- Auction Comapany Detail

CREATE FOREIGN table if not exists sqlserver_fdw.auctioncompanydetail
(
    AuctionNo  integer,
    CompanyNo  smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'AuctionCompanyDetail'
);

INSERT INTO purchase.auction_company_detail
(
    auction_id,
    company_id
)
SELECT
    acd.AuctionNo AS auction_id,
    acd.CompanyNo AS company_id
FROM sqlserver_fdw.auctioncompanydetail acd;



-------------------------------------------------------------------------------------------------------------------------------------------------------------
------ RFQ Generation


--- RFQ Main
CREATE TEMP table if not exists tmp_auction_rfq_mapping
(
    auction_id integer PRIMARY KEY,
    generated_rfq_id integer NOT NULL
);


WITH inserted_rfq AS
(
    INSERT INTO purchase.pur_rfq_main
    (
        division_id,
        ref_doc_type_id,
        due_date,
        is_price_list,
        mail_subject,
        contact_name,
        contact_no,
        contact_no_country_id,
        contact_email,
        tnc_group_id,
        approval_setup_id,
        status_id,
        doc_no_yearly,
        doc_date,
        doc_type_id,
        doc_series_id,
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
    SELECT
        am.division_id,
        9 AS ref_doc_type_id,      ---- auction refDocType for RFQ
        am.end_at AS due_date,
        false AS is_price_list,
        am.mail_subject,
        am.contact_name,
        am.contact_no,
        am.contact_no_country_id,
        am.contact_email,
        am.tnc_group_id,
        am.approval_setup_id,
        9 AS status_id,      ---- Authorize
        am.doc_no_yearly,
        am.doc_date,
        8 AS doc_type_id,      ---- RFQ Default Doc Type for Auction
        am.doc_series_id,
        30 AS document_status_id,  -- Authorize
        am.company_id,
        am.fy_id,
        am.remarks,
        am.created_by_id,
        am.created_date,
        am.modified_by_id,
        am.modified_date,
        am.authorized_by_id,
        am.authorized_date
    FROM purchase.auction_main am
    WHERE am.generated_rfq_id IS NULL
    RETURNING id, doc_no_yearly
)
INSERT INTO tmp_auction_rfq_mapping
(
    auction_id,
    generated_rfq_id
)
SELECT
    am.id,
    ir.id
FROM inserted_rfq ir
INNER JOIN purchase.auction_main am
    ON am.doc_no_yearly = ir.doc_no_yearly;

--- verify
SELECT
    (SELECT COUNT(*)
     FROM purchase.auction_main
     WHERE generated_rfq_id IS NULL) AS auctions_without_generated_rfq,
     
    (SELECT COUNT(*)
     FROM tmp_auction_rfq_mapping) AS newly_generated_rfqs;


--------- RFQ Item Detail
    
INSERT INTO purchase.pur_rfq_item_detail
(
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
SELECT
    m.generated_rfq_id,
    aid.line_no,
    aid.item_id,
    aid.make_id,
    aid.hsn_code,
    aid.tech_specification,
    aid.unit_id,
    aid.qty,
    NULL AS cs_booking_qty,
    NULL AS balance_qty,
    aid.remarks,
    aid.status_id
FROM purchase.auction_item_detail aid
INNER JOIN tmp_auction_rfq_mapping m
    ON m.auction_id = aid.auction_id;

--- verify rfq items count and auction items count
SELECT
    m.auction_id,
    m.generated_rfq_id,
    COUNT(aid.id) AS auction_item_count,
    COUNT(rid.id) AS rfq_item_count
FROM tmp_auction_rfq_mapping m
LEFT JOIN purchase.auction_item_detail aid
    ON aid.auction_id = m.auction_id
LEFT JOIN purchase.pur_rfq_item_detail rid
    ON rid.rfq_id = m.generated_rfq_id
GROUP BY
    m.auction_id,
    m.generated_rfq_id
HAVING COUNT(aid.id) <> COUNT(rid.id)
ORDER BY m.auction_id;


----------- Auction Vendor Detail
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
    m.generated_rfq_id,
    avd.public_id,
    avd.is_guest_vendor,
    avd.user_id,
    avd.vendor_location_id,
    avd.guest_vendor_email,
    avd.guest_vendor_name,
    NULL AS quotation_status_id,
    avd.created_by_id,
    avd.created_date,
    avd.last_mail_sent_on
FROM purchase.auction_vendor_detail avd
INNER JOIN tmp_auction_rfq_mapping m
    ON m.auction_id = avd.auction_id;



--- verify rfq vendor count and auction vendor count
SELECT
    m.auction_id,
    m.generated_rfq_id,
    COUNT(DISTINCT avd.id) AS auction_vendor_count,
    COUNT(DISTINCT rvd.id) AS rfq_vendor_count
FROM tmp_auction_rfq_mapping m
LEFT JOIN purchase.auction_vendor_detail avd
    ON avd.auction_id = m.auction_id
LEFT JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = m.generated_rfq_id
GROUP BY
    m.auction_id,
    m.generated_rfq_id
HAVING COUNT(DISTINCT avd.id) <> COUNT(DISTINCT rvd.id)
ORDER BY m.auction_id;


-------- RFQ Vendor Contact Person Detail
INSERT INTO purchase.pur_rfq_vendor_contact_person_detail
(
    rfq_id,
    rfq_vendor_detail_id,
    vendor_location_contact_person_id,
    contact_name,
    contact_email,
    contact_no,
    contact_no_country_id
)
SELECT
    m.generated_rfq_id,
    rvd.id,
    avcp.vendor_location_contact_person_id,
    NULL AS contact_name,
    NULL AS contact_email,
    NULL AS contact_no,
    NULL AS contact_no_country_id
FROM purchase.auction_vendor_contact_person_detail avcp
INNER JOIN purchase.auction_vendor_detail avd
    ON avd.id = avcp.auction_vendor_detail_id
INNER JOIN tmp_auction_rfq_mapping m
    ON m.auction_id = avd.auction_id
INNER JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = m.generated_rfq_id
    AND rvd.vendor_location_id = avd.vendor_location_id;


-------- RFQ Company Detail
INSERT INTO purchase.pur_rfq_company_detail
(
    rfq_id,
    company_id
)
SELECT
    m.generated_rfq_id,
    acd.company_id
FROM purchase.auction_company_detail acd
INNER JOIN tmp_auction_rfq_mapping m
    ON m.auction_id = acd.auction_id;


-----------------------------------------------------------------------------------------
---- Update Auction Tables with generated RFQ ids

UPDATE purchase.auction_main am
SET generated_rfq_id = m.generated_rfq_id
FROM tmp_auction_rfq_mapping m
WHERE am.id = m.auction_id
  AND am.generated_rfq_id IS NULL;


UPDATE purchase.auction_item_detail aid
SET generated_rfq_item_detail_id = rid.id
FROM tmp_auction_rfq_mapping m
INNER JOIN purchase.pur_rfq_item_detail rid
    ON rid.rfq_id = m.generated_rfq_id
INNER JOIN purchase.auction_item_detail source_aid
    ON source_aid.auction_id = m.auction_id
   AND source_aid.line_no = rid.line_no
WHERE aid.id = source_aid.id
  AND aid.generated_rfq_item_detail_id IS NULL;


UPDATE purchase.auction_vendor_detail avd
SET generated_rfq_vendor_detail_id = rvd.id
FROM tmp_auction_rfq_mapping m
INNER JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = m.generated_rfq_id
INNER JOIN purchase.auction_vendor_detail source_avd
    ON source_avd.auction_id = m.auction_id
   AND source_avd.vendor_location_id = rvd.vendor_location_id
WHERE avd.id = source_avd.id
  AND avd.generated_rfq_vendor_detail_id IS NULL;


--------------------------------------------------------------------------------------------------
----Update rfqId and rfqVendorDetailId in quotation main


UPDATE purchase.quotation_main qm
SET
    rfq_id = am.generated_rfq_id,
    rfq_vendor_detail_id = avd.generated_rfq_vendor_detail_id
FROM sqlserver_fdw.revisedquotationmain r
INNER JOIN purchase.auction_main am
    ON am.id = r.auctionno
INNER JOIN purchase.auction_vendor_detail avd
    ON avd.auction_id = am.id
   AND avd.vendor_location_id = r.vendorlocationno
WHERE r.revisedquotationno = qm.id
  AND qm.is_auction = true
  AND am.generated_rfq_id IS NOT NULL;

--verify
--select count(*) from purchase.quotation_main qm 
--where qm.rfq_id is null or qm.rfq_vendor_detail_id is null
--and qm.is_auction is true

--------- Update rfqId in cs main

UPDATE purchase.cs_main cm
SET rfq_id = am.generated_rfq_id
FROM sqlserver_fdw.csMain cs
INNER JOIN purchase.auction_main am
    ON am.id = cs.auctionno
WHERE cs.csno = cm.id
  AND cm.ref_doc_type_no = 13
  AND am.generated_rfq_id IS NOT NULL;


--- Update rfq_id for cs which is against cs which is agaist auction

--First check how many cs getting updated and with what
--SELECT
--    cm.id AS cs_id,
--    cs.refcsno,
--    cs.auctionno,
--    cm.ref_doc_type_no,
--    cm.rfq_id AS current_rfq_id,
--    source_cm.id AS source_cs_id,
--    source_cm.rfq_id AS source_rfq_id
--FROM purchase.cs_main cm
--INNER JOIN sqlserver_fdw.csMain cs
--    ON cs.csno = cm.id
--INNER JOIN purchase.cs_main source_cm
--    ON source_cm.id = cs.refcsno
--WHERE cs.refcsno IS NOT NULL
--  AND cs.auctionno IS NOT NULL
--  AND cm.ref_doc_type_no = 8
--ORDER BY cm.id;



-- Update query
UPDATE purchase.cs_main cm
SET rfq_id = source_cm.rfq_id
FROM sqlserver_fdw.csMain cs
INNER JOIN purchase.cs_main source_cm
    ON source_cm.id = cs.refcsno
WHERE cs.csno = cm.id
  AND cs.refcsno IS NOT NULL
  AND cs.auctionno IS NOT NULL
  AND cm.ref_doc_type_no = 8
  AND source_cm.rfq_id IS NOT NULL;

--------------------------------------------------------------------
