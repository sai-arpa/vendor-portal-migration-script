CREATE FOREIGN table if not exists sqlserver_fdw.mdbmaster
(
    DBNo smallint,
    DBName varchar(100),
    Code varchar(50),
    DBDescription varchar(500),
    DBConnectionName varchar(200),
    IndentFetchStartDate text,
    LastIndentFetchDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDBMaster'
);

INSERT INTO masterdata.db_master
(
    id,
    db_name,
    code,
    db_description,
    db_connection_name,
    first_indent_fetch_date,
    last_indent_fetch_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    d.DBNo,
    TRIM(d.DBName),
    TRIM(d.Code),
    d.DBDescription,
    d.DBConnectionName,
    migration.parse_sqlserver_datetime(d.IndentFetchStartDate),
    migration.parse_sqlserver_datetime(d.LastIndentFetchDate),
    1 AS created_by_id,
    now() AS created_date,
    1 AS modified_by_id,
    now() AS modified_date,
    1::smallint AS status_id,
    NULL AS status_remarks
FROM sqlserver_fdw.mdbmaster d;