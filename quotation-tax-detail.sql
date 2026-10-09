CREATE FOREIGN TABLE sqlserver_fdw.revisedquotationtaxdetail
(
    RevisedQuotationTaxNo integer,
    RevisedQuotationNo    integer,
    MiscChargeNo   smallint,
    ChargeType     smallint,
    Nature         smallint,
    ChargeOn       smallint,
    ChargeValue    numeric(10,3),
    TotalValue     numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RevisedQuotationTaxDetail'
);

CREATE FOREIGN TABLE sqlserver_fdw.revisedquotationotherchargedetail
(    
    RQOtherChargeNo integer,
    RevisedQuotationNo    integer,
    OtherChargeNo   smallint,
    Description     text,
    Amount       numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'RevisedQuotationOtherChargeDetail'
);



INSERT INTO purchase.quotation_tax_detail
(
    quotation_id,
    tax_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount,
    nature_id
)-- From QuotationTaxDetail
SELECT
    qtd.RevisedQuotationNo AS quotation_id,
    qtd.MiscChargeNo AS tax_id,
    qtd.ChargeType AS charge_type_id,
    case qtd.ChargeOn
        WHEN 1 THEN 2
        WHEN 2 THEN 1
    END,
    qtd.ChargeValue AS charge_value,
    qtd.TotalValue AS amount,
    qtd.Nature AS nature_id
FROM sqlserver_fdw.revisedquotationtaxdetail qtd     --347277
WHERE EXISTS (
    SELECT 1 FROM purchase.quotation_main qm WHERE qm.id = qtd.RevisedQuotationNo
)
UNION ALL -- From QuotationOtherChargeDetail
SELECT
    qocd.RevisedQuotationNo AS quotation_id,
    CASE qocd.OtherChargeNo
        WHEN 1 THEN 103
        WHEN 2 THEN 105
        WHEN 3 THEN 104
    	WHEN 4 THEN 106
    	WHEN 5 THEN 107
    END AS tax_id,
    2 AS charge_type_id,
    2 AS charge_on_id,
    qocd.Amount AS charge_value,
    qocd.Amount AS amount,
    2 AS nature_id
FROM sqlserver_fdw.revisedquotationotherchargedetail qocd --3489
WHERE EXISTS (
    SELECT 1 FROM purchase.quotation_main qm WHERE qm.id = qocd.RevisedQuotationNo
) AND qocd.amount > 0;

