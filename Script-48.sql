select distinct status_id from purchase.purchase_order_item_detail poid 

select pom.id, pom.document_status_id  from purchase.purchase_order_item_detail poid
left join purchase.purchase_order_main pom 
on pom.id=poid.po_id 
where poid.status_id =14 and pom.document_status_id <> 20

