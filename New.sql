select count(*) from masterdata.unit_master

select * from sqlserver_fdw.mgroupmaster

select count(*) from masterdata.role_master rm 

select * from sqlserver_fdw.documentserial


SELECT
    indentno,
    indentitemlineno,
    COUNT(*) AS duplicate_count
FROM sqlserver_fdw.indentitemdetail
GROUP BY indentno, indentitemlineno
HAVING COUNT(*) > 1
ORDER BY indentno, indentitemlineno;

select indentNo, indentItemLineno FROM sqlserver_fdw.indentitemdetail where indentNo=77270

select count(*) FROM sqlserver_fdw.indentitemdetail

select count(*) from sqlserver_fdw.rfqmain
select count(*) from sqlserver_fdw.rfqvendordetail


select count(*) from sqlserver_fdw.rfqitemdetail

select count(*) from sqlserver_fdw.rfqindentdetail


select count(*) from sqlserver_fdw.revisedquotationmain where auctionNo is not null



select * from purchase.pur_rfq_item_detail
where rfq_id =102 and make_id is null and item_id=2717





select r.auctionno , r.rfqno  from sqlserver_fdw.revisedquotationmain r where r.auctionno is not null

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT rqm.RFQNo) AS distinct_rfq_no
FROM sqlserver_fdw.revisedquotationmain rqm
LEFT JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = rqm.RFQNo
   AND rvd.vendor_location_id = rqm.VendorLocationNo;




SELECT
    rqm.RevisedQuotationNo,
    rqm.RFQNo,
    rqm.VendorLocationNo,
    COUNT(rvd.id) AS matched_rvd_rows
FROM sqlserver_fdw.revisedquotationmain rqm
LEFT JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = rqm.RFQNo
   AND rvd.vendor_location_id = rqm.VendorLocationNo
GROUP BY
    rqm.RevisedQuotationNo,
    rqm.RFQNo,
    rqm.VendorLocationNo
HAVING COUNT(rvd.id) > 1
ORDER BY matched_rvd_rows DESC;





select * from purchase.pur_rfq_vendor_detail rvd where rvd.rfq_id =122



SELECT
    rvd.id AS rvd_id,
    rvd.rfq_id,
    rvd.vendor_location_id,
    c.id AS contact_id
FROM purchase.pur_rfq_vendor_detail rvd
LEFT JOIN purchase.pur_rfq_vendor_contact_person_detail c
    ON c.rfq_vendor_detail_id = rvd.id
WHERE rvd.id IN (
    SELECT id
    FROM (
        SELECT
            id,
            ROW_NUMBER() OVER (
                PARTITION BY rfq_id, vendor_location_id
                ORDER BY id
            ) AS rn
        FROM purchase.pur_rfq_vendor_detail
    ) x
    WHERE rn > 1
)
ORDER BY
    rvd.rfq_id,
    rvd.vendor_location_id,
    rvd.id;


SELECT
    rqm.QuotationNo,
    rqm.RevisedNo,
    COUNT(*) AS duplicate_count,
    ARRAY_AGG(rqm.RevisedQuotationNo ORDER BY rqm.RevisedQuotationNo) AS revised_quotation_nos
FROM sqlserver_fdw.revisedquotationmain rqm
GROUP BY
    rqm.QuotationNo,
    rqm.RevisedNo
HAVING COUNT(*) > 1
ORDER BY
    rqm.QuotationNo,
    rqm.RevisedNo;

select rfqindentDetailno, makeno from 

51939

select * from sqlserver_fdw.revisedquotationmain where quotationno=51939

select id from security.user_master order by id asc


SELECT
    rid.RFQNo,
    rid.ItemNo,
    rid.RFQMakeNo,
    rid.IndentNo,
    rid.IndentItemLineNo,
    COUNT(*) AS rfqid_match_count
FROM sqlserver_fdw.rfqindentdetail rid
INNER JOIN purchase.pur_rfq_item_detail rfqid
    ON rfqid.rfq_id = rid.RFQNo
   AND rfqid.item_id = rid.ItemNo
   AND COALESCE(rfqid.make_id, 0) = COALESCE(rid.RFQMakeNo, 0)
GROUP BY
    rid.RFQNo,
    rid.ItemNo,
    rid.RFQMakeNo,
    rid.IndentNo,
    rid.IndentItemLineNo
HAVING COUNT(*) > 1
ORDER BY rfqid_match_count DESC;



SELECT
    rid.rfqindentdetailno,
    rid.indentno,
    rid.indentitemlineno,
    rid.itemno,
    COUNT(*) AS match_count
FROM sqlserver_fdw.rfqindentdetail rid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = rid.indentno
   AND prid.line_no = rid.indentitemlineno
   AND prid.item_id = rid.itemno
GROUP BY
    rid.rfqindentdetailno,
    rid.indentno,
    rid.indentitemlineno,
    rid.itemno
HAVING COUNT(*) > 1
ORDER BY match_count DESC;


SELECT
    rid.rfqindentdetailno,
    rid.indentno,
    rid.indentitemlineno,
    rid.itemno
FROM sqlserver_fdw.rfqindentdetail rid
LEFT JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = rid.indentno
   AND prid.line_no = rid.indentitemlineno
   AND prid.item_id = rid.itemno
WHERE prid.pur_req_id IS NULL
ORDER BY
    rid.indentno,
    rid.indentitemlineno,
    rid.itemno;


SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE EXISTS (
            SELECT 1
            FROM inventory.purchase_request_item_detail prid
            WHERE prid.pur_req_id = rid.indentno
        )
    ) AS req_id_match,
    COUNT(*) FILTER (
        WHERE EXISTS (
            SELECT 1
            FROM inventory.purchase_request_item_detail prid
            WHERE prid.pur_req_id = rid.indentno
              AND prid.line_no = rid.indentitemlineno
        )
    ) AS req_id_line_match,
    COUNT(*) FILTER (
        WHERE EXISTS (
            SELECT 1
            FROM inventory.purchase_request_item_detail prid
            WHERE prid.pur_req_id = rid.indentno
              AND prid.line_no = rid.indentitemlineno
              AND prid.item_id = rid.itemno
        )
    ) AS full_match
FROM sqlserver_fdw.rfqindentdetail rid;


SELECT
    rid.rfqindentdetailno,
    rid.indentno,
    rid.indentitemlineno,
    rid.itemno AS rid_itemno,
    rid_item.item_name AS rid_item_name,
    prid.item_id AS prid_item_id,
    prid_item.item_name AS prid_item_name,
    prm.created_date  
FROM sqlserver_fdw.rfqindentdetail rid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = rid.indentno
   AND prid.line_no = rid.indentitemlineno
left join inventory.purchase_request_main prm 
on prm.id=prid.pur_req_id 
LEFT JOIN masterdata.item_master rid_item
    ON rid_item.id = rid.itemno
LEFT JOIN masterdata.item_master prid_item
    ON prid_item.id = prid.item_id
WHERE rid.rfqindentdetailno IN (
    31785,33345,33701,43280,44765,51555,56014,57548,
    86469,104297,104303,104304,104305,104306,104295,
    104301,104302,104293,104298,104294,104290,104299,
    104308,104291,104300,104307,104292,104296,106339
)
AND prid.item_id <> rid.itemno
ORDER BY rid.indentno, rid.indentitemlineno;


select * from inventory.purchase_request_item_detail prid 
where prid.pur_req_id=47521 and prid.line_no between 1 and 19

select * from sqlserver_fdw.rfqindentdetail r 
where r.indentno =47521

select im.item_name  from masterdata.item_master im
where im.id in (63996, 3632)



UPDATE sqlserver_fdw.revisedquotationitemdetail rqid
SET rfqItemlineNo = rfqi.line_no
FROM purchase.quotation_main qm
INNER JOIN purchase.pur_rfq_item_detail rfqi
    ON rfqi.rfq_id = qm.rfq_id
   AND rfqi.item_id = rqid.itemNo
   AND COALESCE(rfqi.make_id, 0) = COALESCE(rqid.makeNo, 0)
WHERE qm.id = rqid.RevisedQuotationNo;


SELECT
    qitd.RevisedQuotationNo,
    qitd.ItemNo,
    COALESCE(qitd.MakeNo, 0) AS MakeNo,
    COUNT(*) AS matching_rows
FROM sqlserver_fdw.revisedquotationitemtaxdetail qitd
INNER JOIN purchase.quotation_item_detail qid
    ON qid.quotation_id = qitd.RevisedQuotationNo
    AND qid.item_id = qitd.ItemNo
    AND COALESCE(qid.make_id, 0) = COALESCE(qitd.MakeNo, 0)
GROUP BY
    qitd.RevisedQuotationNo,
    qitd.ItemNo,
    COALESCE(qitd.MakeNo, 0)
HAVING COUNT(*) > 1
ORDER BY matching_rows DESC;


SELECT
    RevisedQuotationNo,
    ItemNo,
    COALESCE(MakeNo, 0) AS MakeNo,
    COUNT(*) AS cnt
FROM sqlserver_fdw.revisedquotationitemtaxdetail
GROUP BY
    RevisedQuotationNo,
    ItemNo,
    COALESCE(MakeNo, 0)
HAVING COUNT(*) > 1
ORDER BY cnt DESC;


SELECT
    quotation_id,
    item_id,
    COALESCE(rfq_make_id, 0) AS rfq_make_id,
    COUNT(*) AS cnt
FROM purchase.quotation_item_detail
GROUP BY
    quotation_id,
    item_id,
    COALESCE(rfq_make_id, 0)
HAVING COUNT(*) > 1
ORDER BY cnt DESC;



---- poItemTax and poItem comparision
SELECT
    paitd.POAmendmentItemTaxNo,
    paitd.POAmendmentNo,
    paitd.ItemNo,
    paitd.MakeNo,
    poid.id AS POItemDetailId,
    poid.po_id,
    poid.item_id,
    poid.make_id
FROM sqlserver_fdw.poamendmentitemtaxdetail paitd
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paitd.POAmendmentNo
    AND poid.item_id = paitd.ItemNo
    AND COALESCE(poid.make_id, 0) = COALESCE(paitd.MakeNo, 0)
WHERE paitd.POAmendmentItemTaxNo IN
(
    SELECT paitd2.POAmendmentItemTaxNo
    FROM sqlserver_fdw.poamendmentitemtaxdetail paitd2
    INNER JOIN purchase.purchase_order_item_detail poid2
        ON poid2.po_id = paitd2.POAmendmentNo
        AND poid2.item_id = paitd2.ItemNo
        AND COALESCE(poid2.make_id, 0) = COALESCE(paitd2.MakeNo, 0)
    GROUP BY paitd2.POAmendmentItemTaxNo
    HAVING COUNT(*) > 1
)
ORDER BY
    paitd.POAmendmentItemTaxNo,
    poid.id;

select count(*) from (
SELECT
    paitd.POAmendmentItemTaxNo,
    paitd.POAmendmentNo,
    paitd.ItemNo,
    paitd.MakeNo,
    COUNT(*) AS MatchingPOItemCount
FROM sqlserver_fdw.poamendmentitemtaxdetail paitd
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paitd.POAmendmentNo
    AND poid.item_id = paitd.ItemNo
    AND COALESCE(poid.make_id, 0) = COALESCE(paitd.MakeNo, 0)
GROUP BY
    paitd.POAmendmentItemTaxNo,
    paitd.POAmendmentNo,
    paitd.ItemNo,
    paitd.MakeNo
HAVING COUNT(*) > 1
) x;
ORDER BY
    MatchingPOItemCount DESC;




---po pr and po item
SELECT
    paid.poamend,
    paid.POAmendmentNo,
    paid.IndentNo,
    paid.IndentItemLineNo,
    paid.ItemNo,
    paid.MakeNo,
    COUNT(*) AS MatchingPOItemCount
