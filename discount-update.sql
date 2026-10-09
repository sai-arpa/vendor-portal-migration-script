--formulas
--discount_amount
--    = discount tax amount
--
--discount_per_qty
--    = discount_amount / qty
--
--discount_rate
--    = discount_amount / basic_amount × 100
--
--rate_after_discount
--    = rate - discount_per_qty




------------------------------------------------------------------QUOTATION----------------------------------------------------------------------------------------------------
--check
SELECT
    qid.id,
    qid.qty,
    qid.rate,
    qid.basic_amount,
    qit.amount AS discount_amount,
    ROUND(qit.amount / NULLIF(qid.qty, 0), 2) AS discount_per_qty,
    ROUND(
        100 * qit.amount / NULLIF(qid.basic_amount, 0),
        2
    ) AS discount_rate,
    ROUND(
        qid.rate - (qit.amount / NULLIF(qid.qty, 0)),
        2
    ) AS rate_after_discount
FROM purchase.quotation_item_detail qid
INNER JOIN purchase.quotation_item_tax_detail qit
    ON qit.quotation_item_detail_id = qid.id
WHERE qit.tax_id = 8
ORDER BY qid.id;

-- Update
UPDATE purchase.quotation_item_detail qid
SET
    discount_amount = qit.amount,
    discount_per_qty = ROUND(qit.amount / NULLIF(qid.qty, 0), 2),
    discount_rate = ROUND(
        100 * qit.amount / NULLIF(qid.basic_amount, 0),
        2
    ),
    rate_after_discount = ROUND(
        qid.rate - (qit.amount / NULLIF(qid.qty, 0)),
        2
    )
FROM purchase.quotation_item_tax_detail qit
WHERE qid.id = qit.quotation_item_detail_id
  AND qit.tax_id = 8;


-----
-- add missing taxes in item tax detail
WITH MissingTaxes AS
(
    SELECT
        qtd.quotation_id,
        qtd.tax_id,
        qtd.amount AS quotation_tax_amount,
        qtd.nature_id,
        qtd.charge_type_id,
        qtd.charge_on_id,
        qtd.charge_value
    FROM purchase.quotation_tax_detail qtd
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM purchase.quotation_item_tax_detail qit
        WHERE qit.quotation_id = qtd.quotation_id
          AND qit.tax_id = qtd.tax_id
    )
),
ItemAllocation AS
(
    SELECT
        mt.quotation_id,
        mt.tax_id,
        mt.quotation_tax_amount,
        mt.nature_id,
        mt.charge_type_id,
        mt.charge_on_id,
        mt.charge_value,
        qid.id AS quotation_item_detail_id,
        qid.basic_amount,
        SUM(
            CASE
                WHEN qid.basic_amount > 0
                    THEN qid.basic_amount
                ELSE 0
            END
        ) OVER (
            PARTITION BY mt.quotation_id, mt.tax_id
        ) AS total_positive_basic_amount,
        ROW_NUMBER() OVER (
            PARTITION BY mt.quotation_id, mt.tax_id
            ORDER BY qid.id
        ) AS item_rn,
        MIN(
            CASE
                WHEN qid.basic_amount > 0 THEN qid.id
            END
        ) OVER (
            PARTITION BY mt.quotation_id, mt.tax_id
        ) AS first_positive_item_id
    FROM MissingTaxes mt
    INNER JOIN purchase.quotation_item_detail qid
        ON qid.quotation_id = mt.quotation_id
),
CalculatedAllocation AS
(
    SELECT
        *,
        ROUND(
            CASE
                WHEN basic_amount > 0
                 AND total_positive_basic_amount > 0
                THEN quotation_tax_amount
                     * basic_amount
                     / total_positive_basic_amount
                ELSE 0
            END,
            2
        ) AS calculated_amount
    FROM ItemAllocation
),
FinalAllocation AS
(
    SELECT
        *,
        SUM(calculated_amount) OVER (
            PARTITION BY quotation_id, tax_id
        ) AS calculated_total
    FROM CalculatedAllocation
)
INSERT INTO purchase.quotation_item_tax_detail
(
    quotation_id,
    quotation_item_detail_id,
    tax_id,
    nature_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount
)
SELECT
    quotation_id,
    quotation_item_detail_id,
    tax_id,
    nature_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    CASE
        WHEN basic_amount = 0 THEN 0
        WHEN total_positive_basic_amount = 0 THEN 0
        WHEN quotation_item_detail_id = first_positive_item_id THEN
            calculated_amount
            + (quotation_tax_amount - calculated_total)
        ELSE
            calculated_amount
    END AS amount
