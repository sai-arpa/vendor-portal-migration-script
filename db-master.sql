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
    code,
    db_description,
    db_name,
    status_id,
    db_connection_name,
    first_indent_fetch_date,
    last_indent_fetch_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    DBNo,
    TRIM(Code),
    TRIM(DBDescription),
    TRIM(DBName),
    1,
    COALESCE(TRIM(DBConnectionName), TRIM(DBName)),
    migration.parse_sqlserver_datetime(IndentFetchStartDate),
    migration.parse_sqlserver_datetime(LastIndentFetchDate),
    1,
    now(),
    1,
    now()
FROM sqlserver_fdw.mdbmaster;