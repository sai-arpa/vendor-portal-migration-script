
-- =============================================
-- Author: Akash     
-- Create date: 2026-06-08
-- Description: Fetches Make Master data from Oracle (via foreign table),
--              inserts new records into erpmaster.e_make_master,
--              creates new masterdata.make_master entries for unmapped makes,
--              and links them back via vp_make_id.
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_make_from_lighthouse()
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_seq   INT;
BEGIN

    -- -------------------------------------------------------------------------
    -- STEP 1: Insert new ERP make records (not yet in e_make_master)
    --         Hits oracle_make_mast (foreign table) ONCE here only
    -- -------------------------------------------------------------------------
    INSERT INTO erpmaster.e_make_master
        (code, make_name, erp_unique_value, vp_make_id, db_id, created_date, modified_date, inactive)
    SELECT
        ora.make_code,
        ora.make_name,
        ora.make_code,          -- erp_unique_value = make_code
        NULL,                   -- vp_make_id: not yet mapped
        db.id,                      -- db_id: default 1
        NOW(),
        NOW(),
        FALSE                   -- inactive: default false
    FROM oracle_make_mast ora
    INNER JOIN masterdata.db_master db
        ON db.code = ora.entity_code
    LEFT JOIN erpmaster.e_make_master eim
        ON eim.erp_unique_value = ora.make_code
       AND eim.db_id = db.id
    WHERE eim.id IS NULL
      AND ora.make_name IS NOT NULL;


    -- -------------------------------------------------------------------------
    -- STEP 2: Determine next sequence for make_master code generation
    --         Code format: MM0001, MM0002, ...
    -- -------------------------------------------------------------------------
    SELECT COALESCE(
        MAX( CAST( RIGHT(code, 4) AS INT ) ),
        0
    )
    INTO v_max_seq
    FROM masterdata.make_master;


    -- -------------------------------------------------------------------------
    -- STEP 3: Insert new master makes (not yet in make_master by name)
    --         Reads only local erpmaster.e_make_master — no Oracle hit
    -- -------------------------------------------------------------------------
    INSERT INTO masterdata.make_master
        (code, make_name, alias, status_id, status_remarks, created_by_id, created_date, modified_by_id, modified_date)
    SELECT
        'MM' || LPAD( CAST( ROW_NUMBER() OVER (ORDER BY eim.make_name) + v_max_seq AS TEXT ), 4, '0' ),
        eim.make_name,
        eim.code,                       -- alias: code
        1,                              -- status_id: default active
        NULL,                           -- status_remarks
        1,                              -- created_by_id: default 1
        NOW(),
        1,                              -- modified_by_id: default 1
        NOW()
    FROM erpmaster.e_make_master eim
    LEFT JOIN masterdata.make_master mm
        ON mm.make_name = eim.make_name
    WHERE mm.id IS NULL;


    -- -------------------------------------------------------------------------
    -- STEP 4: Update vp_make_id in e_make_master for newly linked records
    --         Reads only local tables — no Oracle hit
    -- -------------------------------------------------------------------------
    UPDATE erpmaster.e_make_master eim
    SET
        vp_make_id    = mm.id,
        modified_date = NOW()
    FROM masterdata.make_master mm
    WHERE mm.make_name    = eim.make_name
      AND eim.vp_make_id IS NULL;


EXCEPTION
    WHEN OTHERS THEN

        -- Log error into error log table
--        INSERT INTO masterdata.error_log
--            (error_date, error_code, error_message, error_procedure, user_name, form_code)
--        VALUES
--            (
--                NOW(),
--                SQLSTATE,
--                SQLERRM,
--                'erpmaster.fetch_make_from_lighthouse',
--                CURRENT_USER,
--                'Job'
--            );

        -- Re-raise so the caller knows it failed
        RAISE;

END;
$$;

call erpmaster.fetch_make_from_lighthouse();




-- =============================================
-- Author:  Akash
-- Create date: 2026-06-08
-- Description: Fetches Unit Master data from Oracle (via foreign table),
--              inserts new records into erpmaster.e_unit_master,
--              creates new masterdata.unit_master entries for unmapped units,
--              and links them back via vp_unit_id.
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_unit_from_lighthouse()
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_seq   INT;
    v_new_code  VARCHAR(6);
BEGIN
    -- -------------------------------------------------------------------------
    -- STEP 1: Insert new ERP unit records (not yet in e_unit_master)
    --         Hits oracle_unit_mast (foreign table) ONCE here only
    -- -------------------------------------------------------------------------
    INSERT INTO erpmaster.e_unit_master
        (code, unit_name, erp_unique_value, alias, vp_unit_id, db_id, created_date, modified_date, inactive)
    SELECT
        ora.um_code,
        ora.um_name,
        ora.um_code,            -- erp_unique_value = um_code
        ora.um_code,            -- alias = um_code (as stored in ERP)
        NULL,                   -- vp_unit_id: not yet mapped
        db.id,                      -- db_id: default 1
        NOW(),
        NOW(),
        FALSE                   -- inactive: default false
    FROM oracle_unit_mast ora
    INNER JOIN masterdata.db_master db
        ON db.code = ora.entity_code
    LEFT JOIN erpmaster.e_unit_master eim
        ON eim.erp_unique_value = ora.um_code
       AND eim.db_id = db.id
    WHERE eim.id IS NULL;
    -- -------------------------------------------------------------------------
    -- STEP 2: Determine next sequence for unit_master code generation
    --         Code format: UM0001, UM0002, ...
    -- -------------------------------------------------------------------------
    SELECT COALESCE(
        MAX( CAST( RIGHT(code, 4) AS INT ) ),
        0
    )
    INTO v_max_seq
    FROM masterdata.unit_master;
    -- -------------------------------------------------------------------------
    -- STEP 3: Insert new master units (not yet in unit_master by name)
    --         alias = code
    --         Reads only local erpmaster.e_unit_master — no Oracle hit
    -- -------------------------------------------------------------------------
    INSERT INTO masterdata.unit_master
        (code, unit_name, alias, status_id, status_remarks, created_by_id, created_date, modified_by_id, modified_date)
    SELECT
        'UM' || LPAD( CAST( ROW_NUMBER() OVER (ORDER BY eim.unit_name) + v_max_seq AS TEXT ), 4, '0' ),
        eim.unit_name,
        eim.alias,
        1,                      -- status_id: default active
        NULL,                   -- status_remarks
        1,                      -- created_by_id: default 1
        NOW(),
        1,                      -- modified_by_id: default 1
        NOW()
    FROM erpmaster.e_unit_master eim
    LEFT JOIN masterdata.unit_master um
        ON um.unit_name = eim.unit_name
    WHERE um.id IS NULL;
    -- -------------------------------------------------------------------------
    -- STEP 4: Update vp_unit_id in e_unit_master for newly linked records
    --         Reads only local tables — no Oracle hit
    -- -------------------------------------------------------------------------
    UPDATE erpmaster.e_unit_master eim
    SET
        vp_unit_id    = um.id,
        modified_date = NOW()
    FROM masterdata.unit_master um
    WHERE um.unit_name    = eim.unit_name
      AND eim.vp_unit_id IS NULL;
EXCEPTION
    WHEN OTHERS THEN
        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (
        --         NOW(),
        --         SQLSTATE,
        --         SQLERRM,
        --         'erpmaster.fetch_unit_from_lighthouse',
        --         CURRENT_USER,
        --         'Job'
        --     );

        RAISE;
END;
$$;

call erpmaster.fetch_unit_from_lighthouse();



