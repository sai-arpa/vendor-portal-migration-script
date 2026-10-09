select * from purchase.pur_rfq_main prm where prm.id=58906

select * from purchase.pur_rfq_item_detail prm where prm.rfq_id=58906

select * from purchase.pur_rfq_pr_detail prm where prm.rfq_id=58906

select * from purchase.pur_rfq_item_detail prid where prid.tech_specification = 'DUMMY RFQ ITEM DETAIL FOR AUCTION QUOTATION MIGRATION'

select * from purchase.pur_rfq_vendor_detail where rfq_id=58906
select * from purchase.quotation_item_detail qid where qid.rfq_item_detail_id = 275703

update purchase.quotation_main 
set rfq_vendor_detail_id = null
where rfq_vendor_detail_id = 229513

select * from purchase.quotation_main qm where qm.rfq_vendor_detail_id = 229513