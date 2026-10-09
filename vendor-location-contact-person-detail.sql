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