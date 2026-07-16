INSERT INTO masterdata.doc_type_master
(
    code,
    doc_type_alias,
    doc_type_name,
    form_id,
    status_id,
    created_date,
    modified_date,
    created_by_id
)
VALUES
(
    'DT0001',
    'PRG',
    'General Purchase Request',
    6,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0002',
    'CSG',
    'General Comparative Statement',
    8,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0003',
    'POG',
    'General Purchase Order',
    10,
    1,
    Now(),
    Now(),
    1
),
(
    'DT0004',
    'RQG',
    'General Request For Quotation',
    7,
    1,
    Now(),
    Now(),
    1
);
