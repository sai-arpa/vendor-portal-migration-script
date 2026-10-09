select count(*) from sqlserver_fdw.mvendorcard mm  --3568
where mm.gvendortypeno = 6

select count(*) from masterdata.vendor_master vm-- 2618
where vm.bp_type_id=1


select count(*) from masterdata.vendor_master_location_Detail vld --4174
inner join masterdata.vendor_master vm on vm.id=vld.vendor_id where vm.bp_type_id =1 

select count(*) from masterdata.vendor_master_location_Detail vld --4006
inner join masterdata.vendor_master vm on vm.id=vld.vendor_id where vm.bp_type_id =1 and vld.status_id =1



select count(*) from sqlserver_fdw.mvendorcard vm --4174
inner join sqlserver_fdw.mvendorlocationdetail vld on vm.vendorno =vld.vendorNo where vm.gvendortypeno =6

select count(*) from sqlserver_fdw.mvendorcard vm --4006
inner join sqlserver_fdw.mvendorlocationdetail vld on vm.vendorno =vld.vendorNo where vm.gvendortypeno =6
and vld.inactive is false


