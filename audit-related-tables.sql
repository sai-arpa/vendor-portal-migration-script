-- AUDIT MASTER

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mauditmaster
(
    AuditNo SMALLINT,
    Code VARCHAR(6),
    FormNo SMALLINT,
    InActive BIT,
    CreatedBy INTEGER,
    CreatedDate text,
    ModifiedBy INTEGER,
    ModifiedDate text,
    AuditName VARCHAR(100),
    Description VARCHAR(500),
    FromNetAmount NUMERIC(19,4),
    ToNetAmount NUMERIC(19,4),
    FromDate text,
    ToDate text
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mAuditMaster'
);

--- AUDIT DETAIL

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mauditdetail
(
    AuditDetailNo INTEGER,
    AuditNo SMALLINT,
    LevelNo SMALLINT,
    LoginNo INTEGER,
    IsDefault BIT
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mAuditDetail'
);

-- AUDIT COMPANY DETAIL

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.mauditcompanydetail
(
    AuditNo SMALLINT,
    CompanyNo SMALLINT
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'masterdata',
    table_name 'mAuditCompanyDetail'
);

-- AUDIT DOCUMENT MAIN

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.auditdocumentmain
(
    AuditDocumentNo INTEGER,
    FormNo SMALLINT,
    DocumentNo INTEGER,
    StatusNo SMALLINT,
    AuditNo SMALLINT
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'AuditDocumentMain'
);

-- AUDIT DOCUMENT DETAIL

CREATE FOREIGN TABLE IF NOT EXISTS sqlserver_fdw.auditdocumentdetail
(
    AuditDocumentDetailNo INTEGER,
    AuditDocumentNo INTEGER,
    LoginNo SMALLINT,
    Comment VARCHAR(1000),
    StatusNo SMALLINT,
    ModifiedDate text,
    LevelNo SMALLINT,
    IsReady BIT,
    IsChangeable BIT,
    NextReviewerNo SMALLINT
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'AuditDocumentDetail'
);

-- AUDIT MAPPING

CREATE TABLE migration.audit_setup_mapping
(
    old_audit_no SMALLINT PRIMARY KEY,
    new_approval_setup_id INTEGER NOT NULL
);

CREATE TABLE migration.audit_level_mapping
(
    old_audit_no SMALLINT,
    old_level_no SMALLINT,
    new_approval_level_id INTEGER NOT NULL,

    PRIMARY KEY
    (
        old_audit_no,
        old_level_no
    )
);
-------------------------- INSERT START -----------------------

-- Approval Setup Insert

INSERT INTO masterdata.approval_setup_master
(
    code,
    approval_setup_name,
    form_id,
    approval_scope_id,
    min_net_amount,
    max_net_amount,
    revision_no,
    is_current,
    main_approval_id,
    description,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    from_date,
    is_audit,
    is_audit_apply_to_existing_documents,
    to_date
)
SELECT
    LEFT(TRIM(COALESCE(am.code,'')),6),
    LEFT(TRIM(COALESCE(am.auditname,'')),100),
    fm.new_form_id,
    1 as approval_scope_id,
    am.fromnetamount,
    am.tonetamount,
    0 as revision_no,
    true,
    NULL,
    LEFT(TRIM(COALESCE(am.description,'')),500),
    COALESCE(am.createdby,1),
    migration.parse_sqlserver_datetime(am.createddate),
    am.modifiedby,
    COALESCE(
        migration.parse_sqlserver_datetime(am.modifieddate),
        migration.parse_sqlserver_datetime(am.createddate)
    ),
    CASE
        WHEN COALESCE(am.inactive,B'0') = B'1' THEN 2
        ELSE 1
    END,
    NULL,
    migration.parse_sqlserver_datetime(am.fromdate)::date,
    true,
    false,
    migration.parse_sqlserver_datetime(am.todate)::date
FROM sqlserver_fdw.mauditmaster am
left join migration.form_mapping fm 
on fm.old_form_id = am.formno;



-- Approval Setup Mapping

INSERT INTO migration.audit_setup_mapping
(
    old_audit_no,
    new_approval_setup_id
)
SELECT
    am.auditno,
    asm.id
FROM sqlserver_fdw.mauditmaster am
INNER JOIN masterdata.approval_setup_master asm
    ON asm.code = am.code
   AND asm.is_audit = true;


-- Approval Setup Level Detail