-- =============================================
-- Author: Akash
-- Create date: 2026-06-08
-- Description: Fetches Vendor Master and Vendor Location data from Oracle
--              (via foreign tables) and inserts new records into
--              erpmaster.e_vendor_master and erpmaster.e_vendor_location.
--              Does NOT populate masterdata tables.
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_vendor_master()
LANGUAGE plpgsql
AS $$
BEGIN
    -- -------------------------------------------------------------------------
    -- STEP 1: Insert new ERP vendor records (not yet in e_vendor_master)
    --         Source: oracle_acc_mast (VIEW_PP_ACC_MAST)
    --         Oracle hit ONCE — direct insert, no temp table
    --         Excludes vendors where acc_code starts with 'd'
    -- -------------------------------------------------------------------------
    INSERT INTO erpmaster.e_vendor_master
        (code, vendor_name, erp_unique_value, vp_bp_type_id, vp_vendor_id, db_id, created_date, modified_date, inactive)
    SELECT
        ora.acc_code,                           -- code = acc_code
        ora.acc_name,                           -- vendor_name
        ora.acc_code,                           -- erp_unique_value = acc_code
        CASE WHEN LEFT(ora.acc_code, 1) = 'T'   
             THEN 2                             -- Transporter(2)
             ELSE 1                             -- Supplier(1)
        END,                                    
        NULL,                                   -- vp_vendor_id: not yet mapped
        6,                                  -- db_id from db_master
        NOW(),
        NOW(),
        FALSE                                   -- inactive: default false
    FROM oracle_acc_mast ora
    LEFT JOIN erpmaster.e_vendor_master evm
        ON evm.erp_unique_value = ora.acc_code
       AND evm.db_id = 6
    WHERE evm.id IS NULL
      AND ora.acc_name IS NOT NULL
      AND ora.acc_code NOT ILIKE 'd%';          -- exclude 'd%' vendors because it is customer in lighthouse
    -- -------------------------------------------------------------------------
    -- STEP 2: Insert new ERP vendor location records (not yet in e_vendor_location)
    --         Source: oracle_address_mast (VIEW_PP_ADDRESS_MAST)
    --         Oracle hit ONCE — direct insert, no temp table
    --         erp_unique_value  = acc_code  (UniqueValue1 in old SP)
    --         erp_unique_value_2 = slno     (UniqueValue2 in old SP)
    --         Excludes vendors where acc_code starts with 'd'
    --         Excludes records where pin length > 6
    -- -------------------------------------------------------------------------
    INSERT INTO erpmaster.e_vendor_location_master
        (e_vendor_id, erp_unique_value, erp_unique_value2, code,
         address1, address2, address3,
         e_city_id, e_state_id, e_country_id,
         contact_no, email, website,
         cin_no, gstin_no, pan_no,
         db_id, created_date, modified_date, inactive)
    SELECT
        evm.id,                                 -- e_vendor_id from already-inserted e_vendor_master
        ora.acc_code,                           -- erp_unique_value = acc_code
        ora.slno,                               -- erp_unique_value_2 = slno
        ora.acc_code,                           -- code = acc_code
        LEFT(ora.add1, 100),                    -- address_1 (capped at varchar(100))
        ora.add2,                               -- address_2
        ora.add3,                               -- address_3
        NULL,                                   -- e_city_id: not mapped yet
        NULL,                                   -- e_state_id: not mapped yet
        NULL,                                   -- e_country_id: not mapped yet (old SP hardcoded 'INDIA')
        LEFT(ora.phone,15),                     -- contact_no
        LEFT(ora.email,320),                    -- email
        NULL,                                   -- website: not in source
        NULL,                                   -- cin_no: not in source
        ora.gstinno,                            -- gstin_no
        LEFT(ora.pager,10),                              -- pan_no (mapped from PAGER column in old SP)
        6,                                  -- db_id from db_master
        NOW(),
        NOW(),
        FALSE                                   -- inactive: default false
    FROM oracle_address_mast ora
    INNER JOIN erpmaster.e_vendor_master evm
        ON evm.erp_unique_value = ora.acc_code
       AND evm.db_id = 6
    LEFT JOIN erpmaster.e_vendor_location_master evl
        ON evl.erp_unique_value  = ora.acc_code
       AND evl.erp_unique_value2 = ora.slno
       AND evl.db_id = 6
    WHERE evl.id IS NULL
      AND ora.acc_name IS NOT NULL
      AND ora.acc_code NOT ILIKE 'd%'           -- exclude 'd%' vendors because it is customer in lighthouse
      AND LENGTH(ora.pin) <= 6;                 -- exclude invalid pin lengths
EXCEPTION
    WHEN OTHERS THEN
        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (
        --         NOW(),
        --         SQLSTATE,
        --         SQLERRM,
        --         'erpmaster.fetch_vendor_master',
        --         CURRENT_USER,
        --         'Job'
        --     );

        RAISE;
END;
$$;

call erpmaster.fetch_vendor_master();



-- =============================================
-- Author: Akash
-- Create date: 2026-06-08
-- Description: Fetches Location Master data from Oracle (via foreign table),
--              inserts new records into erpmaster.e_location_master,
--              creates new masterdata.location_master entries for unmapped locations,
--              and links them back via vp_location_id.
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_location_from_lighthouse()
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_seq   INT;
BEGIN
    -- -------------------------------------------------------------------------
    -- STEP 1: Insert new ERP location records (not yet in e_location_master)
    --         Source: oracle_area_mast (VIEW_PP_AREA_MAST)
    --         Oracle hit ONCE — direct insert, no temp table
    -- -------------------------------------------------------------------------
    INSERT INTO erpmaster.e_location_master
        (code, location_name, erp_unique_value, vp_location_id, db_id, created_date, modified_date, inactive)
    SELECT
        ora.area_code,                          -- code = area_code
        ora.area_name,                          -- location_name
        ora.area_code,                          -- erp_unique_value = area_code
        NULL,                                   -- vp_location_id: not yet mapped
        db.id,                                  -- db_id via company_master
        NOW(),
        NOW(),
        FALSE                                   -- inactive: default false
    FROM oracle_area_mast ora
    INNER JOIN masterdata.db_master db
        ON db.code = ora.entity_code
    LEFT JOIN erpmaster.e_location_master eim
        ON eim.erp_unique_value = ora.area_code
       AND eim.db_id = db.id
    WHERE eim.id IS NULL;
    -- -------------------------------------------------------------------------
    -- STEP 2: Determine next sequence for location_master code generation
    --         Code format: LM0001, LM0002, ...
    -- -------------------------------------------------------------------------
    SELECT COALESCE(
        MAX( CAST( RIGHT(code, 4) AS INT ) ),
        0
    )
    INTO v_max_seq
    FROM masterdata.location_master;
    -- -------------------------------------------------------------------------
    -- STEP 3: Insert new master locations (not yet in location_master by name)
    --         alias = generated code (LM0001 etc.), capped at VARCHAR(6)
    --         Reads only local erpmaster.e_location_master — no Oracle hit
    -- -------------------------------------------------------------------------
INSERT INTO masterdata.location_master
    (code, alias, location_name, status_id, status_remarks,
     created_by_id, created_date, modified_by_id, modified_date)
SELECT
    'LM' || LPAD(
        CAST(ROW_NUMBER() OVER (ORDER BY src.location_name) + v_max_seq AS TEXT),
        4,
        '0'
    ),
    LEFT(src.code, 6),
    src.location_name,
    1,
    NULL,
    1,
    NOW(),
    1,
    NOW()
FROM (
    SELECT DISTINCT ON (location_name)
        code,
        location_name
    FROM erpmaster.e_location_master
    ORDER BY location_name, code
) src
WHERE NOT EXISTS (
    SELECT 1
    FROM masterdata.location_master lm
    WHERE lm.location_name = src.location_name
);
    -- -------------------------------------------------------------------------
    -- STEP 4: Update vp_location_id in e_location_master for newly linked records
    --         Reads only local tables — no Oracle hit
    -- -------------------------------------------------------------------------
    UPDATE erpmaster.e_location_master elm
    SET
        vp_location_id = lm.id,
        modified_date  = NOW()
    FROM masterdata.location_master lm
    WHERE lm.location_name   = elm.location_name
      AND elm.vp_location_id IS NULL;
EXCEPTION
    WHEN OTHERS THEN
        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (
        --         NOW(),
        --         SQLSTATE,
        --         SQLERRM,
        --         'erpmaster.fetch_location_from_lighthouse',
        --         CURRENT_USER,
        --         'Job'
        --     );

        RAISE;
END;
$$;

call erpmaster.fetch_location_from_lighthouse();




-- =============================================
-- Author:  Akash
-- Create date: 09-07-2026
-- Description: Fetches Division & Department Master data from Oracle
--              (via foreign tables), inserts new records into
--              erpmaster.e_division_master / e_dept_master,
--              creates new masterdata.division_master /
--              dept_master entries for unmapped rows, maps them
--              to companies, and links them back via
--              vp_division_id / vp_department_id.
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_div_and_dept_from_lighthouse()
LANGUAGE plpgsql
AS $$
DECLARE
    v_default_db_id INT := 6;   -- hardcoded in original script; kept as-is
