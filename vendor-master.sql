CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mvendorcard
(
    VendorNo INTEGER,
    Code VARCHAR(7),
    VendorName VARCHAR(100),
    CreatedDate TEXT,
    ModifiedDate TEXT,
    MailingName VARCHAR(100),
    VendorTypeNo INTEGER,
    GVendorTypeNo INTEGER
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mVendorCard'
);

INSERT INTO masterdata.vendor_master
(
    id,
    code,
    vendor_name,
    legal_name,
    bp_type_id,
    rating,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    VendorNo,
    LEFT(
        TRIM(COALESCE(Code, '')),
        8
    ) AS code,
    LEFT(
        TRIM(COALESCE(VendorName, '')),
        150
    ) AS vendor_name,
    LEFT(
        TRIM(COALESCE(MailingName, '')),
        150
    ) AS legal_name,
    CASE WHEN gvendorTypeNo=6 THEN 1 ELSE 2 end,
    NULL AS rating,
    1 AS created_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ) AS created_date,
    1 AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ) AS modified_date
FROM sqlserver_fdw.mvendorcard;


--UPDATE masterdata.vendor_master vm
--SET bp_type_id = 1
--FROM sqlserver_fdw.mvendorcard vc
--WHERE vm.id = vc.VendorNo
--  AND vc.GVendorTypeNo = 6;

--
--select code, count(1) from sqlserver_fdw.mvendorCard
--group by code
--having count(1)>1
--
--select * from sqlserver_fdw.mvendorCard
--where code in ('VC10848', 'VC10849', 'VC10850', 'VC10851', 'VC10852')
--
--select * from sqlserver_fdw.mvendorcard where vendorNo in (975,976,974, 977, 978)
--
--select * from sqlserver_fdw.mvendorcard order by vendorno desc limit 1
--


--select count(*) from masterdata.vendor_master vm
--inner join masterdata.vendor_master_location_detail vld
--on vm.id =vld.vendor_id 
--where vm.bp_type_id =1