INSERT INTO masterdata.approval_setup_level_detail
(
    approval_setup_id,
    level_no,
    printing_caption,
    approval_rule_id,
    is_next_level_selection_allowed,
    max_approval_time
)
SELECT
    asm.new_approval_setup_id as approval_setup_id,
    ad.levelno as level_no,
    'AUDIT LEVEL ' || ad.levelno,
    1 as approval_rule_id,
    false as is_next_level_selection_allowed,
    null as max_approval_time
FROM sqlserver_fdw.mauditdetail ad
LEFT JOIN migration.audit_setup_mapping asm
    ON asm.old_audit_no = ad.auditno
group by asm.new_approval_setup_id, ad.auditno , ad.levelno;

--select count(*) from masterdata.approval_setup_level_detail asld 

-- Approval Setup Level Mapping

INSERT INTO migration.audit_level_mapping
(
    old_audit_no,
    old_level_no,
    new_approval_level_id
)
SELECT DISTINCT
    ad.auditno,
    ad.levelno,
    asld.id
FROM sqlserver_fdw.mauditdetail ad
INNER JOIN migration.audit_setup_mapping asm
    ON asm.old_audit_no = ad.auditno
INNER JOIN masterdata.approval_setup_level_detail asld
    ON asld.approval_setup_id = asm.new_approval_setup_id
   AND asld.level_no = ad.levelno;

-- User Detail

INSERT INTO masterdata.approval_setup_user_detail
(
    approval_setup_level_id,
    user_id,
    role_id,
    is_default
)
SELECT
    alm.new_approval_level_id,
    ad.loginno,
    NULL,
    case when COALESCE(ad.isdefault,B'0') = B'0' then false else true end
FROM sqlserver_fdw.mauditdetail ad
INNER JOIN migration.audit_level_mapping alm
    ON alm.old_audit_no = ad.auditno
   AND alm.old_level_no = ad.levelno;

-- Approval setup org unit

INSERT INTO masterdata.approval_setup_org_unit_detail
(
    approval_setup_id,
    company_id,
    division_id,
    department_id
)
SELECT DISTINCT
    asm.new_approval_setup_id,
    acd.companyno,
    NULL::INTEGER AS division_id,
    NULL::INTEGER AS department_id
FROM sqlserver_fdw.mauditcompanydetail acd
INNER JOIN migration.audit_setup_mapping asm
    ON asm.old_audit_no = acd.auditno;

-- Approval setup

INSERT INTO masterdata.approval_setup_doc_type_detail
(
    approval_setup_id,
    doc_type_id
)
SELECT
    asm.id AS approval_setup_id,
    dtm.id AS doc_type_id
FROM masterdata.approval_setup_master asm
INNER JOIN masterdata.doc_type_master dtm
    ON dtm.form_id = asm.form_id
where asm.is_audit is true;


-------------------------------------------------- APPROVAL PROCESS RELATED TABLES --------------------------------------------------

-- Audit Entry Main

INSERT INTO utility.audit_entry_main
(
    form_id,
    doc_id,
    approval_setup_id,
    status_id,
    created_by_id,
    created_date,
    authorized_by_id,
    authorized_date
)
SELECT
    fm.new_form_id ,
    adm.DocumentNo,
    asm.new_approval_setup_id,
    adm.StatusNo,
    coalesce(first_detail.LoginNo,1) AS created_by_id,
    coalesce(first_detail.ModifiedDate, now()) AS created_date,
    last_detail.LoginNo AS authorized_by_id,
    coalesce(last_detail.ModifiedDate, now()) AS authorized_date
FROM sqlserver_fdw.AuditDocumentMain adm
INNER JOIN migration.audit_setup_mapping asm
    ON asm.old_audit_no = adm.AuditNo
left join migration.form_mapping fm 
	on fm.old_form_id = adm.formno 
LEFT JOIN LATERAL
(
    SELECT
        ad.LoginNo,
        migration.parse_sqlserver_datetime(ad.ModifiedDate)
            AS ModifiedDate
    FROM sqlserver_fdw.AuditDocumentDetail ad
    WHERE ad.AuditDocumentNo = adm.AuditDocumentNo
    ORDER BY ad.LevelNo ASC,
             ad.AuditDocumentDetailNo ASC
    LIMIT 1
) first_detail ON true
LEFT JOIN LATERAL
(
    SELECT
        ad.LoginNo,
        migration.parse_sqlserver_datetime(ad.ModifiedDate)
            AS ModifiedDate
    FROM sqlserver_fdw.AuditDocumentDetail ad
    WHERE ad.AuditDocumentNo = adm.AuditDocumentNo
    ORDER BY ad.LevelNo DESC,
             ad.AuditDocumentDetailNo DESC
    LIMIT 1
) last_detail ON true;


