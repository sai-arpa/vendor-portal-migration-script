CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mprioritymaster
(
    PriorityNo smallint,
    PriorityName varchar(100),
    Code char(6),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mPriorityMaster');

INSERT INTO masterdata.priority_master
(
    id,
    priority_name,
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
    p.PriorityNo,
    LEFT(TRIM(p.PriorityName), 100),
    LEFT(TRIM(p.Code), 6),
    COALESCE(p.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(p.CreatedDate),
        now()
    ),
    p.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(p.ModifiedDate),
        migration.parse_sqlserver_datetime(p.CreatedDate),
        now()
    ),
    1::smallint,
    NULL
FROM sqlserver_fdw.mprioritymaster p;