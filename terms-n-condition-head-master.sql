CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mtermsnconditionhead
(
    TermsNConditionHeadNo SMALLINT,
    Code CHAR(6),
    TermsNConditionHeadName VARCHAR(50),
    IsCompulsary BIT,
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mTermsNConditionHead'
);

INSERT INTO masterdata.terms_n_condition_head_master
(
    id,
    code,
    tnc_head_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    is_compulsory,
    is_default
)
OVERRIDING SYSTEM VALUE
SELECT
    TermsNConditionHeadNo,
    LEFT(TRIM(COALESCE(Code, '')), 6),
    LEFT(TRIM(COALESCE(TermsNConditionHeadName, '')), 100),
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
    1::smallint,
    NULL,
    CASE
        WHEN IsCompulsary = B'1' THEN TRUE
        ELSE FALSE
    END,
    FALSE
FROM sqlserver_fdw.mtermsnconditionhead;