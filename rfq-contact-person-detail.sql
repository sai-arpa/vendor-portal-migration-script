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
    CASE 
        WHEN NULLIF(TRIM(vcp.ContactNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(vcp.ContactNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(vcp.ContactNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END
FROM sqlserver_fdw.rfqvendordetail rvd
LEFT JOIN masterdata.vendor_location_contact_person_detail vcp
    ON vcp.id = rvd.VendorContactNo;