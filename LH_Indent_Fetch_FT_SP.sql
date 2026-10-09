
CREATE FOREIGN TABLE oracle_indent_head (
    entity_code    varchar(4),
    fy             varchar(5),
    indent_no      varchar(30),
    tcode          varchar(1),
    indent_date    timestamp,
    indent_type    varchar(1),
    department     varchar(10),
    division_code  varchar(10)
)
SERVER oracle_server
OPTIONS (
    table '(SELECT ENTITY_CODE,
                   FY,
                   INDENT_NO,
                   TCODE,
                   INDENT_DATE,
                   INDENT_TYPE,
                   DEPARTMENT,
                   DIVISION_CODE
            FROM RIPLRR.VIEW_PP_INDENT_HEAD)'
);

select * from oracle_indent_head



CREATE FOREIGN TABLE oracle_indent_body (
    data_for        varchar(100),
    entity_code     varchar(100),
    vrno            varchar(30),
    vrdate          timestamp,
    slno            varchar(10),
    item_code       varchar(50),
    make_code       varchar(50),
    techspecs       varchar(1000),
    required_qty    numeric(15,3),
    indent_qty      numeric(15,3),
    rate            numeric(19,4),
    amount          numeric(19,4),
    costhead_pk     varchar(20),
    duedate         timestamp,
    scheduledate    text,
    scheduleqty     text,
    remarks         varchar(1000)
)
SERVER oracle_server
OPTIONS (
    table '(SELECT DATA_FOR,
                   ENTITY_CODE,
                   VRNO,
                   VRDATE,
                   SLNO,
                   ITEM_CODE,
                   MAKE_CODE,
                   TECHSPECS,
                   REQUIRED_QTY,
                   INDENT_QTY,
                   RATE,
                   AMOUNT,
                   COSTHEAD_PK,
                   DUEDATE,
                   SCHEDULEDATE,
                   SCHEDULEQTY,
                   REMARKS
            FROM RIPLRR.VIEW_PP_INDENT_BODY)'
);

select * from oracle_indent_body



------------------------------------SP------------------------------------------------




-- =============================================
-- Author:
-- Create date: 2026-06-08
-- Description: Fetches Purchase Request (Indent) Head and Body data from
--              Oracle (via foreign tables), inserts into erpinventory.pr_main,
--              erpinventory.pr_item_detail, and erpinventory.pr_item_detail_recent.
-- =============================================

