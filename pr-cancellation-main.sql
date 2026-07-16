CREATE FOREIGN TABLE sqlserver_fdw.changeindentstatusmain
(
    companyno smallint,
    yearno smallint,
    changeindentstatusno integer,
    divisionno integer,
    documentnoyearly varchar(30),
    documentdate text,
    indentno integer,
    statusno smallint,
    reason varchar(1000),
    createdby smallint,
    createddate text,
    modifiedby smallint,
    modifieddate text,
    authorizedby smallint,
    authorizeddate text,
    documentstatusno smallint,
    isinserted integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'ChangeIndentStatusMain'
);