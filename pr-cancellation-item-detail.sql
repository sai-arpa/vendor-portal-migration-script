CREATE FOREIGN TABLE sqlserver_fdw.changeindentstatusitemdetail
(
    changeindentstatusitemdetailno integer,
    changeindentstatusno integer,
    indentitemlineno numeric(10,3),
    itemno integer,
    makeno smallint,
    statusno smallint,
    reason varchar(500),
    cancelqty numeric(15,3)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'ChangeIndentStatusItemdetail'
);