CREATE FOREIGN table if not exists sqlserver_fdw.mdivisionmaster
(
    DivisionNo integer,
    DivisionCode varchar(50),
    DivisionName varchar(500),
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
    table_name 'mDivisionMaster'
);

INSERT INTO masterdata.division_master
(
    id,
    code,
    division_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    d.DivisionNo,
    TRIM(d.DivisionCode),
    TRIM(d.DivisionName),
    COALESCE(d.CreatedBy, 1) AS created_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(d.CreatedDate),
        now()
    ),
    COALESCE(d.ModifiedBy, 1) AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(d.ModifiedDate),
        migration.parse_sqlserver_datetime(d.CreatedDate),
        now()
    ),
    CASE
        WHEN COALESCE(d.Inactive,FALSE)
            THEN 2::smallint
        ELSE 1::smallint
    END,
    CASE
    	WHEN Inactive THEN 'inactive'
	END AS status_remarks
FROM sqlserver_fdw.mdivisionmaster d;