CREATE FOREIGN TABLE sqlserver_fdw.loginhistory
(
    loginhistoryno INTEGER,
    loginno SMALLINT,
    logindate text,
    ipaddress VARCHAR(300),
    operatingsystem VARCHAR(100),
    device VARCHAR(100),
    browser VARCHAR(100)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Security',
    table_name 'LoginHistory'
);

CREATE FOREIGN TABLE sqlserver_fdw.loginfailhistory
(
    loginfailhistoryno INTEGER,
    userid VARCHAR(300),
    pwd VARCHAR(300),
    logindate text,
    ipaddress VARCHAR(300),
    operatingsystem VARCHAR(100),
    device VARCHAR(100),
    browser VARCHAR(100)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Security',
    table_name 'LoginFailHistory'
);


---------------------------Session Log----------------------------------------



INSERT INTO security.session_logs
(
    user_id,
    user_name,
    session_id,
    ip_address,
    device_type,
    browser_information,
    operating_system,
    user_agent,
    login_datetime,
    last_token_refresh_datetime,
    refresh_count,
    logout_datetime,
    status_id,
    created_at
)
SELECT
    um.id AS user_id,
    um.username ,
    'SESSION-' || lh.loginhistoryno
        AS session_id,
    LEFT(
        COALESCE(lh.ipaddress,''),
        45
    ) AS ip_address,
    LEFT(
        lh.device,
        50
    ) AS device_type,
    LEFT(
        lh.browser,
        100
    ) AS browser_information,
    LEFT(
        lh.operatingsystem,
        100
    ) AS operating_system,
    NULL AS user_agent,
    migration.parse_sqlserver_datetime(lh.logindate)
        AS login_datetime,
    NULL AS last_token_refresh_datetime,
    0 AS refresh_count,
    NULL AS logout_datetime,
    1 AS status_id,
    migration.parse_sqlserver_datetime(lh.logindate)
        AS created_at
FROM sqlserver_fdw.loginhistory lh
INNER JOIN security.user_master um
    ON um.id = lh.loginno;



---------------------------failed login attempts----------------------------------------



INSERT INTO security.failed_login_attempts
(
    user_id,
    user_name,
    session_id,
    ip_address,
    device_type,
    browser_information,
    operating_system,
    user_agent,
    login_attempt_at,
    failure_code,
    failure_reason,
    status_id,
    created_at
)
SELECT
    NULL,
    coalesce(lfh.userid,'username') AS user_name,
    NULL AS session_id,
    LEFT(
        COALESCE(lfh.ipaddress,''),
        45
    ) AS ip_address,
    LEFT(
        lfh.device,
        50
    ) AS device_type,
    LEFT(
        lfh.browser,
        100
    ) AS browser_information,
    LEFT(
        lfh.operatingsystem,
        100
    ) AS operating_system,
    NULL AS user_agent,
    migration.parse_sqlserver_datetime(lfh.logindate)
        AS login_attempt_at,
    'LOGIN_FAILED' AS failure_code,
    'Migrated from old login fail history'
        AS failure_reason,
    1 AS status_id,
    migration.parse_sqlserver_datetime(lfh.logindate)
        AS created_at
FROM sqlserver_fdw.loginfailhistory lfh