FROM sqlserver_fdw.poamendmentindentdetail paid
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = paid.POAmendmentNo
    AND poid.item_id = paid.ItemNo
    AND COALESCE(poid.make_id, 0) = COALESCE(paid.MakeNo, 0)
GROUP BY
    paid.POAmendmentIndentNo,
    paid.POAmendmentNo,
    paid.IndentNo,
    paid.IndentItemLineNo,
    paid.ItemNo,
    paid.MakeNo
HAVING COUNT(*) > 1
ORDER BY
    MatchingPOItemCount DESC;


--- po item detail duplicate check
select poid.po_id, count(*)
from purchase.purchase_order_item_detail poid 
group by 
    poid.po_id,
    poid.item_id,
    poid.make_id
having count(*)>1


--- Approval Process Related
update Inventory.purchase_request_main
set  approval_setup_id=120
where id =87582

select count(*) from masterdata.approval_setup_level_detail asld 
where asld.printing_caption is null

select count(*) from inventory.purchase_request_main prm where prm.document_status_id =20



-- check missing indentAuthorizationDetail
SELECT
    prm.id AS PurchaseRequestId,
    prm.doc_no_yearly,
    COUNT(iad.IndentAuthorizationDetailNo) AS AuthorizationDetailCount
FROM inventory.purchase_request_main prm
LEFT JOIN sqlserver_fdw.indentauthorizationdetail iad
    ON iad.IndentNo = prm.id
WHERE prm.approval_setup_id IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM utility.approval_process_main apm
      WHERE apm.doc_id = prm.id
  )
GROUP BY
    prm.id,
    prm.doc_no_yearly;

-- check missing poauthorizationDetail
SELECT
    prm.id AS PurchaseRequestId,
    prm.doc_no_yearly,
    COUNT(iad.poamendmentauthorizationdetailno ) AS AuthorizationDetailCount
FROM purchase.purchase_order_main prm
LEFT JOIN sqlserver_fdw.poamendmentauthorizationdetail iad
    ON iad.poamendmentno  = prm.id
WHERE prm.approval_setup_id IS NOT NULL
GROUP BY
    prm.id,
    prm.doc_no_yearly
having COUNT(iad.poamendmentauthorizationdetailno )=0;


select count(*) from inventory.purchase_request_main prm where prm.approval_setup_id is not null;


---Po Approval Process Verification
select count(*) from purchase.purchase_order_main pom 
where pom.approval_setup_id is not null     ---101397

select count(distinct poamendmentno ) from sqlserver_fdw.poamendmentauthorizationdetail  ---101391

select count(*) from utility.approval_process_main apm    ---101391
where apm.form_id =10

---CS Approval Process Verification
select count(*) from purchase.cs_main pom 
where pom.approval_setup_id is not null     ---46891

select count(distinct csno ) from sqlserver_fdw.csauthorizationdetail  ---46651

select count(*) from utility.approval_process_main apm    ---46651
where apm.form_id =8

--- check for cs which have approval_setup_id but no records in authorizationDetail
SELECT COUNT(DISTINCT pom.id) AS cs_without_auth
FROM purchase.cs_main pom
WHERE pom.approval_setup_id IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM sqlserver_fdw.csauthorizationdetail pad
      WHERE pad.csNo = pom.id
  );

--check csAuthorizationDetail cs record that do not exist in cs main
SELECT DISTINCT
    pad.csNo
FROM sqlserver_fdw.csauthorizationdetail pad
LEFT JOIN purchase.cs_main pom
    ON pom.id = pad.csNo
WHERE pom.id IS NULL
ORDER BY pad.csNo;

--check pauthorizationDetail po record that do not exist in po main
SELECT DISTINCT
    pad.POAmendmentNo
FROM sqlserver_fdw.poamendmentauthorizationdetail pad
LEFT JOIN purchase.purchase_order_main pom
    ON pom.id = pad.POAmendmentNo
WHERE pom.id IS NULL
ORDER BY pad.POAmendmentNo;

---POAmendmentNo exists, but approval_setup_id IS NULL
SELECT DISTINCT
    pad.POAmendmentNo,
    pom.approval_setup_id 
FROM sqlserver_fdw.poamendmentauthorizationdetail pad
INNER JOIN purchase.purchase_order_main pom
    ON pom.id = pad.POAmendmentNo
WHERE pom.approval_setup_id IS null
ORDER BY pad.POAmendmentNo;


---CsAuthorizationDetail, csNo exist but approval_setup_id is null
SELECT DISTINCT
    pad.csNo,
    pom.approval_setup_id
FROM sqlserver_fdw.csauthorizationdetail pad
INNER JOIN purchase.cs_main pom
    ON pom.id = pad.csNo
WHERE pom.approval_setup_id IS NULL
ORDER BY pad.csNo;

---po left
---74501, 86776, 87417, 91654, 96220, 98627, 102085, 103186

select count(*) from utility.approval_process_detail apd 


--- update po_main approval_setup_id where it is null and have entry in poAuthorizatioNDetail
update purchase.purchase_order_main
set approval_setup_id=59
where id in (70910, 72610, 75076, 79594, 82907, 82908, 82909, 88833, 91212, 101974);


----find approval setup id for remaining 8 po
WITH target_pos AS
(
    SELECT
        pom.id,
        pom.doc_no_yearly,
        pom.company_id,
        pom.division_id,
        pom.department_id,
        pom.net_amount
    FROM purchase.purchase_order_main pom
    WHERE pom.id IN
    (
        74501,
        86776,
        87417,
        91654,
        96220,
        98627,
        102085,
        103186
    )
),
/* Users actually present in the old PO authorization workflow */
po_users AS
(
    SELECT DISTINCT
        pad.POAmendmentNo,
        pad.LoginNo,
        pad.LevelNo
    FROM sqlserver_fdw.poamendmentauthorizationdetail pad
    INNER JOIN target_pos p
        ON p.id = pad.POAmendmentNo
    WHERE pad.LoginNo IS NOT NULL
),
/* Number of distinct levels in the old authorization workflow */
po_level_count AS
(
    SELECT
        POAmendmentNo,
        COUNT(DISTINCT LevelNo) AS po_level_count
    FROM po_users
    GROUP BY POAmendmentNo
),
/*
    Candidate approval setups based on organizational unit.
    
    Division / department matching:
      - exact match gets priority
      - NULL in setup means the setup is broader and is still a candidate
*/
candidate_setups AS
(
    SELECT DISTINCT
        p.id AS po_id,
        p.doc_no_yearly,
        p.company_id,
        p.division_id,
        p.department_id,
        p.net_amount,
        asm.id AS approval_setup_id,
        asm.code,
        asm.approval_setup_name,
        asm.min_net_amount,
        asm.max_net_amount,
        asm.revision_no,
        asm.is_current,
        asm.status_id,
        aos.company_id AS setup_company_id,
        aos.division_id AS setup_division_id,
        aos.department_id AS setup_department_id,
        CASE
            WHEN aos.company_id = p.company_id
             AND aos.division_id = p.division_id
             AND aos.department_id = p.department_id
                THEN 3
            WHEN aos.company_id = p.company_id
             AND aos.division_id = p.division_id
             AND aos.department_id IS NULL
                THEN 2
            WHEN aos.company_id = p.company_id
             AND aos.division_id IS NULL
             AND aos.department_id IS NULL
                THEN 1
            ELSE 0
        END AS org_match_score,
        CASE
            WHEN
                (asm.min_net_amount IS NULL OR p.net_amount >= asm.min_net_amount)
                AND
                (asm.max_net_amount IS NULL OR p.net_amount <= asm.max_net_amount)
            THEN 1
            ELSE 0
        END AS amount_match
    FROM target_pos p
    INNER JOIN masterdata.approval_setup_org_unit_detail aos
        ON aos.company_id = p.company_id
       AND (aos.division_id = p.division_id OR aos.division_id IS NULL)
       AND (aos.department_id = p.department_id OR aos.department_id IS NULL)
    INNER JOIN masterdata.approval_setup_master asm
        ON asm.id = aos.approval_setup_id
       AND asm.form_id = 10
),
/* Number of levels configured in each candidate setup */
setup_level_count AS
(
    SELECT
        approval_setup_id,
        COUNT(DISTINCT level_no) AS setup_level_count
    FROM masterdata.approval_setup_level_detail
    GROUP BY approval_setup_id
),
/*
    Compare old PO users against users configured in candidate setup.
*/
user_match AS
(
    SELECT
        cs.po_id,
        cs.approval_setup_id,
        COUNT(DISTINCT pu.LoginNo) AS po_user_count,
        COUNT
        (
            DISTINCT
            CASE
                WHEN asu.user_id = pu.LoginNo
                THEN pu.LoginNo
            END
        ) AS matched_user_count
    FROM candidate_setups cs
    LEFT JOIN po_users pu
        ON pu.POAmendmentNo = cs.po_id
    LEFT JOIN masterdata.approval_setup_level_detail asld
        ON asld.approval_setup_id = cs.approval_setup_id
    LEFT JOIN masterdata.approval_setup_user_detail asu
        ON asu.approval_setup_level_id = asld.id
       AND asu.user_id = pu.LoginNo
    GROUP BY
        cs.po_id,
        cs.approval_setup_id
),
/* Compare number of levels */
level_match AS
(
    SELECT
        cs.po_id,
        cs.approval_setup_id,
        COALESCE(plc.po_level_count, 0) AS po_level_count,
        COALESCE(slc.setup_level_count, 0) AS setup_level_count,
        ABS(
            COALESCE(plc.po_level_count, 0)
            -
            COALESCE(slc.setup_level_count, 0)
        ) AS level_difference
    FROM candidate_setups cs
    LEFT JOIN po_level_count plc
        ON plc.POAmendmentNo = cs.po_id
    LEFT JOIN setup_level_count slc
        ON slc.approval_setup_id = cs.approval_setup_id
),
ranked AS
(
    SELECT
        cs.*,
        COALESCE(um.po_user_count, 0) AS po_user_count,
        COALESCE(um.matched_user_count, 0) AS matched_user_count,
        lm.po_level_count,
        lm.setup_level_count,
        lm.level_difference,
        /*
            Main ranking score.

            Organization is strongest.
            Amount eligibility is next.
            User overlap is useful evidence.
            Level count similarity is supporting evidence.
        */
        (
            cs.org_match_score * 1000
            +
            cs.amount_match * 500
            +
            COALESCE(um.matched_user_count, 0) * 50
            -
            lm.level_difference * 20
        ) AS match_score
    FROM candidate_setups cs
    LEFT JOIN user_match um
        ON um.po_id = cs.po_id
       AND um.approval_setup_id = cs.approval_setup_id
    LEFT JOIN level_match lm
        ON lm.po_id = cs.po_id
       AND lm.approval_setup_id = cs.approval_setup_id
)
SELECT
    po_id,
    doc_no_yearly,
    net_amount,
    approval_setup_id,
    code,
    approval_setup_name,
    org_match_score,
    setup_company_id,
    setup_division_id,
    setup_department_id,
    amount_match,
    min_net_amount,
    max_net_amount,
    po_user_count,
    matched_user_count,
    po_level_count,
    setup_level_count,
    level_difference,
    is_current,
    revision_no,
    status_id,
    match_score,
    RANK() OVER
    (
        PARTITION BY po_id
        ORDER BY match_score DESC
    ) AS candidate_rank
FROM ranked
ORDER BY
    po_id,
    candidate_rank,
    approval_setup_id;


select distinct status_id from utility.approval_process_main


--- find logins with duplicate mail
SELECT
    um.id,
    um.username,
    um.display_name,
    um.email,
    um.contact_no,
    um.supplier_account_id,
    um.status_id,
    um.is_blocked,
    um.created_date
FROM security.user_master um
INNER JOIN
(
    SELECT LOWER(TRIM(email)) AS normalized_email
    FROM security.user_master
    WHERE user_type_id = 3
      AND email IS NOT NULL
      AND TRIM(email) <> ''
    GROUP BY LOWER(TRIM(email))
    HAVING COUNT(*) > 1
) dup
    ON LOWER(TRIM(um.email)) = dup.normalized_email
