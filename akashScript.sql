---------------------------------------------------------------------------------------------------------------
----------------------  MIGRATION SCRIPTS----------------------------------------------------------------------



-----Unit Master----

CREATE FOREIGN TABLE sqlserver_fdw.munitmaster
(
    UnitNo smallint,
    Code varchar(6),
    UnitName varchar(25),
    Alias varchar(6),
    UnitCategoryNo smallint,
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text,
    DocumentStatusNo smallint,
    AuthorizedBy smallint,
    AuthorizedDate text,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mUnitMaster'
);




INSERT INTO masterdata.unit_master
(
    id,
    code,
    unit_name,
    alias,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    UnitNo,
    TRIM(Code),
    TRIM(UnitName),
    TRIM(Alias),
    CASE
        WHEN COALESCE(Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    NULL,
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    )
FROM sqlserver_fdw.munitmaster;


----------------Make Master-------------------------

CREATE FOREIGN TABLE sqlserver_fdw.mmakemaster
(
    MakeNo smallint,
    Code varchar(6),
    MakeName varchar(100),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text,
    DocumentStatusNo smallint,
    AuthorizedBy smallint,
    AuthorizedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mMakeMaster'
);


INSERT INTO masterdata.make_master
(
    id,
    code,
    make_name,
    alias,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    MakeNo,
    TRIM(Code),
    LEFT(TRIM(MakeName), 50),
    LEFT(TRIM(MakeName), 10),
    1,
    NULL,
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    )
FROM sqlserver_fdw.mmakemaster;



------------------------- Item Category Master----------------
CREATE FOREIGN TABLE sqlserver_fdw.mcategorymaster
(
    CategoryNo smallint,
    Code varchar(2),
    CategoryName varchar(50),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mCategoryMaster'
);

INSERT INTO masterdata.category_master
(
    id,
    category_name,
    code,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    CategoryNo,
    TRIM(CategoryName),
    TRIM(Code),
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    NULL
FROM sqlserver_fdw.mcategorymaster;


---------------------------- Item  Group Master ----------------------------

CREATE FOREIGN TABLE sqlserver_fdw.mgroupmaster
(
    GroupNo smallint,
    Code varchar(2),
    GroupName varchar(100),
    CategoryNo smallint,
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mGroupMaster'
);


INSERT INTO masterdata.group_master
(
    id,
    code,
    group_code,
    group_name,
    category_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    gm.GroupNo,
    TRIM(gm.Code),
    TRIM(cm.code) || TRIM(gm.Code),
    TRIM(gm.GroupName),
    gm.CategoryNo,
    COALESCE(gm.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(gm.CreatedDate),
        now()
    ),
    COALESCE(gm.ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(gm.ModifiedDate),
        migration.parse_sqlserver_datetime(gm.CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(gm.Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    NULL
FROM sqlserver_fdw.mgroupmaster gm
INNER JOIN masterdata.category_master cm
    ON cm.id = gm.CategoryNo;



---------------- Item Subgroup Master-------------------

CREATE FOREIGN TABLE sqlserver_fdw.msubgroupmaster
(
    SubGroupNo smallint,
    Code varchar(2),
    SubGroupName varchar(100),
    GroupNo smallint,
    GSTCategoryNo smallint,
    HSNSACCode varchar(8),
    UnitNo smallint,
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mSubGroupMaster'
);

---Insertion----

WITH subgroup_unit_usage AS
(
    SELECT
        im.SubGroupNo,
        im.UnitNo,
        COUNT(*) AS unit_count,
        ROW_NUMBER() OVER
        (
            PARTITION BY im.SubGroupNo
            ORDER BY COUNT(*) DESC, im.UnitNo
        ) AS rn
    FROM sqlserver_fdw.mitemmaster im
    WHERE im.UnitNo IS NOT NULL
    GROUP BY
        im.SubGroupNo,
        im.UnitNo
)
INSERT INTO masterdata.subgroup_master
(
    id,
    code,
    subgroup_code,
    subgroup_name,
    group_id,
    gst_category_id,
    hsn_sac_code,
    stock_unit_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    sg.SubGroupNo,
    TRIM(sg.Code),
    TRIM(gm.group_code) || TRIM(sg.Code),
    TRIM(sg.SubGroupName),
    sg.GroupNo,
    sg.GSTCategoryNo,
    TRIM(sg.HSNSACCode),
    COALESCE(
    suu.UnitNo,
    (
        SELECT um.id
        FROM masterdata.unit_master um
        WHERE UPPER(TRIM(um.alias)) IN ('NO', 'NOS')
        ORDER BY um.id
        LIMIT 1
    )
   ),
    COALESCE(sg.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(sg.CreatedDate),
        now()
    ),
    COALESCE(sg.ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(sg.ModifiedDate),
        migration.parse_sqlserver_datetime(sg.CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(sg.Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    NULL
FROM sqlserver_fdw.msubgroupmaster sg
INNER JOIN masterdata.group_master gm
    ON gm.id = sg.GroupNo
LEFT JOIN subgroup_unit_usage suu
    ON suu.SubGroupNo = sg.SubGroupNo
   AND suu.rn = 1;

-----------------  Item Master -------------------------------------

CREATE FOREIGN TABLE sqlserver_fdw.mitemmaster
(
    ItemNo int,
    Code varchar(4),
    ItemName varchar(200),
    SubGroupNo smallint,
    UnitNo smallint,
    GSTCategoryNo smallint,
    HSNSACCode varchar(8),
    Remarks varchar(4000),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mItemMaster'
);


INSERT INTO masterdata.item_master
(
    id,
    code,
    item_name,
    subgroup_id,
    stock_unit_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    gst_category_id,
    hsn_sac_code,
    remarks,
    item_code,
	is_multiunit_applicable,
	make_mgmt_type_id
)
OVERRIDING SYSTEM VALUE
SELECT
    im.ItemNo,
    TRIM(im.Code),
    TRIM(im.ItemName),
    im.SubGroupNo,
    im.UnitNo,
    COALESCE(im.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(im.CreatedDate),
        now()
    ),
    COALESCE(im.ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(im.ModifiedDate),
        migration.parse_sqlserver_datetime(im.CreatedDate),
        now()
    ),
    1,
    NULL,
    im.GSTCategoryNo,
    TRIM(im.HSNSACCode),
    LEFT(TRIM(im.Remarks), 300),
    TRIM(sm.subgroup_code) || TRIM(im.Code),
	false,
	1
FROM sqlserver_fdw.mitemmaster im
INNER JOIN masterdata.subgroup_master sm
ON sm.id = im.subGroupNo;



------ Insert Unit Conversion for all Item -----

INSERT INTO masterdata.item_master_unit_conversion_detail
(
    item_id,
    unit_type_id,
    unit_conversion_type_id,
    from_unit_id,
    from_unit_value,
    to_unit_id,
    to_unit_value
)
SELECT
    im.id AS item_id,
    1 AS unit_type_id,              -- (1) For Stock
    1 AS unit_conversion_type_id,   -- (1) For Fixed
    im.stock_unit_id AS from_unit_id,
    1.000 AS from_unit_value,
    im.stock_unit_id AS to_unit_id,
    1.000 AS to_unit_value
FROM masterdata.item_master im
WHERE NOT EXISTS
(
    SELECT 1
    FROM masterdata.item_master_unit_conversion_detail uc
    WHERE uc.item_id = im.id
);


---------------------Location Master ----------------------------------

CREATE FOREIGN TABLE sqlserver_fdw.mlocationmaster
(
    LocationNo smallint,
    Code varchar(6),
    LocationName varchar(50),
    CityNo integer,
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mLocationMaster'
);


INSERT INTO masterdata.location_master
(
    id,
    code,
    alias,
    location_name,
    city_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    LocationNo,
    TRIM(Code),
    TRIM(Code),
    LocationName,
    CityNo,
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    1,
    NULL
FROM sqlserver_fdw.mlocationmaster
on conflict(location_name) do nothing;


----------------- Financial Year ------------------------

CREATE FOREIGN TABLE sqlserver_fdw.mfyear
(
    YearNo smallint,
    YearName varchar(5),
    StartDate text,
    EndDate text,
    PreviousYearNo smallint,
    NextYearNo smallint,
    StatusNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mFYear'
);


INSERT INTO masterdata.fin_year
(
    id,
    name,
    alias,
    start_date,
    end_date,
    pre_fin_year_id,
    next_fin_year_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    code,
    short_alias
)
OVERRIDING SYSTEM VALUE
SELECT
    YearNo,
    TRIM(YearName),
    TRIM(YearName),
    migration.parse_sqlserver_datetime(StartDate)::date,
    migration.parse_sqlserver_datetime(EndDate)::date,
    PreviousYearNo,
    NextYearNo,
    1,
    now(),
    1,
    now(),
    COALESCE(StatusNo, 1),
    NULL,
    TRIM(YearName),
    TRIM(YearName)
FROM sqlserver_fdw.mfyear;



---------------------------- Division Master Company Detail ------------------

CREATE FOREIGN TABLE sqlserver_fdw.mdivisionmastercompanydetail
(
    DivisionNo integer,
    CompanyNo smallint,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDivisionMasterCompanyDetail'
);

INSERT INTO masterdata.division_company_detail
(
    division_id,
    company_id,
    status_id
)
SELECT
    DivisionNo,
    CompanyNo,
    CASE
        WHEN COALESCE(Inactive, FALSE)
        THEN 2
        ELSE 1
    END
FROM sqlserver_fdw.mdivisionmastercompanydetail;


------------------------------ FORM Master Foreign Table ------------------------

CREATE FOREIGN TABLE sqlserver_fdw.formMaster
(
    FormNo                              integer,
    FormName                            varchar(255),
    FormCode                            varchar(100),
    FormMainTableinDB                   varchar(255),
    IsMaster                            boolean,
    IsReport                            boolean,
    FormCaption                         varchar(255),
    ParentMenu                          integer,
    SubRoutineCalled                    varchar(255),
    ModuleNo                            integer,
    SmallIcon                           varchar(255),
    largeIcon                           varchar(255),
    CreatedBy                           integer,
    CreatedDate                         varchar(50),
    ModifiedBy                          integer,
    ModifiedDate                        varchar(50),
    IsVisible                           boolean,
    IsHeadOfficeVisible                 boolean,
    IsTaxApplicable                     boolean,
    IsTermsNConditionApplicable         boolean,
    IsCustomFieldApplicable             boolean,
    SequenceNo                          integer,
    IsCashPaymentApplicable             boolean,
    MenuName                            varchar(255),
    IsPrintOnce                         boolean,
    SearchDataProcName                  varchar(255),
    DeleteProcName                      varchar(255),
    IsMultipleDeleteAllow               boolean,
    IsAllowAutoMail                     boolean,
    IsAllowMobileAuthorization          boolean,
    IsWeb                               boolean,
    IsAuthorizationApplicable           boolean,
    IsEnableAuditLog                    boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'globaldata',
    table_name 'formMaster'
);


-------------------------------------------- Doc Serial ------------------------------
create foreign table sqlserver_fdw.documentserial
(
    DocumentSerialNo integer,
    FormCode varchar(50),
    YearNo smallint,
    Series varchar(2),
    SeriesType varchar(1),
    Description varchar(100),
    DivisionNo integer,
    Inactive boolean,
    IsDefault boolean,
    CompanyNo smallint,
    ERPUniqueValue varchar(10)
)
server sqlserver_fdw
options (
    schema_name 'Customize',
    table_name 'DocumentSerial'
);

INSERT INTO masterdata.erp_doc_serial_master
(
    id,
    form_id,
    year_id,
    series,
    series_type,
    description,
    company_id,
    division_id,
    status_id,
    status_remarks,
    is_default,
    erp_unique_id,
    display_name,
	created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    ds.DocumentSerialNo,
    fm.new_form_id,
    ds.YearNo,
    NULLIF(TRIM(ds.Series), ''),
    NULLIF(TRIM(ds.SeriesType), ''),
    TRIM(ds.Description),
    ds.CompanyNo,
    ds.DivisionNo,
    CASE
        WHEN COALESCE(ds.Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    NULL,
    COALESCE(ds.IsDefault, FALSE),
    TRIM(ds.Series),
    CONCAT_WS(
        ' - ',
        NULLIF(TRIM(ds.Description), ''),
        NULLIF(TRIM(ds.Series), '')
    ),
	    1,
    NOW(),
    1,
    NOW()
FROM sqlserver_fdw.documentserial ds
INNER JOIN sqlserver_fdw.formmaster f
    ON UPPER(TRIM(ds.FormCode)) = UPPER(TRIM(f.FormCode))
INNER JOIN migration.form_mapping fm
    ON f.FormNo = fm.old_form_id;

---------------------------------- Request For Quotation -------------------------------

CREATE FOREIGN TABLE sqlserver_fdw.rfqmain
(
    RFQNo               integer,
    CompanyNo           smallint,
    YearNo              smallint,
    DivisionNo          integer,
    DocumentSettingNo   smallint,
    DocumentNoYearly    varchar(30),
    DocumentDate        varchar(50),
    DocumentStatusNo    smallint,
    RFQAgainstNo        smallint,
    SubmissionDate      varchar(50),
    OpeningDate         varchar(50),
    ValidityDate        varchar(50),
    Remark              varchar(500),
    VendorType          smallint,
    VendorGroupNo       smallint,
    CreatedBy           smallint,
    CreatedDate         varchar(50),
    ModifiedBy          smallint,
    ModifiedDate        varchar(50),
    AuthorizedBy        smallint,
    AuthorizedDate      varchar(50),
    StatusNo            smallint,
    ReleasedBy          smallint,
    ReleasedDate        varchar(50),
    SubjectOfCS         varchar(500),
    ShowTDCOnNo         smallint,
    IsCSPrepared        boolean,
    RFQEmailSubject     text,
    ContactEmail        varchar(300),
    ContactPersonName   varchar(100),
    ContactNo           varchar(50),
    IsPL                boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RFQMain'
);



INSERT INTO purchase.pur_rfq_main
(
    id,
    ref_doc_type_id,
    doc_no_yearly,
    doc_date,
    doc_series_id,
    document_status_id,
    status_id,
    doc_type_id,
    due_date,
    is_price_list,
    mail_subject,
    contact_name,
    contact_no,
    contact_no_country_id,
    contact_email,
    remarks,
    tnc_group_id,
    approval_setup_id,
    company_id,
    division_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    authorized_by_id,
    authorized_date,
	fy_id
)
OVERRIDING SYSTEM VALUE
SELECT
    rfq.RFQNo,
    CASE rfq.RFQAgainstNo
        WHEN 1 THEN 5
        WHEN 2 THEN 6
    END,
    TRIM(rfq.DocumentNoYearly),
    COALESCE(
        migration.parse_sqlserver_datetime(rfq.DocumentDate)::date,
        CURRENT_DATE
    ),
    rfq.DocumentSettingNo,
    rfq.DocumentStatusNo,
    sm.new_status_id,
    4,
    migration.parse_sqlserver_datetime(rfq.SubmissionDate),
    COALESCE(rfq.IsPL, FALSE),
    NULLIF(LEFT(TRIM(rfq.RFQEmailSubject),500), ''),
    NULLIF(TRIM(rfq.ContactPersonName), ''),
    CASE 
        WHEN NULLIF(TRIM(rfq.ContactNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(rfq.ContactNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(rfq.ContactNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    NULLIF(TRIM(rfq.ContactEmail), ''),
    NULLIF(LEFT(TRIM(rfq.Remark), 1000), ''),
    NULL,
    NULL,
    rfq.CompanyNo,
    rfq.DivisionNo,
    COALESCE(rfq.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(rfq.CreatedDate),
        now()
    ),
    rfq.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(rfq.ModifiedDate),
        migration.parse_sqlserver_datetime(rfq.CreatedDate),
        now()
    ),
    rfq.AuthorizedBy,
    migration.parse_sqlserver_datetime(rfq.AuthorizedDate),
	rfq.yearNo
FROM sqlserver_fdw.rfqmain rfq
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = rfq.StatusNo;


----Item Detail---
--- TO DO: create a query to update the cs_qty and balance qty---

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


---- Insert RFQ Purchase Request Detail -----
-- We have to fix the PR and RFQ item not matching issue before insert----
CREATE FOREIGN TABLE sqlserver_fdw.rfqindentdetail
(
    rfqindentdetailno      INTEGER,
    rfqno                  INTEGER,
    indentno               INTEGER,
    itemno                 INTEGER,
    makeno                 SMALLINT,
    firstcf                NUMERIC(7,3),
    unitno                 SMALLINT,
    secondcf               NUMERIC(7,3),
    rfqqty                 NUMERIC(10,3),
    technicalgradeno       SMALLINT,
    csbookingqty           NUMERIC(12,3),
    rfqmakeno              SMALLINT,
    indentitemlineno       NUMERIC(10,3)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'RFQIndentDetail'
);

INSERT INTO purchase.pur_rfq_pr_detail
(
    id,
    rfq_id,
    rfq_item_detail_id,
    pr_item_detail_id,
    item_id,
    make_id,
    rfq_make_id,
    unit_id,
    rfq_unit_id,
    first_cf,
    second_cf,
    rfq_qty
)
OVERRIDING SYSTEM VALUE
SELECT
    rid.RFQIndentDetailNo,
    rid.RFQNo,
    rfqid.id,
    prid.id,
    rid.ItemNo,
    rid.MakeNo,
    rid.RFQMakeNo,
    rid.UnitNo,
    rid.UnitNo,
    COALESCE(rid.FirstCF, 0),
    COALESCE(rid.SecondCF, 0),
    COALESCE(rid.RFQQty, 0)
FROM sqlserver_fdw.rfqindentdetail rid
INNER JOIN purchase.pur_rfq_item_detail rfqid
    ON rfqid.rfq_id = rid.RFQNo
   AND rfqid.item_id = rid.ItemNo
   AND COALESCE(rfqid.make_id, 0) = COALESCE(rid.RFQMakeNo, 0)
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = rid.IndentNo
   AND prid.line_no = rid.IndentItemLineNo
on conflict (id) do nothing;


---- Terms and Condition Detail-----

CREATE FOREIGN TABLE sqlserver_fdw.rfqtermsnconditiondetail
(
    RFQTermsDetailNo         integer,
    RFQNo                    integer,
    TermsNConditionHeadNo    smallint,
    TermsNCondition          varchar(300)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RFQTermsNConditionDetail'
);

INSERT INTO purchase.pur_rfq_tnc_detail
(
    id,
    rfq_id,
    tnc_head_id,
    tnc_value
)
OVERRIDING SYSTEM VALUE
SELECT
    rtd.RFQTermsDetailNo,
    rtd.RFQNo,
    rtd.TermsNConditionHeadNo,
    LEFT(
        COALESCE(
            NULLIF(TRIM(rtd.TermsNCondition), ''),
            ''
        ),
        1000
    )
FROM sqlserver_fdw.rfqtermsnconditiondetail rtd;


----Company Detail------

CREATE FOREIGN TABLE sqlserver_fdw.rfqcompanydetail
(
    RFQNo       integer,
    CompanyNo   smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RFQCompanyDetail'
);

INSERT INTO purchase.pur_rfq_company_detail
(
    rfq_id,
    company_id
)
SELECT
    rcd.RFQNo,
    rcd.CompanyNo
FROM sqlserver_fdw.rfqcompanydetail rcd;


---- Vendor Detail Status Update----

UPDATE purchase.pur_rfq_vendor_Detail rvd
SET quotation_status_id = 8
WHERE EXISTS (
    SELECT 1
    FROM purchase.quotation_main qm
    WHERE qm.rfq_id = rvd.rfq_id
      AND qm.document_status_id = 30
);



-------------------------- Purchase Request --------------------------------------------

CREATE FOREIGN TABLE sqlserver_fdw.indentmain
(
    CompanyNo                   smallint,
    YearNo                      smallint,
    IndentNo                    integer,
    DocumentNoYearly            varchar(30),
    DocumentDate                varchar(50),
    DocumentStatusNo            smallint,
    IndentAgainstNo             smallint,
    RefDocumentNo               integer,
    IndentTypeNo                smallint,
    DeptNo                      integer,
    ReferenceNo                 varchar(30),
    ReferenceDate               varchar(50),
    RequestedBy                 varchar(100),
    WareHouseNo                 smallint,
    Remark                      varchar(1000),
    StatusNo                    smallint,
    NetAmount                   numeric(19,4),
    CreatedBy                   smallint,
    CreatedDate                 varchar(50),
    ModifiedBy                  smallint,
    ModifiedDate                varchar(50),
    AuthorizedBy                smallint,
    AuthorizedDate              varchar(50),
    ReleasedBy                  smallint,
    ReleasedDate                varchar(50),
    DivisionNo                  integer,
    RequstedByContactNo         varchar(500),
    RequstedByEmailId           varchar(500),
    IsReadyForAuthorization     boolean,
    AuthGrpRevisionNo           smallint,
    Priority                    varchar(300),
    ERPCreatedDate              varchar(50),
    ERPAuthorizedDate           varchar(50),
    DocumentSerialNo            integer,
    PortalDocumentNoYearly      varchar(30)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'IndentMain'
);

INSERT INTO inventory.purchase_request_main
(
    id,
    fy_id,
    company_id,
    division_id,
    doc_type_id,
    doc_no_yearly,
    doc_date,
    doc_series_id,
    display_doc_no_yearly,
    document_status_id,
    department_id,
    expenditure_type_id,
    ref_doc_no,
    ref_doc_date,
    requested_by,
    requested_by_contact_no,
    requested_by_contact_no_county_id,
    requested_by_email,
    net_amount,
    erp_serial_no_id,
    remarks,
    approval_setup_id,
    status_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    authorized_by_id,
    authorized_date,
    is_inserted_into_erp
)
OVERRIDING SYSTEM VALUE
SELECT
    im.IndentNo,
    im.YearNo,
    im.CompanyNo,
    im.DivisionNo,
    2,
    COALESCE(NULLIF(TRIM(im.PortalDocumentNoYearly), ''), TRIM(im.DocumentNoYearly)),
    COALESCE(
        migration.parse_sqlserver_datetime(im.DocumentDate)::date,
        CURRENT_DATE
    ),
    NULL,
    TRIM(im.DocumentNoYearly),
    im.DocumentStatusNo,
    im.DeptNo,
	 CASE im.IndentTypeNo
        WHEN 1 THEN 1
        WHEN 2 THEN 2
		WHEN 3 THEN 3
        WHEN 7 THEN 4
    END,
    NULLIF(TRIM(im.ReferenceNo), ''),
    migration.parse_sqlserver_datetime(im.ReferenceDate)::date,
    NULLIF(TRIM(im.RequestedBy), ''),
    CASE 
        WHEN NULLIF(TRIM(im.RequstedByContactNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(im.RequstedByContactNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(im.RequstedByContactNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    NULLIF(TRIM(im.RequstedByEmailId), ''),
    COALESCE(im.NetAmount, 0),
    im.DocumentSerialNo,
    NULLIF(TRIM(im.Remark), ''),
    im.AuthGrpRevisionNo,
    sm.new_status_id,
    COALESCE(im.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(im.CreatedDate),
        now()
    ),
    im.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(im.ModifiedDate),
        migration.parse_sqlserver_datetime(im.CreatedDate),
        now()
    ),
    im.AuthorizedBy,
    migration.parse_sqlserver_datetime(im.AuthorizedDate),
    TRUE
FROM sqlserver_fdw.indentmain im
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = im.StatusNo;


---- Item Detail ----
CREATE FOREIGN TABLE sqlserver_fdw.indentitemdetail
(
    IndentItemDetailNo      integer,
    IndentNo                integer,
    ItemNo                  integer,
    MakeNo                  smallint,
    UnitNo                  smallint,
    TechSpecification       varchar(1000),
    RequiredQty             numeric(12,3),
    IndentQty               numeric(12,3),
    Rate                    numeric(19,4),
    BasicAmount             numeric(19,4),
    CostCenterNo            integer,
    Remark                  varchar(500),
    IsReserved              boolean,
    StatusNo                smallint,
    POQty                   numeric(12,3),
    TechnicalGradeNo        smallint,
    ItemLineNo              smallint,
    IndentFlowNo            smallint,
    AllotedUserNo           integer,
    DueDate                 text,
    IndentItemLineNo        numeric(12,3),
    Reason                  varchar(1000),
    ExpiryReason            varchar(100),
    PriorityNo              smallint,
    ReasonNo                smallint,
    ReducedQtyReason        varchar(500),
    OldIndentQty            numeric(12,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'IndentItemDetail'
);

INSERT INTO inventory.purchase_request_item_detail
(
    id,
    pur_req_id,
    line_no,
    item_id,
    make_id,
    tech_specification,
    unit_id,
    required_qty,
    pr_qty,
    balance_qty,
    po_qty,
    direct_po_qty,
    rfq_qty,
    rfq_balance_qty,
    rfq_release_qty,
    pr_cancel_qty,
    po_release_qty,
    rate,
    amount,
    schedule_date,
    cost_center_id,
    priority_id,
    remarks,
    status_id
)
OVERRIDING SYSTEM VALUE
SELECT
    iid.IndentItemDetailNo,
    iid.IndentNo,
    iid.IndentItemLineNo,
    iid.ItemNo,
    iid.MakeNo,
    NULLIF(TRIM(iid.TechSpecification), ''),
    iid.UnitNo,
    COALESCE(iid.RequiredQty, 0),
    COALESCE(iid.IndentQty, 0),
    COALESCE(iid.IndentQty, 0),
    COALESCE(iid.POQty, 0),
    0,
    0,
    COALESCE(iid.IndentQty, 0),
    0,
    0,
    0,
    COALESCE(iid.Rate, 0),
    COALESCE(iid.BasicAmount, 0),
	COALESCE(
    migration.parse_sqlserver_datetime(iid.DueDate),
    prm.doc_date + INTERVAL '10 days'
    ),
    iid.CostCenterNo,
    COALESCE(
    iid.PriorityNo,
    (
        SELECT pm.id
        FROM masterdata.priority_master pm
        ORDER BY pm.id
        LIMIT 1
    )
    ),
    NULLIF(LEFT(TRIM(iid.Remark), 500), ''),
    sm.new_status_id
FROM sqlserver_fdw.indentitemdetail iid
INNER JOIN inventory.purchase_request_main prm
    ON prm.id = iid.IndentNo
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = iid.StatusNo;




------------------------------------------------- Comparative Statements ---------------------------

-----Without Auction Entry-----

CREATE FOREIGN TABLE sqlserver_fdw.csmain
(
    CompanyNo                  smallint,
    YearNo                     smallint,
    CSNo                       integer,
    DocumentNoYearly           varchar(30),
    DocumentDate               varchar(50),
    DocumentStatusNo           smallint,
    RFQNo                      integer,
    Remarks                    varchar(1000),
    CreatedBy                  smallint,
    CreatedDate                varchar(50),
    ModifiedBy                 smallint,
    ModifiedDate               varchar(50),
    AuthorizedBy               smallint,
    AuthorizedDate             varchar(50),
    CSType                     smallint,
    AuctionNo                  integer,
    Validity                   varchar(50),
    ValidityChangeReason       varchar(1000),
    IsReadyForAuthorization    boolean,
    AuthGrpRevisionNo          smallint,
    RefCSNo                    integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSMain'
);


INSERT INTO purchase.cs_main
(
    id,
    fy_id,
    company_id,
    division_id,
    doc_type_id,
    doc_no_yearly,
    doc_date,
    doc_series_id,
    document_status_id,
    ref_doc_type_no,
    rfq_id,
    ref_cs_id,
    vendor_selection_basis_id,
    validity_date,
    selection_criteria_id,
    remarks,
    approval_setup_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    authorized_by_id,
    authorized_date
)
OVERRIDING SYSTEM VALUE
SELECT
    cs.CSNo,
    cs.YearNo,
    cs.CompanyNo,
    NULL,
    3,
    TRIM(cs.DocumentNoYearly),
    COALESCE(
        migration.parse_sqlserver_datetime(cs.DocumentDate)::date,
        CURRENT_DATE
    ),
    NULL,
    cs.DocumentStatusNo,
    CASE
    WHEN cs.RefCSNo IS NOT NULL THEN 2
    ELSE 1
    END,
    cs.RFQNo,
    cs.RefCSNo,
    CASE cs.CSType
     WHEN 1 THEN 2
     WHEN 2 THEN 1
    END,
    COALESCE(
        migration.parse_sqlserver_datetime(cs.Validity)::date,
        COALESCE(
            migration.parse_sqlserver_datetime(cs.DocumentDate)::date,
            CURRENT_DATE
        )
    ),
    1,
    NULLIF(TRIM(cs.Remarks), ''),
    cs.AuthGrpRevisionNo,
    COALESCE(cs.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(cs.CreatedDate),
        NOW()
    ),
    cs.ModifiedBy,
    COALESCE(
    migration.parse_sqlserver_datetime(cs.ModifiedDate),
    migration.parse_sqlserver_datetime(cs.CreatedDate),
    NOW()
    ),
    cs.AuthorizedBy,
    migration.parse_sqlserver_datetime(cs.AuthorizedDate)
FROM sqlserver_fdw.csmain cs

----- Company Detail -------
CREATE FOREIGN TABLE sqlserver_fdw.cscompanydetail
(
    CSNo       integer,
    CompanyNo   smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSCompanyDetail'
);

INSERT INTO purchase.cs_company_detail
(
    cs_id,
    company_id
)
SELECT
    ccd.CSNo,
    ccd.CompanyNo
FROM sqlserver_fdw.cscompanydetail ccd
INNER JOIN  sqlserver_fdw.csmain csm
ON csm.csNo = ccd.csNo


----- Quotation Participation Detail -----
CREATE FOREIGN TABLE sqlserver_fdw.csquotationdetail
(
    QQuotationNo         integer,
    CSNo                 integer,
    RevisedQuotationNo   integer,
    IsSelected           boolean,
    MakeNo               smallint,
    ItemNo               integer,
    Quantity             numeric(12,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSQuotationDetail'
);

INSERT INTO purchase.cs_quotation_participation_detail
(
    id,
    cs_id,
    quotation_id,
    remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    cqd.QQuotationNo,
    cqd.CSNo,
    cqd.RevisedQuotationNo,
    NULL
FROM sqlserver_fdw.csquotationdetail cqd
INNER JOIN  sqlserver_fdw.csmain csm
ON csm.csNo = cqd.csNo
on conflict (id) do nothing;


----CS Quotation Detail------
INSERT INTO purchase.cs_quotation_detail
(
    id,
    cs_id,
    quotation_id,
    quotation_item_detail_id,
    qty
)
OVERRIDING SYSTEM VALUE
SELECT
    cqd.QQuotationNo AS id,
    cqd.CSNo AS cs_id,
    cqd.RevisedQuotationNo AS quotation_id,
    CASE WHEN cqd.itemNo IS NOT NULL THEN qid.id ELSE NULL END AS quotation_item_detail_id,
    CASE WHEN cqd.itemNo IS NOT NULL THEN cqd.Quantity ELSE NULL END AS qty
FROM sqlserver_fdw.csquotationdetail cqd
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = cqd.itemNo 
    AND COALESCE(cqd.makeNo,0) = COALESCE(qid.rfq_make_id,0)
    AND qid.quotation_id = cqd.RevisedQuotationNo
WHERE cqd.isSelected IS TRUE
  AND cqd.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = cqd.RevisedQuotationNo
  );



----- CS Pr Detail -----
CREATE FOREIGN TABLE sqlserver_fdw.csindentdetail
(
    CSIndentDetailNo      integer,
    IndentNo              integer,
    ItemNo                integer,
    MakeNo                smallint,
    RevisedQuotationNo    integer,
    Qty                   numeric(10,3),
    CSNo                  integer,
    IndentItemLineNo      numeric(10,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSIndentDetail'
);


INSERT INTO purchase.cs_pr_detail
(
    id,
    cs_id,
    pr_item_detail_id,
    quotation_id,
    quotation_item_detail_id,
    quotation_item_id,
    quotation_make_id,
    qty,
    balance_qty,
    po_qty,
    status_id
)
OVERRIDING SYSTEM VALUE
SELECT
    cid.CSIndentDetailNo AS id,
    cid.CSNo AS cs_id,
    prid.id AS pr_item_detail_id,
    cid.RevisedQuotationNo AS quotation_id,
    qid.id AS quotation_item_detail_id,
    cid.ItemNo AS quotation_item_id,
    cid.MakeNo AS quotation_make_id,
    cid.Qty AS qty,
    cid.Qty AS balance_qty,
    0 AS po_qty,
    9 AS status_id
FROM sqlserver_fdw.csindentdetail cid
INNER JOIN sqlserver_fdw.csmain csm
    ON csm.csNo = cid.CSNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cid.IndentNo
    AND prid.line_no = cid.IndentItemLineNo
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = cid.ItemNo
    AND COALESCE(qid.rfq_make_id,0) = COALESCE(cid.MakeNo,0)
    AND qid.quotation_id = cid.RevisedQuotationNo
WHERE cid.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = cid.RevisedQuotationNo
  )
on conflict (id) do nothing;



---- CS Reason Detail -----

CREATE FOREIGN TABLE sqlserver_fdw.csreasondetail
(
    CSQDReasonNo   integer,
    QQuotationNo   integer,
    CSReasonNo     integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSReasonDetail'
);

INSERT INTO purchase.cs_reason_detail
(
    id,
    cs_quotation_detail_id,
    cs_reason_id
)
OVERRIDING SYSTEM VALUE
SELECT
    crd.CSQDReasonNo AS id,
    crd.QQuotationNo AS cs_quotation_detail_id,
    crd.CSReasonNo AS cs_reason_id
FROM sqlserver_fdw.csreasondetail crd
WHERE EXISTS (
    SELECT 1 FROM purchase.cs_quotation_detail cqd WHERE cqd.id = crd.QQuotationNo
);


----- Cs Rank Detail -----


CREATE FOREIGN TABLE sqlserver_fdw.csl1detail
(
    CSL1DetailNo        integer,
    CSNo                integer,
    ItemNo              integer,
    MakeNo              smallint,
    RFQMakeNo           smallint,
    RevisedQuotationNo  integer,
    Rate                numeric(18,4),
    BasicAfterDiscount  numeric(18,4),
    RFQItemDetailNo     integer,
    AuctionItemDetailNo integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'CSL1Detail'
);

INSERT INTO purchase.cs_rank_detail
(
    id,
    cs_id,
    is_item_detail,
    rfq_item_detail_id,
    quotation_id,
    quotation_item_detail_id,
    rate,
    basic_rate_after_discount,
    net_amount
)
OVERRIDING SYSTEM VALUE
SELECT
    csl.CSL1DetailNo AS id,
    csl.CSNo AS cs_id,
    CASE WHEN csm.vendor_selection_basis_id = 1 THEN TRUE ELSE FALSE END AS isItemDetail,
    csl.RFQItemDetailNo AS rfq_item_detail_id,
    csl.RevisedQuotationNo AS quotation_id,
    qid.id AS quotation_item_detail_id,
    csl.Rate AS rate,
    csl.Rate AS basic_rate_after_discount,
    0 AS net_amount
FROM sqlserver_fdw.csl1detail csl
INNER JOIN purchase.cs_main csm
    ON csm.id = csl.CSNo
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = csl.ItemNo
    AND COALESCE(qid.rfq_make_id,0) = COALESCE(csl.MakeNo,0)
    AND qid.quotation_id = csl.RevisedQuotationNo
WHERE csl.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = csl.RevisedQuotationNo
  );

---------------------------------------- Approval Setup --------------------------------------

CREATE FOREIGN TABLE sqlserver_fdw.mauthorizationgroup
(
    AuthGrpRevisionNo integer,
    AuthorizationGroupNo smallint,
    Code varchar(6),
    AuthorizationGroupName varchar(100),
    FormNo smallint,
    CompanySelectionBasedOn smallint,
    FromNetAmount numeric(18,2),
    ToNetAmount numeric(18,2),
    RevisionNo smallint,
    Description varchar(500),
    CreatedBy integer,
    CreatedDate text,
    ModifiedBy integer,
    ModifiedDate text,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mAuthGrpRevisionMain'
);

INSERT INTO masterdata.approval_setup_master
(
    id,
    code,
    approval_setup_name,
    form_id,
    approval_scope_id,
    min_net_amount,
    max_net_amount,
    revision_no,
    is_current,
    main_approval_id,
    description,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    from_date,
    is_audit,
    is_audit_apply_to_existing_documents,
    to_date
)
OVERRIDING SYSTEM VALUE
SELECT
    AuthGrpRevisionNo,

    TRIM(Code),

    TRIM(AuthorizationGroupName),

    fm.new_form_id,

    CompanySelectionBasedOn,

    COALESCE(FromNetAmount, 0),

    COALESCE(ToNetAmount, 0),

    COALESCE(RevisionNo, 0),

    FALSE,

    AuthorizationGroupNo,

    Description,

    COALESCE(CreatedBy, 1),

    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),

    COALESCE(ModifiedBy, 1),

    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),

    CASE
        WHEN COALESCE(Inactive, FALSE)
        THEN 2
        ELSE 1
    END,

    NULL,

    NULL,

    FALSE,

    FALSE,

    NULL

FROM sqlserver_fdw.mauthorizationgroup
INNER JOIN migration.form_mapping fm
ON sqlserver_fdw.mauthorizationgroup.FormNo = fm.old_form_id;


---- Approver Level Detial ----

CREATE FOREIGN TABLE sqlserver_fdw.mauthorizationgroupdetail
(
    AuthGrpRevisionDetailNo integer,
    AuthGrpRevisionNo integer,
    LevelNo smallint,
	LoginNo smallint,
    PrintingCaption varchar(100),
	IsDefault Boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mAuthGrpRevisionDetail'
);


INSERT INTO masterdata.approval_setup_level_detail
(
    id,
    approval_setup_id,
    level_no,
    printing_caption,
    approval_rule_id,
    is_next_level_selection_allowed,
    max_approval_time
)
OVERRIDING SYSTEM VALUE
SELECT
    AuthGrpRevisionDetailNo,
    AuthGrpRevisionNo,
    LevelNo,
    TRIM(PrintingCaption),
    2,
    FALSE,
    NULL
FROM
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY AuthGrpRevisionNo, LevelNo
               ORDER BY AuthGrpRevisionDetailNo
           ) AS rn
    FROM sqlserver_fdw.mauthorizationgroupdetail
) t
WHERE rn = 1;


---- Approver user Detail ----


INSERT INTO masterdata.approval_setup_user_detail
(
    approval_setup_level_id,
    user_id,
    role_id,
    is_default
)
SELECT
    asl.id,
    agd.LoginNo,
    NULL,
    agd.IsDefault
FROM sqlserver_fdw.mauthorizationgroupdetail agd
INNER JOIN masterdata.approval_setup_level_detail asl
    ON asl.approval_setup_id = agd.AuthGrpRevisionNo
   AND asl.level_no = agd.LevelNo
WHERE agd.LoginNo IS NOT NULL;


---Insertion Company-Division-Department-

CREATE FOREIGN TABLE sqlserver_fdw.mauthgrprevisioncompanydetail
(
    AuthRevisionCompanyDetailNo integer,
    AuthGrpRevisionNo integer,
    CompanyNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mAuthGrpRevisionCompanyDetail'
);

CREATE FOREIGN TABLE sqlserver_fdw.mauthgrprevisiondivdeptdetail
(
    AuthGrpRevisionDivDeptDetailNo integer,
    AuthGrpRevisionNo integer,
    CompanyNo integer,
    DivisionNo integer,
    DeptNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mAuthGrpRevisionDivDeptDetail'
);


INSERT INTO masterdata.approval_setup_org_unit_detail
(
    approval_setup_id,
    company_id,
    division_id,
    department_id
)
SELECT
    AuthGrpRevisionNo,
    CompanyNo,
    NULL,
    NULL
FROM sqlserver_fdw.mauthgrprevisioncompanydetail

UNION ALL

SELECT
    AuthGrpRevisionNo,
    CompanyNo,
    DivisionNo,
    DeptNo
FROM sqlserver_fdw.mauthgrprevisiondivdeptdetail;


---Doc Type Insertion -- -

INSERT INTO masterdata.approval_setup_doc_type_detail
(
    approval_setup_id,
    doc_type_id
)
SELECT
    asm.id AS approval_setup_id,
    dtm.id AS doc_type_id
FROM masterdata.approval_setup_master asm
INNER JOIN masterdata.doc_type_master dtm
    ON dtm.form_id = asm.form_id;


---- Set Approval Main and Is Current-----

UPDATE masterdata.approval_setup_master qm
SET main_approval_id = x.main_approval_id
FROM (
    SELECT
        r.authgrprevisionNo AS approval_id,
        qf.authgrprevisionNo AS main_approval_id
    FROM sqlserver_fdw.mAuthorizationGROUP r
    INNER JOIN (
        SELECT
            authgrprevisionNo,
            authorizationgroupNo,
            ROW_NUMBER() OVER (
                PARTITION BY authorizationgroupNo
                ORDER BY revisionNo, authgrprevisionNo
            ) AS rn
        FROM sqlserver_fdw.mAuthorizationGROUP
    ) qf
        ON qf.authorizationgroupNo = r.authorizationgroupNo
       AND qf.rn = 1
) x
WHERE qm.id = x.approval_id;

UPDATE masterdata.approval_setup_master t
SET is_Current = TRUE
FROM (
    SELECT DISTINCT ON (main_approval_id)
        id
    FROM masterdata.approval_setup_master
    ORDER BY main_approval_id, revision_no DESC
) x
WHERE t.id = x.id;

--------------------------------------------------- Tax Master --------------------------------
---Before Running this Script we have to run globaldata script and also have to create group master from global data we have created ------------------
-----We have to check the tax_group_id before runnig  this script-----
INSERT INTO masterdata.tax_master
(
    id,
    tax_group_id,
    code,
    tax_name,
    rate,
    calc_nature_id,
    display_name,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
VALUES
--CGST--
(92, 1, 'MC00091', 'CGST @ 0%', 0.0000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),
(101, 1, 'MC00096', 'CGST @1.5%', 1.5000, 1, 'CGST', 1, NULL, 1, NOW(), NULL, NOW()),
(73, 1, 'MC00073', 'CGST @ 2.5%', 2.5000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),
(78, 1, 'MC00078', 'CGST @6%', 6.0000, 1, 'CGST', 2, 'Deprecated', 1, NOW(), 1, NOW()),
(74, 1, 'MC00074', 'CGST @ 9%', 9.0000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),
(80, 1, 'MC00080', 'CGST @14%', 14.0000, 1, 'CGST', 1, NULL, 1, NOW(), 1, NOW()),
--DISCOUNT--
(8, 6, 'MC00008', 'DISC', 0.0000, 2, 'DISC', 1, NULL, 1, NOW(), 1, NOW()),
--IGST--
(94, 3, 'MC00093', 'IGST @0%', 0.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),
(100, 3, 'MC00095', 'IGST @3%', 3.0000, 1, 'IGST', 1, NULL, 1, NOW(), NULL, NOW()),
(85, 3, 'MC00085', 'IGST @5%', 5.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),
(86, 3, 'MC00086', 'IGST @12%', 12.0000, 1, 'IGST', 2, 'Deprecated', 1, NOW(), NULL, NOW()),
(81, 3, 'MC00081', 'IGST @18', 18.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),
(84, 3, 'MC00084', 'IGST @28', 28.0000, 1, 'IGST', 1, NULL, 1, NOW(), 1, NOW()),
--SGST--
(93, 2, 'MC00092', 'SGST @ 0%', 0.0000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),
(102, 2, 'MC00097', 'SGST @1.5%', 1.5000, 1, 'SGST', 1, NULL, 1, NOW(), NULL, NOW()),
(76, 2, 'MC00076', 'SGST @ 2.5%', 2.5000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),
(82, 2, 'MC00082', 'SGST @ 6%', 6.0000, 1, 'SGST', 2, 'Deprecated', 1, NOW(), 1, NOW()),
(75, 2, 'MC00075', 'SGST @ 9%', 9.0000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),
(83, 2, 'MC00083', 'SGST @ 14%', 14.0000, 1, 'SGST', 1, NULL, 1, NOW(), 1, NOW()),
--UGST--
(95, 4, 'MC00094', 'UTGST @ 0%', 0.0000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),
(88, 4, 'MC00087', 'UTGST @ 2.5%', 2.5000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),
(89, 4, 'MC00088', 'UTGST @ 6%', 6.0000, 1, 'UTGST', 2, 'Deprecated', 1, NOW(), 1, NOW()),
(90, 4, 'MC00089', 'UTGST @ 9%', 9.0000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),
(91, 4, 'MC00090', 'UTGST @ 14%', 14.0000, 1, 'UTGST', 1, NULL, 1, NOW(), 1, NOW()),
--OTHER--
(103, 8, 'MC00103', 'Freight (Taxable)', 0.0000, 1, 'Freight', 1, NULL, 1, NOW(), NULL, NOW()),
(104, 7, 'MC00104', 'Other Charges (+)', 0.0000, 1, 'Other Charges', 1, NULL, 1, NOW(), NULL, NOW()),
(105, 15, 'MC00105', 'Loading/Unloading', 0.0000, 1, 'Loading/Unloading', 1, NULL, 1, NOW(), NULL, NOW());

INSERT INTO masterdata.tax_master
(
    id,
    tax_group_id,
    code,
    tax_name,
    rate,
    calc_nature_id,
    display_name,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
values
(106, 14, 'MC00106', 'RoundOff (-)', 0.0000, 2, 'RoundOff (-)', 1, null, 1, NOW(), null, NOW()),
(107, 5, 'MC00107', 'RoundOff (-)', 0.0000, 2, 'RoundOff (-)', 1, null, 1, NOW(), null, NOW()),
(108, 14, 'MC00106', 'RoundOff (-)', 0.0000, 2, 'RoundOff (-)', 1, null, 1, NOW(), null, NOW()),
(109, 14, 'MC00106', 'RoundOff (-)', 0.0000, 2, 'RoundOff (-)', 1, null, 1, NOW(), null, NOW()),
(110, 14, 'MC00106', 'RoundOff (-)', 0.0000, 2, 'RoundOff (-)', 1, null, 1, NOW(), null, NOW()),
(111, 14, 'MC00106', 'RoundOff (-)', 0.0000, 2, 'RoundOff (-)', 1, null, 1, NOW(), null, NOW())

-----------------Tax Group Dependent ----------------------------

insert into masterdata.tax_group_dpendent 
(tax_group_id, dep_tax_group_id)
values 
(1,6),
(1,8),
(2,6),
(2,8),
(3,6),
(3,8),
(4,6),
(4,8),
(8,6),
(10,6);





------------------------------------- Quotation Tax Detail -------------------------
---Tax Detail----
---Check Tax id before Insertion----

CREATE FOREIGN TABLE sqlserver_fdw.revisedquotationtaxdetail
(
    RevisedQuotationTaxNo integer,
    RevisedQuotationNo    integer,
    MiscChargeNo   smallint,
    ChargeType     smallint,
    Nature         smallint,
    ChargeOn       smallint,
    ChargeValue    numeric(10,3),
    TotalValue     numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RevisedQuotationTaxDetail'
);

CREATE FOREIGN TABLE sqlserver_fdw.revisedquotationotherchargedetail
(    
    RQOtherChargeNo integer,
    RevisedQuotationNo    integer,
    OtherChargeNo   smallint,
    Description     text,
    Amount       numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RevisedQuotationOtherChargeDetail'
);



INSERT INTO purchase.quotation_tax_detail
(
    quotation_id,
    tax_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount,
    nature_id
)-- From QuotationTaxDetail
SELECT
    qtd.RevisedQuotationNo AS quotation_id,
    qtd.MiscChargeNo AS tax_id,
    qtd.ChargeType AS charge_type_id,
    case qtd.ChargeOn
        WHEN 1 THEN 2
        WHEM 2 THEN 1
    END,
    qtd.ChargeValue AS charge_value,
    qtd.TotalValue AS amount,
    qtd.Nature AS nature_id
FROM sqlserver_fdw.revisedquotationtaxdetail qtd
WHERE EXISTS (
    SELECT 1 FROM purchase.quotation_main qm WHERE qm.id = qtd.RevisedQuotationNo
)
UNION ALL -- From QuotationOtherChargeDetail
SELECT
    qocd.RevisedQuotationNo AS quotation_id,
    CASE qocd.OtherChargeNo
        WHEN 1 THEN 103
        WHEN 2 THEN 105
        WHEN 3 THEN 104
    	WHEN 4 THEN 106
    	WHEN 5 THEN 107
    END AS tax_id,
    2 AS charge_type_id,
    2 AS charge_on_id,
    qocd.Amount AS charge_value,
    qocd.Amount AS amount,
    2 AS nature_id
FROM sqlserver_fdw.revisedquotationotherchargedetail qocd
WHERE EXISTS (
    SELECT 1 FROM purchase.quotation_main qm WHERE qm.id = qocd.RevisedQuotationNo
) AND qocd.amount > 0;


----Item Tax Detail-----
---We have to take care for the same Make, Item, RevisedQuotationNo - It will give issue in mapping-----


CREATE FOREIGN TABLE sqlserver_fdw.revisedquotationitemotherchargedetail
(   
    RevisedQuotationItemOtherChargeNo integer,
    RevisedQuotationNo                integer,
    ItemNo                     integer,
    MakeNo                      smallint,
    OtherChargeNo               smallint,
    Nature                      smallint,
    Amount                      numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RevisedQuotationItemOtherChargeDetail'
);

CREATE FOREIGN TABLE sqlserver_fdw.revisedquotationitemtaxdetail
(
    RevisedQuotationItemTaxNo integer,
    RevisedQuotationNo        integer,
    Selected           bit,
    ItemNo             integer,
    MakeNo             smallint,
    MiscChargeNo       smallint,
    ChargeType         smallint,
    Nature             smallint,
    ChargeOn           smallint,
    ChargeValue        numeric(10,3),
    TotalAmount        numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RevisedQuotationItemTaxDetail'
);

INSERT INTO purchase.quotation_item_tax_detail
(
    quotation_id,
    quotation_item_detail_id,
    tax_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount,
    nature_id
)-- From QuotationItemTaxDetail
SELECT
    qitd.RevisedQuotationNo AS quotation_id,
    qid.id AS quotation_item_detail_id,
    qitd.MiscChargeNo AS tax_id,
    qitd.ChargeType AS charge_type_id,
    case qitd.ChargeOn
        WHEN 1 THEN 2
        WHEN 2 THEN 1
    END,
    qitd.ChargeValue AS charge_value,
    qitd.TotalAmount AS amount,
    qitd.Nature AS nature_id
FROM sqlserver_fdw.revisedquotationitemtaxdetail qitd
INNER JOIN purchase.quotation_item_detail qid
    ON qid.quotation_id = qitd.RevisedQuotationNo
    AND qid.item_id = qitd.ItemNo
    AND COALESCE(qid.make_id,0) = COALESCE(qitd.MakeNo,0)
WHERE EXISTS (
    SELECT 1 FROM purchase.quotation_main qm WHERE qm.id = qitd.RevisedQuotationNo
)
UNION ALL-- From QuotationItemOtherChargeDetail
SELECT
    qiocd.RevisedQuotationNo AS quotation_id,
    qid.id AS quotation_item_detail_id,
    CASE qiocd.OtherChargeNo
        WHEN 1 THEN 103
        WHEN 2 THEN 105
        WHEN 3 THEN 104
		WHEN 4 THEN 106
		WHEN 5 THEN 107
    END AS tax_id,
    2 AS charge_type_id,
    2 AS charge_on_id,
    qiocd.Amount AS charge_value,
    qiocd.Amount AS amount,
    2 AS nature_id
FROM sqlserver_fdw.revisedquotationitemotherchargedetail qiocd
INNER JOIN purchase.quotation_item_detail qid
    ON qid.quotation_id = qiocd.RevisedQuotationNo
    AND qid.item_id = qiocd.ItemNo
    AND COALESCE(qid.make_id,0) = COALESCE(qiocd.MakeNo,0)
WHERE EXISTS (
    SELECT 1 FROM purchase.quotation_main qm WHERE qm.id = qiocd.RevisedQuotationNo
) AND qiocd.amount > 0;


-------------------------------------- Purchase Order Tax Detail -------------------------------

---- Tax Detail-------

CREATE FOREIGN TABLE sqlserver_fdw.poamendmenttaxdetail
(
    POAmendmentTaxNo integer,
    POAmendmentNo    integer,
    MiscChargeNo     smallint,
    ChargeType       smallint,
    Nature           smallint,
    ChargeOn         smallint,
    ChargeValue      numeric(10,3),
    TotalValue       numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentTaxDetail'
);

CREATE FOREIGN TABLE sqlserver_fdw.poamendmentotherchargedetail
(
    POAmendmentOtherChargeNo integer,
    POAmendmentNo            integer,
    OtherChargeNo            smallint,
    Description              text,
    Amount                   numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentOtherChargeDetail'
);


INSERT INTO  purchase.purchase_order_tax_detail
(
    po_id,
    tax_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount,
    nature_id   ---Need to update to nature_id
)-- From POAmendmentTaxDetail
SELECT
    patd.POAmendmentNo AS purchase_order_id,
    patd.MiscChargeNo AS tax_id,
    2 AS charge_type_id,
    case patd.ChargeOn
        WHEN 1 THEN 2
        WHEN 2 THEN 1
    END,
    patd.ChargeValue AS charge_value,
    patd.TotalValue AS amount,
    patd.Nature AS nature_id
FROM sqlserver_fdw.poamendmenttaxdetail patd
WHERE EXISTS (
    SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = patd.POAmendmentNo
)
UNION ALL -- From POAmendmentOtherChargeDetail
SELECT
    paocd.POAmendmentNo AS purchase_order_id,
    CASE paocd.OtherChargeNo
        WHEN 1 THEN 103
        WHEN 2 THEN 105
        WHEN 3 THEN 104
    		WHEN 4 THEN 106
    		WHEN 5 THEN 107
    END AS tax_id,
    2 AS charge_type_id,
    2 AS charge_on_id,
    paocd.Amount AS charge_value,
    paocd.Amount AS amount,
    2 AS nature_id
FROM sqlserver_fdw.poamendmentotherchargedetail paocd
WHERE EXISTS (
    SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = paocd.POAmendmentNo
);


----Item Tax Detail -------


CREATE FOREIGN TABLE sqlserver_fdw.poamendmentitemtaxdetail
(
    POAmendmentItemTaxNo integer,
    POAmendmentNo        integer,
    Selected             bit,
    ItemNo               integer,
    MakeNo               smallint,
    MiscChargeNo         smallint,
    ChargeType           smallint,
    Nature               smallint,
    ChargeOn             smallint,
    ChargeValue          numeric(10,3),
    TotalAmount          numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentItemTaxDetail'
);

CREATE FOREIGN TABLE sqlserver_fdw.poamendmentitemotherchargedetail
(
    POAmendmentItemOtherChargeNo integer,
    POAmendmentNo                integer,
    ItemNo                       integer,
    MakeNo                       smallint,
    OtherChargeNo                smallint,
    Nature                       smallint,
    Amount                       numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentItemOtherChargeDetail'
);


INSERT INTO purchase.purchase_order_item_tax_detail
(
    po_id,
    po_item_detail_id,
    tax_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount,
    nature_id
)
-- From POAmendmentItemTaxDetail
SELECT
    paitd.POAmendmentNo AS purchase_order_id,
    poid.id AS purchase_order_item_detail_id,
    paitd.MiscChargeNo AS tax_id,
    2 AS charge_type_id,
    case paitd.ChargeOn
        WHEN 1 THEN 2
        WHEN 2 THEN 1
    END,
    paitd.ChargeValue AS charge_value,
    paitd.TotalAmount AS amount,
    paitd.Nature AS nature_id
FROM sqlserver_fdw.poamendmentitemtaxdetail paitd
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paitd.POAmendmentNo
    AND poid.item_id = paitd.ItemNo
    AND COALESCE(poid.make_id,0) = COALESCE(paitd.MakeNo,0)
WHERE EXISTS (
    SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = paitd.POAmendmentNo
)
UNION ALL
-- From POAmendmentItemOtherChargeDetail
SELECT
    paiocd.POAmendmentNo AS purchase_order_id,
    poid.id AS purchase_order_item_detail_id,
    CASE paiocd.OtherChargeNo
        WHEN 1 THEN 103
        WHEN 2 THEN 105
        WHEN 3 THEN 104
        WHEN 4 THEN 106
        WHEN 5 THEN 107
    END AS tax_id,
    2 AS charge_type_id,
    2 AS charge_on_id,
    paiocd.Amount AS charge_value,
    paiocd.Amount AS amount,
    paiocd.Nature AS nature_id
FROM sqlserver_fdw.poamendmentitemotherchargedetail paiocd
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paiocd.POAmendmentNo
    AND poid.item_id = paiocd.ItemNo
    AND COALESCE(poid.make_id,0) = COALESCE(paiocd.MakeNo,0)
WHERE EXISTS (
    SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = paiocd.POAmendmentNo
);



------------------------------ Approval Process ----------------------------------------------------------

CREATE FOREIGN TABLE sqlserver_fdw.indentauthorizationdetail
(
    IndentAuthorizationDetailNo     integer,
    IndentNo                        integer,
    StatusNo                        smallint,
    Comment                         varchar(500),
    ModifiedBy                      integer,
    ModifiedDate                    varchar(50),
    LastStatusNo                    smallint,
    LastComment                     varchar(500),
    LoginNo                         integer,
    LastModifiedDate                varchar(50),
    LevelNo                         smallint,
    IsReady                         boolean,
    AssignDate                      varchar(50),
    NextApproverNo                  integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'IndentAuthorizationDetail'
);

WITH action_cte AS (
    SELECT DISTINCT ON (iad.IndentNo)
        iad.IndentNo,
        iad.ModifiedBy      AS action_by_id,
        migration.parse_sqlserver_datetime(iad.ModifiedDate) AS action_date
    FROM sqlserver_fdw.indentauthorizationdetail iad
    WHERE iad.ModifiedBy IS NOT NULL
      AND iad.ModifiedDate IS NOT NULL
    ORDER BY iad.IndentNo, iad.LevelNo DESC
)
INSERT INTO utility.approval_process_main (
    form_id,
    doc_id,
    approval_setup_id,
    revision_no,
    is_current,
    status_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    max_approver_level_no,
    current_approved_level_no,
    approval_start_date,
    action_by_id,
    action_date,
    company_id,
    division_id,
    department_id,
    doc_type_id,
    is_audit,
    audit_entry_id
)
OVERRIDING SYSTEM VALUE
SELECT
    6                                                           AS form_id,
    pr.id                                                       AS doc_id,
    COALESCE(pr.approval_setup_id,120)                          AS approval_setup_id,
    0                                                           AS revision_no,
    true                                                        AS is_current,
    CASE
    WHEN pr.document_status_id = 30 THEN 9
    WHEN pr.document_status_id = 10
         AND EXISTS (
             SELECT 1
             FROM sqlserver_fdw.indentauthorizationdetail iad2
             WHERE iad2.IndentNo = pr.id
               AND iad2.StatusNo = 1
         ) THEN 14
    WHEN pr.document_status_id = 10 THEN 7
    END                                                         AS status_id,
    pr.created_by_id                                            AS created_by_id,
    pr.created_date         AS created_date,
    pr.modified_by_id                                           AS modified_by_id,
    pr.modified_date       AS modified_date,
    MAX(iad.LevelNo)                                            AS max_approver_level_no,
    MAX(CASE WHEN iad.IsReady = true THEN iad.LevelNo END)      AS current_approved_level_no,
    COALESCE(migration.parse_sqlserver_datetime(MIN(iad.AssignDate)), Now())     AS approval_start_date,
    ac.action_by_id                                             AS action_by_id,
    ac.action_date                                              AS action_date,
    pr.company_id                                               AS company_id,
    pr.division_id                                              AS division_id,
    pr.department_id                                            AS department_id,
    pr.doc_type_id                                              AS doc_type_id,
    false                                                       AS is_audit,
    NULL                                                        AS audit_entry_id
FROM inventory.purchase_request_main pr
JOIN sqlserver_fdw.indentauthorizationdetail iad
    ON iad.IndentNo = pr.id
LEFT JOIN action_cte ac
    ON ac.IndentNo = pr.id
GROUP BY
    pr.id,
    pr.approval_setup_id,
    pr.created_by_id,
    pr.created_date,
    pr.modified_by_id,
    pr.modified_date,
    pr.company_id,
    pr.division_id,
    pr.department_id,
    pr.doc_type_id,
	ac.action_by_id,
    ac.action_date;


INSERT INTO utility.approval_process_detail (
    approval_process_id,
    user_id,
    role_id,
    level_no,
    assigned_date,
    modified_date,
    modified_by,
    status_id,
    status_remarks,
    approval_rule_id,
    is_next_level_selection_allowed,
	printing_caption
)
OVERRIDING SYSTEM VALUE
SELECT
    apm.id                                                          AS approval_process_id,
    iad.LoginNo                                                     AS user_id,
    NULL                                                            AS role_id,
    iad.LevelNo                                                     AS level_no,
    migration.parse_sqlserver_datetime(iad.AssignDate)              AS assigned_date,
    migration.parse_sqlserver_datetime(
        COALESCE(iad.ModifiedDate, iad.LastModifiedDate)
    )                                                               AS modified_date,
    iad.ModifiedBy                                                  AS modified_by,
    sm.new_status_id                                                AS status_id,
    COALESCE(
        NULLIF(TRIM(iad.Comment), ''),
        NULLIF(TRIM(iad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
	COALESCE(alm.printing_caption, 'Approved By')
FROM sqlserver_fdw.indentauthorizationdetail iad
JOIN utility.approval_process_main apm
    ON apm.doc_id = iad.IndentNo
    AND apm.form_id = 6
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = iad.StatusNo
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
	AND alm.level_no = iad.levelNo;


CREATE FOREIGN TABLE sqlserver_fdw.poamendmentauthorizationdetail
(
    POAmendmentAuthorizationDetailNo    integer,
    POAmendmentNo                       integer,
    StatusNo                            smallint,
    Comment                             varchar(500),
    ModifiedBy                          integer,
    ModifiedDate                        varchar(50),
    LastStatusNo                        smallint,
    LastComment                         varchar(500),
    LoginNo                             integer,
    LastModifiedDate                    varchar(50),
    LevelNo                             smallint,
    IsReady                             boolean,
    AssignDate                          varchar(50),
    NextApproverNo                      integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentAuthorizationDetail'
);

----- Insert Main ---- (po)
WITH action_cte AS (
    SELECT DISTINCT ON (pad.POAmendmentNo)
        pad.POAmendmentNo,
        pad.ModifiedBy                                          AS action_by_id,
        migration.parse_sqlserver_datetime(pad.ModifiedDate)    AS action_date
    FROM sqlserver_fdw.poamendmentauthorizationdetail pad
    WHERE pad.ModifiedBy IS NOT NULL
      AND pad.ModifiedDate IS NOT NULL
    ORDER BY pad.POAmendmentNo, pad.LevelNo DESC
)
INSERT INTO utility.approval_process_main (
    form_id,
    doc_id,
    approval_setup_id,
    revision_no,
    is_current,
    status_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    max_approver_level_no,
    current_approved_level_no,
    approval_start_date,
    action_by_id,
    action_date,
    company_id,
    division_id,
    department_id,
    doc_type_id,
    is_audit,
    audit_entry_id
)
OVERRIDING SYSTEM VALUE
SELECT
    10                                                              AS form_id,
    pom.id                                                          AS doc_id,
    pom.approval_setup_id                                           AS approval_setup_id,
    0                                                               AS revision_no,
    true                                                            AS is_current,
    CASE
    WHEN pom.document_status_id = 30 THEN 9
    WHEN pom.document_status_id = 10
         AND EXISTS (
             SELECT 1
             FROM sqlserver_fdw.poamendmentauthorizationdetail pad2
             WHERE pad2.poAmendmentNo = pom.id
               AND pad2.StatusNo = 1
         ) THEN 14
    WHEN pom.document_status_id = 10 THEN 7
    END                                                             AS status_id,
    pom.created_by_id                                               AS created_by_id,
    pom.created_date                                                AS created_date,
    pom.modified_by_id                                              AS modified_by_id,
    pom.modified_date                                               AS modified_date,
    MAX(pad.LevelNo)                                                AS max_approver_level_no,
    MAX(CASE WHEN pad.IsReady = true THEN pad.LevelNo END)          AS current_approved_level_no,
    COALESCE(migration.parse_sqlserver_datetime(MIN(pad.AssignDate)), NOW()) AS approval_start_date,
    ac.action_by_id                                                 AS action_by_id,
    ac.action_date                                                  AS action_date,
    pom.company_id                                                  AS company_id,
    pom.division_id                                                 AS division_id,
    pom.department_id                                               AS department_id,
    pom.doc_type_id                                                 AS doc_type_id,
    false                                                           AS is_audit,
    NULL                                                            AS audit_entry_id
FROM purchase.purchase_order_main pom
JOIN sqlserver_fdw.poamendmentauthorizationdetail pad
    ON pad.POAmendmentNo = pom.id
	AND  pom.approval_setup_id IS NOT NULL
LEFT JOIN action_cte ac
    ON ac.POAmendmentNo = pom.id
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = pom.status_id
GROUP BY
    pom.id,
    pom.approval_setup_id,
    pom.created_by_id,
    pom.created_date,
    pom.modified_by_id,
    pom.modified_date,
    pom.company_id,
    pom.division_id,
    pom.department_id,
    pom.doc_type_id,
    ac.action_by_id,
    ac.action_date;



-----Detail-----

INSERT INTO utility.approval_process_detail (
    approval_process_id,
    user_id,
    role_id,
    level_no,
    assigned_date,
    modified_date,
    modified_by,
    status_id,
    status_remarks,
    approval_rule_id,
    is_next_level_selection_allowed,
    printing_caption
)
OVERRIDING SYSTEM VALUE
SELECT
    apm.id                                                          AS approval_process_id,
    pad.LoginNo                                                     AS user_id,
    NULL                                                            AS role_id,
    pad.LevelNo                                                     AS level_no,
    migration.parse_sqlserver_datetime(pad.AssignDate)              AS assigned_date,
    migration.parse_sqlserver_datetime(
        COALESCE(pad.ModifiedDate, pad.LastModifiedDate)
    )                                                               AS modified_date,
    pad.ModifiedBy                                                  AS modified_by,
	CASE
	WHEN pad.StatusNo = 1 THEN 12
	WHEN pad.StatusNo = 5 THEN 3
	WHEN pad.StatusNo = 17 THEN 19 
	END                                                             AS status_id,
    COALESCE(
        NULLIF(TRIM(pad.Comment), ''),
        NULLIF(TRIM(pad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
    COALESCE(alm.printing_caption, 'Approved By')                   AS printing_caption
FROM sqlserver_fdw.poamendmentauthorizationdetail pad
JOIN utility.approval_process_main apm
    ON apm.doc_id = pad.POAmendmentNo
    AND apm.form_id = 10
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
    AND alm.level_no = pad.LevelNo;

------------------------------------------