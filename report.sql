CREATE UNIQUE INDEX IF NOT EXISTS ix_report_columns_report_id_name
    ON globaldata.report_columns (report_id, name);

CREATE UNIQUE INDEX IF NOT EXISTS ix_report_filter_fields_report_id_name
    ON globaldata.report_filter_fields (report_id, name);

INSERT INTO globaldata.report_main (
    id,
    report_code,
    report_category,
    report_name,
    report_path,
    inactive,
    is_custom_report,
    is_pagination_apply,
    sp_name
)
VALUES
    (1,  'INDTR',    'Register',   'MIS Indent Register',              NULL, FALSE, FALSE, TRUE,  'inventory.mis_func_indent_register'),
    (2,  'ITMAGE',   'Register',   'MIS Indent Item Ageing',           NULL, FALSE, FALSE, FALSE,  'inventory.mis_func_indent_ageing'),
    (3,  'POAR',     'Register',   'MIS PO Amendment Register',        NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_po_amendment_register'),
    (4,  'IGRPPRC',  'Custom',     'Item Group Wise Procurement',      NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_item_group_wise_procurement'),
    (5,  'ITMPSM',   'Custom',     'Item Wise Purchase Summary',       NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_item_wise_purchase_summary'),
    (6,  'MISNV',    'Register',   'MIS New Vendors',                  NULL, TRUE, FALSE, TRUE,  'masterdata.mis_func_new_vendors'),
    (7,  'PORJH',    'Register',   'MIS PO Rejection History',         NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_po_rejection_history_register'),
    (8,  'POSUM',    'Register',   'MIS PO Summary',                   NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_po_summary'),
    (9,  'PRR',      'Register',   'MIS Purchase Register',            NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_purchase_register'),
    (10, 'VNDLST',   'Register',   'MIS Vendor List',                  NULL, FALSE, FALSE, TRUE,  'masterdata.mis_func_vendor_list'),
    (11, 'VNDPRC',   'Custom',     'Vendor Wise Procurement',          NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_vendor_wise_procurement'),
    (12, 'PSVND',    'Register',   'MIS Passive Vendors',              NULL, FALSE, FALSE, TRUE,  'masterdata.mis_func_passive_vendors'),
    (13, 'RFQTPO',   'Register',   'MIS RFQ To PO',                    NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_rfq_to_po_progress_flow'),
    (14, 'UPCW',     'Custom',     'User Performance Company Wise',    NULL, FALSE, TRUE,  FALSE, 'security.mis_func_user_performance_company_wise'),
    (15, 'USRPF',    'Custom',     'User Performance',                 NULL, FALSE, TRUE,  FALSE, 'security.mis_func_user_performance'),
    (16, 'POTMLN',   'Register',   'MIS PO Timeline',                  NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_po_timeline'),
    (17, 'AUTHREV',  'Register',   'MIS Authorization Review',         NULL, TRUE, TRUE,  TRUE,  'purchase.mis_func_po_authorization_review'),
    (18, 'POL2',     'Register',   'MIS PO L2 Report',                 NULL, FALSE, FALSE, TRUE,  'purchase.mis_func_po_l2_report'),
    (19, 'IGWPURSM', 'Custom',     'Item Group Wise Purchase Summary', NULL, FALSE, FALSE, FALSE, 'purchase.mis_func_item_group_wise_purchase_summary'),
    (20, 'ITMPURMW', 'Drilldown',  'Item Purchase Summary Month Wise', NULL, FALSE, FALSE, FALSE, 'purchase.mis_func_item_purchase_summary_month_wise'),
    (21, 'VNDSUMMW', 'Drilldown',  'Vendor Summary Month Wise',        NULL, FALSE, FALSE, FALSE, 'masterdata.mis_func_vendor_summary_month_wise'),
    (22, 'IGPURVW',  'Custom',     'Item Group Purchase Summary Vendor Wise', NULL, FALSE, FALSE, FALSE, 'purchase.mis_func_item_group_purchase_summary_vendor_wise'),
    (23, 'IGRPDTL',  'Drilldown',  'Item Group Wise Detail',           NULL, FALSE, FALSE, FALSE, 'purchase.mis_func_item_group_wise_detail'),
    (24, 'INDAGDET', 'Drilldown',  'Indent Item Ageing Detail',        NULL, FALSE, TRUE, FALSE, 'inventory.func_indent_item_ageing_detail')

ON CONFLICT (id) DO UPDATE SET
    report_code = EXCLUDED.report_code,
    report_category = EXCLUDED.report_category,
    report_name = EXCLUDED.report_name,
    report_path = EXCLUDED.report_path,
    inactive = EXCLUDED.inactive,
    is_custom_report = EXCLUDED.is_custom_report,
    is_pagination_apply = EXCLUDED.is_pagination_apply,
    sp_name = EXCLUDED.sp_name;


DELETE FROM globaldata.report_columns
WHERE Id IN (245, 247, 254,386, 278);

DELETE FROM globaldata.report_filter_fields
WHERE Id IN (37, 44, 45, 97, 98);


INSERT INTO globaldata.report_columns (
    id,
    report_id,
    name,
    caption,
    field_type,
    seq_no,
    is_visible,
    redirection_link,
    format_json
)
VALUES
    -- Report 1 (inventory.mis_func_indent_register)

    -- Organization
    (1,   1, 'CompanyName', 'Company', 'TEXT', 1, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (2,   1, 'DivisionName', 'Division', 'TEXT', 2, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (3,   1, 'DepartmentName', 'Department', 'TEXT', 3, TRUE, NULL, '{ "type": "text" }'::jsonb),

    -- PR Details
    (4,   1, 'PrNo', 'PR No.', 'TEXT', 4, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (5,   1, 'PrDocDate', 'PR Date', 'TEXT', 5, TRUE, NULL, '{ "type": "date" }'::jsonb),
    (440, 1, 'RefDocNo', 'Ref Doc No.', 'TEXT', 6, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (441, 1, 'RefDocDate', 'Ref Doc Date', 'TEXT', 7, TRUE, NULL, '{ "type": "date" }'::jsonb),
    (439, 1, 'RequestedBy', 'Requested By', 'TEXT', 8, TRUE, NULL, '{ "type": "text" }'::jsonb),

    -- Item Details
    (8,   1, 'ItemName', 'Item', 'TEXT', 9, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (9,   1, 'TechSpecification', 'Tech Specification', 'TEXT', 10, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (10,  1, 'MakeName', 'Make', 'TEXT', 11, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (11,  1, 'CostCenterName', 'Cost Center', 'TEXT', 12, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (12,  1, 'Unit', 'Unit', 'TEXT', 13, TRUE, NULL, '{ "type": "text" }'::jsonb),

    -- Quantity Details
    (20,  1, 'PrQty', 'PR Qty.', 'NUMBER', 14, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (21,  1, 'PrCancelQty', 'PR Cancel Qty.', 'NUMBER', 15, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (23,  1, 'PrBalanceQty', 'Balance Qty.', 'NUMBER', 16, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),

    -- Due & Status
    (13,  1, 'DueDate', 'Due Date', 'TEXT', 17, TRUE, NULL, '{ "type": "date" }'::jsonb),
    (15,  1, 'StatusName', 'Status', 'TEXT', 18, TRUE, NULL, '{ "type": "text" }'::jsonb),

    -- Procurement Flow
    (16,  1, 'RfqDetails', 'RFQ Details', 'TEXT', 19, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (17,  1, 'RfqQty', 'RFQ Qty.', 'NUMBER', 20, TRUE, NULL, '{ "type": "number" }'::jsonb),
    (438, 1, 'CsDetail', 'CS Details', 'TEXT', 21, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (18,  1, 'PoDetails', 'PO Details', 'TEXT', 22, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (19,  1, 'PoQuantity', 'PO Qty.', 'NUMBER', 23, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (22,  1, 'PoReleaseQty', 'PO Release Qty.', 'NUMBER', 24, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),

    -- Closing Information
    (24,  1, 'Remark', 'Remark', 'TEXT', 25, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (25,  1, 'ExpireIn', 'Expire In (Days)', 'NUMBER', 26, TRUE, NULL, '{ "type": "number", "alignment": "right" }'::jsonb),

    -- Hidden Fields
    (435, 1, 'CompanyId', 'Company Id', 'NUMBER', 27, FALSE, NULL, '{ "type": "number" }'::jsonb),
    (436, 1, 'DivisionId', 'Division Id', 'NUMBER', 28, FALSE, NULL, '{ "type": "number" }'::jsonb),
    (7,   1, 'ItemId', 'Item Id', 'NUMBER', 29, FALSE, NULL, '{ "type": "number" }'::jsonb),
    (6,   1, 'PrItemLineNo', 'Line No', 'NUMBER', 30, FALSE, NULL, '{ "type": "number", "alignment": "right" }'::jsonb),
    (14,  1, 'StatusId', 'Status Id', 'NUMBER', 31, FALSE, NULL, '{ "type": "number" }'::jsonb),


    -- Report 2 (inventory.mis_func_indent_ageing)

    -- Organization
    (26, 2, 'Company', 'Company', 'TEXT', 1, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (27, 2, 'Division', 'Division', 'TEXT', 2, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (473, 2, 'DrilldownReport', 'DrilldownReport', 'TEXT', 29, FALSE, NULL, '{ "type": "text" }'::jsonb),
    -- Overall Statistics
    (28, 2, 'NumOfIndentLineItems', 'No. Of Indent Line Items', 'NUMBER', 3, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),

    -- Status Summary
    (32, 2, 'NumOfPendingIndent', 'No. of Pending Indent', 'NUMBER', 4, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (31, 2, 'NumOfInProgressIndent', 'No. Of In Progress Indent', 'NUMBER', 5, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (29, 2, 'NumOfPOCompletedIndent', 'No. Of PO Completed Indent', 'NUMBER', 6, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (30, 2, 'Cancelled/ ExpiredIndent', 'Cancelled/ Expired Indent', 'NUMBER', 7, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),

    -- Ageing Buckets
    (33, 2, 'NumOfAgeing0-7', '0-7 Days', 'NUMBER', 8, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (34, 2, 'NumOfAgeing8-15', '8-15 Days', 'NUMBER', 9, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (35, 2, 'NumOfAgeing16-30', '16-30 Days', 'NUMBER', 10, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (36, 2, 'NumOfAgeing31-60', '31-60 Days', 'NUMBER', 11, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (37, 2, 'NumOfAgeing61-90', '61-90 Days', 'NUMBER', 12, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (38, 2, 'NumOfAgeing91-120', '91-120 Days', 'NUMBER', 13, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (39, 2, 'NumOfAgeing121-180', '121-180 Days', 'NUMBER', 14, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),
    (40, 2, 'NumOfAgeing>181', '>181 Days', 'NUMBER', 15, TRUE, NULL, '{ "type": "number", "alignment": "right", "isUsedForRedirection": true }'::jsonb),

    -- Drilldown parameter columns (hidden)
    (461, 2, 'NumOfIndentLineItems^Params', 'NumOfIndentLineItemsParams', 'OBJECT', 16, FALSE, NULL, '{}'::jsonb),
    (462, 2, 'NumOfPendingIndent^Params', 'NumOfPendingIndentParams', 'OBJECT', 17, FALSE, NULL, '{}'::jsonb),
    (463, 2, 'NumOfInProgressIndent^Params', 'NumOfInProgressIndentParams', 'OBJECT', 18, FALSE, NULL, '{}'::jsonb),
    (464, 2, 'NumOfPOCompletedIndent^Params', 'NumOfPOCompletedIndentParams', 'OBJECT', 19, FALSE, NULL, '{}'::jsonb),
    (465, 2, 'Cancelled/ ExpiredIndent^Params', 'Cancelled/ ExpiredIndentParams', 'OBJECT', 20, FALSE, NULL, '{}'::jsonb),
    (466, 2, 'NumOfAgeing0-7^Params', 'NumOfAgeing0-7Params', 'OBJECT', 21, FALSE, NULL, '{}'::jsonb),
    (467, 2, 'NumOfAgeing8-15^Params', 'NumOfAgeing8-15Params', 'OBJECT', 22, FALSE, NULL, '{}'::jsonb),
    (468, 2, 'NumOfAgeing16-30^Params', 'NumOfAgeing16-30Params', 'OBJECT', 23, FALSE, NULL, '{}'::jsonb),
    (469, 2, 'NumOfAgeing31-60^Params', 'NumOfAgeing31-60Params', 'OBJECT', 24, FALSE, NULL, '{}'::jsonb),
    (470, 2, 'NumOfAgeing61-90^Params', 'NumOfAgeing61-90Params', 'OBJECT', 25, FALSE, NULL, '{}'::jsonb),
    (471, 2, 'NumOfAgeing91-120^Params', 'NumOfAgeing91-120Params', 'OBJECT', 26, FALSE, NULL, '{}'::jsonb),
    (472, 2, 'NumOfAgeing121-180^Params', 'NumOfAgeing121-180Params', 'OBJECT', 27, FALSE, NULL, '{}'::jsonb),
    (473, 2, 'NumOfAgeing>181^Params', 'NumOfAgeing>181Params', 'OBJECT', 28, FALSE, NULL, '{}'::jsonb),
    
    -- Report 3 (purchase.mis_func_po_amendment_register)

    (45, 3, 'Company', 'Company', 'TEXT', 1, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (442, 3, 'CompanyId', 'Company Id', 'NUMBER', 2, FALSE, NULL, '{ "type": "number" }'::jsonb),
    (46, 3, 'Division', 'Division', 'TEXT', 3, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (434, 3, 'DivisionId', 'Division Id', 'NUMBER', 4, FALSE, NULL, '{ "type": "number" }'::jsonb),
    (47, 3, 'DocNoYearly', 'PO No.', 'TEXT', 5, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (48, 3, 'DocDate', 'PO Date', 'TEXT', 6, TRUE, NULL, '{ "type": "date" }'::jsonb),
    (49, 3, 'AmendmentNo', 'Amendment No', 'NUMBER', 7, TRUE, NULL, '{ "type": "number" }'::jsonb),
    (50, 3, 'DocumentType', 'Document Type', 'TEXT', 8, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (51, 3, 'Department', 'Department', 'TEXT', 9, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (52, 3, 'VendorName', 'Vendor', 'TEXT', 10, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (53, 3, 'Location', 'Location', 'TEXT', 11, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (54, 3, 'RefDocType', 'Ref Document Type', 'TEXT', 12, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (55, 3, 'RefDocDetails', 'Ref Document Details', 'TEXT', 13, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (56, 3, 'ContactPersonName', 'Contact Person', 'TEXT', 14, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (57, 3, 'ItemName', 'Item', 'TEXT', 15, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (58, 3, 'Make', 'Make', 'TEXT', 16, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (59, 3, 'TechSpec', 'Tech Specification', 'TEXT', 17, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (60, 3, 'Unit', 'Unit', 'TEXT', 18, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (61, 3, 'POA Quantity', 'POA Quantity', 'NUMBER', 19, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (62, 3, 'ScheduleDate', 'Schedule Date', 'TEXT', 20, TRUE, NULL, '{ "type": "date" }'::jsonb),
    (63, 3, 'PoItemStatus', 'PO Item Status', 'TEXT', 21, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (64, 3, 'CostCenter', 'Cost Center', 'TEXT', 22, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (65, 3, 'Rate', 'Rate', 'NUMBER', 23, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (66, 3, 'Discount', 'Discount', 'NUMBER', 24, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (67, 3, 'BasicValue', 'Basic Value', 'NUMBER', 25, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (68, 3, 'Authorized', 'Authorized', 'TEXT', 26, TRUE, NULL, '{ "type": "text" }'::jsonb),
    (69, 3, 'CST', 'CST', 'NUMBER', 27, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (70, 3, 'CGST', 'CGST', 'NUMBER', 28, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (71, 3, 'SGST', 'SGST', 'NUMBER', 29, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (72, 3, 'IGST', 'IGST', 'NUMBER', 30, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (73, 3, 'OtherCharges', 'Other Charges', 'NUMBER', 31, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (74, 3, 'AmendmentReason', 'Amendment Reason', 'TEXT', 32, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (75, 3, 'Status', 'Status', 'TEXT', 33, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (76, 3, 'CreatedBy', 'Created By', 'TEXT', 34, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (77, 3, 'CreatedDate', 'Created Date', 'TEXT', 35, TRUE, NULL, '{ "type": "date"}'::jsonb),
    (78, 3, 'AuthorizedBy', 'Authorized By', 'TEXT', 36, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (79, 3, 'AuthorizedDate', 'Authorized Date', 'TEXT', 37, TRUE, NULL, '{ "type": "date"}'::jsonb),

    -- Report 4 (purchase.mis_func_item_group_wise_procurement)

    (80, 4, 'ItemGroupId', 'Item Group Id', 'NUMBER', 1, FALSE, NULL, '{ "type": "number"}'::jsonb),
    (81, 4, 'ItemGroupName', 'Item Group Name', 'TEXT', 2, TRUE, NULL, '{ "type": "text", "isUsedForRedirection": true}'::jsonb),
    (82, 4, 'TotalPoAmount', 'Total PO Amount', 'NUMBER', 3, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (83, 4, 'POCount', 'PO Count', 'NUMBER', 4, TRUE, NULL, '{ "type": "number", "alignment": "right" }'::jsonb),
    (84, 4, 'TotalVendorCount', 'Total Vendor Count', 'NUMBER', 5, TRUE, NULL, '{ "type": "number", "alignment": "right" }'::jsonb),
    (85, 4, 'Vendor1Id', 'Vendor 1 Id', 'NUMBER', 6, FALSE, NULL, '{ "type": "number"}'::jsonb),
    (86, 4, 'Vendor1Name', 'Vendor 1 Name', 'TEXT', 7, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (87, 4, 'Vendor1PoAmount', 'Vendor 1 PO Amount', 'NUMBER', 8, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (88, 4, 'Vendor1PercentOfGroup', 'Vendor 1 Percent Of Group', 'NUMBER', 9, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (89, 4, 'Vendor2Id', 'Vendor 2 Id', 'NUMBER', 10, FALSE, NULL, '{ "type": "number"}'::jsonb),
    (90, 4, 'Vendor2Name', 'Vendor 2 Name', 'TEXT', 11, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (91, 4, 'Vendor2PoAmount', 'Vendor 2 PO Amount', 'NUMBER', 12, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (92, 4, 'Vendor2PercentOfGroup', 'Vendor 2 Percent Of Group', 'NUMBER', 13, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (93, 4, 'Vendor3Id', 'Vendor 3 Id', 'NUMBER', 14, FALSE, NULL, '{ "type": "number"}'::jsonb),
    (94, 4, 'Vendor3Name', 'Vendor 3 Name', 'TEXT', 15, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (95, 4, 'Vendor3PoAmount', 'Vendor 3 PO Amount', 'NUMBER', 16, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (96, 4, 'Vendor3PercentOfGroup', 'Vendor 3 Percent Of Group', 'NUMBER', 17, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (97, 4, 'Vendor4Id', 'Vendor 4 Id', 'NUMBER', 18, FALSE, NULL, '{ "type": "number"}'::jsonb),
    (98, 4, 'Vendor4Name', 'Vendor 4 Name', 'TEXT', 19, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (99, 4, 'Vendor4PoAmount', 'Vendor 4 PO Amount', 'NUMBER', 20, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (100, 4, 'Vendor4PercentOfGroup', 'Vendor 4 Percent Of Group', 'NUMBER', 21, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (101, 4, 'Vendor5Id', 'Vendor 5 Id', 'NUMBER', 22, FALSE, NULL, '{ "type": "number"}'::jsonb),
    (102, 4, 'Vendor5Name', 'Vendor 5 Name', 'TEXT', 23, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (103, 4, 'Vendor5PoAmount', 'Vendor 5 PO Amount', 'NUMBER', 24, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (104, 4, 'Vendor5PercentOfGroup', 'Vendor 5 Percent Of Group', 'NUMBER', 25, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (105, 4, 'PoCycleTime', 'PO Cycle Time', 'NUMBER', 26, TRUE, NULL, '{ "type": "number", "alignment": "right"}'::jsonb),

    -- Report 5 (purchase.mis_func_item_wise_purchase_summary )

    (106, 5, 'ItemId', 'Item Id', 'NUMBER', 1, FALSE, NULL, '{"type":"number"}'::jsonb),
    (107, 5, 'ItemName', 'Item Name', 'TEXT', 2, TRUE, NULL, '{"type":"string", "isUsedForRedirection": true}'::jsonb),
    (110, 5, 'TotalPoQuantity', 'Total PO Qty.', 'NUMBER', 3, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (108, 5, 'PoUnitId', 'PO Unit Id', 'NUMBER', 4, FALSE, NULL, '{"type":"number"}'::jsonb),
    (109, 5, 'PoUnit', 'UOM', 'TEXT', 5, TRUE, NULL, '{"type":"string"}'::jsonb),
    (111, 5, 'TotalVendorCount', 'Total Vendor Count', 'NUMBER', 6, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (112, 5, 'TotalPoCount', 'Total PO Count', 'NUMBER', 7, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (113, 5, 'TotalPoAmount', 'Total PO Amount', 'NUMBER', 6, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (114, 5, 'AvgPoRate', 'Avg. Rate', 'NUMBER', 9, TRUE, NULL, '{"type":"number","alignment":"right", "isRate": true}'::jsonb),
    (115, 5, 'LowestRate', '', 'TEXT', 17, TRUE, NULL, '{"type":"string", "colToBeExpanded": "LowestPoRate"}'::jsonb),
    (116, 5, 'LowestPoRate', 'Last PO Vendor', 'OBJECT', 18, TRUE, NULL, '{"type":"object", "isExpandable": true}'::jsonb),
    (117, 5, 'HighestRate', 'Highest Rate', 'NUMBER', 18, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":3, "colToBeExpanded": "HighestPoRate" }'::jsonb),
    (118, 5, 'HighestPoRate', 'Highest PO Rate', 'OBJECT', 15, TRUE, NULL, '{"type":"object", "isExpandable": true}'::jsonb),
    (119, 5, 'LastPurchaseQty', 'Last Purchase Qty.', 'NUMBER', 21, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":3, "colToBeExpanded": "LastPoDate"}'::jsonb),
    (120, 5, 'LastPoDate', 'Last PO Date', 'DATE', 16, TRUE, NULL, '{"type":"date", "isExpandable": true}'::jsonb),
    (121, 5, 'LastPurchaseRate', 'Last Purchase Rate', 'NUMBER', 22, TRUE, NULL, '{"type":"number","alignment":"right", "isRate": true, "colToBeExpanded": "LastPoRate"}'::jsonb),
    (122, 5, 'LastPoRate', 'Last PO Rate', 'OBJECT', 13, TRUE, NULL, '{ "type":"object", "isExpandable": true}'::jsonb),
    (123, 5, 'CycleDays', 'Cycle Days', 'NUMBER', 12, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),

    -- Report 6 (masterdata.mis_func_new_vendors)

    (134, 6, 'VendorName', 'Vendor Name', 'TEXT', 1, TRUE, NULL, '{"type":"text"}'::jsonb),
    (135, 6, 'VendorLocation', 'Vendor Location', 'TEXT', 2, TRUE, NULL, '{"type":"text"}'::jsonb),
    (136, 6, 'ContactPerson', 'Contact Person', 'TEXT', 3, TRUE, NULL, '{"type":"text"}'::jsonb),
    (137, 6, 'RegistrationDate', 'Registration Date', 'TEXT', 4, TRUE, NULL, '{"type":"date"}'::jsonb),
    (138, 6, 'StatusName', 'Status Name', 'TEXT', 5, TRUE, NULL, '{"type":"text"}'::jsonb),
    (139, 6, 'TotalRfq', 'Total RFQ', 'NUMBER', 6, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (140, 6, 'TotalQt', 'Total Quotation', 'NUMBER', 7, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (141, 6, 'TotalPo', 'Total PO', 'NUMBER', 8, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),

    -- Report 7 (purchase.mis_func_po_rejection_history_register)

    (142, 7, 'Company', 'Company', 'TEXT', 1, TRUE, NULL, '{"type": "text"}'::jsonb),
    (143, 7, 'CompanyId', 'Company Id', 'NUMBER', 2, FALSE, NULL, '{}'::jsonb),
    (144, 7, 'Division', 'Division', 'TEXT', 3, TRUE, NULL, '{"type": "text"}'::jsonb),
    (145, 7, 'DivisionId', 'Division Id', 'NUMBER', 4, FALSE, NULL, '{}'::jsonb),
    (146, 7, 'DocNoYearly', 'Doc No Yearly', 'TEXT', 5, TRUE, NULL, '{"type": "text"}'::jsonb),
    (147, 7, 'PoDate', 'PO Date', 'DATE', 6, TRUE, NULL, '{"type": "DATE"}'::jsonb),
    (148, 7, 'VendorName', 'Vendor Name', 'TEXT', 7, TRUE, NULL, '{"type": "text"}'::jsonb),
    (149, 7, 'VendorLocation', 'Vendor Location', 'TEXT', 8, TRUE, NULL, '{"type": "text"}'::jsonb),
    (150, 7, 'RejectedByUser', 'Rejected By User', 'TEXT', 9, TRUE, NULL, '{"type": "text"}'::jsonb),
    (151, 7, 'RejectionComment', 'Rejection Comment', 'TEXT', 10, TRUE, NULL, '{"type": "text"}'::jsonb),
    (152, 7, 'RejectionNetAmt', 'Rejection Net Amount', 'NUMBER', 11, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (153, 7, 'ApprovalSetupName', 'Approval Setup Name', 'TEXT', 12, TRUE, NULL, '{"type": "text"}'::jsonb),
    (154, 7, 'RejectionDate', 'Rejection Date', 'DATE', 13, TRUE, NULL, '{"type": "DATE"}'::jsonb),
    (155, 7, 'ErpPoNo', 'ERP PO No.', 'TEXT', 14, TRUE, NULL, '{"type": "DATE"}'::jsonb),
    (156, 7, 'CreatedBy', 'Created By', 'TEXT', 15, TRUE, NULL, '{"type": "DATE"}'::jsonb),
    (157, 7, 'CreatedDate', 'Created Date', 'DATE', 16, TRUE, NULL, '{"type": "DATE"}'::jsonb),


    -- Report 8 (purchase.mis_func_po_summary)

    (158, 8, 'Company', 'Company', 'TEXT', 1, TRUE, NULL, '{"type":"string"}'::jsonb),
    (159, 8, 'CompanyId', 'Company Id', 'NUMBER', 2, FALSE, NULL, '{"type":"number"}'::jsonb),
    (160, 8, 'Division', 'Division', 'TEXT', 3, TRUE, NULL, '{"type":"string"}'::jsonb),
    (161, 8, 'DivisionId', 'Division Id', 'NUMBER', 4, FALSE, NULL, '{"type":"number"}'::jsonb),
    (162, 8, 'Department', 'Department', 'TEXT', 5, TRUE, NULL, '{"type":"string"}'::jsonb),
    (163, 8, 'PoNo', 'PO No.', 'TEXT', 6, TRUE, NULL, '{"type":"string"}'::jsonb),
    (164, 8, 'AmendmentNo', 'Amendment No.', 'NUMBER', 7, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (165, 8, 'ErpPoNo', 'ERP PO No.', 'TEXT', 8, TRUE, NULL, '{"type":"string"}'::jsonb),
    (166, 8, 'PoDate', 'PO Date', 'DATE', 9, TRUE, NULL, '{"type":"date"}'::jsonb),
    (167, 8, 'DocumentType', 'Document Type', 'TEXT', 10, TRUE, NULL, '{"type":"string"}'::jsonb),
    (168, 8, 'RefDocumentNo', 'Ref Document No.', 'TEXT', 11, TRUE, NULL, '{"type":"string"}'::jsonb),
    (169, 8, 'RefDocumentDate', 'Ref Document Date', 'TEXT', 12, TRUE, NULL, '{"type":"date"}'::jsonb),
    (170, 8, 'QuotationRevNo', 'Quotation Rev No.', 'NUMBER', 13, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (171, 8, 'VendorName', 'Vendor Name', 'TEXT', 14, TRUE, NULL, '{"type":"string"}'::jsonb),
    (172, 8, 'VendorLocation', 'Vendor Location', 'TEXT', 15, TRUE, NULL, '{"type":"string"}'::jsonb),
    (173, 8, 'PartyRefNo', 'Party Ref No.', 'TEXT', 16, TRUE, NULL, '{"type":"string"}'::jsonb),
    (174, 8, 'PartyRefDate', 'Party Ref Date', 'DATE', 17, TRUE, NULL, '{"type":"date"}'::jsonb),
    (175, 8, 'FreightType', 'Freight Type', 'TEXT', 18, TRUE, NULL, '{"type":"string"}'::jsonb),
    (176, 8, 'FromLocation', 'From Location', 'TEXT', 19, TRUE, NULL, '{"type":"string"}'::jsonb),
    (177, 8, 'ToLocation', 'To Location', 'TEXT', 20, TRUE, NULL, '{"type":"string"}'::jsonb),
    (178, 8, 'ShippingLocation', 'Shipping Location', 'TEXT', 21, TRUE, NULL, '{"type":"string"}'::jsonb),
    (179, 8, 'ItemName', 'Item', 'TEXT', 22, TRUE, NULL, '{"type":"string"}'::jsonb),
    (180, 8, 'Discount', 'Discount', 'NUMBER', 23, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (181, 8, 'Cgst', 'CGST', 'NUMBER', 24, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (182, 8, 'Sgst', 'SGST', 'NUMBER', 25, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (183, 8, 'Igst', 'IGST', 'NUMBER', 26, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (184, 8, 'PoNetAmount', 'PO Net Amount', 'NUMBER', 27, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (185, 8, 'AgainstCs', 'Against CS', 'TEXT', 28, TRUE, NULL, '{"type":"string"}'::jsonb),
    (186, 8, 'CreatedBy', 'Created By', 'TEXT', 29, TRUE, NULL, '{"type":"string"}'::jsonb),
    (187, 8, 'ReviewStatus', 'Review Status', 'TEXT', 30, TRUE, NULL, '{"type":"string"}'::jsonb),
    (188, 8, 'RejectionComment', 'Rejection Comment', 'TEXT', 31, TRUE, NULL, '{"type":"string"}'::jsonb),
    (189, 8, 'AgainstAuction', 'Against Auction', 'TEXT', 32, TRUE, NULL, '{"type":"string"}'::jsonb),
    (190, 8, 'IsAuthorized', 'Is Authorized', 'TEXT', 33, TRUE, NULL, '{"type":"string"}'::jsonb),


    -- Report 9 (purchase.mis_func_purchase_register)
    
    (191, 9, 'DocNoYearly', 'PO No.', 'TEXT', 1, TRUE, NULL, '{"type":"string"}'::jsonb),
    (192, 9, 'Company', 'Company', 'TEXT', 2, TRUE, NULL, '{"type":"string"}'::jsonb),
    (193, 9, 'CompanyId', 'Company Id', 'NUMBER', 3, FALSE, NULL, '{"type":"number"}'::jsonb),
    (194, 9, 'Division', 'Division', 'TEXT', 4, TRUE, NULL, '{"type":"string"}'::jsonb),
    (195, 9, 'DivisionId', 'Division Id', 'NUMBER', 5, FALSE, NULL, '{"type":"number"}'::jsonb),
    (196, 9, 'Department', 'Department', 'TEXT', 6, TRUE, NULL, '{"type":"string"}'::jsonb),
    (197, 9, 'ErpDocNoYearly', 'ERP Doc No.', 'TEXT', 7, TRUE, NULL, '{"type":"string"}'::jsonb),
    (198, 9, 'DocDate', 'Doc Date', 'DATE', 8, TRUE, NULL, '{"type":"date"}'::jsonb),
    (199, 9, 'AmendmentNo', 'Amendment No.', 'NUMBER', 9, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (200, 9, 'RefDocType', 'Ref Doc Type', 'TEXT', 10, TRUE, NULL, '{"type":"string"}'::jsonb),
    (201, 9, 'RefDocNo', 'Ref Doc No.', 'TEXT', 11, TRUE, NULL, '{"type":"string"}'::jsonb),
    (202, 9, 'RefDocTypeId', 'Ref Doc Type Id', 'NUMBER', 12, FALSE, NULL, '{"type":"number"}'::jsonb),
    (203, 9, 'VendorName', 'Vendor Name', 'TEXT', 13, TRUE, NULL, '{"type":"string"}'::jsonb),
    (204, 9, 'VendorLocation', 'Vendor Location', 'TEXT', 14, TRUE, NULL, '{"type":"string"}'::jsonb),
    (205, 9, 'PartyRefNo', 'Party Ref No.', 'TEXT', 15, TRUE, NULL, '{"type":"string"}'::jsonb),
    (206, 9, 'PartyRefDate', 'Party Ref Date', 'DATE', 16, TRUE, NULL, '{"type":"date"}'::jsonb),
    (207, 9, 'CarrierType', 'Carrier Type', 'TEXT', 17, TRUE, NULL, '{"type":"string"}'::jsonb),
    (208, 9, 'DueDays', 'Due Days', 'NUMBER', 18, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (209, 9, 'PaymentDueBasis', 'Payment Due Basis', 'TEXT', 19, TRUE, NULL, '{"type":"string"}'::jsonb),
    (210, 9, 'FreightType', 'Freight Type', 'TEXT', 20, TRUE, NULL, '{"type":"string"}'::jsonb),
    (211, 9, 'FromLocation', 'From Location', 'TEXT', 21, TRUE, NULL, '{"type":"string"}'::jsonb),
    (212, 9, 'ToLocation', 'To Location', 'TEXT', 22, TRUE, NULL, '{"type":"string"}'::jsonb),
    (213, 9, 'ShippingLocation', 'Shipping Location', 'TEXT', 23, TRUE, NULL, '{"type":"string"}'::jsonb),
    (214, 9, 'HsnCode', 'HSN Code', 'TEXT', 24, TRUE, NULL, '{"type":"string", "alignment": "right"}'::jsonb),
    (215, 9, 'ItemName', 'Item', 'TEXT', 25, TRUE, NULL, '{"type":"string"}'::jsonb),
    (216, 9, 'Make', 'Make', 'TEXT', 26, TRUE, NULL, '{"type":"string"}'::jsonb),
    (217, 9, 'TechSpec', 'Tech Spec', 'TEXT', 27, TRUE, NULL, '{"type":"string"}'::jsonb),
    (218, 9, 'Quantity', 'Quantity', 'NUMBER', 28, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":3}'::jsonb),
    (219, 9, 'Rate', 'Rate', 'NUMBER', 29, TRUE, NULL, '{"type":"number","alignment":"right", "isRate": true}'::jsonb),
    (220, 9, 'BasicAmount', 'Basic Amount', 'NUMBER', 30, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (221, 9, 'Discount', 'Discount', 'NUMBER', 31, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (222, 9, 'Cgst', 'CGST', 'NUMBER', 32, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (223, 9, 'Sgst', 'SGST', 'NUMBER', 33, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (224, 9, 'Igst', 'IGST', 'NUMBER', 34, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (225, 9, 'ItemNetAmount', 'Item Net Amount', 'NUMBER', 35, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (226, 9, 'PoNetAmount', 'PO Net Amount', 'NUMBER', 36, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (227, 9, 'ReviewStatus', 'Review Status', 'TEXT', 37, TRUE, NULL, '{"type":"string"}'::jsonb),
    (228, 9, 'DispatchClearanceStatus', 'Dispatch Clearance Status', 'TEXT', 38, FALSE, NULL, '{"type":"string"}'::jsonb),
    (229, 9, 'DispatchClearanceNo', 'Dispatch Clearance No.', 'TEXT', 39, FALSE, NULL, '{"type":"string"}'::jsonb),
    (230, 9, 'DispatchQty', 'Dispatch Qty.', 'NUMBER', 40, FALSE, NULL, '{"type":"number","alignment":"right","decimalPlaces":3}'::jsonb),
    (231, 9, 'DispatchEntryNoYearly', 'Dispatch Entry No. Yearly', 'TEXT', 41, FALSE, NULL, '{"type":"string"}'::jsonb),
    (232, 9, 'PrDetail', 'PR Detail', 'TEXT', 42, TRUE, NULL, '{"type":"string"}'::jsonb),
    (233, 9, 'ScheduleDate', 'Schedule Date', 'DATE', 43, TRUE, NULL, '{"type":"date"}'::jsonb),
    (234, 9, 'IsAuthorized', 'Is Authorized', 'TEXT', 44, TRUE, NULL, '{"type":"string"}'::jsonb),
    (235, 9, 'MsmeNo', 'MSME No.', 'TEXT', 45, TRUE, NULL, '{"type":"string"}'::jsonb),
    (236, 9, 'MsmeType', 'MSME Type', 'TEXT', 46, TRUE, NULL, '{"type":"string"}'::jsonb),

    -- Report 10 (masterdata.mis_func_vendor_list)

    (237, 10, 'VendorName', 'Vendor Name', 'TEXT', 1, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (238, 10, 'Address', 'Address', 'TEXT', 2, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (239, 10, 'City', 'City', 'TEXT', 3, TRUE, NULL,'{"type": "TEXT"}'::jsonb),
    (240, 10, 'GstRegistrationType', 'GST Registration Type', 'TEXT', 4, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (241, 10, 'VendorType', 'Vendor Type', 'TEXT', 5, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (242, 10, 'Region', 'Region', 'TEXT', 6, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (243, 10, 'BusinessType', 'Business Type', 'TEXT', 7, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (244, 10, 'GstinNo', 'GSTIN No', 'TEXT', 8, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (246, 10, 'PanNo', 'PAN No', 'TEXT', 10, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (248, 10, 'ContactNo', 'Contact No', 'TEXT', 12, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (249, 10, 'WebSite', 'Web Site', 'TEXT', 13, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (250, 10, 'Email', 'Email', 'TEXT', 14, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (251, 10, 'MsmeType', 'MSME Type', 'TEXT', 15, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (252, 10, 'MsmeRegNo', 'MSME Reg No', 'TEXT', 16, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (253, 10, 'ItemGroup', 'Item Group', 'TEXT', 17, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (255, 10, 'CreatedDate', 'Created Date', 'DATE', 19, TRUE, NULL, '{"type": "DATE"}'::jsonb),
    (256, 10, 'ModifiedBy', 'Modified By', 'TEXT', 20, TRUE, NULL, '{"type": "TEXT"}'::jsonb),
    (257, 10, 'ModifiedDate', 'Modified Date', 'DATE', 21, TRUE, NULL, '{"type": "DATE"}'::jsonb),

    -- Report 11 (purchase.mis_func_vendor_wise_procurement)

    (258, 11, 'VendorId', 'Vendor Id', 'NUMBER', 1, FALSE, NULL, '{"type":"number","alignment":"right", "isHidden": true}'::jsonb),
    (259, 11, 'VendorName', 'Vendor Name', 'TEXT', 2, TRUE, NULL, '{"type":"text", "isUsedForRedirection": true}'::jsonb),
    (260, 11, 'TotalEnquirySent', 'Total Enquiry Sent', 'NUMBER', 3, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (261, 11, 'TotalQuotationReceived', 'Total Quotation Received', 'NUMBER', 4, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (262, 11, 'POCount', 'PO Count', 'NUMBER', 5, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (263, 11, 'TotalPoAmount', 'Total PO Amount', 'NUMBER', 6, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (264, 11, 'MinPoValue', 'Min PO Value', 'NUMBER', 7, TRUE, NULL,'{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (265, 11, 'MaxPoValue', 'Max PO Value', 'NUMBER', 8, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (266, 11, 'AveragePoAmount', 'Average PO Amount', 'NUMBER', 9, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (267, 11, 'LastPoDate', 'Last PO Date', 'DATE', 10, TRUE, NULL, '{"type":"date"}'::jsonb),
    (268, 11, 'LastPoAmount', 'Last PO Amount', 'NUMBER', 11, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),

    -- Report 12 (purchase.mis_func_passive_vendors)

    (269, 12, 'VendorId', 'Vendor Id', 'NUMBER', 1, FALSE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (270, 12, 'VendorName', 'Vendor Name', 'TEXT', 2, TRUE, NULL, '{"type":"text"}'::jsonb),
    (271, 12, 'RFQCount', 'RFQ Count', 'NUMBER', 3, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (272, 12, 'QuotationCount', 'Quotation Count', 'NUMBER', 4, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (273, 12, 'NeverOpenedCount', 'Never Opened Count', 'NUMBER', 5, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (274, 12, 'RegretCount', 'Regret Count', 'NUMBER', 6, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (275, 12, 'ViewedCount', 'Viewed Count', 'NUMBER', 7, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (276, 12, 'PurchaseOrderCount', 'Purchase Order Count', 'NUMBER', 8, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (277, 12, 'PurchaseOrderAmount', 'Purchase Order Amount', 'NUMBER', 9, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),

    -- Report 13 (purchase.mis_func_rfq_to_po_progress_flow)

    (278, 13, 'RfqNo', 'RFQ No.', 'TEXT', 1, TRUE, NULL, '{"type":"text"}'::jsonb),
    (279, 13, 'RfqDate', 'RFQ Date', 'TEXT', 2, TRUE, NULL, '{"type":"date"}'::jsonb),
    (280, 13, 'ItemDetails', 'Item', 'TEXT', 3, TRUE, NULL, '{"type":"text"}'::jsonb),
    (281, 13, 'RfqAgainst', 'RFQ Against', 'TEXT', 4, TRUE, NULL, '{"type":"text"}'::jsonb),
    (282, 13, 'ValidityDate', 'Validity Date', 'TEXT', 5, TRUE, NULL, '{"type":"date"}'::jsonb),
    (283, 13, 'CreatedBy', 'Created By', 'TEXT', 6, TRUE, NULL, '{"type":"text"}'::jsonb),
    (284, 13, 'AuthorizedBy', 'Authorized By', 'TEXT', 7, TRUE, NULL, '{"type":"text"}'::jsonb),
    (285, 13, 'Status', 'Status', 'TEXT', 8, TRUE, NULL, '{"type":"text"}'::jsonb),
    (286, 13, 'QtReceived', 'Quotation Received', 'TEXT', 9, TRUE, NULL, '{"type":"text"}'::jsonb),
    (287, 13, 'CsNo', 'CS No.', 'TEXT', 10, TRUE, NULL, '{"type":"text"}'::jsonb),
    (433, 13, 'ErpPoNo', 'ERP PO No', 'TEXT', 11, TRUE, NULL, '{"type":"text"}'::jsonb),

    -- Report 14 (security.mis_func_user_performance_company_wise) — custom JSON; dynamic company columns per row

    (288, 14, 'User', 'User', 'TEXT', 1, TRUE, NULL, '{"section":"data","key":"User"}'::jsonb),
    (289, 14, 'Total', 'Total', 'TEXT', 2, TRUE, NULL, '{"section":"data","key":"Total","cellFormat":"poValue|poCount|shareOfTotalAmount|shareOfTotalCount|shareOfUserAmount|shareOfUserCount"}'::jsonb),
    (290, 14, 'CompanyColumn', 'Company', 'TEXT', 3, TRUE, NULL, '{"section":"data","dynamic":true,"keySource":"company_alias","cellFormat":"poValue|poCount|shareOfTotalAmount|shareOfTotalCount|shareOfUserAmount|shareOfUserCount"}'::jsonb),
    (291, 14, 'page_no', 'Page No', 'NUMBER', 4, FALSE, NULL, '{"section":"root","key":"page_no"}'::jsonb),
    (292, 14, 'page_size', 'Page Size', 'NUMBER', 5, FALSE, NULL, '{"section":"root","key":"page_size"}'::jsonb),
    (293, 14, 'total_count', 'Total Count', 'NUMBER', 6, FALSE, NULL, '{"section":"root","key":"total_count"}'::jsonb),

    -- Report 15 (security.mis_func_user_performance) — custom JSON; graph + table1 + table2

    (294, 15, 'Graph_UserName', 'User', 'TEXT', 1, TRUE, NULL, '{"section":"graph","key":"UserName"}'::jsonb),
    (295, 15, 'Graph_Auction', 'Auction', 'NUMBER', 2, TRUE, NULL, '{"section":"graph","key":"Auction","divisor":100000}'::jsonb),
    (296, 15, 'Graph_Direct', 'Direct', 'NUMBER', 3, TRUE, NULL, '{"section":"graph","key":"Direct","divisor":100000}'::jsonb),
    (297, 15, 'Graph_RFQ', 'RFQ', 'NUMBER', 4, TRUE, NULL, '{"section":"graph","key":"RFQ","divisor":100000}'::jsonb),
    (298, 15, 'Graph_PLCS', 'PL/CS', 'NUMBER', 5, TRUE, NULL, '{"section":"graph","key":"PL/CS","divisor":100000}'::jsonb),
    (299, 15, 'Table1_UserName', 'User', 'TEXT', 6, TRUE, NULL, '{"section":"table1","key":"UserName"}'::jsonb),
    (300, 15, 'Table1_RfqCount', 'RFQ Count', 'NUMBER', 7, TRUE, NULL, '{"section":"table1","key":"RfqCount"}'::jsonb),
    (301, 15, 'Table1_QuotationCount', 'Quotation Count', 'NUMBER', 8, TRUE, NULL, '{"section":"table1","key":"QuotationCount"}'::jsonb),
    (302, 15, 'Table1_PoCount', 'PO Count', 'NUMBER', 9, TRUE, NULL, '{"section":"table1","key":"PoCount"}'::jsonb),
    (303, 15, 'Table1_PoAmount', 'PO Amount', 'NUMBER', 10, TRUE, NULL, '{"section":"table1","key":"PoAmount"}'::jsonb),
    (304, 15, 'Table1_TotalRfqCount', 'Total RFQ Count', 'NUMBER', 11, TRUE, NULL, '{"section":"table1","key":"TotalRfqCount"}'::jsonb),
    (305, 15, 'Table1_TotalQuotationCount', 'Total Quotation Count', 'NUMBER', 12, TRUE, NULL, '{"section":"table1","key":"TotalQuotationCount"}'::jsonb),
    (306, 15, 'Table1_TotalPoCount', 'Total PO Count', 'NUMBER', 13, TRUE, NULL, '{"section":"table1","key":"TotalPoCount"}'::jsonb),
    (307, 15, 'Table1_TotalPoAmount', 'Total PO Amount', 'NUMBER', 14, TRUE, NULL, '{"section":"table1","key":"TotalPoAmount"}'::jsonb),
    (308, 15, 'Table1_RfqPercentage', 'RFQ %', 'NUMBER', 15, TRUE, NULL, '{"section":"table1","key":"RfqPercentage","suffix":"%"}'::jsonb),
    (309, 15, 'Table1_QuotationPercentage', 'Quotation %', 'NUMBER', 16, TRUE, NULL, '{"section":"table1","key":"QuotationPercentage","suffix":"%"}'::jsonb),
    (310, 15, 'Table1_PoCountPercentage', 'PO Count %', 'NUMBER', 17, TRUE, NULL, '{"section":"table1","key":"PoCountPercentage","suffix":"%"}'::jsonb),
    (311, 15, 'Table1_PoAmountPercentage', 'PO Amount %', 'NUMBER', 18, TRUE, NULL, '{"section":"table1","key":"PoAmountPercentage","suffix":"%"}'::jsonb),
    (312, 15, 'Table2_UserName', 'User', 'TEXT', 19, TRUE, NULL, '{"section":"table2","key":"UserName"}'::jsonb),
    (313, 15, 'Table2_Direct', 'Direct', 'NUMBER', 20, TRUE, NULL, '{"section":"table2","key":"Direct"}'::jsonb),
    (314, 15, 'Table2_RFQ', 'RFQ', 'NUMBER', 21, TRUE, NULL, '{"section":"table2","key":"RFQ"}'::jsonb),
    (315, 15, 'Table2_Auction', 'Auction', 'NUMBER', 22, TRUE, NULL, '{"section":"table2","key":"Auction"}'::jsonb),
    (316, 15, 'Table2_Total', 'Total', 'NUMBER', 23, TRUE, NULL, '{"section":"table2","key":"Total"}'::jsonb),
    (317, 15, 'Table2_PLCS', 'PL/CS', 'NUMBER', 24, TRUE, NULL, '{"section":"table2","key":"PL/CS"}'::jsonb),
    (318, 15, 'Table2_Percentage', 'Percentage', 'NUMBER', 25, TRUE, NULL, '{"section":"table2","key":"Percentage","suffix":"%"}'::jsonb),

    -- PO Timeline (purchase.mis_func_po_timeline)

    (320, 16, 'Company', 'Company', 'TEXT', 1, TRUE, NULL, '{"type":"text"}'::jsonb),
    (321, 16, 'CompanyId', 'Company Id', 'NUMBER', 2, FALSE, NULL, '{"type":"number"}'::jsonb),
    (322, 16, 'Division', 'Division', 'TEXT', 3, TRUE, NULL, '{"type":"text"}'::jsonb),
    (323, 16, 'DivisionId', 'Division Id', 'NUMBER', 4, FALSE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (324, 16, 'DocNoYearly', 'PO No', 'TEXT', 5, TRUE, NULL, '{"type":"text"}'::jsonb),
    (325, 16, 'ErpDocNoYearly', 'ERP PO No', 'TEXT', 6, TRUE, NULL, '{"type":"text"}'::jsonb),
    (326, 16, 'DocDate', 'PO Date', 'TEXT', 7, TRUE, NULL, '{"type":"date"}'::jsonb),
    (327, 16, 'PoCreatedBy', 'PO Created By', 'TEXT', 8, TRUE, NULL, '{"type":"text"}'::jsonb),
    (328, 16, 'PoCreatedDate', 'PO Created Date', 'TEXT', 9, TRUE, NULL, '{"type":"date"}'::jsonb),
    (329, 16, 'PoAuthorizedBy', 'PO Authorized By', 'TEXT', 10, TRUE, NULL, '{"type":"text"}'::jsonb),
    (330, 16, 'PoAuthorizedDate', 'PO Authorized Date', 'TEXT', 11, TRUE, NULL, '{"type":"date"}'::jsonb),
    (331, 16, 'NetAmount', 'Net Amount', 'NUMBER', 12, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (332, 16, 'RefDocumentType', 'Ref Document Type', 'TEXT', 13, TRUE, NULL, '{"type":"text"}'::jsonb),
    (333, 16, 'VendorName', 'Vendor Name', 'TEXT', 14, TRUE, NULL, '{"type":"text"}'::jsonb),
    (334, 16, 'CsId', 'CS No', 'TEXT', 15, TRUE, NULL, '{"type":"text"}'::jsonb),
    (335, 16, 'CsDate', 'CS Date', 'TEXT', 16, TRUE, NULL, '{"type":"date"}'::jsonb),
    (336, 16, 'CsCreatedBy', 'CS Created By', 'TEXT', 17, TRUE, NULL, '{"type":"text"}'::jsonb),
    (337, 16, 'CsCreatedDate', 'CS Created Date', 'TEXT', 18, TRUE, NULL, '{"type":"date"}'::jsonb),
    (338, 16, 'CsAuthorizedBy', 'CS Authorized By', 'TEXT', 19, TRUE, NULL, '{"type":"text"}'::jsonb),
    (339, 16, 'CsAuthorizedDate', 'CS Authorized Date', 'TEXT', 20, TRUE, NULL, '{"type":"date"}'::jsonb),
    (340, 16, 'QuotationNo', 'Quotation No', 'TEXT', 21, TRUE, NULL, '{"type":"text"}'::jsonb),
    (341, 16, 'QuotationDate', 'Quotation Date', 'TEXT', 22, TRUE, NULL, '{"type":"date"}'::jsonb),
    (342, 16, 'AuctionNo', 'Auction No', 'TEXT', 23, FALSE, NULL, '{"type":"text"}'::jsonb),
    (343, 16, 'AuctionDate', 'Auction Date', 'TEXT', 24, FALSE, NULL, '{"type":"date"}'::jsonb),
    (344, 16, 'AuctionCreatedBy', 'Auction Created By', 'TEXT', 25, FALSE, NULL, '{"type":"text"}'::jsonb),
    (345, 16, 'AuctionCreatedDate', 'Auction Created Date', 'TEXT', 26, FALSE, NULL, '{"type":"date"}'::jsonb),
    (346, 16, 'AuctionAuthorizedBy', 'Auction Authorized By', 'TEXT', 27, FALSE, NULL, '{"type":"text"}'::jsonb),
    (347, 16, 'AuctionAuthorizedDate', 'Auction Authorized Date', 'TEXT', 28, FALSE, NULL, '{"type":"date"}'::jsonb),
    (348, 16, 'RfqNo', 'RFQ No', 'TEXT', 29, TRUE, NULL, '{"type":"text"}'::jsonb),
    (349, 16, 'RfqDate', 'RFQ Date', 'TEXT', 30, TRUE, NULL, '{"type":"date"}'::jsonb),
    (350, 16, 'RfqCreatedBy', 'RFQ Created By', 'TEXT', 31, TRUE, NULL, '{"type":"text"}'::jsonb),
    (351, 16, 'RfqCreatedDate', 'RFQ Created Date', 'TEXT', 32, TRUE, NULL, '{"type":"date"}'::jsonb),
    (352, 16, 'RfqAuthorizedBy', 'RFQ Authorized By', 'TEXT', 33, TRUE, NULL, '{"type":"text"}'::jsonb),
    (353, 16, 'RfqAuthorizedDate', 'RFQ Authorized Date', 'TEXT', 34, TRUE, NULL, '{"type":"date"}'::jsonb),
    (354, 16, 'TotalDays', 'Total Days', 'NUMBER', 35, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (355, 16, 'ItemDescription', 'Item Description', 'TEXT', 36, TRUE, NULL, '{"type":"text"}'::jsonb),

    -- PO L2 Report (purchase.mis_func_po_l2_report)

    (378, 18, 'Company', 'Company', 'TEXT', 1, TRUE, NULL, '{"type":"text"}'::jsonb),
    (379, 18, 'ErpPoNo', 'ERP PO No', 'TEXT', 2, TRUE, NULL, '{"type":"text"}'::jsonb),
    (380, 18, 'PoNo', 'PO No', 'TEXT', 3, TRUE, NULL, '{"type":"text"}'::jsonb),
    (381, 18, 'DocumentDate', 'PO Date', 'TEXT', 4, TRUE, NULL, '{"type":"date"}'::jsonb),
    (382, 18, 'PoVendor', 'PO Vendor', 'TEXT', 5, TRUE, NULL, '{"type":"text"}'::jsonb),
    (383, 18, 'FullAddress', 'Full Address', 'TEXT', 6, TRUE, NULL, '{"type":"text"}'::jsonb),
    (384, 18, 'Quotation', 'Quotation', 'TEXT', 7, TRUE, NULL, '{"type":"text"}'::jsonb),
    (385, 18, 'QuotationDate', 'Quotation Date', 'TEXT', 8, TRUE, NULL, '{"type":"date"}'::jsonb),
    (386, 18, 'Item', 'Item Description', 'TEXT', 9, TRUE, NULL, '{"type":"text"}'::jsonb),
    (387, 18, 'Make', 'Make', 'TEXT', 10, TRUE, NULL, '{"type":"text"}'::jsonb),
    (388, 18, 'TechSpecification', 'Tech Specification', 'TEXT', 11, TRUE, NULL, '{"type":"text"}'::jsonb),
    (389, 18, 'Remark', 'Remark', 'TEXT', 12, TRUE, NULL, '{"type":"text"}'::jsonb),
    (390, 18, 'Quantity', 'Quantity', 'NUMBER', 13, TRUE, NULL, '{"type":"number","alignment":"right", "decimalPlaces": 3}'::jsonb),
    (391, 18, 'PoRate', 'PO Rate', 'NUMBER', 14, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (392, 18, 'DiscPerc', 'Discount %', 'NUMBER', 15, TRUE, NULL, '{"type":"number","alignment":"right", "decimalPlaces": 3}'::jsonb),
    (393, 18, 'DiscAmt', 'Discount Amount', 'NUMBER', 16, TRUE, NULL, '{"type":"number","alignment":"right", "decimalPlaces": 2}'::jsonb),
    (394, 18, 'RateAfterDiscount', 'Rate After Discount', 'NUMBER', 17, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (395, 18, 'BasicAmount', 'Basic Amount', 'NUMBER', 18, TRUE, NULL, '{"type":"number","alignment":"right", "decimalPlaces": 2}'::jsonb),
    (396, 18, 'L1Vendor', 'L1 Vendor', 'TEXT', 19, TRUE, NULL, '{"type":"text"}'::jsonb),
    (397, 18, 'L1Rate', 'L1 Rate', 'NUMBER', 20, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (398, 18, 'DifferenceAmt', 'Difference Amount', 'NUMBER', 21, TRUE, NULL, '{"type":"number", "alignment":"right", "decimalPlaces": 2}'::jsonb),
    (399, 18, 'DiffPerc', 'Difference %', 'NUMBER', 22, TRUE, NULL, '{"type":"number","alignment":"right", "decimalPlaces": 3}'::jsonb),
    (400, 18, 'CreatedBy', 'Created By', 'TEXT', 23, TRUE, NULL, '{"type": "text"}'::jsonb),
    (401, 18, 'CsReason', 'CS Reason', 'TEXT', 24, TRUE, NULL, '{"type": "text"}'::jsonb),

    -- Report 19 (purchase.mis_func_item_group_wise_purchase_summary)

    (402, 19, 'MonthName', 'Month', 'TEXT', 1, TRUE, NULL, '{ "type": "text"}'::jsonb),
    (403, 19, 'TotalAmount', 'Total Amount', 'NUMBER', 2, TRUE, NULL, '{"type":"number","alignment":"right", "decimalPlaces": 2}'::jsonb),
    (404, 19, 'NoOfPOs', 'No. of POs', 'NUMBER', 3, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
   

    -- Report 20 (purchase.mis_func_item_purchase_summary_month_wise)

    (405, 20, 'Month', 'Month', 'TEXT', 1, TRUE, NULL, '{"type":"string"}'::jsonb),
    (406, 20, 'TotalQuantity', 'Total Qty.', 'NUMBER', 2, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":3}'::jsonb),
    (407, 20, 'TotalPoAmount', 'Total PO Amount', 'NUMBER', 3, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (408, 20, 'TotalPoCount', 'Total PO Count', 'NUMBER', 4, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),
    (443, 20, 'AveragePoQty', 'Avg. PO Qty.', 'NUMBER', 5, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":3}'::jsonb),
    (444, 20, 'AveragePoAmount', 'Avg PO Amount', 'NUMBER', 6, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (445, 20, 'AverageRate', 'Avg Rate', 'NUMBER', 7, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),
    (446, 20, '%OfPoAmount', '% of PO Amount', 'NUMBER', 8, TRUE, NULL, '{"type":"number","alignment":"right","decimalPlaces":2}'::jsonb),


    -- Report 21 (masterdata.mis_func_vendor_summary_month_wise)

    (409, 21, 'Month', 'Month', 'TEXT', 1, TRUE, NULL, '{"type": "text"}'::jsonb),
    (410, 21, 'TotalPoAmount', 'Total PO Amount', 'NUMBER', 2, TRUE, NULL, '{"type":"number","alignment":"right", "decimalPlaces": 2}'::jsonb),
    (411, 21, 'NumOfPo', 'No. of POs', 'NUMBER', 3, TRUE, NULL, '{"type":"number","alignment":"right"}'::jsonb),

    -- Report 22 (purchase.mis_func_item_group_purchase_summary_vendor_wise)

    (412, 22, 'VendorId', 'Vendor Id', 'NUMBER', 1, FALSE, NULL, '{  "type": "number", "alignment": "right"}'::jsonb),
    (413, 22, 'VendorName', 'Vendor Name', 'TEXT', 2, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (414, 22, 'PoQty', 'PO Qty.', 'NUMBER', 3, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (415, 22, 'TotalPoAmount', 'Total PO Amount', 'NUMBER', 4, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (416, 22, 'NumOfPo', 'No. of POs', 'NUMBER', 5, TRUE, NULL, '{ "type": "number", "alignment": "right"}'::jsonb),
    (417, 22, 'AvgRate', 'Avg. Rate', 'NUMBER', 6, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (418, 22, 'PercentOfVendorWiseAmount', 'Percent Of Vendor Wise Amount', 'NUMBER', 7, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),

    -- Report 23 (purchase.mis_func_item_group_wise_detail)

    (419, 23, 'ItemGroupId', 'Item Group Id', 'NUMBER', 1, FALSE, NULL, '{ "type": "number", "alignment": "right", "isHidden": true}'::jsonb),
    (420, 23, 'ItemId', 'Item Id', 'NUMBER', 2, FALSE, NULL, '{ "type": "number", "alignment": "right", "isHidden" : true }'::jsonb),
    (421, 23, 'CurrentVendorId', 'Current Vendor Id', 'NUMBER', 3, FALSE, NULL, '{ "type": "number", "alignment": "right"}'::jsonb),
    (422, 23, 'TopVendorId', 'Top Vendor Id', 'NUMBER', 4, FALSE, NULL, '{ "type": "number", "alignment": "right"}'::jsonb),
    (423, 23, 'ItemGroupName', 'Item Group Name', 'TEXT', 5, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (424, 23, 'ItemName', 'Item Name', 'TEXT', 6, TRUE, NULL, '{ "type": "string", "isUsedForRedirection": true}'::jsonb),
    (425, 23, 'PoQuantity', 'PO Quantity', 'NUMBER', 7, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (426, 23, 'TotalPoAmount', 'Total PO Amount', 'NUMBER', 8, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (427, 23, 'GroupValueOfVendor', 'Group Value Of Vendor', 'NUMBER', 9, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (428, 23, 'GroupValueOfAllVendors', 'Group Value Of All Vendors', 'NUMBER', 10, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 2 }'::jsonb),
    (429, 23, 'VendorToAllVendorsRatio', 'Vendor To All Vendors Ratio', 'NUMBER', 11, TRUE, NULL, '{ "type": "number", "alignment": "right"}'::jsonb),
    (430, 23, 'TopVendorName', 'Top Vendor Name', 'TEXT', 12, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (431, 23, 'TopVendorPoAmount', 'Top Vendor PO Amount', 'NUMBER', 13, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (432, 23, 'TopVendorToAllVendorsRatio', 'Top Vendor To All Vendors Ratio', 'NUMBER', 14, TRUE, NULL, '{ "type": "number", "alignment": "right"}'::jsonb),

    -- Report 24 (inventory.func_indent_item_ageing_detail)
    (447, 24, 'company_name', 'Company', 'TEXT', 1, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (448, 24, 'division_name', 'Division', 'TEXT', 2, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (449, 24, 'doc_no_yearly', 'PR No.', 'TEXT', 3, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (450, 24, 'doc_date', 'PR Date', 'TEXT', 4, TRUE, NULL, '{ "type": "date" }'::jsonb),
    (451, 24, 'item_name', 'Item Name', 'TEXT', 5, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (452, 24, 'unit_alias', 'UOM', 'TEXT', 6, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (453, 24, 'make_name', 'Make', 'TEXT', 7, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (454, 24, 'pr_qty', 'PR Qty.', 'NUMBER', 8, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (455, 24, 'po_qty', 'PO Qty.', 'NUMBER', 9, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (456, 24, 'balance_qty', 'Balance Qty.', 'NUMBER', 10, TRUE, NULL, '{ "type": "number", "alignment": "right", "decimalPlaces": 3 }'::jsonb),
    (457, 24, 'status_name', 'Status', 'TEXT', 11, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (458, 24, 'ageing_days', 'Ageing (Days)', 'NUMBER', 12, TRUE, NULL, '{ "type": "number", "alignment": "right" }'::jsonb),
    (459, 24, 'ageing_range', 'Ageing Range', 'TEXT', 13, TRUE, NULL, '{ "type": "string" }'::jsonb),
    (460, 24, 'status_id', 'Status Id', 'NUMBER', 14, FALSE, NULL, '{ "type": "number", "alignment": "right", "isHidden": true }'::jsonb)

ON CONFLICT (report_id, name) DO UPDATE SET
    caption = EXCLUDED.caption,
    field_type = EXCLUDED.field_type,
    seq_no = EXCLUDED.seq_no,
    is_visible = EXCLUDED.is_visible,
    redirection_link = EXCLUDED.redirection_link,
    format_json = EXCLUDED.format_json;



INSERT INTO globaldata.report_filter_fields (
    id,
    report_id,
    name,
    caption,
    field_type,
    default_value,
    seq_no,
    is_mandatory,
    operator,
    config_json
)
VALUES
    -- Report 1 (inventory.mis_func_indent_register)

    (1,  1,  'pr_doc_no_yearly',   'PR Document Number',    'TEXT',     NULL,  1,  FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (2,  1,  'from_date',          'From Date',             'DATE',     NULL,  2,  TRUE, '>=', '{"type": "DATE"}'::jsonb),
    (3,  1,  'to_date',            'To Date',               'DATE',     NULL,  3,  TRUE, '<=', '{"type": "DATE"}'::jsonb),
    (4,  1,  'item_name',          'Item Name',             'TEXT',     NULL,  9,  FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (5,  1,  'expire_in',          'Expire In Days',        'INT',      NULL,  6,  FALSE, '=',  '{"type": "INT"}'::jsonb),
    (6,  1,  'company_ids',        'Companies',             'INT',      NULL,  10, TRUE, 'IN', '{"component" : "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias", "isMultiselect": true}'::jsonb),
    (7,  1,  'indent_due_type',    'Indent Due Type',       'INT',      NULL,  4,  TRUE, '=',  '{"component" : "drop-down", "options": [{"id": 1, "value": "ALL"}, {"id": 2, "value": "Expired"}, {"id": 3, "value": "Expires In"}], "accessorKey": "value"}'::jsonb),
    (8,  1,  'status_ids',         'Status',                'INT',      NULL,  5,  FALSE, 'IN',  '{"component" : "combo-box", "isMultiselect": true, "options": [{"id": 11, "value": "Completed"}, {"id": 5, "value": "Expired"}, {"id": 10, "value": "Inprogress"}, {"id": 3, "value": "Pending"}], "accessorKey": "value"}'::jsonb),
    (9,  1,  'department_name',    'Department Name',       'TEXT',     NULL,  7,  FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (10, 1,  'division_name',      'Division Name',         'TEXT',     NULL,  8,  FALSE, '=',  '{"type": "TEXT"}'::jsonb),

    -- Report 2 Indent Item Ageing (inventory.mis_func_indent_ageing)
    (11, 2, 'from_date',          'From Date',         'DATE',     NULL,  1,  TRUE, '>=', '{"type": "DATE"}'::jsonb),
    (12, 2, 'to_date',            'To Date',           'DATE',     NULL,  2,  TRUE, '<=', '{"type": "DATE"}'::jsonb),
    (13, 2, 'company_ids',        'Companies',         'INT',      NULL,  3,  TRUE, 'IN', '{"component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias", "isMultiselect": true}'::jsonb),
    (14, 2, 'division_id',        'Division',          'INT',      NULL,  4, FALSE, '=',  '{"component": "combo-box", "api": "/api/master/divisions/get", "accessorKey": "code"}'::jsonb),
    (15, 2, 'status_ids',         'Status',            'INT', NULL,  5, FALSE, 'IN', '{"component" : "combo-box", "isMultiselect": true, "options": [{"id": 11, "value": "Completed"}, {"id": 5, "value": "Expired"}, {"id": 10, "value": "Inprogress"}, {"id": 3, "value": "Pending"}, {"id": 15, "value": "Cancelled"}], "accessorKey": "value"}'::jsonb),
    (16, 2, 'ageing_range_id',    'Ageing Range',      'INT', NULL,  6, FALSE, '=',  '{"component": "drop-down", "options": [{"id": 1, "value": "0-7"}, {"id": 2, "value": "8-15"}, {"id": 3, "value": "16-30"}, {"id": 4, "value": "31-60"}, {"id": 5, "value": "61-90"}, {"id": 6, "value": "91-120"}, {"id": 7, "value": "121-180"}, {"id": 8, "value": ">180"}], "accessorKey": "value"}'::jsonb),

    -- Report 3 PO Amendment Register (purchase.mis_func_po_amendment_register)
    (17, 3, 'company_ids',        'Companies',       'INT',      NULL,  4, TRUE, 'IN', '{ "component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias", "isMultiselect": true }'::jsonb),
    (18, 3, 'from_date',          'From Date',        'DATE',     NULL,  1, TRUE, '>=', '{ "type": "DATE" }'::jsonb),
    (19, 3, 'to_date',            'To Date',          'DATE',     NULL,  2, TRUE, '<=', '{ "type": "DATE" }'::jsonb),
    (20, 3, 'division',           'Division Name',         'TEXT',     NULL,  10, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (21, 3, 'department',         'Department Name',       'TEXT',     NULL,  11, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (22, 3, 'from_amount',        'From Amount',      'decimal',  NULL,  5, FALSE, '=',  '{ "type": "NUMERIC", "precision": "2", "maxlength": "17" }'::jsonb),
    (23, 3, 'to_amount',          'To Amount',        'decimal',  NULL,  6, FALSE, '=',  '{ "type": "NUMERIC", "precision": "2", "maxlength": "17" }'::jsonb),
    (24, 3, 'ref_doc_type_id',    'Ref Doc Type',       'INT',      NULL,  3, FALSE, '=',  '{ "component": "combo-box", "api": "/api/globaldata/ref-doc-type?formId=10", "accessorKey": "refDocTypeName"}'::jsonb),
    (25, 3, 'status_id',          'Status',           'INT',      NULL,  9, FALSE, '=',  '{"component": "drop-down", "options": [ {"id": 7, "value": "Draft"}, {"id": 11, "value": "Completed"} ] }'::jsonb),
    (26, 3, 'po_no',              'PO No.',             'TEXT',     NULL, 7, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (27, 3, 'erp_po_no',          'ERP PO No.',          'TEXT',     NULL, 8, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (28, 3, 'vendor_name',        'Vendor Name',       'TEXT',     NULL, 13, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (29, 3, 'item_name',          'Item Name',         'TEXT',     NULL, 14, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (30, 3, 'show_all',           'ShowAll',          'BOOL',     NULL, 12, FALSE, '=',  '{"component": "checkbox"}'::jsonb),

    -- Report 4 Item Group Wise Procurement (purchase.mis_func_item_group_wise_procurement)
    (31, 4, 'company_ids',        'Companies',       'INT',      NULL,  4, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (32, 4, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{ "type": "DATE"}'::jsonb),
    (33, 4, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
   (34, 4, 'item_id',            'Item',           'INT',      NULL,  6, FALSE, '=',  '{
        "component": "combo-box",
        "api": "/api/master/items/get",
        "accessorKey": "itemName"
    }'::jsonb),
    (35, 4, 'vendor_id',          'Vendor',         'INT',      NULL,  3, FALSE, '=',  '{
        "component": "combo-box",
        "api": "/api/master/vendor-master/Get",
        "accessorKey": "vendorName"
    }'::jsonb),
    (36, 4, 'group_id',           'Group',          'INT',      NULL,  5, FALSE, '=',  '{
        "component": "combo-box",
        "api": "/api/master/groups/get",
        "accessorKey": "groupName"
    }'::jsonb),

    -- Report 5 Item Wise Purchase Summary (purchase.mis_func_item_wise_purchase_summary)
    (38, 5, 'company_ids',        'Company',       'INT',      NULL,  1, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (39, 5, 'from_date',          'From Date',         'DATE',     NULL,  2, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (40, 5, 'to_date',            'To Date',           'DATE',     NULL,  3, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (41, 5, 'item_id',            'Item',           'INT',      NULL,  4, FALSE, '=',  '{
       "api": "/api/master/items/get",
    "accessorKey": "itemName",
    "component": "auto-suggest",
    "columnDef": [
    {
      "id": "itemName",
      "name": "itemName",
      "header": "Item Name"
    },
    {
      "id": "itemCode",
      "name": "itemCode",
      "header": "Item Code"
    }
    ]
    }'::jsonb),
    (42, 5, 'vendor_id',          'Vendor',         'INT',      NULL,  5, FALSE, '=',  '{
      "api": "/api/master/vendor-master/Get",
    "accessorKey": "vendorName",
    "component": "auto-suggest",
    "columnDef": [
    {
      "id": "vendorName",
      "name": "vendorName",
      "header": "Vendor Name"
    },
    {
      "id": "vendorCode",
      "name": "vendorCode",
      "header": "Vendor Code"
    }
    ]
    }'::jsonb),
    (43, 5, 'group_id',           'Group',          'INT',      NULL,  6, FALSE, '=',  '{
     "api": "/api/master/groups/get",
    "accessorKey": "groupName",
    "component": "auto-suggest",
    "columnDef": [
    {
      "id": "groupName",
      "name": "groupName",
      "header": "Group Name"
    },
    {
      "id": "groupCode",
      "name": "groupCode",
      "header": "Group Code"
    }
    ]
    }'::jsonb),


    -- Report 6 MIS New Vendors (masterdata.mis_func_new_vendors)
    (46, 6, 'from_date',          'FromDate',         'DATE',     NULL,  1, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (47, 6, 'to_date',            'ToDate',           'DATE',     NULL,  2, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),

    -- Report 7 PO Rejection History (purchase.mis_func_po_rejection_history_register)
    
    (48, 7, 'user_id',           'User',           'INT',      NULL,  9, FALSE, '=',  '{ "type": "numeric", "component": "auto-suggest", "api": "/api/security/users/get", "accessorKey": "username", "columnDef": [ { "id": "username", "name": "username", "header": "Username" }, { "id": "displayName", "name": "displayName", "header": "Display Name" } ]}'::jsonb),
    (49, 7, 'company_ids',        'Companies',       'INT',      NULL,  4, TRUE, 'IN', ' { "component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias", "isMultiselect": true }'::jsonb),
    (50, 7, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{"type": "DATE"}'::jsonb),
    (51, 7, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{"type": "DATE"}'::jsonb),
    (52, 7, 'division',           'Division',         'INT',      NULL,  10, FALSE, '=',  '{"component": "auto-suggest", "api": "/api/master/divisions/get", "accessorKey": "divisionName"}'::jsonb),
    (53, 7, 'from_amount',        'From Amount',       'decimal',  NULL,  7, FALSE, '=',  '{"type": "numeric", "alignment": "right", "decimalPlaces": 2}'::jsonb),
    (54, 7, 'to_amount',          'To Amount',         'decimal',  NULL,  8, FALSE, '=',  '{"type": "numeric", "alignment": "right", "decimalPlaces": 2}'::jsonb),
    (55, 7, 'ref_doc_type_id',    'Ref Doc Type',     'INT',      NULL,  3, FALSE, '=',  '{ "component": "combo-box", "api": "/api/globaldata/ref-doc-type?formId=10", "accessorKey": "refDocTypeName"}'::jsonb),
    (56, 7, 'status_id',          'Status',         'INT',      NULL,  12, FALSE, '=',  '{"component": "drop-down", "options": [ {"id": 7, "value": "Draft"}, {"id": 11, "value": "Completed"} ] }'::jsonb),
    (57, 7, 'po_no',              'PO No.',             'TEXT',     NULL, 5, FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (58, 7, 'erp_po_no',          'ERP PO No.',          'TEXT',     NULL, 6, FALSE, '=',  '{"type": "TEXT" }'::jsonb),
    (59, 7, 'show_all',           'Show All',          'BOOL',     NULL, 13, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (60, 7, 'vendor_id',          'Vendor',         'INT',      NULL, 11, FALSE, '=',  '{"component": "auto-suggest", "api": "/api/master/vendor-master/Get", "accessorKey": "vendorName"}'::jsonb),
    
    
    --Report 8 PO Summary (purchase.mis_func_po_summary)
    (61, 8, 'company_ids',        'Companies',       'INT',      NULL,  4, FALSE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (62, 8, 'division',           'Division',         'INT',      NULL,  12, FALSE, '=',  '{
      "api": "/api/master/divisions/get",
    "accessorKey": "divisionName",
     "component": "auto-suggest",
    "columnDef": [
    {
      "id": "divisionName",
      "name": "divisionName",
      "header": "Division Name"
    },
    {
      "id": "code",
      "name": "code",
      "header": "Division Code"
    }
    ]
    }'::jsonb),
    (63, 8, 'department_name',    'Department',       'TEXT',     NULL,  9, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (64, 8, 'from_amount',        'From Amount',       'DECIMAL',  NULL,  7, FALSE, '=',  '{
    
 "type": "NUMERIC",
  "precision": "2",
  "maxlength": "17" 
}'::jsonb),
    (65, 8, 'to_amount',          'To Amount',         'DECIMAL',  NULL,  8, FALSE, '=',  '{
    
 "type": "NUMERIC",
  "precision": "2",
  "maxlength": "17" 

    }'::jsonb),
    (66, 8, 'from_date',          'From Date',         'DATE',     NULL,  1, FALSE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (67, 8, 'to_date',            'To Date',           'DATE',     NULL,  2, FALSE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (68, 8, 'ref_doc_type_id',    'Ref. Doc Type',     'INT',      NULL,  3, FALSE, '=',  '{
    "component": "drop-down",
"options": [
  {"id": 2, "value": "Direct"},
  {"id": 3, "value": "Purchase Request"},
  {"id": 4, "value": "Quotation"}
]
    }'::jsonb),
    (69, 8, 'status_id',          'Status',         'INT',      NULL,  10, FALSE, '=',  '{
    "component": "drop-down",
"options": [
  {"id": 5, "value": "Expired"},
  {"id": 9, "value": "Authorized"},
  {"id": 10, "value": "In Progress"},
  {"id": 11, "value": "Completed"}
]
    }'::jsonb),
    (70, 8, 'po_no',              'PO No.',             'TEXT',     NULL, 5, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (71, 8, 'erp_po_no',          'Erp PO No.',          'TEXT',     NULL, 6, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (72, 8, 'show_all',           'Show All',          'BOOL',     NULL, 13, FALSE, '=',  '{"type":"checkbox"}'::jsonb),
    (73, 8, 'vendor_name',        'Vendor Name',       'TEXT',     NULL, 11, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),

    --Report 9 Purchase Register (purchase.mis_func_purchase_register)
   
    (74, 9, 'company_ids',        'Companies',        'INT',      NULL,  4, TRUE, 'IN', '{"component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias", "isMultiselect": true }'::jsonb),
    (75, 9, 'division',           'Division Name',         'TEXT',     NULL,  10, FALSE, '=',  '{"api": "/api/master/divisions/get", "accessorKey": "divisionName", "component": "auto-suggest","columnDef": [{ "id": "divisionName", "name": "divisionName", "header": "Division Name"},{"id": "code", "name": "code", "header": "Division Code"} ]}'::jsonb),
    (76, 9, 'department',         'Department Name',       'TEXT',     NULL,  11, FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (77, 9, 'from_amount',        'From Amount',      'DECIMAL',  NULL,  7, FALSE, '=',  '{ "type": "NUMERIC","precision": "2", "maxlength": "17" }'::jsonb),
    (78, 9, 'to_amount',          'To Amount',        'DECIMAL',  NULL,  8, FALSE, '=',  '{ "type": "NUMERIC","precision": "2", "maxlength": "17" }'::jsonb),
    (79, 9, 'from_date',          'From Date',        'DATE',     NULL,  1, TRUE, '>=', '{"type": "DATE"}'::jsonb),
    (80, 9, 'to_date',            'To Date',          'DATE',     NULL,  2, TRUE, '<=', '{"type": "DATE"}'::jsonb),
    (81, 9, 'ref_doc_type_id',    'Ref Doc Type',    'INT',      NULL,   3, FALSE, '=',  '{"component": "drop-down", "options": [{"id": 2, "value": "Direct"},{"id": 3, "value": "Purchase Request"},{"id": 4, "value": "Quotation"}]}'::jsonb),
    (82, 9, 'status_id',          'Status',           'INT',      NULL,  9, FALSE, '=',  '{"component": "drop-down","options": [  {"id": 9, "value": "Authorized"}, {"id": 10, "value": "In Progress"}, {"id": 11, "value": "Completed"}]}'::jsonb),
    (83, 9, 'po_no',              'PO No.',           'TEXT',     NULL, 5, FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (84, 9, 'erp_po_no',          'Erp PO No.',       'TEXT',     NULL, 6, FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (85, 9, 'show_all',           'Show All',         'BOOL',     NULL, 16, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (86, 9, 'vendor_name',        'Vendor Name',      'TEXT',     NULL, 14, FALSE, '=',  '{"type": "TEXT"}'::jsonb),
    (87, 9, 'item_name',          'Item Name',        'TEXT',     NULL, 12, FALSE, '=',  '{"type": "TEXT", "isHidden" : true}'::jsonb),
    (88, 9, 'item_id',            'Item',        'INT',      NULL, 13, FALSE, '=',  '{"api": "/api/master/items/get","accessorKey": "itemName", "component": "auto-suggest", "columnDef": [{ "id": "itemName", "name": "itemName","header": "Item Name" }, { "id": "itemCode", "name": "itemCode", "header": "Item Code" } ]}'::jsonb),
    (89, 9, 'vendor_location_id', 'Vendor Location',  'INT',      NULL, 15, FALSE, '=',  '{"api": "/api/master/vendor-master/locations/Get","accessorKey": "address", "component": "auto-suggest","columnDef": [{"id": "address", "name": "address","header": "Address"},{"id": "code", "name": "code","header": "Code"}],"isVisible": false}'::jsonb),

    -- Report 10 Vendor List (masterdata.mis_func_vendor_list)
    (90, 10, 'type_no',            'Vendor Type',      'INT',      NULL,  1, TRUE, '=',  '{"component": "drop-down", "options": [{"id": 1, "value": "ALL"}, {"id": 2, "value": "Approved"}, {"id": 3, "value": "Not Approved"}], "accessorKey": "value"}'::jsonb),


    -- Report 11 Vendor Wise Procurement (purchase.mis_func_vendor_wise_procurement)
    (91, 11, 'company_ids',        'Comapnies',        'INT',      NULL,  4, TRUE, 'IN', '{"component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias", "isMultiselect": true}'::jsonb),
    (92, 11, 'from_date',          'FromDate',         'DATE',     NULL,  1, TRUE, '>=', '{"type": "DATE"}'::jsonb),
    (93, 11, 'to_date',            'ToDate',           'DATE',     NULL,  2, TRUE, '<=', '{"type": "DATE"}'::jsonb),
    (94, 11, 'item_id',            'Item',             'INT',      NULL,  3, FALSE, '=',  '{"component": "combo-box", "api": "/api/master/items/get", "accessorKey": "itemName"}'::jsonb),
    (95, 11, 'vendor_id',          'Vendor',           'INT',      NULL,  5, FALSE, '=',  '{"component": "combo-box", "api": "/api/master/vendor-master/Get", "accessorKey": "vendorName"}'::jsonb),
    (96, 11, 'group_id',           'Group',            'INT',      NULL,  6, FALSE, '=',  '{"component": "combo-box", "api": "/api/master/groups/get", "accessorKey": "groupName"}'::jsonb),

    -- Report 12 Passive Vendors (purchase.mis_func_passive_vendors)
    (99, 12, 'minimum_rfq_count',  'Minimum RFQ Count',  'INT',      NULL,  3, FALSE, '=',  '{"type": "numeric", "alignment": "right", "maxLength": 4}'::jsonb),
    (100, 12, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (101, 12, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (102, 12, 'response_limit',     'Response Limit Percentage',    'decimal',  NULL,  4, TRUE, '=',  '{"type": "numeric", "alignment": "right", "maxLength": 4}'::jsonb),


    --Report 13 RFQ To PO (purchase.mis_func_rfq_to_po_progress_flow)
    (103, 13, 'user_id',            'User',           'INT',      NULL,  6,  FALSE, '=',  '{ "type": "numeric", "component": "auto-suggest", "api": "/api/security/users/get", "accessorKey": "username",
        "columnDef": [
          {
            "id": "username",
            "name": "username",
            "header": "Username"
          },
          {
            "id": "displayName",
            "name": "displayName",
            "header": "Display Name"
          }
        ]}'::jsonb),
    (104, 13, 'from_date',          'From Date',         'DATE',     NULL,  1,  TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (105, 13, 'to_date',            'To Date',           'DATE',     NULL,  2,  TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (106, 13, 'company_ids',        'Companies',       'INT',      NULL,  4, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (107, 13, 'rfq_id',             'RFQ',            'TEXT',     NULL,  3, FALSE, '=',  '{
    "type": "numric",
"component": "combo-box",
     "api": "/api/purchase/request-for-quotations/get",
     "accessorKey": "docNoYearly" }'::jsonb),
    (108, 13, 'item_details',       'Item Name',      'TEXT',     NULL,  5, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (109, 13, 'status_id',          'Status',         'INT',      NULL,  7, FALSE, '=',  '{
"component": "drop-down",
"options": [
  {"id": 5, "value": "Expired"},
  {"id": 9, "value": "Authorized"},
  {"id": 10, "value": "In Progress"},
  {"id": 11, "value": "Completed"}
]
}'::jsonb),

    -- Report 14 User Performance Company Wise (security.mis_func_user_performance_company_wise)
    (110, 14, 'from_date',          'From Date',         'DATE',     NULL,  1,  TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (111, 14, 'to_date',            'To Date',           'DATE',     NULL,  2,  TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (112, 14, 'user_ids',           'Users',          'INT',      NULL,  3, TRUE, 'IN', '{"type": "numeric", "component": "combo-box", "isMultiselect": true, "api": "/api/security/users/get", "accessorKey": "username",
        "columnDef": [
          {
            "id": "username",
            "name": "username",
            "header": "Username"
          },
          {
            "id": "displayName",
            "name": "displayName",
            "header": "Display Name"
          }
        ]}'::jsonb),

    -- Report 15 MIS User Performance (security.mis_func_user_performance)
    (113, 15, 'from_date',          'From Date',         'DATE',     NULL,  1,  TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (114, 15, 'to_date',            'To Date',           'DATE',     NULL,  2,  TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (115, 15, 'user_ids',           'Users',          'INT',      NULL,  3, TRUE, 'IN', '{
   "component": "combo-box",
    "api": "/api/security/users/get",
    "accessorKey": "username",
    "isMultiselect": true,
    "columnDef": [
    {
      "id": "displayName",
      "name": "displayName",
      "header": "Display Name"
    },
    {
      "id": "username",
      "name": "username",
      "header": "Username"
    }
  ]
    }'::jsonb),

    -- Report 16 PO Timeline (purchase.mis_func_po_timeline)
    (116, 16, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (117, 16, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (118, 16, 'po_no',              'PO No.',             'TEXT',     NULL,  5, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (119, 16, 'erp_po_no',          'Erp P0 No.',          'TEXT',     NULL,  6, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (120, 16, 'vendor_name',        'Vendor Name',       'TEXT',     NULL,  3, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (121, 16, 'item_name',          'Item Name',         'TEXT',     NULL,  8, FALSE, '=',  '{
  "type": "TEXT"
}'::jsonb),
    (122, 16, 'user_id', 'Users', 'INT', NULL, 7, FALSE, '=',
'{
  "component": "auto-suggest",
  "api": "/api/security/users/get",
  "accessorKey": "username",
  "columnDef": [
    {
      "id": "username",
      "name": "username",
      "header": "Username"
    },
    {
      "id": "displayName",
      "name": "displayName",
      "header": "Display Name"
    }
  ]
}'::jsonb),
    (123, 16, 'company_ids',        'Companies',       'INT',      NULL,  4, FALSE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),

    -- Report 17 Authorization Review (purchase.mis_func_po_authorization_review) — filters only; columns from function JSON
    (124, 17, 'company_ids', 'Companies', 'INT', NULL, 4, TRUE, 'IN', '{"component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias","isMultiselect": true}'::jsonb),
    (125, 17, 'from_date', 'From Date', 'DATE', NULL, 1, TRUE, '>=', '{"type": "DATE"}'::jsonb),
    (126, 17, 'to_date', 'To Date', 'DATE', NULL, 2, TRUE, '<=', '{"type": "DATE"}'::jsonb),
    (127, 17, 'division', 'Division Name', 'TEXT', NULL, 9, FALSE, '=', '{"type": "TEXT"}'::jsonb),
    (128, 17, 'department', 'Department Name', 'TEXT', NULL, 10, FALSE, '=', '{"type": "TEXT"}'::jsonb),
    (129, 17, 'portal_po_no', 'PO No.', 'TEXT', NULL, 5, FALSE, '=', '{"type": "TEXT"}'::jsonb),
    (130, 17, 'erp_po_no', 'Erp PO No.', 'TEXT', NULL, 6, FALSE, '=', '{"type": "TEXT"}'::jsonb),
    (131, 17, 'vendor_name', 'Vendor Name', 'TEXT', NULL, 11, FALSE, '=', '{"type": "TEXT"}'::jsonb),
    (132, 17, 'item', 'Item Name', 'TEXT', NULL, 8, FALSE, '=', '{"type": "TEXT"}'::jsonb),
    (133, 17, 'ref_doc_type_id', 'Source Document', 'SMALLINT', NULL, 3, FALSE, '=', '{"component": "combo-box","options": [{"id": 3, "value": "Purchase Request"}, {"id": 4, "value": "Quotation"}], "accessorKey": "value"}'::jsonb),
    (134, 17, 'show_all', 'Show All', 'BOOLEAN', NULL, 14, FALSE, '=', '{"component": "checkbox"}'::jsonb),
    (135, 17, 'user_id', 'User', 'INT', NULL, 12, FALSE, '=', '{"component": "combo-box", "api": "/api/security/users/get", "accessorKey": "username","columnDef": [{ "id": "displayName", "name": "displayName", "header": "Display Name"}, { "id": "username", "name": "username", "header": "Username"} ]}'::jsonb),
    (136, 17, 'status_id', 'Status', 'SMALLINT', NULL, 7, FALSE, '=', '{"component" : "combo-box", "isMultiselect": false, "options": [{"id": "11", "value": "Completed"}, {"id": "5", "value": "Expired"}, {"id": "10", "value": "Inprogress"}, {"id": "3", "value": "Pending"}], "accessorKey": "value"}'::jsonb),
    (137, 17, 'review_status_id', 'Review Status', 'SMALLINT', NULL, 13, FALSE, '=', '{"component" : "combo-box", "isMultiselect": false, "options": [{"id": 11, "value": "Completed"}, {"id": 3, "value": "Pending"}], "accessorKey": "value"}'::jsonb),

    -- Report 18 PO L2 Report (purchase.mis_func_po_l2_report)
    (138, 18, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{ "type": "DATE" }'::jsonb),
    (139, 18, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{ "type": "DATE" }'::jsonb),
    (140, 18, 'po_no',              'PO No.',             'TEXT',     NULL,  5, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (141, 18, 'erp_po_no',          'Erp Po No.',         'TEXT',     NULL,  6, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (142, 18, 'vendor_name',        'Vendor Name',       'TEXT',     NULL,  3, FALSE, '=',  '{ "type": "TEXT" }'::jsonb),
    (143, 18, 'item_name',          'Item Name',         'TEXT',     NULL,  8, FALSE, '=',  '{"type": "TEXT" }'::jsonb),
    (144, 18, 'user_id',            'User',              'INT',      NULL,  7, FALSE, '=',  '{ "type": "numeric", "component": "auto-suggest", "api": "/api/security/users/get", "accessorKey": "username", "columnDef": [ { "id": "username", "name": "username", "header": "Username" }, { "id": "displayName", "name": "displayName", "header": "Display Name" } ]}'::jsonb),
    (145, 18, 'company_ids',        'Companies',         'INT',      NULL,  4, TRUE, 'IN', '{ "component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias", "isMultiselect": true }'::jsonb),

    -- Report 19 Item Group Wise Purchase Summary (purchase.mis_func_item_group_wise_purchase_summary)
    (146, 19, 'company_ids',        'Companies',       'INT',      NULL,  1, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (147, 19, 'from_date',          'From Date',         'DATE',     NULL,  2, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (148, 19, 'to_date',            'To Date',           'DATE',     NULL,  3, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (149, 19, 'group_id',           'Group',          'INT',      NULL,  4, FALSE, '=',  '{ "isVisible": "FALSE", "type": "numeric", "component": "auto-suggest", "api": "/api/master/groups/get", "accessorKey": "groupName"}'::jsonb),

    -- Report 20 Item Purchase Summary Month Wise (purchase.mis_func_item_purchase_summary_month_wise)
     (150, 20, 'company_ids',        'Company',       'INT',      NULL,  3, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (151, 20, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (152, 20, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (153, 20, 'item_id',            'Item',           'INT',      NULL,  4, TRUE, '=',  '{
    "component": "auto-suggest",
    "api": "/api/master/items/get",
    "accessorKey": "itemName",
    "columnDef": [
    {
      "id": "itemName",
      "name": "itemName",
      "header": "Item Name"
    },
    {
      "id": "itemCode",
      "name": "itemCode",
      "header": "Item Code"
    }
    ]
    }'::jsonb),


    -- Report 21 Vendor Summary Month Wise (masterdata.mis_func_vendor_summary_month_wise)
    (154, 21, 'company_ids',        'Companies',       'INT',      NULL,  3, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (155, 21, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (156, 21, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (157, 21, 'vendor_id',          'Vendor',         'INT',      NULL,  4, TRUE, '=',  '{"component": "combo-box", "api": "/api/master/vendor-master/Get", "accessorKey": "vendorName"}'::jsonb),

    -- Report 22 Item Group Purchase Summary Vendor Wise (purchase.mis_func_item_group_purchase_summary_vendor_wise)
    (158, 22, 'company_ids',        'Companies',       'INT',      NULL,  3, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (159, 22, 'from_date',          'From Date',         'DATE',     NULL,  1, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (160, 22, 'to_date',            'To Date',           'DATE',     NULL,  2, TRUE, '<=', '{
  "type": "DATE"
}'::jsonb),
    (161, 22, 'item_id',            'Item',           'INT',      NULL,  4, FALSE, '=',  '{ "type": "numeric", "component": "auto-suggest", "api": "/api/master/items/get", "accessorKey": "itemName"}'::jsonb),
    (162, 22, 'group_id',           'Group',          'INT',      NULL,  5, FALSE, '=',  '{ "type": "numeric", "component": "auto-suggest", "api": "/api/master/item-group-master/get", "accessorKey": "groupName"}'::jsonb),

    -- Report 23 Item Group Wise Detail (purchase.mis_func_item_group_wise_detail)
    (163, 23, 'company_ids',        'Companies',       'INT',      NULL,  1, TRUE, 'IN', '
    {
        "component": "combo-box",
        "api": "/api/master/companies/get",
        "accessorKey": "alias",
        "isMultiselect": true
    }
'::jsonb),
    (164, 23, 'from_date',          'From Date',         'DATE',     NULL,  2, TRUE, '>=', '{
  "type": "DATE"
}'::jsonb),
    (165, 23, 'to_date',            'To Date',           'DATE',     NULL,  3, TRUE, '<=', '{"type": "DATE"}'::jsonb),
    (166, 23, 'item_id',            'Item',           'INT',      NULL,  4, FALSE, '=',  '{"component": "combo-box", "api": "/api/master/items/get", "accessorKey": "itemName"}'::jsonb),
    (167, 23, 'vendor_id',          'Vendor',         'INT',      NULL,  5, FALSE, '=',  '{"component": "combo-box", "api": "/api/master/vendor-master/Get", "accessorKey": "vendorName"}'::jsonb),
    (168, 23, 'group_id',           'Group',          'INT',      NULL,  6, FALSE, '=',  '{"component": "combo-box", "api": "/api/master/groups/get", "accessorKey": "groupName"}'::jsonb),
    (169, 23, 'for_drilldown',      'Drilldown',      'BOOL',     NULL,  7, FALSE, '=',  '{}'::jsonb),

    -- Report 24 Indent Item Ageing Detail (inventory.func_indent_item_ageing_detail)
    (170, 24, 'from_date',                'From Date',                'DATE', NULL, 1,  TRUE,  '>=', '{"type": "DATE"}'::jsonb),
    (171, 24, 'to_date',                  'To Date',                  'DATE', NULL, 2,  TRUE,  '<=', '{"type": "DATE"}'::jsonb),
    (172, 24, 'company_id',               'Company',                 'INT',  NULL, 3,  FALSE, '=',  '{"component": "combo-box", "api": "/api/master/companies/get", "accessorKey": "alias"}'::jsonb),
    (173, 24, 'division_id',              'Division',                'INT',  NULL, 4,  FALSE, '=',  '{"component": "combo-box", "api": "/api/master/divisions/get", "accessorKey": "code"}'::jsonb),
    (174, 24, 'show_all',                 'Show All',                 'BOOL', NULL, 5,  FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (175, 24, 'show_completed',           'Show Completed',           'BOOL', NULL, 6,  FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (176, 24, 'show_pending',             'Show Pending',             'BOOL', NULL, 7,  FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (177, 24, 'show_cancelled_n_expired', 'Show Cancelled & Expired', 'BOOL', NULL, 8,  FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (178, 24, 'show_inprogress',          'Show In Progress',          'BOOL', NULL, 9,  FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (179, 24, 'show_0to7',                '0-7 Days',                 'BOOL', NULL, 10, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (180, 24, 'show_8to15',               '8-15 Days',                'BOOL', NULL, 11, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (181, 24, 'show_16to30',              '16-30 Days',               'BOOL', NULL, 12, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (182, 24, 'show_31to60',              '31-60 Days',               'BOOL', NULL, 13, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (183, 24, 'show_61to90',              '61-90 Days',               'BOOL', NULL, 14, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (184, 24, 'show_91to120',             '91-120 Days',              'BOOL', NULL, 15, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (185, 24, 'show_121to180',            '121-180 Days',             'BOOL', NULL, 16, FALSE, '=',  '{"component": "checkbox"}'::jsonb),
    (186, 24, 'show_181nplus',            '>181 Days',                'BOOL', NULL, 17, FALSE, '=',  '{"component": "checkbox"}'::jsonb)
ON CONFLICT (id)
DO UPDATE
SET
    report_id = EXCLUDED.report_id,
    name = EXCLUDED.name,
    caption = EXCLUDED.caption,
    field_type = EXCLUDED.field_type,
    default_value = EXCLUDED.default_value,
    seq_no = EXCLUDED.seq_no,
    is_mandatory = EXCLUDED.is_mandatory,
    operator = EXCLUDED.operator,
    config_json = EXCLUDED.config_json;