BEGIN

    -- -------------------------------------------------------------------------
    -- STEP 0: Pull Oracle data ONCE into temp tables (auto-dropped on commit)
    -- -------------------------------------------------------------------------
    CREATE TEMP TABLE temp_oracle_div_mast ON COMMIT DROP AS
    SELECT div_code, div_name, entity_code
    FROM oracle_div_mast;

    CREATE TEMP TABLE temp_oracle_dept_mast ON COMMIT DROP AS
    SELECT dept_code, dept_name, entity_code
    FROM oracle_dept_mast;


    -- =========================================================================
    -- DIVISION MASTER
    -- =========================================================================

    -- STEP 1: Insert new ERP division records (not yet in e_division_master)
    INSERT INTO erpmaster.e_division_master
        (erp_unique_value, code, division_name, db_id, created_date, modified_date, inactive)
    SELECT
        ora.div_code,
        ora.div_code,
        ora.div_name,
        v_default_db_id,
        NOW(),
        NOW(),
        FALSE
    FROM (
        SELECT div_code, div_name
        FROM temp_oracle_div_mast
        GROUP BY div_code, div_name
    ) ora
    LEFT JOIN erpmaster.e_division_master eim
        ON eim.erp_unique_value = ora.div_code
       AND eim.db_id = v_default_db_id
    WHERE eim.id IS NULL
      AND ora.div_name IS NOT NULL;
    -- STEP 2: Insert new master divisions (anti-joined by code, not by null FK)
    INSERT INTO masterdata.division_master
        (code, division_name, created_by_id, created_date, modified_by_id, modified_date,status_id)
    SELECT
        elm.code,
        elm.division_name,
        1,
        NOW(),
        1,
        NOW(),
		1
    FROM erpmaster.e_division_master elm
    LEFT JOIN masterdata.division_master dm
        ON dm.code = elm.code
    WHERE dm.id IS NULL;
    -- STEP 3: Map divisions to active companies
    INSERT INTO masterdata.division_company_detail
        (division_id, company_id,status_id)
    SELECT
        lm.id,
        cm.id,
        CASE WHEN ora.entity_code = cm.code THEN 1 ELSE 2 END
    FROM erpmaster.e_division_master elm
    INNER JOIN masterdata.division_master lm
        ON lm.division_name = elm.division_name
       AND lm.code = elm.code
    INNER JOIN masterdata.company_master cm
        ON cm.status_id = 1
    LEFT JOIN temp_oracle_div_mast ora
        ON ora.div_code = elm.code
       AND ora.entity_code = cm.code
    LEFT JOIN masterdata.division_company_detail dmcd
        ON dmcd.division_id = lm.id
       AND dmcd.company_id = cm.id
    WHERE elm.vp_division_id IS NULL
      AND dmcd.company_id IS NULL;
    -- STEP 4: Back-fill vp_division_id
    UPDATE erpmaster.e_division_master elm
    SET
        vp_division_id = lm.id,
        modified_date  = NOW()
    FROM masterdata.division_master lm
    WHERE lm.code = elm.code
      AND elm.vp_division_id IS NULL;
    -- =========================================================================
    -- DEPARTMENT MASTER
    -- =========================================================================
    -- STEP 5: Insert new ERP department records (not yet in e_department_master)
    INSERT INTO erpmaster.e_department_master
        (erp_unique_value, code, department_name, db_id, created_date, modified_date, inactive)
    SELECT
        ora.dept_code,
        ora.dept_code,
        ora.dept_name,
        v_default_db_id,
        NOW(),
        NOW(),
        FALSE
    FROM temp_oracle_dept_mast ora
    LEFT JOIN erpmaster.e_department_master eim
        ON eim.erp_unique_value = ora.dept_code
       AND eim.db_id = v_default_db_id
    WHERE eim.id IS NULL
      AND ora.dept_name IS NOT NULL;
    -- STEP 6: Insert new master departments (anti-joined by code)
    INSERT INTO masterdata.department_master
        (code, department_name, created_by_id, created_date, modified_by_id, modified_date,status_id)
    SELECT
        elm.code,
        elm.department_name,
        1,
        NOW(),
        1,
        NOW(),
		1
    FROM erpmaster.e_department_master elm
    LEFT JOIN masterdata.department_master dm
        ON dm.code = elm.code
    WHERE dm.id IS NULL;
    -- STEP 7: Map departments to active companies and divisions
INSERT INTO masterdata.department__company_division_detail
    (department_id, company_id, division_id)
SELECT
    lm.id AS department_id,
    cm.id AS company_id,
    dm.id AS division_id
FROM erpmaster.e_department_master elm
INNER JOIN masterdata.department_master lm
    ON lm.department_name = elm.department_name
   AND lm.code = elm.code
INNER JOIN masterdata.company_master cm
    ON cm.status_id = 1
INNER JOIN masterdata.division_master dm
    ON dm.status_id = 1      -- if division_master has status_id
LEFT JOIN masterdata.department__company_division_detail dcd
    ON dcd.department_id = lm.id
   AND dcd.company_id = cm.id
   AND dcd.division_id = dm.id
WHERE elm.vp_department_id IS NULL
  AND dcd.department_id IS NULL;
    -- STEP 8: Back-fill vp_department_id
    UPDATE erpmaster.e_department_master elm
    SET
        vp_department_id    = lm.id,
        modified_date = NOW()
    FROM masterdata.department_master lm
    WHERE lm.department_name = elm.department_name
      AND lm.code = elm.code
      AND elm.vp_department_id IS NULL;
EXCEPTION
    WHEN OTHERS THEN

        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (
        --         NOW(),
        --         SQLSTATE,
        --         SQLERRM,
        --         'erpmaster.fetch_div_and_dept_from_lighthouse',
        --         CURRENT_USER,
        --         'Job'
        --     );

        RAISE;
END;
$$;

call erpmaster.fetch_div_and_dept_from_lighthouse();



-- =============================================
-- Author:
-- Create date: 2026-06-08
-- Description: Fetches Cost Center Master data from Oracle (via foreign table),
--              inserts new records into erpmaster.e_cost_center_master,
--              creates new masterdata.cost_center_master entries,
--              and maps masterdata.cost_center_company_detail directly
--
-- Blank/NULL entity_code from Oracle → all active companies
-- Blank/NULL div_code from Oracle    → all active divisions
-- Both blank/NULL                    → all active companies × all active divisions
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_cost_center_from_lighthouse()
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_seq   INT;
BEGIN

    -- -------------------------------------------------------------------------
    -- STEP 1: Load Oracle cost center data into temp table
    --         Oracle hit ONCE — reused across all steps
    --         Source filter: NVL(STATUS,'R') = 'R'  (active records only)
    -- -------------------------------------------------------------------------
    CREATE TEMP TABLE tmp_oracle_cc AS
    SELECT
        entity_code,
        div_code,
        cost_code,
        cost_name
    FROM oracle_cost_mast
    WHERE COALESCE(status, 'R') = 'R';


    -- -------------------------------------------------------------------------
    -- STEP 2: Insert new ERP cost center records (not yet in e_cost_center_master)
    --         Deduplicate by cost_code + cost_name
    -- -------------------------------------------------------------------------
    INSERT INTO erpmaster.e_cost_center_master
        (code, cost_center_name, erp_unique_value, e_parent_cost_center_id, vp_cost_center_id, db_id, created_date, modified_date, inactive)
    SELECT
        ora.cost_code,
        ora.cost_name,
        ora.cost_code,              -- erp_unique_value = cost_code
        NULL,                       -- e_cost_center_id: parent, not mapped yet
        NULL,                       -- vp_cost_center_id: not yet mapped
        db.id,                      -- db_id via company_master
        NOW(),
        NOW(),
        FALSE
    FROM (
        SELECT DISTINCT cost_code, cost_name, entity_code
        FROM tmp_oracle_cc
    ) ora
    INNER JOIN masterdata.db_master db
        ON db.code = ora.entity_code
    LEFT JOIN erpmaster.e_cost_center_master eim
        ON eim.erp_unique_value = ora.cost_code
       AND eim.db_id = db.id
    WHERE eim.id IS NULL
      AND NOT EXISTS (
            SELECT 1
            FROM erpmaster.e_cost_center_master eim2
            WHERE eim2.db_id = db.id
              AND eim2.cost_center_name = ora.cost_name
      );


    -- -------------------------------------------------------------------------
    -- STEP 3: Determine next sequence for cost_center_master code generation
    --         Code format: CC0001, CC0002, ...
    -- -------------------------------------------------------------------------
    SELECT COALESCE(
        MAX( CAST( RIGHT(code, 4) AS INT ) ),
        0
    )
    INTO v_max_seq
    FROM masterdata.cost_center_master;


    -- -------------------------------------------------------------------------
    -- STEP 4: Insert new masterdata cost center records (not yet present by name)
    --         Reads only local e_cost_center_master — no Oracle hit
    -- -------------------------------------------------------------------------
    INSERT INTO masterdata.cost_center_master
        (code, cost_center_name, alias, parent_cost_center_id, status_id, status_remarks,
         created_by_id, created_date, modified_by_id, modified_date)
    SELECT
        'CC' || LPAD( CAST( ROW_NUMBER() OVER (ORDER BY eccm.cost_center_name) + v_max_seq AS TEXT ), 4, '0' ),
        eccm.cost_center_name,
        LEFT(eccm.code, 15),        -- alias = cost_code from ERP, capped at varchar(15)
        NULL,                       -- parent_cost_center_id: not mapped yet
        1,                          -- status_id: default active
        NULL,                       -- status_remarks
        1,                          -- created_by_id: default 1
        NOW(),
        1,                          -- modified_by_id: default 1
        NOW()
    FROM erpmaster.e_cost_center_master eccm
    LEFT JOIN masterdata.cost_center_master ccm
        ON ccm.cost_center_name = eccm.cost_center_name
    WHERE ccm.id IS NULL;


    -- -------------------------------------------------------------------------
    -- STEP 5: Update vp_cost_center_id in e_cost_center_master
    -- -------------------------------------------------------------------------
    UPDATE erpmaster.e_cost_center_master eccm
    SET
        vp_cost_center_id = ccm.id,
        modified_date     = NOW()
    FROM masterdata.cost_center_master ccm
    WHERE ccm.cost_center_name    = eccm.cost_center_name
      AND eccm.vp_cost_center_id IS NULL;


    -- -------------------------------------------------------------------------
    -- STEP 6: Clear both detail tables — full refresh every run
    --         masterdata deleted first to respect FK dependency
    -- -------------------------------------------------------------------------
    DELETE FROM masterdata.cost_center_company_detail;


    -- -------------------------------------------------------------------------
    -- STEP 7: Insert masterdata.cost_center_company_detail directly from
    --
    --         entity_code blank/NULL → all active companies
    --         div_code blank/NULL    → all active divisions
    --         Both blank/NULL        → all active companies × all active divisions
    --         If entity_code provided but not in company_master   → skip row
    --         If div_code provided but not in e_division_master   → skip row
    -- -------------------------------------------------------------------------
    INSERT INTO masterdata.cost_center_company_detail
        (cost_center_id, company_id, division_id)
    SELECT DISTINCT
        ccm.id,
        cm.id,
        dm.id
    FROM tmp_oracle_cc ora

    -- Resolve cost center
    INNER JOIN erpmaster.e_cost_center_master eccm
        ON eccm.erp_unique_value = ora.cost_code
    INNER JOIN masterdata.cost_center_master ccm
        ON ccm.id = eccm.vp_cost_center_id

    -- Resolve company:
    --   blank/NULL entity_code → all active companies
    --   else match on erp_company_unique_id
    INNER JOIN masterdata.company_master cm
        ON (
            (ora.entity_code IS NULL OR ora.entity_code = '')
            OR cm.erp_company_unique_id = ora.entity_code
        )
        AND cm.status_id = 1

    -- Resolve division:
    --   blank/NULL div_code → all active divisions
    --   else match on erp_unique_value in e_division_master → division_master
    INNER JOIN masterdata.division_master dm
        ON (
            ora.div_code IS NULL
            OR ora.div_code = ''
            OR EXISTS (
                SELECT 1
                FROM erpmaster.e_division_master edm
                WHERE edm.erp_unique_value = ora.div_code
                  AND edm.vp_division_id   = dm.id
                  AND edm.inactive         = FALSE
            )
        )

    -- Ensure division is valid for this company
    INNER JOIN masterdata.division_company_detail dcd
        ON dcd.division_id = dm.id
       AND dcd.company_id  = cm.id

    -- If div_code was provided but not found in e_division_master → skip
    WHERE (
        ora.div_code IS NULL
        OR ora.div_code = ''
        OR EXISTS (
            SELECT 1
            FROM erpmaster.e_division_master edm
            WHERE edm.erp_unique_value = ora.div_code
              AND edm.inactive         = FALSE
        )
    );
    -- -------------------------------------------------------------------------
    -- STEP 8: Drop temp table
    -- -------------------------------------------------------------------------
    DROP TABLE IF EXISTS tmp_oracle_cc;
