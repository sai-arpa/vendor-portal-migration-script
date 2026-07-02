select *
FROM sqlserver_fdw.poamendmentitemdetail
where poamendmentno =107

SELECT COUNT(*)
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsid.ChangePOStatusNo;

SELECT COUNT(*)
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsid.ChangePOStatusNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
   AND prid.item_id = cpsid.POItemNo
   AND COALESCE(prid.make_id,0) = COALESCE(cpsid.POMakeNo,0);

SELECT COUNT(*)
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsid.ChangePOStatusNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
   AND prid.item_id = cpsid.POItemNo
   AND COALESCE(prid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = pcm.po_id
   AND poid.item_id = cpsid.POItemNo
   AND
   (
       COALESCE(cpsid.POMakeNo,0) = 0
       OR COALESCE(poid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
   );



SELECT
    cpsid.ChangePOStatusIndentDetailsNo,
    cpsid.ChangePOStatusNo,
    cpsid.IndentNo,
    cpsid.POItemNo,
    cpsid.POMakeNo,
    cpsid.IndentItemLineNo,
    cpsid.CancelQty
FROM sqlserver_fdw.changepostatusindentdetails cpsid
LEFT JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
   AND prid.item_id = cpsid.POItemNo
   AND COALESCE(prid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
WHERE prid.id IS NULL
ORDER BY cpsid.ChangePOStatusIndentDetailsNo;



SELECT
    cpsid.ChangePOStatusIndentDetailsNo,
    cpsid.IndentNo,
    cpsid.POItemNo,
    cpsid.POMakeNo,
    cpsid.IndentItemLineNo,
    prid.id,
    prid.make_id
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
   AND prid.item_id = cpsid.POItemNo
WHERE NOT EXISTS
(
    SELECT 1
    FROM inventory.purchase_request_item_detail p2
    WHERE p2.pur_req_id = cpsid.IndentNo
      AND p2.line_no = cpsid.IndentItemLineNo
      AND p2.item_id = cpsid.POItemNo
      AND COALESCE(p2.make_id,0) = COALESCE(cpsid.POMakeNo,0)
);

SELECT
    cpsid.ChangePOStatusIndentDetailsNo,
    COUNT(*) AS cnt,
    ARRAY_AGG(poid.id) AS po_item_ids,
    ARRAY_AGG(poid.item_id) AS po_items,
    ARRAY_AGG(COALESCE(poid.make_id,0)) AS po_makes
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsid.ChangePOStatusNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = pcm.po_id
   AND poid.item_id = cpsid.POItemNo
   AND COALESCE(poid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
INNER JOIN purchase.po_cancellation_item_detail pcid
    ON pcid.po_cancellation_id = pcm.id
   AND pcid.po_item_detail_id = poid.id
GROUP BY cpsid.ChangePOStatusIndentDetailsNo
HAVING COUNT(*) > 1;



SELECT pci.id ,pci.po_cancellation_id ,pci.po_item_detail_id , pci.cancel_qty , pcm.doc_date 
FROM purchase.po_cancellation_item_detail pci
inner join purchase.po_cancellation_main pcm 
on pcm.id=pci.po_cancellation_id 
WHERE pci.po_cancellation_id = 57
  AND pci.po_item_detail_id = 68415;


SELECT
    ChangePOStatusNo,
    ItemNo,
    MakeNo,
    COUNT(*)
FROM sqlserver_fdw.changepostatusitemdetails
GROUP BY
    ChangePOStatusNo,
    ItemNo,
    MakeNo
HAVING COUNT(*) > 1;

SELECT
    po_cancellation_id,
    po_item_detail_id,
    COUNT(*)
FROM purchase.po_cancellation_item_detail
GROUP BY
    po_cancellation_id,
    po_item_detail_id
HAVING COUNT(*) > 1;


SELECT COUNT(*)
FROM sqlserver_fdw.changepostatusindentdetails cpsid
INNER JOIN purchase.po_cancellation_main pcm
    ON pcm.id = cpsid.ChangePOStatusNo
INNER JOIN inventory.purchase_request_item_detail prid
    ON prid.pur_req_id = cpsid.IndentNo
   AND prid.line_no = cpsid.IndentItemLineNo
   AND prid.item_id = cpsid.POItemNo
   AND COALESCE(prid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = pcm.po_id
   AND poid.item_id = cpsid.POItemNo
   AND
   (
       COALESCE(cpsid.POMakeNo,0) = 0
       OR COALESCE(poid.make_id,0) = COALESCE(cpsid.POMakeNo,0)
   )
INNER JOIN purchase.po_cancellation_item_detail pcid
    ON pcid.po_cancellation_id = pcm.id
   AND pcid.po_item_detail_id = poid.id;



SELECT *
FROM purchase.purchase_order_pr_item_detail
WHERE po_id = 810
  AND pr_item_detail_id = 14299
  AND item_id = 1482
  AND po_make_id IS NULL;



SELECT
    po_id,
    pr_item_detail_id,
    item_id,
    po_make_id,
    COUNT(*)
FROM purchase.purchase_order_pr_item_detail
GROUP BY
    po_id,
    pr_item_detail_id,
    item_id,
    po_make_id
HAVING COUNT(*) > 1;



select * from purchase.po_cancellation_pr_detail pcpd 
select count(*) from purchase.purchase_order_pr_item_detail pcpd 
truncate table purchase.purchase_order_pr_item_detail cascade


select pos.poamendmentno , pos.itemno , pos.makeno, pos.scheduledate , count(*)  from sqlserver_fdw.poamendmentitemscheduledetail pos
group by pos.poamendmentno , pos.itemno , pos.makeno, pos.scheduledate 
having count(*)>1

select * from sqlserver_fdw.poamendmentitemscheduledetail pos

WITH duplicate_groups AS
(
    SELECT
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0) AS MakeNo,
        COUNT(*) AS total_rows,
        COUNT(DISTINCT ScheduleDate) AS distinct_schedule_dates,
        MIN(ScheduleDate) AS min_schedule_date,
        MAX(ScheduleDate) AS max_schedule_date,
        SUM(COALESCE(ScheduleQty,0)) AS total_qty
    FROM sqlserver_fdw.poamendmentitemscheduledetail
    GROUP BY
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0)
    HAVING COUNT(*) > 1
)
SELECT
    *
FROM duplicate_groups
ORDER BY
    distinct_schedule_dates DESC,
    total_rows DESC;

select count(*) from (
WITH merged_schedule AS
(
    SELECT
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0) AS MakeNo,
        COUNT(*) AS cnt
    FROM sqlserver_fdw.poamendmentitemscheduledetail
    GROUP BY
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0)
)
SELECT
    ms.*
FROM merged_schedule ms
LEFT JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = ms.POAmendmentNo
   AND poid.item_id = ms.ItemNo
   AND COALESCE(poid.make_id,0) = ms.MakeNo
WHERE poid.id IS NULL
ORDER BY
    ms.POAmendmentNo,
    ms.ItemNo);


WITH merged_schedule AS
(
    SELECT
        MIN(POAmendmentISDetailNo) AS new_id,
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0) AS MakeNo,
        ScheduleDate,
        SUM(COALESCE(ScheduleQty,0)) AS ScheduleQty
    FROM sqlserver_fdw.poamendmentitemscheduledetail
    GROUP BY
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0),
        ScheduleDate
)
SELECT COUNT(*)
FROM merged_schedule;


