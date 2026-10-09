UPDATE purchase.purchase_order_main AS po
SET created_by_id = pom.createdBy
FROM sqlserver_fdw.poamendmentmain AS pom
WHERE po.id = pom.poamendmentNo
  AND pom.createdBy IS NOT NULL
  AND pom.createdBy <> 0;


--UPDATE purchase.quotation_main AS po
--SET created_by_id = pom.createdBy
--FROM sqlserver_fdw.revisedquotationmain AS pom
--WHERE po.id = pom.revisedquotationno 
--  AND pom.createdBy IS NOT NULL
--  AND pom.createdBy <> 0;

SELECT DISTINCT authorized_by_id 
FROM purchase.purchase_order_main
WHERE doc_date >= '2026-01-01' and doc_date <= '2026-06-16';