FROM FinalAllocation;


--- Discount amount update in QuotationMain
UPDATE purchase.quotation_main qm
SET discount_amount = sub.total_discount
FROM (
    SELECT quotation_id, SUM(discount_amount) AS total_discount
    FROM purchase.quotation_item_detail
    GROUP BY quotation_id
) sub
WHERE qm.id = sub.quotation_id;

--- Tax Amount update in QuotationMain
update purchase.quotation_main
set tax_amount = net_amount - basic_amount



------------------------------------------------------------------purchase Order----------------------------------------------------------------------------------------------------

--- Basic Amount update in purchaseOrderMain
UPDATE purchase.purchase_order_main qm
SET basic_amount = sub.total_basic_amount
FROM (
    SELECT po_id, SUM(basic_amount) AS total_basic_amount
    FROM purchase.purchase_order_item_detail
    GROUP BY po_id
) sub
WHERE qm.id = sub.po_id;

--- tax Amount update in purchaseOrderMain (pending)
update purchase.purchase_order_main
set tax_amount = net_amount - basic_amount


--- Update Discount Columns
UPDATE purchase.purchase_order_item_detail qid
SET
    discount_amount = qit.amount,
    discount_per_qty = ROUND(qit.amount / NULLIF(qid.qty, 0), 2),
    discount_rate = ROUND(
        100 * qit.amount / NULLIF(qid.basic_amount, 0),
        2
    ),
    rate_after_discount = ROUND(
        qid.rate - (qit.amount / NULLIF(qid.qty, 0)),
        2
    )
FROM purchase.purchase_order_item_tax_detail qit
WHERE qid.id = qit.po_item_detail_id
  AND qit.tax_id = 8;

------- add missing taxes in item tax detail
WITH MissingTaxes AS
(
    SELECT
        qtd.po_id,
        qtd.tax_id,
        qtd.amount AS po_tax_amount,
        qtd.nature_id,
        qtd.charge_type_id,
        qtd.charge_on_id,
        qtd.charge_value
    FROM purchase.purchase_order_tax_detail qtd
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM purchase.purchase_order_item_tax_detail qit
        WHERE qit.po_id = qtd.po_id
          AND qit.tax_id = qtd.tax_id
    )
),
ItemAllocation AS
(
    SELECT
        mt.po_id,
        mt.tax_id,
        mt.po_tax_amount,
        mt.nature_id,
        mt.charge_type_id,
        mt.charge_on_id,
        mt.charge_value,
        qid.id AS po_item_detail_id,
        qid.basic_amount,
        SUM(
            CASE
                WHEN qid.basic_amount > 0
                    THEN qid.basic_amount
                ELSE 0
            END
        ) OVER (
            PARTITION BY mt.po_id, mt.tax_id
        ) AS total_positive_basic_amount,
        ROW_NUMBER() OVER (
            PARTITION BY mt.po_id, mt.tax_id
            ORDER BY qid.id
        ) AS item_rn,
        MIN(
            CASE
                WHEN qid.basic_amount > 0 THEN qid.id
            END
        ) OVER (
            PARTITION BY mt.po_id, mt.tax_id
        ) AS first_positive_item_id
    FROM MissingTaxes mt
    INNER JOIN purchase.purchase_order_item_detail qid
        ON qid.po_id = mt.po_id
),
CalculatedAllocation AS
(
    SELECT
        *,
        ROUND(
            CASE
                WHEN basic_amount > 0
                 AND total_positive_basic_amount > 0
                THEN po_tax_amount
                     * basic_amount
                     / total_positive_basic_amount
                ELSE 0
            END,
            2
        ) AS calculated_amount
    FROM ItemAllocation
),
FinalAllocation AS
(
    SELECT
        *,
        SUM(calculated_amount) OVER (
            PARTITION BY po_id, tax_id
        ) AS calculated_total
    FROM CalculatedAllocation
)
INSERT INTO purchase.purchase_order_item_tax_detail
(
    po_id,
    po_item_detail_id,
    tax_id,
    nature_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    amount
)
SELECT
    po_id,
    po_item_detail_id,
    tax_id,
    nature_id,
    charge_type_id,
    charge_on_id,
    charge_value,
    CASE
        WHEN basic_amount = 0 THEN 0
        WHEN total_positive_basic_amount = 0 THEN 0
        WHEN po_item_detail_id = first_positive_item_id THEN
            calculated_amount
            + (po_tax_amount - calculated_total)
        ELSE
            calculated_amount
    END AS amount
