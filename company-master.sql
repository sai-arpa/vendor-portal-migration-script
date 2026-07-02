CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcompanymaster
(
    CompanyNo                smallint,
    CompanyCode              varchar(10),
    CompanyName              varchar(100),
    AliasName                varchar(30),
    Address1                 varchar(100),
    Address2                 varchar(100),
    Address3                 varchar(100),
    CINNo                    varchar(50),
    CityNo                   integer,
    PhoneNo                  varchar(200),
    CorporateOfficeAddress   varchar(250),
    CorporateOfficePhone     varchar(50),
    CorporateOfficeEmail     varchar(300),
    CountryNo                integer,
    DBNo                     smallint,
    Email                    varchar(200),
    ERPCompanyCode           varchar(10),
    GSTINNo                  varchar(50),
    HeadOfficeNo             smallint,
    ITPANNo                  varchar(100),
    PinCodeCompany           varchar(6),
    PrintingName             varchar(50),
    RegdOfficeAddress        varchar(250),
    RegdOfficePhone          varchar(50),
    RegdOfficeEmail          varchar(300),
    StateNo                  integer,
    TallyCompanyName         varchar(150),
    TallyGodownName          varchar(150),
    Website                  varchar(100),
    Inactive                 boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mCompanyMaster'
);


INSERT INTO masterdata.company_master
(
    id,
    code,
    company_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    alias,
    address1,
    address2,
    address3,
    cin_no,
    city_id,
    contact_no,
    contact_no_country_id,
    corporate_office_address,
    corporate_office_contact_no,
    corporate_office_contact_no_country_id,
    corporate_office_email,
    country_id,
    db_config_id,
    email,
    erp_company_unique_id,
    full_address,
    gstin_no,
    head_office_id,
    pan_no,
    pincode,
    printing_name,
    regd_office_address,
    regd_office_contact_no,
    regd_office_contact_no_country_id,
    regd_office_email,
    state_id,
    tally_company_name,
    tally_godown_name,
    website,
    time_zones_id
)
OVERRIDING SYSTEM VALUE
SELECT
    CompanyNo,
    LEFT(TRIM(CompanyCode), 8),
    LEFT(TRIM(CompanyName), 100),
    1 AS created_by_id,
    now() AS created_date,
    1 AS modified_by_id,
    now() AS modified_date,
    CASE
        WHEN COALESCE(Inactive, FALSE)
            THEN 2::smallint
        ELSE 1::smallint
    END AS status_id,
    NULL AS status_remarks,
    LEFT(TRIM(AliasName), 15),
    LEFT(TRIM(Address1), 150),
    LEFT(TRIM(Address2), 150),
    LEFT(TRIM(Address3), 150),
    LEFT(TRIM(CINNo), 21),
    CityNo,
    LEFT(TRIM(PhoneNo), 15),
    case
	    when phoneNo is not null
	    then 2
	    else null
	end,
    LEFT(TRIM(CorporateOfficeAddress), 500),
    LEFT(TRIM(CorporateOfficePhone), 15),
    case
	    when CorporateOfficePhone is not null
	    then 2
	    else null
	end,
    LEFT(TRIM(CorporateOfficeEmail), 100),
    CountryNo,
    null as db_config_id,
    LEFT(TRIM(Email), 320),
    LEFT(TRIM(ERPCompanyCode), 50),
    LEFT(
        CONCAT_WS(
            ', ',
            NULLIF(TRIM(Address1), ''),
            NULLIF(TRIM(Address2), ''),
            NULLIF(TRIM(Address3), '')
        ),
        500
    ) AS full_address,
    LEFT(TRIM(GSTINNo), 15),
    NULL::integer AS head_office_id,
    LEFT(TRIM(ITPANNo), 10),
    LEFT(TRIM(PinCodeCompany), 10),
    LEFT(TRIM(PrintingName), 100),
    LEFT(TRIM(RegdOfficeAddress), 500),
    LEFT(TRIM(RegdOfficePhone), 15),
    case
	    when RegdOfficePhone is not null
	    then 2
	    else null
	end,
    LEFT(TRIM(RegdOfficeEmail), 100),
    StateNo,
    LEFT(TRIM(TallyCompanyName), 100),
    LEFT(TRIM(TallyGodownName), 100),
    LEFT(TRIM(Website), 150),
    1::smallint AS time_zones_id
FROM sqlserver_fdw.mcompanymaster;


-- Update headoffice Id
UPDATE masterdata.company_master cm
SET head_office_id = src.HeadOfficeNo
FROM sqlserver_fdw.mcompanymaster src
WHERE cm.id = src.CompanyNo
  AND src.HeadOfficeNo IS NOT NULL
  AND src.HeadOfficeNo <> 0;