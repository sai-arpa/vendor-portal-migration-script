
CREATE FOREIGN TABLE sqlserver_fdw.mduplicateitemgroupdetail
(
    DupDetailNo integer,
    DItemGroupNo integer,
    ItemNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDuplicateItemGroupDetail'
);

INSERT INTO utility.duplicate_item_group_detail
(
    id,
    group_id,
    item_id
)
OVERRIDING SYSTEM VALUE
SELECT
    DupDetailNo,
    DItemGroupNo,
    ItemNo
FROM sqlserver_fdw.mduplicateitemgroupdetail;
