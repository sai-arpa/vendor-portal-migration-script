---------------------------------------------------- Migrate vendor master and vendor location from e_ tables---------------------------------------------------
INSERT INTO masterdata.vendor_master (
    code,
    vendor_name,
    legal_name,
    bp_type_id,
    rating,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
SELECT
    v.code,
    v.vendor_name,
    v.vendor_name AS legal_name,
    v.vp_bp_type_id AS bp_type_id,
    NULL AS rating,
    1 AS created_by_id,       -- Change as required
    v.created_date,
    NULL AS modified_by_id,
    v.modified_date
FROM erpmaster.e_vendor_master v
WHERE v.inactive = false
  AND EXISTS (
      SELECT 1
      FROM erpmaster.e_vendor_location_master vl
      WHERE vl.e_vendor_id = v.id
        AND vl.inactive = false
  );





-- 2. Migrate vendor locations
INSERT INTO masterdata.vendor_master_location_detail  (
    vendor_id,
    code,
    address_line_1,
    address_line_2,
    address_line_3,
    full_address,
    contact_no,
    contact_no_country_id,
    email,
    website,
    country_id,
    state_id,
    city_id,
    pincode,
    vendor_category_id,
    pan_no,
    gst_reg_type_id,
    gstin_no,
    region_id,
    business_type_id,
    business_description,
    msme_type_id,
    msme_no,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
SELECT
    vm.id AS vendor_id,
    vl.code,
    coalesce(vl.address1, 'address 1') AS address_line_1,
    vl.address2 AS address_line_2,
    vl.address3 AS address_line_3,
    -- Build full address
    CONCAT_WS(
        ', ',
        NULLIF(vl.address1, ''),
        NULLIF(vl.address2, ''),
        NULLIF(vl.address3, '')
    ) AS full_address,
    vl.contact_no,
    NULL AS contact_no_country_id,
    coalesce(vl.email, 'dummyVendorLocMail123@gmail.com'),
    vl.website,
    vl.e_country_id AS country_id,
    vl.e_state_id AS state_id,
    vl.e_city_id AS city_id,
    NULL AS pincode,
    NULL AS vendor_category_id,
    vl.pan_no,
    CASE
	    WHEN NULLIF(TRIM(vl.gstin_no), '') IS NOT NULL THEN 1
    	ELSE 5
	END,
    vl.gstin_no,
    NULL AS region_id,
    NULL AS business_type_id,
    NULL AS business_description,
    2 AS msme_type_id,
    NULL AS msme_no,
    1 AS created_by_id,        -- Change as required
    vl.created_date,
    NULL AS modified_by_id,
    vl.modified_date,
    1 AS status_id,
    NULL AS status_remarks
FROM erpmaster.e_vendor_location_master vl
JOIN masterdata.vendor_master vm
    ON vm.code = (
        SELECT v.code
        FROM erpmaster.e_vendor_master v
        WHERE v.id = vl.e_vendor_id
    )
WHERE vl.inactive = false;



----------------------------- Mapping Update ------------------------------

UPDATE erpmaster.e_vendor_master ev
SET vp_vendor_id = vm.id
FROM masterdata.vendor_master vm
WHERE vm.code = ev.code


UPDATE erpmaster.e_vendor_location_master evl
SET vp_vendor_location_id = vml.id
FROM erpmaster.e_vendor_master ev
JOIN masterdata.vendor_master vm
    ON vm.code = ev.code
JOIN masterdata.vendor_master_location_detail vml
    ON vml.vendor_id = vm.id
WHERE ev.id = evl.e_vendor_id
  AND vml.code = evl.code;


