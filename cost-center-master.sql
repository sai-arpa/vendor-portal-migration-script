CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcostcentermaster
(
    CostCenterNo INTEGER,
    Code CHAR(6),
    CostCenterName VARCHAR(50),
    ParentCostCenterNo INTEGER,
    CreatedBy SMALLINT,
    CreatedDate TEXT,
    ModifiedBy SMALLINT,
    ModifiedDate TEXT,
    Inactive BIT
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mCostCenterMaster'
);

INSERT INTO masterdata.cost_center_master
(
    id,
    code,
    cost_center_name,
    parent_cost_center_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    alias
)
OVERRIDING SYSTEM VALUE
SELECT
    ccm.CostCenterNo,
    LEFT(TRIM(COALESCE(ccm.Code, '')), 6),
    LEFT(TRIM(COALESCE(ccm.CostCenterName, '')), 50),
    ccm.ParentCostCenterNo,
    COALESCE(ccm.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ccm.CreatedDate),
        now()
    ),
    COALESCE(ccm.ModifiedBy, ccm.CreatedBy, 1),
    COALESCE(
        migration.parse_sqlserver_datetime(ccm.ModifiedDate),
        migration.parse_sqlserver_datetime(ccm.CreatedDate),
        now()
    ),
    CASE
        WHEN ccm.Inactive = B'1'
            THEN 2::smallint
        ELSE 1::smallint
    END,
    CASE
        WHEN ccm.Inactive = B'1'
            THEN 'inactive'
        ELSE NULL
    END,
    LEFT(TRIM(COALESCE(ccm.Code, '')), 15)
FROM sqlserver_fdw.mcostcentermaster ccm;