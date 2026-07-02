CREATE FOREIGN table if not exists sqlserver_fdw.mvendorlocationbankdetail
(
    BankDetailNo int,
    VendorLocationNo int,
    BankName varchar(100),
    BranchName varchar(100),
    IFSCCode varchar(25),
    AccountNumber varchar(30),
    BankAccountTypeNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mVendorLocationBankDetail'
);


INSERT INTO masterdata.vendor_location_bank_detail
(
    id,
    vendor_location_id,
    bank_name,
    branch_name,
    ifsc_code,
    account_name,
    account_no,
    bank_account_type_id,
    swift_code
)
OVERRIDING SYSTEM VALUE
SELECT
    b.BankDetailNo,
    b.VendorLocationNo,
    LEFT(TRIM(COALESCE(b.BankName,'')),150),
    LEFT(TRIM(COALESCE(b.BranchName,'')),150),
    LEFT(TRIM(COALESCE(b.IFSCCode,'')),11),
    LEFT(TRIM(COALESCE(b.AccountNumber,'')),150),
    LEFT(TRIM(COALESCE(b.AccountNumber,'')),20),
    b.BankAccountTypeNo,
    NULL
FROM sqlserver_fdw.mvendorlocationbankdetail b;