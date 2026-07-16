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
    case when vld.BusinessTypeNo=0 then 20 else vld.BusinessTypeNo end,
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
    case when vld.RegionNo=0 then 1 else vld.RegionNo end,
    vld.StateNo,
    CASE
        WHEN COALESCE(vld.Inactive, FALSE)
            THEN 2::smallint
        ELSE 1::smallint
    END,
    NULL AS status_remarks,
    case
	    when vld.VendorTypeNo=0 then 1
	    else vld.VendorTypeNo
	end,
    vld.VendorNo,
    LEFT(TRIM(COALESCE(vld.WebSite, '')), 50)
FROM sqlserver_fdw.mvendorlocationdetail vld;