CREATE OR REPLACE PROCEDURE erpinventory.fetch_indent_from_lighthouse()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id    INT;
BEGIN

    -- -------------------------------------------------------------------------
    -- JOB LOG: Start
    -- NOTE: job_log table may not exist in new version — confirm before enabling
    -- -------------------------------------------------------------------------
    -- SELECT COALESCE(MAX(id), 0) + 1 INTO v_job_id FROM masterdata.job_log;
    -- INSERT INTO masterdata.job_log (id, job_name, stage, log_date, seq_no)
    -- VALUES (v_job_id, 'IndentFetch', 'Start', NOW(), 1);


    -- -------------------------------------------------------------------------
    -- STEP 1: Load Oracle indent head into temp table (Oracle hit ONCE)
    --         Deduped by GROUP BY same as old SP
    -- -------------------------------------------------------------------------
    CREATE TEMP TABLE tmp_oracle_indent_head AS
    SELECT
        entity_code,
        fy,
        indent_no,
        tcode,
        indent_date,
        indent_type,
        department,
        division_code
    FROM oracle_indent_head
    GROUP BY
        entity_code, fy, indent_no, tcode,
        indent_date, indent_type, department, division_code;


    -- -------------------------------------------------------------------------
    -- STEP 2: Load Oracle indent body into temp table (Oracle hit ONCE)
    --         Reused for pr_item_detail + pr_item_detail_recent
    -- -------------------------------------------------------------------------
    CREATE TEMP TABLE tmp_oracle_indent_body AS
    SELECT
        data_for,
        entity_code,
        vrno,
        vrdate,
        slno,
        item_code,
        make_code,
        techspecs,
        required_qty,
        indent_qty,
        rate,
        amount,
        costhead_pk,
        duedate,
        scheduledate,
        scheduleqty,
        remarks
    FROM oracle_indent_body;


    -- -------------------------------------------------------------------------
    -- STEP 3: Insert new PR head records (not yet in pr_main)
    --         Joined via company_master.erp_company_unique_id → db_master
    -- -------------------------------------------------------------------------
    INSERT INTO erpinventory.pr_main
        (entity_code, fy, doc_no_yearly, doc_date, t_code, indent_type,
         erp_department_uv, erp_division_uv, db_id, inactive)
    SELECT
        ora.entity_code,
        ora.fy,
        ora.indent_no,
        ora.indent_date::date,
        ora.tcode,
        MAX(ora.indent_type),               -- same as old SP MAX(Indent_Type)
        ora.department,
        ora.division_code,
        db.id,
        FALSE
    FROM tmp_oracle_indent_head ora
    INNER JOIN masterdata.db_master db
        ON db.code = ora.entity_code
    LEFT JOIN erpinventory.pr_main pm
        ON pm.entity_code    = ora.entity_code
       AND pm.fy             = ora.fy
       AND pm.doc_no_yearly  = ora.indent_no
       AND pm.doc_date       = ora.indent_date::date
       AND pm.t_code         = ora.tcode
    WHERE pm.id IS NULL
    GROUP BY
        ora.entity_code, ora.fy, ora.indent_no,
        ora.indent_date, ora.tcode,
        ora.department, ora.division_code, db.id;


    -- -------------------------------------------------------------------------
    -- JOB LOG: Head inserted
    -- NOTE: job_log table may not exist in new version — confirm before enabling
    -- -------------------------------------------------------------------------
    -- INSERT INTO masterdata.job_log (id, job_name, stage, log_date, seq_no)
    -- VALUES (v_job_id, 'IndentFetch', 'Head', NOW(), 2);


    -- -------------------------------------------------------------------------
    -- STEP 4: Insert new PR item detail records (not yet in pr_item_detail)
    --         Joins pr_main on entity_code + vrno + vrdate to get c_pr_id
    -- -------------------------------------------------------------------------
    INSERT INTO erpinventory.pr_item_detail
        (c_pr_id, line_no, erp_item_uv, erp_make_uv, tech_specification,
         required_qty, indent_qty, rate, amount, erp_cost_center_uv,
         vp_pr_id, vp_pr_item_detail_id, due_date, remarks, db_id)
    SELECT
        pm.id,                              -- c_pr_id from pr_main
        ora.slno::smallint,
        ora.item_code,
        ora.make_code,
        ora.techspecs,
        ora.required_qty,
        ora.indent_qty,
        ora.rate,
        ora.amount,
        ora.costhead_pk,
        NULL,                               -- vp_pr_id: not yet mapped
        NULL,                               -- vp_pr_item_detail_id: not yet mapped
        ora.duedate::date,
        ora.remarks,
        6
    FROM tmp_oracle_indent_body ora
    INNER JOIN erpinventory.pr_main pm
        ON pm.entity_code   = ora.entity_code
       AND pm.doc_no_yearly = ora.vrno
       AND pm.doc_date      = ora.vrdate::date
    LEFT JOIN erpinventory.pr_item_detail pid
        ON pid.c_pr_id  = pm.id
       AND pid.line_no  = ora.slno::smallint
    WHERE pid.id IS NULL;


    -- -------------------------------------------------------------------------
    -- JOB LOG: Body inserted
    -- NOTE: job_log table may not exist in new version — confirm before enabling
    -- -------------------------------------------------------------------------
    -- INSERT INTO masterdata.job_log (id, job_name, stage, log_date, seq_no)
    -- VALUES (v_job_id, 'IndentFetch', 'Body', NOW(), 3);


    -- -------------------------------------------------------------------------
    -- TODO: Create portal PR function (equivalent of RealDeals.Inventory.CreatePortalIndent)
    --       This function should create inventory.purchase_request_main and
    --       inventory.purchase_request_item_detail from erpinventory.pr_main/pr_item_detail
    -- -------------------------------------------------------------------------
    CALL erpinventory.create_portal_pr();


    -- -------------------------------------------------------------------------
    -- JOB LOG: PR created in portal
    -- NOTE: job_log table may not exist in new version — confirm before enabling
    -- -------------------------------------------------------------------------
    -- INSERT INTO masterdata.job_log (id, job_name, stage, log_date, seq_no)
    -- VALUES (v_job_id, 'IndentFetch', 'PRCreatedInPortal', NOW(), 4);


    -- -------------------------------------------------------------------------
    -- STEP 5: Truncate pr_item_detail_recent before refill (stage table)
    --         Same as old SP TruncateStageTable
    -- -------------------------------------------------------------------------
    TRUNCATE TABLE erpinventory.pr_item_detail_recent;


    -- -------------------------------------------------------------------------
    -- STEP 6: Insert into pr_item_detail_recent (stage/recent table)
    --         Reads from tmp_oracle_indent_body (no second Oracle hit)
    --         Due date capped: if > 2050-12-31 → vrdate + 5 days (same as old SP)
    -- -------------------------------------------------------------------------
    INSERT INTO erpinventory.pr_item_detail_recent
        (document_no_yearly, document_date, sl_no, erp_item_uv, erp_make_uv,
         entity_code, due_date, db_no)
    SELECT
        ora.vrno,
        ora.vrdate::date,
        ora.slno::int,
        ora.item_code,
        ora.make_code,
        ora.entity_code,
        CASE
            WHEN ora.duedate > '2050-12-31'
            THEN (ora.vrdate::date + INTERVAL '5 days')::date
            ELSE ora.duedate::date
        END,
        db.id
    FROM tmp_oracle_indent_body ora
    INNER JOIN masterdata.db_master db
        ON db.code = ora.entity_code;


    -- -------------------------------------------------------------------------
    -- TODO: Create update live PR function (equivalent of RealDeals.Inventory.UpdateLiveIndent)
    --       This function should update PR status based on latest indent data
    -- -------------------------------------------------------------------------
     CALL erpinventory.update_live_pr();


    -- -------------------------------------------------------------------------
    -- JOB LOG: End
    -- NOTE: job_log table may not exist in new version — confirm before enabling
    -- -------------------------------------------------------------------------
    -- INSERT INTO masterdata.job_log (id, job_name, stage, log_date, seq_no)
    -- VALUES (v_job_id, 'IndentFetch', 'End', NOW(), 5);


    -- -------------------------------------------------------------------------
    -- STEP 7: Drop temp tables
    -- -------------------------------------------------------------------------
    DROP TABLE IF EXISTS tmp_oracle_indent_head;
    DROP TABLE IF EXISTS tmp_oracle_indent_body;


