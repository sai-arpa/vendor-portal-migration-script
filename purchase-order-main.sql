CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.poamendmentmain
(
    CompanyNo INTEGER,
    YearNo INTEGER,
    POAmendmentNo INTEGER,
    POAmendmentDate TEXT,
    PONo INTEGER,
    AmendmentNo INTEGER,
    DivisionNo INTEGER,
    DocumentNoYearly VARCHAR(30),
    DocumentDate TEXT,
    DocumentStatusNo INTEGER,
    DocumentSerialNo INTEGER,
    PODocumentTypeNo INTEGER,
    IndentTypeNo INTEGER,
    POPurchaseCategoryNo INTEGER,
    PORefDocumentTypeNo INTEGER,
    RefDocumentNo INTEGER,
    VendorNo INTEGER,
    VendorLocationNo INTEGER,
    VendorContactNo INTEGER,
    ValidityDate TEXT,
    FreightTypeNo INTEGER,
    FreightRateTypeNo INTEGER,
    FreightAmount NUMERIC(19,4),
    ToLocationNo INTEGER,
    PaymentModeNo INTEGER,
    Remarks VARCHAR(1000),
    StatusNo INTEGER,
    NetAmount NUMERIC(19,4),
    CreatedBy INTEGER,
    CreatedDate TEXT,
    ModifiedBy INTEGER,
    ModifiedDate TEXT,
    AuthorizedBy INTEGER,
    AuthorizedDate TEXT,
    CurrencyConversionNo INTEGER,
    DivisibilityRate NUMERIC(9,6),
    MultiplicativeRate NUMERIC(9,6),
    DeptNo INTEGER,
    FromLocationNo INTEGER,
    AmendmentReason VARCHAR(300),
    NoOfTrips INTEGER,
    Items TEXT,
    BasicAmount NUMERIC(19,4),
    VehicleTypeNo INTEGER,
    PaymentDueBasisNo INTEGER,
    DueDays INTEGER,
    CompanyShippingLocation INTEGER,
    PartyRefNo VARCHAR(300),
    PartyRefDate TEXT,
    AuthGrpRevisionNo INTEGER,
    IsReadyForAuthorization INTEGER,
    IsPublishInPortal BIT,
    IsPOAgainstCS BIT,
    IsManuallyClosing BIT,
    PriorityNo INTEGER,
    InsertedDateInERP TEXT,
    InsertedByInERP INTEGER
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'POAmendmentMain'
);

--drop FOREIGN TABLE sqlserver_fdw.poamendmentmain

