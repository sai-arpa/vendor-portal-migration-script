select count(*) from sqlserver_fdw.
select count(*) from masterdata.vendor_master vm-- 2618
where vm.bp_type_id=1

select count(*) from masterdata.vendor_master_location_Detail vld --2872
inner join masterdata.vendor_master vm on vm.id=vld.vendor_id where vm.bp_type_id =1