EXCEPTION
    WHEN OTHERS THEN

        DROP TABLE IF EXISTS tmp_oracle_indent_head;
        DROP TABLE IF EXISTS tmp_oracle_indent_body;

        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (NOW(), SQLSTATE, SQLERRM,
        --      'erpinventory.fetch_indent_from_lighthouse', CURRENT_USER, 'Job');

        RAISE;

END;
$$;

call erpinventory.fetch_indent_from_lighthouse();






-- =============================================
-- Author: Akash
-- Create date: 2026-07-11 (converted to PostgreSQL)
-- Description: Takes staged ERP PR data from erpinventory.pr_main /
--              pr_item_detail (populated by fetch_indent_from_lighthouse)
--              and creates the corresponding portal records in
--              inventory.purchase_request_main / purchase_request_item_detail,
--              then links the staging rows back via vp_pr_id / vp_pr_item_detail_id.
--
-- erp_serial_no_id is resolved via a lookup against
-- masterdata.erp_doc_serial_master, matched on form 'PMPO' + financial
-- year + company + division + series_type. pr_main.t_code (old TCode,
-- varchar(1)) is the same value as SeriesType in the document-serial
-- fetch ('Y'/'D'), so it's used as the match key. Rows with no matching
-- serial config are excluded from insertion (same gating behavior as
-- the department-mapping check) since the column is NOT NULL.
--
-- KNOWN GAPS (marked inline as TODO) — the new pr_main / pr_item_detail
-- staging tables do not currently carry these old RealIndentMain /
-- RealIndentBody fields, so placeholders/defaults are used below:
--   - expenditure_type_id (mandatory, Capital/Revenue) — no source at all
--   - priority_id (mandatory, item level) — old header had RIM.Priority,
--     but current pr_main insert list does not capture it
--   - schedule_date (mandatory, item level) — tmp_oracle_indent_body has
--     scheduledate/scheduleqty from Oracle, but pr_item_detail's insert
--     list does not persist them; falling back to due_date here
--   - ref_doc_no / ref_doc_date / requested_by / remarks (header level)
--     — not present in current pr_main staging columns
-- =============================================

