select * from [Security].LoginFailHistory order by logindate desc
select * from [Security].loginHistory order by logindate desc


select * from purchase.POAmendmentRejectionHistory
select count(distinct pm.POAmendmentNo) from purchase.POAmendmentRejectionHistory pm


select count(*) from purchase.POAmendmentMain pm where pm.DocumentStatusNo =40
sleect 