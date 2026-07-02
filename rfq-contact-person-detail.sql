INSERT INTO purchase.pur_rfq_vendor_contact_person_detail
(
    id,
    rfq_id,
    rfq_vendor_detail_id,
    vendor_location_contact_person_id,
    contact_name,
    contact_email,
    contact_no,
    contact_no_country_id
)
OVERRIDING SYSTEM VALUE
SELECT
    rvd.RFQVendorDetailNo,
    rvd.RFQNo,
    rvd.RFQVendorDetailNo,
    rvd.VendorContactNo,
    vcp.contact_person_name,
    vcp.email,
    vcp.contact_no,
    case
    	when vcp.contact_no is not null
    		then (select id from masterdata.country_master where lower(country_name)=lower('india'))
    	else null
    end as contact_no_country_id
FROM sqlserver_fdw.rfqvendordetail rvd
LEFT JOIN masterdata.vendor_location_contact_person_detail vcp
    ON vcp.id = rvd.VendorContactNo;