EXCEPTION
    WHEN OTHERS THEN
        DROP TABLE IF EXISTS tmp_oracle_cc;
        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (
        --         NOW(),
        --         SQLSTATE,
        --         SQLERRM,
        --         'erpmaster.fetch_cost_center_from_lighthouse',
        --         CURRENT_USER,
        --         'Job'
        --     );
        RAISE;
END;
$$;

call erpmaster.fetch_cost_center_from_lighthouse();



-- =============================================
-- Author:  Akash
-- Create date: 2026-06-08 (converted to PostgreSQL)
-- Description: Fetches Document Serial config from Oracle (via foreign
--              table) and inserts new rows directly into the
--              consolidated masterdata.erp_doc_serial_master table.
--              Unlike unit/division/dept masters, this table merges
--              the "ERP staging" and "master" concepts into one row
--              (ERPUniqueId column instead of a separate e_ table).
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_document_serial_from_lighthouse()
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyear_name VARCHAR(5);
    v_fyear_id   INT;
    v_form_id    SMALLINT;
BEGIN

    -- -------------------------------------------------------------------------
    -- STEP 1: Resolve current financial year
    -- -------------------------------------------------------------------------
    SELECT name, id
    INTO v_fyear_name, v_fyear_id
    FROM masterdata.fin_year
    WHERE CURRENT_DATE BETWEEN start_date AND end_date;

    -- -------------------------------------------------------------------------
    -- STEP 2: Resolve FormId for 'PMPO' (was hardcoded FormCode in original)
    -- -------------------------------------------------------------------------
    SELECT id
    INTO v_form_id
    FROM globaldata.form_master
    WHERE form_code = 'PMPO';

    -- -------------------------------------------------------------------------
    -- STEP 3: Insert new document serial rows (deduped on series/type/company/year)
    --         Hits oracle_config_mast (foreign table) ONCE here only
    -- -------------------------------------------------------------------------
    INSERT INTO masterdata.erp_doc_serial_master
        (form_id, year_id, series, series_type, description, company_id, division_id,
         status_id, status_remarks, is_default, erp_unique_id, display_name, created_by_id, created_date, modified_date)
    SELECT
        v_form_id,
        v_fyear_id,
        ora.series,
        ora.seriestype,
        ora.bheading,
        cm.id,
        dm.vp_division_id,
        1,              -- status_id: default active
        NULL,           -- status_remarks
        FALSE,          -- is_default
        ora.series,     
        ora.bheading,    -- display_name: mandatory column, source has no separate value
		1,
		Now(),
		Now()
	FROM oracle_config_mast ora
    INNER JOIN masterdata.company_master cm
        ON cm.status_id = 1
       AND cm.code = ora.entity_code
    LEFT JOIN masterdata.erp_doc_serial_master ds
        ON ds.series      = ora.series
       AND ds.series_type = ora.seriestype
       AND ds.company_id  = cm.id
       AND ds.year_id     = v_fyear_id
    LEFT JOIN erpmaster.e_division_master dm
        ON dm.db_id = 6
       AND dm.code  = ora.div_code
    LEFT JOIN masterdata.division_company_detail dmcd
        ON COALESCE(dmcd.division_id, 0) = COALESCE(dm.vp_division_id, 0)
       AND COALESCE(dmcd.company_id, 0)  = COALESCE(cm.id, 0)
    WHERE ora.acc_year    = v_fyear_name
      AND ora.tnature     = 'ORDI'
      AND ora.seriestype IN ('Y', 'D')
      AND (
            (dm.vp_division_id IS NOT NULL AND ora.div_code IS NOT NULL AND dmcd.division_id IS NOT NULL)
            OR ora.div_code IS NULL
          )
      AND ora.bheading IS NOT NULL
      AND ora.series   IS NOT NULL
      AND ds.id IS NULL
    ORDER BY ora.div_code;


EXCEPTION
    WHEN OTHERS THEN

        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (
        --         NOW(),
        --         SQLSTATE,
        --         SQLERRM,
        --         'erpmaster.fetch_document_serial_from_lighthouse',
        --         CURRENT_USER,
        --         'Job'
        --     );

        RAISE;

END;
$$;

call erpmaster.fetch_document_serial_from_lighthouse();



-- =============================================
-- Author:  Akash
-- Create date: 2026-06-08 (converted to PostgreSQL)
-- Description: Fetches Item Master data from Oracle (via foreign table)
--              and inserts new records into erpmaster.e_item_master.
--              Note: unlike unit/division/dept, this table's new schema
--              has no Size/Grade/ItemDescription/SubGroup-FK columns and
--              no separate masterdata.item_master creation step here —
--              vp_item_id is populated by a later mapping process, same
--              as it was left unmapped (ERPItemNo carried, ItemNo null)
--              in the original script.
-- =============================================
 
CREATE OR REPLACE PROCEDURE erpmaster.fetch_item_from_lighthouse()
LANGUAGE plpgsql
AS $$
BEGIN
 
    -- -------------------------------------------------------------------------
    -- STEP 1: Insert new ERP item records (not yet in e_item_master)
    --         Hits oracle_item_mast (foreign table) ONCE here only
    -- -------------------------------------------------------------------------
    INSERT INTO erpmaster.e_item_master
        (erp_unique_value, code, item_name, e_unit_id, item_nature, category_name,
         group_name, subgroup_name, hsn_sac_code, vp_item_id, purchase_emp_code,
         db_id, created_date, modified_date, inactive)
    SELECT
        ora.item_code,
        ora.item_code,
        ora.item_name,
        eum.id,             -- e_unit_id: FK to e_unit_master's own id (not vp_unit_id)
        ora.item_nature,
        NULL,               -- category_name: not supplied by source
        ora.item_group_name,
        ora.item_sub_group_name,
        NULL,               -- hsn_sac_code: not supplied by source
        NULL,               -- vp_item_id: not yet mapped
        ora.purchase_emp_code,
        db.id,
        NOW(),
        NOW(),
        FALSE               -- inactive: default false, as hardcoded in original source query
    FROM oracle_item_mast ora
    INNER JOIN masterdata.db_master db
        ON db.code = ora.entity_code
    INNER JOIN erpmaster.e_unit_master eum
        ON eum.erp_unique_value = ora.unit
       AND eum.db_id = db.id
    LEFT JOIN erpmaster.e_item_master eim
        ON eim.erp_unique_value = ora.item_code
       AND eim.db_id = db.id
    WHERE eim.id IS NULL;
 
 
    -- -------------------------------------------------------------------------
    -- STEP 2: Truncate item rename tracking table
    --         Original called RealDeals.Purchase.TruncateItemRename — convert
    --         that procedure separately and call its Postgres equivalent here.
    -- -------------------------------------------------------------------------
    -- CALL erpmaster.truncate_item_rename();
 
    -- -------------------------------------------------------------------------
    -- Rename Item logic was commented out in the original source script too —
    -- kept disabled here for parity. Uncomment and adapt once needed:
    -- -------------------------------------------------------------------------
    -- INSERT INTO erpmaster.e_renamed_item_master
    --     (company_code, erp_unique_value, item_name, unit, db_id)
    -- SELECT ora.entity_code, ora.item_code, ora.item_name, ora.unit, db.id
    -- FROM oracle_item_mast ora
    -- INNER JOIN masterdata.db_master db ON db.code = ora.entity_code
    -- INNER JOIN erpmaster.e_item_master eim
    --     ON eim.erp_unique_value = ora.item_code AND eim.db_id = db.id
    -- WHERE TRIM(ora.item_name) <> eim.item_name;
 
 
