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