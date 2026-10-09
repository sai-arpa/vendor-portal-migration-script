CREATE FOREIGN TABLE if not exists sqlserver_fdw.mvendorregistrationgroupdetail
(
    VendorRegGroupNo int,
    VendorRegNo int,
    GroupNo smallint
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'masterdata', table_name 'mVendorRegistrationGroupDetail');


INSERT INTO masterdata.vendor_reg_location_item_group_detail
(
    vendor_reg_location_id,
    item_group_id
)
SELECT DISTINCT
    l.id,
    g.GroupNo
FROM sqlserver_fdw.mvendorregistrationgroupdetail g
INNER JOIN masterdata.vendor_reg_location_detail l
    ON l.vendor_reg_id = g.VendorRegNo;