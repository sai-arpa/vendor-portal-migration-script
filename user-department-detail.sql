CREATE FOREIGN table if not exists sqlserver_fdw.logindeptdetail
(
    LoginDeptNo integer,
    LoginNo smallint,
    DeptNo integer
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Security',
    table_name 'LoginDeptDetail'
);

INSERT INTO security.user_master_department_detail
(
    id,
    user_id,
    department_id
)
OVERRIDING SYSTEM VALUE
SELECT
    d.LoginDeptNo,
    d.LoginNo,
    d.DeptNo
FROM sqlserver_fdw.logindeptdetail d
INNER JOIN security.user_master u
    ON u.id = d.LoginNo
INNER JOIN masterdata.department_master dm
    ON dm.id = d.DeptNo;