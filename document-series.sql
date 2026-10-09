INSERT INTO masterdata.document_series_master
(
    code,
    padding,
    pattern,
    frequency_id,
    number_starts_from,
    effective_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
VALUES
(   ---- Specifically for PR
    'DS0000001',
    5,
    'MMPR{{N}}',
    3, -- continuous
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 5)::INT), 0) + 1
        FROM inventory.purchase_request_main
        WHERE doc_no_yearly ~ '^MMPR[0-9]+$'
    ),
    (
        SELECT created_date
        FROM inventory.purchase_request_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(    ---- Specifically for PO
    'DS0000002',
    5,
    '{{FY2}}Y{{N}}',
    3, -- yearly
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 4)::INT), 0) + 1
        FROM purchase.purchase_order_main
        WHERE doc_no_yearly ~ '^26Y[0-9]+$'
    ),
    (
        SELECT created_date
        FROM purchase.purchase_order_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for RFQ
    'DS0000003',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.pur_rfq_main
        WHERE ref_doc_type_id <> 9
    ),
    (
        SELECT created_date
        FROM purchase.pur_rfq_main
        WHERE ref_doc_type_id <> 9
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for CS
    'DS0000004',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.cs_main
    ),
    (
        SELECT created_date
        FROM purchase.cs_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for PR Cancellation
    'DS0000005',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM utility.purchase_request_cancellation_main
    ),
    (
        SELECT created_date
        FROM utility.purchase_request_cancellation_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(   ---- Specifically for PO Cancellation
    'DS0000006',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.po_cancellation_main
    ),
    (
        SELECT created_date
        FROM purchase.po_cancellation_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
),
(    -----Specifically for Auction
    'DS0000007',
    5,
    'AU{{N}}',
    4, -- continuous
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 3)::INT),0) + 1
        FROM purchase.auction_main
        WHERE doc_no_yearly ~ '^AU[0-9]+$'
    ),
    (
        SELECT created_date
        FROM purchase.auction_main
        ORDER BY created_date ASC
        LIMIT 1
    ),
    1,
    NOW(),
    1,
    NOW(),
    1,
    NULL
);


INSERT INTO masterdata.document_series_form_detail
(
document_series_id,
form_id
)
values
(1,6),
(2,10),
(3,7),
(4,8),
(5,97),
(6,42),
(7,106);

INSERT INTO masterdata.document_series_doc_type_detail
(
document_series_id,
document_type_id,
status_id
) VALUES
(1,(select id from masterdata.doc_type_master where form_id in (6)),1),
(2,(select id from masterdata.doc_type_master where form_id in (10)),1),
(3,(select id from masterdata.doc_type_master where form_id in (7) limit 1),1),  ---confirm what is return before running
(4,(select id from masterdata.doc_type_master where form_id in (8)),1),
(5,(select id from masterdata.doc_type_master where form_id in (97)),1),
(6,(select id from masterdata.doc_type_master where form_id in (42)),1),
(7,(select id from masterdata.doc_type_master where form_id in (106)),1);

INSERT INTO masterdata.document_series_company_detail
(
    document_series_id,
    company_id,
    status_id
)
SELECT
    ds.document_series_id,
    cm.id,
    1 AS status_id
FROM
    masterdata.company_master cm
CROSS JOIN
(
    SELECT 1 AS document_series_id
    UNION ALL
    SELECT 2
    UNION ALL
    SELECT 3
    UNION ALL
    SELECT 4
    UNION ALL
    SELECT 5
    UNION ALL
    SELECT 6
    UNION ALL
    SELECT 7
) ds; 

INSERT INTO masterdata.document_series_division_detail
(
    document_series_id,
    division_id,
    status_id
)
SELECT
    ds.document_series_id,
    dm.id,
    1 AS status_id
FROM
    masterdata.division_master dm
CROSS JOIN
(
    SELECT 1 AS document_series_id
    UNION ALL
    SELECT 2
    UNION ALL
    SELECT 3
    UNION ALL
    SELECT 4
    UNION ALL
    SELECT 5
    UNION ALL
    SELECT 6
    UNION ALL
    SELECT 7
) ds;

INSERT INTO masterdata.document_series_next_number 
(
document_series_id,
period,
next_number
) VALUES 
(1,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 1)),
(2,'2026',(select number_starts_from from masterdata.document_series_master where id = 2)),
(3,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 3)),
(4,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 4)),
(5,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 5)),
(6,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 6)),
(7,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 7));





--------------------------------------------------------------------------------------------------------------------------------------------------
---Doc no Yearly analysis

--pr
select doc_no_yearly, created_date  from inventory.purchase_request_main
WHERE doc_no_yearly !~ '^[A-Z]{2}[0-9]{2}Y-[0-9]{5}$'
and doc_no_yearly ~ '^MMPR[0-9]+$'
order by doc_no_yearly desc


--po
select doc_no_yearly, created_date  from purchase.purchase_order_main pom 
where pom.doc_no_yearly !~ '^[0-9]{6}$'
and pom.doc_no_yearly ~ '^[0-9]{2}Y[0-9]{5}$'
order by doc_no_yearly desc

--rfq
select doc_no_yearly, created_date  from purchase.pur_rfq_main pom
where pom.doc_no_yearly ~ '^[0-9]{6}$'
order by doc_no_yearly desc

--cs
select doc_no_yearly, created_date  from purchase.cs_main pom
where pom.doc_no_yearly ~ '^[0-9]{6}$'
order by doc_no_yearly desc


-- pr cancellation
select doc_no_yearly, created_date  from utility.purchase_request_cancellation_main pom
order by doc_no_yearly desc


-- po cancellation
select doc_no_yearly, created_date  from utility.purchase_request_cancellation_main pom
order by doc_no_yearly desc