WHERE um.user_type_id = 3
ORDER BY LOWER(TRIM(um.email)), um.id;

select * from utility.approval_process_detail apm where apm.approval_process_id =19899


SELECT
    qm.id AS quotation_id,
    qm.rfq_vendor_detail_id,
    rqm.revisedquotationno,
    rqm.rfqno,
    rqm.vendorlocationno,
    rqm.auctionno,
    rvd.id AS rfq_vendor_detail_id_found,
    rvd.rfq_id AS matched_rfq_id,
    rvd.vendor_location_id AS matched_vendor_location_id
FROM purchase.quotation_main qm
INNER JOIN sqlserver_fdw.revisedquotationmain rqm
    ON rqm.revisedquotationno = qm.id
LEFT JOIN purchase.pur_rfq_vendor_detail rvd
    ON rvd.rfq_id = rqm.rfqno
   AND rvd.vendor_location_id = rqm.vendorlocationno
WHERE qm.is_auction = false
  AND qm.rfq_vendor_detail_id IS NULL
ORDER BY qm.id;


SELECT doc_no_yearly
FROM purchase.cs_main
WHERE doc_no_yearly !~ '^[0-9]+$'
LIMIT 20;

SELECT doc_no_yearly
FROM purchase.pur_rfq_main
WHERE doc_no_yearly !~ '^[0-9]+$'
LIMIT 20;


--- QUOTATION ITEM DETAIL DUPLICATE FIX
-- update query
--- updating makeNo in quotaton_item_detail
--17873  null to 156
--17911  156 to null
--216264 null to 736
--224614 null to 736

update purchase.quotation_item_detail
set make_id=736
where id=224614

-- check quotation item detail
SELECT
    qid.quotation_id,
    qid.item_id,
    COALESCE(qid.make_id, 0) AS make_id,
    COUNT(*) AS qid_count
FROM purchase.quotation_item_detail qid
GROUP BY
    qid.quotation_id,
    qid.item_id,
    COALESCE(qid.make_id, 0)
HAVING COUNT(*) > 1
ORDER BY qid_count DESC;


--check quotation item tax detail
SELECT
    qid.revisedquotationno,
    qid.itemNo,
    COALESCE(qid.makeNo, 0) AS make_id,
    qid.miscchargeno,
    COUNT(*) AS qid_count
FROM sqlserver_fdw.revisedquotationitemtaxdetail qid
GROUP BY
    qid.revisedquotationNo,
    qid.itemNo,
    COALESCE(qid.makeNo, 0),
    qid.miscchargeno
HAVING COUNT(*) > 1
ORDER BY qid_count DESC;

--check itemTax rows that has no correponding itemDetail
SELECT
    qitd.RevisedQuotationNo,
    qitd.ItemNo,
    qitd.MakeNo,
    qitd.MiscChargeNo
FROM sqlserver_fdw.revisedquotationitemtaxdetail qitd
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.quotation_id = qitd.RevisedQuotationNo
   AND qid.item_id = qitd.ItemNo
   AND COALESCE(qid.make_id, 0) = COALESCE(qitd.MakeNo, 0)
WHERE qid.quotation_id IS NULL
ORDER BY
    qitd.RevisedQuotationNo,
    qitd.ItemNo,
    qitd.MakeNo,
    qitd.MiscChargeNo;

--- these items are missing
--qNo,   iNo,   mkNo
--24262, 50495, 587
--41313, 14762, 669
-- 62801, 55423, 669


----QUotation item detail, rfqItemDetailId incident
select count(*) from purchase.quotation_item_detail qid 
where qid.rfq_item_detail_id is null

SELECT
    rqid.RevisedQuotationItemNo,
    rqid.RevisedQuotationNo,
    rqid.ItemNo,
    rqid.RFQMakeNo,
    qid.id AS target_qid_id,
    qid.rfq_item_detail_id
FROM sqlserver_fdw.revisedquotationitemdetail rqid
INNER JOIN purchase.quotation_main qm
    ON qm.id = rqid.RevisedQuotationNo
LEFT JOIN purchase.pur_rfq_item_detail rfqi
    ON rfqi.rfq_id = qm.rfq_id
   AND rfqi.item_id = rqid.ItemNo
   AND COALESCE(rfqi.make_id, 0) = COALESCE(rqid.RFQMakeNo, 0)
LEFT JOIN purchase.quotation_item_detail qid
    ON qid.id = rqid.RevisedQuotationItemNo
WHERE rfqi.id IS NULL
ORDER BY rqid.RevisedQuotationItemNo;

SELECT
    rqid.RevisedQuotationItemNo,
    rqid.RevisedQuotationNo,
    rqid.ItemNo,
    rqid.RFQMakeNo,
    rqid.MakeNo,
    qm.rfq_id,
    qid.rfq_item_detail_id AS target_rfq_item_detail_id,
    rfqi.id AS current_matching_rfq_item_detail_id,
    rfqi.item_id AS matched_item_id,
    rfqi.make_id AS matched_make_id
FROM sqlserver_fdw.revisedquotationitemdetail rqid
INNER JOIN purchase.quotation_main qm
    ON qm.id = rqid.RevisedQuotationNo
INNER JOIN purchase.quotation_item_detail qid
    ON qid.id = rqid.RevisedQuotationItemNo
LEFT JOIN purchase.pur_rfq_item_detail rfqi
    ON rfqi.rfq_id = qm.rfq_id
   AND rfqi.item_id = rqid.ItemNo
   AND COALESCE(rfqi.make_id, 0) = COALESCE(rqid.RFQMakeNo, 0)
WHERE rfqi.id IS NULL
  AND qid.rfq_item_detail_id IS NOT NULL
ORDER BY rqid.RevisedQuotationItemNo;


SELECT
    COUNT(*) AS total_quotations,
    COUNT(*) FILTER (
        WHERE qm.rfq_id = rq.rfqno
    ) AS matching_rfq,
    COUNT(*) FILTER (
        WHERE qm.rfq_id <> rq.rfqno
    ) AS different_rfq,
    COUNT(*) FILTER (
        WHERE qm.rfq_id IS NULL
    ) AS pg_null_rfq
FROM sqlserver_fdw.revisedquotationmain rq
INNER JOIN purchase.quotation_main qm
    ON qm.id = rq.revisedquotationno;


SELECT
    COUNT(*) AS missing_quotation_main
FROM sqlserver_fdw.revisedquotationmain rq
LEFT JOIN purchase.quotation_main qm
    ON qm.id = rq.RevisedQuotationNo
WHERE qm.id IS null
and rq.auctionno is null;

SELECT
    COUNT(*) AS total_unmatched,
    COUNT(*) FILTER (WHERE prd.id IS NOT NULL) AS_found_in_pg,
    COUNT(*) FILTER (WHERE prd.id IS NULL) AS_missing_in_pg
FROM sqlserver_fdw.revisedquotationitemdetail rid
JOIN sqlserver_fdw.revisedquotationmain rq
    ON rq.revisedquotationno = rid.revisedquotationno
LEFT JOIN purchase.pur_rfq_item_detail prd
    ON prd.rfq_id = rq.rfqno
   AND prd.item_id = rid.itemno
   AND COALESCE(prd.make_id, 0) = COALESCE(rid.rfqmakeno, 0)
WHERE NOT EXISTS (
    SELECT 1
    FROM sqlserver_fdw.rfqitemdetail rd
    WHERE rd.rfqno = rq.rfqno
      AND rd.itemno = rid.itemno
      AND COALESCE(rd.makeno, 0) = COALESCE(rid.rfqmakeno, 0)
);


SELECT COUNT(*) AS source_rfq_items_missing_in_pg
FROM sqlserver_fdw.rfqitemdetail rd
LEFT JOIN purchase.pur_rfq_item_detail prd
    ON prd.rfq_id = rd.rfqno
   AND prd.item_id = rd.itemno
   AND COALESCE(prd.make_id, 0) = COALESCE(rd.makeno, 0)
WHERE prd.id IS NULL;

SELECT
    rq.rfqno,
    COUNT(*) AS unmatched_item_count
FROM sqlserver_fdw.revisedquotationitemdetail rid
JOIN sqlserver_fdw.revisedquotationmain rq
    ON rq.revisedquotationno = rid.revisedquotationno
WHERE NOT EXISTS (
    SELECT 1
    FROM sqlserver_fdw.rfqitemdetail rd
    WHERE rd.rfqno = rq.rfqno
      AND rd.itemno = rid.itemno
      AND COALESCE(rd.makeno, 0) = COALESCE(rid.rfqmakeno, 0)
)
GROUP BY rq.rfqno
ORDER BY unmatched_item_count DESC
LIMIT 20;


select count(*) from sqlserver_fdw.revisedquotationmain r
where r.rfqno is null and r.auctionno is null

select count(*) from purchase.quotation_main qm
where qm.rfq_id is null

SELECT COUNT(*) AS unmatched_non_null_rfq
FROM sqlserver_fdw.revisedquotationitemdetail rid
JOIN sqlserver_fdw.revisedquotationmain rq
    ON rq.revisedquotationno = rid.revisedquotationno
WHERE rq.auctionNo is not NULL
  AND NOT EXISTS (
      SELECT 1
      FROM sqlserver_fdw.rfqitemdetail rd
      WHERE rd.rfqno = rq.rfqno
        AND rd.itemno = rid.itemno
        AND COALESCE(rd.makeno, 0) = COALESCE(rid.rfqmakeno, 0)
  );



--16221, 16220 -> 1221

select * from purchase.quotation_main qm 
where qm.id in (16221, 16220);

select * from sqlserver_fdw.revisedquotationmain qm 
where qm.revisedquotationno  in (16221, 16220)

select * from sqlserver_fdw.csquotationdetail c 
where c.revisedquotationno  in (16221, 16220)


select * from purchase.cs_pr_detail cpd 

select * from purchase.quotation_item_detail qid
inner join purchase.quotation_main qm 
on qm.id = qid.quotation_id 
where qid.rfq_item_detail_id is null
and qm.is_auction is false

--update purchase.quotation_main qm
--set rfq_id=r.rfqNo
--from sqlserver_fdw.revisedquotationmain r
--where r.revisedquotationno = qm.id
--and qm.is_auction is false
--and qm.rfq_id <> r.rfqno 

select count(*) from purchase.quotation_main qm 
inner join sqlserver_fdw.revisedquotationmain r 
on r.revisedquotationno =qm.id 
where qm.rfq_id <> r.rfqno 
and qm.is_auction is false

select cqd. from purchase.cs_quotation_detail cqd 
where cqd.quotation_id =20128


select p.poamendmentno, p.itemno, p.makeno , p.miscchargeno  from sqlserver_fdw.poamendmentitemtaxdetail p 
group by p.poamendmentno, p.itemno, p.makeno , p.miscchargeno
having count(*u)


select count(*) from purchase.quotation_item_detail r
inner join purchase.quotation_main r2 
on r.quotation_id  = r2.id
left join sqlserver_fdw.rfqitemdetail r3 
on r3.rfqno = r2.rfq_id 
and r3.itemno = r.item_id
and coalesce(r3.makeno,0) = coalesce(r.rfq_make_id,0)
where r2.is_auction is false
and r3.rfqno is null


--UPDATE purchase.quotation_item_detail qid
--SET rfq_item_detail_id = rfqi.id
--FROM sqlserver_fdw.revisedquotationitemdetail rqid
--INNER JOIN purchase.quotation_main qm
--ON qm.id = rqid.RevisedQuotationNo
--left JOIN purchase.pur_rfq_item_detail rfqi
--ON rfqi.rfq_id = qm.rfq_id
--AND rfqi.item_id = rqid.itemNo
--AND COALESCE(rfqi.make_id, 0) = COALESCE(rqid.rfqmakeNo, 0)
--WHERE qid.id=rqid.revisedquotationitemno 

