CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.revisedquotationtermsnconditiondetail
(
    RevisedQuotationTermsDetailNo INTEGER,
    RevisedQuotationNo INTEGER,
    TermsNConditionHeadNo INTEGER,
    TermsNCondition VARCHAR(300)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'RevisedQuotationTermsNConditionDetail'
);

INSERT INTO purchase.quotation_terms_condition_detail
(
    id,
    quotation_id,
    tnc_head_id,
    tnc_value
)
OVERRIDING SYSTEM VALUE
SELECT
    t.RevisedQuotationTermsDetailNo,
    t.RevisedQuotationNo,
    t.TermsNConditionHeadNo,
    LEFT(
        TRIM(COALESCE(t.TermsNCondition, '')),
        300
    )
FROM sqlserver_fdw.revisedquotationtermsnconditiondetail t
INNER JOIN purchase.quotation_main q
    ON q.id = t.RevisedQuotationNo;