WITH sched AS
(
    SELECT
        POAmendmentISDetailNo,
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0) AS MakeNo
    FROM sqlserver_fdw.poamendmentitemscheduledetail
)
SELECT
    s.POAmendmentISDetailNo,
    s.POAmendmentNo,
    s.ItemNo,
    s.MakeNo
FROM sched s
LEFT JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = s.POAmendmentNo
   AND poid.item_id = s.ItemNo
   AND COALESCE(poid.make_id,0) = s.MakeNo
WHERE poid.id IS NULL
LIMIT 100;


WITH sched AS
(
    SELECT
        POAmendmentISDetailNo,
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0) AS MakeNo
    FROM sqlserver_fdw.poamendmentitemscheduledetail
),
classified AS
(
    SELECT
        s.*,
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM purchase.purchase_order_item_detail p3
                WHERE p3.po_id = s.POAmendmentNo
                  AND p3.item_id = s.ItemNo
                  AND COALESCE(p3.make_id,0) = s.MakeNo
            )
            THEN 'exact_match'
            WHEN EXISTS
            (
                SELECT 1
                FROM purchase.purchase_order_item_detail p2
                WHERE p2.po_id = s.POAmendmentNo
                  AND p2.item_id = s.ItemNo
            )
            THEN 'make_mismatch'
            WHEN EXISTS
            (
                SELECT 1
                FROM purchase.purchase_order_item_detail p1
                WHERE p1.po_id = s.POAmendmentNo
            )
            THEN 'item_mismatch'
            ELSE 'po_missing'
        END AS mismatch_type
    FROM sched s
)
SELECT
    c.mismatch_type,
    COUNT(*) AS row_count,
    MIN(pom.doc_date) AS min_doc_date,
    MAX(pom.doc_date) AS max_doc_date
