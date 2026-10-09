CREATE FOREIGN TABLE sqlserver_fdw.logindivisiondetail
(
    LoginDivNo integer,
    LoginNo smallint,
    DivisionNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Security',
    table_name 'LoginDivisionDetail'
);

INSERT INTO security.user_master_division_detail
(
    id,
    user_id,
    division_id
)
OVERRIDING SYSTEM VALUE
SELECT
    d.LoginDivNo,
    d.LoginNo,
    d.DivisionNo
FROM sqlserver_fdw.logindivisiondetail d
INNER JOIN security.user_master u
    ON u.id = d.LoginNo
INNER JOIN masterdata.division_master dm
    ON dm.id = d.DivisionNo;