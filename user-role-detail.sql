CREATE FOREIGN table if not exists sqlserver_fdw.loginroledetail (
	loginroleno int4 NULL,
	loginno int2 NULL,
	rolemasterno int2 NULL
)
SERVER sqlserver_fdw
OPTIONS (schema_name 'Security', table_name 'LoginRoleDetail');

INSERT INTO security.user_master_role_detail
(
    id,
    user_id,
    company_id,
    role_id
)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT
    rd.LoginRoleNo,
    rd.LoginNo,
    c.id,
    rm.id
FROM sqlserver_fdw.loginroledetail rd
INNER JOIN sqlserver_fdw.mrolemaster rm2
    ON rm2.RoleMasterNo = rd.RoleMasterNo
INNER JOIN masterdata.role_master rm
    ON rm.code = TRIM(rm2.Code)
INNER JOIN masterdata.company_master c
    ON c.id = rm2.CompanyNo;