FROM classified c
LEFT JOIN purchase.purchase_order_main pom
    ON pom.id = c.POAmendmentNo
WHERE c.mismatch_type IN ('item_mismatch','make_mismatch')
GROUP BY c.mismatch_type
ORDER BY c.mismatch_type;




-- Problem Po Diagonostic
WITH missing AS
(
    SELECT
        sched.POAmendmentISDetailNo,
        sched.POAmendmentNo,
        sched.ItemNo,
        COALESCE(sched.MakeNo,0) AS MakeNo
    FROM sqlserver_fdw.poamendmentitemscheduledetail sched

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM purchase.purchase_order_item_detail poid
        WHERE poid.po_id = sched.POAmendmentNo
          AND poid.item_id = sched.ItemNo
          AND COALESCE(poid.make_id,0) = COALESCE(sched.MakeNo,0)
    )
)
SELECT
    po_id,
    COUNT(*) AS po_item_count
FROM
(
    SELECT DISTINCT
        m.POAmendmentNo AS po_id,
        poid.id
    FROM missing m
    INNER JOIN purchase.purchase_order_item_detail poid
        ON poid.po_id = m.POAmendmentNo
) x
GROUP BY po_id
ORDER BY po_item_count ASC;



WITH sched AS
(
    SELECT
        POAmendmentISDetailNo,
        POAmendmentNo,
        ItemNo,
        COALESCE(MakeNo,0) AS MakeNo
    FROM sqlserver_fdw.poamendmentitemscheduledetail
),
missing AS
(
    SELECT *
    FROM sched s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM purchase.purchase_order_item_detail p
        WHERE p.po_id = s.POAmendmentNo
          AND p.item_id = s.ItemNo
          AND COALESCE(p.make_id,0) = s.MakeNo
    )
),
po_item_counts AS
(
    SELECT
        po_id,
        COUNT(*) AS item_count
    FROM purchase.purchase_order_item_detail
    GROUP BY po_id
)
SELECT
    CASE
        WHEN pic.item_count = 1 THEN 'recoverable_single_item_po'
        ELSE 'ambiguous_multi_item_po'
    END AS category,
    COUNT(*) AS schedule_rows
FROM missing m
INNER JOIN po_item_counts pic
    ON pic.po_id = m.POAmendmentNo
GROUP BY 1;





select count(*) from purchase.purchase_order_pr_item_detail popid 











WITH make_mismatch AS
(
    SELECT
        sched.POAmendmentISDetailNo,
        sched.POAmendmentNo,
        sched.ItemNo,
        COALESCE(sched.MakeNo,0) AS schedule_make_no,
        migration.parse_sqlserver_datetime(sched.ScheduleDate)::date AS schedule_date,
        sched.ScheduleQty
    FROM sqlserver_fdw.poamendmentitemscheduledetail sched
    WHERE EXISTS
    (
        SELECT 1
        FROM purchase.purchase_order_item_detail p1
        WHERE p1.po_id = sched.POAmendmentNo
          AND p1.item_id = sched.ItemNo
    )
    AND NOT EXISTS
    (
        SELECT 1
        FROM purchase.purchase_order_item_detail p2
        WHERE p2.po_id = sched.POAmendmentNo
          AND p2.item_id = sched.ItemNo
          AND COALESCE(p2.make_id,0) = COALESCE(sched.MakeNo,0)
    )
)
SELECT
    mm.POAmendmentISDetailNo,
    mm.POAmendmentNo AS po_id,
    pom.doc_date,
    mm.ItemNo AS schedule_item_id,
    mm.schedule_make_no,
    mm.ScheduleQty,
    mm.schedule_date,
    poid.id AS po_item_detail_id,
    poid.item_id AS po_item_id,
    COALESCE(poid.make_id,0) AS po_make_id,
    poid.qty AS po_qty
FROM make_mismatch mm
INNER JOIN purchase.purchase_order_main pom
    ON pom.id = mm.POAmendmentNo
INNER JOIN purchase.purchase_order_item_detail poid
    ON poid.po_id = mm.POAmendmentNo
   AND poid.item_id = mm.ItemNo
ORDER BY
    mm.POAmendmentNo,
    mm.ItemNo;


SELECT setval(
    pg_get_serial_sequence(
        'purchase.purchase_order_schedule_detail',
        'id'
    ),
    (
        SELECT MAX(id)
        FROM purchase.purchase_order_schedule_detail
    )
);

select id from purchase.purchase_order_schedule_detail posd 
order by id desc


