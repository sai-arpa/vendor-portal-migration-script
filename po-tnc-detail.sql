CREATE FOREIGN TABLE sqlserver_fdw.poamendmenttermsnconditiondetail
(
    poamendmenttermsdetailno integer,
    poamendmentno integer,
    termsnconditionheadno smallint,
    termsncondition varchar(300)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentTermsNConditionDetail'
);

INSERT INTO purchase.purchase_order_terms_n_condition_detail
(
    id,
    po_id,
    tnc_head_id,
    value
)
OVERRIDING SYSTEM VALUE
SELECT
    potc.poamendmenttermsdetailno,
    potc.poamendmentno,
    potc.termsnconditionheadno,
    LEFT(TRIM(COALESCE(potc.termsncondition, '')), 1000)
FROM sqlserver_fdw.poamendmenttermsnconditiondetail potc;