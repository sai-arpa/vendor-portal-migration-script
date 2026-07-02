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
    LEFT(TRIM(COALESCE(c.PhoneNo,'')),15),
    CASE WHEN c.phoneNo IS NOT NULL THEN 2 ELSE NULL end,
    LEFT(TRIM(COALESCE(c.Email,'')),320),
    NULL
FROM sqlserver_fdw.mvendorregistrationcontactdetail c;