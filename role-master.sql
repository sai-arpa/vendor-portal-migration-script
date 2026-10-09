CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mrolemaster(
    companyno smallint,
    rolemasterno smallint,
    code character varying(12) COLLATE pg_catalog."default",
    rolename character varying(50) COLLATE pg_catalog."default",
    createdby smallint,
    createddate text COLLATE pg_catalog."default",
    modifiedby smallint,
    modifieddate text COLLATE pg_catalog."default"
)
    SERVER sqlserver_fdw
    OPTIONS (schema_name 'Security', table_name 'mRoleMaster');


INSERT INTO masterdata.role_master
(
    id,
    code,
    role_name,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks
)
OVERRIDING SYSTEM VALUE
SELECT
    rm.RoleMasterNo AS id,
    LEFT(TRIM(rm.Code), 50),
    LEFT(TRIM(rm.RoleName), 200),
    COALESCE(rm.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(rm.CreatedDate),
        now()
    ),
    rm.ModifiedBy,
    COALESCE(
        migration.parse_sqlserver_datetime(rm.ModifiedDate),
        migration.parse_sqlserver_datetime(rm.CreatedDate),
        now()
    ),
    1::smallint,
    NULL
FROM sqlserver_fdw.mrolemaster rm
JOIN masterdata.company_master c
    ON c.id = rm.CompanyNo
WHERE c.head_office_id IS NULL;



--select rm.id ,rm2.rolemasterno ,c.id
--from masterdata.role_master RM
--inner join sqlserver_fdw.mrolemaster rm2 on rm2.code =rm.code 
--inner JOIN masterdata.company_master c   ON c.id = rm2.CompanyNo;

CREATE TABLE migration.role_mapping
(
    sql_role_id integer PRIMARY KEY,
    pg_role_id integer NOT NULL
);


INSERT INTO migration.role_mapping
(
    sql_role_id,
    pg_role_id
)
SELECT
    rm.RoleMasterNo,
    rm.RoleMasterNo
FROM sqlserver_fdw.mrolemaster rm
JOIN masterdata.company_master c
    ON c.id = rm.CompanyNo
WHERE c.head_office_id IS NULL;