CREATE FOREIGN table if not exists sqlserver_fdw.mcitymaster
(
    CityNo integer,
    Code varchar(50),
    CityName varchar(200),
    StateNo smallint,
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mCityMaster'
);

INSERT INTO masterdata.city_master
(
    id,
    code,
    city_name,
    state_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    CityNo,
    TRIM(Code),
    TRIM(CityName),
    StateNo,
    COALESCE(CreatedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(Inactive,FALSE)
        THEN 2
        ELSE 1
    END,
    CASE
    	WHEN Inactive THEN 'inactive'
	END AS status_remarks
FROM sqlserver_fdw.mcitymaster;