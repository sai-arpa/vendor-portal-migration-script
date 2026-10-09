INSERT INTO masterdata.doc_type_master
(code, doc_type_alias, doc_type_name, form_id, created_by_id, created_date, modified_by_id, modified_date, status_id, status_remarks)
OVERRIDING SYSTEM VALUE
VALUES
('DT0001','PRG','Purchase Request General',6,1,'2026-08-20 05:30:00+05:30',1,'2026-08-20 05:30:00+05:30',1,NULL),
('DT0002','RFG','Request For Quotation General',7,1,'2026-08-20 05:30:00+05:30',NULL,'2026-08-20 05:30:00+05:30',1,NULL),
('DT0003','CSG','Comparative Statement General',8,1,'2026-08-20 05:30:00+05:30',NULL,'2026-08-20 05:30:00+05:30',1,NULL),
('DT0004','POG','Purchase Order General',10,1,'2026-08-20 05:30:00+05:30',1,'2026-08-20 05:30:00+05:30',1,NULL)
ON CONFLICT (code)
DO UPDATE SET
doc_type_alias = EXCLUDED.doc_type_alias,
doc_type_name = EXCLUDED.doc_type_name,
form_id = EXCLUDED.form_id,
modified_by_id = EXCLUDED.modified_by_id,
modified_date = EXCLUDED.modified_date,
status_id = EXCLUDED.status_id,
status_remarks = EXCLUDED.status_remarks;
