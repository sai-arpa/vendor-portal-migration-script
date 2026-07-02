CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mtermsnconditiongroupdetail
(
    TermsNConditionGroupDetailNo INTEGER,
    TermsNConditionGroupNo SMALLINT,
    HeadNo SMALLINT,
    Value VARCHAR(100)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mTermsNConditionGroupDetail'
);

INSERT INTO masterdata.terms_n_condition_group_detail
(
    id,
    tnc_group_id,
    tnc_head_id,
    tnc_value
)
OVERRIDING SYSTEM VALUE
SELECT
    TermsNConditionGroupDetailNo,
    TermsNConditionGroupNo,
    HeadNo,
    LEFT(TRIM(COALESCE(Value, '')), 1000)
FROM sqlserver_fdw.mtermsnconditiongroupdetail;