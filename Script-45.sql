select count(*) from purchase.pur_rfq_item_detail prid 
inner join purchase.pur_rfq_main prm 
on prm.id = prid.rfq_id 

select count(*) from sqlserver_fdw.rfqitemdetail rfd
inner join sqlserver_fdw.rfqmain r 
on r.rfqno = rfd.rfqno 