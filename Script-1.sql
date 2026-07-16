-- Line No Squence Check

WITH cte AS
(
    SELECT
        poamendmentitemdetailno,
        poamendmentno,
        poitemlineno,
        ROW_NUMBER() OVER
        (
            PARTITION BY poamendmentno
            ORDER BY poitemlineno
        ) * 10 AS expected_line_no
    FROM sqlserver_fdw.poamendmentitemdetail
)
SELECT
    poamendmentitemdetailno,
    poamendmentno,
    poitemlineno AS actual_line_no,
    expected_line_no
FROM cte
WHERE poitemlineno <> expected_line_no
ORDER BY poamendmentno, poitemlineno;

-- Duplicate item, make inside poamendmentNo


SELECT
    pid.poamendmentno,
    pid.itemno,
    pid.makeno,
    COUNT(*) AS duplicate_count
FROM sqlserver_fdw.poamendmentitemdetail pid
GROUP BY
    pid.poamendmentno,
    pid.itemno,
    pid.makeno
HAVING COUNT(*) > 1
ORDER BY
    pid.poamendmentno,
    pid.itemno,
    pid.makeno;


-- duplicates with date

WITH duplicate_rows AS
(
    SELECT
        pid.poamendmentitemdetailno,
        pid.poamendmentno,
        pid.itemno,
        pid.makeno,
        pom.created_date,
        COUNT(*) OVER
        (
            PARTITION BY
                pid.poamendmentno,
                pid.itemno,
                pid.makeno
        ) AS duplicate_count
    FROM sqlserver_fdw.poamendmentitemdetail pid
    LEFT JOIN purchase.purchase_order_main pom
        ON pom.id = pid.poamendmentno
)
SELECT
    poamendmentitemdetailno,
    poamendmentno,
    itemno,
    makeno,
    created_date,
    duplicate_count
FROM duplicate_rows
WHERE duplicate_count > 1
ORDER BY
    poamendmentno,
    itemno,
    makeno,
    created_date;

-- line no null check

select * from sqlserver_fdw.poamendmentitemdetail limit 100


select count (1) FROM sqlserver_fdw.csindentdetail cid
INNER JOIN sqlserver_fdw.csmain csm
    ON csm.csNo = cid.CSNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cid.IndentNo
    AND prid.line_no = cid.IndentItemLineNo
    AND prid.item_id = cid.ItemNo
    AND COALESCE(prid.make_id,0) = COALESCE(cid.MakeNo,0)
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.item_id = cid.ItemNo
    AND COALESCE(qid.make_id,0) = COALESCE(cid.MakeNo,0)
    AND qid.quotation_id = cid.RevisedQuotationNo
WHERE cid.RevisedQuotationNo IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM purchase.quotation_main q WHERE q.id = cid.RevisedQuotationNo
  );


SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    poid.id AS po_item_detail_id,
    prid.id AS pr_item_detail_id,
    paid.ItemNo
FROM sqlserver_fdw.poamendmentindentdetail paid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = paid.IndentNo
   AND prid.line_no = paid.IndentItemLineNo
   AND prid.item_id = paid.ItemNo
   AND COALESCE(prid.make_id,0) = COALESCE(paid.IndentMakeNo,0)
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
LIMIT 100;

select poamendmentNo,itemNo, makeNo, count(*)
FROM sqlserver_fdw.poamendmentindentdetail
group by poamendmentNo,itemNo, makeNo
having count(*)>1;

select *
FROM sqlserver_fdw.poamendmentindentdetail
where indentno  =11756 and indentitemlineno =1

select count(*) from sqlserver_fdw.poamendmentindentdetail

select * from sqlserver_fdw.indentitemdetail i 
where i.indentno in (11756, 11756, 46276, 72322)


-- duplicate verification
SELECT
    paid.POAmendmentIndentDetailNo,
    COUNT(*) AS cnt
FROM sqlserver_fdw.poamendmentindentdetail paid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = paid.IndentNo
   AND prid.line_no = paid.IndentItemLineNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
GROUP BY paid.POAmendmentIndentDetailNo
HAVING COUNT(*) > 1;


-- dry run preview

SELECT
--    paid.POAmendmentIndentDetailNo,
--    paid.POAmendmentNo,
--    poid.id AS po_item_detail_id,
--    prid.id AS pr_item_detail_id,
--    paid.ItemNo
      count(*)	
FROM sqlserver_fdw.poamendmentindentdetail paid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = paid.IndentNo
   AND prid.line_no = paid.IndentItemLineNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
   
   
   --- po pr mismatch with pr item detail
   SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    paid.IndentNo,
    paid.IndentItemLineNo,
    paid.ItemNo,
    paid.IndentMakeNo,
    pom.doc_date 
FROM sqlserver_fdw.poamendmentindentdetail paid
LEFT JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = paid.IndentNo
   AND prid.line_no = paid.IndentItemLineNo
left join purchase.purchase_order_main pom 
	on paid.poamendmentno = pom.id
WHERE prid.id IS NULL;
   
--- po pr mismatch with po item detail   
   SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    paid.ItemNo,
    paid.MakeNo,
    pom.doc_date 
FROM sqlserver_fdw.poamendmentindentdetail paid
LEFT JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
left join purchase.purchase_order_main pom 
	on paid.poamendmentno =pom.id
WHERE poid.id IS NULL;


SELECT *
FROM sqlserver_fdw.poamendmentindentdetail
WHERE IndentItemLineNo <> FLOOR(IndentItemLineNo);

SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    paid.ItemNo,
    paid.MakeNo,
    poid.id,
    poid.make_id
FROM sqlserver_fdw.poamendmentindentdetail paid
LEFT JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
WHERE poid.id IS NULL;
   

SELECT
    poid.po_id,
    poid.item_id,
    poid.make_id,
    COUNT(*)
FROM purchase.purchase_order_item_detail poid
GROUP BY
    poid.po_id,
    poid.item_id,
    poid.make_id 
HAVING COUNT(*) > 1;


SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    paid.ItemNo,
    paid.MakeNo,
    paid.IndentNo,
    paid.IndentItemLineNo
FROM sqlserver_fdw.poamendmentindentdetail paid
LEFT JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
WHERE poid.id IS NULL;
   

select count(*) from sqlserver_fdw.poamendmentitemdetail paid
select * from sqlserver_fdw.poamendmentindentdetail paid
select count(*) from purchase.purchase_order_item_detail poid

truncate table purchase.purchase_order_item_detail cascade

select count(*) from purchase.purchase_order_item_tax_detail poitd 

truncate table purchase.purchase_order_tax_detail potd cascade


-- check for po whose item do not exist in po item
SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    paid.ItemNo          AS indent_item,
    paid.MakeNo          AS indent_make,
    poid.id              AS po_item_detail_id,
    poid.item_id         AS po_item,
    poid.make_id         AS po_make
FROM sqlserver_fdw.poamendmentindentdetail paid
LEFT JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
WHERE poid.po_id IS NOT NULL
  AND NOT EXISTS
(
    SELECT 1
    FROM purchase.purchase_order_item_detail x
    WHERE x.po_id = paid.POAmendmentNo
      AND x.item_id = paid.ItemNo
);
   

-- check for only 22
SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    paid.ItemNo,
    paid.MakeNo,
    paid.IndentNo,
    paid.IndentItemLineNo
FROM sqlserver_fdw.poamendmentindentdetail paid
LEFT JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
WHERE poid.id IS NULL;

SELECT
    paid.POAmendmentIndentDetailNo,
    paid.POAmendmentNo,
    paid.ItemNo,
    paid.MakeNo,
    CASE
        WHEN NOT EXISTS
        (
            SELECT 1
            FROM purchase.purchase_order_item_detail poid
            WHERE poid.po_id = paid.POAmendmentNo
        )
        THEN 'PO_ID_MISSING'
        WHEN NOT EXISTS
        (
            SELECT 1
            FROM purchase.purchase_order_item_detail poid
            WHERE poid.po_id = paid.POAmendmentNo
              AND poid.item_id = paid.ItemNo
        )
        THEN 'ITEM_ID_MISMATCH'
        WHEN NOT EXISTS
        (
            SELECT 1
            FROM purchase.purchase_order_item_detail poid
            WHERE poid.po_id = paid.POAmendmentNo
              AND poid.item_id = paid.ItemNo
              AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
        )
        THEN 'MAKE_ID_MISMATCH'
        ELSE 'MATCHED'
    END AS mismatch_reason
FROM sqlserver_fdw.poamendmentindentdetail paid
WHERE NOT EXISTS
(
    SELECT 1
    FROM purchase.purchase_order_item_detail poid
    WHERE poid.po_id = paid.POAmendmentNo
      AND poid.item_id = paid.ItemNo
      AND COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
)
ORDER BY mismatch_reason,
         paid.POAmendmentNo,
         paid.ItemNo;



select poid.id,poid.po_id,poid.item_id , poid.make_id  from purchase.purchase_order_item_detail poid 
where poid.po_id in (
--1015
1101 
--2482, 
--4451, 
--6970, 
--7828, 
--9629, 
--9789, 
--9793, 
--10910, 
--17010
);

select poid.poamendmentindentdetailno ,poid.poamendmentno,poid.itemno, poid.makeno ,poid.indentno , poid.indentItemLineNo from sqlserver_fdw.poamendmentindentdetail poid 
where poid.poamendmentno  in (
--1015
1101 
--2482, 
--4451, 
--6970, 
--7828, 
--9629, 
--9789, 
--9793, 
--10910, 
--17010
);

select p.poamendmentno ,p.itemno ,p.makeno ,p.indentno, count(*) from sqlserver_fdw.poamendmentindentdetail p 
group by p.poamendmentno ,p.itemno ,p.makeno ,p.indentno 
having count(*)>1

select count(*) from sqlserver_fdw.poamendmentindentdetail


SELECT
    paid.POAmendmentIndentDetailNo,
    COUNT(*) AS cnt
FROM sqlserver_fdw.poamendmentindentdetail paid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = paid.IndentNo
   AND prid.line_no = paid.IndentItemLineNo
   AND prid.item_id = paid.ItemNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
   AND poid.item_id = paid.ItemNo
   AND
   (
       COALESCE(paid.MakeNo,0) = 0
       OR COALESCE(poid.make_id,0) = COALESCE(paid.MakeNo,0)
   )
GROUP BY paid.POAmendmentIndentDetailNo
HAVING COUNT(*) > 1;


select * from sqlserver_fdw.indentitemdetail


SELECT COUNT(*)
FROM
(
    SELECT
        pom.main_po_id,
        poid.item_id,
        poid.make_id
    FROM purchase.purchase_order_item_detail poid
    INNER JOIN purchase.purchase_order_main pom
        ON pom.id = poid.po_id
    GROUP BY
        pom.main_po_id,
        poid.item_id,
        poid.make_id
) x;