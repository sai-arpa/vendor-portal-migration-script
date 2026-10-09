CREATE FOREIGN table if not exists sqlserver_fdw.changepostatusmain
(
    companyno integer,
    yearno integer,
    changepostatusno integer,
    divisionno integer,
    documentsettingno text,
    documentnoyearly varchar(30),
    documentdate text,
    documentstatusno smallint,
    poamendmentno integer,
    statusno smallint,
    reason varchar(1000),
    createdby integer,
    createddate text,
    modifiedby integer,
    modifieddate text,
    authorizedby integer,
    authorizeddate text,
    releasedby integer,
    releaseddate text,
    isinserted bit
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'ChangePOStatusMain'
);


INSERT INTO purchase.po_cancellation_main
(
	id,
    po_id,
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
overriding system value
select
    cpsm.changepoStatusNo,
    cpsm.poamendmentNo,
    cpsm.documentnoyearly,
    migration.parse_sqlserver_datetime(cpsm.documentdate),
    6,
    cpsm.divisionno,
    NULL,
    cpsm.documentstatusno,
    cpsm.companyno,
    cpsm.yearno,
    cpsm.reason,
    cpsm.createdby,
    migration.parse_sqlserver_datetime(cpsm.createddate),
    cpsm.modifiedby,
    COALESCE(
        migration.parse_sqlserver_datetime(cpsm.modifieddate),
        migration.parse_sqlserver_datetime(cpsm.createddate)
    ),
    cpsm.authorizedby,
    migration.parse_sqlserver_datetime(cpsm.authorizeddate)
FROM sqlserver_fdw.changepostatusmain cpsm


