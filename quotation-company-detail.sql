CREATE FOREIGN table if not exists sqlserver_fdw.quotationcompanydetail
(
    QuotationNo int,
    CompanyNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'QuotationCompanyDetail'
);

INSERT INTO purchase.quotation_company_detail
(
    quotation_id,
    company_id
)
SELECT
    rqm.revisedquotationno ,
    qcd.CompanyNo
FROM sqlserver_fdw.quotationcompanydetail qcd
inner join sqlserver_fdw.revisedquotationmain rqm
on qcd.QuotationNo =rqm.quotationno