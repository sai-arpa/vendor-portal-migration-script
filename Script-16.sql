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
(
    'DS0000001',
    5,
    'MMPR{{N}}',
    4, -- continuous
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
(
    'DS0000002',
    5,
    '{{FY2}}{{N}}',
    3, -- yearly
    (
        SELECT COALESCE(MAX(SUBSTRING(doc_no_yearly FROM 5)::INT), 0) + 1
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
(
    'DS0000003',
    6,
    '{{N}}',
    4, -- continuos
    (
        SELECT COALESCE(MAX(doc_no_yearly::INT), 0) + 1
        FROM purchase.pur_rfq_main
    ),
    (
        SELECT created_date
        FROM purchase.pur_rfq_main
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
VALUES
(1,6),
(2,10),
(3,7);

INSERT INTO masterdata.document_series_doc_type_detail
(
document_series_id,
document_type_id,
status_id
) VALUES
(1,(select id from masterdata.doc_type_master where form_id = 6),1),
(2,(select id from masterdata.doc_type_master where form_id = 10),1),
(3,(select id from masterdata.doc_type_master where form_id = 7),1);

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
) ds;

INSERT INTO masterdata.document_series_next_number 
(
document_series_id,
period,
next_number
) VALUES 
(1,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 1)),
(2,'2026',(select number_starts_from from masterdata.document_series_master where id = 2)),
(3,'GLOBAL',(select number_starts_from from masterdata.document_series_master where id = 3));



select * from masterdata.approval_setup_master asm where asm.form_id =6




select * from utility.approval_process_main apm where apm.status_id=19

update utility.approval_process_main
set status_id=19
where id in (
select distinct apm.approval_process_id  from utility.approval_process_detail apm where apm.status_id=19
)


select qm.id, qm.main_quotation_id, qm.revision_no, qm.is_current  from purchase.quotation_main qm 


