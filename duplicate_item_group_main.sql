CREATE FOREIGN TABLE sqlserver_fdw.mduplicateitemgroup
(
    DItemGroupNo integer,
    Code varchar(8),
    GroupName varchar(600),
    InActive boolean,
    CreatedBy integer,
    CreatedDate text,
    ModifiedBy integer,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mDuplicateItemGroup'
);

INSERT INTO utility.duplicate_item_group_main
(
    id,
    code,
    group_name,
    status_id,
    status_remarks,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    DItemGroupNo,
    TRIM(Code),
    TRIM(GroupName),
    CASE
        WHEN COALESCE(InActive, FALSE)
        THEN 2
        ELSE 1
    END,
    NULL,
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    )
FROM sqlserver_fdw.mduplicateitemgroup;
