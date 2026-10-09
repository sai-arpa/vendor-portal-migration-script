CREATE FOREIGN TABLE if not exists sqlserver_fdw.loginwhitelistip
(
    loginwhitelistipno smallint,
    loginno integer,
    fromipaddress varchar(100),
    toipaddress varchar(100)
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Security',
    table_name 'LoginWhiteListIP'
);

INSERT INTO utility.whitelist_ip_main
(
    id,
    code,
    from_ip_address,
    to_ip_address,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date
)
OVERRIDING SYSTEM VALUE
SELECT
    lwip.loginwhitelistipno,
    LPAD(lwip.loginwhitelistipno::text, 6, '0'),
    LEFT(TRIM(COALESCE(lwip.fromipaddress, '')), 45),
    NULLIF(LEFT(TRIM(COALESCE(lwip.toipaddress, '')), 45), ''),
    1,
    NOW(),
    1,
    NOW()
FROM sqlserver_fdw.loginwhitelistip lwip
where lwip.loginNo is not null;

INSERT INTO utility.whitelist_ip_detail
(
    id,
    white_list_ip_id,
    user_id
)
OVERRIDING SYSTEM VALUE
SELECT
    lwip.loginwhitelistipno,
    lwip.loginwhitelistipno,
    lwip.loginno
FROM sqlserver_fdw.loginwhitelistip lwip
where lwip.loginNo is not null;