FROM FinalAllocation;

---- freight amount update
UPDATE purchase.purchase_order_main pom
SET freight_amount = x.fm
FROM (
    SELECT
        potd.po_id,
        SUM(potd.amount) AS fm
    FROM purchase.purchase_order_tax_detail potd
    WHERE potd.tax_id = 103
    GROUP BY potd.po_id
) x
WHERE pom.id = x.po_id;

----------------------------------------------------------------------------------------------------------------


---Verification

---- find difference of amounts between quotationTaxDetail and quotationItemTaxDetail
SELECT
    qtd.quotation_id,
    qtd.tax_id,
    qtd.amount AS quotation_tax_amount,
    qm.created_date,
    COALESCE(SUM(qit.amount), 0) AS item_tax_amount,
    ROUND(
        qtd.amount - COALESCE(SUM(qit.amount), 0),
        2
    ) AS difference
FROM purchase.quotation_tax_detail qtd
LEFT JOIN purchase.quotation_item_tax_detail qit
    ON qit.quotation_id = qtd.quotation_id
   AND qit.tax_id = qtd.tax_id
left join purchase.quotation_main qm 
on qm.id = qtd.quotation_id 
GROUP BY
    qtd.quotation_id,
    qtd.tax_id,
    qm.created_date,
    qtd.amount
HAVING qtd.amount <> ROUND(COALESCE(SUM(qit.amount), 0), 2)
ORDER BY
    qm.created_date desc

---- find difference of amounts between quotationTaxDetail and quotationItemTaxDetail
    -- (160)
SELECT
    qtd.po_id,
    qtd.tax_id,
    qtd.amount AS quotation_tax_amount,
    qm.created_date,
    COALESCE(SUM(qit.amount), 0) AS item_tax_amount,
    ROUND(
        qtd.amount - COALESCE(SUM(qit.amount), 0),
        2
    ) AS difference
FROM purchase.purchase_order_tax_detail qtd
LEFT JOIN purchase.purchase_order_item_tax_detail qit
    ON qit.po_id = qtd.po_id
   AND qit.tax_id = qtd.tax_id
left join purchase.purchase_order_main qm 
on qm.id = qtd.po_id 
GROUP BY
    qtd.po_id,
    qtd.tax_id,
    qm.created_date,
    qtd.amount
HAVING qtd.amount <> ROUND(COALESCE(SUM(qit.amount), 0), 2)
ORDER BY
    qm.created_date desc
    
    
    
--- find missing tax rows in quotationItemTaxDetail
SELECT
    qm.created_date 
FROM purchase.quotation_tax_detail qtd
LEFT JOIN purchase.quotation_item_tax_detail qit
    ON qit.quotation_id = qtd.quotation_id
   AND qit.tax_id = qtd.tax_id
left join purchase.quotation_main qm 
	on qm.id = qtd.quotation_id 
left join masterdata.tax_master tm 
	on tm.id = qtd.tax_id 
WHERE qit.id IS null 
--and tm.id not in (103,104,105)

--- find missing tax rows in poItemTaxDetail
SELECT
    *
FROM purchase.purchase_order_tax_detail qtd
LEFT JOIN purchase.purchase_order_item_tax_detail qit
    ON qit.po_id = qtd.po_id
   AND qit.tax_id = qtd.tax_id
left join purchase.purchase_order_main qm 
	on qm.id = qtd.po_id 
left join masterdata.tax_master tm 
	on tm.id = qtd.tax_id 
WHERE qit.id IS null 
and tm.id  in (103,104,105)


----
select * from purchase.purchase_order_main where id=5274;
select * from purchase.purchase_order_item_detail where po_id=5274;
select * from purchase.purchase_order_tax_detail where po_id=5274;
select * from purchase.purchase_order_item_tax_detail where po_id=5274;


