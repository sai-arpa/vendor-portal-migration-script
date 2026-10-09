--- CANCELLED ---


CREATE FOREIGN TABLE sqlserver_fdw.poamendmentrejectionhistory
(
    poarejectionhistoryno INTEGER,
    poamendmentno INTEGER,
    levelno SMALLINT,
    loginno SMALLINT,
    rejectiondate text,
    authgrprevisionno SMALLINT,
    comment VARCHAR(1000),
    netamount NUMERIC(19,4)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'POAmendmentRejectionHistory'
);

---

CREATE TABLE migration.po_rejection_revision_mapping
(
    po_rejection_history_no INTEGER PRIMARY KEY,
    new_approval_process_id INTEGER NOT NULL
);

----Revision No Update for approved entries


WITH rejection_count AS
(
    SELECT
        prh.poamendmentno,
        COUNT(*) AS rejection_count
    FROM sqlserver_fdw.poamendmentrejectionhistory prh
    GROUP BY prh.poamendmentno
)
UPDATE utility.approval_process_main apm
SET
    revision_no = rc.rejection_count
FROM rejection_count rc
WHERE apm.doc_id = rc.poamendmentno
   AND apm.form_id = 10
  AND apm.is_audit = false;


----- Main Insert

WITH rejection_revision AS
(
    SELECT
        prh.poarejectionhistoryno,
        prh.poamendmentno,
        prh.levelno,
        prh.loginno,
        prh.authgrprevisionno,
        prh.comment,
        prh.netamount,
        migration.parse_sqlserver_datetime(prh.rejectiondate) AS rejection_date,
        ROW_NUMBER() OVER
        (
            PARTITION BY prh.poamendmentno
            ORDER BY migration.parse_sqlserver_datetime(prh.rejectiondate)
        ) - 1 AS revision_no
    FROM sqlserver_fdw.poamendmentrejectionhistory prh
),
base_process AS
(
    SELECT
        apm.doc_id,
        apm.form_id,
        apm.approval_setup_id,
        apm.max_approver_level_no,
        apm.company_id,
        apm.division_id,
        apm.department_id,
        apm.doc_type_id,
        apm.created_by_id,
        apm.created_date
    FROM utility.approval_process_main apm
    WHERE apm.is_audit = false
      AND apm.form_id = 10
      AND apm.is_current = true
),
latest_revision AS
(
    SELECT
        form_id,
        doc_id,
        is_audit,
        MAX(revision_no) AS max_revision_no
    FROM utility.approval_process_main
    GROUP BY
        form_id,
        doc_id,
        is_audit
)
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
    10 AS form_id,
    rr.poamendmentno AS doc_id,
    bp.approval_setup_id,
    rr.revision_no,
    false AS is_current,
    bp.max_approver_level_no,
    rr.levelno - 1 AS current_approved_level_no,
    rr.rejection_date AS approval_start_date,
    rr.loginno AS action_by_id,
    rr.rejection_date AS action_date,
    bp.company_id,
    bp.division_id,
    bp.department_id,
    bp.doc_type_id,
    bp.created_by_id,
    bp.created_date,
    rr.loginno AS modified_by_id,
    rr.rejection_date AS modified_date,
    13 AS status_id,
    rr.comment AS status_remarks,
    false AS is_audit,
    NULL AS audit_entry_id
FROM rejection_revision rr
INNER JOIN base_process bp
    ON bp.doc_id = rr.poamendmentno
   AND bp.form_id = 10
LEFT JOIN latest_revision lr
    ON lr.form_id = 10
   AND lr.doc_id = rr.poamendmentno
   AND lr.is_audit = false;
   
    
      
-- Mapping --

WITH rejection_revision AS
(
    SELECT
        prh.poarejectionhistoryno,
        prh.poamendmentno,
        ROW_NUMBER() OVER
        (
            PARTITION BY prh.poamendmentno
            ORDER BY migration.parse_sqlserver_datetime(prh.rejectiondate)
        ) - 1 AS revision_no
    FROM sqlserver_fdw.poamendmentrejectionhistory prh
)
INSERT INTO migration.po_rejection_revision_mapping
(
    po_rejection_history_no,
    new_approval_process_id
)
SELECT
    rr.poarejectionhistoryno,
    apm.id
