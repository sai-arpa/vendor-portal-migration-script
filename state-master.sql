CREATE FOREIGN TABLE sqlserver_fdw.mstatemaster
(
    StateNo smallint,
    Code varchar(50),
    StateName varchar(200),
    CountryNo smallint,
    GSTStateCode varchar(50),
    IsUnionTerritory boolean,
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
    table_name 'mStateMaster'
);

INSERT INTO masterdata.state_master
(
    id,
    code,
    state_name,
    country_id,
    gst_state_code,
    is_union_territory,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    StateNo,
    TRIM(Code),
    TRIM(StateName),
    CountryNo,
    GSTStateCode,
    COALESCE(IsUnionTerritory,FALSE),
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
FROM sqlserver_fdw.mstatemaster;