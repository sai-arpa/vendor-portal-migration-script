CREATE FOREIGN TABLE if not exists sqlserver_fdw.changeindentstatusmain
(
    companyno smallint,
    yearno smallint,
    changeindentstatusno integer,
    divisionno integer,
    documentnoyearly varchar(30),
    documentdate text,
    indentno integer,
    statusno smallint,
    reason varchar(1000),
    createdby smallint,
    createddate text,
    modifiedby smallint,
    modifieddate text,
    authorizedby smallint,
    authorizeddate text,
    documentstatusno smallint,
    isinserted integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Inventory',
    table_name 'ChangeIndentStatusMain'
);


insert into utility.purchase_request_cancellation_main (
	id,
	pr_id,
	doc_no_yearly,
	doc_date,
	doc_type_id,
	division_id,
	doc_series_id,
	document_status_id,
	company_id,
	fy_id,
	remarks,
	created_by_id,
	created_date,
	modified_by_id,
	modified_date,
	authorized_by_id,
	authorized_date
)
overriding system VALUE
select
	changeindentstatusno as id,
	prc.indentNo as pr_id,
	prc.documentnoyearly as doc_no_yearly,
	migration.parse_sqlserver_datetime(prc.documentdate) as doc_date,
	5 as doc_type_id,
	prc.divisionno as division_id,
	null,
	prc.documentstatusno,
	prc.companyno as company_id,
	prc.yearno as fy_id,
	prc.reason as remarks,
	prc.createdby,
	migration.parse_sqlserver_datetime(prc.createddate),
	prc.modifiedby,
	coalesce(migration.parse_sqlserver_datetime(prc.modifieddate), migration.parse_sqlserver_datetime(prc.createddate)),
	prc.authorizedby,
	migration.parse_sqlserver_datetime(prc.authorizeddate)
from
	sqlserver_fdw.ChangeIndentStatusMain prc;