SELECT
    cm.id AS cs_id,
    cqd.quotation_id,
    COUNT(*) AS detail_count
FROM purchase.cs_main cm
INNER JOIN purchase.cs_quotation_detail cqd
    ON cqd.cs_id = cm.id
WHERE cm.ref_doc_type_no = 7
  AND cqd.quotation_item_detail_id IS NULL
GROUP BY
    cm.id,
    cqd.quotation_id
HAVING COUNT(*) > 1
ORDER BY
    detail_count DESC;

SELECT
    cm.id AS cs_id,
    cqd.revisedquotationno ,
    COUNT(*) AS detail_count
FROM purchase.cs_main cm
INNER JOIN sqlserver_fdw.csquotationdetail cqd
    ON cqd.csno  = cm.id
WHERE cm.ref_doc_type_no = 7
  AND cqd.itemno IS NULL
GROUP BY
    cm.id,
    cqd.revisedquotationno 
HAVING COUNT(*) > 1
ORDER BY
    detail_count DESC;

select * from sqlserver_fdw.csmain cm 

SELECT
    cqd.id,
    cqd.cs_id,
    cqd.quotation_id,
    cqd.quotation_item_detail_id,
    cqd.qty
FROM purchase.cs_quotation_detail cqd
WHERE cqd.cs_id = 20
  AND cqd.quotation_id = 168
  AND cqd.quotation_item_detail_id IS NULL
ORDER BY cqd.id;

SELECT
    cqd.qquotationno ,
    cqd.csno ,
    cqd.revisedquotationno ,
    cqd.itemno,
    cqd.makeno,
    cqd.quantity 
FROM sqlserver_fdw.csquotationdetail cqd
WHERE cqd.csno  = 20
  AND cqd.revisedquotationno  = 168
  AND cqd.itemno  IS null
  
  
  "qquotationno","csno","revisedquotationno","isselected","makeno","itemno","quantity","id","fy_id","company_id","division_id","doc_type_id","doc_no_yearly","doc_date","doc_series_id","selection_criteria_id","ref_doc_type_no","rfq_id","ref_cs_id","vendor_selection_basis_id","validity_date","remarks","approval_setup_id","created_by_id","created_date","modified_by_id","modified_date","authorized_by_id","authorized_date","document_status_id","doc_sequence_no","id","quotation_id","line_no","rfq_item_detail_id","item_id","hsn_code","rfq_make_id","make_id","other_make_name","qty","unit_id","rate","tax_amount","delivery_days","basic_amount","net_amount","tech_spec","remarks","discount_amount","discount_per_qty","discount_rate","rate_after_discount"
1039,176,812,true,,8874,40.000,176,6,2,,2,"000152",2018-02-08,,1,7,337,,1,2018-05-09,,,33,2018-02-08 12:31:00.000 +0530,33,2018-02-13 15:30:00.000 +0530,33,2018-02-13 15:30:00.000 +0530,30,,,,,,,,,,,,,,,,,,,,,,,
1045,176,819,true,,7769,40.000,176,6,2,,2,"000152",2018-02-08,,1,7,337,,1,2018-05-09,,,33,2018-02-08 12:31:00.000 +0530,33,2018-02-13 15:30:00.000 +0530,33,2018-02-13 15:30:00.000 +0530,30,,,,,,,,,,,,,,,,,,,,,,,

select qid.quotation_id, qid2.revisedquotationno, qid.item_id , qid2.itemno from purchase.quotation_item_detail qid
inner join sqlserver_fdw.revisedquotationitemdetail qid2
on qid.id=qid2.revisedquotationitemno 
where qid.item_id <> qid2.itemno 
or qid.make_id <> qid2.makeno



select * from purchase.quotation_item_detail qid
where qid.quotation_id in (812,819)

select * from sqlserver_fdw.revisedquotationitemdetail qid
where qid.revisedquotationno in (812,819)
  
  select * from
	sqlserver_fdw.csquotationdetail cqd
inner join purchase.cs_main cm
on cm.id= cqd.csNo
left join purchase.quotation_item_detail qid
on qid.item_id = cqd.itemNo
	and coalesce(cqd.makeNo, 0) = coalesce(qid.rfq_make_id, 0)
	and qid.quotation_id = cqd.RevisedQuotationNo
where cqd.itemNo is not null
and qid.id is null
and cqd.isSelected is true
and cqd.RevisedQuotationNo is not null
and exists (
	select 1
	from
		purchase.quotation_main q
	where
		q.id = cqd.RevisedQuotationNo
  );
  
  
 select * from
	sqlserver_fdw.csquotationdetail cqd
left join sqlserver_fdw.revisedquotationitemdetail qid
    on
	qid.itemNo = cqd.itemNo
	and coalesce(cqd.makeNo, 0) = coalesce(qid.rfqmakeNo, 0)
	and qid.revisedQuotationNo = cqd.RevisedQuotationNo
where cqd.itemNo is not null
and qid.revisedQuotationItemno is null
and
	cqd.isSelected is true
	and cqd.RevisedQuotationNo is not null
	and exists (
	select 1
	from
		purchase.quotation_main q
	where
		q.id = cqd.RevisedQuotationNo
  );
 
--delete from purchase.quotation_item_detail;
--delete from purchase.quotation_item_tax_detail;
--delete from purchase.cs_pr_detail;
--
--delete from purchase.cs_quotation_detail;
--delete from purchase.cs_reason_detail;
--delete from purchase.cs_rank_detail;

select * from purchase.quotation_item_detail qid 
where qid.quotation_id in (168, 812, 819, 83050)
and qid.item_id in (10378, 30259, 30255, 25128, 20265, 14183, 14035, 5351, 8874, 7769, 2535)

------------------------------------Verification Scripts-------------------------------------------------------------------------------

-------------------------Purchase Request ----------------------------------
-- PrMain NetAmount must match PrItemDetail amount sum

select count(*) from (
select 
	prm.id as prmid, 
	sum(prid.amount),
	prm.net_amount
from inventory.purchase_request_main prm
inner join inventory.purchase_request_item_detail prid 
on prid.pur_req_id = prm.id
group by prm.id 
having sum(prid.amount)!=prm.net_amount
)

-- PrItemDetail qty*rate != amount
select 
	prid.pr_qty,
	prid.rate, 
	prid.amount  
from inventory.purchase_request_item_detail prid
where 
	prid.pr_qty * prid.rate != prid.amount;

--- Approval Process
	
--- Active level must contain only status 3
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 3) AS pending_count,
    COUNT(*) FILTER (
        WHERE apd.status_id <> 3 OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
INNER JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
WHERE apm.is_current = true
  AND apd.level_no = COALESCE(apm.current_approved_level_no, 0) + 1
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (
    WHERE apd.status_id <> 3 OR apd.status_id IS NULL
) > 0
ORDER BY
    apd.approval_process_id;


---Every level before active level must have 12 or 13
--- one issue (19899)
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE apd.status_id IN (12, 13)
    ) AS completed_count
FROM utility.approval_process_detail apd
INNER JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
WHERE apm.is_current = true
  AND apd.level_no < COALESCE(apm.current_approved_level_no, 0) + 1
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (
    WHERE apd.status_id IN (12, 13)
) = 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;


