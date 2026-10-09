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