EXCEPTION
    WHEN OTHERS THEN
 
        -- INSERT INTO masterdata.error_log
        --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
        -- VALUES
        --     (
        --         NOW(),
        --         SQLSTATE,
        --         SQLERRM,
        --         'erpmaster.fetch_item_from_lighthouse',
        --         CURRENT_USER,
        --         'Job'
        --     );
 
        RAISE;
 
END;
$$;

call erpmaster.fetch_item_from_lighthouse()

-- =============================================
-- Author:
-- Create date: 2026-06-08
-- Description: Fetches Item Schedule (Category/Group/Subgroup) and Item Master
--              from Oracle, creates/updates masterdata tables, logs renames,
--              and deletes/inactivates records removed from Oracle.
--              Wrapped in a single transaction — full rollback on any error.
-- =============================================

CREATE OR REPLACE PROCEDURE erpmaster.fetch_and_create_item_master()
LANGUAGE plpgsql
AS $$
BEGIN
    -- =========================================================================
    -- START TRANSACTION
    -- =========================================================================
    BEGIN
        -- ---------------------------------------------------------------------
        -- STEP 1: Load Oracle data into temp tables (Oracle hit ONCE each)
        -- ---------------------------------------------------------------------
        CREATE TEMP TABLE tmp_oracle_sch AS
        SELECT
            item_sch,
            item_sch_name,
            code_level,
            short_name,
            parent_code
        FROM oracle_item_sch_mast;

        CREATE TEMP TABLE tmp_oracle_item AS
        SELECT
            entity_code,
            item_code,
            item_name,
            item_group_name,
            item_sub_group_name,
            unit,
            l1_name,
            l2_name,
            l3_name,
            sub_group,
            purchase_emp_code,
            item_nature
        FROM oracle_item_mast;


        -- =====================================================================
        -- CATEGORY MASTER
        -- =====================================================================

        -- ---------------------------------------------------------------------
        -- STEP 2: Insert new ERP category records (code_level = 1)
        -- ---------------------------------------------------------------------
        INSERT INTO erpmaster.e_category_master
            (code, category_name, erp_unique_value, alias, vp_category_id, db_id, created_date, modified_date, inactive)
        SELECT
            ora.item_sch,
            ora.item_sch_name,
            ora.item_sch,
            ora.short_name,
            NULL,
            db.id,
            NOW(),
            NOW(),
            FALSE
        FROM tmp_oracle_sch ora
        INNER JOIN masterdata.db_master db         -- fixed db reference same as old SP
            ON db.id = '6'
        LEFT JOIN erpmaster.e_category_master eim
            ON eim.erp_unique_value = ora.item_sch
        WHERE ora.code_level = '1'
          AND eim.id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 3: Insert new masterdata category records
        -- ---------------------------------------------------------------------
        INSERT INTO masterdata.category_master
            (code, category_name, status_id, status_remarks, created_by_id, created_date, modified_by_id, modified_date)
        SELECT
            (SELECT LPAD(UPPER(TO_HEX(COALESCE(MAX(('x' || code)::bit(64)::bigint), 0) + 1)),2,'0') AS next_code
			FROM masterdata.category_master
			WHERE code ~ '^[0-9A-Fa-f]{2}$'),           -- code = ERP unique value directly
            ecm.category_name,
            1,
            NULL,
            1,
            NOW(),
            1,
            NOW()
        FROM erpmaster.e_category_master ecm
        LEFT JOIN masterdata.category_master cm
            ON ecm.vp_category_id = cm.id   -- avoid duplicate via link
        WHERE cm.id IS NULL
          AND ecm.vp_category_id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 4: Link vp_category_id
        -- ---------------------------------------------------------------------
        UPDATE erpmaster.e_category_master ecm
        SET
            vp_category_id = cm.id,
            modified_date  = NOW()
        FROM masterdata.category_master cm
        WHERE cm.code          = ecm.erp_unique_value
          AND ecm.vp_category_id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 5: Update renamed categories
        -- ---------------------------------------------------------------------
        WITH renamed_cat AS (
            SELECT
                ecm.id              AS e_category_id,
                cm.id               AS vp_category_id,
                ora.item_sch_name   AS new_name,
                ecm.erp_unique_value
            FROM erpmaster.e_category_master ecm
            INNER JOIN masterdata.category_master cm
                ON cm.id = ecm.vp_category_id
            LEFT JOIN tmp_oracle_sch ora
                ON ora.item_sch = ecm.erp_unique_value
               AND ora.code_level = '1'
            WHERE ora.item_sch_name IS NOT NULL
              AND ora.item_sch_name <> cm.category_name
        )
        -- Log rename
        -- INSERT INTO masterdata.master_rename_log_detail
        --     (operation_flag, table_name, id, erp_unique_value, old_name, new_name, created_date)
        -- SELECT 'Update', 'category_master', rc.vp_category_id, rc.erp_unique_value,
        --        cm.category_name, rc.new_name, NOW()
        -- FROM renamed_cat rc
        -- INNER JOIN masterdata.category_master cm ON cm.id = rc.vp_category_id;

        UPDATE erpmaster.e_category_master ecm
        SET category_name = ora.item_sch_name, modified_date = NOW()
        FROM tmp_oracle_sch ora
        INNER JOIN masterdata.category_master cm ON cm.code = ora.item_sch
        WHERE ora.item_sch = ecm.erp_unique_value
          AND ora.code_level = '1'
          AND ora.item_sch_name <> ecm.category_name;

        UPDATE masterdata.category_master cm
        SET category_name = ora.item_sch_name, modified_date = NOW()
        FROM erpmaster.e_category_master ecm
        INNER JOIN tmp_oracle_sch ora ON ora.item_sch = ecm.erp_unique_value AND ora.code_level = '1'
        WHERE ecm.vp_category_id = cm.id
          AND ora.item_sch_name <> cm.category_name;


        -- =====================================================================
        -- GROUP MASTER
        -- =====================================================================

        -- ---------------------------------------------------------------------
        -- STEP 6: Insert new ERP group records (code_level = 2)
        -- ---------------------------------------------------------------------
        INSERT INTO erpmaster.e_group_master
            (code, group_name, erp_unique_value, e_category_id, alias, vp_group_id, db_id, created_date, modified_date, inactive)
        SELECT
            ora.item_sch,
            ora.item_sch_name,
            ora.item_sch,
            ecm.id,
            COALESCE(ora.short_name,ora.item_sch),
            NULL,
            ecm.db_id,
            NOW(),
            NOW(),
            FALSE
        FROM tmp_oracle_sch ora
        INNER JOIN erpmaster.e_category_master ecm
            ON ecm.erp_unique_value = ora.parent_code
        LEFT JOIN erpmaster.e_group_master eim
            ON eim.erp_unique_value = ora.item_sch
        WHERE ora.code_level = '2'
          AND eim.id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 7: Insert new masterdata group records
        --         group_code = category.code(2) + group.code(2)
        -- ---------------------------------------------------------------------
        INSERT INTO masterdata.group_master
    (code, group_code, group_name, category_id,
     status_id, status_remarks,
     created_by_id, created_date,
     modified_by_id, modified_date)
SELECT
    nxt.next_code,                                   -- Generated group code
    cm.code || nxt.next_code,                        -- category_code + group_code
    egm.group_name,
    cm.id,
    1,
    NULL,
    1,
    NOW(),
    1,
    NOW()
FROM erpmaster.e_group_master egm
INNER JOIN erpmaster.e_category_master ecm
    ON ecm.id = egm.e_category_id
INNER JOIN masterdata.category_master cm
    ON cm.id = ecm.vp_category_id
LEFT JOIN masterdata.group_master gm
    ON egm.vp_group_id = gm.id
