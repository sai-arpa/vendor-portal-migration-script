CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mtermsnconditiongroup
(
    TermsNConditionGroupNo SMALLINT,
    Code CHAR(6),
    TermsNConditionGroupName VARCHAR(50),
    Inactive BIT,
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mTermsNConditionGroup'
);

INSERT INTO masterdata.terms_n_condition_group_master
(
    id,
    code,
    tnc_group_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    is_po_default,
    is_rfq_default
)
OVERRIDING SYSTEM VALUE
SELECT
    TermsNConditionGroupNo,
    LEFT(TRIM(COALESCE(Code, '')), 6),
    LEFT(TRIM(COALESCE(TermsNConditionGroupName, '')), 50),
    COALESCE(CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy, CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    CASE
        WHEN Inactive = B'1' THEN 2::smallint
        ELSE 1::smallint
    END,
    CASE
        WHEN Inactive = B'1' THEN 'inactive'
        ELSE NULL
    END,
    FALSE,
    FALSE
FROM sqlserver_fdw.mtermsnconditiongroup;