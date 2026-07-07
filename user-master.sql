create schema if not exists sqlserver_fdw;

CREATE FOREIGN table if not exists sqlserver_fdw.login
(
    loginno smallint,
    loginid varchar(50),
    pwd text,
    vendorlocationno integer,
    usertype varchar(1),
    createdby integer,
    createddate text,
    modifiedby integer,
    modifieddate text,
    printingname varchar(50),
    phoneno varchar(50),
    inactive boolean,
    email varchar(300),
    lastlogindate text,
    lastactivedate text,
    loginguid varchar(50),
    lastpasswordchangeddate text,
    defaultdashboard smallint,
    isblocked boolean,
    blockeddate text,
    divisionselectionon smallint,
    deptselectionon smallint
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Security',
    table_name 'Login'
);

CREATE FOREIGN table if not exists sqlserver_fdw.loginvendorlocationdetail
(
    logindivno integer,
    loginno smallint,
    vendorlocationno integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Security',
    table_name 'LoginVendorLocationDetail'
);


INSERT INTO security.user_master
(
    id,
    user_type_id,
    username,
    password_hash,
    display_name,
    created_by_id,
    created_date,
    modified_date,
    status_id,
    is_guest_login,
    failed_login_attempt_counter
)
OVERRIDING SYSTEM VALUE
VALUES
(
    1000000,
    1,
    'migration',
    'migration',
    'Migration User',
    1000000,
    now(),
    now(),
    1,
    false,
    0
);

--drop foreign table sqlserver_fdw.login;

--truncate table security.user_master cascade;

INSERT INTO security.user_master
(
    id,
    user_type_id,
    username,
    password_hash,
    display_name,
    contact_no,
    contact_no_country_id,
    time_zones_id,
    email,
    erp_user_id,
    division_type_id,
    department_type_id,
    is_blocked,
    blocked_date,
    last_password_changed_date,
    last_login_date,
    failed_login_attempt_counter,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    supplier_account_id,
    is_guest_login
)
OVERRIDING SYSTEM VALUE
SELECT
    l.LoginNo,
    CASE
        WHEN supplier.LoginNo IS NOT NULL THEN 3::smallint
        ELSE l.UserType::smallint
    END AS user_type_id,
    l.LoginID,
    'ab',
    COALESCE(NULLIF(l.PrintingName, ''), l.LoginID),
    CASE 
        WHEN NULLIF(TRIM(l.PhoneNo), '') IS NOT NULL 
        THEN '+91' || LEFT(TRIM(l.PhoneNo), 12)
        ELSE NULL 
    END,
    CASE
        WHEN NULLIF(TRIM(l.PhoneNo), '') IS NOT NULL
        THEN (
            SELECT cm.id
            FROM masterdata.country_master cm
            WHERE LOWER(cm.country_name) = 'india'
            LIMIT 1
        )
        ELSE NULL
    END,
    1::smallint AS time_zones_id,
    l.Email,
    l.LoginGUID,
    COALESCE(l.DivisionSelectionOn, 1)::smallint,
    COALESCE(l.DeptSelectionOn, 1)::smallint,
    COALESCE(l.IsBlocked, false),
    migration.parse_sqlserver_datetime(l.BlockedDate),
    migration.parse_sqlserver_datetime(l.LastPasswordChangedDate),
    migration.parse_sqlserver_datetime(l.LastLoginDate),
    0::smallint AS failed_login_attempt_counter,
    1000000 AS created_by_id,
    COALESCE(migration.parse_sqlserver_datetime(l.CreatedDate), now()) AS created_date,
    NULL AS modified_by_id,
    COALESCE(
        migration.parse_sqlserver_datetime(l.ModifiedDate),
        migration.parse_sqlserver_datetime(l.CreatedDate),
        now()
    ) AS modified_date,
    CASE
        WHEN COALESCE(l.Inactive, false)
            THEN 2::smallint
        ELSE 1::smallint
    END AS status_id,
    NULL AS status_remarks,
    NULL AS supplier_account_id,
    FALSE AS is_guest_login
FROM sqlserver_fdw.login l
LEFT JOIN
(
    SELECT DISTINCT LoginNo
    FROM sqlserver_fdw.loginvendorlocationdetail
) supplier
ON supplier.LoginNo = l.LoginNo;

CREATE TEMP TABLE tmp_login AS
SELECT
    LoginNo,
    CreatedBy,
    ModifiedBy
FROM sqlserver_fdw.login;

UPDATE security.user_master u
SET
    created_by_id = CASE
                        WHEN COALESCE(t.createdby, 0) = 0 THEN 1
                        ELSE t.createdby
                    END,
    modified_by_id = CASE
                         WHEN COALESCE(t.modifiedby, 0) = 0 THEN 1
                         ELSE t.modifiedby
                     END
FROM tmp_login t
WHERE u.id = t.loginno;

DELETE FROM security.user_master
WHERE id = 1000000;