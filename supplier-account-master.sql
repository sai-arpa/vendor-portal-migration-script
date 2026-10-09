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

INSERT INTO security.supplier_account_vendor_location_detail
(
    supplier_account_id,
    vendor_location_id
)
SELECT
    LoginNo AS supplier_account_id,
    VendorLocationNo AS vendor_location_id
FROM sqlserver_fdw.loginvendorlocationdetail;

UPDATE security.user_master um
SET supplier_account_id = um.id
WHERE EXISTS
(
    SELECT 1
    FROM security.supplier_account_master sam
    WHERE sam.id = um.id
);