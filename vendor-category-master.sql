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