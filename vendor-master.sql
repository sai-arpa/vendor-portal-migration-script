CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorcard
(
    VendorNo INTEGER,
    Code VARCHAR(7),
    VendorName VARCHAR(100),
    CreatedDate TEXT,
    ModifiedDate TEXT,
    MailingName VARCHAR(100),
    VendorTypeNo INTEGER
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
    1 as bp_type_id,
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