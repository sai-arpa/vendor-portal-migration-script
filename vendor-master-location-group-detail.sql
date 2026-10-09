CREATE FOREIGN TABLE if not exists sqlserver_fdw.mvendoritemgroupdetail
(
    VendorItemGroupNo int,
    VendorNo int,
    GroupNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mVendorItemGroupDetail'
);


INSERT INTO masterdata.vendor_location_item_group_detail
(
    id,
    vendor_location_id,
    item_group_id
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            g.VendorItemGroupNo,
            vl.id
    ) AS id,
    vl.id,
    g.GroupNo
FROM sqlserver_fdw.mvendoritemgroupdetail g
INNER JOIN masterdata.vendor_master_location_detail vl
    ON vl.vendor_id = g.VendorNo;