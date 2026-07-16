UPDATE purchase.purchase_order_main pom
SET expenditure_type_id = spm.indenttypeno
FROM sqlserver_fdw.poamendmentmain spm
WHERE pom.id = spm.poamendmentno;