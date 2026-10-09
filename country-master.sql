CREATE FOREIGN table if not exists sqlserver_fdw.mcountrymaster
(
    CountryNo smallint,
    CountryName varchar(200),
    Code varchar(50),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mCountryMaster'
);

INSERT INTO masterdata.country_master
(
    id,
    country_name,
    code,
    iso_country_code,
    phone_code,
    pin_code_length,
    min_contact_no_length,
    max_contact_no_length,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    pin_code_format_id
)
OVERRIDING SYSTEM VALUE
SELECT
    CountryNo,
    TRIM(CountryName),
    TRIM(Code),
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 'IN'
        WHEN 'CHINA' THEN 'CN'
        WHEN 'SWEDEN' THEN 'SE'
        WHEN 'HONG KONG' THEN 'HK'
        ELSE NULL
    END AS iso_country_code,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN '+91'
        WHEN 'CHINA' THEN '+86'
        WHEN 'SWEDEN' THEN '+46'
        WHEN 'HONG KONG' THEN '+852'
        ELSE NULL
    END AS phone_code,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 6
        WHEN 'CHINA' THEN 6
        WHEN 'SWEDEN' THEN 5
        WHEN 'HONG KONG' THEN NULL
        ELSE NULL
    END AS pin_code_length,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 13
        WHEN 'CHINA' THEN 11
        WHEN 'SWEDEN' THEN 7
        WHEN 'HONG KONG' THEN 8
        ELSE NULL
    END AS min_contact_no_length,
    CASE UPPER(TRIM(CountryName))
        WHEN 'INDIA' THEN 13
        WHEN 'CHINA' THEN 14
        WHEN 'SWEDEN' THEN 13
        WHEN 'HONG KONG' THEN 12
        ELSE NULL
    END AS max_contact_no_length,
    COALESCE(CreatedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    COALESCE(ModifiedBy,1),
    COALESCE(
        migration.parse_sqlserver_datetime(ModifiedDate),
        migration.parse_sqlserver_datetime(CreatedDate),
        now()
    ),
    1,
    NULL,
    case UPPER(TRIM(CountryName))
    	when 'HONG KONG' then 2
    	else 1
    end
FROM sqlserver_fdw.mcountrymaster;