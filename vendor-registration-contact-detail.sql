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