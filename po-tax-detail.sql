BEGIN;
CREATE FOREIGN TABLE sqlserver_fdw.poamendmenttaxdetail
(
    POAmendmentTaxNo integer,
    POAmendmentNo    integer,
    MiscChargeNo     smallint,
    ChargeType       smallint,
    Nature           smallint,
    ChargeOn         smallint,
    ChargeValue      numeric(10,3),
    TotalValue       numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentTaxDetail'
);

CREATE FOREIGN TABLE sqlserver_fdw.poamendmentotherchargedetail
(
    POAmendmentOtherChargeNo integer,
    POAmendmentNo            integer,
    OtherChargeNo            smallint,
    Description              text,
    Amount                   numeric(18,2)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'POAmendmentOtherChargeDetail'
);


INSERT INTO  purchase.purchase_order_tax_detail
(
    po_id,
    tax_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount,
    nature_id   ---Need to update to nature_id
)-- From POAmendmentTaxDetail
SELECT
    patd.POAmendmentNo AS purchase_order_id,
    patd.MiscChargeNo AS tax_id,
    2 AS charge_type_id,
    case patd.ChargeOn
        WHEN 1 THEN 2
        WHEN 2 THEN 1
    END,
    patd.ChargeValue AS charge_value,
    patd.TotalValue AS amount,
    patd.Nature AS nature_id
FROM sqlserver_fdw.poamendmenttaxdetail patd
WHERE EXISTS (
    SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = patd.POAmendmentNo
)
UNION ALL -- From POAmendmentOtherChargeDetail
SELECT
    paocd.POAmendmentNo AS purchase_order_id,
    CASE paocd.OtherChargeNo
        WHEN 1 THEN 103
        WHEN 2 THEN 105
        WHEN 3 THEN 104
    		WHEN 4 THEN 106
    		WHEN 5 THEN 107
    END AS tax_id,
    2 AS charge_type_id,
    2 AS charge_on_id,
    paocd.Amount AS charge_value,
    paocd.Amount AS amount,
    2 AS nature_id
FROM sqlserver_fdw.poamendmentotherchargedetail paocd
WHERE EXISTS (
    SELECT 1 FROM purchase.purchase_order_main pom WHERE pom.id = paocd.POAmendmentNo
);
COMMIT;