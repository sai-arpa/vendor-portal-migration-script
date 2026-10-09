--CREATE EXTENSION tds_fdw;

CREATE SERVER sqlserver_fdw
FOREIGN DATA WRAPPER tds_fdw
OPTIONS (
    servername '192.168.2.181',
    port '1433',
    database 'RealDeals01102026' --RealDeals16062026
);

CREATE USER MAPPING FOR CURRENT_USER
SERVER sqlserver_fdw
OPTIONS (
    username 'user01',
    password 'user01'
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


create schema if not exists migration;

CREATE OR REPLACE FUNCTION migration.parse_sqlserver_datetime(p_value text)
 RETURNS timestamp with time zone
 LANGUAGE sql
 IMMUTABLE
AS $function$
    SELECT CASE
    WHEN p_value IS NULL OR trim(p_value) = '' THEN NULL

    -- Format 1: SQL Server style string
    WHEN p_value ~ '^[A-Za-z]{3}\s+\d{1,2}\s+\d{4}'
    THEN to_timestamp(
        p_value,
        'Mon DD YYYY HH12:MI:SS:MSPM'
    )

    -- Format 2: ISO timestamp with timezone
    ELSE p_value::timestamptz
END
$function$;

CREATE TABLE migration.status_mapping (
    old_status_id   INT,
    old_status_name VARCHAR(100),
    new_status_id   INT,
    new_status_name VARCHAR(100)
);

-- Insert data
INSERT INTO migration.status_mapping (
    old_status_id,
    old_status_name,
    new_status_id,
    new_status_name
)
VALUES
(1,  'Authorized',  9,  'Authorize'),
(2,  'Completed',   11, 'Completed'),
(3,  'Hold',        17, 'Hold'),
(4,  'Cancel',      15, 'Cancelled'),
(5,  'Initial',     7,  'Draft'),
(6,  'Release',     14, 'In Review'),
(7,  'Short Close', 16, 'Short Closed'),
(8,  'In Progress', 10, 'In Progress'),
(9,  'Reject',      13, 'Rejected'),
(10, 'Fixed',       12, 'Approved'),
(11, 'Open',        1,  'Active'),
(12, 'Accept',      12, 'Approved'),
(13, 'Approve',     12, 'Approved'),
(14, 'Pending',     3,  'Pending'),
(15, 'Live',        1,  'Active'),
(16, 'Expired',     5,  'Expired'),
(17, 'Skipped',     19, 'Skipped');


CREATE TABLE IF NOT EXISTS migration.form_mapping (
    new_form_id INTEGER NOT NULL,
    old_form_id INTEGER NOT NULL
);

INSERT INTO migration.form_mapping (new_form_id, old_form_id)
VALUES
(46,185),   -- Role Master, Role Master
(45,186),   -- User Master, User Master
(44,1001),  -- User Access Control, User Access Control
(35,1018),  -- Item Master, Item Master
(33,1015),  -- Category Master, Category Master
(32,1016),  -- Group Master, Group Master
(34,1017),  -- Subgroup Master, Sub Group Master
(19,1029),  -- Unit Master, Unit
(20,1034),  -- Make Master, Make Master
(21,1028),  -- Cost Center Master, Cost Center
(27,1032),  -- Department Master, Department
(16,1033),  -- State Master, State Master
(17,1036),  -- City Master, City Master
(15,1035),  -- Country Master, Country Master
(18,1031),  -- Location Master, Location Master
(24,1030),  -- Division, Division
(49,1058),  -- Vendor Master, Vendor Master List
(36,498),   -- Skip Approval, Skip Auhorization
(37,495),   -- Release Indent, Release Indent
(38,487),   -- Duplicate Item Group, Duplicate Item Group
(39,496),   -- CS Validity, CS Validity
(40,485),   -- Data Fetch Utility, Data Fetch Utility
(42,1005),  -- PO Cancellation, PO Cancellation
(6,1019),   -- Purchase Request, Purchase Request
(7,462),    -- Request For Quotation, RFQ
(8,464),    -- Comparative Statement, Comparative Statement
(9,466),    -- Quotation, Quotation
(10,463),   -- Purchase Order, Purchase Order
(51,1052),  -- Purchase Request Approval, Indent Authorization
(52,491),   -- Purchase Order Approval, PO Authorization
(53,7),     -- Request For Quotation Approval, RFQ
(54,494),   -- Comparative Statement Approval, CS Authorization
(68,1054),  -- Vendor Wise Procurement, Vendor Wise Procurement
(69,467),   -- Indent Register, Indent Register
(70,1042),  -- Purchase Order Amendment Register, PO Amendment Register
(71,474),   -- Purchase Register, PO Register
(72,475),   -- Purchase Summary, PO Summary
(73,1056),  -- Indent Ageing, Indent Item Ageing
(74,1043),  -- PO Rejection History, PO Rejection History Register
(75,475),   -- PO Summary, PO Summary
(76,490),   -- PO L2 Report, PO L2 Report
(77,1058),  -- Vendor List, Vendor Master List
(79,1013),  -- RFQ To PO Report, RFQ To PO Progress Flow
(80,1055),  -- Item Group Wise Procurement, Item Group Wise Procurement
(81,1053),  -- Item Wise Purchase Summary, Item Wise Procurement
(82,460),   -- New Vendors, New Vendors
(82,501),   -- New Vendors, New Vendors
(83,477);   -- Passive Vendors, Passive Vendors


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


create schema if not exists sqlserver_fdw;

CREATE FOREIGN table if not exists sqlserver_fdw.login
(
    loginno smallint,
    loginid varchar(50),
    pwd text,
    vendorlocationno integer,
    usertype varchar(1),
    createdby integer,
    createddate text,
    modifiedby integer,
    modifieddate text,
    printingname varchar(50),
    phoneno varchar(50),
    inactive boolean,
    email varchar(300),
    lastlogindate text,
    lastactivedate text,
    loginguid varchar(50),
    lastpasswordchangeddate text,
    defaultdashboard smallint,
    isblocked boolean,
    blockeddate text,
    divisionselectionon smallint,
    deptselectionon smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Security',
    table_name 'Login'
);

CREATE FOREIGN table if not exists sqlserver_fdw.loginvendorlocationdetail
(
    logindivno integer,
    loginno smallint,
    vendorlocationno integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Security',
    table_name 'LoginVendorLocationDetail'
);


INSERT INTO security.user_master
(
    id,
    user_type_id,
    username,
    password_hash,
    display_name,
    created_by_id,
    created_date,
    modified_date,
    status_id,
    is_guest_login,
    failed_login_attempt_counter
)
OVERRIDING SYSTEM VALUE
VALUES
(
    1000000,
    1,
    'migration',
    'migration',
    'Migration User',
    1000000,
    now(),
    now(),
    1,
    false,
    0
);

--drop foreign table sqlserver_fdw.login;

--truncate table security.user_master cascade;

INSERT INTO security.user_master
(
    id,
    user_type_id,
    username,
    password_hash,
    display_name,
    contact_no,
    contact_no_country_id,
    time_zones_id,
    email,
    erp_user_id,
    division_type_id,
    department_type_id,
    is_blocked,
    blocked_date,
    last_password_changed_date,
    last_login_date,
    failed_login_attempt_counter,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    supplier_account_id,
    is_guest_login
)
OVERRIDING SYSTEM VALUE
SELECT
    l.LoginNo,
    CASE
        WHEN supplier.LoginNo IS NOT NULL THEN 3::smallint
        ELSE l.UserType::smallint
    END AS user_type_id,
    l.LoginID,
    'ab',
    COALESCE(NULLIF(l.PrintingName, ''), l.LoginID),
    CASE 
        WHEN NULLIF(TRIM(l.PhoneNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(l.PhoneNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(l.PhoneNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    1::smallint AS time_zones_id,
    l.Email,
    l.LoginGUID,
    COALESCE(l.DivisionSelectionOn, 1)::smallint,
    COALESCE(l.DeptSelectionOn, 1)::smallint,
    COALESCE(l.IsBlocked, false),
    migration.parse_sqlserver_datetime(l.BlockedDate),
    migration.parse_sqlserver_datetime(l.LastPasswordChangedDate),
    migration.parse_sqlserver_datetime(l.LastLoginDate),
    0::smallint AS failed_login_attempt_counter,
    1000000 AS created_by_id,
    COALESCE(migration.parse_sqlserver_datetime(l.CreatedDate), now()) AS created_date,
    NULL AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(l.ModifiedDate),
        migration.parse_sqlserver_datetime(l.CreatedDate),
        now()
    ) AS modified_date,
    CASE
        WHEN COALESCE(l.Inactive, false)
            THEN 2::smallint
        ELSE 1::smallint
    END AS status_id,
    NULL AS status_remarks,
    NULL AS supplier_account_id,
    FALSE AS is_guest_login
FROM sqlserver_fdw.login l
LEFT JOIN
(
    SELECT DISTINCT LoginNo
    FROM sqlserver_fdw.loginvendorlocationdetail
) supplier
ON supplier.LoginNo = l.LoginNo;

CREATE TEMP TABLE tmp_login AS
SELECT
    LoginNo,
    CreatedBy,
    ModifiedBy
FROM sqlserver_fdw.login;

UPDATE security.user_master u
SET
    created_by_id = CASE
                        WHEN COALESCE(t.createdby, 0) = 0 THEN 1
                        ELSE t.createdby
                    END,
    modified_by_id = CASE
                         WHEN COALESCE(t.modifiedby, 0) = 0 THEN 1
                         ELSE t.modifiedby
                     END
FROM tmp_login t
WHERE u.id = t.loginno;

DELETE FROM security.user_master
WHERE id = 1000000;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE FOREIGN table if not exists sqlserver_fdw.mcountrymaster
(
    CountryNo smallint,
    CountryName varchar(200),
    Code varchar(50),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mCountryMaster'
);

INSERT INTO masterdata.country_master
(
    id,
    country_name,
    code,
    iso_country_code,
    phone_code,
    pin_code_length,
    min_contact_no_length,
    max_contact_no_length,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    pin_code_format_id
)
OVERRIDING SYSTEM VALUE
SELECT
    CountryNo,
    TRIM(CountryName),
    TRIM(Code),
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 'IN'
        WHEN 'CHINA' THEN 'CN'
        WHEN 'SWEDEN' THEN 'SE'
        WHEN 'HONG KONG' THEN 'HK'
        ELSE NULL
    END AS iso_country_code,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN '+91'
        WHEN 'CHINA' THEN '+86'
        WHEN 'SWEDEN' THEN '+46'
        WHEN 'HONG KONG' THEN '+852'
        ELSE NULL
    END AS phone_code,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 6
        WHEN 'CHINA' THEN 6
        WHEN 'SWEDEN' THEN 5
        WHEN 'HONG KONG' THEN NULL
        ELSE NULL
    END AS pin_code_length,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 13
        WHEN 'CHINA' THEN 11
        WHEN 'SWEDEN' THEN 7
        WHEN 'HONG KONG' THEN 8
        ELSE NULL
    END AS min_contact_no_length,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 13
        WHEN 'CHINA' THEN 14
        WHEN 'SWEDEN' THEN 13
        WHEN 'HONG KONG' THEN 12
        ELSE NULL
    END AS max_contact_no_length,
    COALESCE(CreatedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    1,
    NULL,
    case UPPER(TRIM(CountryName))
    	when 'HONG KONG' then 2
    	else 1
    end
FROM sqlserver_fdw.mcountrymaster;




-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE sqlserver_fdw.mstatemaster
(
    StateNo smallint,
    Code varchar(50),
    StateName varchar(200),
    CountryNo smallint,
    GSTStateCode varchar(50),
    IsUnionTerritory boolean,
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
    table_name 'mStateMaster'
);

INSERT INTO masterdata.state_master
(
    id,
    code,
    state_name,
    country_id,
    gst_state_code,
    is_union_territory,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    StateNo,
    TRIM(Code),
    TRIM(StateName),
    CountryNo,
    GSTStateCode,
    COALESCE(IsUnionTerritory,FALSE),
    COALESCE(CreatedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(Inactive,FALSE)
        THEN 2
        ELSE 1
    END,
    CASE
    	WHEN Inactive THEN 'inactive'
	END AS status_remarks
FROM sqlserver_fdw.mstatemaster;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.mcitymaster
(
    CityNo integer,
    Code varchar(50),
    CityName varchar(200),
    StateNo smallint,
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
    table_name 'mCityMaster'
);

INSERT INTO masterdata.city_master
(
    id,
    code,
    city_name,
    state_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    CityNo,
    TRIM(Code),
    TRIM(CityName),
    StateNo,
    COALESCE(CreatedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(Inactive,FALSE)
        THEN 2
        ELSE 1
    END,
    CASE
    	WHEN Inactive THEN 'inactive'
	END AS status_remarks
FROM sqlserver_fdw.mcitymaster;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE sqlserver_fdw.mdbmaster
(
    DBNo integer,
    Code varchar(10),
    DBDescription varchar(300),
    DBName varchar(100),
    Inactive boolean,
    DBConnectionName varchar(300),
    IndentFetchStartDate text,
    LastIndentFetchDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDBMaster'
);

INSERT INTO masterdata.db_master
(
    id,
    code,
    db_description,
    db_name,
    status_id,
    db_connection_name,
    first_indent_fetch_date,
    last_indent_fetch_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    DBNo,
    TRIM(Code),
    TRIM(DBDescription),
    TRIM(DBName),
    CASE
        WHEN COALESCE(Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    COALESCE(TRIM(DBConnectionName), TRIM(DBName)),
    migration.parse_sqlserver_datetime(IndentFetchStartDate),
    migration.parse_sqlserver_datetime(LastIndentFetchDate),
    1,
    now(),
    1,
    now()
FROM sqlserver_fdw.mdbmaster;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcompanymaster
(
    CompanyNo                smallint,
    CompanyCode              varchar(10),
    CompanyName              varchar(100),
    AliasName                varchar(30),
    Address1                 varchar(100),
    Address2                 varchar(100),
    Address3                 varchar(100),
    CINNo                    varchar(50),
    CityNo                   integer,
    PhoneNo                  varchar(200),
    CorporateOfficeAddress   varchar(250),
    CorporateOfficePhone     varchar(50),
    CorporateOfficeEmail     varchar(300),
    CountryNo                integer,
    DBNo                     smallint,
    Email                    varchar(200),
    ERPCompanyCode           varchar(10),
    GSTINNo                  varchar(50),
    HeadOfficeNo             smallint,
    ITPANNo                  varchar(100),
    PinCodeCompany           varchar(6),
    PrintingName             varchar(50),
    RegdOfficeAddress        varchar(250),
    RegdOfficePhone          varchar(50),
    RegdOfficeEmail          varchar(300),
    StateNo                  integer,
    TallyCompanyName         varchar(150),
    TallyGodownName          varchar(150),
    Website                  varchar(100),
    Inactive                 boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mCompanyMaster'
);


INSERT INTO masterdata.company_master
(
    id,
    code,
    company_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    alias,
    address1,
    address2,
    address3,
    cin_no,
    city_id,
    contact_no,
    contact_no_country_id,
    corporate_office_address,
    corporate_office_contact_no,
    corporate_office_contact_no_country_id,
    corporate_office_email,
    country_id,
    email,
    erp_company_unique_id,
    full_address,
    gstin_no,
    head_office_id,
    pan_no,
    pincode,
    printing_name,
    regd_office_address,
    regd_office_contact_no,
    regd_office_contact_no_country_id,
    regd_office_email,
    state_id,
    tally_company_name,
    tally_godown_name,
    website,
    time_zones_id,
    db_master_id
)
OVERRIDING SYSTEM VALUE
SELECT
    CompanyNo,
    LEFT(TRIM(CompanyCode), 8),
    LEFT(TRIM(CompanyName), 100),
    1 AS created_by_id,
    now() AS created_date,
    1 AS modified_by_id,
    now() AS modified_date,
    CASE
        WHEN COALESCE(Inactive, FALSE)
            THEN 2::smallint
        ELSE 1::smallint
    END AS status_id,
    NULL AS status_remarks,
    LEFT(TRIM(AliasName), 15),
    LEFT(TRIM(Address1), 150),
    LEFT(TRIM(Address2), 150),
    LEFT(TRIM(Address3), 150),
    LEFT(TRIM(CINNo), 21),
    CityNo,
    CASE 
        WHEN NULLIF(TRIM(PhoneNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(PhoneNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(PhoneNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    LEFT(TRIM(CorporateOfficeAddress), 500),
    CASE 
        WHEN NULLIF(TRIM(CorporateOfficePhone), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(CorporateOfficePhone), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(CorporateOfficePhone), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    LEFT(TRIM(CorporateOfficeEmail), 100),
    case when CountryNo = 1 then 3 else CountryNo end,
    LEFT(TRIM(Email), 320),
    LEFT(TRIM(ERPCompanyCode), 50),
    LEFT(
        CONCAT_WS(
            ', ',
            NULLIF(TRIM(Address1), ''),
            NULLIF(TRIM(Address2), ''),
            NULLIF(TRIM(Address3), '')
        ),
        500
    ) AS full_address,
    LEFT(TRIM(GSTINNo), 15),
    NULL::integer AS head_office_id,
    LEFT(TRIM(ITPANNo), 10),
    LEFT(TRIM(PinCodeCompany), 10),
    LEFT(TRIM(PrintingName), 100),
    LEFT(TRIM(RegdOfficeAddress), 500),
    CASE 
        WHEN NULLIF(TRIM(RegdOfficePhone), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(RegdOfficePhone), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(RegdOfficePhone), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    LEFT(TRIM(RegdOfficeEmail), 100),
    StateNo,
    LEFT(TRIM(TallyCompanyName), 100),
    LEFT(TRIM(TallyGodownName), 100),
    LEFT(TRIM(Website), 150),
    1::smallint AS time_zones_id,
    dbno as db_master_id
FROM sqlserver_fdw.mcompanymaster;


-- Update headoffice Id
UPDATE masterdata.company_master cm
SET head_office_id = src.HeadOfficeNo
FROM sqlserver_fdw.mcompanymaster src
WHERE cm.id = src.CompanyNo
  AND src.HeadOfficeNo IS NOT NULL
  AND src.HeadOfficeNo <> 0;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcompanymasterlocationdetail
(
    CompanyMasterLocationNo integer,
    CompanyNo smallint,
    ShippingAddress varchar(300),
    Code varchar(7),
    ERPUniqueID varchar(10),
    IsDefault boolean
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mCompanyMasterLocationDetail');

INSERT INTO masterdata.company_master_location_detail
(
    id,
    code,
    company_id,
    address1,
    address2,
    address3,
    city_id,
    state_id,
    country_id,
    pincode,
    full_address,
    contact_no,
    contact_no_country_id,
    is_default,
    status_id,
    status_remarks,
    erp_location_unique_id_1,
    erp_location_unique_id_2,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    m.CompanyMasterLocationNo,
    LEFT(TRIM(m.Code), 6),
    m.CompanyNo,
    LEFT(COALESCE(m.ShippingAddress, ''), 150),
    NULL AS address2,
    NULL AS address3,
    c.city_id,
    c.state_id,
    2,
    NULL AS pincode,
    LEFT(COALESCE(m.ShippingAddress, ''), 500) AS full_address,
    CASE 
        WHEN NULLIF(TRIM(c.contact_no), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(c.contact_no), 12)
        ELSE '+91' 
    END,
    CASE
        WHEN NULLIF(TRIM(c.contact_no), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE null
    END,
    COALESCE(m.IsDefault, FALSE),
    1::smallint AS status_id,
    NULL AS status_remarks,
    m.ERPUniqueID,
    NULL AS erp_location_unique_id_2,
    1 AS created_by_id,
    now() AS created_date,
    1 AS modified_by_id,
    now() AS modified_date
FROM sqlserver_fdw.mcompanymasterlocationdetail m
INNER JOIN masterdata.company_master c
    ON c.id = m.CompanyNo;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.mdivisionmaster
(
    DivisionNo integer,
    DivisionCode varchar(50),
    DivisionName varchar(500),
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
    table_name 'mDivisionMaster'
);

INSERT INTO masterdata.division_master
(
    id,
    code,
    division_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    d.DivisionNo,
    TRIM(d.DivisionCode),
    TRIM(d.DivisionName),
    COALESCE(d.CreatedBy, 1) AS created_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(d.CreatedDate),
        now()
    ),
    COALESCE(d.ModifiedBy, 1) AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(d.ModifiedDate),
        migration.parse_sqlserver_datetime(d.CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(d.Inactive,FALSE)
            THEN 2::smallint
        ELSE 1::smallint
    END,
    CASE
    	WHEN Inactive THEN 'inactive'
	END AS status_remarks
FROM sqlserver_fdw.mdivisionmaster d;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.mdivisionmastercompanydetail
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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.mdeptmaster
(
    DeptNo integer,
    Code varchar(50),
    DeptName varchar(500),
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
    table_name 'mDeptMaster'
);

INSERT INTO masterdata.department_master
(
    id,
    code,
    department_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    d.DeptNo,
    TRIM(d.Code),
    TRIM(d.DeptName),
	COALESCE(d.CreatedBy, 1) AS created_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(d.CreatedDate),
        now()
    ),
    COALESCE(d.ModifiedBy, 1) AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(d.ModifiedDate),
        migration.parse_sqlserver_datetime(d.CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(d.Inactive,FALSE)
            THEN 2::smallint
        ELSE 1::smallint
    END,
    CASE
    	WHEN Inactive THEN 'inactive'
	END AS status_remarks
FROM sqlserver_fdw.mdeptmaster d;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcostcentermaster
(
    CostCenterNo INTEGER,
    Code CHAR(6),
    CostCenterName VARCHAR(50),
    ParentCostCenterNo INTEGER,
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT,
    Inactive BIT
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mCostCenterMaster'
);

INSERT INTO masterdata.cost_center_master
(
    id,
    code,
    cost_center_name,
    parent_cost_center_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    alias
)
OVERRIDING SYSTEM VALUE
SELECT
    ccm.CostCenterNo,
    LEFT(TRIM(COALESCE(ccm.Code, '')), 6),
    LEFT(TRIM(COALESCE(ccm.CostCenterName, '')), 50),
    ccm.ParentCostCenterNo,
    COALESCE(ccm.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ccm.CreatedDate),
        now()
    ),
    COALESCE(ccm.ModifiedBy, ccm.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ccm.ModifiedDate),
        migration.parse_sqlserver_datetime(ccm.CreatedDate),
        now()
    ),
    CASE
        WHEN ccm.Inactive = B'1'
            THEN 2::smallint
        ELSE 1::smallint
    END,
    CASE
        WHEN ccm.Inactive = B'1'
            THEN 'inactive'
        ELSE NULL
    END,
    LEFT(TRIM(COALESCE(ccm.Code, '')), 15)
FROM sqlserver_fdw.mcostcentermaster ccm;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcostcentercompanydetail
(
    CostCenterCompanyDetailNo INTEGER,
    CostCenterNo INTEGER,
    CompanyNo INTEGER,
    DivisionNo INTEGER
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mCostCenterCompanyDetail'
);

INSERT INTO masterdata.cost_center_company_detail
(
    id,
    cost_center_id,
    company_id,
    division_id
)
OVERRIDING SYSTEM VALUE
SELECT
    cccd.CostCenterCompanyDetailNo,
    cccd.CostCenterNo,
    cccd.CompanyNo,
    cccd.DivisionNo
FROM sqlserver_fdw.mcostcentercompanydetail cccd;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



INSERT INTO masterdata.currency_master (
    code,
    currency_name,
    currency_notation,
    currency_symbol,
    subunit_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
VALUES (
    'INR',
    'Indian Rupee',
    'INR',
    '₹',
    'Paise',
    1,
    CURRENT_TIMESTAMP,
    1,
    CURRENT_TIMESTAMP,
    1,
    'Active'
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.mfyear
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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorbusinesstypemaster
(
    VendorBusinessTypeNo SMALLINT,
    VendorBusinessTypeName VARCHAR(50),
    Code CHAR(6),
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mVendorBusinessTypeMaster'
);

INSERT INTO masterdata.business_type_master
(
    id,
    business_type_name,
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
    VendorBusinessTypeNo,
    LEFT(
        TRIM(COALESCE(VendorBusinessTypeName, '')),
        100
    ) AS business_type_name,
    LEFT(
        TRIM(COALESCE(Code, '')),
        6
    ) AS code,
    COALESCE(CreatedBy, 1) AS created_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ) AS created_date,
    COALESCE(ModifiedBy, CreatedBy, 1) AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ) AS modified_date,
    1 as status_id,
    NULL AS status_remarks
FROM sqlserver_fdw.mvendorbusinesstypemaster;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mprioritymaster
(
    PriorityNo smallint,
    PriorityName varchar(100),
    Code char(6),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mPriorityMaster');

INSERT INTO masterdata.priority_master
(
    id,
    priority_name,
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
    p.PriorityNo,
    LEFT(TRIM(p.PriorityName), 100),
    LEFT(TRIM(p.Code), 6),
    COALESCE(p.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(p.CreatedDate),
        now()
    ),
    p.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(p.ModifiedDate),
        migration.parse_sqlserver_datetime(p.CreatedDate),
        now()
    ),
    1::smallint,
    NULL
FROM sqlserver_fdw.mprioritymaster p;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


create foreign table if not exists sqlserver_fdw.mcsreasonmaster
(
    CSReasonNo INTEGER,
    Reason VARCHAR(50),
    Code CHAR(6),
    CreatedBy smallint,
    CreatedDate TEXT,
    ModifiedBy smallint,
    ModifiedDate TEXT,
    Inactive BOOLEAN
)
server sqlserver_fdw
options
(
    schema_name 'masterdata',
    table_name 'mCSReasonMaster'
);

insert into masterdata.cs_reason_master
(
    id,
	reason_name,
	code,
	created_by_id,
	created_date,
	modified_by_id,
	modified_date,
	status_id,
	status_remarks
)
overriding system VALUE
select
	r.CSReasonNo,
	left(TRIM(coalesce(r.Reason, '')), 100),
	left(TRIM(coalesce(r.Code, '')), 6),
	coalesce(r.CreatedBy, 1),
	coalesce(
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
	r.ModifiedBy,
	coalesce(
        migration.parse_sqlserver_datetime(r.ModifiedDate),
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
	case
		when coalesce(r.Inactive, false)
            then 2::smallint
		else 1::smallint
	end,
	case
		when Inactive then 'inactive'
	end as status_remarks
from
	sqlserver_fdw.mcsreasonmaster r;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mregionmaster
(
    RegionNo smallint,
    RegionName varchar(50),
    Code char(6),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mRegionMaster');

INSERT INTO masterdata.region_master
(
    id,
    region_name,
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
    r.RegionNo,
    LEFT(TRIM(r.RegionName), 100),
    LEFT(TRIM(r.Code), 6),
    COALESCE(r.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
    r.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(r.ModifiedDate),
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
    1::smallint,
    NULL
FROM sqlserver_fdw.mregionmaster r;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



INSERT INTO masterdata.tax_group_master
(
    code,
    gb_tax_group_id,
    tax_group_name,
    tax_category_id,
    formula,
    seq_no,
    is_charge_on_order_applicable,
    is_charge_on_item_applicable,
    is_nature_perc_applicable,
    is_nature_amount_applicable,
    is_nature_unit_applicable,
    default_charge_on_id,
    default_nature_id,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
	modified_date
)
SELECT
    tg.code,
    tg.id,
    tg.tax_group_name,
    tg.tax_category_id,
    tg.formula,
    tg.seq_no,
    tg.is_charge_on_order_applicable,
    tg.is_charge_on_item_applicable,
    tg.is_nature_perc_applicable,
    tg.is_nature_amount_applicable,
    tg.is_nature_unit_applicable,
    tg.default_charge_on_id,
    tg.default_nature_id,
    1,
    NULL,
    1,
    NOW(),
	NOW()
FROM globaldata.tax_group tg
WHERE NOT EXISTS
(
    SELECT 1
    FROM masterdata.tax_group_master mt
    WHERE mt.gb_tax_group_id = tg.id
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



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
(103, 9, 'MC00103', 'Freight (Taxable)', 0.0000, 1, 'Freight', 1, NULL, 1, NOW(), NULL, NOW()),
(104, 7, 'MC00104', 'Other Charges (+)', 0.0000, 1, 'Other Charges', 1, NULL, 1, NOW(), NULL, NOW()),
(105, 15, 'MC00105', 'Loading/Unloading', 0.0000, 1, 'Loading/Unloading', 1, NULL, 1, NOW(), NULL, NOW());



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mtermsnconditionhead
(
    TermsNConditionHeadNo SMALLINT,
    Code CHAR(6),
    TermsNConditionHeadName VARCHAR(50),
    IsCompulsary BIT,
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT,
    ERPColumnName VARCHAR(20)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mTermsNConditionHead'
);

INSERT INTO masterdata.terms_n_condition_head_master
(
    id,
    code,
    tnc_head_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    is_compulsory,
    is_default
)
OVERRIDING SYSTEM VALUE
SELECT
    TermsNConditionHeadNo,
    LEFT(TRIM(COALESCE(Code, '')), 6),
    LEFT(TRIM(COALESCE(TermsNConditionHeadName, '')), 100),
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    1::smallint,
    NULL,
    CASE
        WHEN IsCompulsary = B'1' THEN TRUE
        ELSE FALSE
    END,
    FALSE
FROM sqlserver_fdw.mtermsnconditionhead;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mtermsnconditiongroup
(
    TermsNConditionGroupNo SMALLINT,
    Code CHAR(6),
    TermsNConditionGroupName VARCHAR(50),
    Inactive BIT,
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mTermsNConditionGroup'
);

INSERT INTO masterdata.terms_n_condition_group_master
(
    id,
    code,
    tnc_group_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    is_po_default,
    is_rfq_default
)
OVERRIDING SYSTEM VALUE
SELECT
    TermsNConditionGroupNo,
    LEFT(TRIM(COALESCE(Code, '')), 6),
    LEFT(TRIM(COALESCE(TermsNConditionGroupName, '')), 50),
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    CASE
        WHEN Inactive = B'1' THEN 2::smallint
        ELSE 1::smallint
    END,
    CASE
        WHEN Inactive = B'1' THEN 'inactive'
        ELSE NULL
    END,
    FALSE,
    FALSE
FROM sqlserver_fdw.mtermsnconditiongroup;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mtermsnconditiongroupdetail
(
    TermsNConditionGroupDetailNo INTEGER,
    TermsNConditionGroupNo SMALLINT,
    HeadNo SMALLINT,
    Value VARCHAR(100)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mTermsNConditionGroupDetail'
);

INSERT INTO masterdata.terms_n_condition_group_detail
(
    id,
    tnc_group_id,
    tnc_head_id,
    tnc_value
)
OVERRIDING SYSTEM VALUE
SELECT
    TermsNConditionGroupDetailNo,
    TermsNConditionGroupNo,
    HeadNo,
    LEFT(TRIM(COALESCE(Value, '')), 1000)
FROM sqlserver_fdw.mtermsnconditiongroupdetail;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendortypemaster
(
    VendorTypeNo    SMALLINT,
    Code            CHAR(6),
    VendorType      VARCHAR(30),
    CreatedBy       SMALLINT,
    CreatedDate     TEXT,
    ModifiedBy      SMALLINT,
    ModifiedDate    TEXT
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mVendorTypeMaster'
);


INSERT INTO masterdata.vendor_category
(
    id,
    code,
    vendor_category_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    v.VendorTypeNo,
    LEFT(TRIM(v.Code), 6),
    LEFT(TRIM(v.VendorType), 100),
    COALESCE(v.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(v.CreatedDate),
        now()
    ),
    COALESCE(v.ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(v.ModifiedDate),
        migration.parse_sqlserver_datetime(v.CreatedDate),
        now()
    ),
    1::smallint,
    NULL
FROM sqlserver_fdw.mvendortypemaster v;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.mduplicateitemgroup
(
    DItemGroupNo integer,
    Code varchar(8),
    GroupName varchar(600),
    InActive boolean,
    CreatedBy integer,
    CreatedDate text,
    ModifiedBy integer,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDuplicateItemGroup'
);

INSERT INTO utility.duplicate_item_group_main
(
    id,
    code,
    group_name,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    DItemGroupNo,
    TRIM(Code),
    TRIM(GroupName),
    CASE
        WHEN COALESCE(InActive, FALSE)
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
FROM sqlserver_fdw.mduplicateitemgroup;



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.logindeptdetail
(
    LoginDeptNo integer,
    LoginNo smallint,
    DeptNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Security',
    table_name 'LoginDeptDetail'
);

INSERT INTO security.user_master_department_detail
(
    id,
    user_id,
    department_id
)
OVERRIDING SYSTEM VALUE
SELECT
    d.LoginDeptNo,
    d.LoginNo,
    d.DeptNo
FROM sqlserver_fdw.logindeptdetail d
INNER JOIN security.user_master u
    ON u.id = d.LoginNo
INNER JOIN masterdata.department_master dm
    ON dm.id = d.DeptNo;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE sqlserver_fdw.logindivisiondetail
(
    LoginDivNo integer,
    LoginNo smallint,
    DivisionNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Security',
    table_name 'LoginDivisionDetail'
);

INSERT INTO security.user_master_division_detail
(
    id,
    user_id,
    division_id
)
OVERRIDING SYSTEM VALUE
SELECT
    d.LoginDivNo,
    d.LoginNo,
    d.DivisionNo
FROM sqlserver_fdw.logindivisiondetail d
INNER JOIN security.user_master u
    ON u.id = d.LoginNo
INNER JOIN masterdata.division_master dm
    ON dm.id = d.DivisionNo;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



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
FROM sqlserver_fdw.mlocationmaster;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO masterdata.doc_type_master
(
    code,
    doc_type_alias,
    doc_type_name,
    form_id,
    status_id,
    created_date,
    modified_date,
    created_by_id
)
values
(
    'DT0001',
    'PRG',
    'General Purchase Request',
    6,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0002',
    'CSG',
    'General Comparative Statement',
    8,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0003',
    'POG',
    'General Purchase Order',
    10,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0004',
    'RQG',
    'General Request For Quotation',
    7,
    1,
    Now(),
    Now(),
    1
),
(
	'DT0005', 
	'PRC', 
	'General PR Cancellation', 
	 97, 
	 1, 
	 Now(),
	 Now(),
	 1
),
(
	'DT0006', 
	'POC', 
	'General PO Cancellation', 
	 42, 
	 1, 
	 Now(),
	 Now(),
	 1
),
(
	'DT0007', 
	'AUG', 
	'General Auction', 
	 106, 
	 1, 
	 Now(),
	 Now(),
	 1
),
(
	'DT0008', 
	'RAG', 
	'General Auction RFQ', 
	 7, 
	 1, 
	 Now(),
	 Now(),
	 1
);



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO masterdata.doc_type_company_detail
(
    doc_type_id,
    company_id,
    division_id
)
SELECT
    dt.id,
    cm.id,
    dm.id
FROM masterdata.doc_type_master dt
CROSS JOIN masterdata.company_master cm
CROSS JOIN masterdata.division_master dm;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mrolemaster(
    companyno smallint,
    rolemasterno smallint,
    code character varying(12) COLLATE pg_catalog."default",
    rolename character varying(50) COLLATE pg_catalog."default",
    createdby smallint,
    createddate text COLLATE pg_catalog."default",
    modifiedby smallint,
    modifieddate text COLLATE pg_catalog."default"
)
    SERVER sqlserver_fdw
    OPTIONS (schema_name 'Security', table_name 'mRoleMaster');


INSERT INTO masterdata.role_master
(
    id,
    code,
    role_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    rm.RoleMasterNo AS id,
    LEFT(TRIM(rm.Code), 50),
    LEFT(TRIM(rm.RoleName), 200),
    COALESCE(rm.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(rm.CreatedDate),
        now()
    ),
    rm.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(rm.ModifiedDate),
        migration.parse_sqlserver_datetime(rm.CreatedDate),
        now()
    ),
    1::smallint,
    NULL
FROM sqlserver_fdw.mrolemaster rm
JOIN masterdata.company_master c
    ON c.id = rm.CompanyNo
WHERE c.head_office_id IS NULL;



--select rm.id ,rm2.rolemasterno ,c.id
--from masterdata.role_master RM
--inner join sqlserver_fdw.mrolemaster rm2 on rm2.code =rm.code 
--inner JOIN masterdata.company_master c   ON c.id = rm2.CompanyNo;

CREATE TABLE migration.role_mapping
(
    sql_role_id integer PRIMARY KEY,
    pg_role_id integer NOT NULL
);


INSERT INTO migration.role_mapping
(
    sql_role_id,
    pg_role_id
)
SELECT
    rm.RoleMasterNo,
    rm.RoleMasterNo
FROM sqlserver_fdw.mrolemaster rm
JOIN masterdata.company_master c
    ON c.id = rm.CompanyNo
WHERE c.head_office_id IS NULL;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.loginroledetail (
	loginroleno int4 NULL,
	loginno int2 NULL,
	rolemasterno int2 NULL
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'Security', table_name 'LoginRoleDetail');

INSERT INTO security.user_master_role_detail
(
    id,
    user_id,
    company_id,
    role_id
)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT
    rd.LoginRoleNo,
    rd.LoginNo,
    c.id,
    rm.id
FROM sqlserver_fdw.loginroledetail rd
INNER JOIN sqlserver_fdw.mrolemaster rm2
    ON rm2.RoleMasterNo = rd.RoleMasterNo
INNER JOIN masterdata.role_master rm
    ON rm.code = TRIM(rm2.Code)
INNER JOIN masterdata.company_master c
    ON c.id = rm2.CompanyNo;



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorlocationdetail
(
    VendorLocationNo INTEGER,
    VendorNo INTEGER,
    VendorTypeNo INTEGER,
    BusinessTypeNo INTEGER,
    Code CHAR(7),
    Address1 VARCHAR(100),
    Address2 VARCHAR(100),
    Address3 VARCHAR(100),
    CityNo INTEGER,
    StateNo SMALLINT,
    CountryNo SMALLINT,
    RegionNo SMALLINT,
    PhoneNo VARCHAR(50),
    Email VARCHAR(300),
    FullAddress VARCHAR(500),
    GSTRegistrationTypeNo smallint,
    GSTINNo VARCHAR(50),
    PANNo VARCHAR(30),
    IsMSME BOOLEAN,
    MSMERegNo VARCHAR(30),
    Pincode VARCHAR(6),
    WebSite VARCHAR(50),
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT,
    Inactive BOOLEAN
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mVendorLocationDetail'
);

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorcard
(
    VendorNo INTEGER,
    Code VARCHAR(7),
    VendorName VARCHAR(100),
    CreatedDate TEXT,
    ModifiedDate TEXT,
    MailingName VARCHAR(100),
    VendorTypeNo INTEGER,
    GVendorTypeNo INTEGER
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mVendorCard'
);

INSERT INTO security.supplier_account_master
(
    id,
    code,
    supplier_account_name,
    description,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    l.LoginNo AS id,
    LEFT(
        'SUP' || l.LoginNo::text,
        8
    ) AS code,
    LEFT(
        TRIM(vm.VendorName)
        || ' - '
        || vld.VendorLocationNo::text,
        150
    ) AS supplier_account_name,
    NULL AS description,
    1 AS created_by_id,
    now() AS created_date,
    1 AS modified_by_id,
    now() AS modified_date,
    1::smallint AS status_id,
    NULL AS status_remarks
FROM sqlserver_fdw.login l
JOIN
(
    SELECT DISTINCT ON (lvd.LoginNo)
        lvd.LoginNo,
        vld.VendorLocationNo,
        vm.VendorName
    FROM sqlserver_fdw.loginvendorlocationdetail lvd
    JOIN sqlserver_fdw.mvendorlocationdetail vld
        ON vld.VendorLocationNo = lvd.VendorLocationNo
    JOIN sqlserver_fdw.mvendorcard vm
        ON vm.VendorNo = vld.VendorNo
    ORDER BY
        lvd.LoginNo,
        lvd.VendorLocationNo
) x
    ON x.LoginNo = l.LoginNo
JOIN sqlserver_fdw.mvendorlocationdetail vld
    ON vld.VendorLocationNo = x.VendorLocationNo
JOIN sqlserver_fdw.mvendorcard vm
    ON vm.VendorNo = vld.VendorNo;


UPDATE security.user_master um
SET supplier_account_id = um.id
WHERE EXISTS
(
    SELECT 1
    FROM security.supplier_account_master sam
    WHERE sam.id = um.id
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


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




-----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE FOREIGN table if not exists sqlserver_fdw.msubgroupmaster
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

CREATE FOREIGN TABLE if not exists sqlserver_fdw.mitemmaster
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
    ModifiedDate text,
    FullCode varchar(10)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mItemMaster'
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


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



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
    im.fullCode,
	false,
	1
FROM sqlserver_fdw.mitemmaster im




-----------------------------------------------------------------------------------------------------------------------------------------------------------------


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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE FOREIGN TABLE if not exists sqlserver_fdw.mduplicateitemgroupdetail
(
    DupDetailNo integer,
    DItemGroupNo integer,
    ItemNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDuplicateItemGroupDetail'
);

INSERT INTO utility.duplicate_item_group_detail
(
    id,
    group_id,
    item_id
)
OVERRIDING SYSTEM VALUE
SELECT
    DupDetailNo,
    DItemGroupNo,
    ItemNo
FROM sqlserver_fdw.mduplicateitemgroupdetail;



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorcard
(
    VendorNo INTEGER,
    Code VARCHAR(7),
    VendorName VARCHAR(100),
    CreatedDate TEXT,
    ModifiedDate TEXT,
    MailingName VARCHAR(100),
    VendorTypeNo INTEGER,
    GVendorTypeNo INTEGER
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mVendorCard'
);

INSERT INTO masterdata.vendor_master
(
    id,
    code,
    vendor_name,
    legal_name,
    bp_type_id,
    rating,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    VendorNo,
    LEFT(
        TRIM(COALESCE(Code, '')),
        8
    ) AS code,
    LEFT(
        TRIM(COALESCE(VendorName, '')),
        150
    ) AS vendor_name,
    LEFT(
        TRIM(COALESCE(MailingName, '')),
        150
    ) AS legal_name,
    CASE WHEN gvendorTypeNo=6 THEN 1 ELSE 2 end,
    NULL AS rating,
    1 AS created_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ) AS created_date,
    1 AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ) AS modified_date
FROM sqlserver_fdw.mvendorcard;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.mvendorregistration
(
    VendorRegNo int,
    VendorName varchar(100),
    CreatedDate text,
    ModifiedDate text,
    StatusNo smallint,
    Code varchar(7),
    RejectionReason varchar(300)
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mVendorRegistration');


INSERT INTO masterdata.vendor_registration
(
    id,
    public_id,
    code,
    vendor_name,
    legal_name,
    vendor_id,
    bp_type_id,
    approval_setup_id,
    remarks,
    status_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    vr.VendorRegNo,
    gen_random_uuid(),
    LEFT(TRIM(vr.Code),8),
    LEFT(TRIM(vr.VendorName),150),
    LEFT(TRIM(vr.VendorName),150),
    NULL,
    1,
    NULL,
    LEFT(TRIM(COALESCE(vr.RejectionReason,'')),300),
    COALESCE(sm.new_status_id,1),
    COALESCE(
        migration.parse_sqlserver_datetime(vr.CreatedDate),
        now()
    ),
    1,
    COALESCE(
        migration.parse_sqlserver_datetime(vr.ModifiedDate),
        migration.parse_sqlserver_datetime(vr.CreatedDate),
        now()
    )
FROM sqlserver_fdw.mvendorregistration vr
LEFT JOIN migration.status_mapping sm
    ON sm.old_status_id = vr.StatusNo;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorlocationdetail
(
    VendorLocationNo INTEGER,
    VendorNo INTEGER,
    VendorTypeNo INTEGER,
    BusinessTypeNo INTEGER,
    Code CHAR(7),
    Address1 VARCHAR(100),
    Address2 VARCHAR(100),
    Address3 VARCHAR(100),
    CityNo INTEGER,
    StateNo SMALLINT,
    CountryNo SMALLINT,
    RegionNo SMALLINT,
    PhoneNo VARCHAR(50),
    Email VARCHAR(300),
    FullAddress VARCHAR(500),
    GSTRegistrationTypeNo smallint,
    GSTINNo VARCHAR(50),
    PANNo VARCHAR(30),
    IsMSME BOOLEAN,
    MSMERegNo VARCHAR(30),
    Pincode VARCHAR(6),
    WebSite VARCHAR(50),
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT,
    Inactive BOOLEAN
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mVendorLocationDetail'
);

INSERT INTO masterdata.vendor_master_location_detail
(
    id,
    code,
    address_line_1,
    address_line_2,
    address_line_3,
    business_description,
    business_type_id,
    city_id,
    contact_no,
    contact_no_country_id,
    country_id,
    created_by_id,
    created_date,
    email,
    full_address,
    gst_reg_type_id,
    gstin_no,
    modified_by_id,
    modified_date,
    msme_no,
    msme_type_id,
    pan_no,
    pincode,
    region_id,
    state_id,
    status_id,
    status_remarks,
    vendor_category_id,
    vendor_id,
    website
)
OVERRIDING SYSTEM VALUE
SELECT
    vld.VendorLocationNo,
    LEFT(TRIM(COALESCE(vld.Code, '')), 10),
    LEFT(TRIM(COALESCE(vld.Address1, '')), 100),
    LEFT(TRIM(COALESCE(vld.Address2, '')), 100),
    LEFT(TRIM(COALESCE(vld.Address3, '')), 100),
    NULL AS business_description,
    case when vld.BusinessTypeNo=0 then 20 else vld.BusinessTypeNo end,      -- if BusinessTypeNo=0, then 20 (other),else keep BusinessTypeNo
    vld.CityNo,
    CASE 
        WHEN NULLIF(TRIM(vld.PhoneNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(vld.PhoneNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(vld.PhoneNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    vld.CountryNo,
    COALESCE(vld.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(vld.CreatedDate),
        now()
    ),
    LEFT(TRIM(COALESCE(vld.Email, '')), 320),
    vld.FullAddress,
	COALESCE(vld.GSTRegistrationTypeNo, 7),
    LEFT(TRIM(COALESCE(vld.GSTINNo, '')), 15),
    COALESCE(vld.ModifiedBy, vld.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(vld.ModifiedDate),
        migration.parse_sqlserver_datetime(vld.CreatedDate),
        now()
    ),
    LEFT(TRIM(COALESCE(vld.MSMERegNo, '')), 16),
    CASE
    	when coalesce(vld.ismsme, FALSE)
    		then 1::smallint
    	else 2::smallint
    END,
    LEFT(TRIM(COALESCE(vld.PANNo, '')), 10),
    LEFT(TRIM(COALESCE(vld.Pincode, '')), 10),
    case when vld.RegionNo=0 then Null else vld.RegionNo end,
    vld.StateNo,
    CASE
        WHEN COALESCE(vld.Inactive, FALSE)
            THEN 2::smallint
        ELSE 1::smallint
    END,
    NULL AS status_remarks,
    case
	    when vld.VendorTypeNo=0 then NULL
	    else vld.VendorTypeNo
	end,
    vld.VendorNo,
    LEFT(TRIM(COALESCE(vld.WebSite, '')), 50)
FROM sqlserver_fdw.mvendorlocationdetail vld;



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.mvendorregistrationlocationdetail
(
    VendorRegLocationNo int,
    Code char(7),
    VendorRegNo int,
    VendorName varchar(100),
    MailingName varchar(100),
    Address1 varchar(100),
    Address2 varchar(100),
    Address3 varchar(100),
    CityNo int,
    StateNo smallint,
    CountryNo smallint,
    Pincode varchar(6),
    FullAddress varchar(500),
    PhoneNo varchar(50),
    FaxNo varchar(50),
    Email varchar(300),
    Website varchar(50),
    RegionNo smallint,
    CreatedDate text,
    ModifiedDate text,
    CINNo varchar(30),
    CSTNo varchar(30),
    TINNo varchar(30),
    ECCCode varchar(30),
    PANNo varchar(30),
    VendorTypeNo smallint,
    BusinessTypeNo smallint,
    ManufacturingTypeNo smallint,
    GSTRegistrationTypeNo smallint,
    GSTINNo varchar(50),
    MobileNo varchar(54),
    IsMSME bit,
    MSMERegNo varchar(30)
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mVendorRegistrationLocationDetail');



INSERT INTO masterdata.vendor_reg_location_detail
(
    id,
    vendor_reg_id,
    code,
    address_line1,
    address_line2,
    address_line3,
    contact_no,
    contact_no_country_id,
    email,
    website,
    country_id,
    state_id,
    city_id,
    pincode,
    vendor_category_id,
    pan_no,
    gst_reg_type_id,
    gstin_no,
    region_id,
    business_type_id,
    msme_type_id,
    msme_no,
    full_address,
    created_date,
    modified_by_id,
    modified_date,
    business_description
)
OVERRIDING SYSTEM VALUE
SELECT
    l.VendorRegLocationNo,
    l.VendorRegNo,
    LEFT(TRIM(l.Code),8),
    LEFT(TRIM(COALESCE(l.Address1,'')),100),
    LEFT(TRIM(COALESCE(l.Address2,'')),100),
    LEFT(TRIM(COALESCE(l.Address3,'')),100),
    CASE 
        WHEN COALESCE(NULLIF(TRIM(l.PhoneNo), ''), NULLIF(TRIM(l.MobileNo), '')) IS NOT NULL 
        THEN '+91' || LEFT(COALESCE(NULLIF(TRIM(l.PhoneNo), ''), NULLIF(TRIM(l.MobileNo), '')), 12)
        ELSE NULL 
    END,
    CASE
        WHEN COALESCE(NULLIF(TRIM(l.PhoneNo), ''), NULLIF(TRIM(l.MobileNo), '')) IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    LEFT(TRIM(COALESCE(l.Email,'')),320),
    LEFT(TRIM(COALESCE(l.Website,'')),50),
    l.CountryNo,
    l.StateNo,
    l.CityNo,
    LEFT(TRIM(COALESCE(l.Pincode,'')),10),
    case
	    when coalesce(l.VendorTypeNo,0)=0 then Null
	    else l.VendorTypeNo
	end,
    LEFT(TRIM(COALESCE(l.PANNo,'')),10),
    COALESCE(l.GSTRegistrationTypeNo,7),
    LEFT(TRIM(COALESCE(l.GSTINNo,'')),15),
    case when coalesce(l.RegionNo,0)=0 then 1 else l.RegionNo end,
    case when coalesce(l.BusinessTypeNo,0)=0 then 20 else l.BusinessTypeNo end,
    CASE
        WHEN l.IsMSME = B'1' THEN 1
        WHEN l.IsMSME = B'0' THEN 2
        ELSE 3
    END,
    LEFT(TRIM(COALESCE(l.MSMERegNo,'')),16),
    LEFT(TRIM(COALESCE(l.FullAddress,'')),500),
    COALESCE(
        migration.parse_sqlserver_datetime(l.CreatedDate),
        now()
    ),
    1,
    COALESCE(
        migration.parse_sqlserver_datetime(l.ModifiedDate),
        migration.parse_sqlserver_datetime(l.CreatedDate),
        now()
    ),
    ''
FROM sqlserver_fdw.mvendorregistrationlocationdetail l;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.mvendorlocationbankdetail
(
    BankDetailNo int,
    VendorLocationNo int,
    BankName varchar(100),
    BranchName varchar(100),
    IFSCCode varchar(25),
    AccountNumber varchar(30),
    BankAccountTypeNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mVendorLocationBankDetail'
);


INSERT INTO masterdata.vendor_location_bank_detail
(
    id,
    vendor_location_id,
    bank_name,
    branch_name,
    ifsc_code,
    account_name,
    account_no,
    bank_account_type_id,
    swift_code
)
OVERRIDING SYSTEM VALUE
SELECT
    b.BankDetailNo,
    b.VendorLocationNo,
    LEFT(TRIM(COALESCE(b.BankName,'')),150),
    LEFT(TRIM(COALESCE(b.BranchName,'')),150),
    LEFT(TRIM(COALESCE(b.IFSCCode,'')),11),
    '.',
    LEFT(TRIM(COALESCE(b.AccountNumber,'')),20),
    b.BankAccountTypeNo,
    NULL
FROM sqlserver_fdw.mvendorlocationbankdetail b;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorlocationcontactdetail
(
    VendorContactNo INTEGER,
    VendorLocationNo INTEGER,
    ContactPersonName VARCHAR(100),
    Designation VARCHAR(100),
    PhoneNo VARCHAR(50),
    Email VARCHAR(300),
    Inactive BIT
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mVendorLocationContactDetail'
);

INSERT INTO masterdata.vendor_location_contact_person_detail
(
    id,
    vendor_location_id,
    contact_person_name,
    designation,
    contact_no,
    contact_no_country_id,
    email,
    remarks,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    VendorContactNo,
    VendorLocationNo,
    LEFT(
        TRIM(COALESCE(ContactPersonName, '')),
        100
    ) AS contact_person_name,
    LEFT(
        TRIM(COALESCE(Designation, '')),
        50
    ) AS designation,
    CASE 
        WHEN NULLIF(TRIM(PhoneNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(PhoneNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(PhoneNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    LEFT(
        TRIM(COALESCE(Email, '')),
        320
    ) AS email,
    NULL AS remarks,
    CASE
        WHEN Inactive = B'1'
            THEN 2::smallint
        ELSE 1::smallint
    END AS status_id,
	'remarks' as status_remarks
FROM sqlserver_fdw.mvendorlocationcontactdetail;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.mvendoritemgroupdetail
(
    VendorItemGroupNo int,
    VendorNo int,
    GroupNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mVendorItemGroupDetail'
);


INSERT INTO masterdata.vendor_location_item_group_detail
(
    id,
    vendor_location_id,
    item_group_id
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            g.VendorItemGroupNo,
            vl.id
    ) AS id,
    vl.id,
    g.GroupNo
select count(*) FROM sqlserver_fdw.mvendoritemgroupdetail g
INNER JOIN masterdata.vendor_master_location_detail vl
    ON vl.vendor_id = g.VendorNo;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.mvendorregistrationbankdetail
(
    BankDetailNo int,
    VendorRegLocationNo int,
    BankName varchar(100),
    BranchName varchar(100),
    IFSCCode varchar(25),
    AccountNumber varchar(30),
    BankAccountTypeNo smallint
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mVendorRegistrationBankDetail');

INSERT INTO masterdata.vendor_reg_location_bank_detail
(
    id,
    vendor_reg_location_id,
    bank_name,
    branch_name,
    ifsc_code,
    account_name,
    account_no,
    bank_account_type_id,
    swift_code
)
OVERRIDING SYSTEM VALUE
SELECT
    b.BankDetailNo,
    b.VendorRegLocationNo,
    LEFT(TRIM(b.BankName),150),
    LEFT(TRIM(b.BranchName),150),
    LEFT(TRIM(COALESCE(b.IFSCCode,'')),11),
    '.' as account_name,
    LEFT(TRIM(COALESCE(b.AccountNumber,'')),20),
    b.BankAccountTypeNo,
    NULL
FROM sqlserver_fdw.mvendorregistrationbankdetail b


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.mvendorregistrationcontactdetail
(
    VendorRegContactNo int,
    VendorRegLocationNo int,
    VendorRegNo int,
    Code char(7),
    ContactPersonName varchar(100),
    Designation varchar(100),
    PhoneNo varchar(50),
    Email varchar(300),
    CreatedDate text
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mVendorRegistrationContactDetail');


INSERT INTO masterdata.vendor_reg_location_contact_person_detail
(
    id,
    vendor_reg_location_id,
    contact_person_name,
    designation,
    contact_no,
    contact_no_country_id,
    email,
    remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    c.VendorRegContactNo,
    c.VendorRegLocationNo,
    LEFT(TRIM(c.ContactPersonName),100),
    LEFT(TRIM(COALESCE(c.Designation,'')),50),
    CASE 
        WHEN NULLIF(TRIM(c.PhoneNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(c.PhoneNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(c.PhoneNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    LEFT(TRIM(COALESCE(c.Email,'')),320),
    NULL
FROM sqlserver_fdw.mvendorregistrationcontactdetail c;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.mvendorregistrationgroupdetail
(
    VendorRegGroupNo int,
    VendorRegNo int,
    GroupNo smallint
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mVendorRegistrationGroupDetail');


INSERT INTO masterdata.vendor_reg_location_item_group_detail
(
    vendor_reg_location_id,
    item_group_id
)
SELECT DISTINCT
    l.id,
    g.GroupNo
FROM sqlserver_fdw.mvendorregistrationgroupdetail g
INNER JOIN masterdata.vendor_reg_location_detail l
    ON l.vendor_reg_id = g.VendorRegNo;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE FOREIGN table if not exists sqlserver_fdw.mauthorizationgroup
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

CREATE FOREIGN TABLE if not exists sqlserver_fdw.mauthorizationgroupdetail
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

CREATE FOREIGN table if not exists sqlserver_fdw.mauthgrprevisioncompanydetail
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

CREATE FOREIGN TABLE if not exists sqlserver_fdw.mauthgrprevisiondivdeptdetail
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

-- Step 1: move the existing values out of the way
UPDATE masterdata.approval_setup_master
SET main_approval_id = null
WHERE id IN (
    SELECT AuthGrpRevisionNo
    FROM sqlserver_fdw.mauthorizationgroup
);

-- Step 2: apply the correct source mapping
UPDATE masterdata.approval_setup_master qm
SET
    main_approval_id = x.main_approval_id,
    revision_no = x.revision_no
FROM (
    SELECT
        r.AuthGrpRevisionNo AS approval_id,
        r.RevisionNo AS revision_no,
        qf.AuthGrpRevisionNo AS main_approval_id
    FROM sqlserver_fdw.mauthorizationgroup r
    INNER JOIN (
        SELECT
            AuthGrpRevisionNo,
            AuthorizationGroupNo,
            ROW_NUMBER() OVER (
                PARTITION BY AuthorizationGroupNo
                ORDER BY RevisionNo, AuthGrpRevisionNo
            ) AS rn
        FROM sqlserver_fdw.mauthorizationgroup
    ) qf
        ON qf.AuthorizationGroupNo = r.AuthorizationGroupNo
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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.loginwhitelistip
(
    loginwhitelistipno smallint,
    loginno integer,
    fromipaddress varchar(100),
    toipaddress varchar(100)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Security',
    table_name 'LoginWhiteListIP'
);

INSERT INTO utility.whitelist_ip_main
(
    id,
    code,
    from_ip_address,
    to_ip_address,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    lwip.loginwhitelistipno,
    LPAD(lwip.loginwhitelistipno::text, 6, '0'),
    LEFT(TRIM(COALESCE(lwip.fromipaddress, '')), 45),
    NULLIF(LEFT(TRIM(COALESCE(lwip.toipaddress, '')), 45), ''),
    1,
    NOW(),
    1,
    NOW()
FROM sqlserver_fdw.loginwhitelistip lwip
where lwip.loginNo is not null;

INSERT INTO utility.whitelist_ip_detail
(
    id,
    white_list_ip_id,
    user_id
)
OVERRIDING SYSTEM VALUE
SELECT
    lwip.loginwhitelistipno,
    lwip.loginwhitelistipno,
    lwip.loginno
FROM sqlserver_fdw.loginwhitelistip lwip
where lwip.loginNo is not null;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO security.supplier_account_vendor_location_detail
(
    supplier_account_id,
    vendor_location_id
)
SELECT
    LoginNo AS supplier_account_id,
    VendorLocationNo AS vendor_location_id
FROM sqlserver_fdw.loginvendorlocationdetail;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN table if not exists sqlserver_fdw.formMaster
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

create foreign table if not exists sqlserver_fdw.documentserial
(
    DocumentSerialNo integer,
    FormCode varchar(50),
    YearNo smallint,
    Series varchar(2),
    SeriesType varchar(3),
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
    LEFT(NULLIF(TRIM(ds.SeriesType), ''), 1),
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
    ON f.FormNo = fm.old_form_id
where fm.new_form_id = 6 or fm.new_form_id=10;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------TRANSACTIONS START---------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE FOREIGN TABLE if not exists sqlserver_fdw.indentmain
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
    1,
    COALESCE(NULLIF(TRIM(im.PortalDocumentNoYearly), ''), TRIM(im.DocumentNoYearly)),
    COALESCE(
        migration.parse_sqlserver_datetime(im.DocumentDate)::date,
        CURRENT_DATE
    ),
    NULL,
    TRIM(im.DocumentNoYearly),
    CASE
        WHEN im.isreadyforauthorization = true
             AND im.documentstatusno = 10
        THEN 20
        ELSE im.documentstatusno
    END,
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
    case when im.modifiedBy=0 then null else im.modifiedBy end,
    COALESCE(
        migration.parse_sqlserver_datetime(im.ModifiedDate),
        migration.parse_sqlserver_datetime(im.CreatedDate),
        now()
    ),
    case when im.authorizedBy=0 then 1 else im.authorizedBy end,
    migration.parse_sqlserver_datetime(im.AuthorizedDate),
    TRUE
FROM sqlserver_fdw.indentmain im
INNER JOIN migration.status_mapping sm
    ON sm.old_status_id = im.StatusNo;


---- Item Detail ----
CREATE FOREIGN table if not exists sqlserver_fdw.indentitemdetail
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
    ItemLineNo              numeric(12,3),
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




-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists sqlserver_fdw.changeindentstatusmain
(
    companyno smallint,
    yearno smallint,
    changeindentstatusno integer,
    divisionno integer,
    documentnoyearly varchar(30),
    documentdate text,
    indentno integer,
    statusno smallint,
    reason varchar(1000),
    createdby smallint,
    createddate text,
    modifiedby smallint,
    modifieddate text,
    authorizedby smallint,
    authorizeddate text,
    documentstatusno smallint,
    isinserted integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'ChangeIndentStatusMain'
);


insert into utility.purchase_request_cancellation_main (
	id,
	pr_id,
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
	authorized_date
)
overriding system VALUE
select
	changeindentstatusno as id,
	prc.indentNo as pr_id,
	prc.documentnoyearly as doc_no_yearly,
	migration.parse_sqlserver_datetime(prc.documentdate) as doc_date,
	5 as doc_type_id,
	prc.divisionno as division_id,
	null,
	prc.documentstatusno,
	prc.companyno as company_id,
	prc.yearno as fy_id,
	prc.reason as remarks,
	prc.createdby,
	migration.parse_sqlserver_datetime(prc.createddate),
	prc.modifiedby,
	coalesce(migration.parse_sqlserver_datetime(prc.modifieddate), migration.parse_sqlserver_datetime(prc.createddate)),
	prc.authorizedby,
	migration.parse_sqlserver_datetime(prc.authorizeddate)
from
	sqlserver_fdw.ChangeIndentStatusMain prc;



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


-----------------------------------------------------------------------------------------------------------------------------------------------------------------



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
    case when rfq.createdBy=0 then 1 else coalesce(rfq.createdBy,1) end,
    COALESCE(
        migration.parse_sqlserver_datetime(rfq.CreatedDate),
        now()
    ),
    case when rfq.modifiedBy=0 then null else rfq.modifiedBy end,
    COALESCE(
        migration.parse_sqlserver_datetime(rfq.ModifiedDate),
        migration.parse_sqlserver_datetime(rfq.CreatedDate),
        now()
    ),
     case when rfq.authorizedBy=0 then 1 else rfq.authorizedBy end,
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


--- Rfq Item Detail line No Update ---
UPDATE purchase.pur_rfq_item_detail t
SET line_no  = x.new_line_no
FROM (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY rfq_id
            ORDER BY id
        ) AS new_line_no
    FROM purchase.pur_rfq_item_detail
) x
WHERE t.id = x.id;


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
   AND prid.item_id = rid.ItemNo;

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



INSERT INTO purchase.pur_rfq_vendor_contact_person_detail
(
    id,
    rfq_id,
    rfq_vendor_detail_id,
    vendor_location_contact_person_id,
    contact_name,
    contact_email,
    contact_no,
    contact_no_country_id
)
OVERRIDING SYSTEM VALUE
SELECT
    rvd.RFQVendorDetailNo,
    rvd.RFQNo,
    rvd.RFQVendorDetailNo,
    rvd.VendorContactNo,
    vcp.contact_person_name,
    vcp.email,
    CASE 
        WHEN NULLIF(TRIM(vcp.contact_no), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(vcp.Contact_No), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(vcp.contact_no), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END
FROM sqlserver_fdw.rfqvendordetail rvd
LEFT JOIN masterdata.vendor_location_contact_person_detail vcp
    ON vcp.id = rvd.VendorContactNo;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


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


----- TO Update rfq_id and rfq_vendor_detail_id with generated rfq
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
    authorized_date,
    is_auction
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
    false,
    1,
    LEFT(TRIM(COALESCE(rqm.DocumentNoYearly,'')),20),
    migration.parse_sqlserver_datetime(rqm.DocumentDate),
    rqm.DocumentStatusNo,
    rqm.CompanyNo,
    rqm.YearNo,
    LEFT(TRIM(COALESCE(rqm.Remarks,'')),1000),
    case when rqm.createdBy=0 then 1 else coalesce(rqm.createdBy,1) end,
    COALESCE(
        migration.parse_sqlserver_datetime(rqm.CreatedDate),
        now()
    ),
    case when rqm.modifiedBy=0 then null else rqm.modifiedBy end,
    COALESCE(
        migration.parse_sqlserver_datetime(rqm.ModifiedDate),
        migration.parse_sqlserver_datetime(rqm.CreatedDate),
        now()
    ),
    case when rqm.authorizedBy=0 then 1 else rqm.authorizedBy end,
    migration.parse_sqlserver_datetime(rqm.AuthorizedDate),
    case when rqm.auctionNo is not null then true else false end
FROM sqlserver_fdw.revisedquotationmain rqm
LEFT JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = rqm.RFQNo
   AND rvd.vendor_location_id = rqm.VendorLocationNo;
--where rvd.id is null and rqm.rfqNo is not null

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

--update purchase.quotation_main qm 
--set qm.is_current=true
--where qm.revision_no =0

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

--INSERT INTO purchase.pur_rfq_vendor_detail
--(
--    rfq_id,
--    public_id,
--    is_guest_vendor,
--    user_id,
--    vendor_location_id,
--    guest_vendor_email,
--    guest_vendor_name,
--    quotation_status_id,
--    created_by_id,
--    created_date,
--    last_mail_sent_on
--)
--SELECT
--    rqm.rfqno,
--    gen_random_uuid(),
--    false,
--    NULL,
--    rqm.vendorlocationno,
--    NULL,
--    NULL,
--    NULL,
--    NULL,
--    NULL,
--    NULL
--FROM purchase.quotation_main qm
--INNER JOIN sqlserver_fdw.revisedquotationmain rqm
--    ON rqm.revisedquotationno = qm.id
--LEFT JOIN purchase.pur_rfq_vendor_detail rvd
--    ON rvd.rfq_id = rqm.rfqno
--   AND rvd.vendor_location_id = rqm.vendorlocationno
--WHERE qm.is_auction = false
--  AND qm.rfq_vendor_detail_id IS NULL
--  AND rvd.id IS NULL;

--- Update missing rfq_vendor_detail_id in quotation_main
--UPDATE purchase.quotation_main qm
--SET rfq_vendor_detail_id = rvd.id
--FROM sqlserver_fdw.revisedquotationmain rqm
--INNER JOIN purchase.pur_rfq_vendor_detail rvd
--    ON rvd.rfq_id = rqm.rfqno
--   AND rvd.vendor_location_id = rqm.vendorlocationno
--WHERE rqm.revisedquotationno = qm.id
--  AND qm.is_auction = false
--  AND qm.rfq_vendor_detail_id IS NULL;


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
    COALESCE(rfqi.id,null),
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
from sqlserver_fdw.revisedquotationitemdetail rqid
INNER JOIN sqlserver_fdw.revisedQuotationMain qm
    ON qm.RevisedQuotationNo = rqid.RevisedQuotationNo
left JOIN purchase.pur_rfq_item_detail rfqi
    ON rfqi.rfq_id = qm.rfqNo
    and rfqi.item_id = rqid.itemNo
    and coalesce(rfqi.make_id,0) = coalesce(rqid.rfqmakeNo,0);
--where rfqi.rfq_id is null;
-- where rfqi.rfq_id is null and qm.auctionNo is null;

 
WITH cte AS
(
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY quotation_id
            ORDER BY id
        ) AS new_line_no
    FROM purchase.quotation_item_detail
)
UPDATE purchase.quotation_item_detail qid
SET line_no = cte.new_line_no
FROM cte
WHERE qid.id = cte.id;


--inner join purchase.quotation_item_detail qid 
--on qid.id = r.revisedQuotationItemNo
--where r.itemno <> qid.item_id 


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
        WHEn 2 THEN 1
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
left JOIN purchase.quotation_item_detail qid
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
from sqlserver_fdw.revisedquotationitemotherchargedetail qiocd
INNER JOIN purchase.quotation_item_detail qid
    ON qid.quotation_id = qiocd.RevisedQuotationNo
    AND qid.item_id = qiocd.ItemNo
    AND COALESCE(qid.make_id,0) = COALESCE(qiocd.MakeNo,0)
WHERE EXISTS (
    SELECT 1 FROM purchase.quotation_main qm WHERE qm.id = qiocd.RevisedQuotationNo
) AND qiocd.amount > 0;


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.revisedquotationtermsnconditiondetail
(
    RevisedQuotationTermsDetailNo INTEGER,
    RevisedQuotationNo INTEGER,
    TermsNConditionHeadNo INTEGER,
    TermsNCondition VARCHAR(300)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'RevisedQuotationTermsNConditionDetail'
);

INSERT INTO purchase.quotation_terms_condition_detail
(
    id,
    quotation_id,
    tnc_head_id,
    tnc_value
)
OVERRIDING SYSTEM VALUE
SELECT
    t.RevisedQuotationTermsDetailNo,
    t.RevisedQuotationNo,
    t.TermsNConditionHeadNo,
    LEFT(
        TRIM(COALESCE(t.TermsNCondition, '')),
        300
    )
FROM sqlserver_fdw.revisedquotationtermsnconditiondetail t
INNER JOIN purchase.quotation_main q
    ON q.id = t.RevisedQuotationNo;


CREATE FOREIGN table if not exists sqlserver_fdw.quotationcompanydetail
(
    QuotationNo int,
    CompanyNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'QuotationCompanyDetail'
);

INSERT INTO purchase.quotation_company_detail
(
    quotation_id,
    company_id
)
SELECT
    rqm.revisedquotationno ,
    qcd.CompanyNo
FROM sqlserver_fdw.quotationcompanydetail qcd
inner join sqlserver_fdw.revisedquotationmain rqm
on qcd.QuotationNo =rqm.quotationno;


INSERT INTO purchase.quotation_summary
(
    main_quotation_id,
    current_revision_no,
    authorized_revision_no
)
SELECT
    qm.main_quotation_id,
    MAX(qm.revision_no) AS current_revision_no,
    MAX(
        CASE
            WHEN qm.document_status_id = 30
                THEN qm.revision_no
        END
    ) AS authorized_revision_no
FROM purchase.quotation_main qm
GROUP BY
    qm.main_quotation_id;


--- discounts and taxes

-- Update
UPDATE purchase.quotation_item_detail qid
SET
    discount_amount = qit.amount,
    discount_per_qty = ROUND(qit.amount / NULLIF(qid.qty, 0), 2),
    discount_rate = ROUND(
        100 * qit.amount / NULLIF(qid.basic_amount, 0),
        2
    ),
    rate_after_discount = ROUND(
        qid.rate - (qit.amount / NULLIF(qid.qty, 0)),
        2
    )
FROM purchase.quotation_item_tax_detail qit
WHERE qid.id = qit.quotation_item_detail_id
  AND qit.tax_id = 8;


-----
-- add missing taxes in item tax detail
WITH MissingTaxes AS
(
    SELECT
        qtd.quotation_id,
        qtd.tax_id,
        qtd.amount AS quotation_tax_amount,
        qtd.nature_id,
        qtd.charge_type_id,
        qtd.charge_on_id,
        qtd.charge_value
    FROM purchase.quotation_tax_detail qtd
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM purchase.quotation_item_tax_detail qit
        WHERE qit.quotation_id = qtd.quotation_id
          AND qit.tax_id = qtd.tax_id
    )
),
ItemAllocation AS
(
    SELECT
        mt.quotation_id,
        mt.tax_id,
        mt.quotation_tax_amount,
        mt.nature_id,
        mt.charge_type_id,
        mt.charge_on_id,
        mt.charge_value,
        qid.id AS quotation_item_detail_id,
        qid.basic_amount,
        SUM(
            CASE
                WHEN qid.basic_amount > 0
                    THEN qid.basic_amount
                ELSE 0
            END
        ) OVER (
            PARTITION BY mt.quotation_id, mt.tax_id
        ) AS total_positive_basic_amount,
        ROW_NUMBER() OVER (
            PARTITION BY mt.quotation_id, mt.tax_id
            ORDER BY qid.id
        ) AS item_rn,
        MIN(
            CASE
                WHEN qid.basic_amount > 0 THEN qid.id
            END
        ) OVER (
            PARTITION BY mt.quotation_id, mt.tax_id
        ) AS first_positive_item_id
    FROM MissingTaxes mt
    INNER JOIN purchase.quotation_item_detail qid
        ON qid.quotation_id = mt.quotation_id
),
CalculatedAllocation AS
(
    SELECT
        *,
        ROUND(
            CASE
                WHEN basic_amount > 0
                 AND total_positive_basic_amount > 0
                THEN quotation_tax_amount
                     * basic_amount
                     / total_positive_basic_amount
                ELSE 0
            END,
            2
        ) AS calculated_amount
    FROM ItemAllocation
),
FinalAllocation AS
(
    SELECT
        *,
        SUM(calculated_amount) OVER (
            PARTITION BY quotation_id, tax_id
        ) AS calculated_total
    FROM CalculatedAllocation
)
INSERT INTO purchase.quotation_item_tax_detail
(
    quotation_id,
    quotation_item_detail_id,
    tax_id,
    nature_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount
)
SELECT
    quotation_id,
    quotation_item_detail_id,
    tax_id,
    nature_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    CASE
        WHEN basic_amount = 0 THEN 0
        WHEN total_positive_basic_amount = 0 THEN 0
        WHEN quotation_item_detail_id = first_positive_item_id THEN
            calculated_amount
            + (quotation_tax_amount - calculated_total)
        ELSE
            calculated_amount
    END AS amount
FROM FinalAllocation;


--- Discount amount update in QuotationMain
UPDATE purchase.quotation_main qm
SET discount_amount = sub.total_discount
FROM (
    SELECT quotation_id, SUM(discount_amount) AS total_discount
    FROM purchase.quotation_item_detail
    GROUP BY quotation_id
) sub
WHERE qm.id = sub.quotation_id;

--- Tax Amount update in QuotationMain
update purchase.quotation_main
set tax_amount = net_amount - basic_amount




-----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE FOREIGN table if not exists sqlserver_fdw.csmain
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
    2,
    TRIM(cs.DocumentNoYearly),
    COALESCE(
        migration.parse_sqlserver_datetime(cs.DocumentDate)::date,
        CURRENT_DATE
    ),
    NULL,
    CASE
        WHEN cs.isreadyforauthorization = true
             AND cs.documentstatusno = 10
        THEN 20
        ELSE cs.documentstatusno
    END,
    case
    	WHEN cs.RefCSNo IS NOT NULL THEN 8
    	when cs.auctionNo is not null then 12
	    ELSE 7
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
    case when cs.createdBy=0 then 1 else coalesce(cs.createdBy,1) end,
    COALESCE(
        migration.parse_sqlserver_datetime(cs.CreatedDate),
        NOW()
    ),
    case when cs.modifiedBy=0 then null else cs.modifiedBy end,
    COALESCE(
    migration.parse_sqlserver_datetime(cs.ModifiedDate),
    migration.parse_sqlserver_datetime(cs.CreatedDate),
    NOW()
    ),
     case when cs.authorizedBy=0 then 1 else cs.authorizedBy end,
    migration.parse_sqlserver_datetime(cs.AuthorizedDate)
FROM sqlserver_fdw.csmain cs;

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
ON csm.csNo = ccd.csNo;


----- Quotation Participation Detail -----
CREATE FOREIGN table if not exists sqlserver_fdw.csquotationdetail
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
ON csm.csNo = cqd.csNo;


----CS Quotation Detail------
insert
	into
	purchase.cs_quotation_detail
(
    id,
	cs_id,
	quotation_id,
	quotation_item_detail_id,
	qty
)
overriding system VALUE
select
	cqd.QQuotationNo as id,
	cqd.CSNo as cs_id,
	cqd.RevisedQuotationNo as quotation_id,
	case
		when cqd.itemNo is not null then qid.id
		else null
	end as quotation_item_detail_id,
	case
		when cqd.itemNo is not null then cqd.Quantity
		else null
	end as qty
from
	sqlserver_fdw.csquotationdetail cqd
left join purchase.quotation_item_detail qid
    on
	qid.item_id = cqd.itemNo
	and coalesce(cqd.makeNo, 0) = coalesce(qid.rfq_make_id, 0)
	and qid.quotation_id = cqd.RevisedQuotationNo
where
	cqd.isSelected is true
	and cqd.RevisedQuotationNo is not null
	and exists (
	select
		1
	from
		purchase.quotation_main q
	where
		q.id = cqd.RevisedQuotationNo
  );



----- CS Pr Detail -----
CREATE FOREIGN TABLE if not exists sqlserver_fdw.csindentdetail
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
select count(1) FROM sql_migration.csindentdetail cid
INNER JOIN sql_migration.csmain csm
    ON csm.csNo = cid.CSNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cid.IndentNo
    AND prid.line_no = cid.IndentItemLineNo
inner JOIN purchase.quotation_item_detail qid
    ON qid.item_id = cid.ItemNo
    AND COALESCE(qid.rfq_make_id,0) = COALESCE(cid.MakeNo,0)
    AND qid.quotation_id = cid.RevisedQuotationNo
where qid.id is null and cid.itemNo is not null
WHERE cid.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = cid.RevisedQuotationNo
  );


---- CS Reason Detail -----

CREATE FOREIGN TABLE if not exists sqlserver_fdw.csreasondetail
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


CREATE FOREIGN TABLE if not exists sqlserver_fdw.csl1detail
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



-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------


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


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.poamendmentitemdetail
(
    POAmendmentItemDetailNo INTEGER,
    POAmendmentNo INTEGER,
    POItemLineNo SMALLINT,
    ItemNo INTEGER,
    MakeNo SMALLINT,
    TechSpecification VARCHAR(1000),
    Quantity NUMERIC(10,3),
    UnitNo SMALLINT,
    Rate NUMERIC(19,4),
    BasicAmount NUMERIC(19,4),
    NetAmount NUMERIC(19,4),
    Remark VARCHAR(500),
    StatusNo SMALLINT,
    ToleranceBasisNo SMALLINT,
    TolerancePlus NUMERIC(12,3),
    ToleranceMinus NUMERIC(12,3),
    CostCenterNo INTEGER,
    HSNSACCode VARCHAR(8),
    CSNo INTEGER,
    ERPItemCode VARCHAR(50)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'POAmendmentItemDetail'
);

INSERT INTO purchase.purchase_order_item_detail
(
    id,
    line_no,
    po_id,
    item_id,
    hsn_code,
    make_id,
    tech_specification,
    unit_id,
    cs_quotation_detail_id,
    quotation_item_detail_id,
    qty,
    rate,
    basic_amount,
    tax_amount,
    net_amount,
    cost_center_id,
    tolerance_type,
    tolerance_plus,
    tolerance_minus,
    remarks,
    status_id,
    discount_amount,
    discount_per_qty,
    discount_rate,
    rate_after_discount
)
OVERRIDING SYSTEM VALUE
SELECT
    poid.POAmendmentItemDetailNo,
    10,
    poid.POAmendmentNo,
    poid.ItemNo,
    LEFT(
        TRIM(COALESCE(poid.HSNSACCode,'')),
        20
    ) AS hsn_code,
    poid.MakeNo,
    LEFT(
        TRIM(COALESCE(poid.TechSpecification,'')),
        1000
    ) AS tech_specification,
    poid.UnitNo,
    NULL AS cs_quotation_detail_id,
    NULL AS quotation_item_detail_id,
    COALESCE(poid.Quantity,0),
    COALESCE(poid.Rate,0),
    COALESCE(poid.BasicAmount,0),
    COALESCE(poid.NetAmount,0) - COALESCE(poid.BasicAmount,0) AS tax_amount,
    COALESCE(poid.NetAmount,0),
    poid.CostCenterNo,
    poid.ToleranceBasisNo,
    poid.TolerancePlus,
    poid.ToleranceMinus,
    LEFT(
        TRIM(COALESCE(poid.Remark,'')),
        300
    ) AS remarks,
    COALESCE(sm.new_status_id,1) AS status_id,
    0 AS discount_amount,
    NULL AS discount_per_qty,
    NULL AS discount_rate,
    COALESCE(poid.Rate,0) AS rate_after_discount
FROM sqlserver_fdw.poamendmentitemdetail poid
LEFT JOIN migration.status_mapping sm
    ON sm.old_status_id = poid.StatusNo;


WITH cte AS
(
    SELECT
        id,
        (ROW_NUMBER() OVER (
            PARTITION BY po_id
            ORDER BY id
        ) * 1) AS new_line_no
    FROM purchase.purchase_order_item_detail
)
UPDATE purchase.purchase_order_item_detail qid
SET line_no = cte.new_line_no
FROM cte
WHERE qid.id = cte.id;


----po Tax Detail -------


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
from sqlserver_fdw.poamendmentitemtaxdetail paitd
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


CREATE FOREIGN TABLE sqlserver_fdw.poamendmenttermsnconditiondetail
(
    poamendmenttermsdetailno integer,
    poamendmentno integer,
    termsnconditionheadno smallint,
    termsncondition varchar(300)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentTermsNConditionDetail'
);

INSERT INTO purchase.purchase_order_terms_n_condition_detail
(
    id,
    po_id,
    tnc_head_id,
    value
)
OVERRIDING SYSTEM VALUE
SELECT
    potc.poamendmenttermsdetailno,
    potc.poamendmentno,
    potc.termsnconditionheadno,
    LEFT(TRIM(COALESCE(potc.termsncondition, '')), 1000)
FROM sqlserver_fdw.poamendmenttermsnconditiondetail potc;


----PoPRDetail----

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

----------PO Schedule-----------------
CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.poamendmentitemscheduledetail
(
    POAmendmentISDetailNo INTEGER,
    POAmendmentNo INTEGER,
    POItemLineNo SMALLINT,
    ItemNo INTEGER,
    MakeNo SMALLINT,
    ScheduleDate TEXT,
    ScheduleQty NUMERIC(10,3)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'POAmendmentItemScheduleDetail'
);


INSERT INTO purchase.purchase_order_schedule_detail
(
    id,
    po_id,
    po_item_detail_id,
    pr_item_detail_id,
    qty,
    schedule_date
)
overriding system value
SELECT
    pis.poamendmentisdetailno as id,
    pis.poamendmentNo as po_id,
    poid.id as po_item_detail_id,
    null as pr_item_detail_id,
    pis.scheduleqty as qty,
    migration.parse_sqlserver_datetime(pis.ScheduleDate) as schedule_date
from sqlserver_fdw.poamendmentitemscheduledetail pis
inner join purchase.purchase_order_item_detail poid
	on poid.po_id=pis.poamendmentNo
	and poid.item_id=pis.itemNo
	and coalesce(poid.make_id,0)=coalesce(pis.makeNo,0);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--------Po Cancellation-------

CREATE FOREIGN table if not exists sqlserver_fdw.changepostatusmain
(
    companyno integer,
    yearno integer,
    changepostatusno integer,
    divisionno integer,
    documentsettingno text,
    documentnoyearly varchar(30),
    documentdate text,
    documentstatusno smallint,
    poamendmentno integer,
    statusno smallint,
    reason varchar(1000),
    createdby integer,
    createddate text,
    modifiedby integer,
    modifieddate text,
    authorizedby integer,
    authorizeddate text,
    releasedby integer,
    releaseddate text,
    isinserted bit
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'ChangePOStatusMain'
);


INSERT INTO purchase.po_cancellation_main
(
	id,
    po_id,
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
    authorized_date
)
overriding system value
select
    cpsm.changepoStatusNo,
    cpsm.poamendmentNo,
    cpsm.documentnoyearly,
    migration.parse_sqlserver_datetime(cpsm.documentdate),
    6,
    cpsm.divisionno,
    NULL,
    cpsm.documentstatusno,
    cpsm.companyno,
    cpsm.yearno,
    cpsm.reason,
    cpsm.createdby,
    migration.parse_sqlserver_datetime(cpsm.createddate),
    cpsm.modifiedby,
    COALESCE(
        migration.parse_sqlserver_datetime(cpsm.modifieddate),
        migration.parse_sqlserver_datetime(cpsm.createddate)
    ),
    cpsm.authorizedby,
    migration.parse_sqlserver_datetime(cpsm.authorizeddate)
FROM sqlserver_fdw.changepostatusmain cpsm;



CREATE FOREIGN TABLE if not exists sqlserver_fdw.changepostatusitemdetails
(
    changepostatusitemdetailsno integer,
    changepostatusno integer,
    itemno integer,
    makeno integer,
    statusno smallint,
    reason varchar(500),
    isreleaseindent bit,
    technicalgradeno integer,
    cancelqty numeric(15,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'ChangePOStatusItemDetails'
);

INSERT INTO purchase.po_cancellation_item_detail
(
	id,
    line_no,
    po_cancellation_id,
    po_item_detail_id,
    cancel_qty,
    is_release_pr_quantity,
    status_id,
    remarks
)
overriding system value
select
	cpsi.changepostatusitemdetailsno,
    poi.line_no,
    pcm.id,
    poi.id,
    cpsi.cancelqty,
	COALESCE(cpsi.isreleaseindent, B'0') = B'0',
    sm.new_status_id,
    cpsi.reason
FROM sqlserver_fdw.changepostatusitemdetails cpsi
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsi.changePoStatusNo
INNER JOIN purchase.purchase_order_item_detail poi
    ON poi.po_id = pcm.po_id
   AND poi.item_id = cpsi.itemno
   AND COALESCE(poi.make_id,0) = COALESCE(cpsi.makeno,0)
LEFT JOIN migration.status_mapping sm
    ON sm.old_status_id = cpsi.statusno;


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.changepostatusindentdetails
(
    ChangePOStatusIndentDetailsNo INTEGER,
    ChangePOStatusNo INTEGER,
    IndentNo INTEGER,
    POItemNo INTEGER,
    POMakeNo SMALLINT,
    IndentItemLineNo NUMERIC(10,3),
    CancelQty NUMERIC(15,3)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'ChangePOStatusIndentDetails'
);


INSERT INTO purchase.po_cancellation_pr_detail
(
    id,
    po_cancellation_id,
    po_cancellation_item_detail_id,
    pr_item_detail_id,
    po_item_detail_id,
    pr_cancel_qty,
    purchase_order_cancellation_item_detail_id
)
OVERRIDING SYSTEM VALUE
SELECT
    cpsid.ChangePOStatusIndentDetailsNo,
    pcm.id,
    pcid.id,
    prid.id,
    poid.id,
    COALESCE(cpsid.CancelQty,0),
    pcid.id
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsid.ChangePOStatusNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = pcm.po_id
   AND poid.item_id = cpsid.POItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
INNER JOIN purchase.po_cancellation_item_detail pcid
    ON pcid.po_cancellation_id = pcm.id
   AND pcid.po_item_detail_id = poid.id;



-----------------------------------------------------------------------------------------------------------------------------------------------------------------

---Po Summary---

INSERT INTO purchase.purchase_order_summary
(
    main_po_id,
    current_amendment_no,
    last_ack_amendment_no,
    last_ack_date,
    last_published_amendment_no,
    last_published_date,
    current_authorized_amendment_no
)
SELECT
    p.main_po_id,
    MAX(p.amendment_no) AS current_amendment_no,
    NULL AS last_ack_amendment_no,
    NULL AS last_ack_date,
    (
        SELECT p1.amendment_no
        FROM purchase.purchase_order_main p1
        WHERE p1.main_po_id = p.main_po_id
          AND p1.is_published = TRUE
        ORDER BY p1.amendment_no DESC
        LIMIT 1
    ) AS last_published_amendment_no,
    (
        SELECT p1.publication_modified_date
        FROM purchase.purchase_order_main p1
        WHERE p1.main_po_id = p.main_po_id
          AND p1.is_published = TRUE
        ORDER BY p1.amendment_no DESC
        LIMIT 1
    ) AS last_published_date,
    (
        SELECT MAX(p2.amendment_no)
        FROM purchase.purchase_order_main p2
        WHERE p2.main_po_id = p.main_po_id
          AND p2.document_status_id = 30
    ) AS current_authorized_amendment_no
FROM purchase.purchase_order_main p
GROUP BY p.main_po_id;


----Po Item Process----
WITH LatestAuthorizedPO AS
(
    SELECT
        pom.id AS po_id,
        pom.main_po_id,
        pom.amendment_no,
        ROW_NUMBER() OVER
        (
            PARTITION BY pom.main_po_id
            ORDER BY pom.amendment_no DESC
        ) AS rn
    FROM purchase.purchase_order_main pom
    WHERE pom.document_status_id NOT IN (10,20)
),
POCancellation AS
(
    SELECT
        po_item_detail_id,
        SUM(COALESCE(cancel_qty, 0)) AS cancel_qty
    FROM purchase.po_cancellation_item_detail
    GROUP BY po_item_detail_id
)
INSERT INTO purchase.purchase_order_item_process_detail
(
    main_po_id,
    line_no,
    item_id,
    make_id,
    po_qty,
    grn_process_qty,
    cancel_qty,
    balance_qty,
    po_min_tolerance_qty,
    po_max_tolerance_qty,
    excess_qty,
    status_id
)
SELECT
    lap.main_po_id,
    poid.line_no,
    poid.item_id,
    poid.make_id,
    COALESCE(poid.qty, 0) AS po_qty,
    0 AS grn_process_qty,
    COALESCE(poc.cancel_qty, 0) AS cancel_qty,
    (
        COALESCE(poid.qty, 0)
        - COALESCE(poc.cancel_qty, 0)
    ) AS balance_qty,
    CASE
        WHEN poid.tolerance_type = 1
        THEN COALESCE(poid.tolerance_minus, 0)
        WHEN poid.tolerance_type = 2
        THEN
            COALESCE(poid.qty, 0)
            * COALESCE(poid.tolerance_minus, 0)
            / 100
        ELSE 0
    END AS po_min_tolerance_qty,
    CASE
        WHEN poid.tolerance_type = 1
        THEN COALESCE(poid.tolerance_plus, 0)
        WHEN poid.tolerance_type = 2
        THEN
            COALESCE(poid.qty, 0)
            * COALESCE(poid.tolerance_plus, 0)
            / 100
        ELSE 0
    END AS po_max_tolerance_qty,
    0 AS excess_qty,
    poid.status_id
FROM LatestAuthorizedPO lap
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = lap.po_id
LEFT JOIN POCancellation poc
    ON poc.po_item_detail_id = poid.id
WHERE lap.rn = 1;


--- Po Pr Process----
CREATE FOREIGN table if not exists sqlserver_fdw.po_amendment_item_compute_detail (
    poamendmentno integer NOT NULL,
    pono integer NOT NULL,
    indentno integer NULL,
    indentitemlineno numeric(10,3) NOT NULL,
    poqty numeric(10,3) NOT NULL,
    cancelqty numeric(38,3) NULL,
    tolerancebasisno smallint NULL,
    toleranceplus numeric(12,3) NULL,
    toleranceminus numeric(12,3) NULL,
    ToleranceMinusQty decimal(26,8) NOT NULL,
	TolerancePlusQty decimal(26,8) NOT NULL,
    minpoqty numeric(27,8) NULL,
    maxpoqty numeric(27,8) null,
    ItemNo int NOT NULL,
	MakeNo smallint NULL,
	IndentMakeNo smallint NULL
)
 SERVER sqlserver_fdw
 OPTIONS
 (
     schema_name 'dbo',
     table_name 'PO_Amendment_Item_Compute_Detail'
 );


INSERT INTO purchase.purchase_order_pr_item_process_detail
(
    main_po_id,
    pr_item_detail_id,
    item_id,
    make_id,
    po_qty,
    grn_qty,
    cancel_qty,
    balance_qty,
    po_min_tolerance_qty,
    po_max_tolerance_qty
)
SELECT
    pom.main_po_id,
    prid.id AS pr_item_detail_id,
    pacd.itemNo,
    pacd.makeNo,
    pacd.poqty AS po_qty,
    0 AS grn_qty,
    coalesce(pacd.cancelqty,0) AS cancel_qty,
    coalesce(pacd.poqty,0) - coalesce(pacd.cancelqty,0) AS balance_qty,
    pacd.ToleranceMinusQty AS po_min_tolerance_qty,
    pacd.TolerancePlusQty AS po_max_tolerance_qty
FROM sqlserver_fdw.po_amendment_item_compute_detail pacd
INNER JOIN purchase.purchase_order_main pom
    ON pom.id = pacd.poamendmentno
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = pacd.indentno
   AND prid.line_no = pacd.indentitemlineno
   


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO masterdata.document_series_master
(
    code,
    padding,
    pattern,
    frequency_id,
    number_starts_from,
    effective_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
VALUES
(   ---- Specifically for PR
    'DS0000001',
    5,
    'MMPR{{N}}',
    3, -- continuous
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 5)::INT), 0) + 1
        FROM inventory.purchase_request_main
        WHERE doc_no_yearly ~ '^MMPR[0-9]+$'
    ),
    (
        SELECT created_date
        FROM inventory.purchase_request_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(    ---- Specifically for PO
    'DS0000002',
    5,
    '{{FY2}}Y{{N}}',
    3, -- yearly
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 4)::INT), 0) + 1
        FROM purchase.purchase_order_main
        WHERE doc_no_yearly ~ '^26Y[0-9]+$'
    ),
    (
        SELECT created_date
        FROM purchase.purchase_order_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for RFQ
    'DS0000003',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.pur_rfq_main
        WHERE ref_doc_type_id <> 9
    ),
    (
        SELECT created_date
        FROM purchase.pur_rfq_main
        WHERE ref_doc_type_id <> 9
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for CS
    'DS0000004',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.cs_main
    ),
    (
        SELECT created_date
        FROM purchase.cs_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for PR Cancellation
    'DS0000005',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM utility.purchase_request_cancellation_main
    ),
    (
        SELECT created_date
        FROM utility.purchase_request_cancellation_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for PO Cancellation
    'DS0000006',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.po_cancellation_main
    ),
    (
        SELECT created_date
        FROM purchase.po_cancellation_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(    -----Specifically for Auction
    'DS0000007',
    5,
    'AU{{N}}',
    4, -- continuous
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 3)::INT),0) + 1
        FROM purchase.auction_main
        WHERE doc_no_yearly ~ '^AU[0-9]+$'
    ),
    (
        SELECT created_date
        FROM purchase.auction_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
);


INSERT INTO masterdata.document_series_form_detail
(
document_series_id,
form_id
)
values
(1,6),
(2,10),
(3,7),
(4,8),
(5,97),
(6,42),
(7,106);

INSERT INTO masterdata.document_series_doc_type_detail
(
document_series_id,
document_type_id,
status_id
) VALUES
(1,(select id from masterdata.doc_type_master where form_id in (6)),1),
(2,(select id from masterdata.doc_type_master where form_id in (10)),1),
(3,(select id from masterdata.doc_type_master where form_id in (7) limit 1),1),  ---confirm what is return before running
(4,(select id from masterdata.doc_type_master where form_id in (8)),1),
(5,(select id from masterdata.doc_type_master where form_id in (97)),1),
(6,(select id from masterdata.doc_type_master where form_id in (42)),1),
(7,(select id from masterdata.doc_type_master where form_id in (106)),1);

INSERT INTO masterdata.document_series_company_detail
(
    document_series_id,
    company_id,
    status_id
)
SELECT
    ds.document_series_id,
    cm.id,
    1 AS status_id
FROM
    masterdata.company_master cm
CROSS JOIN
(
    SELECT 1 AS document_series_id
    UNION ALL
    SELECT 2
    UNION ALL
    SELECT 3
    UNION ALL
    SELECT 4
    UNION ALL
    SELECT 5
    UNION ALL
    SELECT 6
    UNION ALL
    SELECT 7
) ds; 

INSERT INTO masterdata.document_series_division_detail
(
    document_series_id,
    division_id,
    status_id
)
SELECT
    ds.document_series_id,
    dm.id,
    1 AS status_id
FROM
    masterdata.division_master dm
CROSS JOIN
(
    SELECT 1 AS document_series_id
    UNION ALL
    SELECT 2
    UNION ALL
    SELECT 3
    UNION ALL
    SELECT 4
    UNION ALL
    SELECT 5
    UNION ALL
    SELECT 6
    UNION ALL
    SELECT 7
) ds;

INSERT INTO masterdata.document_series_next_number 
(
document_series_id,
period,
next_number
) VALUES 
(1,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 1)),
(2,'2026',(select number_starts_from from masterdata.document_series_master where id = 2)),
(3,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 3)),
(4,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 4)),
(5,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 5)),
(6,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 6)),
(7,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 7));



-----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE FOREIGN table if not exists sqlserver_fdw.indentauthorizationdetail
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
    COALESCE(pr.approval_setup_id)                              AS approval_setup_id,
    0                                                           AS revision_no,
    true                                                        AS is_current,
    CASE
	    WHEN pr.document_status_id = 30 THEN 9
    	WHEN pr.document_status_id = 20 then 14
	    WHEN pr.document_status_id = 10 THEN 7
    END                                                         AS status_id,
    pr.created_by_id                                            AS created_by_id,
    pr.created_date         AS created_date,
    pr.modified_by_id                                           AS modified_by_id,
    pr.modified_date       AS modified_date,
    MAX(iad.LevelNo)                                            AS max_approver_level_no,
    MAX(
    	CASE
        	WHEN iad.StatusNo = 1 THEN iad.LevelNo
	    END
	) AS current_approved_level_no,
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

--- Approval Process Detail
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
    CASE
		WHEN iad.StatusNo = 1 THEN 12
		WHEN iad.StatusNo = 5 THEN 20 
	END                                                             AS status_id,
    COALESCE(
        NULLIF(TRIM(iad.Comment), ''),
        NULLIF(TRIM(iad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
	alm.printing_caption
FROM sqlserver_fdw.indentauthorizationdetail iad
JOIN utility.approval_process_main apm
    ON apm.doc_id = iad.IndentNo
    AND apm.form_id = 6
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
	AND alm.level_no = iad.levelNo;


CREATE FOREIGN TABLE if not exists sqlserver_fdw.poamendmentauthorizationdetail
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
	    WHEN pom.document_status_id = 20 THEN 14
	    WHEN pom.document_status_id = 10 THEN 7
    END                                                             AS status_id,
    pom.created_by_id                                               AS created_by_id,
    pom.created_date                                                AS created_date,
    pom.modified_by_id                                              AS modified_by_id,
    pom.modified_date                                               AS modified_date,
    MAX(pad.LevelNo)                                                AS max_approver_level_no,
    MAX(
    	CASE
        	WHEN pad.StatusNo = 1 THEN pad.LevelNo
	    END
	) AS current_approved_level_no,
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
		WHEN pad.StatusNo = 5 THEN 20
		WHEN pad.StatusNo = 17 THEN 19 
	END                                                             AS status_id,
    COALESCE(
        NULLIF(TRIM(pad.Comment), ''),
        NULLIF(TRIM(pad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
    alm.printing_caption                                            AS printing_caption
FROM sqlserver_fdw.poamendmentauthorizationdetail pad
JOIN utility.approval_process_main apm
    ON apm.doc_id = pad.POAmendmentNo
    AND apm.form_id = 10
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
    AND alm.level_no = pad.LevelNo;


CREATE FOREIGN TABLE sqlserver_fdw.csauthorizationdetail
(
    CSAuthorizationDetailNo         integer,
    CSNo                        integer,
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
    schema_name 'Purchase',
    table_name 'csAuthorizationDetail'
);


WITH action_cte AS (
    SELECT DISTINCT ON (cad.csNo)
        cad.csNo,
        cad.ModifiedBy                                          AS action_by_id,
        migration.parse_sqlserver_datetime(cad.ModifiedDate)    AS action_date
    FROM sqlserver_fdw.csauthorizationdetail cad
    WHERE cad.ModifiedBy IS NOT NULL
      AND cad.ModifiedDate IS NOT NULL
    ORDER BY cad.csNo, cad.LevelNo DESC
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
    doc_type_id,
    is_audit,
    audit_entry_id
)
OVERRIDING SYSTEM VALUE
SELECT
    8                                                              AS form_id,
    pom.id                                                          AS doc_id,
    pom.approval_setup_id                                           AS approval_setup_id,
    0                                                               AS revision_no,
    true                                                            AS is_current,
    CASE
	    WHEN pom.document_status_id = 30 THEN 9
	    WHEN pom.document_status_id = 20 THEN 14
	    WHEN pom.document_status_id = 10 THEN 7
    END                                                             AS status_id,
    pom.created_by_id                                               AS created_by_id,
    pom.created_date                                                AS created_date,
    pom.modified_by_id                                              AS modified_by_id,
    pom.modified_date                                               AS modified_date,
    MAX(cad.LevelNo)                                                AS max_approver_level_no,
    MAX(
    	CASE
        	WHEN cad.StatusNo = 1 THEN cad.LevelNo
	    END
	) AS current_approved_level_no,
    COALESCE(migration.parse_sqlserver_datetime(MIN(cad.AssignDate)), NOW()) AS approval_start_date,
    ac.action_by_id                                                 AS action_by_id,
    ac.action_date                                                  AS action_date,
    pom.company_id                                                  AS company_id,
    pom.doc_type_id                                                 AS doc_type_id,
    false                                                           AS is_audit,
    NULL                                                            AS audit_entry_id
FROM purchase.cs_main pom
JOIN sqlserver_fdw.csauthorizationdetail cad
    ON cad.csNo = pom.id
 AND  pom.approval_setup_id IS NOT NULL
LEFT JOIN action_cte ac
    ON ac.csNo = pom.id
GROUP BY
    pom.id,
    pom.approval_setup_id,
    pom.created_by_id,
    pom.created_date,
    pom.modified_by_id,
    pom.modified_date,
    pom.company_id,
    pom.doc_type_id,
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
 WHEN pad.StatusNo = 5 THEN 20 
 WHEN pad.StatusNo = 17 THEN 19
 END                                                             AS status_id,
    COALESCE(
        NULLIF(TRIM(pad.Comment), ''),
        NULLIF(TRIM(pad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
    alm.printing_caption                                            AS printing_caption
FROM sqlserver_fdw.csAuthorizationDetail pad
JOIN utility.approval_process_main apm
    ON apm.doc_id = pad.csNo
    AND apm.form_id = 8
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
    AND alm.level_no = pad.LevelNo; 




-----------------------------------------------------------------------------------------------------------------------------------------------------------------



---- Detail Status Update (approved_by_peer and rejected_by_peer)
UPDATE utility.approval_process_detail apd
SET status_id = CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM utility.approval_process_detail x
                        WHERE x.approval_process_id = apd.approval_process_id
                          AND x.level_no = apd.level_no
                          AND x.status_id = 12
                    ) THEN 21
                    WHEN EXISTS (
                        SELECT 1
                        FROM utility.approval_process_detail x
                        WHERE x.approval_process_id = apd.approval_process_id
                          AND x.level_no = apd.level_no
                          AND x.status_id = 13
                    ) THEN 29
                END
WHERE apd.status_id NOT IN (12, 13)
  AND EXISTS (
        SELECT 1
        FROM utility.approval_process_detail x
        WHERE x.approval_process_id = apd.approval_process_id
          AND x.level_no = apd.level_no
        GROUP BY x.approval_process_id, x.level_no
        HAVING COUNT(*) > 1
  )
  AND (
        EXISTS (
            SELECT 1
            FROM utility.approval_process_detail x
            WHERE x.approval_process_id = apd.approval_process_id
              AND x.level_no = apd.level_no
              AND x.status_id = 12
        )
        OR
        EXISTS (
            SELECT 1
            FROM utility.approval_process_detail x
            WHERE x.approval_process_id = apd.approval_process_id
              AND x.level_no = apd.level_no
              AND x.status_id = 13
        )
      );

---------------------------------
----update pending status for in review status
UPDATE utility.approval_process_detail apd
SET status_id = 3
FROM utility.approval_process_main apm
WHERE apm.id = apd.approval_process_id
  AND apm.status_id = 14
  AND apd.level_no = COALESCE(apm.current_approved_level_no, 0) + 1
  AND apd.status_id = 20;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
----- Auction ----


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


-- Update RFQItemDetailId in Quotation_Item_Detail
UPDATE purchase.quotation_item_detail qid
SET rfq_item_detail_id = 3
FROM sqlserver_fdw.revisedquotationmain r
inner join purchase.auction_item_detail aid 
	aid.auction_id=r.auctionNo and
	aid.item_id = qid.item_id and
	aid.make_id = qid.rfq_make_id

update purchase.quotation_item_detail
set item_id = 2242
where id =

update purchase.cs_pr_detail
set item_id = 2242
where id ;

select * from purchase.quotation_item_detail qid
inner join sqlserver_fdw.revisedQuotationItemDetail rqid
on rqid.revisedQuotationItemNo= qid.id
where rqid.itemNo<>qid.item_id

select
	qid.id,
	rqm.auctionno,
	aid.id ,
	aid.generated_rfq_item_detail_id
from
	purchase.quotation_item_detail qid
inner join sql_migration.revisedquotationmain rqm
    on
	rqm.revisedquotationno = qid.quotation_id
	--where rqm.auctionno is not null
left join purchase.auction_item_detail aid 
on
	aid.auction_id = rqm.auctionno
	and aid.item_id = qid.item_id
	and coalesce(aid.make_id, 0) = coalesce(qid.rfq_make_id, 0)
where
	rqm.auctionno is not null
	and aid.id is null

select im.item_name from masterdata.item_master im 
where im.id in (2224,2333,19059,52564, 2252)

select * from purchase.quotation_item_detail where id=152461;

select * from purchase.auction_item_detail where auction_id =210;




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


-----------------------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------
---Category Master

CREATE FOREIGN table if not exists sqlserver_fdw.ecategorymaster
(
    ERPCategoryNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    CategoryName    varchar(100),
    Alias           varchar(50),
    CategoryNo      smallint,
    DBNo            smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCategoryMaster'
);


INSERT INTO erpmaster.e_category_master
(
    id,
    category_name,
    alias,
    vp_category_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
overriding system value
SELECT
    e.ERPCategoryNo,
    e.CategoryName,
    e.Alias,
    e.CategoryNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    migration.parse_sqlserver_datetime(e.CreatedDate),
    migration.parse_sqlserver_datetime(coalesce(e.ModifiedDate, e.CreatedDate)),
    e.Inactive
FROM sqlserver_fdw.ecategorymaster e;



---------------------------------------------------------
---Country master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecountrymaster
(
    ERPCountryNo    smallint,
    Code            varchar(10),
    CountryName     varchar(100),
    DBNo            smallint,
    CountryNo       smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    ERPUniqueValue  varchar(10)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCountryMaster'
);

INSERT INTO erpmaster.e_country_master
(
    id,
    country_name,
    vp_country_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCountryNo,
    e.CountryName,
    e.CountryNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.ecountrymaster e;


---------------------------------------------------------
---State master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.estatemaster
(
    ERPStateNo      smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    StateName       varchar(100),
    ERPCountryNo    smallint,
    DBNo            smallint,
    StateNo         smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eStateMaster'
);


INSERT INTO erpmaster.e_state_master
(
    id,
    state_name,
    vp_state_id,
    e_country_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPStateNo,
    e.StateName,
    e.StateNo,
    e.ERPCountryNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.estatemaster e;


---------------------------------------------------------
---City Master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecitymaster
(
    ERPCityNo       smallint,
    ERPUniqueValue  varchar(20),
    Code            varchar(20),
    CityName        varchar(100),
    ERPStateNo      smallint,
    DBNo            smallint,
    CityNo          integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCityMaster'
);


INSERT INTO erpmaster.e_city_master
(
    id,
    city_name,
    e_state_id,
    vp_city_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCityNo,
    e.CityName,
    e.ERPStateNo,
    e.CityNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.ecitymaster e;


--------------------------------------------------------
----division master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.edivisionmaster
(
    ERPDivisionNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    DivisionName    varchar(100),
    DBNo            smallint,
    DivisionNo      integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    CompanyNo       smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eDivisionMaster'
);

INSERT INTO erpmaster.e_division_master
(
    id,
    division_name,
    vp_division_id,
    vp_company_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPDivisionNo,
    e.DivisionName,
    e.DivisionNo,
    e.CompanyNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.edivisionmaster e;


---------------------------------------------------------
---Cost center Master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecostcentermaster
(
    ERPCostCenterNo       integer,
    ERPUniqueValue        varchar(10),
    Code                  varchar(10),
    CostCenterName        varchar(100),
    ERPParentCostCenterNo integer,
    DBNo                  smallint,
    CostCenterNo          integer,
    CreatedDate           text,
    ModifiedDate          text,
    Inactive              boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCostCenterMaster'
);


INSERT INTO erpmaster.e_cost_center_master
(
    id,
    cost_center_name,
    e_parent_cost_center_id,
    vp_cost_center_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCostCenterNo,
    e.CostCenterName,
    e.ERPParentCostCenterNo,
    e.CostCenterNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.ecostcentermaster e;


---------------------------------------------------------
---Cost Center Company Detail

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecostcentercompanydetail
(
    CostCenterCompanyDetailNo  integer,
    ERPCostCenterNo            integer,
    ERPDivisionNo              smallint,
    CompanyNo                  smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCostCenterCompanyDetail'
);


INSERT INTO erpmaster.e_cost_center_company_detail
(
    id,
    e_cost_center_id,
    e_division_id,
    vp_company_id
)
OVERRIDING SYSTEM VALUE
SELECT
    e.CostCenterCompanyDetailNo,
    e.ERPCostCenterNo,
    e.ERPDivisionNo,
    e.CompanyNo
FROM sqlserver_fdw.ecostcentercompanydetail e;



---------------------------------------------------------
---Currency master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecurrencymaster
(
    ERPCurrencyNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    CurrencyName    varchar(50),
    Notation        varchar(10),
    DBNo            smallint,
    CurrencyNo      smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCurrencyMaster'
);


INSERT INTO erpmaster.e_currency_master
(
    id,
    currency_name,
    notation,
    vp_currency_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCurrencyNo,
    e.CurrencyName,
    e.Notation,
    e.CurrencyNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.ecurrencymaster e;



---------------------------------------------------------
---Unit master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.eunitmaster
(
    ERPUnitNo       smallint,
    Code            varchar(10),
    UnitName        varchar(100),
    DBNo            smallint,
    UnitNo          smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    ERPUniqueValue  varchar(10),
    Alias           varchar(6)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eUnitMaster'
);

INSERT INTO erpmaster.e_unit_master
(
    id,
    unit_name,
    alias,
    vp_unit_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPUnitNo,
    e.UnitName,
    e.Alias,
    e.UnitNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.eunitmaster e;


---------------------------------------------------------
---Department master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.edeptmaster
(
    ERPDeptNo       smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    DeptName        varchar(100),
    ERPDivisionNo   smallint,
    DBNo            smallint,
    DeptNo          integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    CompanyNo       smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eDeptMaster'
);


INSERT INTO erpmaster.e_department_master
(
    id,
    department_name,
    vp_department_id,
    e_division_id,
    vp_company_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPDeptNo,
    e.DeptName,
    e.DeptNo,
    e.ERPDivisionNo,
    e.CompanyNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.edeptmaster e;

---------------------------------------------------------
---Group master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.egroupmaster
(
    ERPGroupNo       smallint,
    ERPCategoryNo    smallint,
    ERPUniqueValue   varchar(10),
    Code             varchar(10),
    GroupName        varchar(100),
    Alias            varchar(50),
    GroupNo          smallint,
    DBNo             smallint,
    CreatedDate      text,
    ModifiedDate     text,
    Inactive         boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eGroupMaster'
);


INSERT INTO erpmaster.e_group_master
(
    id,
    group_name,
    e_category_id,
    alias,
    vp_group_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPGroupNo,
    e.GroupName,
    e.ERPCategoryNo,
    coalesce(e.Alias,e.GroupName),
    e.GroupNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.egroupmaster e;


---------------------------------------------------------
---Item master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.eitemmaster
(
    ERPItemNo         integer,
    ERPUniqueValue    varchar(10),
    Code              varchar(10),
    ItemName          varchar(200),
    Size              varchar(100),
    Grade             varchar(100),
    ERPUnitNo         smallint,
    ItemNatureNo      smallint,
    DBNo              smallint,
    ItemNo            integer,
    CreatedDate       text,
    ModifiedDate      text,
    Inactive          boolean,
    GroupName         varchar(100),
    SubGroupName      varchar(100),
    ItemDescription   varchar(600),
    HSNSACCode        varchar(8),
    ERPSubGroupNo     smallint,
    PurchaseEmpCode   varchar(5)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eItemMaster'
);


INSERT INTO erpmaster.e_item_master
(
    id,
    item_name,
    e_unit_id,
    vp_item_id,
    item_nature,
    category_name,
    group_name,
    subgroup_name,
    hsn_sac_code,
    purchase_emp_code,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPItemNo,
    e.ItemName,
    e.ERPUnitNo,
    e.ItemNo,
    e.ItemNatureNo,
    null,
    e.GroupName,
    e.SubGroupName,
    e.HSNSACCode,
    e.PurchaseEmpCode,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.eitemmaster e;


---------------------------------------------------------
---Location master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.elocationmaster
(
    ERPLocationNo    smallint,
    ERPUniqueValue   varchar(10),
    Code             varchar(10),
    LocationName     varchar(100),
    ERPCityNo        smallint,
    DBNo             smallint,
    LocationNo       smallint,
    CreatedDate      text,
    ModifiedDate     text,
    Inactive         boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eLocationMaster'
);


INSERT INTO erpmaster.e_location_master
(
    id,
    location_name,
    vp_location_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPLocationNo,
    e.LocationName,
    e.LocationNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.elocationmaster e;


---------------------------------------------------------
---Make master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.emakemaster
(
    ERPMakeNo        smallint,
    Code             varchar(10),
    MakeName         varchar(100),
    CreatedDate      text,
    ModifiedDate     text,
    Inactive         boolean,
    DBNo             smallint,
    MakeNo           smallint,
    ERPUniqueValue   varchar(10)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eMakeMaster'
);


INSERT INTO erpmaster.e_make_master
(
    id,
    make_name,
    vp_make_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPMakeNo,
    e.MakeName,
    e.MakeNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.emakemaster e;


---------------------------------------------------------
---Region master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.eregionmaster
(
    ERPRegionNo     smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    RegionName      varchar(100),
    DBNo            smallint,
    RegionNo        smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eRegionMaster'
);

INSERT INTO erpmaster.e_region_master
(
    id,
    region_name,
    vp_region_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPRegionNo,
    e.RegionName,
    e.RegionNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.eregionmaster e;






---------------------------------------------------------
---Subgroup master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.esubgroupmaster
(
    ERPSubGroupNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    ERPGroupNo      smallint,
    SubGroupName    varchar(100),
    Alias           varchar(50),
    SubGroupNo      smallint,
    DBNo            smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eSubGroupMaster'
);

INSERT INTO erpmaster.e_subgroup_master
(
    id,
    subgroup_name,
    e_group_id,
    alias,
    vp_subgroup_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPSubGroupNo,
    e.SubGroupName,
    e.ERPGroupNo,
    coalesce(e.Alias,e.SubGroupName),
    e.SubGroupNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.esubgroupmaster e;


---------------------------------------------------------
---Termsn N Condition Head master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.etermsnconditionhead
(
    ERPTermsNConditionHeadNo  smallint,
    ERPUniqueValue            varchar(10),
    Code                      varchar(10),
    TermsNConditionHeadName   varchar(50),
    DBNo                      smallint,
    TermsNConditionHeadNo     smallint,
    CreatedDate               text,
    ModifiedDate              text,
    Inactive                  boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eTermsNConditionHead'
);


INSERT INTO erpmaster.e_terms_n_condition_head_master
(
    terms_n_condition_head_name,
    vp_tnc_head_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
SELECT
    e.TermsNConditionHeadName,
    e.TermsNConditionHeadNo,
    e.Code,
    e.ERPColumnName,
    6,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    false
FROM sqlserver_fdw.mTermsNConditionHead e;


---------------------------------------------------------
---Vendor master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.evendorcard
(
    ERPVendorNo     integer,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    VendorName      varchar(100),
    DBNo            smallint,
    VendorNo        integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    GVendorTypeNo   smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eVendorCard'
);

INSERT INTO erpmaster.e_vendor_master
(
    id,
    vendor_name,
    vp_vendor_id,
    vp_bp_type_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPVendorNo,
    e.VendorName,
    e.VendorNo,
    case when e.GVendorTypeNo=6 then 2 else e.GVendorTypeNo end,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.evendorcard e;


---------------------------------------------------------
---Vendor Location master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.evendorlocationdetail
(
    ERPVendorLocationNo   integer,
    ERPUniqueValue        varchar(10),
    Code                  varchar(10),
    VendorName             varchar(100),
    Address1               varchar(100),
    Address2               varchar(100),
    Address3               varchar(100),
    City                   varchar(100),
    State                  varchar(100),
    Country                varchar(100),
    Pincode                varchar(6),
    PhoneNo                varchar(100),
    Email                  varchar(300),
    Website                varchar(100),
    CINNo                  varchar(30),
    GSTINNo                varchar(30),
    PANNo                  varchar(35),
    ERPBusinessTypeNo      smallint,
    ERPVendorTypeNo        smallint,
    ERPManufacturingTypeNo smallint,
    ERPCityNo              integer,
    ERPStateNo              smallint,
    ERPCountryNo            smallint,
    DBNo                    smallint,
    VendorLocationNo        integer,
    CreatedDate             text,
    ModifiedDate            text,
    Inactive                boolean,
    ERPUniqueValue2         varchar(10),
    ModifiedBy              smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eVendorLocationDetail'
);


INSERT INTO erpmaster.e_vendor_location_master
(
    id,
    e_vendor_id,
    erp_unique_value2,
    address1,
    address2,
    address3,
    e_city_id,
    e_state_id,
    e_country_id,
    contact_no,
    email,
    website,
    cin_no,
    gstin_no,
    pan_no,
    vp_vendor_location_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPVendorLocationNo,
    e2.erpVendorNo,
    e.ERPUniqueValue2,
    e.Address1,
    e.Address2,
    e.Address3,
    e.ERPCityNo,
    e.ERPStateNo,
    e.ERPCountryNo,
    Left(e.PhoneNo,20),
    e.Email,
    e.Website,
    e.CINNo,
    e.GSTINNo,
    e.PANNo,
    e.VendorLocationNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.evendorlocationdetail e
left join sqlserver_fdw.evendorcard e2 
on e.erpuniquevalue = e2.erpuniquevalue and e.dbno = e2.dbno;

-------------
--business type master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.evendorbusinesstypemaster
(
    ERPVendorBusinessTypeNo  smallint,
    ERPUniqueValue           varchar(10),
    Code                     varchar(10),
    VendorBusinessTypeName   varchar(100),
    DBNo                     smallint,
    VendorBusinessTypeNo     smallint,
    CreatedDate              text,
    ModifiedDate              text,
    Inactive                 boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eVendorBusinessTypeMaster'
);


INSERT INTO erpmaster.e_business_type_master
(
    id,
    business_type_name,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPVendorBusinessTypeNo,
    e.VendorBusinessTypeName,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.evendorbusinesstypemaster e;


----------
--- Add on Master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.addonmaster
(
    AddOnMasterNo  smallint,
    AddOnCode      varchar(5),
    SNo            smallint,
    AFCode         varchar(5),
    AFRateI        varchar(1),
    AFLOGIC        varchar(18)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'AddOnMaster'
);


INSERT INTO erpmaster.e_add_on_master
(
    id,
    addon_code,
    s_no,
    af_code,
    af_rate_type,
    af_logic
)
OVERRIDING SYSTEM VALUE
SELECT
    e.AddOnMasterNo,
    e.AddOnCode,
    e.SNo,
    e.AFCode,
    e.AFRateI,
    e.AFLOGIC
FROM sqlserver_fdw.addonmaster e;

--------------------------------------------------------------Transactions----------------------------------------------------------------------------------------
-------------------- PR Main

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.realindentmain
(
    IndentNo            integer,
    EntityCode          varchar(4),
    FY                  varchar(5),
    DocumentNoYearly    varchar(30),
    DocumentDate        text,
    TCode               varchar(1),
    IndentType          varchar(1),
    Department          varchar(10),
    Division            varchar(10),
    PortalIndentNo      integer,
    DBNo                smallint,
    RequestedBy         varchar(100),
    Remark              varchar(1000),
    Priority            varchar(300),
    ERPCreatedDate      text,
    ERPAuthorizedDate   text,
    InformTo            varchar(4000),
    RefDocNo            varchar(50),
    RefDocDate          text
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'RealIndentMain'
);


INSERT INTO erpinventory.pr_main
(
    id,
    vp_pr_id,
    entity_code,
    fy,
    doc_no_yearly,
    doc_date,
    t_code,
    indent_type,
    erp_department_uv,
    erp_division_uv,
    requested_by,
    remark,
    priority,
    erp_created_date,
    erp_authorized_date,
    inform_to,
    ref_doc_no,
    ref_doc_date,
    db_id,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.IndentNo,
    e.PortalIndentNo,
    e.EntityCode,
    e.FY,
    e.DocumentNoYearly,
    migration.parse_sqlserver_datetime(e.DocumentDate)::date,
    e.TCode,
    coalesce(e.IndentType,'R'),
    e.Department,
    e.Division,
    e.RequestedBy,
    e.Remark,
    e.Priority,
    TIMESTAMPTZ '2018-01-01 00:00:00+05:30',
    TIMESTAMPTZ '2018-01-01 00:00:00+05:30',
    e.InformTo,
    e.RefDocNo,
    TIMESTAMPTZ '2018-01-01 00:00:00+05:30',
    e.DBNo,
    false
FROM sqlserver_fdw.realindentmain e;

-----------------------------------------------------
-------------------- PR Item Detail

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.realindentbody
(
    IndentDetailNo           integer,
    IndentNo                 integer,
    SLNo                     numeric(10,3),
    ItemCode                 varchar(10),
    MakeCode                 varchar(10),
    TechSpecification        varchar(1000),
    RequiredQty              numeric(15,3),
    IndentQty                numeric(15,3),
    Rate                     numeric(19,4),
    Amount                   numeric(19,4),
    CostCenter               varchar(10),
    PortalIndentNo           integer,
    PortalIndentItemDetailNo integer,
    DueDate                  text,
    Remarks                  varchar(500)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'RealIndentBody'
);

INSERT INTO erpinventory.pr_item_detail
(
    id,
    c_pr_id,
    line_no,
    erp_item_uv,
    erp_make_uv,
    tech_specification,
    required_qty,
    indent_qty,
    rate,
    amount,
    erp_cost_center_uv,
    vp_pr_id,
    vp_pr_item_detail_id,
    due_date,
    remarks,
    db_id
)
OVERRIDING SYSTEM VALUE
SELECT
    e.IndentDetailNo,
    e.IndentNo,
    e.SLNo,
    e.ItemCode,
    e.MakeCode,
    e.TechSpecification,
    coalesce(e.RequiredQty,e.IndentQty),
    e.IndentQty,
    e.Rate,
    e.Amount,
    e.CostCenter,
    e.PortalIndentNo,
    e.PortalIndentItemDetailNo,
    migration.parse_sqlserver_datetime(e.DueDate)::date,
    e.Remarks,
    6
FROM sqlserver_fdw.realindentbody e;

----------------------------------------------
-----Pr Item Detail Recent


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.realindentbodyrecent
(
    DocumentNoYearly  varchar(30),
    DocumentDate      text,
    SLNo              numeric(10,3),
    ItemCode          varchar(10),
    MakeCode          varchar(10),
    EntityCode        varchar(4),
    DueDate           text,
    DBNo              smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'RealIndentBodyRecent'
);


INSERT INTO erpinventory.pr_item_detail_recent
(
    document_no_yearly,
    document_date,
    sl_no,
    erp_item_uv,
    erp_make_uv,
    entity_code,
    due_date,
    db_no
)
SELECT
    e.DocumentNoYearly,
    migration.parse_sqlserver_datetime(e.DocumentDate)::date,
    e.SLNo,
    e.ItemCode,
    e.MakeCode,
    e.EntityCode,
    migration.parse_sqlserver_datetime(e.DueDate)::date,
    e.DBNo
FROM sqlserver_fdw.realindentbodyrecent e;



-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------------------------------------------------------