-- Approval Process Main

INSERT INTO utility.approval_process_main
(
    form_id,
    doc_id,
    approval_setup_id,
    revision_no,
    is_current,
    max_approver_level_no,
    current_approved_level_no,
    approval_start_date,
    action_by_id,
    action_date,
    company_id,
    division_id,
    department_id,
    doc_type_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    is_audit,
    audit_entry_id
)
SELECT
    fm.new_form_id,
    adm.DocumentNo,
    asm.new_approval_setup_id,
    0 AS revision_no,
    true AS is_current,
    lvl.max_level_no AS max_approver_level_no,
    null,
    aem.created_date AS approval_start_date,
    aem.authorized_by_id AS action_by_id,
    aem.authorized_date AS action_date,
    pom.company_id,
    pom.division_id  AS division_id,
    pom.department_id  AS department_id,
    pom.doc_type_id  AS doc_type_id,
    aem.created_by_id,
    aem.created_date,
    aem.authorized_by_id,
    COALESCE(aem.authorized_date, aem.created_date),
    case 
	    when adm.StatusNo =2 then 12 when adm.statusNo=8 then 14 when adm.statusNo=14 then 7
	end,
    NULL AS status_remarks,
    true AS is_audit,
    aem.id AS audit_entry_id
FROM sqlserver_fdw.AuditDocumentMain adm
left join purchase.purchase_order_main pom 
	on pom.id = adm.documentno 
left join migration.form_mapping fm 
	on fm.old_form_id = adm.formno 
INNER JOIN migration.audit_setup_mapping asm
    ON asm.old_audit_no = adm.AuditNo
INNER JOIN utility.audit_entry_main aem
    ON aem.form_id = fm.new_form_id 
   AND aem.doc_id = adm.DocumentNo
   AND aem.approval_setup_id = asm.new_approval_setup_id
LEFT JOIN
(
    SELECT
        AuditDocumentNo,
        MAX(LevelNo) AS max_level_no
    FROM sqlserver_fdw.AuditDocumentDetail
    GROUP BY AuditDocumentNo
) lvl
    ON lvl.AuditDocumentNo = adm.AuditDocumentNo
    

--- Detail


INSERT INTO utility.approval_process_detail
(
    approval_process_id,
    user_id,
    role_id,
    level_no,
    assigned_date,
    modified_date,
    modified_by,
    printing_caption,
    status_id,
    status_remarks,
    approval_rule_id,
    is_next_level_selection_allowed
)
SELECT
    apm.id AS approval_process_id,
    addt.LoginNo AS user_id,
    NULL AS role_id,
    addt.LevelNo AS level_no,
    migration.parse_sqlserver_datetime(addt.ModifiedDate)
        AS assigned_date,
    migration.parse_sqlserver_datetime(addt.ModifiedDate)
        AS modified_date,
    addt.LoginNo AS modified_by,
    'AUDIT LEVEL ' || addt.LevelNo
        AS printing_caption,
    case 
    	when addt.StatusNo=2 then 12
    	when addt.StatusNo=14 then 7
    	when addt.StatusNo=3 then 17
    end
    	AS status_id,
    LEFT(TRIM(COALESCE(addt.Comment,'')),500)
        AS status_remarks,
    2 AS approval_rule_id,
    false AS is_next_level_selection_allowed
FROM sqlserver_fdw.AuditDocumentDetail addt
INNER JOIN sqlserver_fdw.AuditDocumentMain adm
    ON adm.AuditDocumentNo = addt.AuditDocumentNo
INNER JOIN migration.form_mapping fm
    ON fm.old_form_id = adm.FormNo
INNER JOIN migration.audit_setup_mapping asm
    ON asm.old_audit_no = adm.AuditNo
INNER JOIN utility.approval_process_main apm
    ON apm.form_id = fm.new_form_id
   AND apm.doc_id = adm.DocumentNo
   AND apm.approval_setup_id = asm.new_approval_setup_id
   AND apm.is_audit = true;