CROSS JOIN LATERAL (
    SELECT LPAD(
               UPPER(
                   TO_HEX(
                       COALESCE(
                           MAX(('x' || g.code)::bit(64)::bigint),
                           0
                       ) + 1
                   )
               ),
               2,
               '0'
           ) AS next_code
    FROM masterdata.group_master g
    WHERE g.category_id = cm.id
      AND g.code ~ '^[0-9A-Fa-f]{2}$'
) nxt

WHERE gm.id IS NULL
  AND egm.vp_group_id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 8: Link vp_group_id
        -- ---------------------------------------------------------------------
        UPDATE erpmaster.e_group_master egm
			SET
    		vp_group_id   = gm.id,
   			 modified_date = NOW()
		FROM masterdata.group_master gm,
     	erpmaster.e_category_master ecm,
     	masterdata.category_master cm
		WHERE ecm.id          = egm.e_category_id
  		AND cm.id            = ecm.vp_category_id
  		AND gm.code           = egm.erp_unique_value
  		AND gm.category_id    = cm.id
  		AND egm.vp_group_id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 9: Update renamed groups
        -- ---------------------------------------------------------------------
        WITH renamed_grp AS (
            SELECT egm.id AS e_group_id, gm.id AS vp_group_id,
                   ora.item_sch_name AS new_name, egm.erp_unique_value
            FROM erpmaster.e_group_master egm
            INNER JOIN masterdata.group_master gm ON gm.id = egm.vp_group_id
            LEFT JOIN tmp_oracle_sch ora
                ON ora.item_sch = egm.erp_unique_value AND ora.code_level = '2'
            WHERE ora.item_sch_name IS NOT NULL
              AND ora.item_sch_name <> gm.group_name
        )
        -- INSERT INTO masterdata.master_rename_log_detail
        --     (operation_flag, table_name, id, erp_unique_value, old_name, new_name, created_date)
        -- SELECT 'Update', 'group_master', rc.vp_group_id, rc.erp_unique_value,
        --        gm.group_name, rc.new_name, NOW()
        -- FROM renamed_grp rc
        -- INNER JOIN masterdata.group_master gm ON gm.id = rc.vp_group_id;

        UPDATE erpmaster.e_group_master egm
        SET group_name = ora.item_sch_name, modified_date = NOW()
        FROM tmp_oracle_sch ora
        WHERE ora.item_sch = egm.erp_unique_value
          AND ora.code_level = '2'
          AND ora.item_sch_name <> egm.group_name;

        UPDATE masterdata.group_master gm
        SET group_name = ora.item_sch_name, modified_date = NOW()
        FROM erpmaster.e_group_master egm
        INNER JOIN tmp_oracle_sch ora ON ora.item_sch = egm.erp_unique_value AND ora.code_level = '2'
        WHERE egm.vp_group_id = gm.id
          AND ora.item_sch_name <> gm.group_name;


        -- =====================================================================
        -- SUBGROUP MASTER
        -- =====================================================================

        -- ---------------------------------------------------------------------
        -- STEP 10: Insert new ERP subgroup records (code_level = 3)
        -- ---------------------------------------------------------------------
        INSERT INTO erpmaster.e_subgroup_master
            (code, subgroup_name, erp_unique_value, e_group_id, alias, vp_subgroup_id, db_id, created_date, modified_date, inactive)
        SELECT
            ora.item_sch,
            ora.item_sch_name,
            ora.item_sch,
            egm.id,
            COALESCE(ora.short_name,ora.item_sch),
            NULL,
            egm.db_id,
            NOW(),
            NOW(),
            FALSE
        FROM tmp_oracle_sch ora
        INNER JOIN erpmaster.e_group_master egm
            ON egm.erp_unique_value = ora.parent_code
        LEFT JOIN erpmaster.e_subgroup_master eim
            ON eim.erp_unique_value = ora.item_sch
        WHERE ora.code_level = '3'
          AND eim.id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 11: Insert new masterdata subgroup records
        --          subgroup_code = cat.code(2) + grp.code(2) + subgrp.code(2)
        --          stock_unit_id resolved via e_unit_master alias match
        -- ---------------------------------------------------------------------
        INSERT INTO masterdata.subgroup_master
    (code, subgroup_code, subgroup_name, group_id, stock_unit_id,
     status_id, status_remarks, created_by_id, created_date, modified_by_id, modified_date)
SELECT
    nxt.next_code,
    cm.code || gm.code || nxt.next_code,      -- category + group + subgroup
    esgm.subgroup_name,
    gm.id,
    um.vp_unit_id,
    1,
    NULL,
    1,
    NOW(),
    1,
    NOW()
FROM erpmaster.e_subgroup_master esgm
INNER JOIN erpmaster.e_group_master egm
    ON egm.id = esgm.e_group_id
INNER JOIN masterdata.group_master gm
    ON gm.id = egm.vp_group_id
INNER JOIN masterdata.category_master cm
    ON cm.id = gm.category_id

-- Resolve unit via alias on e_unit_master
LEFT JOIN erpmaster.e_unit_master um
    ON um.code = esgm.code
   AND um.db_id = esgm.db_id

LEFT JOIN masterdata.subgroup_master sgm
    ON esgm.vp_subgroup_id = sgm.id

CROSS JOIN LATERAL (
    SELECT LPAD(
               UPPER(
                   TO_HEX(
                       COALESCE(
                           MAX(('x' || sg.code)::bit(64)::bigint),
                           0
                       ) + 1
                   )
               ),
               2,
               '0'
           ) AS next_code
    FROM masterdata.subgroup_master sg
    WHERE sg.group_id = gm.id
      AND sg.code ~ '^[0-9A-Fa-f]{2}$'
) nxt

WHERE sgm.id IS NULL
  AND esgm.vp_subgroup_id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 12: Link vp_subgroup_id
        -- ---------------------------------------------------------------------
        UPDATE erpmaster.e_subgroup_master esgm
        SET
            vp_subgroup_id = sgm.id,
            modified_date  = NOW()
        FROM masterdata.subgroup_master sgm
        WHERE sgm.code           = esgm.erp_unique_value
          AND esgm.vp_subgroup_id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 13: Update renamed subgroups
        -- ---------------------------------------------------------------------
        WITH renamed_sg AS (
            SELECT esgm.id AS e_subgroup_id, sgm.id AS vp_subgroup_id,
                   ora.item_sch_name AS new_name, esgm.erp_unique_value
            FROM erpmaster.e_subgroup_master esgm
            INNER JOIN masterdata.subgroup_master sgm ON sgm.id = esgm.vp_subgroup_id
            LEFT JOIN tmp_oracle_sch ora
                ON ora.item_sch = esgm.erp_unique_value AND ora.code_level = '3'
            WHERE ora.item_sch_name IS NOT NULL
              AND ora.item_sch_name <> sgm.subgroup_name
        )
        -- INSERT INTO masterdata.master_rename_log_detail
        --     (operation_flag, table_name, id, erp_unique_value, old_name, new_name, created_date)
        -- SELECT 'Update', 'subgroup_master', rc.vp_subgroup_id, rc.erp_unique_value,
        --        sgm.subgroup_name, rc.new_name, NOW()
        -- FROM renamed_sg rc
        -- INNER JOIN masterdata.subgroup_master sgm ON sgm.id = rc.vp_subgroup_id;

        UPDATE erpmaster.e_subgroup_master esgm
        SET subgroup_name = ora.item_sch_name, modified_date = NOW()
        FROM tmp_oracle_sch ora
        WHERE ora.item_sch = esgm.erp_unique_value
          AND ora.code_level = '3'
          AND ora.item_sch_name <> esgm.subgroup_name;

        UPDATE masterdata.subgroup_master sgm
        SET subgroup_name = ora.item_sch_name, modified_date = NOW()
        FROM erpmaster.e_subgroup_master esgm
        INNER JOIN tmp_oracle_sch ora ON ora.item_sch = esgm.erp_unique_value AND ora.code_level = '3'
        WHERE esgm.vp_subgroup_id = sgm.id
          AND ora.item_sch_name <> sgm.subgroup_name;


        -- =====================================================================
        -- ITEM MASTER
        -- =====================================================================

        -- ---------------------------------------------------------------------
        -- STEP 14: Insert new ERP item records (not yet in e_item_master)
        --          e_item_master is populated by a separate fetch SP;
        --          here we only create masterdata.item_master for unmapped items
        --          item_code = ERP item_code directly (same as old SP FullCode)
        --          stock_unit_id resolved via e_unit_master alias
        -- ---------------------------------------------------------------------
        INSERT INTO masterdata.item_master
    (item_name, code, item_code, stock_unit_id, subgroup_id,
     make_mgmt_type_id, is_multiunit_applicable,
     status_id, status_remarks, remarks,
     created_by_id, created_date, modified_by_id, modified_date)
SELECT
    eim.item_name,
    nxt.next_code,
    cm.code || gm.code || sgm.code || nxt.next_code,   -- item_code
    eum.vp_unit_id,
    sgm.id,
    1,
    FALSE,
    1,
    NULL,
    NULL,
    1,
    NOW(),
    1,
    NOW()