CREATE OR REPLACE PROCEDURE erpinventory.create_portal_pr()
LANGUAGE plpgsql
AS $$
DECLARE
    v_system_user_id        INT      := 1;   -- CreatedBy/AuthorizedBy = 1 in original
    v_default_doc_status_id SMALLINT := 30;   -- old DocumentStatusNo = 30
    v_default_status_id     SMALLINT := 9;    -- old StatusNo = 1 (Authorize)
    v_default_expenditure_type_id SMALLINT := 1; -- CAPEX(1) / Opex(2) 
    v_default_priority_id   INT      := 1;    -- TODO: confirm default priority
    v_form_id                SMALLINT := 6;         -- form_id for Purchase Request
BEGIN

    -- -------------------------------------------------------------------------
    -- STEP 1: Insert new PR headers into inventory.purchase_request_main
    --         (skips duplicates already linked via vp_pr_id, and any header
    --          that would collide on company+department+doc_no_yearly+doc_date,
    --          same guard as the original dedupe/NOT EXISTS checks)
    -- -------------------------------------------------------------------------
    INSERT INTO inventory.purchase_request_main
        (company_id, division_id, doc_type_id, doc_no_yearly, doc_date, doc_series_id,
         display_doc_no_yearly, document_status_id, department_id, expenditure_type_id,
         ref_doc_no, ref_doc_date, requested_by, requested_by_contact_no,
         requested_by_contact_no_county_id, requested_by_email, net_amount,
         erp_serial_no_id, remarks, approval_setup_id, status_id,
         created_by_id, created_date, modified_by_id, modified_date,
         authorized_by_id, authorized_date, is_inserted_into_erp)
    SELECT
        cm.id,                                     -- company_id
        dv.vp_division_id,                          -- division_id
        (select id from masterdata.doc_type_master where form_id = 6 Order by id limit 1), -- doc type id                                        
        pm.doc_no_yearly,
        pm.doc_date,
        NULL,                                       -- doc_series_id: ERP docs bring their own number
        pm.doc_no_yearly,                           -- display_doc_no_yearly: set on first approval
        v_default_doc_status_id,
        dp.vp_department_id,                               -- department_id
        CASE WHEN pm.indent_type = 'C' THEN 1 ELSE 2 END, -- expenditure_type_id: CAPEX(1)/Opex(2)
        NULL,                                        -- ref_doc_no  -- TODO: not in pr_main staging
        NULL,                                        -- ref_doc_date -- TODO: not in pr_main staging
        NULL,                                        -- requested_by -- TODO: not in pr_main staging
        NULL,                                        -- requested_by_contact_no
        NULL,                                        -- requested_by_contact_no_county_id
        NULL,                                        -- requested_by_email
        0,                                           -- net_amount: recalculated downstream
        eds.id,                                      -- erp_serial_no_id
        NULL,                                        -- remarks -- TODO: not in pr_main staging
        NULL,                                        -- approval_setup_id
        v_default_status_id,
        v_system_user_id,
        NOW(),
        v_system_user_id,
        NOW(),
        v_system_user_id,
        NOW(),
        TRUE                                         -- is_inserted_into_erp
    FROM erpinventory.pr_main pm
    INNER JOIN masterdata.company_master cm
        ON cm.code = pm.entity_code
    INNER JOIN erpmaster.e_department_master dp
        ON dp.erp_unique_value = pm.erp_department_uv
       AND dp.db_id = pm.db_id
       AND dp.vp_department_id IS NOT NULL
    LEFT JOIN erpmaster.e_division_master dv
        ON dv.erp_unique_value = pm.erp_division_uv
       AND dv.db_id = pm.db_id
    INNER JOIN masterdata.fin_year fy
        ON fy."name" = pm.fy
    INNER JOIN masterdata.erp_doc_serial_master eds
        ON eds.form_id      = v_form_id
       AND eds.year_id      = fy.id
       AND eds.company_id   = cm.id
       AND eds.series_type  = pm.t_code
       AND (eds.division_id = dv.vp_division_id OR eds.division_id IS NULL)
    WHERE pm.vp_pr_id IS NULL
      AND NOT EXISTS (
            SELECT 1
            FROM inventory.purchase_request_main prm
            WHERE prm.company_id      = cm.id
              AND prm.department_id   = dp.vp_department_id
              AND prm.doc_no_yearly   = pm.doc_no_yearly
              AND prm.doc_date        = pm.doc_date
          );


    -- -------------------------------------------------------------------------
    -- STEP 2: Link staged PR headers back to their new portal id
    -- -------------------------------------------------------------------------
    UPDATE erpinventory.pr_main pm
    SET
        vp_pr_id      = prm.id
    FROM inventory.purchase_request_main prm
    INNER JOIN masterdata.company_master cm
        ON cm.id = prm.company_id
    WHERE prm.doc_no_yearly = pm.doc_no_yearly
      AND prm.doc_date      = pm.doc_date
      AND cm.code            = pm.entity_code
      AND pm.vp_pr_id IS NULL;


    -- -------------------------------------------------------------------------
    -- STEP 3: Insert new PR item detail lines into
    --         inventory.purchase_request_item_detail.
    --         pr_item_detail is already one row per line_no (deduped when
    --         staged), so no Sum/Max grouping is needed here unlike the
    --         original (which grouped raw Oracle body rows).
    -- -------------------------------------------------------------------------
    INSERT INTO inventory.purchase_request_item_detail
        (pur_req_id, line_no, item_id, make_id, tech_specification, unit_id,
         required_qty, pr_qty, balance_qty, po_qty, direct_po_qty, rfq_qty,
         rfq_balance_qty, rfq_release_qty, pr_cancel_qty, po_release_qty,
         rate, amount, schedule_date, cost_center_id, priority_id, remarks, status_id)
    SELECT
        prm.id,                          -- pur_req_id
        pid.line_no,
        eim.vp_item_id,                  -- item_id
        emm.vp_make_id,                  -- make_id (nullable)
        pid.tech_specification,
        eum.vp_unit_id,                  -- unit_id, via item's own e_unit_id
        pid.required_qty,
        pid.indent_qty,                  -- pr_qty (old IndentQty)
        pid.indent_qty,                  -- balance_qty: full qty available initially
        0,                                -- po_qty
        0,                                -- direct_po_qty
        0,                                -- rfq_qty
        0,                                -- rfq_balance_qty
        0,                                -- rfq_release_qty
        0,                                -- pr_cancel_qty
        0,                                -- po_release_qty
        pid.rate,
        pid.amount,
        pid.due_date,                    -- schedule_date -- TODO: real scheduledate not staged yet
        ecm.vp_cost_center_id,           -- cost_center_id (nullable)
        v_default_priority_id,           -- priority_id -- TODO: no source column yet
        pid.remarks,
        v_default_status_id
    FROM erpinventory.pr_item_detail pid
    INNER JOIN erpinventory.pr_main pm
        ON pm.id = pid.c_pr_id
    INNER JOIN inventory.purchase_request_main prm
        ON prm.id = pm.vp_pr_id
    INNER JOIN erpmaster.e_item_master eim
        ON eim.erp_unique_value = pid.erp_item_uv
       AND eim.db_id = pid.db_id
       AND eim.vp_item_id IS NOT NULL
    LEFT JOIN erpmaster.e_make_master emm
        ON emm.erp_unique_value = pid.erp_make_uv
       AND emm.db_id = pid.db_id
    LEFT JOIN erpmaster.e_unit_master eum
        ON eum.id = eim.e_unit_id
    LEFT JOIN erpmaster.e_cost_center_master ecm
        ON ecm.erp_unique_value = pid.erp_cost_center_uv
       AND ecm.db_id = pid.db_id
    WHERE pid.vp_pr_item_detail_id IS NULL
      AND pm.vp_pr_id IS NOT NULL
      AND (pid.erp_make_uv IS NULL OR (pid.erp_make_uv IS NOT NULL AND emm.vp_make_id IS NOT NULL));


    -- -------------------------------------------------------------------------
    -- STEP 4: Link staged PR item lines back to their new portal ids
    -- -------------------------------------------------------------------------
       UPDATE erpinventory.pr_item_detail pid
    SET
        vp_pr_id             = pm.vp_pr_id,
        vp_pr_item_detail_id = prid.id
    FROM erpinventory.pr_main pm,
         inventory.purchase_request_item_detail prid
    WHERE pm.id           = pid.c_pr_id
      AND prid.pur_req_id = pm.vp_pr_id
      AND prid.line_no    = pid.line_no
      AND pid.vp_pr_item_detail_id IS NULL;



    -- -------------------------------------------------------------------------
    -- STEP 5: Recalculate net_amount on purchase_request_main as the sum of
    --         its item detail amounts (old proc left this to a later/separate
    --         update; done here so it's never left at 0 after items are added)
    -- -------------------------------------------------------------------------
    UPDATE inventory.purchase_request_main prm
    SET
        net_amount    = sub.total_amount,
        modified_by_id = v_system_user_id,
        modified_date  = NOW()
    FROM (
        SELECT pur_req_id, COALESCE(SUM(amount), 0) AS total_amount
        FROM inventory.purchase_request_item_detail
        GROUP BY pur_req_id
    ) sub
    INNER JOIN erpinventory.pr_main pm
        ON pm.vp_pr_id = sub.pur_req_id
    WHERE prm.id = sub.pur_req_id
      AND prm.net_amount IS DISTINCT FROM sub.total_amount;
 
 
EXCEPTION
    WHEN OTHERS THEN

        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (NOW(), SQLSTATE, SQLERRM,
        --      'erpinventory.create_portal_pr', CURRENT_USER, 'Indent');

        RAISE;

END;
$$;

call erpinventory.create_portal_pr()



-- =============================================
-- Author:  (converted from [Inventory].[UpdateLiveIndent])
-- Create date: 2026-07-11 (converted to PostgreSQL)
-- Description: Expires PR item lines that have dropped out of the latest
--              ERP "recent" snapshot, and refreshes the open/PO-in-progress
--              status of lines that are still live, based on how much PO
--              quantity has been raised against them.
--
-- Status code mapping (old StatusNo -> new status_id):
--   16 (Expired)            -> 5
--   2  (PO Created/Processed) -> 11
--   1  (Open)                -> 9
--   8  (Partially PO'd)      -> 10
--
-- KNOWN GAP: purchase_request_item_detail has no expiry_reason column yet
-- (old IndentItemDetail.ExpiryReason). The reset-to-NULL step is left
-- commented below — add the column and uncomment once it exists.
-- =============================================

CREATE OR REPLACE PROCEDURE erpinventory.update_live_pr()
LANGUAGE plpgsql
AS $$
BEGIN

    -- -------------------------------------------------------------------------
    -- STEP 1: Expire PR item lines that are no longer present in the latest
    --         ERP recent snapshot (pr_item_detail_recent), for PRs that have
    --         already been authorized in the portal.
    -- -------------------------------------------------------------------------
    UPDATE inventory.purchase_request_item_detail prid
    SET status_id = 5   -- Expired (old StatusNo = 16)
    WHERE prid.id NOT IN (
            SELECT pid.vp_pr_item_detail_id
            FROM erpinventory.pr_item_detail pid
            INNER JOIN erpinventory.pr_main pm
                ON pm.id = pid.c_pr_id
            INNER JOIN erpinventory.pr_item_detail_recent rec
                ON rec.document_no_yearly        = pm.doc_no_yearly
               AND rec.document_date             = pm.doc_date
               AND rec.entity_code               = pm.entity_code
               AND rec.erp_item_uv               = pid.erp_item_uv
               AND COALESCE(rec.erp_make_uv, '') = COALESCE(pid.erp_make_uv, '')
               AND rec.sl_no                     = pid.line_no
               AND rec.db_no                     = pm.db_id
            WHERE pid.vp_pr_item_detail_id IS NOT NULL
          )
      AND prid.status_id <> 11   -- old StatusNo <> 2 (don't touch already-processed lines)
      AND prid.pur_req_id IN (
            SELECT id
            FROM inventory.purchase_request_main
            WHERE authorized_by_id IS NOT NULL
          );


    -- -------------------------------------------------------------------------
    -- STEP 2: Refresh status of lines still present in the recent snapshot,
    --         based on PO quantity raised against them so far, but only
    --         while status is Expired or PO-Created/Processed (5 or 11) and
    --         the PR quantity hasn't been fully covered by POs yet.
    -- -------------------------------------------------------------------------
    UPDATE inventory.purchase_request_item_detail prid
    SET status_id = CASE WHEN calc.total_po_qty = 0 THEN 9 ELSE 10 END
        -- , expiry_reason = NULL  -- TODO: add expiry_reason column to
        --                            purchase_request_item_detail, then uncomment
    FROM (
        SELECT
            pid.vp_pr_item_detail_id AS item_detail_id,
            COALESCE(SUM(po.po_qty), 0) AS total_po_qty
        FROM erpinventory.pr_item_detail pid
        INNER JOIN erpinventory.pr_main pm
            ON pm.id = pid.c_pr_id
        INNER JOIN erpinventory.pr_item_detail_recent rec
            ON rec.document_no_yearly        = pm.doc_no_yearly
           AND rec.document_date             = pm.doc_date
           AND rec.entity_code               = pm.entity_code
           AND rec.erp_item_uv               = pid.erp_item_uv
           AND COALESCE(rec.erp_make_uv, '') = COALESCE(pid.erp_make_uv, '')
           AND rec.sl_no                     = pid.line_no
           AND rec.db_no                     = pm.db_id
        LEFT JOIN purchase.purchase_order_pr_item_detail po
            ON po.pr_item_detail_id = pid.vp_pr_item_detail_id
        WHERE pid.vp_pr_item_detail_id IS NOT NULL
        GROUP BY pid.vp_pr_item_detail_id
    ) calc
    WHERE prid.id = calc.item_detail_id
      AND prid.status_id IN (11, 5)               -- old StatusNo in (2, 16)
      AND prid.pr_qty > calc.total_po_qty;         -- old IndentQty > ISNULL(POQty,0)


EXCEPTION
    WHEN OTHERS THEN

        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (NOW(), SQLSTATE, SQLERRM,
        --      'erpinventory.update_live_pr', CURRENT_USER, 'Indent');

        RAISE;

END;
$$;

call erpinventory.update_live_pr();



















