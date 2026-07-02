CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcompanymasterlocationdetail
(
    CompanyMasterLocationNo integer,
    CompanyNo smallint,
    ShippingAddress varchar(300),
    Code varchar(7),
    ERPUniqueID varchar(10),
    IsDefault boolean
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mCompanyMasterLocationDetail');

INSERT INTO masterdata.company_master_location_detail
(
    id,
    code,
    company_id,
    address1,
    address2,
    address3,
    city_id,
    state_id,
    country_id,
    pincode,
    full_address,
    contact_no,
    contact_no_country_id,
    is_default,
    status_id,
    status_remarks,
    erp_location_unique_id_1,
    erp_location_unique_id_2,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    m.CompanyMasterLocationNo,
    LEFT(TRIM(m.Code), 6),
    m.CompanyNo,
    LEFT(COALESCE(m.ShippingAddress, ''), 150),
    NULL AS address2,
    NULL AS address3,
    c.city_id,
    c.state_id,
    c.country_id,
    NULL AS pincode,
    LEFT(COALESCE(m.ShippingAddress, ''), 500) AS full_address,
    c.contact_no,
    CASE WHEN c.contact_no IS NOT NULL THEN 2 ELSE null end,
    COALESCE(m.IsDefault, FALSE),
    1::smallint AS status_id,
    NULL AS status_remarks,
    m.ERPUniqueID,
    NULL AS erp_location_unique_id_2,
    1 AS created_by_id,
    now() AS created_date,
    1 AS modified_by_id,
    now() AS modified_date
FROM sqlserver_fdw.mcompanymasterlocationdetail m
INNER JOIN masterdata.company_master c
    ON c.id = m.CompanyNo;