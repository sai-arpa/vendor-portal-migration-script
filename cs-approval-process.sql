CREATE FOREIGN TABLE sqlserver_fdw.csauthorizationdetail
(
    CSAuthorizationDetailNo         integer,
    CSNo                        integer,
    StatusNo                        smallint,
    Comment                         varchar(500),
    ModifiedBy                      integer,
    ModifiedDate                    varchar(50),
    LastStatusNo                    smallint,
    LastComment                     varchar(500),
    LoginNo                         integer,
    LastModifiedDate                varchar(50),
    LevelNo                         smallint,
    IsReady                         boolean,
    AssignDate                      varchar(50),
    NextApproverNo                  integer
)
SERVER sqlserver_fdw
OPTIONS (
    schema_name 'Purchase',
    table_name 'csAuthorizationDetail'
);


WITH action_cte AS (
    SELECT DISTINCT ON (cad.csNo)
        cad.csNo,
        cad.ModifiedBy                                          AS action_by_id,
        migration.parse_sqlserver_datetime(cad.ModifiedDate)    AS action_date
    FROM sqlserver_fdw.csauthorizationdetail cad
    WHERE cad.ModifiedBy IS NOT NULL
      AND cad.ModifiedDate IS NOT NULL
    ORDER BY cad.csNo, cad.LevelNo DESC
)
INSERT INTO utility.approval_process_main (
    form_id,
    doc_id,
    approval_setup_id,
    revision_no,
    is_current,
    status_id,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    max_approver_level_no,
    current_approved_level_no,
    approval_start_date,
    action_by_id,
    action_date,
    company_id,
    doc_type_id,
    is_audit,
    audit_entry_id
)
OVERRIDING SYSTEM VALUE
SELECT
    8                                                              AS form_id,
    pom.id                                                          AS doc_id,
    pom.approval_setup_id                                           AS approval_setup_id,
    0                                                               AS revision_no,
    true                                                            AS is_current,
    CASE
	    WHEN pom.document_status_id = 30 THEN 9
	    WHEN pom.document_status_id = 20 THEN 14
	    WHEN pom.document_status_id = 10 THEN 7
    END                                                             AS status_id,
    pom.created_by_id                                               AS created_by_id,
    pom.created_date                                                AS created_date,
    pom.modified_by_id                                              AS modified_by_id,
    pom.modified_date                                               AS modified_date,
    MAX(cad.LevelNo)                                                AS max_approver_level_no,
    MAX(
    	CASE
        	WHEN cad.StatusNo = 1 THEN cad.LevelNo
	    END
	) AS current_approved_level_no,
    COALESCE(migration.parse_sqlserver_datetime(MIN(cad.AssignDate)), NOW()) AS approval_start_date,
    ac.action_by_id                                                 AS action_by_id,
    ac.action_date                                                  AS action_date,
    pom.company_id                                                  AS company_id,
    pom.doc_type_id                                                 AS doc_type_id,
    false                                                           AS is_audit,
    NULL                                                            AS audit_entry_id
FROM purchase.cs_main pom
JOIN sqlserver_fdw.csauthorizationdetail cad
    ON cad.csNo = pom.id
 AND  pom.approval_setup_id IS NOT NULL
LEFT JOIN action_cte ac
    ON ac.csNo = pom.id
GROUP BY
    pom.id,
    pom.approval_setup_id,
    pom.created_by_id,
    pom.created_date,
    pom.modified_by_id,
    pom.modified_date,
    pom.company_id,
    pom.doc_type_id,
    ac.action_by_id,
    ac.action_date;


INSERT INTO utility.approval_process_detail (
    approval_process_id,
    user_id,
    role_id,
    level_no,
    assigned_date,
    modified_date,
    modified_by,
    status_id,
    status_remarks,
    approval_rule_id,
    is_next_level_selection_allowed,
    printing_caption
)
OVERRIDING SYSTEM VALUE
SELECT
    apm.id                                                          AS approval_process_id,
    pad.LoginNo                                                     AS user_id,
    NULL                                                            AS role_id,
    pad.LevelNo                                                     AS level_no,
    migration.parse_sqlserver_datetime(pad.AssignDate)              AS assigned_date,
    migration.parse_sqlserver_datetime(
        COALESCE(pad.ModifiedDate, pad.LastModifiedDate)
    )                                                               AS modified_date,
    pad.ModifiedBy                                                  AS modified_by,
 CASE
 WHEN pad.StatusNo = 1 THEN 12
 WHEN pad.StatusNo = 5 THEN 20 
 WHEN pad.StatusNo = 17 THEN 19
 END                                                             AS status_id,
    COALESCE(
        NULLIF(TRIM(pad.Comment), ''),
        NULLIF(TRIM(pad.LastComment), '')
    )                                                               AS status_remarks,
    2                                                               AS approval_rule_id,
    false                                                           AS is_next_level_selection_allowed,
    alm.printing_caption                                            AS printing_caption
FROM sqlserver_fdw.csAuthorizationDetail pad
JOIN utility.approval_process_main apm
    ON apm.doc_id = pad.csNo
    AND apm.form_id = 8
LEFT JOIN masterdata.approval_setup_level_detail alm
    ON alm.approval_setup_id = apm.approval_setup_id
    AND alm.level_no = pad.LevelNo; 


