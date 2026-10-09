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