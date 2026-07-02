CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mcostcentercompanydetail
(
    CostCenterCompanyDetailNo INTEGER,
    CostCenterNo INTEGER,
    CompanyNo INTEGER,
    DivisionNo INTEGER
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'masterdata',
    table_name 'mCostCenterCompanyDetail'
);

INSERT INTO masterdata.cost_center_company_detail
(
    id,
    cost_center_id,
    company_id,
    division_id
)
OVERRIDING SYSTEM VALUE
SELECT
    cccd.CostCenterCompanyDetailNo,
    cccd.CostCenterNo,
    cccd.CompanyNo,
    cccd.DivisionNo
FROM sqlserver_fdw.mcostcentercompanydetail cccd;