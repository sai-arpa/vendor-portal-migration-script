INSERT INTO config.form_detail
(id, form_id, is_multilevel_approval_applicable, is_document_attachment_applicable, is_custom_search_col_def_applicable, is_net_amount_in_approval, is_audit_applicable, is_delete_reason_applicable, inactive)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 6, true, true, false, false, true, true, false),
    (2, 7, false, true, false, false, true, false, false),
    (3, 10, true, true, false, true, true, false, false),
    (4, 8, false, false, false, false, false, true, false)
