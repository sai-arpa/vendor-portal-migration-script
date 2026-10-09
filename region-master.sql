CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mregionmaster
(
    RegionNo smallint,
    RegionName varchar(50),
    Code char(6),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mRegionMaster');

INSERT INTO masterdata.region_master
(
    id,
    region_name,
    code,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    r.RegionNo,
    LEFT(TRIM(r.RegionName), 100),
    LEFT(TRIM(r.Code), 6),
    COALESCE(r.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
    r.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(r.ModifiedDate),
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
    1::smallint,
    NULL
FROM sqlserver_fdw.mregionmaster r;