FROM rejection_revision rr
INNER JOIN utility.approval_process_main apm
	on apm.form_id  = 10
    and apm.doc_id = rr.poamendmentno
   AND apm.revision_no = rr.revision_no
   AND apm.status_id = 13
   AND apm.is_audit = false;

---- Detail Insert

WITH rejection_data AS
(
    SELECT
        prh.poarejectionhistoryno,
        prh.poamendmentno,
        prh.levelno AS rejected_level_no,
        prh.loginno AS rejected_login_no,
        prh.comment,
        migration.parse_sqlserver_datetime(prh.rejectiondate)
            AS rejection_date,
        aprm.new_approval_process_id,
        apm.approval_setup_id
    FROM sqlserver_fdw.poamendmentrejectionhistory prh
    INNER JOIN migration.po_rejection_revision_mapping aprm
        ON aprm.po_rejection_history_no = prh.poarejectionhistoryno
    INNER JOIN utility.approval_process_main apm
        ON apm.id = aprm.new_approval_process_id
),
setup_levels AS
(
    SELECT
        rd.poarejectionhistoryno,
        rd.new_approval_process_id,
        asld.id AS approval_setup_level_id,
        asld.level_no,
        asld.printing_caption,
        asld.approval_rule_id,
        asld.is_next_level_selection_allowed,
        rd.rejected_level_no,
        rd.rejected_login_no,
        rd.comment,
        rd.rejection_date
    FROM rejection_data rd
    INNER JOIN masterdata.approval_setup_level_detail asld
        ON asld.approval_setup_id = rd.approval_setup_id
),
setup_users AS
(
    SELECT
        sl.poarejectionhistoryno,
        sl.new_approval_process_id,
        sl.level_no,
        asud.user_id,
        asud.role_id,
        sl.printing_caption,
        sl.approval_rule_id,
        sl.is_next_level_selection_allowed,
        sl.rejected_level_no,
        sl.rejected_login_no,
        sl.comment,
        sl.rejection_date,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                sl.poarejectionhistoryno,
                sl.level_no
            ORDER BY asud.is_default DESC,
                     asud.user_id
        ) AS user_order
    FROM setup_levels sl
    INNER JOIN masterdata.approval_setup_user_detail asud
        ON asud.approval_setup_level_id = sl.approval_setup_level_id
),
resolved_users AS
(
    SELECT
        su.*,
        lm.new_user_id AS rejected_user_id
    FROM setup_users su
    LEFT JOIN migration.login_mapping lm
        ON lm.old_login_no = su.rejected_login_no
)
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
    ru.new_approval_process_id AS approval_process_id,
    ru.user_id,
    ru.role_id,
    ru.level_no,
    ru.rejection_date AS assigned_date,
    CASE
        WHEN ru.level_no <= ru.rejected_level_no
        THEN ru.rejection_date
        ELSE NULL
    END AS modified_date,
    CASE
        WHEN ru.level_no <= ru.rejected_level_no
        THEN ru.rejected_user_id
        ELSE NULL
    END AS modified_by,
    ru.printing_caption,
    CASE
        WHEN ru.level_no < ru.rejected_level_no
        THEN
            CASE
                WHEN ru.user_order = 1
                    THEN 12
                ELSE 21
            END
        WHEN ru.level_no = ru.rejected_level_no
        THEN
            CASE
                WHEN ru.user_id = ru.rejected_user_id
                    THEN 13
                ELSE 29
            END
        ELSE NULL
    END AS status_id,
    CASE
        WHEN ru.level_no = ru.rejected_level_no
         AND ru.user_id = ru.rejected_user_id
        THEN ru.comment
        ELSE NULL
    END AS status_remarks,
    ru.approval_rule_id,
    ru.is_next_level_selection_allowed
FROM resolved_users ru;

