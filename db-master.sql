CREATE FOREIGN TABLE sqlserver_fdw.mdbmaster
(
    DBNo integer,
    Code varchar(10),
    DBDescription varchar(300),
    DBName varchar(100),
    Inactive boolean,
    DBConnectionName varchar(300),
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
    CASE
        WHEN COALESCE(Inactive, FALSE)
        THEN 2
        ELSE 1
    END,
    COALESCE(TRIM(DBConnectionName), TRIM(DBName)),
    migration.parse_sqlserver_datetime(IndentFetchStartDate),
    migration.parse_sqlserver_datetime(LastIndentFetchDate),
    1,
    now(),
    1,
    now()
FROM sqlserver_fdw.mdbmaster;