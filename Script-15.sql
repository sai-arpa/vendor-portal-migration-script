select * from masterdata.doc_type_master dtm 

update purchase.cs_main 
set doc_type_id=2

select distinct doc_type_id from inventory.purchase_request_main

select doc_no_yearly  from inventory.purchase_request_main