---Every level after active level must be status 20
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 20) AS status_20_count,
    COUNT(*) FILTER (
        WHERE apd.status_id <> 20 OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
INNER JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
WHERE apm.is_current = true
  AND apd.level_no > COALESCE(apm.current_approved_level_no, 0) + 1
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (
    WHERE apd.status_id <> 20 OR apd.status_id IS NULL
) > 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;



---- Current approval level must be highest level which has 12
WITH calculated AS
(
    SELECT
        approval_process_id,
        MAX(
            CASE
                WHEN status_id IN (12, 13)
                THEN level_no
            END
        ) AS calculated_current_approved_level_no
    FROM utility.approval_process_detail
    GROUP BY approval_process_id
)
SELECT
    apm.id AS approval_process_id,
    apm.current_approved_level_no,
    c.calculated_current_approved_level_no
FROM utility.approval_process_main apm
INNER JOIN calculated c
    ON c.approval_process_id = apm.id
WHERE apm.is_current = true
  AND apm.current_approved_level_no IS DISTINCT FROM
      c.calculated_current_approved_level_no
ORDER BY apm.id;


---Completed approved levels: remaining users must be 21
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 12) AS approved_count,
    COUNT(*) FILTER (WHERE apd.status_id = 21) AS peer_approved_count,
    COUNT(*) FILTER (
        WHERE apd.status_id NOT IN (12, 21)
           OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (WHERE apd.status_id = 12) > 0
   AND COUNT(*) FILTER (
       WHERE apd.status_id NOT IN (12, 21)
          OR apd.status_id IS NULL
   ) > 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;



---Completed rejected levels: remaining users must be 29
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 13) AS rejected_count,
    COUNT(*) FILTER (WHERE apd.status_id = 29) AS peer_rejected_count,
    COUNT(*) FILTER (
        WHERE apd.status_id NOT IN (13, 29)
           OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (WHERE apd.status_id = 13) > 0
   AND COUNT(*) FILTER (
       WHERE apd.status_id NOT IN (13, 29)
          OR apd.status_id IS NULL
   ) > 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;


---Check that 12 and 13 don't coexist at the same level
SELECT
    approval_process_id,
    level_no,
    COUNT(*) FILTER (WHERE status_id = 12) AS approved_count,
    COUNT(*) FILTER (WHERE status_id = 13) AS rejected_count
FROM utility.approval_process_detail
GROUP BY
    approval_process_id,
    level_no
HAVING COUNT(*) FILTER (WHERE status_id = 12) > 0
   AND COUNT(*) FILTER (WHERE status_id = 13) > 0
ORDER BY
    approval_process_id,
    level_no;



---Also check level sequence
WITH levels AS
(
    SELECT DISTINCT
        approval_process_id,
        level_no
    FROM utility.approval_process_detail
),
numbered AS
(
    SELECT
        approval_process_id,
        level_no,
        ROW_NUMBER() OVER (
            PARTITION BY approval_process_id
            ORDER BY level_no
        ) AS expected_level_no
    FROM levels
)
SELECT
    approval_process_id,
    level_no,
    expected_level_no
FROM numbered
WHERE level_no <> expected_level_no
ORDER BY
    approval_process_id,
    level_no;








-------------------
--discount operations
select qid.id, qid.item_id , qid.make_id , qid.basic_amount , qid.tax_amount, qid.net_amount, sum(qitd.amount) from purchase.quotation_item_detail qid 
inner join purchase.quotation_item_tax_detail qitd  
on qitd.quotation_item_detail_id = qid.id 
group by qid.id, qitd.tax_id
having qitd.tax_id =8


SELECT
    qit.quotation_item_detail_id,
    qit.quotation_id,
    qit.tax_id,
    qit.nature_id,
    qit.charge_type_id,
    qit.charge_on_id,
    qit.charge_value,
    qit.amount,
    qid.tax_amount,
    qid.basic_amount,
    qid.net_amount,
    qid.qty,
    qid.rate,
    qid.basic_amount,
    qid.discount_amount,
    qid.discount_per_qty,
    qid.discount_rate,
    qid.rate_after_discount
FROM purchase.quotation_item_tax_detail qit
INNER JOIN purchase.quotation_item_detail qid
    ON qid.id = qit.quotation_item_detail_id
WHERE qit.tax_id = 8
ORDER BY qit.quotation_item_detail_id desc;

update purchase.quotation_item_detail qid
set discount_amount= qit.amount,
	discount_per_qty=qit.amount / qid.qty,
	discount_rate= 100 * (qit.amount / qid.basic_amount),
	rate_after_discount = qid.rate  - (qit.amount / qid.qty)
FROM purchase.quotation_item_tax_detail qit
where qid.id = qit.quotation_item_detail_id
and qit.tax_id = 8

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
	

select * from sqlserver_fdw.revisedquotationmain r where r.revisedquotationno =42604;

select * from sqlserver_fdw.revisedquotationitemdetail r where r.revisedquotationno =42604;

select * from sqlserver_fdw.revisedquotationtaxdetail r where r.revisedquotationno =42604;

select * from sqlserver_fdw.revisedquotationitemtaxdetail r where r.revisedquotationno =42604;

SELECT
    tm.id,
    tm.tax_name ,
    tm.calc_nature_id
FROM masterdata.tax_master tm
WHERE tm.id IN (
    SELECT DISTINCT tax_id
    FROM purchase.quotation_tax_detail

    UNION

    SELECT DISTINCT tax_id
    FROM purchase.quotation_item_tax_detail
)
ORDER BY tm.id;


-------------------------------------------------------------------------------------------------------------------------

select * from purchase.quotation_main r where r.id =42604;

select * from purchase.quotation_item_detail r where r.quotation_id =42604;

select * from purchase.quotation_tax_detail r where r.quotation_id =42604;

select * from purchase.quotation_item_tax_detail r where r.quotation_id =42604;



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
WHERE qit.id IS null and tm.id not in (103,104,105)

select * from purchase.quotation_main qm where qm.id=142852

SELECT
    count(*)
FROM sqlserver_fdw.revisedquotationotherchargedetail qtd
LEFT JOIN sqlserver_fdw.revisedquotationitemotherchargedetail qit
    ON qit.revisedquotationno  = qtd.revisedquotationno 
   AND qit.otherchargeno  = qtd.otherchargeno 
WHERE qit.revisedquotationitemotherchargeno  IS null

SELECT
    *
FROM sqlserver_fdw.revisedquotationtaxdetail qtd
LEFT JOIN sqlserver_fdw.revisedquotationitemtaxdetail qit
    ON qit.revisedquotationno  = qtd.revisedquotationno 
   AND qit.miscchargeno = qtd.miscchargeno  
WHERE qit.revisedquotationitemtaxno   IS null




select distinct r.otherchargeno   from sqlserver_fdw.revisedquotationotherchargedetail r 
inner join masterdata.tax_master tm 
on tm.id = r.otherchargeno 

select * from masterdata.tax_master tm 
order by id


SELECT
    qtd.quotation_id,
    qtd.tax_id,
    qtd.amount AS quotation_tax_amount,
    qid.id AS quotation_item_detail_id,
    qid.basic_amount,
    SUM(qid.basic_amount) OVER (
        PARTITION BY qid.quotation_id
    ) AS total_basic_amount,
    ROUND(
        qtd.amount * qid.basic_amount
        / NULLIF(
            SUM(qid.basic_amount) OVER (
                PARTITION BY qid.quotation_id
            ), 0
        ),
        2
    ) AS calculated_item_tax_amount
FROM purchase.quotation_tax_detail qtd
INNER JOIN purchase.quotation_item_detail qid
    ON qid.quotation_id = qtd.quotation_id
WHERE NOT EXISTS (
    SELECT 1
    FROM purchase.quotation_item_tax_detail qit
    WHERE qit.quotation_id = qtd.quotation_id
      AND qit.tax_id = qtd.tax_id
)
ORDER BY
    qtd.quotation_id,
    qtd.tax_id,
    qid.id;


select count(*) from purchase.pur_rfq_main prm
where prm.document_status_id  in (30)
and prm.due_date > prm.doc_date 


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


select * from masterdata.tax_master tm 



select count(*) from (
SELECT
    csm.id AS cs_id,
    csm.document_status_id,
    apm.id AS approval_process_id,
    COUNT(apd.id) AS detail_count
FROM purchase.cs_main csm
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = csm.id
   AND apm.form_id = 8
INNER JOIN utility.approval_process_detail apd
    ON apd.approval_process_id = apm.id
WHERE csm.document_status_id = 10
  AND apm.status_id = 7
GROUP BY
    csm.id,
    csm.document_status_id,
    apm.id
HAVING BOOL_AND(apd.status_id = 3)
ORDER BY csm.id
) x;


SELECT
    csm.id AS cs_id,
    csm.document_status_id,
    apm.id AS approval_process_id,
    COUNT(apd.id) AS detail_count,
    COUNT(*) FILTER (WHERE apd.status_id = 3) AS pending_count,
    COUNT(*) FILTER (WHERE apd.status_id = 12) AS approved_count
FROM purchase.cs_main csm
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = csm.id
   AND apm.form_id = 8
INNER JOIN utility.approval_process_detail apd
    ON apd.approval_process_id = apm.id
WHERE csm.document_status_id IN (10, 20)
  AND apm.status_id = 7
GROUP BY
    csm.id,
    csm.document_status_id,
    apm.id
HAVING
    BOOL_OR(apd.status_id = 3)
    AND BOOL_OR(apd.status_id = 12)
ORDER BY csm.id;


select count(*) from (
SELECT
    csm.id AS cs_id,
    apm.id AS approval_process_id,
    apd.id AS approval_process_detail_id,
    apd.level_no,
    apd.status_id
FROM purchase.cs_main csm
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = csm.id
   AND apm.form_id = 8
INNER JOIN utility.approval_process_detail apd
    ON apd.approval_process_id = apm.id
WHERE csm.document_status_id = 20
  AND apm.status_id = 7
  AND NOT EXISTS (
      SELECT 1
      FROM utility.approval_process_detail apd2
      WHERE apd2.approval_process_id = apm.id
        AND apd2.status_id <> 20
  )
ORDER BY
    csm.id,
    apm.id,
    apd.level_no
) x;


UPDATE utility.approval_process_detail apd
SET status_id =
    CASE
        WHEN apd.level_no = 1 THEN 3
        ELSE 20
    END
FROM utility.approval_process_main apm
INNER JOIN purchase.cs_main csm
    ON csm.id = apm.doc_id
WHERE apd.approval_process_id = apm.id
  AND apm.form_id = 8
  AND csm.document_status_id = 20
  AND apm.status_id = 7
  AND apd.status_id = 20
  AND NOT EXISTS (
      SELECT 1
      FROM utility.approval_process_detail apd2
      WHERE apd2.approval_process_id = apm.id
        AND apd2.status_id <> 20
  );

SELECT
    csm.id AS cs_id,
    csm.document_status_id,
    c.documentStatusNo,
    apm.id AS approval_process_id,
    COUNT(apd.id) AS detail_count,
    COUNT(*) FILTER (WHERE apd.status_id = 3) AS pending_count,
    COUNT(*) FILTER (WHERE apd.status_id = 12) AS approved_count
FROM purchase.cs_main csm
inner join sqlserver_fdw.csMain c
on csm.id = c.csNo
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = csm.id
   AND apm.form_id = 8
INNER JOIN utility.approval_process_detail apd
    ON apd.approval_process_id = apm.id
WHERE csm.document_status_id IN (20)
  AND apm.status_id = 7
GROUP BY
    csm.id,
    csm.document_status_id,
    c.documentStatusNo,
    apm.id
HAVING
    BOOL_OR(apd.status_id = 3)
    AND BOOL_OR(apd.status_id = 12)
ORDER BY csm.id;


update utility.approval_process_main apm 
set status_id=9
where apm.doc_id in (7214,
15401,
26686,
36214,
57531,
58409,
66861,
72012,
72698) and apm.form_id =8

select count(*) from (
SELECT
    csm.id AS cs_id,
    csm.document_status_id,
    apm.id AS approval_process_id,
    apm.status_id AS current_approval_status
FROM purchase.cs_main csm
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = csm.id
   AND apm.form_id = 8
WHERE csm.document_status_id = 20
  AND apm.status_id <> 14
ORDER BY csm.id
) x;



select distinct apm.status_id  from purchase.cs_main cm 
inner join utility.approval_process_main apm 
on apm.doc_id  =cm.id and apm.form_id =8
where cm.document_status_id =20 and apm.status_id <> 14

update utility.approval_process_main apm 
set status_id=14
from purchase.cs_main cm 
where cm.id = apm.doc_id 
and apm.doc_id =8
and apm.status_id <> 14
and cm.document_status_id = 20

UPDATE utility.approval_process_main apm
SET status_id = 14
FROM purchase.cs_main csm
WHERE apm.doc_id = csm.id
  AND apm.form_id = 8
  AND csm.document_status_id = 20
  AND apm.status_id <> 14;

select * from purchase.cs_main cm
inner join utility.approval_process_main apm 
on cm.id = apm.doc_id and apm.form_id =8
where cm.document_status_id = 30 and apm.status_id <> 9



select pom.id, apm.id, pom.document_status_id, pom.status_id, apm.status_id  from utility.approval_process_main apm
inner join inventory.purchase_request_main pom 
on pom.id = apm.doc_id and apm.form_id =6
where pom.document_status_id =10 and exists (
select 1 from utility.approval_process_detail apd 
where apd.approval_process_id  = apm.id
and apd.status_id <> 20
)

select * from utility.approval_process_detail apd 
where apd.approval_process_id =8041

select pom.id, apm.id, pom.document_status_id, pom.status_id, apm.status_id  from utility.approval_process_main apm
inner join purchase.purchase_order_main pom 
on pom.id = apm.doc_id and apm.form_id =10
where pom.document_status_id =20 and not exists (
select 1 from utility.approval_process_detail apd 
where apd.approval_process_id  = apm.id
and apd.status_id <> 20)


select pom.id, apm.id, pom.document_status_id, pom.status_id, apm.status_id  from utility.approval_process_main apm
inner join purchase.purchase_order_main pom 
on pom.id = apm.doc_id and apm.form_id =10
where pom.document_status_id =30 and apm.status_id <> 9

select pom.id, apm.id, pom.document_status_id, pom.status_id, apm.status_id  from utility.approval_process_main apm
inner join inventory.purchase_request_main pom 
on pom.id = apm.doc_id and apm.form_id =6
where pom.document_status_id =30 and apm.status_id <> 9


select pom.id, apm.id, pom.document_status_id, pom.status_id, apm.status_id  from utility.approval_process_main apm
inner join purchase.purchase_order_main pom 
on pom.id = apm.doc_id and apm.form_id =10
where pom.document_status_id =30 and exists (
select 1 from utility.approval_process_detail apd 
where apd.approval_process_id  = apm.id
and apd.status_id in (20,3)
)



select apd.id, pom.id, apd.approval_process_id as apid , apd.level_no as lvl , apd.status_id as st, apm.status_id as stapm, pom.document_status_id as docSt, apd.user_id as usr from utility.approval_process_detail apd 
left join utility.approval_process_main apm on apm.id = apd.approval_process_id 
left join inventory.purchase_request_main pom on pom.id=apm.doc_id and apm.form_id =6
where apd.approval_process_id  in (8041,8097,8121,8148,8171,8190,8202,8234,8257,8259,8273,8278,8287,8301,8316,8321,8327,8343,8346,8353,8357,8365,8367,8389,8391,8393,8443,8451,8455,8460,8466,8471,8483,8485,8506,8509,8511,8518,8521,8522,8524,8537,8539,8543,8555,8566,8576,8578,8581,8583,8622,8639,8657,8662,8691,8696,8718,8725,8736,8757,8767,8771,8778,8779,8793,8795,8806,8814,8831,8833,8845,8849,8850,8875,8880,8884,8891,8897,8905,8909,8917,8923,8934,8937,8941,8943,8956,8959,8962,8974,8988,8993,9003,9018,9034,9040,9055,9058,9062,9065,9066,9095,9105,9106,9111,9118,9119,9123,9126,9133,9135,9136,9159,9164,9176,9183,9188,9194,9200,9208,9214,9226,9230,9234,9242,9243,9244,9251,9255,9264,9283,9288,9307,9343,9344,9369,9374,9383,9403,9405,9407,9424,9467,9474,9475,9478,9490,9505,9506,9507,9509,9514,9556,9563,9567,9574,9589,9605,9672,9686,9710,9718,9736,9742,9748,9750,9762,9775,9800,9823,9827,9830,9832,9834,9835,9844,9865,9877,9886,9895,9905,9916,9954,9981,9985,9991,10002,10028,10055,10065,10082,10113,10120,10134,10145,10147,10163,10187,10204,10209,10216,10248,10282,10303,10313,10314,10328,10344,10352,10362,10373,10400,10404,10415,10439,10466,10478,10525,10526,10545,10546,10555,10570,10634,10576,10618,10625,10628,10644,10646,10681,10686,10696,10714,10729,10733,10737,10744,10757,10763,10778,10793,10814,10821,10857,10885,10898,10899,10947,10980,10996,11001,11003,11009,11030,11033,11076,11104,11108,11138,11166,11167,11206,11208,11209,11225,11241,11244,11247,11249,11261,11274,11280,11326,11333,11339,11355,11429,11437,11447,11460,11487,11519,11525,11541,11575,11581,11584,11615,11620,11651,11686,11690,11696,11700,11770,11787,11805,11806,11815,11844,11861,11865,11866,11883,11918,11933,11945,11965,11972,11973,11980,11982,11983,11987,11992,11998,12026,12037,12069,12073,12093,12142,12179,12196,12198,12235,12284,12292,12300,12312,12351,12365,12388,12390,12396,12399,12410,12420,12425,12476,12565,12602,12622,12630,12679,12690,12703,12712,12734,12739,12744,12748,12779,12794,12798,12897,12899,12905,12927,12957,12965,12981,13041,13056,13064,13376,13094,13109,13115,13122,13166,13201,13204,13207,13209,13243,13253,13278,13303,13318,13339,13386,13388,13400,13419,13422,13438,13450,13503,13574,13657,13670,13688,13693,13700,13756,13759,13763,13768,13784,13786,13804,13812,13813,13864,13900,13930,13937,13946,14004,14052,14074,14118,14119,14127,14128,14138,14173,14204,14258,14259,14313,14322,14349,14419,14447,14482,14492,14498,14531,14535,14572,14577,14598,14653,14662,14670,14684,14693,14751,14775,14776,14792,14828,14849,14864,14920,14929,14932,14948,14957,14989,14998,15016,15105,15122,15124,15155,15175,15181,15278,15313,15332,15338,15384,15423,15427,15429,15455,15474,15485,15500,15506,15513,15534,15539,15579,15617,15629,15786,15795,15813,15863,15878,15929,15938,15952,15962,15993,16027,16088,16103,16137,16155,16196,16220,16221,16222,16227,16231,16244,16248,16264,16270,16273,16323,16331,16333,16338,16367,16371,16383,16385,16434,16453,16486,16514,16515,16533,16535,16543,16550,16574,16580,16601,16619,16634,16641,16651,16664,16719,16725,16744,16751,16752,16759,16766,16769,16778,16790,16792,16819,16827,16829,16832,16834,16840,16868,16870,16880,16883,16894,16895,16921,16974,16978,17002,17007,17055,17061,17091,17097,17098,17153,17207,17221,17222,17225,17253,17275,17296,17306,17330,17344,17346,17347,17351,17353,17363,17410,17416,17418,17438,17451,17467,17551,17577,17588,17596,17601,17606,17618,17631,17680,17681,17709,17711,17768,17770,17783,17792,17807,17815,17824,17830,17859,17874,17938,17957,17978,17993,18000,18012,18020,18037,18047,18051,18052,18069,18090,18117,18119,18120,18123,18131,18133,18169,18185,18233,18244,18247,18248,18251,18256,18343,18396,18425,18428,18496,18505,18512,18527,18528,18562,18580,18600,18627,18642,18652,18663,18682,18696,18700,18716,18719,18879,18903,18908,18915,18918,18931,18938,18959,18960,18979,18993,19018,19029,19054,19056,19063,19067,19068,19070,19090,19112,19116,19123,19240,19243,19259,19261,19269,19299,19319,19328,19357,19377,19380,19404,19460,19464,19474,19488,19510,19516,19583,19669,19688,19705,19714,19727,19736,19750,19755,19778,19805,19811,19834,19838,19846,19850,19882,19907,19993,19996,20011,20047,20068,20084,20109,20147,20181,20213,20240,20249,20268,20291,20311,20329,20388,20404,20433,20451,20473,20479,20508,20510,20515,20542,20544,20560,20564,20571,20579,20583,20599,20610,20621,20625,20628,20659,20662,20678,20683,20695,20713,20721,20722)
order by apd.approval_process_id, apd.level_no 


select * from inventory.purchase_request_main prm 



--soumen bose - 2090

update purchase.purchase_order_main pom 
set document_status_id =20, status_id=14
where pom.id in (9015,83078,83139,84520,85310,87167,91646,96554,98025)

update utility.approval_process_main pom 
set status_id=14
where pom.doc_id  in (9015,83078,83139,84520,85310,87167,91646,96554,98025)
and pom.form_id =10

update utility.approval_process_main apm
set status_id=14
from purchase.purchase_order_main pom 
where pom.id = apm.doc_id and apm.form_id =10
and pom.document_status_id = 20 and apm.status_id = 7


select * from utility.approval_process_detail apd 
where apd.approval_process_id =129660

select apm.form_id , apm.doc_id , apm.id, apm.status_id , apd.id, apd.level_no , apd.status_id  from utility.approval_process_detail apd 
left join utility.approval_process_main apm 
on apm.id=apd.approval_process_id 
where apd.approval_process_id =7955

select * from inventory.purchase_request_main prm 
where prm.id=77046

--case 1 for pr
SELECT
    pom.id AS po_id,
    apm.id AS approval_process_id,
    COUNT(apd.id) AS detail_count
FROM inventory.purchase_request_main pom
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = pom.id
   AND apm.form_id = 6
INNER JOIN utility.approval_process_detail apd
    ON apd.approval_process_id = apm.id
WHERE pom.status_id = 7
  AND apm.status_id = 7
GROUP BY
    pom.id,
    apm.id
HAVING BOOL_AND(apd.status_id = 3)
ORDER BY pom.id;


--case 2 for pr
SELECT
    pom.id AS po_id,
    apm.id AS approval_process_id,
    COUNT(apd.id) AS detail_count
FROM inventory.purchase_request_main pom
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = pom.id
   AND apm.form_id = 6
INNER JOIN utility.approval_process_detail apd
    ON apd.approval_process_id = apm.id
WHERE pom.status_id = 7
  AND apm.status_id = 7
GROUP BY
    pom.id,
    apm.id
HAVING BOOL_AND(apd.status_id = 12)
ORDER BY pom.id;


--case 3 for pr
SELECT
    pom.id AS po_id,
    apm.id AS approval_process_id,
    COUNT(apd.id) AS detail_count,
    COUNT(*) FILTER (WHERE apd.status_id = 3) AS pending_count,
    COUNT(*) FILTER (WHERE apd.status_id = 12) AS approved_count
FROM inventory.purchase_request_main pom
INNER JOIN utility.approval_process_main apm
    ON apm.doc_id = pom.id
   AND apm.form_id = 6
INNER JOIN utility.approval_process_detail apd
    ON apd.approval_process_id = apm.id
WHERE pom.status_id = 7
  AND apm.status_id = 7
GROUP BY
    pom.id,
    apm.id
HAVING
    BOOL_OR(apd.status_id = 3)
    AND BOOL_OR(apd.status_id = 12)
ORDER BY pom.id;


select prm.id, prm.document_status_id, CASE
        WHEN i.isreadyforauthorization = true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    END  from inventory.purchase_request_main prm 
inner join sqlserver_fdw.indentmain i
on i.indentno  =prm.id
where i.documentstatusno =10 and prm.document_status_id <> CASE
        WHEN i.isreadyforauthorization = true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    END
    
    
    
 update inventory.purchase_request_main prm 
 set document_status_id = CASE
        WHEN i.isreadyforauthorization = 1
             AND i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end

    
    
---- compare pr docStatus and sqlserver docStatus
select prm.id,prm.document_status_id prDocSt, prm.status_id prSt, CASE
        WHEN i.isreadyforauthorization = true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end from inventory.purchase_request_main prm 
inner join sqlserver_fdw.indentmain i 
on i.indentno  = prm.id
where prm.document_status_id <> CASE
        WHEN i.isreadyforauthorization = true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end
order by prdocst 




---- compare po docStatus and sqlserver docStatus    
select prm.id,prm.document_status_id, prm.status_id, CASE
        WHEN i.isreadyforauthorization = 1
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    END from purchase.purchase_order_main prm 
inner join sqlserver_fdw.poamendmentmain i 
on i.poamendmentNo  = prm.id
where prm.document_status_id <> CASE
        WHEN i.isreadyforauthorization = 1
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    END

    
    select * from sqlserver_fdw.poamendmentauthorizationdetail p 
    where p.poamendmentno in (9015,83078,83139,84520,85310,87167,91646,96554,98025)
 
 
---compare prItemDetail status    
select prid.id, prid.pur_req_id , prid.status_id, sm.new_status_id  from inventory.purchase_request_item_detail prid 
inner join sqlserver_fdw.indentitemdetail i 
on prid.id = i.indentitemdetailno 
inner join migration.status_mapping sm 
on sm.old_status_id =i.statusno 
where prid.status_id <> sm.new_status_id and sm.new_status_id <> 5
order by prid.pur_req_id 
    
--- postgres pipeline view for pr statuses
select prm.document_status_id , prm.status_id  from inventory.purchase_request_main prm
where prm.id =77293;

select prid.status_id, prid.pr_qty , prid.balance_qty ,prid.po_qty from inventory.purchase_request_item_detail prid 
where prid.pur_req_id =77293;


---- sql server pipeline view for pr statuses
select i.documentstatusno  from sqlserver_fdw.indentmain i 
where i.indentNo=77070;

select i.statusno  from sqlserver_fdw.indentitemdetail i 
where i.indentNo=77070;

select i.levelno ,i.statusno, i.isready   from sqlserver_fdw.indentauthorizationdetail i 
where i.indentno =77293;


--- sql server pipeline view for cs statius
--12346
select i.documentstatusno  from sqlserver_fdw.csmain i 
where i.csNo=12346;

select i.csno, i.levelno ,i.statusno, i.isready   from sqlserver_fdw.csauthorizationdetail i 
where i.csno in (7379,7417,7420,8017,8056,8152,8476,9234,9282,9424,9445,10680,11223,11225,11483,11734,11823,12062,12346,14724,14746,15184,16275,16276,17013,17713,18632,24371,25111,26502,27991,30900,38146,40873,42832,53342);

---------------------------------------------------------------
select i.poamendmentNo, i.documentStatusNo from sqlserver_fdw.poamendmentmain i
where CASE
        WHEN i.isreadyforauthorization = 1
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end = 10
    and exists (
    select 1 from sqlserver_fdw.poamendmentauthorizationdetail p2 
    where p2.poamendmentno =i.poamendmentNo and (p2.isready is true or p2.statusNo<>5)
    )

    select * from sqlserver_fdw.poamendmentauthorizationdetail p 
    where p.poamendmentno in (18986)

    select * from sqlserver_fdw.poamendmentmain p where p.poamendmentno in (18986);
    select * from sqlserver_fdw.poamendmentitemdetail p where p.poamendmentno in (18986);
    
 select i.poamendmentNo, CASE
        WHEN i.isreadyforauthorization = 1
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end from sqlserver_fdw.poamendmentmain i
where CASE
        WHEN i.isreadyforauthorization = 1
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end = 20
    and not exists (
    select 1 from sqlserver_fdw.poamendmentauthorizationdetail p2 
    where p2.poamendmentno =i.poamendmentNo and (p2.isready is true )
    )

SELECT
    i.poamendmentno,
    p2.levelno,
    COUNT(*) AS level_detail_count,
    COUNT(*) FILTER (WHERE p2.statusno = 1) AS approved_count
FROM sqlserver_fdw.poamendmentmain i
INNER JOIN sqlserver_fdw.poamendmentauthorizationdetail p2
    ON p2.poamendmentno = i.poamendmentno
WHERE
    CASE
        WHEN i.isreadyforauthorization = 1
             AND i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    END = 30
GROUP BY
    i.poamendmentno,
    p2.levelno
HAVING COUNT(*) FILTER (WHERE p2.statusno = 1) = 0
ORDER BY
    i.poamendmentno,
    p2.levelno;    
    
    select * from sqlserver_fdw.poamendmentauthorizationdetail p 
    where p.poamendmentno =18986
 
    
    
    ------------------------------------------------------------------------------------
    
select i.indentNo, CASE
        WHEN i.isreadyforauthorization is true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end from sqlserver_fdw.indentmain i
where CASE
        WHEN i.isreadyforauthorization is true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end = 10
    and exists (
    select 1 from sqlserver_fdw.indentauthorizationdetail p2 
    where p2.indentno =i.indentNo and (p2.isready is true or p2.statusNo<>5)
    )
    
    
SELECT
    i.indentno,
    p2.levelno,
    COUNT(*) AS level_detail_count,
    COUNT(*) FILTER (WHERE p2.statusno = 1) AS approved_count
FROM sqlserver_fdw.indentMain i
INNER JOIN sqlserver_fdw.indentauthorizationdetail p2
    ON p2.indentno = i.indentno
WHERE
    CASE
        WHEN i.isreadyforauthorization is true
             AND i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    END = 30
GROUP BY
    i.indentno,
    p2.levelno
HAVING COUNT(*) FILTER (WHERE p2.statusno = 1) = 0
ORDER BY
    i.indentno,
    p2.levelno;   

--pr inreviee
WITH MaxLevel AS (
    SELECT
        IndentNo,
        MAX(LevelNo) AS MaxLevelNo
    FROM sqlserver_fdw.IndentAuthorizationDetail
    GROUP BY IndentNo
)
SELECT
    i.IndentNo,
    ml.MaxLevelNo
FROM sqlserver_fdw.IndentMain i
INNER JOIN MaxLevel ml
    ON ml.IndentNo = i.IndentNo
WHERE i.DocumentStatusNo = 10
  AND i.IsReadyForAuthorization is true
  AND EXISTS (
      SELECT 1
      FROM sqlserver_fdw.IndentAuthorizationDetail d
      WHERE d.IndentNo = i.IndentNo
        AND d.LevelNo = ml.MaxLevelNo
        AND d.StatusNo = 1
  )
ORDER BY i.IndentNo;

--po inreview
WITH MaxLevel AS (
    SELECT
        poamendmentNo,
        MAX(LevelNo) AS MaxLevelNo
    FROM sqlserver_fdw.poamendmentauthorizationdetail
    GROUP BY poamendmentNo
)
SELECT
    i.poamendmentNo,
    ml.MaxLevelNo
FROM sqlserver_fdw.poamendmentmain i
INNER JOIN MaxLevel ml
    ON ml.poamendmentNo = i.poamendmentNo
WHERE i.DocumentStatusNo = 10
  AND i.IsReadyForAuthorization =1
  AND EXISTS (
      SELECT 1
      FROM sqlserver_fdw.poamendmentauthorizationdetail d
      WHERE d.poamendmentNo = i.poamendmentNo
        AND d.LevelNo = ml.MaxLevelNo
        AND d.StatusNo = 1
  )
ORDER BY i.poamendmentNo;

---------------------------------------------------------------------------
---cs



select i.csNo, CASE
        WHEN i.isreadyforauthorization is true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end from sqlserver_fdw.csmain i
where CASE
        WHEN i.isreadyforauthorization is true
             and i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    end = 10
    and exists (
    select 1 from sqlserver_fdw.csauthorizationdetail p2 
    where p2.csNo =i.csNo and (p2.isready is true or p2.statusNo<>5)
    )
    
select distinct x.csNo from (
SELECT
    i.csNo,
    p2.levelno,
    COUNT(*) AS level_detail_count,
    COUNT(*) FILTER (WHERE p2.statusno = 1) AS approved_count
FROM sqlserver_fdw.csMain i
INNER JOIN sqlserver_fdw.csauthorizationdetail p2
    ON p2.csNo = i.csNo
WHERE
    CASE
        WHEN i.isreadyforauthorization is true
             AND i.documentstatusno = 10
        THEN 20
        ELSE i.documentstatusno
    END = 30
GROUP BY
    i.csNo,
    p2.levelno
HAVING COUNT(*) FILTER (WHERE p2.statusno = 1) = 0 ) x;
ORDER BY
    i.csNo,
    p2.levelno;   

--cs inreview
WITH MaxLevel AS (
    SELECT
        csNo,
        MAX(LevelNo) AS MaxLevelNo
    FROM sqlserver_fdw.csauthorizationdetail
    GROUP BY csNo
)
SELECT
    i.csNo,
    ml.MaxLevelNo
FROM sqlserver_fdw.csmain i
INNER JOIN MaxLevel ml
    ON ml.csNo = i.csNo
WHERE i.DocumentStatusNo = 10
  AND i.IsReadyForAuthorization is true
  AND EXISTS (
      SELECT 1
      FROM sqlserver_fdw.csauthorizationdetail d
      WHERE d.csNo = i.csNo
        AND d.LevelNo = ml.MaxLevelNo
        AND d.StatusNo = 1
  )
ORDER BY i.csNo;


--------------------------------------------------------------------------------------------------------

select count(distinct c.csno)  from sqlserver_fdw.csindentdetail c 
where c.csno in (7379,7417,7417,7420,7420,8017,8056,8152,8476,9234,9282,9424,9445,10680,10680,10680,11223,11225,11483,11734,11823,11823,12062,12346,14724,14746,15184,16275,16276,17013,17713,18632,24371,25111,26502,27991,30900,38146,40873,42832,53342)

select count(distinct poid.csno) from sqlserver_fdw.poamendmentitemdetail poid 
where poid.csno in (7379,7417,7417,7420,7420,8017,8056,8152,8476,9234,9282,9424,9445,10680,10680,10680,11223,11225,11483,11734,11823,11823,12062,12346,14724,14746,15184,16275,16276,17013,17713,18632,24371,25111,26502,27991,30900,38146,40873,42832,53342)

--------------
WITH abc AS (
    SELECT
        prm.id,
        prm.document_status_id AS psqlDocStatus,
        CASE
            WHEN i.IsReadyForAuthorization IS TRUE
                 AND i.DocumentStatusNo = 10
            THEN 20
            ELSE i.DocumentStatusNo
        END AS sqlDocStatus
    FROM inventory.purchase_request_main prm
    INNER JOIN sqlserver_fdw.IndentMain i
        ON i.IndentNo = prm.id
    WHERE
        CASE
            WHEN i.IsReadyForAuthorization IS TRUE
                 AND i.DocumentStatusNo = 10
            THEN 20
            ELSE i.DocumentStatusNo
        END <> prm.document_status_id
)
SELECT
    abc.id AS pr_id,
    abc.psqlDocStatus,
    abc.sqlDocStatus
FROM abc
WHERE EXISTS (
    SELECT 1
    FROM purchase.purchase_order_pr_item_detail popid
    left join inventory.purchase_request_item_detail prm 
    on prm.id=popid.pr_item_detail_id 
    WHERE prm.pur_req_id  = abc.id
)
ORDER BY abc.id;


--UPDATE inventory.purchase_request_main prm
--SET document_status_id =
--    CASE
--        WHEN i.IsReadyForAuthorization IS TRUE
--             AND i.DocumentStatusNo = 10
--        THEN 20
--        ELSE i.DocumentStatusNo
--    END
--FROM sqlserver_fdw.IndentMain i
--WHERE i.IndentNo = prm.id
--  AND
--    CASE
--        WHEN i.IsReadyForAuthorization IS TRUE
--             AND i.DocumentStatusNo = 10
--        THEN 20
--        ELSE i.DocumentStatusNo
--    END <> prm.document_status_id;
--


--update purchase.purchase_order_main pom 
--set document_status_id= CASE
--        WHEN p.isreadyforauthorization =1
--             and p.documentstatusno = 10
--        THEN 20
--        ELSE p.documentstatusno
--    end
--from sqlserver_fdw.poamendmentmain p 
--where  p.poamendmentNo = pom.id
--and CASE
--        WHEN p.isreadyforauthorization =1
--             and p.documentstatusno = 10
--        THEN 20
--        ELSE p.documentstatusno
--    end <> pom.document_status_id 


select c.csNo, c.levelno , c.statusno from sqlserver_fdw.csauthorizationdetail c
where c.csno in (7379,7417,7420,8017,8056,8152,8476,9234,9282,9424,9445,10680,11223,11225,11483,11734,11823,12062,12346,14724,14746,15184,16275,16276,17013,17713,18632,24371,25111,26502,27991,30900,38146,40873,42832,53342)
and not exists (
select 1 from sqlserver_fdw.csauthorizationdetail c2 
where c2.csno =c.csno 
and c2.statusno =1
)

select * from sqlserver_fdw.csauthorizationdetail c 
left join purchase.cs_main cm on cm.csNo = c.csno 
where c.csno in (7417,7420,10680,11823)


select * from utility.approval_process_main apm 
where apm.id=19899

select * from utility.approval_process_detail apd 
where apd.approval_process_id =19899

select count(1) from purchase.cs_main cm 
inner join utility.approval_process_main apm 
on cm.id =apm.doc_id and apm.form_id =8
where cm.approval_setup_id is null


select * from sqlserver_fdw.csmain c 
left join sqlserver_fdw.csauthorizationdetail c2 
on c.csno =c2.csno 
where



SELECT 'vendor_master' AS table_name, code, COUNT(*) AS duplicate_count
FROM masterdata.vendor_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'vendor_master_location_detail', code, COUNT(*)
FROM masterdata.vendor_master_location_detail
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'announcement_master', code, COUNT(*)
FROM masterdata.announcement_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'business_type_master', code, COUNT(*)
FROM masterdata.business_type_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'channel_provider_configuration', code, COUNT(*)
FROM masterdata.channel_provider_configuration
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'city_master', code, COUNT(*)
FROM masterdata.city_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'company_master_location_detail', code, COUNT(*)
FROM masterdata.company_master_location_detail
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'company_master', code, COUNT(*)
FROM masterdata.company_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'cost_center_master', code, COUNT(*)
FROM masterdata.cost_center_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'document_series_master', code, COUNT(*)
FROM masterdata.document_series_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'expense_group_master', code, COUNT(*)
FROM masterdata.expense_group_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'expense_master', code, COUNT(*)
FROM masterdata.expense_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'payment_terms_group_master', code, COUNT(*)
FROM masterdata.payment_terms_group_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'po_cs_exemption_master', code, COUNT(*)
FROM utility.po_cs_exemption_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'priority_master', code, COUNT(*)
FROM masterdata.priority_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'region_master', code, COUNT(*)
FROM masterdata.region_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'state_master', code, COUNT(*)
FROM masterdata.state_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'terms_n_condition_group_master', code, COUNT(*)
FROM masterdata.terms_n_condition_group_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'terms_n_condition_head_master', code, COUNT(*)
FROM masterdata.terms_n_condition_head_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'vendor_category', code, COUNT(*)
FROM masterdata.vendor_category
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'supplier_account_master', code, COUNT(*)
FROM security.supplier_account_master
GROUP BY code HAVING COUNT(*) > 1
UNION ALL
SELECT 'whitelist_ip_main', code, COUNT(*)
FROM utility.whitelist_ip_main
GROUP BY code HAVING COUNT(*) > 1
ORDER BY table_name, duplicate_count DESC;



update masterdata.vendor_master vm 
set code= m.code
from sqlserver_fdw.mvendorcard m
where vm.id = m.vendorNo
and vm.code <> m.code

update masterdata.vendor_master_location_detail vm 
set code= m.code
from sqlserver_fdw.mvendorlocationdetail m
where vm.id = m.vendorlocationno 
and vm.code <> m.code

select count(*) from masterdata.vendor_master_location_detail vm
inner join sqlserver_fdw.mvendorlocationdetail m
on vm.id = m.vendorlocationno 
where vm.code <> m.code




-----------------------------


select * from masterdata.department_master;
select * from masterdata.division_master;
select * from masterdata.cost_center_master ccm ;
select * from masterdata.approval_setup_master ;
select * from masterdata.business_type_master;
select * from masterdata.city_master cm ;
select * from masterdata.country_master cm ;
select * from masterdata.cs_reason_master;
select * from masterdata.expense_group_master ;
select * from masterdata.fin_year fy  ;
select * from masterdata.location_master lm  ;
select * from masterdata.make_master mm  ;
select * from masterdata.pr_reason_master  cm ;
select * from masterdata.priority_master pm  ;
select * from masterdata.region_master rm  ;
select * from masterdata.role_master rm  ;
select * from masterdata.state_master sm ;
select * from masterdata.payment_terms_group_master ptgm  ;
select * from masterdata.terms_n_condition_head_master tnchm ;
select * from masterdata.unit_master um  ;
select * from masterdata.company_master cm ;
select * from masterdata.company_master_location_detail cm ;
select * from masterdata.vendor_master vmld ;
SELECT
    (regexp_match(code, '^([A-Za-z]+)'))[1] AS prefix,
    COUNT(*) AS total_count
FROM masterdata.vendor_master_location_detail
WHERE code ~ '^[A-Za-z]+[0-9]'
GROUP BY 1
ORDER BY 1;
select * from masterdata.vendor_master_location_detail vmld ;
select * from masterdata.vendor_category vc ;

select * from masterdata.vendor_registration vr ;
select * from masterdata.warehouse_master wm  ;

select * from utility.duplicate_item_group_main digm ;
select * from utility.whitelist_ip_main wim ;


select * from sqlserver_fdw.mtermsnconditiongroup m ;
select * from sqlserver_fdw.mtermsnconditiongroupdetail m  ;
select * from sqlserver_fdw.mtermsnconditionhead m ;


select l.loginno  from sqlserver_fdw.login l 
group by l.loginno 
having count(1) > 1


select m.divisioncode , count(1) from sqlserver_fdw.mdivisionmaster m 
group by m.divisioncode 
having count(1)>1


select main_approval_id , revision_no, count(1) from masterdata.approval_setup_master
group by main_approval_id , revision_no 
having count(1)>1

select id, main_approval_id, revision_no , is_current   from masterdata.approval_setup_master

select * from sqlserver_fdw.mauthorizationGroup


SELECT
    qm.id AS updating_id,
    qm.revision_no,
    qm.main_approval_id AS current_main_approval_id,
    x.main_approval_id AS new_main_approval_id,
    existing.id AS conflicting_id,
    existing.main_approval_id AS conflicting_main_approval_id
FROM masterdata.approval_setup_master qm
JOIN (
    SELECT
        r.AuthGrpRevisionNo AS approval_id,
        qf.AuthGrpRevisionNo AS main_approval_id
    FROM sqlserver_fdw.mauthorizationgroup r
    INNER JOIN (
        SELECT
            AuthGrpRevisionNo,
            AuthorizationGroupNo,
            ROW_NUMBER() OVER (
                PARTITION BY AuthorizationGroupNo
                ORDER BY RevisionNo, AuthGrpRevisionNo
            ) AS rn
        FROM sqlserver_fdw.mauthorizationgroup
    ) qf
        ON qf.AuthorizationGroupNo = r.AuthorizationGroupNo
       AND qf.rn = 1
) x
    ON qm.id = x.approval_id
JOIN masterdata.approval_setup_master existing
    ON existing.main_approval_id = x.main_approval_id
   AND existing.revision_no = qm.revision_no
   AND existing.id <> qm.id
ORDER BY
    x.main_approval_id,
    qm.revision_no;


SELECT
    id,
    revision_no,
    main_approval_id
FROM masterdata.approval_setup_master
WHERE main_approval_id = 2
   OR id = 2
ORDER BY revision_no, id;


SELECT
    r.AuthGrpRevisionNo,
    r.AuthorizationGroupNo,
    r.RevisionNo,
    qf.AuthGrpRevisionNo AS main_approval_id
FROM sqlserver_fdw.mauthorizationgroup r
INNER JOIN (
    SELECT
        AuthGrpRevisionNo,
        AuthorizationGroupNo,
        ROW_NUMBER() OVER (
            PARTITION BY AuthorizationGroupNo
            ORDER BY RevisionNo, AuthGrpRevisionNo
        ) AS rn
    FROM sqlserver_fdw.mauthorizationgroup
) qf
    ON qf.AuthorizationGroupNo = r.AuthorizationGroupNo
   AND qf.rn = 1
ORDER BY
    r.AuthorizationGroupNo,
    r.RevisionNo,
    r.AuthGrpRevisionNo;



SELECT
    x.main_approval_id,
    x.revision_no,
    COUNT(*) AS cnt,
    ARRAY_AGG(x.approval_id ORDER BY x.approval_id) AS approval_ids
FROM (
    SELECT
        r.AuthGrpRevisionNo AS approval_id,
        r.RevisionNo AS revision_no,
        qf.AuthGrpRevisionNo AS main_approval_id
    FROM sqlserver_fdw.mauthorizationgroup r
    INNER JOIN (
        SELECT
            AuthGrpRevisionNo,
            AuthorizationGroupNo,
            ROW_NUMBER() OVER (
                PARTITION BY AuthorizationGroupNo
                ORDER BY RevisionNo, AuthGrpRevisionNo
            ) AS rn
        FROM sqlserver_fdw.mauthorizationgroup
    ) qf
        ON qf.AuthorizationGroupNo = r.AuthorizationGroupNo
       AND qf.rn = 1
) x
GROUP BY
    x.main_approval_id,
    x.revision_no
HAVING COUNT(*) > 1;



SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'masterdata'
  AND table_name = 'approval_setup_master'
  AND column_name IN ('main_approval_id', 'revision_no');

SELECT
    conname,
    pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'masterdata.approval_setup_master'::regclass;


select * from sqlserver_fdw.indentmain i 
where i.divisionno is null


select qm.revisedQuotationNo, qm.authorizedBy from sqlserver_fdw.revisedQuotationMain qm
left join sqlserver_fdw.login l 
on l.loginno = qm.authorizedBy
where qm.authorizedBy is not null and l.loginno is null and qm.authorizedBy <> 0;

select qm.revisedQuotationNo, qm.createdBy from sqlserver_fdw.revisedQuotationMain qm
left join sqlserver_fdw.login l 
on l.loginno = qm.createdBy
where qm.createdBy is not null and l.loginno is null and qm.createdBy <> 0;

select * from sqlserver_fdw.revisedquotationmain r 
where r.createdby = 431

select distinct qm.authorizedBy from sqlserver_fdw.revisedquotationmain qm

select l.loginNo from sqlserver_fdw.login l
where l.loginNo in (480, 431, 973, 1110)


select * from purchase.quotation_main qm 
where qm.authorized_by_id in (480, 431, 973, 1110)

select qm.authorized_by_id  from purchase.quotation_main qm 
where qm.id in (2299,1713,2211,5552,5837,7153,7154,7150,8865,8866,12479,19628,20403)


select * from globaldata.ref_doc_type rdt 


select i.indentno, ia.indentauthorizationdetailno   from sqlserver_fdw.indentauthorizationdetail ia
left join sqlserver_fdw.indentmain i 
on i.indentno  = ia.indentno 
where i.authgrprevisionno is null

select  i.authgrprevisionno  from sqlserver_fdw.indentauthorizationdetail ia 
left join sqlserver_fdw.indentmain i 
on i.indentno  = ia.indentno 

select i.authgrprevisionno  from sqlserver_fdw.indentmain i 
where i.indentno  in (87582,87582,87582,87582,87582,87582,87582,87582,87582,87582)

update inventory.purchase_request_main
set approval_setup_id=120
where id = 87582


-------------------------------------------------------------------



--DELETE FROM purchase.purchase_order_summary;
--
--DELETE FROM purchase.purchase_order_pr_item_process_detail;
--
--DELETE FROM purchase.purchase_order_item_process_detail;
--
--DELETE FROM purchase.po_cancellation_pr_detail;
--
--DELETE FROM purchase.po_cancellation_item_detail;
--
--DELETE FROM purchase.po_cancellation_main;
--
--DELETE FROM purchase.purchase_order_item_tax_detail;
--
--DELETE FROM purchase.purchase_order_item_detail;
--
--DELETE FROM purchase.purchase_order_terms_n_condition_detail;
--
--DELETE FROM purchase.purchase_order_tax_detail;
--
--DELETE FROM purchase.purchase_order_main;
--
--DELETE FROM purchase.purchase_order_pr_item_detail;
--
--DELETE FROM purchase.purchase_order_schedule_detail;
--
--DELETE FROM purchase.cs_rank_detail;
--
--DELETE FROM purchase.cs_quotation_participation_detail;
--
--DELETE FROM purchase.cs_reason_detail;
--
--DELETE FROM purchase.cs_quotation_detail;
--
--DELETE FROM purchase.cs_pr_detail;
--
--DELETE FROM purchase.cs_company_detail;
--
--DELETE FROM purchase.cs_main;
--
--DELETE FROM purchase.quotation_summary;
--
--DELETE FROM purchase.quotation_company_detail;
--
--DELETE FROM purchase.quotation_terms_condition_detail;
--
--DELETE FROM purchase.quotation_item_tax_detail;
--
--DELETE FROM purchase.quotation_tax_detail;
--
--DELETE FROM purchase.quotation_item_detail;
--
--DELETE FROM purchase.quotation_main;
--
--DELETE FROM purchase.quotation_inform_to_detail;
--
--DELETE FROM purchase.pur_rfq_vendor_contact_person_detail;
--
--DELETE FROM purchase.pur_rfq_vendor_detail;
--
--DELETE FROM purchase.pur_rfq_company_detail;
--
--DELETE FROM purchase.pur_rfq_tnc_detail;
--
--DELETE FROM purchase.pur_rfq_pr_detail;
--
--DELETE FROM purchase.pur_rfq_item_detail;
--
--DELETE FROM purchase.pur_rfq_main;
--
--DELETE FROM purchase.pur_rfq_due_date_log;
--
--DELETE FROM purchase.pur_rfq_pr_item_removal_log_detail;
--
--DELETE FROM purchase.pur_rfq_pr_item_removal_log_main;
--
--DELETE FROM utility.purchase_request_cancellation_item_detail;
--
--DELETE FROM utility.purchase_request_cancellation_main;
--
--DELETE FROM inventory.purchase_request_item_detail;
--
--DELETE FROM inventory.purchase_request_inform_to_detail;
--
--DELETE FROM inventory.purchase_request_main;
--
--
--
--
--DELETE FROM purchase.auction_tnc_detail;
--
--DELETE FROM purchase.auction_end_time_log;
--
--DELETE FROM purchase.auction_company_detail;
--
--DELETE FROM purchase.auction_vendor_contact_person_detail;
--
--DELETE FROM purchase.auction_vendor_detail;
--
--DELETE FROM purchase.auction_item_detail;
--
--DELETE FROM purchase.auction_main;



select * from purchase.quotation_item_detail qid
where qid.quotation_id = 42542;

select * from sqlserver_fdw.revisedquotationitemdetail r 
where r.revisedquotationno = 42542;

select * from sqlserver_fdw.revisedquotationitemdetail r
inner join purchase.quotation_item_detail qid 
on qid.id = r.revisedquotationitemno 
where coalesce(qid.make_id,0) <> coalesce(r.makeno,0)



update purchase.quotation_item_detail qid 
set make_id=552
where id = 165481


drop table sql_migration.csindentdetail


