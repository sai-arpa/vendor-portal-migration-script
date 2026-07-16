INSERT INTO masterdata.doc_type_company_detail
(
    doc_type_id,
    company_id,
    division_id
)
SELECT
    dt.id,
    cm.id,
    dm.id
FROM masterdata.doc_type_master dt
CROSS JOIN masterdata.company_master cm
CROSS JOIN masterdata.division_master dm;