FROM erpmaster.e_item_master eim
INNER JOIN erpmaster.e_subgroup_master esgm
    ON esgm.erp_unique_value = (
        SELECT ora.sub_group
        FROM tmp_oracle_item ora
        WHERE ora.item_code = eim.erp_unique_value
        LIMIT 1
    )
INNER JOIN masterdata.subgroup_master sgm
    ON sgm.id = esgm.vp_subgroup_id
INNER JOIN masterdata.group_master gm
    ON gm.id = sgm.group_id
INNER JOIN masterdata.category_master cm
    ON cm.id = gm.category_id
INNER JOIN erpmaster.e_unit_master eum
    ON eum.id = eim.e_unit_id
LEFT JOIN masterdata.item_master mim
    ON mim.id = eim.vp_item_id

CROSS JOIN LATERAL (
    SELECT LPAD(
               UPPER(
                   TO_HEX(
                       COALESCE(
                           MAX(('x' || im.code)::bit(64)::bigint),
                           0
                       ) + 1
                   )
               ),
               4,
               '0'
           ) AS next_code
    FROM masterdata.item_master im
    WHERE im.subgroup_id = sgm.id
      AND im.code ~ '^[0-9A-Fa-f]{4}$'
) nxt

WHERE eim.vp_item_id IS NULL
  AND eim.inactive = FALSE;

        -- ---------------------------------------------------------------------
        -- STEP 15: Link vp_item_id
        -- ---------------------------------------------------------------------
        UPDATE erpmaster.e_item_master eim
        SET
            vp_item_id    = mim.id,
            modified_date = NOW()
        FROM masterdata.item_master mim
        WHERE mim.item_code    = eim.erp_unique_value
          AND eim.vp_item_id IS NULL;

        -- ---------------------------------------------------------------------
        -- STEP 16: Update changed items (name, unit, subgroup, purchase_emp_code)
        -- ---------------------------------------------------------------------
        CREATE TEMP TABLE tmp_item_updates AS
        SELECT
            eim.id              AS e_item_id,
            mim.id              AS vp_item_id,
            ora.item_name       AS new_item_name,
            ora.item_sub_group_name AS new_subgroup_name,
            ora.purchase_emp_code   AS new_purchase_emp_code,
            new_eum.id          AS new_e_unit_id,
            new_eum.vp_unit_id  AS new_vp_unit_id,
            new_esgm.id         AS new_e_subgroup_id,
            new_esgm.vp_subgroup_id AS new_vp_subgroup_id,
            eim.erp_unique_value
        FROM erpmaster.e_item_master eim
        INNER JOIN masterdata.item_master mim
            ON mim.id = eim.vp_item_id
        INNER JOIN tmp_oracle_item ora
            ON ora.item_code = eim.erp_unique_value
        -- Resolve new unit via alias
        INNER JOIN erpmaster.e_unit_master new_eum
            ON new_eum.code = ora.unit
           AND new_eum.db_id = eim.db_id
        -- Resolve new subgroup
        INNER JOIN erpmaster.e_subgroup_master new_esgm
            ON new_esgm.erp_unique_value = ora.sub_group
        WHERE eim.inactive = FALSE
          AND (
                eim.item_name         <> ora.item_name
             OR eim.e_unit_id         <> new_eum.id
             OR eim.subgroup_name     <> ora.item_sub_group_name
             OR COALESCE(eim.purchase_emp_code, '') <> COALESCE(ora.purchase_emp_code, '')
          );

        -- Log item renames
        -- INSERT INTO masterdata.item_rename_log_detail
        --     (operation_flag, item_id, erp_unique_value,
        --      old_subgroup_id, new_subgroup_id,
        --      old_unit_id, new_unit_id,
        --      old_item_description, new_item_description,
        --      old_purchase_emp_code, new_purchase_emp_code,
        --      created_date)
        -- SELECT
        --     'Update',
        --     mim.id,
        --     tu.erp_unique_value,
        --     mim.subgroup_id,        tu.new_vp_subgroup_id,
        --     mim.stock_unit_id,      tu.new_vp_unit_id,
        --     mim.item_name,          tu.new_item_name,
        --     eim.purchase_emp_code,  tu.new_purchase_emp_code,
        --     NOW()
        -- FROM tmp_item_updates tu
        -- INNER JOIN erpmaster.e_item_master eim ON eim.id = tu.e_item_id
        -- INNER JOIN masterdata.item_master mim  ON mim.id = tu.vp_item_id;

        -- Update e_item_master
        UPDATE erpmaster.e_item_master eim
        SET
            item_name         = tu.new_item_name,
            e_unit_id         = tu.new_e_unit_id,
            subgroup_name     = tu.new_subgroup_name,
            purchase_emp_code = tu.new_purchase_emp_code,
            modified_date     = NOW()
        FROM tmp_item_updates tu
        WHERE eim.id = tu.e_item_id;

        -- Update masterdata.item_master
        UPDATE masterdata.item_master mim
        SET
            item_name    = tu.new_item_name,
            stock_unit_id = tu.new_vp_unit_id,
            subgroup_id  = tu.new_vp_subgroup_id,
            modified_date = NOW()
        FROM tmp_item_updates tu
        WHERE mim.id = tu.vp_item_id;

        DROP TABLE IF EXISTS tmp_item_updates;


        -- =====================================================================
        -- DELETE / INACTIVE LOGIC
        -- =====================================================================

        -- ---------------------------------------------------------------------
        -- STEP 17: Item delete/inactive
        --          Check transactions across RFQ, PO, Indent before deciding
        -- ---------------------------------------------------------------------
--         CREATE TEMP TABLE tmp_delete_items AS
--         SELECT
--             eim.id                  AS e_item_id,
--             mim.id                  AS vp_item_id,
--             eim.erp_unique_value,
--             COALESCE(rfq.cnt, 0) + COALESCE(po.cnt, 0) + COALESCE(ind.cnt, 0) AS transaction_cnt
--         FROM erpmaster.e_item_master eim
--         INNER JOIN masterdata.item_master mim
--             ON mim.id = eim.vp_item_id
--         LEFT JOIN tmp_oracle_item ora
--             ON ora.item_code = eim.erp_unique_value
--         LEFT JOIN (
--             SELECT item_id, COUNT(1) cnt FROM purchase.pur_rfq_item_detail GROUP BY item_id
--         ) rfq ON rfq.item_id = mim.id
--         LEFT JOIN (
--             SELECT item_id, COUNT(1) cnt FROM purchase.purchase_order_item_detail GROUP BY item_id
--         ) po ON po.item_id = mim.id
--         LEFT JOIN (
--             SELECT item_id, COUNT(1) cnt FROM inventory.purchase_request_item_detail GROUP BY item_id
--         ) ind ON ind.item_id = mim.id
--         WHERE ora.item_code IS NULL
--           AND eim.inactive = FALSE;

--         -- Delete items with no transactions
--         DELETE FROM erpmaster.e_item_master
--         WHERE id IN (SELECT e_item_id FROM tmp_delete_items WHERE transaction_cnt = 0);

--         -- INSERT INTO masterdata.item_rename_log_detail
--         --     (operation_flag, item_id, erp_unique_value,
--         --      old_subgroup_id, new_subgroup_id, old_unit_id, new_unit_id,
--         --      old_item_description, new_item_description, created_date)
--         -- SELECT 'Delete', mim.id, di.erp_unique_value,
--         --        mim.subgroup_id, NULL, mim.stock_unit_id, NULL,
--         --        mim.item_name, NULL, NOW()
--         -- FROM tmp_delete_items di
--         -- INNER JOIN masterdata.item_master mim ON mim.id = di.vp_item_id
--         -- WHERE di.transaction_cnt = 0;

--         DELETE FROM masterdata.item_master
--         WHERE id IN (SELECT vp_item_id FROM tmp_delete_items WHERE transaction_cnt = 0);

--         -- Inactive items with transactions
--         UPDATE erpmaster.e_item_master eim
--         SET inactive = TRUE, modified_date = NOW()
--         FROM tmp_delete_items di
--         WHERE eim.id = di.e_item_id
--           AND di.transaction_cnt > 0;

--         -- INSERT INTO masterdata.item_rename_log_detail
--         --     (operation_flag, item_id, erp_unique_value,
--         --      old_subgroup_id, new_subgroup_id, old_unit_id, new_unit_id,
--         --      old_item_description, new_item_description, created_date)
--         -- SELECT 'Inactive', mim.id, di.erp_unique_value,
--         --        mim.subgroup_id, NULL, mim.stock_unit_id, NULL,
--         --        mim.item_name, NULL, NOW()
--         -- FROM tmp_delete_items di
--         -- INNER JOIN masterdata.item_master mim ON mim.id = di.vp_item_id
--         -- WHERE di.transaction_cnt > 0
--         --   AND mim.status_id <> 2;

--         UPDATE masterdata.item_master mim
--         SET status_id = 2, modified_date = NOW()         -- 2 = Inactive
--         FROM tmp_delete_items di
--         WHERE mim.id = di.vp_item_id
--           AND di.transaction_cnt > 0
--           AND mim.status_id <> 2;

