CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.poamendmentitemscheduledetail
(
    POAmendmentISDetailNo INTEGER,
    POAmendmentNo INTEGER,
    POItemLineNo SMALLINT,
    ItemNo INTEGER,
    MakeNo SMALLINT,
    ScheduleDate TEXT,
    ScheduleQty NUMERIC(10,3)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'POAmendmentItemScheduleDetail'
);


-- optimized

WITH merged_schedule AS
(
    SELECT
        MIN(sched.POAmendmentISDetailNo) AS po_schedule_id,
        sched.POAmendmentNo AS po_id,
        sched.ItemNo AS item_id,
        COALESCE(sched.MakeNo,0) AS make_id,
        MAX(
            migration.parse_sqlserver_datetime(sched.ScheduleDate)::date
        ) AS schedule_date,
        SUM(COALESCE(sched.ScheduleQty,0)) AS total_qty
    FROM sqlserver_fdw.poamendmentitemscheduledetail sched
    GROUP BY
        sched.POAmendmentNo,
        sched.ItemNo,
        COALESCE(sched.MakeNo,0)
),
po_schedule_match AS
(
    SELECT
        ms.po_schedule_id,
        ms.po_id,
        ms.item_id,
        ms.make_id,
        ms.schedule_date,
        ms.total_qty,
        poid.id AS po_item_detail_id
    FROM merged_schedule ms
    LEFT JOIN purchase.purchase_order_item_detail poid
        ON poid.po_id = ms.po_id
       AND poid.item_id = ms.item_id
       AND COALESCE(poid.make_id,0) = ms.make_id
),
exact_items AS
(
    SELECT DISTINCT
        psm.po_id,
        psm.item_id,
        psm.make_id
    FROM po_schedule_match psm
    WHERE psm.po_item_detail_id IS NOT NULL
),
exact_rows AS
(
    SELECT
        poprid.po_id,
        poprid.po_item_detail_id,
        poprid.pr_item_detail_id,
        poprid.po_qty AS qty,
        psm.schedule_date
    FROM po_schedule_match psm
    INNER JOIN purchase.purchase_order_pr_item_detail poprid
        ON poprid.po_item_detail_id = psm.po_item_detail_id
    WHERE psm.po_item_detail_id IS NOT NULL
),
fallback_schedule AS
(
    SELECT
        psm.po_id,
        psm.item_id,
        psm.make_id,
        MAX(psm.schedule_date) AS max_schedule_date
    FROM po_schedule_match psm
    WHERE psm.po_item_detail_id IS NULL
    GROUP BY
        psm.po_id,
        psm.item_id,
        psm.make_id
),
fallback_rows AS
(
    SELECT
        poprid.po_id,
        poprid.po_item_detail_id,
        poprid.pr_item_detail_id,
        poprid.po_qty AS qty,
        fs.max_schedule_date AS schedule_date
    FROM fallback_schedule fs
    INNER JOIN purchase.purchase_order_pr_item_detail poprid
        ON poprid.po_id = fs.po_id
       AND poprid.item_id = fs.item_id
       AND COALESCE(poprid.po_make_id,0) = fs.make_id
    LEFT JOIN exact_items ei
        ON ei.po_id = poprid.po_id
       AND ei.item_id = poprid.item_id
       AND ei.make_id = COALESCE(poprid.po_make_id,0)
    WHERE ei.item_id IS NULL
)
INSERT INTO purchase.purchase_order_schedule_detail
(
    id,
    po_id,
    po_item_detail_id,
    pr_item_detail_id,
    qty,
    schedule_date
)
overriding system value
SELECT
    ROW_NUMBER() OVER () AS id,
    x.po_id,
    x.po_item_detail_id,
    x.pr_item_detail_id,
    x.qty,
    x.schedule_date
FROM
(
    SELECT
        po_id,
        po_item_detail_id,
        pr_item_detail_id,
        qty,
        schedule_date
    FROM exact_rows
    UNION ALL
    SELECT
        po_id,
        po_item_detail_id,
        pr_item_detail_id,
        qty,
        schedule_date
    FROM fallback_rows
) x;

