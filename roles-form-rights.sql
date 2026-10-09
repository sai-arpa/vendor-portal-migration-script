CREATE FOREIGN TABLE if not exists sqlserver_fdw.mrolemasterformdetail
(
    RoleMasterFormDetailNo integer,
    RoleMasterNo smallint,
    FormNo smallint,
    IsSave boolean,
    IsUpdate boolean,
    IsOpen boolean,
    IsDelete boolean,
    IsPrint boolean,
    IsPrintPreview boolean,
    IsRelease boolean,
    IsAuthorize boolean,
    IsEmail boolean,
    IsExport boolean
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Security',
    table_name 'mRoleMasterFormDetail'
);

INSERT INTO masterdata.role_form_rights
(
    role_id,
    form_id,
    can_save,
    can_update,
    can_list,
    can_delete,
    can_print,
    can_print_preview,
    can_authorize,
    can_view_report
)
SELECT
    fd.RoleMasterNo AS role_id,
    fm.new_form_id AS form_id,
    COALESCE(fd.IsSave, FALSE),
    COALESCE(fd.IsUpdate, FALSE),
    COALESCE(fd.IsOpen, FALSE),
    COALESCE(fd.IsDelete, FALSE),
    COALESCE(fd.IsPrint, FALSE),
    COALESCE(fd.IsPrintPreview, FALSE),
    COALESCE(fd.IsAuthorize, FALSE),
    FALSE AS can_view_report
FROM sqlserver_fdw.mrolemasterformdetail fd
INNER JOIN sqlserver_fdw.mrolemaster rm
    ON rm.RoleMasterNo = fd.RoleMasterNo
INNER JOIN masterdata.company_master c
    ON c.id = rm.CompanyNo
   AND c.head_office_id IS NULL
INNER JOIN migration.form_mapping fm
    ON fm.old_form_id = fd.FormNo;