--         DROP TABLE IF EXISTS tmp_delete_items;


--         -- ---------------------------------------------------------------------
--         -- STEP 18: Subgroup delete (only if no items remain and not in Oracle)
--         -- ---------------------------------------------------------------------
--         WITH del_sg AS (
--             SELECT esgm.id AS e_subgroup_id, sgm.id AS vp_subgroup_id, esgm.erp_unique_value
--             FROM erpmaster.e_subgroup_master esgm
--             INNER JOIN masterdata.subgroup_master sgm ON sgm.id = esgm.vp_subgroup_id
--             LEFT JOIN tmp_oracle_sch ora
--                 ON ora.item_sch = esgm.erp_unique_value AND ora.code_level = '3'
--             LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--             WHERE ora.item_sch IS NULL
--             GROUP BY esgm.id, sgm.id, esgm.erp_unique_value
--             HAVING COUNT(mim.id) = 0
--         )
--         -- INSERT INTO masterdata.master_rename_log_detail
--         --     (operation_flag, table_name, id, erp_unique_value, old_name, new_name, created_date)
--         -- SELECT 'Delete', 'subgroup_master', sgm.id, ds.erp_unique_value, sgm.subgroup_name, NULL, NOW()
--         -- FROM del_sg ds
--         -- INNER JOIN masterdata.subgroup_master sgm ON sgm.id = ds.vp_subgroup_id;

--         DELETE FROM erpmaster.e_subgroup_master
--         WHERE id IN (
--             SELECT esgm.id FROM erpmaster.e_subgroup_master esgm
--             INNER JOIN masterdata.subgroup_master sgm ON sgm.id = esgm.vp_subgroup_id
--             LEFT JOIN tmp_oracle_sch ora ON ora.item_sch = esgm.erp_unique_value AND ora.code_level = '3'
--             LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--             WHERE ora.item_sch IS NULL GROUP BY esgm.id HAVING COUNT(mim.id) = 0
--         );

--         DELETE FROM masterdata.subgroup_master
--         WHERE id IN (
--             SELECT sgm.id FROM masterdata.subgroup_master sgm
--             LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--             LEFT JOIN erpmaster.e_subgroup_master esgm ON esgm.vp_subgroup_id = sgm.id
--             WHERE esgm.id IS NULL GROUP BY sgm.id HAVING COUNT(mim.id) = 0
--         );


--         -- ---------------------------------------------------------------------
--         -- STEP 19: Group delete (only if no items remain and not in Oracle)
--         -- ---------------------------------------------------------------------
--         WITH del_grp AS (
--     SELECT egm.id AS e_group_id, gm.id AS vp_group_id, egm.erp_unique_value
--     FROM erpmaster.e_group_master egm
--     INNER JOIN masterdata.group_master gm ON gm.id = egm.vp_group_id
--     LEFT JOIN tmp_oracle_sch ora ON ora.item_sch = egm.erp_unique_value AND ora.code_level = '2'
--     LEFT JOIN masterdata.subgroup_master sgm ON sgm.group_id = gm.id
--     LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--     WHERE ora.item_sch IS NULL
--       AND NOT EXISTS (
--           SELECT 1 FROM masterdata.vendor_reg_location_item_group_detail vrl
--           WHERE vrl.item_group_id = gm.id
--       )
--     GROUP BY egm.id, gm.id, egm.erp_unique_value
--     HAVING COUNT(mim.id) = 0
-- )
--         -- INSERT INTO masterdata.master_rename_log_detail
--         --     (operation_flag, table_name, id, erp_unique_value, old_name, new_name, created_date)
--         -- SELECT 'Delete', 'group_master', gm.id, dg.erp_unique_value, gm.group_name, NULL, NOW()
--         -- FROM del_grp dg
--         -- INNER JOIN masterdata.group_master gm ON gm.id = dg.vp_group_id;

--         DELETE FROM erpmaster.e_group_master
-- WHERE id IN (
--     SELECT egm.id FROM erpmaster.e_group_master egm
--     INNER JOIN masterdata.group_master gm ON gm.id = egm.vp_group_id
--     LEFT JOIN tmp_oracle_sch ora ON ora.item_sch = egm.erp_unique_value AND ora.code_level = '2'
--     LEFT JOIN masterdata.subgroup_master sgm ON sgm.group_id = gm.id
--     LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--     WHERE ora.item_sch IS NULL
--       AND NOT EXISTS (
--           SELECT 1 FROM masterdata.vendor_reg_location_item_group_detail vrl
--           WHERE vrl.item_group_id = gm.id
--       )
--     GROUP BY egm.id HAVING COUNT(mim.id) = 0
-- );

-- DELETE FROM masterdata.group_master
-- WHERE id IN (
--     SELECT gm.id FROM masterdata.group_master gm
--     LEFT JOIN masterdata.subgroup_master sgm ON sgm.group_id = gm.id
--     LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--     LEFT JOIN erpmaster.e_group_master egm ON egm.vp_group_id = gm.id
--     WHERE egm.id IS NULL
--       AND NOT EXISTS (
--           SELECT 1 FROM masterdata.vendor_reg_location_item_group_detail vrl
--           WHERE vrl.item_group_id = gm.id
--       )
--     GROUP BY gm.id HAVING COUNT(mim.id) = 0
-- );


--         -- ---------------------------------------------------------------------
--         -- STEP 20: Category delete (only if no items remain and not in Oracle)
--         -- ---------------------------------------------------------------------
--         WITH del_cat AS (
--             SELECT ecm.id AS e_category_id, cm.id AS vp_category_id, ecm.erp_unique_value
--             FROM erpmaster.e_category_master ecm
--             INNER JOIN masterdata.category_master cm ON cm.id = ecm.vp_category_id
--             LEFT JOIN tmp_oracle_sch ora ON ora.item_sch = ecm.erp_unique_value AND ora.code_level = '1'
--             LEFT JOIN masterdata.group_master gm ON gm.category_id = cm.id
--             LEFT JOIN masterdata.subgroup_master sgm ON sgm.group_id = gm.id
--             LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--             WHERE ora.item_sch IS NULL
--             GROUP BY ecm.id, cm.id, ecm.erp_unique_value
--             HAVING COUNT(mim.id) = 0
--         )
--         -- INSERT INTO masterdata.master_rename_log_detail
--         --     (operation_flag, table_name, id, erp_unique_value, old_name, new_name, created_date)
--         -- SELECT 'Delete', 'category_master', cm.id, dc.erp_unique_value, cm.category_name, NULL, NOW()
--         -- FROM del_cat dc
--         -- INNER JOIN masterdata.category_master cm ON cm.id = dc.vp_category_id;

--         DELETE FROM erpmaster.e_category_master
--         WHERE id IN (
--             SELECT ecm.id FROM erpmaster.e_category_master ecm
--             INNER JOIN masterdata.category_master cm ON cm.id = ecm.vp_category_id
--             LEFT JOIN tmp_oracle_sch ora ON ora.item_sch = ecm.erp_unique_value AND ora.code_level = '1'
--             LEFT JOIN masterdata.group_master gm ON gm.category_id = cm.id
--             LEFT JOIN masterdata.subgroup_master sgm ON sgm.group_id = gm.id
--             LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--             WHERE ora.item_sch IS NULL GROUP BY ecm.id HAVING COUNT(mim.id) = 0
--         );

--         DELETE FROM masterdata.category_master
--         WHERE id IN (
--             SELECT cm.id FROM masterdata.category_master cm
--             LEFT JOIN masterdata.group_master gm ON gm.category_id = cm.id
--             LEFT JOIN masterdata.subgroup_master sgm ON sgm.group_id = gm.id
--             LEFT JOIN masterdata.item_master mim ON mim.subgroup_id = sgm.id
--             LEFT JOIN erpmaster.e_category_master ecm ON ecm.vp_category_id = cm.id
--             WHERE ecm.id IS NULL GROUP BY cm.id HAVING COUNT(mim.id) = 0
--         );


        -- ---------------------------------------------------------------------
        -- STEP 21: Drop temp tables
        -- ---------------------------------------------------------------------
        DROP TABLE IF EXISTS tmp_oracle_sch;
        DROP TABLE IF EXISTS tmp_oracle_item;

    -- =========================================================================
    -- COMMIT TRANSACTION
    -- =========================================================================

    EXCEPTION
        WHEN OTHERS THEN

            DROP TABLE IF EXISTS tmp_oracle_sch;
            DROP TABLE IF EXISTS tmp_oracle_item;
            DROP TABLE IF EXISTS tmp_item_updates;
            DROP TABLE IF EXISTS tmp_delete_items;

            -- INSERT INTO masterdata.error_log
            --     (error_date, error_code, error_message, error_procedure, user_name, form_code)
            -- VALUES
            --     (NOW(), SQLSTATE, SQLERRM,
            --      'erpmaster.fetch_and_create_item_master', CURRENT_USER, 'Job');

            RAISE;  -- triggers rollback of the entire transaction block

    END;

END;
$$;

call erpmaster.fetch_and_create_item_master();









