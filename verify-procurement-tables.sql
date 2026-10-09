-- Verification Script for RFQ, Quotation, and Comparative Statement Migration

WITH verification_data AS (
    -- ==============================================
    -- 1. RFQ Tables
    -- ==============================================
    
    -- RFQ Main
    SELECT
        'RFQ Main' AS table_name,
        'Row Count' AS metric,
        (SELECT COUNT(1) FROM sqlserver_fdw.rfqmain) AS source_value,
        (SELECT COUNT(1) FROM purchase.pur_rfq_main where ref_doc_type_id <> 9) AS destination_value
    UNION ALL
    
    -- RFQ Item Detail
    SELECT
        'RFQ Item Detail',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.rfqitemdetail),
        (SELECT COUNT(1) FROM purchase.pur_rfq_item_detail prid left join purchase.pur_rfq_main prm on prm.id=prid.rfq_id where prm.ref_doc_type_id <> 9) 
    UNION ALL
    SELECT
        'RFQ Item Detail',
        'Sum of qty',
        (SELECT COALESCE(SUM(Qty), 0) FROM sqlserver_fdw.rfqitemdetail),
        (SELECT COALESCE(SUM(prid.qty), 0) FROM purchase.pur_rfq_item_detail prid left join purchase.pur_rfq_main prm on prm.id=prid.rfq_id where prm.ref_doc_type_id <> 9)
    UNION ALL
    
    -- RFQ PR Detail
    SELECT
        'RFQ PR Detail',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.rfqindentdetail),
        (SELECT COUNT(1) FROM purchase.pur_rfq_pr_detail)
    UNION ALL
    SELECT
        'RFQ PR Detail',
        'Sum of rfq_qty',
        (SELECT COALESCE(SUM(RFQQty), 0) FROM sqlserver_fdw.rfqindentdetail),
        (SELECT COALESCE(SUM(rfq_qty), 0) FROM purchase.pur_rfq_pr_detail)
    UNION ALL

    -- ==============================================
    -- 2. Quotation Tables
    -- ==============================================
    
    -- Quotation Main
    SELECT
        'Quotation Main',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.revisedquotationmain),
        (SELECT COUNT(1) FROM purchase.quotation_main)
    UNION ALL
    SELECT
        'Quotation Main',
        'Sum of basic_amount',
        (SELECT COALESCE(SUM(BasicAmount), 0) FROM sqlserver_fdw.revisedquotationmain),
        (SELECT COALESCE(SUM(basic_amount), 0) FROM purchase.quotation_main)
    UNION ALL
    SELECT
        'Quotation Main',
        'Sum of tax_amount',
        (SELECT COALESCE(SUM(TaxAmount), 0) FROM sqlserver_fdw.revisedquotationmain),
        (SELECT COALESCE(SUM(tax_amount), 0) FROM purchase.quotation_main)
    UNION ALL
    SELECT
        'Quotation Main',
        'Sum of net_amount',
        (SELECT COALESCE(SUM(NetAmount), 0) FROM sqlserver_fdw.revisedquotationmain),
        (SELECT COALESCE(SUM(net_amount), 0) FROM purchase.quotation_main)
    UNION ALL
    
    -- Quotation Item Detail
    SELECT
        'Quotation Item Detail',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.revisedquotationitemdetail),
        (SELECT COUNT(1) FROM purchase.quotation_item_detail)
    UNION ALL
    SELECT
        'Quotation Item Detail',
        'Sum of qty',
        (SELECT COALESCE(SUM(Quantity), 0) FROM sqlserver_fdw.revisedquotationitemdetail),
        (SELECT COALESCE(SUM(qty), 0) FROM purchase.quotation_item_detail)
    UNION ALL
    SELECT
        'Quotation Item Detail',
        'Sum of rate',
        (SELECT COALESCE(SUM(Rate), 0) FROM sqlserver_fdw.revisedquotationitemdetail),
        (SELECT COALESCE(SUM(rate), 0) FROM purchase.quotation_item_detail)
    UNION ALL
    SELECT
        'Quotation Item Detail',
        'Sum of amount',
        (SELECT COALESCE(SUM(TotalAmount), 0) FROM sqlserver_fdw.revisedquotationitemdetail),
        (SELECT COALESCE(SUM(basic_amount), 0) FROM purchase.quotation_item_detail)
    UNION ALL

    -- ==============================================
    -- 3. Comparative Statement (CS) Tables
    -- ==============================================
    
    -- CS Main
    SELECT
        'CS Main',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.csmain),
        (SELECT COUNT(1) FROM purchase.cs_main)
    UNION ALL
    
    -- CS Quotation Detail
    SELECT
        'CS Quotation Detail',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.csquotationdetail WHERE IsSelected IS TRUE AND RevisedQuotationNo IS NOT NULL),
        (SELECT COUNT(1) FROM purchase.cs_quotation_detail)
    UNION ALL
    SELECT
        'CS Quotation Detail',
        'Sum of qty',
        (SELECT COALESCE(SUM(Quantity), 0) FROM sqlserver_fdw.csquotationdetail WHERE IsSelected IS TRUE AND RevisedQuotationNo IS NOT NULL),
        (SELECT COALESCE(SUM(qty), 0) FROM purchase.cs_quotation_detail)
    UNION ALL
    
    -- CS PR Detail
    SELECT
        'CS PR Detail',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.csindentdetail WHERE RevisedQuotationNo IS NOT NULL),
        (SELECT COUNT(1) FROM purchase.cs_pr_detail)
    UNION ALL
    SELECT
        'CS PR Detail',
        'Sum of qty',
        (SELECT COALESCE(SUM(Qty), 0) FROM sqlserver_fdw.csindentdetail WHERE RevisedQuotationNo IS NOT NULL),
        (SELECT COALESCE(SUM(qty), 0) FROM purchase.cs_pr_detail)
    UNION ALL
    
    -- CS Rank Detail
    SELECT
        'CS Rank Detail',
        'Row Count',
        (SELECT COUNT(1) FROM sqlserver_fdw.csl1detail WHERE RevisedQuotationNo IS NOT NULL),
        (SELECT COUNT(1) FROM purchase.cs_rank_detail)
    UNION ALL
    SELECT
        'CS Rank Detail',
        'Sum of rate',
        (SELECT COALESCE(SUM(Rate), 0) FROM sqlserver_fdw.csl1detail WHERE RevisedQuotationNo IS NOT NULL),
        (SELECT COALESCE(SUM(rate), 0) FROM purchase.cs_rank_detail)
)
SELECT 
    table_name AS "Table Name",
    metric AS "Metric",
    source_value AS "Source Value (SQL Server)",
    destination_value AS "Destination Value (PostgreSQL)",
    CASE 
        WHEN source_value = destination_value THEN 'MATCH'
        WHEN ABS(source_value - destination_value) < 0.01 THEN 'MATCH (Rounding)'
        ELSE 'MISMATCH'
    END AS "Status"
FROM verification_data
ORDER BY 
    CASE 
        WHEN table_name LIKE 'RFQ%' THEN 1
        WHEN table_name LIKE 'Quotation%' THEN 2
        WHEN table_name LIKE 'CS%' THEN 3
        ELSE 4
    END,
    table_name,
    metric;

    
    
    
--    
--    
--select count(*) FROM sqlserver_fdw.rfqindentdetail rid
--inner JOIN purchase.pur_rfq_item_detail rfqid
--    ON rfqid.rfq_id = rid.RFQNo
--   AND rfqid.item_id = rid.ItemNo
--   AND COALESCE(rfqid.make_id, 0) = COALESCE(rid.RFQMakeNo, 0)
--   
--select * FROM sqlserver_fdw.rfqindentdetail rid
--left JOIN inventory.purchase_request_item_detail prid
--    ON prid.pur_req_id = rid.IndentNo
--   AND prid.line_no = rid.IndentItemLineNo
--   AND prid.item_id = rid.ItemNo
--where prid.id is null
--
--2584, 8831, 6
--
--select * from inventory.purchase_request_item_detail prid
--where prid.pur_req_id = 2584


