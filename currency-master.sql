CREATE FOREIGN table if not exists sqlserver_fdw.mcurrencymaster
(
    CurrencyNo smallint,
    Code varchar(50),
    Name varchar(200),
    Notation varchar(100),
    Symbol varchar(100),
    CreatedBy smallint,
    CreatedDate text,
    ModifiedBy smallint,
    ModifiedDate text,
    Inactive boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mCurrencyMaster'
);

INSERT INTO masterdata.currency_master
(
    id,
    code,
    currency_name,
    currency_notation,
    currency_symbol,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    subunit_name
)
OVERRIDING SYSTEM VALUE
SELECT
    CurrencyNo,
    TRIM(Code),
    TRIM(Name),
    Notation,
    Symbol,
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
    CASE
        WHEN COALESCE(Inactive,FALSE)
        THEN 2
        ELSE 1
    END,
    CASE
    	WHEN Inactive THEN 'inactive'
	END AS status_remarks,
    NULL
FROM sqlserver_fdw.mcurrencymaster;





----------- Manual ----------


INSERT INTO masterdata.currency_master (
    code,
    currency_name,
    currency_notation,
    currency_symbol,
    subunit_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
VALUES (
    'INR',
    'Indian Rupee',
    'INR',
    '₹',
    'Paise',
    1,
    CURRENT_TIMESTAMP,
    1,
    CURRENT_TIMESTAMP,
    1,
    'Active'
);