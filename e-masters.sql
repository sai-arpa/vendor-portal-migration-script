---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------
---Category Master

CREATE FOREIGN table if not exists sqlserver_fdw.ecategorymaster
(
    ERPCategoryNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    CategoryName    varchar(100),
    Alias           varchar(50),
    CategoryNo      smallint,
    DBNo            smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCategoryMaster'
);


INSERT INTO erpmaster.e_category_master
(
    id,
    category_name,
    alias,
    vp_category_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
overriding system value
SELECT
    e.ERPCategoryNo,
    e.CategoryName,
    e.Alias,
    e.CategoryNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    migration.parse_sqlserver_datetime(e.CreatedDate),
    migration.parse_sqlserver_datetime(coalesce(e.ModifiedDate, e.CreatedDate)),
    e.Inactive
FROM sqlserver_fdw.ecategorymaster e;



---------------------------------------------------------
---Country master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecountrymaster
(
    ERPCountryNo    smallint,
    Code            varchar(10),
    CountryName     varchar(100),
    DBNo            smallint,
    CountryNo       smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    ERPUniqueValue  varchar(10)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCountryMaster'
);

INSERT INTO erpmaster.e_country_master
(
    id,
    country_name,
    vp_country_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCountryNo,
    e.CountryName,
    e.CountryNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.ecountrymaster e;


---------------------------------------------------------
---State master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.estatemaster
(
    ERPStateNo      smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    StateName       varchar(100),
    ERPCountryNo    smallint,
    DBNo            smallint,
    StateNo         smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eStateMaster'
);


INSERT INTO erpmaster.e_state_master
(
    id,
    state_name,
    vp_state_id,
    e_country_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPStateNo,
    e.StateName,
    e.StateNo,
    e.ERPCountryNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.estatemaster e;


---------------------------------------------------------
---City Master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecitymaster
(
    ERPCityNo       smallint,
    ERPUniqueValue  varchar(20),
    Code            varchar(20),
    CityName        varchar(100),
    ERPStateNo      smallint,
    DBNo            smallint,
    CityNo          integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCityMaster'
);


INSERT INTO erpmaster.e_city_master
(
    id,
    city_name,
    e_state_id,
    vp_city_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCityNo,
    e.CityName,
    e.ERPStateNo,
    e.CityNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.ecitymaster e;


--------------------------------------------------------
----division master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.edivisionmaster
(
    ERPDivisionNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    DivisionName    varchar(100),
    DBNo            smallint,
    DivisionNo      integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    CompanyNo       smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eDivisionMaster'
);

INSERT INTO erpmaster.e_division_master
(
    id,
    division_name,
    vp_division_id,
    vp_company_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPDivisionNo,
    e.DivisionName,
    e.DivisionNo,
    e.CompanyNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.edivisionmaster e;


---------------------------------------------------------
---Cost center Master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecostcentermaster
(
    ERPCostCenterNo       integer,
    ERPUniqueValue        varchar(10),
    Code                  varchar(10),
    CostCenterName        varchar(100),
    ERPParentCostCenterNo integer,
    DBNo                  smallint,
    CostCenterNo          integer,
    CreatedDate           text,
    ModifiedDate          text,
    Inactive              boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCostCenterMaster'
);


INSERT INTO erpmaster.e_cost_center_master
(
    id,
    cost_center_name,
    e_parent_cost_center_id,
    vp_cost_center_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCostCenterNo,
    e.CostCenterName,
    e.ERPParentCostCenterNo,
    e.CostCenterNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.ecostcentermaster e;


---------------------------------------------------------
---Cost Center Company Detail

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecostcentercompanydetail
(
    CostCenterCompanyDetailNo  integer,
    ERPCostCenterNo            integer,
    ERPDivisionNo              smallint,
    CompanyNo                  smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCostCenterCompanyDetail'
);


INSERT INTO erpmaster.e_cost_center_company_detail
(
    id,
    e_cost_center_id,
    e_division_id,
    vp_company_id
)
OVERRIDING SYSTEM VALUE
SELECT
    e.CostCenterCompanyDetailNo,
    e.ERPCostCenterNo,
    e.ERPDivisionNo,
    e.CompanyNo
FROM sqlserver_fdw.ecostcentercompanydetail e;



---------------------------------------------------------
---Currency master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.ecurrencymaster
(
    ERPCurrencyNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    CurrencyName    varchar(50),
    Notation        varchar(10),
    DBNo            smallint,
    CurrencyNo      smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eCurrencyMaster'
);


INSERT INTO erpmaster.e_currency_master
(
    id,
    currency_name,
    notation,
    vp_currency_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPCurrencyNo,
    e.CurrencyName,
    e.Notation,
    e.CurrencyNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.ecurrencymaster e;



---------------------------------------------------------
---Unit master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.eunitmaster
(
    ERPUnitNo       smallint,
    Code            varchar(10),
    UnitName        varchar(100),
    DBNo            smallint,
    UnitNo          smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    ERPUniqueValue  varchar(10),
    Alias           varchar(6)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eUnitMaster'
);

INSERT INTO erpmaster.e_unit_master
(
    id,
    unit_name,
    alias,
    vp_unit_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPUnitNo,
    e.UnitName,
    e.Alias,
    e.UnitNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.eunitmaster e;


---------------------------------------------------------
---Department master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.edeptmaster
(
    ERPDeptNo       smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    DeptName        varchar(100),
    ERPDivisionNo   smallint,
    DBNo            smallint,
    DeptNo          integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    CompanyNo       smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eDeptMaster'
);


INSERT INTO erpmaster.e_department_master
(
    id,
    department_name,
    vp_department_id,
    e_division_id,
    vp_company_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPDeptNo,
    e.DeptName,
    e.DeptNo,
    e.ERPDivisionNo,
    e.CompanyNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        NOW()
    ),
    e.Inactive
FROM sqlserver_fdw.edeptmaster e;

---------------------------------------------------------
---Group master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.egroupmaster
(
    ERPGroupNo       smallint,
    ERPCategoryNo    smallint,
    ERPUniqueValue   varchar(10),
    Code             varchar(10),
    GroupName        varchar(100),
    Alias            varchar(50),
    GroupNo          smallint,
    DBNo             smallint,
    CreatedDate      text,
    ModifiedDate     text,
    Inactive         boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eGroupMaster'
);


INSERT INTO erpmaster.e_group_master
(
    id,
    group_name,
    e_category_id,
    alias,
    vp_group_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPGroupNo,
    e.GroupName,
    e.ERPCategoryNo,
    coalesce(e.Alias,e.GroupName),
    e.GroupNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.egroupmaster e;


---------------------------------------------------------
---Item master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.eitemmaster
(
    ERPItemNo         integer,
    ERPUniqueValue    varchar(10),
    Code              varchar(10),
    ItemName          varchar(200),
    Size              varchar(100),
    Grade             varchar(100),
    ERPUnitNo         smallint,
    ItemNatureNo      smallint,
    DBNo              smallint,
    ItemNo            integer,
    CreatedDate       text,
    ModifiedDate      text,
    Inactive          boolean,
    GroupName         varchar(100),
    SubGroupName      varchar(100),
    ItemDescription   varchar(600),
    HSNSACCode        varchar(8),
    ERPSubGroupNo     smallint,
    PurchaseEmpCode   varchar(5)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eItemMaster'
);


INSERT INTO erpmaster.e_item_master
(
    id,
    item_name,
    e_unit_id,
    vp_item_id,
    item_nature,
    category_name,
    group_name,
    subgroup_name,
    hsn_sac_code,
    purchase_emp_code,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPItemNo,
    e.ItemName,
    e.ERPUnitNo,
    e.ItemNo,
    e.ItemNatureNo,
    null,
    e.GroupName,
    e.SubGroupName,
    e.HSNSACCode,
    e.PurchaseEmpCode,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.eitemmaster e;


---------------------------------------------------------
---Location master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.elocationmaster
(
    ERPLocationNo    smallint,
    ERPUniqueValue   varchar(10),
    Code             varchar(10),
    LocationName     varchar(100),
    ERPCityNo        smallint,
    DBNo             smallint,
    LocationNo       smallint,
    CreatedDate      text,
    ModifiedDate     text,
    Inactive         boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eLocationMaster'
);


INSERT INTO erpmaster.e_location_master
(
    id,
    location_name,
    vp_location_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPLocationNo,
    e.LocationName,
    e.LocationNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.elocationmaster e;


---------------------------------------------------------
---Make master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.emakemaster
(
    ERPMakeNo        smallint,
    Code             varchar(10),
    MakeName         varchar(100),
    CreatedDate      text,
    ModifiedDate     text,
    Inactive         boolean,
    DBNo             smallint,
    MakeNo           smallint,
    ERPUniqueValue   varchar(10)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eMakeMaster'
);


INSERT INTO erpmaster.e_make_master
(
    id,
    make_name,
    vp_make_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPMakeNo,
    e.MakeName,
    e.MakeNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.emakemaster e;


---------------------------------------------------------
---Region master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.eregionmaster
(
    ERPRegionNo     smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    RegionName      varchar(100),
    DBNo            smallint,
    RegionNo        smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eRegionMaster'
);

INSERT INTO erpmaster.e_region_master
(
    id,
    region_name,
    vp_region_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPRegionNo,
    e.RegionName,
    e.RegionNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.eregionmaster e;






---------------------------------------------------------
---Subgroup master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.esubgroupmaster
(
    ERPSubGroupNo   smallint,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    ERPGroupNo      smallint,
    SubGroupName    varchar(100),
    Alias           varchar(50),
    SubGroupNo      smallint,
    DBNo            smallint,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eSubGroupMaster'
);

INSERT INTO erpmaster.e_subgroup_master
(
    id,
    subgroup_name,
    e_group_id,
    alias,
    vp_subgroup_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPSubGroupNo,
    e.SubGroupName,
    e.ERPGroupNo,
    coalesce(e.Alias,e.SubGroupName),
    e.SubGroupNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.esubgroupmaster e;


---------------------------------------------------------
---Termsn N Condition Head master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.etermsnconditionhead
(
    ERPTermsNConditionHeadNo  smallint,
    ERPUniqueValue            varchar(10),
    Code                      varchar(10),
    TermsNConditionHeadName   varchar(50),
    DBNo                      smallint,
    TermsNConditionHeadNo     smallint,
    CreatedDate               text,
    ModifiedDate              text,
    Inactive                  boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eTermsNConditionHead'
);


INSERT INTO erpmaster.e_terms_n_condition_head_master
(
    terms_n_condition_head_name,
    vp_tnc_head_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
SELECT
    e.TermsNConditionHeadName,
    e.TermsNConditionHeadNo,
    e.Code,
    e.ERPColumnName,
    6,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    false
FROM sqlserver_fdw.mTermsNConditionHead e;


---------------------------------------------------------
---Vendor master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.evendorcard
(
    ERPVendorNo     integer,
    ERPUniqueValue  varchar(10),
    Code            varchar(10),
    VendorName      varchar(100),
    DBNo            smallint,
    VendorNo        integer,
    CreatedDate     text,
    ModifiedDate    text,
    Inactive        boolean,
    GVendorTypeNo   smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eVendorCard'
);

INSERT INTO erpmaster.e_vendor_master
(
    id,
    vendor_name,
    vp_vendor_id,
    vp_bp_type_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPVendorNo,
    e.VendorName,
    e.VendorNo,
    case when e.GVendorTypeNo=6 then 2 else e.GVendorTypeNo end,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.evendorcard e;


---------------------------------------------------------
---Vendor Location master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.evendorlocationdetail
(
    ERPVendorLocationNo   integer,
    ERPUniqueValue        varchar(10),
    Code                  varchar(10),
    VendorName             varchar(100),
    Address1               varchar(100),
    Address2               varchar(100),
    Address3               varchar(100),
    City                   varchar(100),
    State                  varchar(100),
    Country                varchar(100),
    Pincode                varchar(6),
    PhoneNo                varchar(100),
    Email                  varchar(300),
    Website                varchar(100),
    CINNo                  varchar(30),
    GSTINNo                varchar(30),
    PANNo                  varchar(35),
    ERPBusinessTypeNo      smallint,
    ERPVendorTypeNo        smallint,
    ERPManufacturingTypeNo smallint,
    ERPCityNo              integer,
    ERPStateNo              smallint,
    ERPCountryNo            smallint,
    DBNo                    smallint,
    VendorLocationNo        integer,
    CreatedDate             text,
    ModifiedDate            text,
    Inactive                boolean,
    ERPUniqueValue2         varchar(10),
    ModifiedBy              smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eVendorLocationDetail'
);


INSERT INTO erpmaster.e_vendor_location_master
(
    id,
    e_vendor_id,
    erp_unique_value2,
    address1,
    address2,
    address3,
    e_city_id,
    e_state_id,
    e_country_id,
    contact_no,
    email,
    website,
    cin_no,
    gstin_no,
    pan_no,
    vp_vendor_location_id,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPVendorLocationNo,
    e2.erpVendorNo,
    e.ERPUniqueValue2,
    e.Address1,
    e.Address2,
    e.Address3,
    e.ERPCityNo,
    e.ERPStateNo,
    e.ERPCountryNo,
    Left(e.PhoneNo,20),
    e.Email,
    e.Website,
    e.CINNo,
    e.GSTINNo,
    e.PANNo,
    e.VendorLocationNo,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.evendorlocationdetail e
left join sqlserver_fdw.evendorcard e2 
on e.erpuniquevalue = e2.erpuniquevalue and e.dbno = e2.dbno;

-------------
--business type master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.evendorbusinesstypemaster
(
    ERPVendorBusinessTypeNo  smallint,
    ERPUniqueValue           varchar(10),
    Code                     varchar(10),
    VendorBusinessTypeName   varchar(100),
    DBNo                     smallint,
    VendorBusinessTypeNo     smallint,
    CreatedDate              text,
    ModifiedDate              text,
    Inactive                 boolean
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'ERPMaster',
    table_name 'eVendorBusinessTypeMaster'
);


INSERT INTO erpmaster.e_business_type_master
(
    id,
    business_type_name,
    code,
    erp_unique_value,
    db_id,
    created_date,
    modified_date,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.ERPVendorBusinessTypeNo,
    e.VendorBusinessTypeName,
    e.Code,
    e.ERPUniqueValue,
    e.DBNo,
    COALESCE(
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    COALESCE(
        migration.parse_sqlserver_datetime(e.ModifiedDate),
        migration.parse_sqlserver_datetime(e.CreatedDate),
        TIMESTAMPTZ '2018-01-01 00:00:00+05:30'
    ),
    e.Inactive
FROM sqlserver_fdw.evendorbusinesstypemaster e;


----------
--- Add on Master

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.addonmaster
(
    AddOnMasterNo  smallint,
    AddOnCode      varchar(5),
    SNo            smallint,
    AFCode         varchar(5),
    AFRateI        varchar(1),
    AFLOGIC        varchar(18)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'AddOnMaster'
);


INSERT INTO erpmaster.e_add_on_master
(
    id,
    addon_code,
    s_no,
    af_code,
    af_rate_type,
    af_logic
)
OVERRIDING SYSTEM VALUE
SELECT
    e.AddOnMasterNo,
    e.AddOnCode,
    e.SNo,
    e.AFCode,
    e.AFRateI,
    e.AFLOGIC
FROM sqlserver_fdw.addonmaster e;

--------------------------------------------------------------Transactions----------------------------------------------------------------------------------------
-------------------- PR Main

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.realindentmain
(
    IndentNo            integer,
    EntityCode          varchar(4),
    FY                  varchar(5),
    DocumentNoYearly    varchar(30),
    DocumentDate        text,
    TCode               varchar(1),
    IndentType          varchar(1),
    Department          varchar(10),
    Division            varchar(10),
    PortalIndentNo      integer,
    DBNo                smallint,
    RequestedBy         varchar(100),
    Remark              varchar(1000),
    Priority            varchar(300),
    ERPCreatedDate      text,
    ERPAuthorizedDate   text,
    InformTo            varchar(4000),
    RefDocNo            varchar(50),
    RefDocDate          text
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'RealIndentMain'
);


INSERT INTO erpinventory.pr_main
(
    id,
    vp_pr_id,
    entity_code,
    fy,
    doc_no_yearly,
    doc_date,
    t_code,
    indent_type,
    erp_department_uv,
    erp_division_uv,
    requested_by,
    remark,
    priority,
    erp_created_date,
    erp_authorized_date,
    inform_to,
    ref_doc_no,
    ref_doc_date,
    db_id,
    inactive
)
OVERRIDING SYSTEM VALUE
SELECT
    e.IndentNo,
    e.PortalIndentNo,
    e.EntityCode,
    e.FY,
    e.DocumentNoYearly,
    migration.parse_sqlserver_datetime(e.DocumentDate)::date,
    e.TCode,
    coalesce(e.IndentType,'R'),
    e.Department,
    e.Division,
    e.RequestedBy,
    e.Remark,
    e.Priority,
    TIMESTAMPTZ '2018-01-01 00:00:00+05:30',
    TIMESTAMPTZ '2018-01-01 00:00:00+05:30',
    e.InformTo,
    e.RefDocNo,
    TIMESTAMPTZ '2018-01-01 00:00:00+05:30',
    e.DBNo,
    false
FROM sqlserver_fdw.realindentmain e;

-----------------------------------------------------
-------------------- PR Item Detail

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.realindentbody
(
    IndentDetailNo           integer,
    IndentNo                 integer,
    SLNo                     numeric(10,3),
    ItemCode                 varchar(10),
    MakeCode                 varchar(10),
    TechSpecification        varchar(1000),
    RequiredQty              numeric(15,3),
    IndentQty                numeric(15,3),
    Rate                     numeric(19,4),
    Amount                   numeric(19,4),
    CostCenter               varchar(10),
    PortalIndentNo           integer,
    PortalIndentItemDetailNo integer,
    DueDate                  text,
    Remarks                  varchar(500)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'RealIndentBody'
);


INSERT INTO erpinventory.pr_item_detail
(
    id,
    c_pr_id,
    line_no,
    erp_item_uv,
    erp_make_uv,
    tech_specification,
    required_qty,
    indent_qty,
    rate,
    amount,
    erp_cost_center_uv,
    vp_pr_id,
    vp_pr_item_detail_id,
    due_date,
    remarks,
    db_id
)
OVERRIDING SYSTEM VALUE
SELECT
    e.IndentDetailNo,
    e.IndentNo,
    e.SLNo,
    e.ItemCode,
    e.MakeCode,
    e.TechSpecification,
    coalesce(e.RequiredQty,e.IndentQty),
    e.IndentQty,
    e.Rate,
    e.Amount,
    e.CostCenter,
    e.PortalIndentNo,
    e.PortalIndentItemDetailNo,
    migration.parse_sqlserver_datetime(e.DueDate)::date,
    e.Remarks,
    6
FROM sqlserver_fdw.realindentbody e;

----------------------------------------------
-----Pr Item Detail Recent


CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.realindentbodyrecent
(
    DocumentNoYearly  varchar(30),
    DocumentDate      text,
    SLNo              numeric(10,3),
    ItemCode          varchar(10),
    MakeCode          varchar(10),
    EntityCode        varchar(4),
    DueDate           text,
    DBNo              smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Customize',
    table_name 'RealIndentBodyRecent'
);


INSERT INTO erpinventory.pr_item_detail_recent
(
    document_no_yearly,
    document_date,
    sl_no,
    erp_item_uv,
    erp_make_uv,
    entity_code,
    due_date,
    db_no
)
SELECT
    e.DocumentNoYearly,
    migration.parse_sqlserver_datetime(e.DocumentDate)::date,
    e.SLNo,
    e.ItemCode,
    e.MakeCode,
    e.EntityCode,
    migration.parse_sqlserver_datetime(e.DueDate)::date,
    e.DBNo
FROM sqlserver_fdw.realindentbodyrecent e;