--- MANUAL 5 ROW INSERT

INSERT INTO purchase.purchase_order_schedule_detail
(
    id,
    po_id,
    po_item_detail_id,
    pr_item_detail_id,
    qty,
    schedule_date
)
overriding system value
SELECT
    nextval(
        pg_get_serial_sequence(
            'purchase.purchase_order_schedule_detail',
            'id'
        )
    ) AS id,
    poprid.po_id,
    poprid.po_item_detail_id,
    poprid.pr_item_detail_id,
    poprid.po_qty,
    src.schedule_date
FROM
(
    VALUES
    (1604, 8830, DATE '2018-06-30'),
    (1715, 1542, DATE '2018-06-29'),
    (1715, 1623, DATE '2018-06-29'),
    (1416, 22883, DATE '2018-06-15'),
    (646, 14715, DATE '2018-05-16')
) AS src(po_id, item_id, schedule_date)
INNER JOIN purchase.purchase_order_pr_item_detail poprid
    ON poprid.po_id = src.po_id
   AND poprid.item_id = src.item_id;

--MANUAL 2 ROWS

WITH po_max_schedule_date AS
(
    SELECT
        sched.POAmendmentNo AS po_id,
        MAX(
            migration.parse_sqlserver_datetime(sched.ScheduleDate)::date
        ) AS max_schedule_date
    FROM sqlserver_fdw.poamendmentitemscheduledetail sched
    GROUP BY sched.POAmendmentNo
)
INSERT INTO purchase.purchase_order_schedule_detail
(
    id,
    po_id,
    po_item_detail_id,
    pr_item_detail_id,
    qty,
    schedule_date
)
overriding system value
SELECT
    nextval(
        pg_get_serial_sequence(
            'purchase.purchase_order_schedule_detail',
            'id'
        )
    ) AS id,
    poprid.po_id,
    poprid.po_item_detail_id,
    poprid.pr_item_detail_id,
    poprid.po_qty,
    pmsd.max_schedule_date
FROM purchase.purchase_order_pr_item_detail poprid
INNER JOIN po_max_schedule_date pmsd
    ON pmsd.po_id = poprid.po_id
WHERE
(
    poprid.po_id = 3347
    AND poprid.item_id = 46366
    AND COALESCE(poprid.po_make_id,0) = 736
)
OR
(
    poprid.po_id = 10513
    AND poprid.item_id = 47331
    AND COALESCE(poprid.po_make_id,0) = 156
);





---- Verification For Last 7 po pr rows

WITH merged_schedule AS
(
    SELECT
        sched.POAmendmentNo AS po_id,
        sched.ItemNo AS item_id,
        COALESCE(sched.MakeNo,0) AS make_id
    FROM sqlserver_fdw.poamendmentitemscheduledetail sched
    GROUP BY
        sched.POAmendmentNo,
        sched.ItemNo,
        COALESCE(sched.MakeNo,0)
),
matched_rows AS
(
    SELECT DISTINCT
        poprid.id
    FROM merged_schedule ms
    INNER JOIN purchase.purchase_order_item_detail poid
        ON poid.po_id = ms.po_id
       AND poid.item_id = ms.item_id
       AND COALESCE(poid.make_id,0) = ms.make_id
    INNER JOIN purchase.purchase_order_pr_item_detail poprid
        ON poprid.po_item_detail_id = poid.id
    UNION
    SELECT DISTINCT
        poprid.id
    FROM merged_schedule ms
    INNER JOIN purchase.purchase_order_pr_item_detail poprid
        ON poprid.po_id = ms.po_id
       AND poprid.item_id = ms.item_id
       AND COALESCE(poprid.po_make_id,0) = ms.make_id
)
SELECT
    poprid.*
FROM purchase.purchase_order_pr_item_detail poprid
LEFT JOIN matched_rows mr
    ON mr.id = poprid.id
WHERE mr.id IS NULL;