INSERT INTO purchase.purchase_order_main
(
    id,
    main_po_id,
    display_doc_no_yearly,
    amendment_no,
    amendment_date,
    amendment_reason,
    is_current_amendment,
    erp_serial_no_id,
    vendor_location_id,
    contact_person_id,
    expenditure_type_id,
    ref_doc_type_id,
    quotation_id,
    validity_date,
    party_ref_no,
    party_ref_date,
    department_id,
    is_manually_closing,
    currency_id,
    exchange_rate,
    vehicle_type_id,
    payment_mode_id,
    due_basis_id,
    due_days,
    freight_type_id,
    freight_rate_type_id,
    freight_amount,
    priority_id,
    from_location_id,
    to_location_id,
    consignee_location_id,
    is_route_applicable,
    tnc_group_id,
    payment_terms_group_id,
    approval_setup_id,
    status_id,
    is_published,
    is_po_against_cs,
    net_amount,
    basic_amount,
    tax_amount,
    items,
    no_of_trips,
    doc_no_yearly,
    doc_date,
    doc_type_id,
    division_id,
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
    authorized_date,
    publication_modified_by_id,
    publication_modified_date,
    ack_date,
    is_inserted_into_erp,
    purchase_category_id,
    purchase_document_level_id,
    inserted_date_in_erp,
    inserted_in_erp_by_user_id
)
OVERRIDING SYSTEM VALUE
select
    po.POAmendmentNo,
    NULL,
    LEFT(TRIM(COALESCE(po.DocumentNoYearly,'')),30),
    COALESCE(po.AmendmentNo,0),
    migration.parse_sqlserver_datetime(po.POAmendmentDate)::date,
    LEFT(TRIM(COALESCE(po.AmendmentReason,'')),300),
	FALSE,
    po.documentSerialNo,
    po.VendorLocationNo,
    po.VendorContactNo,
    po.indentTypeNo,
    CASE po.PORefDocumentTypeNo
        WHEN 1 THEN 4
        WHEN 3 THEN 3
        WHEN 7 THEN 2
    END,
    CASE
        WHEN po.PORefDocumentTypeNo = 1
        THEN po.RefDocumentNo
        ELSE NULL
    END,
    migration.parse_sqlserver_datetime(po.ValidityDate)::date,
    LEFT(TRIM(COALESCE(po.PartyRefNo,'')),50),
    migration.parse_sqlserver_datetime(po.PartyRefDate)::date,
    po.DeptNo,
    CASE WHEN po.IsManuallyClosing = B'1' THEN TRUE ELSE FALSE end,
    1,
    1,
    po.VehicleTypeNo,
    po.PaymentModeNo,
    CASE po.PaymentDueBasisNo
        WHEN 1 THEN 2
        WHEN 2 THEN 1
    END,
    po.DueDays,
    CASE
        WHEN po.FreightTypeNo = 1 THEN 2
        ELSE 1
    END,
    po.FreightRateTypeNo,
    po.FreightAmount,
    po.PriorityNo,
    COALESCE(po.FromLocationNo, (select id from masterdata.location_master limit 1)),
    coalesce(po.ToLocationNo, (select id from masterdata.location_master limit 1)),
    po.CompanyShippingLocation,
    FALSE,
    NULL,
    NULL,
    po.AuthGrpRevisionNo,
    sm.new_status_id,
    CASE WHEN po.IsPublishInPortal = B'1' THEN TRUE ELSE FALSE end,
    CASE WHEN po.IsPOAgainstCS = B'1' THEN TRUE ELSE FALSE end,
    COALESCE(po.NetAmount,0),
    COALESCE(po.BasicAmount,0),
    COALESCE(po.NetAmount,0)
      - COALESCE(po.BasicAmount,0),
    COALESCE(po.Items,''),
    po.NoOfTrips,
    LEFT(TRIM(COALESCE(po.DocumentNoYearly,'')),30),
    migration.parse_sqlserver_datetime(po.DocumentDate)::date,
    3,
    po.DivisionNo,
    NULL,
    CASE
        WHEN po.isreadyforauthorization = 1 AND po.documentstatusno = 10 THEN 20
        ELSE po.documentstatusno
    END,
    po.CompanyNo,
    po.YearNo,
    LEFT(TRIM(COALESCE(po.Remarks,'')),1000),
    case when po.createdBy=0 then 1 else coalesce(po.createdBy,1) end,
    COALESCE(
        migration.parse_sqlserver_datetime(po.CreatedDate),
        now()
    ),
    case when po.modifiedBy=0 then null else po.modifiedBy end,
    COALESCE(
        migration.parse_sqlserver_datetime(po.ModifiedDate),
        migration.parse_sqlserver_datetime(po.CreatedDate),
        now()
    ),
    case when po.authorizedBy=0 then 1 else po.authorizedBy end,
    migration.parse_sqlserver_datetime(po.AuthorizedDate),
    NULL,
    NULL,
    null,
	CASE
    	WHEN po.InsertedDateInERP IS NOT NULL
         OR po.InsertedByInERP IS NOT NULL
	    THEN TRUE
    	ELSE FALSE
	END,
	case when po.POPurchaseCategoryNo=1 then 2 else 1 end,
	2,
	migration.parse_sqlserver_datetime(po.InsertedDateInERP),
	po.InsertedByInERP
FROM sqlserver_fdw.poamendmentmain po
LEFT JOIN migration.status_mapping sm
      ON sm.old_status_id = po.StatusNo;


-- Update main po id
UPDATE purchase.purchase_order_main pom
SET main_po_id = x.main_po_id
FROM
(
    SELECT
        p1.POAmendmentNo,
        qf.POAmendmentNo AS main_po_id
    FROM sqlserver_fdw.poamendmentmain p1
    INNER JOIN
    (
        SELECT
            POAmendmentNo,
            PONo,
            ROW_NUMBER() OVER
            (
                PARTITION BY PONo
                ORDER BY AmendmentNo,
                         POAmendmentNo
            ) rn
        FROM sqlserver_fdw.poamendmentmain
    ) qf
        ON qf.PONo = p1.PONo
       AND qf.rn = 1
) x
WHERE pom.id = x.POAmendmentNo;

-- Update IsCurrent
UPDATE purchase.purchase_order_main pom
SET is_current_amendment = TRUE
FROM
(
    SELECT
        main_po_id,
        MAX(amendment_no) AS max_amendment_no
    FROM purchase.purchase_order_main
    GROUP BY main_po_id
) x
WHERE pom.main_po_id = x.main_po_id
  AND pom.amendment_no = x.max_amendment_no;



------- VERIFICATION ------------


--- Check is Current
WITH q AS (
    SELECT
        id,
        main_po_id,
        amendment_no ,
        is_current_amendment ,
        MAX(amendment_no ) OVER (
            PARTITION BY main_po_id
        ) AS max_revision_no
    FROM purchase.purchase_order_main
)
SELECT *
FROM q
WHERE is_current_amendment  <> (amendment_no  = max_revision_no)
ORDER BY main_po_id, amendment_no ;


--- check revisioNo duplicate in same main_quotation_id
SELECT
    main_po_id,
    amendment_no,
    COUNT(*) AS duplicate_count,
    ARRAY_AGG(id ORDER BY id) AS ids
FROM purchase.purchase_order_main
GROUP BY
    main_po_id,
    amendment_no 
HAVING COUNT(*) > 1
ORDER BY
    main_po_id,
    amendment_no;
