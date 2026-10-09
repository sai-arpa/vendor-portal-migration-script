
DO $MAIN$
BEGIN
    BEGIN

        -- Form Master UPSERT
       DELETE from masterdata.role_form_rights where form_id = 93;
       DELETE from globaldata.form_master where id = 93 ;


	   DELETE FROM masterdata.role_form_rights
		WHERE id IN
		(
    		SELECT rfr.id
    		FROM masterdata.role_form_rights AS rfr
    		INNER JOIN globaldata.form_master AS fm
        		ON fm.id = rfr.form_id
    		WHERE fm.parent_form_id = 67
		);

	   DELETE from globaldata.form_master as fm where fm.parent_form_id = 67;
       DELETE FROM globaldata.form_master WHERE id = 67;
 
        INSERT INTO globaldata.form_master
        (
            Id,
            Parent_Form_Id,
            Form_Caption,
            Form_Code,
            Form_Abbrevation,
            Access_Route,
            Seq_No,
            Icon,
            Is_Master,
            Is_Visible_To_Vendor,
            Is_Disable_Company_Wise_Doc_Series,
            Is_Doc_Series_Applicable,
            Is_Doc_Type_Applicable,
            Inactive
        )
        VALUES
        -- MAX ID = 104
        -- Root Nodes
 
            (  1, NULL, 'Transaction'                   , 'TRAN' , NULL, 'transaction'                                        ,    1, 'ri/RiFolderTransferLine'   , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            (  2, NULL, 'Security'                      , 'SECR' , NULL, 'security'                                           ,    8, 'ri/RiShieldKeyholeLine'    , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            (  4, NULL, 'Master'                        , 'MASTR', NULL, 'master'                                             ,    2, 'ri/RiDatabase2Line'        , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            (  5, NULL, 'Utility'                       , 'UTLY' , NULL, 'utility'                                            ,    6, 'ri/RiToolsLine'            , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 50, NULL, 'Work List'                     , 'WKLST', NULL, 'work-list'                                          ,    4, 'ri/RiListCheck2'           , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 60, NULL, 'Audit List'                    , 'ADLST', NULL, 'audit-list'                                         ,    5, 'ri/RiFilePaper2Line'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            (  3, NULL, 'Material Master'               , 'MSTM' , NULL, 'material-master'                                    ,    3, 'lu/LuPackageOpen'          , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
	        ( 96, NULL, 'Reports'                       , 'RPRT' , NULL, 'reports'                                            ,    7, 'ri/RiBarChartBoxLine'      , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),
 
        -- Purchase

            (  6,    1, 'Purchase Request'              , 'IPR'  , 'PR', 'transaction/purchase-request'                       ,    1, 'ri/RiFileList3Line'        , FALSE, FALSE, FALSE, TRUE , TRUE , FALSE),
            (  7,    1, 'Request For Quotation'         , 'PRFQ' , 'RFQ', 'transaction/request-for-quotation'                  ,    2, 'ri/RiQuestionAnswerLine'   , FALSE, FALSE, TRUE , TRUE , TRUE , FALSE),
            (  8,    1, 'Comparative Statement'         , 'PMCS' , 'CS', 'transaction/comparative-statement'                  ,    3, 'ri/RiScales3Line'          , FALSE, FALSE, TRUE , TRUE , TRUE , FALSE),
            (  9,    1, 'Quotation'                     , 'PCQT' , 'QTN', 'transaction/quotation'                              ,    4, 'ri/RiPriceTag3Line'        , FALSE, FALSE, TRUE , FALSE, FALSE, FALSE), -- For Comapny User
            ( 94,    1, 'Quotation'                     , 'PVQT' , 'QTN', 'transaction/quotation'                              ,    4, 'ri/RiPriceTag3Line'        , FALSE, TRUE , TRUE , FALSE, FALSE, FALSE),  -- For Vendor
            ( 10,    1, 'Purchase Order'                , 'POCU' , 'PO', 'transaction/purchase-order'                         ,    5, 'ri/RiShoppingCartLine'     , FALSE, FALSE, FALSE, TRUE , TRUE , FALSE),   -- For Comapny User
            ( 95,    1, 'Purchase Order'                , 'POVN' , 'PO', 'transaction/purchase-order'                         ,    5, 'ri/RiShoppingCartLine'     , FALSE, TRUE , FALSE, TRUE , TRUE , FALSE),   -- For Vendor
 
        -- Masters (Parent = 4)
 
            -- Organization Structure
            ( 23,    4, 'Company Master'                , 'ICOM' , NULL, 'master/company-master'                              ,    1, 'ri/RiBuilding4Line'        , TRUE , FALSE, FALSE, FALSE, FALSE, TRUE ),
            ( 24,    4, 'Division Master'               , 'IDIV' , NULL, 'master/division-master'                             ,    2, 'ri/RiGitMergeLine'         , TRUE , FALSE, FALSE, FALSE, FALSE, TRUE ),
            ( 87,    4, 'Company Location Master'       , 'CMPL' , NULL, 'master/company-location-master'                     ,    3, 'hi/HiOutlineOfficeBuilding', TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 27,    4, 'Department Master'             , 'IDPT' , NULL, 'master/department-master'                           ,    4, 'ri/RiTeamLine'             , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 21,    4, 'Cost Center Master'            , 'ICCM' , NULL, 'master/cost-center-master'                          ,    5, 'ri/RiMoneyDollarCircleLine', TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),

            -- Geography
            ( 15,    4, 'Country Master'                , 'CUCM' , NULL, 'master/country-master'                              ,    6, 'ri/RiEarthLine'            , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 16,    4, 'State Master'                  , 'SMSM' , NULL, 'master/state-master'                                ,    7, 'ri/RiMapPinLine'           , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 17,    4, 'City Master'                   , 'CMCM' , NULL, 'master/city-master'                                 ,    8, 'ri/RiBuildingLine'         , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 28,    4, 'Region Master'                 , 'IREG' , NULL, 'master/region-master'                               ,    9, 'ri/RiMapLine'              , TRUE , FALSE, FALSE, FALSE, FALSE, TRUE ),
            ( 18,    4, 'Location Master'               , 'LOCD' , NULL, 'master/location-master'                             ,   10, 'ri/RiMapPin2Line'          , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),

            -- Financial & System
            ( 88,    4, 'Currency Master'               , 'CURM' , NULL, 'master/currency-master'                             ,   11, 'gi/GiCash'                 , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 89,    4, 'Financial Year Master'         , 'FYM'  , NULL, 'master/financial-year-master'                       ,   12, 'fa6/FaRegCalendarDays'     , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 91,    4, 'Tax Master'                    , 'TAXM' , NULL, 'master/tax-master'                                  ,   13, 'fa/FaCashRegister'         , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 25,    4, 'Doc Series Master'             , 'IDOC' , NULL, 'settings/document-series-setup'                     ,   14, 'ri/RiFileList2Line'        , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 26,    4, 'Doc Type Master'               , 'IDTY' , NULL, 'master/doc-type-master'                             ,   15, 'ri/RiFileSettingsLine'     , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),

            -- Vendor Setup
            ( 29,    4, 'Business Type Master'          , 'IBUS' , NULL, 'master/business-type-master'                        ,   16, 'ri/RiBriefcaseLine'        , TRUE , FALSE, FALSE, FALSE, FALSE, TRUE ),
            ( 30,    4, 'Vendor Category Master'        , 'IVCT' , NULL, 'master/vendor-category-master'                      ,   17, 'ri/RiGroupLine'            , TRUE , FALSE, FALSE, FALSE, FALSE, TRUE ),
            ( 48,    4, 'Vendor Registration Master'    , 'IVVR' , NULL, 'master/vendor-registration'                         ,   18, 'ri/RiUserAddLine'          , TRUE , TRUE , FALSE, FALSE, FALSE, TRUE ),
            ( 49,    4, 'Vendor Master'                 , 'IVVM' , NULL, 'master/vendor-master'                               ,   19, 'ri/RiStore2Line'           , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 92,    4, 'Vendor Location Master'        , 'VNDL' , NULL, 'master/vendor-location-master'                      ,   20, 'md/MdMyLocation'           , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 22,    4, 'Vendor Attachment Master'      , 'VNDA' , NULL, 'master/vendor-attachment-master'                    ,   21, 'im/ImAttachment'           , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),

            -- Workflow
            ( 14,    4, 'Approval Setup Master'         , 'AUTH' , NULL, 'master/approval-setup-master'                       ,   22, 'ri/RiUserFollowLine'       , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 31,    4, 'Priority Master'               , 'IPRI' , NULL, 'master/priority-master'                             ,   23, 'ri/RiArrowUpCircleLine'    , TRUE , FALSE, FALSE, FALSE, FALSE, TRUE ),
            ( 90,    4, 'CS Reason Master'              , 'RESN' , NULL, 'master/cs-reason-master'                            ,   24, 'ri/RiIndentIncrease'       , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),

            -- Terms & Conditions
            ( 11,    4, 'Terms & Condition Head Master' , 'MTHG' , NULL, 'master/terms-and-conditions-head-master'            ,   25, 'ri/RiNewspaperLine'        , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 12,    4, 'Terms & Condition Group Master', 'MTCG' , NULL, 'master/terms-and-conditions-group-master'           ,   26, 'ri/RiFolderInfoLine'       , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),

			( 98,    4, 'Announcement Master'           , 'ANMM' , NULL, 'master/announcement-master'                         ,   28, 'bs/BsMegaphone'            , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
			( 99,    4, 'Expense Group Master'          , 'EXGM' , NULL, 'master/expense-group-master'                        ,   29, 'lu/LuCoins'                , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            (100,    4, 'Payment Terms Group Master'    , 'PTGM' , NULL, 'master/payment-terms-group-master'                  ,   30, 'lu/LuFileClock'            , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            (101,    4, 'PR Reason Master'              , 'PRRM' , NULL, 'master/pr-reason-master'                            ,   31, 'lu/LuFilePenLine'          , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            (102,    4, 'Tax Group Master'              , 'TAGM' , NULL, 'master/tax-group-master'                            ,   32, 'ai/AiOutlineGroup'         , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            (103,    4, 'Warehouse Master'              , 'WAHM' , NULL, 'master/warehouse-master'                            ,   33, 'lu/LuWarehouse'            , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),

        -- Material Master (Parent = 94)    

            ( 32,    3, 'Group Master'                  , 'IGRP' , NULL, 'master/item-group-master'                           ,    2, 'ri/RiFoldersLine'          , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 33,    3, 'Category Master'               , 'ICAT' , NULL, 'master/item-category-master'                        ,    1, 'ri/RiPriceTag2Line'        , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 34,    3, 'Subgroup Master'               , 'ISUG' , NULL, 'master/item-subgroup-master'                        ,    3, 'ri/RiFolder3Line'          , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 35,    3, 'Item Master'                   , 'IITE' , NULL, 'master/item-master'                                 ,    4, 'ri/RiBox3Line'             , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 19,    3, 'Unit Master'                   , 'INUM' , NULL, 'master/unit-master'                                 ,    9, 'ri/RiScalesLine'           , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 20,    3, 'Make Master'                   , 'IMKE' , NULL, 'master/make-master'                                 ,   10, 'ri/RiTrademarkLine'        , TRUE , FALSE, FALSE, FALSE, FALSE, FALSE),


	    -- Utility (Parent = 5)
 
            ( 36,    5, 'Skip Approval'                 , 'ISKP' , NULL, 'utility/skip-approval/new'                          ,    1, 'ri/RiSkipForwardLine'      , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 37,    5, 'Release Indent'                , 'IRER' , NULL, ''                                                   ,    3, 'ri/RiShareForwardLine'     , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 38,    5, 'Duplicate Item Group'          , 'IMDG' , NULL, 'utility/duplicate-item-group'                       ,    4, 'ri/RiFileCopyLine'         , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 39,    5, 'CS Validity'                   , 'CSVL' , NULL, 'utility/cs-validity/new'                            ,    5, 'ri/RiCalendarCheckLine'    , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 40,    5, 'Data Fetch Utility'            , 'IDFUT', NULL, 'utility/data-fetch'                                 ,    6, 'ri/RiDatabaseLine'         , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 41,    5, 'PO CS Exemption'               , 'IPEX' , NULL, 'utility/po-cs-exemptions'                           ,    7, 'ri/RiFileShieldLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 42,    5, 'PO Cancellation'               , 'IPPOC', NULL, 'utility/po-cancellation'                            ,    8, 'ri/RiCloseCircleLine'      , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 65,    5, 'Due Date Amendment'            , 'UDDA' , NULL, ''                                                   ,    9, 'ri/RiCalendarEventLine'    , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 66,    5, 'Add Vendor'                    , 'UAV'  , NULL, ''                                                   ,   10, 'ri/RiUserAddLine'          , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 84,    5, 'IP Whitelist'                  , 'UIPW' , NULL, 'utility/ip-whitelistings'                           ,   11, 'ri/RiFileShieldLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
	        ( 97,    5, 'PR Cancellation'               , 'PRCAN', NULL, 'utility/pr-cancellation'                            ,   12, 'tb/TbFilter2Cancel'        , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 104,   5, 'Backlog Entry'                 , 'SBLD',  NULL, 'utility/backlog-entry'                              ,   13, NULL                        , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 105,   5, 'Health Check'                  , 'HCHK',  NULL, 'utility/health-check'                              ,   14, 'ri/RiPulseLine'            , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
        
        -- Security (Parent = 2)

            ( 44,    2, 'User Access Control'           , 'IUUA' , NULL, 'security/user-access-control'                       ,    1, 'ri/RiLockUnlockLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, TRUE ),
            ( 45,    2, 'User Master'                   , 'IUSM' , NULL, 'security/user-master'                               ,    2, 'ri/RiUserSettingsLine'     , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 46,    2, 'Role Master'                   , 'IURLM', NULL, 'security/role-master'                               ,    3, 'ri/RiUserSettingsLine'     , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 47,    2, 'Supplier Account Master'       , 'SACM' , NULL, 'security/supplier-account-master'                   ,    4, 'ri/RiAccountBoxLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
 
 
        -- Work List (Parent = 48)

            ( 51,   50, 'Purchase Request Approval'     , 'IPRA' , NULL, 'transaction/purchase-request/pending-approvals'     ,    1, 'ri/RiCheckDoubleLine'      , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 52,   50, 'Purchase Order Approval'       , 'IPOA' , NULL, 'transaction/purchase-order/pending-approvals'       ,    2, 'ri/RiCheckDoubleLine'      , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 53,   50, 'Request For Quotation Approval', 'IPRFQ', NULL, 'transaction/request-for-quotation/pending-approvals',    4, 'ri/RiCheckDoubleLine'      , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 54,   50, 'Comparative Statement Approval', 'IPCS' , NULL, 'transaction/comparative-statement/pending-approvals',    5, 'ri/RiCheckDoubleLine'      , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),


        -- Vendor

            ( 55, NULL, 'Enquiry'                       , 'ENQR' , NULL, 'rfq/enquires'                                       , NULL, 'ri/RiMessage3Line'         , FALSE, TRUE , FALSE, FALSE, FALSE, FALSE),


        -- Audit List (Parent = 60)

            ( 61,   60, 'Purchase Request Audit'        , 'APR'  , NULL, 'transaction/purchase-request/pending-audit'         ,    1, 'ri/RiFileSearchLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 62,   60, 'Purchase Order Audit'          , 'APO'  , NULL, 'transaction/purchase-order/pending-audit'           ,    2, 'ri/RiFileSearchLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 63,   60, 'Request For Quotation Audit'   , 'ARFQ' , NULL, 'transaction/request-for-quotation/pending-audit'    ,    4, 'ri/RiFileSearchLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
            ( 64,   60, 'Comparative Statement Audit'   , 'ACS'  , NULL, 'transaction/comparative-statement/pending-audit'    ,    5, 'ri/RiFileSearchLine'       , FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),

		-- Auction
			( 106,    1, 'Create Auction'         , 'MAUC' , 'AUC', ''                  ,    2, ''   , FALSE, FALSE, TRUE , TRUE , TRUE , TRUE),

		-- Budget 
			 (107, 1, 'Budget',                 'ADBC', 'BUG', '',                 99, '', FALSE, FALSE,  FALSE,  TRUE,  TRUE, TRUE)


        ON CONFLICT (Id) DO UPDATE SET
            Parent_Form_Id = EXCLUDED.Parent_Form_Id,
            Form_Caption = EXCLUDED.Form_Caption,
            Form_Code = EXCLUDED.Form_Code,
            Access_Route = EXCLUDED.Access_Route,
            Seq_No = EXCLUDED.Seq_No,
            Icon = EXCLUDED.Icon,
            Is_Master = EXCLUDED.Is_Master,
            Is_Visible_To_Vendor = EXCLUDED.Is_Visible_To_Vendor,
            Is_Disable_Company_Wise_Doc_Series = EXCLUDED.Is_Disable_Company_Wise_Doc_Series,
            Is_Doc_Series_Applicable = EXCLUDED.Is_Doc_Series_Applicable,
            Is_Doc_Type_Applicable = EXCLUDED.Is_Doc_Type_Applicable,
            Inactive = EXCLUDED.Inactive;
 

        -- Status 
        INSERT INTO globaldata.status (id, status_name, inactive) VALUES
            (1, 'Active', FALSE),
            (2, 'Inactive', TRUE),
            (3, 'Pending', FALSE),
            (4, 'Verified', FALSE),
            (5, 'Expired', FALSE),
            (6, 'Suspended', FALSE),
            (7, 'Draft', FALSE),
            (8, 'Received', FALSE),
            (9, 'Authorize', FALSE),
            (10, 'In Progress', FALSE),
            (11, 'Completed', FALSE),
            (12, 'Approved', FALSE),
            (13, 'Rejected', FALSE),
            (14, 'In Review', FALSE),
            (15, 'Cancelled', FALSE),
            (16, 'Short Closed', FALSE),
            (17, 'Hold', FALSE),
            (18, 'Blocked', FALSE),
            (19, 'Skipped', False),
            (20, 'Not Assigned', False),
            (21, 'Approved By Peer', False),
			(22, 'Decline', FALSE),
			(23, 'Viewed', FALSE),
			(24, 'Withdraw', FALSE),
			(25, 'New', FALSE),
			(26, 'ForceLogout', FALSE),
			(27, 'Failed', FALSE),
			(28, 'LoggedOut', FALSE),
			(29, 'Rejected By Peer', False)
            ON CONFLICT (id) DO UPDATE SET
            status_name = EXCLUDED.status_name,
            inactive = EXCLUDED.inactive;

        -- GST Category
        INSERT INTO globaldata.gst_category (id, gst_category_name, inactive) VALUES
            (1, 'GST Relavant', FALSE),
            (2, 'Non-GST', FALSE),
            (3, 'GST Exempted', FALSE),
            (4, 'GST Relevant Negative', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            gst_category_name = EXCLUDED.gst_category_name,
            inactive = EXCLUDED.inactive;

        -- GST Registration Type
        INSERT INTO globaldata.gst_reg_type (id, gst_reg_type_name, inactive) VALUES
            (1, 'Full GST Registered', FALSE),
            (2, 'Full GST(PSU)', FALSE),
            (3, 'GST Exempt', FALSE),
            (4, 'GST Compounding', FALSE),
            (5, 'Un - Registered', FALSE),
			(6, 'Foreign', FALSE),
			(7, 'N/A', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            gst_reg_type_name = EXCLUDED.gst_reg_type_name,
            inactive = EXCLUDED.inactive;

        -- Selection Type
        INSERT INTO globaldata.selection_type (id, selection_type_name, inactive) VALUES
            (1, 'All', FALSE),
            (2, 'Selected', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            selection_type_name = EXCLUDED.selection_type_name,
            inactive = EXCLUDED.inactive;

        -- User Type
        INSERT INTO globaldata.user_type (id, user_type_name, inactive) VALUES
            (1, 'Company Admin', FALSE),
            (2, 'Company General', FALSE),
            (3, 'Supplier', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            user_type_name = EXCLUDED.user_type_name,
            inactive = EXCLUDED.inactive;

        -- MSME Type
        INSERT INTO globaldata.msme_type (id, msme_type_name, inactive) VALUES
            (1, 'Registered', FALSE),
            (2, 'Un-Registered', FALSE),
			(3, 'N/A', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            msme_type_name = EXCLUDED.msme_type_name,
            inactive = EXCLUDED.inactive;

        -- Purchase Type
        INSERT INTO globaldata.purchase_type (id, purchase_type_name, inactive) VALUES
            (1, 'Capital', FALSE),
            (2, 'General', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            purchase_type_name = EXCLUDED.purchase_type_name,
            inactive = EXCLUDED.inactive;

        -- Approval Scope
        INSERT INTO globaldata.approval_scope (id, approval_scope_name, inactive) VALUES
            (1, 'Company Wise', FALSE),
            (2, 'Company + Division Wise', FALSE),
            (3, 'Company + Division + Department Wise', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            approval_scope_name = EXCLUDED.approval_scope_name,
            inactive = EXCLUDED.inactive;

        -- Approval Rule
        INSERT INTO globaldata.approval_rule (id, approval_rule_name, inactive) VALUES
            (1, 'All Users Must Approve', FALSE),
            (2, 'Any One User Can Approve', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            approval_rule_name = EXCLUDED.approval_rule_name,
            inactive = EXCLUDED.inactive;

        -- Pincode Format
        INSERT INTO globaldata.pincode_format (id, pin_code_format_name, inactive) VALUES
            (1, 'Numeric', FALSE),
            (2, 'Alphanumeric', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            pin_code_format_name = EXCLUDED.pin_code_format_name,
            inactive = EXCLUDED.inactive;

        -- Bank Account Type
        INSERT INTO globaldata.bank_account_type (id, bank_account_type_name, inactive) VALUES
            (1, 'Savings', FALSE),
            (2, 'Current', FALSE),
            (3, 'Salary', FALSE),
            (4, 'Fixed Deposit', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            bank_account_type_name = EXCLUDED.bank_account_type_name,
            inactive = EXCLUDED.inactive;

        -- Business Partner Type
        INSERT INTO globaldata.business_partner_type (id, business_partner_type_name, inactive) VALUES
            (1, 'Supplier', FALSE),
            (2, 'Transporter', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            business_partner_type_name = EXCLUDED.business_partner_type_name,
            inactive = EXCLUDED.inactive;

        -- Unit Conversion Type
        INSERT INTO globaldata.unit_conversion_type (id, unit_conversion_type_name, inactive) VALUES
            (1, 'Fixed', FALSE),
            (2, 'Variant', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            unit_conversion_type_name = EXCLUDED.unit_conversion_type_name,
            inactive = EXCLUDED.inactive;

        -- Time Zones
        INSERT INTO globaldata.time_zones (id, time_zone_code, utc_offset, display_name, inactive) VALUES
            (1, 'Asia/Kolkata', '+05:30', 'Asia/Kolkata (UTC+05:30) Kolkata', TRUE),
            (2, 'America/New_York', '-05:00', 'America/New_York (UTC-05:00) New York', TRUE),
            (3, 'Asia/Dubai', '+04:00', 'Asia/Dubai (UTC+04:00) Dubai', TRUE)
            ON CONFLICT (id) DO UPDATE SET
            time_zone_code = EXCLUDED.time_zone_code,
            utc_offset = EXCLUDED.utc_offset,
            display_name = EXCLUDED.display_name,
            inactive = EXCLUDED.inactive;

        -- Expenditure Type
        INSERT INTO globaldata.expenditure_type (id, expenditure_type_name, inactive) VALUES
            (1, 'Capex', FALSE),
            (2, 'Opex', FALSE),
            (3, 'Raw Material', TRUE),
            (4, 'General', TRUE),
            (5, 'Drop Shipment', TRUE),
            (6, 'Reusable', TRUE),
            (7, 'Trading', TRUE)
            ON CONFLICT (id) DO UPDATE SET
            expenditure_type_name = EXCLUDED.expenditure_type_name,
            inactive = EXCLUDED.inactive;
        
        -- Document Status
        INSERT INTO globaldata.document_status (id, document_status_name, inactive) VALUES
            (10, 'Draft', FALSE),
            (20, 'In Review', FALSE),
            (30, 'Authorized', FALSE),
            (40, 'Rejected', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            document_status_name = EXCLUDED.document_status_name,
            inactive = EXCLUDED.inactive;

        -- Doc Series Frequency
        INSERT INTO globaldata.doc_series_frequency (id, doc_series_frequency_name, inactive) VALUES
            (1, 'Daily', FALSE),
            (2, 'Monthly', FALSE),
            (3, 'Yearly', FALSE),
            (4, 'Continous', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            doc_series_frequency_name = EXCLUDED.doc_series_frequency_name,
            inactive = EXCLUDED.inactive;

        -- Ref Doc Type
        INSERT INTO globaldata.ref_doc_type (id, ref_doc_type_name, form_id, inactive, remark) VALUES
            (1, 'Direct', 6, FALSE, 'For Purchase Request'),
            (2, 'Direct', 10, FALSE, 'For Purchase Order'),
            (3, 'Purchase Request', 10, FALSE, 'For Purchase Order'),
            (4, 'Quotation', 10, FALSE, 'For Purchase Order'),
            (5, 'Direct', 7, FALSE, 'For RFQ'),
            (6, 'Purchase Request', 7, FALSE, 'For RFQ'),
            (7, 'RFQ', 8, FALSE, 'For CS'),
            (8, 'CS', 8, FALSE, 'For CS'),
			(9, 'Auction', 7, TRUE, 'For RFQ'),
			(10, 'Direct', 106, FALSE, 'For Auction'),
			(11, 'RFQ', 106, FALSE, 'For Auction')
            ON CONFLICT (id) DO UPDATE SET
            ref_doc_type_name = EXCLUDED.ref_doc_type_name,
            inactive = EXCLUDED.inactive,
            remark = EXCLUDED.remark;
        
        -- Attachment Context
        INSERT INTO globaldata.attachment_context (id, context_name, form_id, inactive, doc_id_format) VALUES
            (1, 'vendor_reg', 48, FALSE, '~{formCode}~{vendorRegLocationId}~{vendorAttachmentId}~'),
            (2, 'vendor_master', 49, FALSE, '~{formCode}~{vendorMasterLocationId}~{vendorAttachmentId}~'),
            (3, 'pur_req_header', 6, FALSE, '~{formCode}~{Id}~'),
            (4, 'pur_req_item', 6, FALSE, '~{formCode}~{Id}~{lineNo}~'),
			(5, 'pur_rfq_header', 7, FALSE, '~{formCode}~{Id}~'),
            (6, 'pur_rfq_item', 7, FALSE, '~{formCode}~{Id}~{lineNo}~'),
			(7, 'quotation_header', 9, FALSE, '~{formCode}~{Id}~'),
            (8, 'quotation_item', 9, FALSE, '~{formCode}~{Id}~{lineNo}~'),
			(9, 'pur_order_header', 10, FALSE, '~{formCode}~{Id}~'),
            (10, 'pur_order_item', 10, FALSE, '~{formCode}~{Id}~{lineNo}~'),
            (11, 'user_master', 45, FALSE, '~{formCode}~{Id}~'),
            (12, 'announce_master', 98, FALSE, '~{formCode}~{Id}~'),
			(13, 'auction_header', 106, FALSE, '~{formCode}~{Id}~'),
			(14, 'auction_item', 106, FALSE, '~{formCode}~{Id}~{lineNo}~')
            ON CONFLICT (id) DO UPDATE SET
            context_name = EXCLUDED.context_name,
            form_id = EXCLUDED.form_id,
            inactive = EXCLUDED.inactive,
            doc_id_format = EXCLUDED.doc_id_format;
		
		--Notification Channel
		INSERT INTO globaldata.notification_channel
		(id, channel_name, inactive)
		VALUES
		(1, 'email', FALSE),
		(2, 'sms', FALSE),
		(3, 'whatsapp', FALSE)
		ON CONFLICT (id) DO UPDATE SET
		channel_name = EXCLUDED.channel_name,
		inactive = EXCLUDED.inactive;
		
		--Recipient Type
		INSERT INTO globaldata.notification_recipient_types
		(id, recipient_type, form_id, inactive)
		VALUES
		(1, 'CreatedBy', NULL, FALSE),
		(2, 'ModifiedBy', NULL, FALSE),
		(3, 'AuthorizedBy', NULL, FALSE),
		(4, 'InReviewBy', NULL, FALSE),
		(5, 'FirstApprovers', NULL, FALSE),
		(6, 'LastApprovers', NULL, FALSE),
		(7, 'NextApprovers', NULL, FALSE),
		(8, 'PreviousApprovers', NULL, FALSE),
		(9, 'AllPreviousApprovers', NULL, FALSE),
		(10, 'AllNextApprovers', NULL, FALSE),
		(11, 'AllApprovers', NULL, FALSE),
		(12, 'RFQ_ContactPerson', 7, FALSE),
		(13, 'PR_AllInformTos', 6, FALSE),
		(14, 'QT_AllInformTos', 9, FALSE),
		(15, 'QT_VendorLocations', 9, FALSE),
		(16, 'QT_VendorLogin', 9, FALSE),
		(17, 'QT_VendorAllContact', 9, FALSE),
		(18, 'QT_RFQContactPerson', 9, FALSE),
		(19, 'QT_RFQ Creater', 9, FALSE),
		(20, 'PO_Vendor', 10, FALSE),
		(21, 'PO_VendorLogin', 10, FALSE),
		(22, 'PO_VendorContactPerson', 10, FALSE),
		(23, 'PO_VendorAllcontact', 10, FALSE),
		(24, 'RFQ_VendorLocations', 7, FALSE),
		(25, 'RFQ_VendorAllContact', 7, FALSE),
		(26, 'QT_VendorInformToAll',9,FALSE),
		(27, 'QT_RFQCreator',9,FALSE),
		(28, 'QT_Default',9,FALSE),
		(29, 'RFQ_Default',7,FALSE),
		(30, 'PeerApprovers',NULL,FALSE)
		ON CONFLICT (id) DO UPDATE SET
		recipient_type = EXCLUDED.recipient_type,
		form_id = EXCLUDED.form_id,
		inactive = EXCLUDED.inactive;
		
		--Notification Action
		INSERT INTO globaldata.notification_action
		(id, form_id, action_name, description, inactive)
		VALUES
		(1, 6, 'PRAuthorize', 'When Purchase request authorized, send notification.', FALSE),
		(2, NULL, 'ApprovalPending', 'When document created,updated or authorized, send notification.', FALSE),
        (3,	NULL,	'Password Changed',	'When Password is changed, forgotten, reset successfully.',	FALSE),
        (4,	NULL,	'User Blocked Max Failed Login Attempts Reached','When user tries to login and reaches max failed login attempt because of wrong passwords.',	FALSE),
		(5, 7, 'RFQAuthorize', 'When RFQ authorized, send notification.', FALSE),
		(17, 9, 'QT_VendorAllContact', 'Inform RFQ Vendor Contact Person that Vendor has Submitted or Revised the Quotation', FALSE),
        (18, 9, 'QT_RFQContactPerson', 'Inform RFQ Contact Person that Vendor has Submitted or Revised the Quotation', FALSE),
		(19, 9, 'QT_RFQContactPerson', 'Inform RFQ Contact Person that Vendor has Withdraw the Quotation', FALSE),
		(20, 9, 'QT_VendorAllContact', 'Inform RFQ Vendor Contact Person that Vendor has Witdraw the Quotation', FALSE),
		(21, 9, 'QT_VendorAllContact,QT_RFQContactPerson', 'Inform RFQ Vendor Contact Person & RFQ Contact that Vendor has Deleted the Quotation', FALSE),
		(22, 9, 'QT_VendorAllContact,QT_RFQContactPerson', 'Inform RFQ Vendor Contact Person & RFQ Contact that Vendor has Rejoin the Quotation', FALSE),
		(23, 7, 'RFQ_ContactPerson', 'Inform RFQ Vendor Contact Person that Vendor has Declied the Quotation', FALSE),
		(24, 7, 'RFQ_VendorAllContact', 'Inform  RFQ Contact that Vendor has Decline the Quotation', FALSE),
		(25, 10, 'PO_PublishedCreator', 'Inform PO Creator that the PO is published in the vendor portal', FALSE),
		(26, 10, 'PO_PublishedVendor', 'Inform Vendor that the PO is published in the vendor portal', FALSE),
		(27, 10, 'PO_AcknowledgedCreator', 'Inform PO Creator that the PO is acknowledged by the vendor', FALSE),
		(28, NULL, 'ApprovalRejected', 'When request for document approval is rejected, sends notification.', FALSE),
        (29, 10, 'PO_AuthorizedCreator', 'Inform PO Creator that the PO is authorized', FALSE),
        (30,  7, 'RFQ_ValidityDateUpdate', 'Inform the Vendors that RFQs validity date is extended.', FALSE),
        (31,  7, 'RFQ_Authorize_InformCreator', 'Inform the creator about the RFQ Authorization.', FALSE),
        (32, 105, 'SendTestEmail', 'Real-time diagnostic health check test email dispatches.', FALSE),
        (33, 105, 'SendTestEmailSummary', 'Real-time diagnostic health check summary completion email.', FALSE),
        (34,  7, 'RFQ_ContactPerson', 'Inform RFQ Contact Person that Vendor has Reversed the Decline against the Quotation', FALSE),
        (35,  7, 'RFQ_VendorAllContact', 'Inform Vendor that they have Successfully Reversed the Decline on the Quotation', FALSE)

		ON CONFLICT (id) DO UPDATE SET
		form_id = EXCLUDED.form_id,
		action_name = EXCLUDED.action_name,
		description = EXCLUDED.description,
		inactive = EXCLUDED.inactive;

		--Notification Rule 
		INSERT INTO globaldata.notification_rule
		(id, form_id, rule_name, channel_id, inactive)
		VALUES
		(1, 6, 'Send_Mail_After_Authorize', 1, FALSE),
		(2, NULL, 'Send_Mail_To_Approvers', 1, FALSE),
        (3, NULL,	'Send_Mail_After_Successful_Password_Change', 1, FALSE),
        (4, NULL,	'Send_Mail_To_Blocked_User_After_Max_Failed_Login_Attempt_Reached', 1, FALSE),
		(5, 7, 'Send_Mail_After_RFQ_Authorize', 1, FALSE),
		(17, 9, 'Send_Mail_To_VendorContactPerson', 1, FALSE),
		(18, 9, 'Inform RFQ Contact Person that Vendor has Submitted or Revised the Quotation', 1, FALSE),
		(19, 9, 'Inform RFQ Contact Person that Vendor has Withdraw the Quotation', 1, FALSE),
		(20, 9, 'Send_Mail_To_VendorContactPerson for withdraw', 1, FALSE),
		(21, 9, 'Send_Mail_To_VendorContactPerson&RFQContact for Delete', 1, FALSE),
		(22, 9, 'Send_Mail_To_VendorContactPerson&RFQContact for Rejoin', 1, FALSE),
		(23, 7, 'Send_Mail_To_VendorContactPerson for Declin', 1, FALSE),
		(24, 7, 'Send_Mail_To_RFQContact for Decline', 1, FALSE),
		(25, 10, 'Send_Mail_To_POCreator_After_PO_Publish', 1, FALSE),
        (26, 10, 'Send_Mail_To_Vendor_After_PO_Publish', 1, FALSE),
		(27, 10, 'Send_Mail_To_POCreator_After_PO_Acknowledgement', 1, FALSE),
		(28, NULL, 'Send_Mail_After_Approval_Rejected', 1, FALSE),
        (29, 10, 'Send_Mail_To_POCreator_After_PO_Authorization', 1, FALSE),
        (30, 7, 'Send_Mail_To_Vendors_After_RFQs_Validity_Date_Update', 1, FALSE),
        (31, 7, 'Send_Mail_To_Creator_After_Authorization', 1, FALSE),
        (32, 105, 'Send_Test_Email_Diagnostic', 1, FALSE),
        (33, 105, 'Send_Test_Email_Diagnostic_Summary', 1, FALSE),
        (34, 7, 'Send_Mail_To_RFQContact for Undo Decline', 1, FALSE),
        (35, 7, 'Send_Mail_To_VendorContactPerson for Undo Decline', 1, FALSE)

		ON CONFLICT (id) DO UPDATE SET
		form_id = EXCLUDED.form_id,
		rule_name = EXCLUDED.rule_name,
		channel_id = EXCLUDED.channel_id,
		inactive = EXCLUDED.inactive;

		--Notification Recipient mapping
		INSERT INTO globaldata.notification_rule_recipient_mapping
		(id, notification_rule_id, "to", cc, inactive)
		VALUES
		(1, 1, 'CreatedBy,PR_AllInformTos', NULL, FALSE),
		(2, 2, 'NextApprovers', NULL, FALSE),
       	 	(3, 3, 'User', NULL, FALSE),
        	(4, 4, 'User', NULL, FALSE),
		(5, 5, 'RFQ_VendorLocations', NULL, FALSE),
		(17, 17, 'QT_VendorAllContact', 'QT_VendorInformToAll', FALSE),
		(18, 18, 'QT_RFQContactPerson','QT_Default,QT_RFQCreator', FALSE),
		(19, 19, 'QT_RFQContactPerson', 'QT_RFQCreator,QT_Default', FALSE),
		(20, 20, 'QT_VendorAllContact', 'QT_VendorInformToAll', FALSE),
		(21, 21, 'QT_VendorAllContact,QT_RFQContactPerson', 'QT_VendorInformToAll,QT_RFQCreator,QT_Default', FALSE),
		(22, 22, 'QT_VendorAllContact,QT_RFQContactPerson', 'QT_VendorInformToAll,QT_RFQCreator,QT_Default', FALSE),
		(23, 23, 'RFQ_ContactPerson','CreatedBy,RFQ_Default', FALSE),
		(24, 24, 'RFQ_VendorAllContact', NULL, FALSE),
		(25, 25, 'CreatedBy', NULL, FALSE),
        (26, 26, 'PO_VendorAllContact', NULL, FALSE),
		(27, 27, 'CreatedBy', NULL, FALSE),
		(28, 28, 'CreatedBy,AllPreviousApprovers,PeerApprovers', NULL, FALSE),
        (29, 29, 'CreatedBy', NULL, FALSE),
        (30, 30, 'RFQ_VendorLocations', NULL, FALSE),
        (31, 31, 'CreatedBy', NULL, FALSE),
        (32, 32, 'User', NULL, FALSE),
        (33, 33, 'User', NULL, FALSE),
        (34, 34, 'RFQ_ContactPerson', 'CreatedBy,RFQ_Default', FALSE),
        (35, 35, 'RFQ_VendorAllContact', NULL, FALSE)

		ON CONFLICT (id) DO UPDATE SET
		notification_rule_id = EXCLUDED.notification_rule_id,
		"to" = EXCLUDED."to",
		cc = EXCLUDED.cc,
		inactive = EXCLUDED.inactive;

		--Notification Template 	
		INSERT INTO globaldata.notification_template (
			id,
			rule_id,
			template_name,
			tag,
			channel_id,
			subject,
			body,
			inactive
		)
		VALUES (
			1,
			1,
			'PRAuthorizeEmail',
			'Default',
			1,
			'Purchase Request {{DisplayDocNoYearly}} ({{ExpenditureType}}) has been authorized.',
			'<p>         
         
    <p style="margin-top:0;">
        Dear <strong>{{UserName}}</strong>,
    </p>

    <p>
        This is to inform you that your <strong>Purchase Request {{DisplayDocNoYearly}}</strong> dated <strong> {{DocDate}} </strong> has been has been authorized by <strong>{{AuthorizedByName}}</strong>.
    </p>

    <p>
        Please find the details below for your reference.
    </p>
            
    <strong>Purchase Request Details:</strong> <br><br>

    <!-- Purchase Request Details -->
    <table cellpadding="6" cellspacing="0" border="1"
        style="border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 14px;
    ">

        <tr>
            <td width="35%"><strong>Purchase Request No.</strong></td>
            <td>{{DisplayDocNoYearly}}</td>
        </tr>

        <tr>
            <td><strong>Purchase Request Date</strong></td>
            <td>{{DocDate}}</td>
        </tr>

        <tr>
            <td><strong>Company</strong></td>
            <td>{{CompanyDisplayName}} ({{CompanyAliasName}})</td>
        </tr>

        <tr>
            <td><strong>Division</strong></td>
            <td>{{DivisionName}} ({{DivisionCode}})</td>
        </tr>

        <tr>
            <td><strong>Department</strong></td>
            <td>{{DepartmentName}}</td>
        </tr>

        <tr>
            <td><strong>Expenditure Type</strong></td>
            <td>{{ExpenditureType}}</td>
        </tr>

        <tr>
            <td><strong>Requested By</strong></td>
            <td>{{RequestedByName}}</td>
        </tr>

        <tr>
            <td><strong>Created By</strong></td>
            <td>{{CreatedByName}}</td>
        </tr>

    </table>

    <br>

    <p>
        Below are some of the items included in the Purchase Request.
        Additional items may also be part of the Purchase Request.
    </p>

    <!-- Item Table -->
    <table cellpadding="6" cellspacing="0" border="1"
        style="border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 14px;
    ">

        <tr>
            <th align="center">Item</th>
            <th width="120" align="center">Quantity</th>
        </tr>

        <tr>
            <td>{{PrItemOneName}}</td>
            <td align="center">{{PrItemOneQty}}</td>
        </tr>

        <tr style="background:#f7f7f7;">
            <td>{{PrItemTwoName}}</td>
            <td align="center">{{PrItemTwoQty}}</td>
        </tr>

        <tr>
            <td>{{PrItemThreeName}}</td>
            <td align="center">{{PrItemThreeQty}}</td>
        </tr>

    </table>

    <br>

    <p>
        To view the Purchase Request, please click the link below:
    </p>

    <p>
        <a clicktracking="off" href="{{DisplayURL}}">
            View Purchase Request
        </a>
    </p>

    <p>
        If you are unable to click the link, copy and paste the following URL into your browser:
    </p>

    <p style="word-break:break-all;">
        {{DisplayURL}}
    </p>

    <hr style="border:none;border-top:1px solid #dddddd;margin:30px 0;">

    <p style="font-size:13px;color:#777777;">
        This is a system generated mail. Please do not reply to the sender of this mail.
    </p>

    <div style="margin-top:25px;">
        {{DefaultEmailSignature}}
    </div>
</p>',
			FALSE
		),
		 (
			2,
			2,
			'DocumentApproval',
			'Default',
			1,
			'Approval Pending at Your Level {{DocumentNoColumnName}} : {{DocumentNoYearly}}.',
			$DOC_APPROVAL$
			<p>Dear {{ApproverName}},</p>

			<p>A <b>{{DocumentName}}</b> has been submitted and is awaiting your approval. Below are the details:</p>

			<p>
			<b>{{DocumentNoColumnName}}:</b> {{DocumentNoYearly}}<br>
			<b>{{DocumentDateColumnName}}:</b> {{DocumentDate}}<br>
			<b>Created By:</b> {{CreatedByName}}<br>
			<b>Approval Level:</b> {{CurrentApprovalLevelName}} - {{CurrentApprovalLevelNo}}
			</p>

			<p>Please review the document and take the necessary action (Approve/Reject).</p>

			<p>
			<a clicktracking='off' href='{{CurrentApprovalLink}}'>Click here to review and approve</a>
			</p>

			<p>If you are unable to click the link, please copy and paste the following URL into your browser:<br>
			{{CurrentApprovalLink}}
			</p>

			<p>
			This is a system generated mail. Please do not reply to the sender of this mail.
			</p>

			<p>{{DefaultEmailSignature}}</p>
			$DOC_APPROVAL$,
			FALSE
		),

        (
            3,	
            3,
            'ChangedPassword',
            'Default',
            1,
            'Password changed successfully.',
            'Dear {{DisplayName}},<br><br>

            This is to inform you that the password for your account has been changed successfully.<br>

            If you did not perform this action, please contact us immediately.<br><br>

            Best Regards,<br><br>

            {{DefaultEmailSignature}}',
            
            FALSE
        ),
        (
            4,	
            4,
            'MaxFailedLoginAttempstBreached',
            'Default',
            1,
            'Account access temporarily restricted.',
            'Dear {{DisplayName}},<br><br>

            This is to inform you that access to your account has been temporarily restricted due to multiple unsuccessful login attempts with incorrect passwords.<br>

            You can regain access to your account by resetting your password using the <b>Forgot Password</b> option available on the login page.<br>

            <a clicktracking="off" href="{{ForgotPassword}}">
                Forgot Password
            </a><br><br>

            If the above link is not clickable, please copy and paste the following URL into your browser.<br>
            {{ForgotPassword}}<br><br>

            For any queries or assistance, please contact us.<br>

            Best Regards,<br><br>

            {{DefaultEmailSignature}}',
            FALSE
        ),
		 (
			5,
			5,
			'RFQAuthorizeEmail',
			'Default',
			1,
			'{{RFQSubject}}',
			$RFQ_VENDOR_EMAIL$
			<p>Dear {{VendorName}},</p>

			<p>You are hereby invited to submit your quotation against RFQ {{DocNoYearly}} issued by {{HeadOfficeName}}.</p>

			The RFQ comprises items such as:
			<ul>{{Top3Items}}</ul>

			<p>Please review the document and take the necessary action before {{DueDate}}</p>

			<p>
				<a clicktracking='off' href='{{RFQRouteForVendor}}'>
					Click here to Open the RFQ
				</a>
			</p>

			<p>If you are unable to click the link, please copy and paste the following URL into your browser:<br>
			{{RFQRouteForVendor}}
			</p>

			<p>
				For any queries or assistance, please contact the concerned team.
			</p>

            <p>
			This is a system generated mail. Please do not reply to the sender of this mail.
			</p>

			<p>Best Regards,</p>
			<span>{{DefaultEmailSignature}}</span>
			$RFQ_VENDOR_EMAIL$,
			FALSE
		),
(
			17,
			17,
			'QT_VendorAllContact',
			'Default',
			1,
			'Quotation {{VendorAction}} successfully against RFQ {{RfqDocNoYearly}}',
			'<p>Dear {{VendorLegalName}},</p>

			<p>
			Your quotation
			<strong>{{QuotationDocNoYearly}}</strong>
			against RFQ
			<strong>{{RfqDocNoYearly}}</strong>
			has been {{VendorAction}} successfully.
</p>

<p>
Below are the details for your reference:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

    <tr>
        <td><strong>Vendor Name</strong></td>
        <td>{{VendorLegalName}}</td>
    </tr>

    <tr>
        <td><strong>Vendor Location</strong></td>
        <td>{{VendorLocationAddress}}</td>
    </tr>

    <tr>
        <td><strong>RFQ No.</strong></td>
        <td>{{RfqDocNoYearly}}</td>
    </tr>

    <tr>
        <td><strong>Quotation No.</strong></td>
        <td>{{QuotationDocNoYearly}}</td>
    </tr>

    <tr>
        <td><strong>Revision No.</strong></td>
        <td>{{RevisionNo}}</td>
    </tr>

</table>

<p>
To review the quotation, please click the link below:
</p>

<p>
    <a clicktracking="off" href="{{VendorLink}}">
        View Quotation
    </a>
</p>

<p>
If you are unable to click the link, copy and paste the following URL into your browser:
<br>
{{VendorLink}}
</p>

<p>
For any queries or assistance, please contact us.
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',			FALSE
		),
		(
			18,
			18,
			'QT_RFQContactPerson',
			'Default',
			1,
			'Quotation {{QuotationDocNoYearly}} {{VendorAction}} against RFQ {{RfqDocNoYearly}}',
			'<p>Dear {{VendorLegalName}},</p>

<p>
This is to inform you that the vendor <strong>{{VendorLegalName}}</strong> has successfully {{VendorAction}} the quotation <strong>{{QuotationDocNoYearly}}</strong> against RFQ <strong>{{RfqDocNoYearly}}</strong>.
</p>

<p>
    Below are the details for your reference:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

    <tr>
        <td><strong>Vendor Name</strong></td>
        <td>{{VendorLegalName}}</td>
    </tr>

    <tr>
        <td><strong>Vendor Location</strong></td>
        <td>{{VendorLocationAddress}}</td>
    </tr>

    <tr>
        <td><strong>RFQ No.</strong></td>
        <td>{{RfqDocNoYearly}}</td>
    </tr>

    <tr>
        <td><strong>Quotation No.</strong></td>
        <td>{{QuotationDocNoYearly}}</td>
    </tr>

    <tr>
        <td><strong>Revision No.</strong></td>
        <td>{{RevisionNo}}</td>
    </tr>

    <tr>
        <td><strong>Quotation Date</strong></td>
        <td>{{QuotationDate}}</td>
    </tr>

    <tr>
        <td><strong>Quotation Validity Date</strong></td>
        <td>{{QuotationValidityDate}}</td>
    </tr>

    <tr>
        <td><strong>Net Amount</strong></td>
        <td>{{QuotationNetAmount}}</td>
    </tr>

</table>

<p>
To review the quotation, please click the link below:
</p>

<p>
    <a clicktracking="off" href="{{QuotationLink}}">
        View Quotation
    </a>
</p>

<p>
If you are unable to click the link, copy and paste the following URL into your browser:
<br>
{{QuotationLink}}
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',			FALSE
		),
(
			19,
			19,
			'QT_RFQContactPerson',
			'Default',
			1,
			'Vendor withdrew Quotation Against RFQ {{RfqDocNoYearly}}',
			'<p>Dear {{VendorLegalName}},</p>

<p>
This is to inform you that the vendor <strong>{{VendorLegalName}}</strong> has withdrew the quotation against RFQ <strong>{{RfqDocNoYearly}}</strong>.
</p>

<p>
Below are the details for your reference:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

    <tr>
        <td><strong>Vendor Name</strong></td>
        <td>{{VendorLegalName}}</td>
    </tr>

    <tr>
        <td><strong>Vendor Location</strong></td>
        <td>{{VendorLocationAddress}}</td>
    </tr>

    <tr>
        <td><strong>RFQ No.</strong></td>
        <td>{{RfqDocNoYearly}}</td>
    </tr>

    <tr>
        <td><strong>Quotation No.</strong></td>
        <td>{{QuotationDocNoYearly}}</td>
    </tr>

</table>


<p>
To review the quotation, please click the link below:
</p>

<p>
    <a clicktracking="off" href="{{QuotationLink}}">
        View Quotation
    </a>
</p>

<p>
If you are unable to click the link, copy and paste the following URL into your browser:
<br>
{{QuotationLink}}
</p>


<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',			FALSE
		),
(
			20,
			20,
			'QT_VendorAllContact',
			'Default',
			1,
			'Quotation successfully withdraw against RFQ {{RfqDocNoYearly}}',
			'<p>Dear {{VendorLegalName}},</p>

<p>

Your have successfully {{VendorAction}} Quotation {{QuotationDocNoYearly}} against RFQ <strong>{{RfqDocNoYearly}}</strong>.

</p>

<p>
For any queries or assistance, please contact us.
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>
',			FALSE
		),
(
			21,
			21,
			'QT_VendorAllContact,QT_RFQContactPerson',
			'Default',
			1,
			'{{VendorLegalName}} has deleted Quotation for RFQ {{RfqDocNoYearly}}.',
			'<p>Dear {{UserName}},</p>

<p>
This is to inform you that
<strong>{{VendorLegalName}}</strong>
has deleted Quotation {{QuotationDocNoYearly}} against RFQ
<strong>{{RfqDocNoYearly}}</strong>.
</p>


<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>

',			FALSE
		),
(
			22,
			22,
			'QT_VendorAllContact,QT_RFQContactPerson',
			'Default',
			1,
			'{{VendorLegalName}} withdraw request for RFQ {{RfqDocNoYearly}} has been reversed.',
			'<p>Dear {{UserName}},</p>

<p>
This is to inform you that 
<strong>{{VendorLegalName}}</strong>
has successfully reversed the withdraw request for Quotation {{QuotationDocNoYearly}} against RFQ
<strong>{{RfqDocNoYearly}}</strong>.
</p>


<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',			FALSE
		),
		(
			23,
			23,
			'RFQ_ContactPerson',
			'Default',
			1,
			'Vendor declined Quotation against RFQ {{RfqDocNoYearly}}.',
			'<p>Dear {{ContactPersonName}},</p>

<p>
This is to inform you that the vendor <strong>{{VendorLegalName}}</strong> has <strong>declined</strong> the quotation against RFQ <strong>{{RfqDocNoYearly}}</strong>.
</p>

<p>
Below are the details for your reference:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

    <tr>
        <td><strong>Vendor Name</strong></td>
        <td>{{VendorLegalName}}</td>
    </tr>

    <tr>
        <td><strong>Vendor Location</strong></td>
        <td>{{VendorLocationAddress}}</td>
    </tr>

    <tr>
        <td><strong>RFQ No.</strong></td>
        <td>{{RfqDocNoYearly}}</td>
    </tr>

</table>


<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>
',			FALSE
		),
		(
			24,
			24,
			'RFQ_VendorAllContact',
			'Default',
			1,
			'Quotation successfully declined against RFQ {{RfqDocNoYearly}}.',
			'<p>Dear {{VendorLegalName}},</p>

<p>

Your have successfully <strong>declined the Quotation</strong> against RFQ <strong>{{RfqDocNoYearly}}</strong>.

</p>

<p>
For any queries or assistance, please contact us.
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',			FALSE
		),
				(
    25,
    25,
    'PO_PublishedCreator',
    'Default',
    1,
    'Purchase Order {{PurchaseOrderDocNoYearly}} is published in the portal.',
    '<p>Dear {{UserDisplayName}},</p>

<p>
This is to inform you that the Purchase Order
<strong>{{PurchaseOrderDocNoYearly}}</strong>
dated {{PurchaseOrderDate}} has been published in the vendor portal.
</p>

<p>
Below are the details for your reference:
</p>

<p>
<strong>Purchase Order Details:</strong>
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

<tr>
    <td><strong>PO No.</strong></td>
    <td>{{PurchaseOrderDocNoYearly}}</td>
</tr>

<tr>
    <td><strong>PO Date</strong></td>
    <td>{{PurchaseOrderDate}}</td>
</tr>

<tr>
    <td><strong>Vendor Name</strong></td>
    <td>{{VendorLegalName}}</td>
</tr>

</table>

<p>
Below are some of the items included in the Purchase Order. Additional items may also be part of the Purchase Order:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

<tr>
    <th><strong>Item</strong></th>
    <th><strong>Quantity</strong></th>
    <th><strong>Rate</strong></th>
    <th><strong>Amount</strong></th>
    <th><strong>Schedule</strong></th>
</tr>

<tr>
    <td>{{ItemName}}</td>
    <td>{{ItemQty}}</td>
    <td>{{ItemRate}}</td>
    <td>{{ItemAmount}}</td>
    <td>{{DeliverySchedule}}</td>
</tr>

</table>

<p>
To review the Purchase Order, please click the link below:
</p>

<p>
<a clicktracking="off" href="{{PurchaseOrderLink}}">
View Purchase Order
</a>
</p>

<p>
If you are unable to click the link, copy and paste the following URL into your browser:
<br>
{{PurchaseOrderLink}}
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',
    FALSE
),

(
    26,
    26,
    'PO_PublishedVendor',
    'Default',
    1,
    'Purchase Order {{PurchaseOrderDocNoYearly}} is published in the portal.',
    '<p>Dear {{VendorLegalName}},</p>

<p>
This is to inform you that Purchase Order
<strong>{{PurchaseOrderDocNoYearly}}</strong>,
dated {{PurchaseOrderDate}}, has been assigned to you and published on the vendor portal.
</p>

<p>
To view the Purchase Order, please click the link below:
</p>

<p>
    <a clicktracking="off" href="{{PurchaseOrderLink}}">
        View Purchase Order
    </a>
</p>

<p>
If you are unable to click the link, copy and paste the following URL into your browser:
<br>
{{PurchaseOrderLink}}
</p>

<p>
For any queries or assistance, please contact us.
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',
    FALSE
),
(
    27,
    27,
    'PO_AcknowledgedCreator',
    'Default',
    1,
    'Purchase Order {{PurchaseOrderDocNoYearly}} has been acknowledged by vendor.',
    '<p>Dear Team,</p>
<p>
We are pleased to inform you that the following Purchase Order has been successfully acknowledged by the vendor.
</p>
<p>
<strong>PO Number:</strong> {{PurchaseOrderDocNoYearly}}
<strong>PO Date:</strong> {{PurchaseOrderDate}}
<strong>Vendor:</strong> {{VendorLegalName}}
<strong>Acknowledgement No:</strong> {{LastAckAmendmentNo}}
<strong>Acknowledgement Date:</strong> {{LastAckDate}}
</p>
<p>
To view the Purchase Order details, please click the link below:
</p>
<p>
    <a clicktracking="off" href="{{PurchaseOrderLink}}">
        View Purchase Order Details
    </a>
</p>
<p>
If you are unable to click the link, copy and paste the following URL into your browser:
{{PurchaseOrderLink}}
</p>
<p>
For any queries or assistance, please contact us.
</p>
<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>
<p>
Best Regards,
{{DefaultEmailSignature}}
</p>',
    FALSE
),
		 (
			28,
			28,
			'DocumentApprovalRejection',
			'Default',
			1,
			'The {{DocumentName}} {{DocumentNoColumnName}}: {{DocumentNoYearly}} has been rejected.',
			$DOC_APPROVAL_REJECTED$
			<p>Dear User,</p>

			<p>
			A <strong>{{DocumentName}}</strong>, has been rejected. Below are the details.
			</p>

			<table cellpadding="4" cellspacing="0" border="1" style="border-collapse: collapse;">
				<tr>
					<td><strong>{{DocumentNoColumnName}}</strong></td>
					<td>{{DocumentNoYearly}}</td>
				</tr>
				<tr>
					<td><strong>{{DocumentDateColumnName}}</strong></td>
					<td>{{DocumentDate}}</td>
				</tr>
				<tr>
					<td><strong>Created By</strong></td>
					<td>{{CreatedByName}}</td>
				</tr>
				<tr>
					<td><strong>Approval Level</strong></td>
					<td>{{CurrentApprovalLevelNo}}</td>
				</tr>
				<tr>
					<td><strong>Rejected By</strong></td>
					<td>{{RejectedBy}}</td>
				</tr>
				<tr>
					<td><strong>Rejection Reason</strong></td>
					<td>{{RejectionReason}}</td>
				</tr>
			</table>

			<p>
			This is a system generated mail. Please do not reply to the sender of this mail.
			</p>

			<p>
			Best Regards,<br>
			{{DefaultEmailSignature}}
			</p>
			$DOC_APPROVAL_REJECTED$,
			FALSE
		),

        (
    29,
    29,
    'PO_AuthorizedCreator',
    'Default',
    1,
    'Purchase Order {{PurchaseOrderDocNoYearly}} is Authorized.',
    '<p>Dear {{UserDisplayName}},</p>

<p>
This is to inform you that your {{Amendment}}Purchase Order
<strong>{{PurchaseOrderDocNoYearly}}</strong>
dated {{PurchaseOrderDate}} has been authorized in the vendor portal.
</p>

<p>
Below are the details for your reference:
</p>

<p>
<strong>Purchase Order Details:</strong>
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

<tr>
    <td><strong>PO No.</strong></td>
    <td>{{PurchaseOrderDocNoYearly}}</td>
</tr>

<tr>
    <td><strong>PO Date</strong></td>
    <td>{{PurchaseOrderDate}}</td>
</tr>

<tr>
    <td><strong>Vendor Name</strong></td>
    <td>{{VendorLegalName}}</td>
</tr>

</table>

<p>
Below are some of the items included in the Purchase Order. Additional items may also be part of the Purchase Order:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

<tr>
    <th><strong>Item</strong></th>
    <th><strong>Quantity</strong></th>
    <th><strong>Rate</strong></th>
    <th><strong>Amount</strong></th>
    <th><strong>Schedule</strong></th>
</tr>

<tr>
    <td>{{RowOneItemName}}</td>
    <td>{{RowOneItemQty}}</td>
    <td>{{RowOneItemRate}}</td>
    <td>{{RowOneItemAmount}}</td>
    <td>{{RowOneDeliverySchedule}}</td>
</tr>

<tr>
    <td>{{RowTwoItemName}}</td>
    <td>{{RowTwoItemQty}}</td>
    <td>{{RowTwoItemRate}}</td>
    <td>{{RowTwoItemAmount}}</td>
    <td>{{RowTwoDeliverySchedule}}</td>
</tr>

<tr>
    <td>{{RowThreeItemName}}</td>
    <td>{{RowThreeItemQty}}</td>
    <td>{{RowThreeItemRate}}</td>
    <td>{{RowThreeItemAmount}}</td>
    <td>{{RowThreeDeliverySchedule}}</td>
</tr>

</table>

<p>
To review the Purchase Order, please click the link below:
</p>

<p>
<a clicktracking="off" href="{{PurchaseOrderLink}}">
View Purchase Order
</a>
</p>

<p>
If you are unable to click the link, copy and paste the following URL into your browser:
<br>
{{PurchaseOrderLink}}
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',
    FALSE
),
        (
    30,
    30,
    'RFQValidityUpdate',
    'Default',
    1,
    'RFQ {{DocNoYearly}} – Validity Date extended to {{ValidityDate}}',
    $RFQVALIDITY$
<p>Dear {{VendorName}},</p>

<p>
This is to notify you that RFQ {{DocNoYearly}} validity date has been changed to {{ValidityDate}}. Please review and submit your quotation accordingly.
</p>

<p>
    To access the RFQ and submit your response, please use the link below:
</p>

<p>
    <a clicktracking='off' href='{{RFQRouteForVendor}}'>
        View RFQ
    </a>
</p>

<p>If you are unable to click the link, please copy and paste the following URL into your browser:<br>
{{RFQRouteForVendor}}
</p>

<p>
    For any queries or assistance, please contact the concerned team.
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>


<p>Best Regards,</p>
<span>{{DefaultEmailSignature}}</span>
$RFQVALIDITY$,
    FALSE
),        (
    31,
    31,
    'RFQ_AuthorizeCreator',
    'Default',
    1,
    'RFQ {{RfqDocNoYearly}} is Authorized.',
    '<p>Dear {{UserDisplayName}},</p>

<p>
This is to inform you that your RFQ 
<strong>{{RfqDocNoYearly}}</strong>
dated {{RfqDocDate}} has been authorized in the vendor portal.
</p>

<p>
Below are the details for your reference:
</p>

<p>
<strong>Purchase Order Details:</strong>
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

<tr>
    <td><strong>PO No.</strong></td>
    <td>{{RfqDocNoYearly}}</td>
</tr>

<tr>
    <td><strong>PO Date</strong></td>
    <td>{{RfqDocDate}}</td>
</tr>

</table>

<p>
Below are some of the items included in the RFQ. Additional items may also be part of the RFQ:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

<tr>
    <th><strong>Item</strong></th>
    <th><strong>Make</strong></th>
    <th><strong>Unit</strong></th>
    <th><strong>Quantity</strong></th>
</tr>

<tr>
    <td>{{RowOneItemName}}</td>
    <td>{{RowOneItemMake}}</td>
    <td>{{RowOneItemUnit}}</td>
    <td>{{RowOneItemQuantity}}</td>
</tr>

<tr>
    <td>{{RowTwoItemName}}</td>
    <td>{{RowTwoItemMake}}</td>
    <td>{{RowTwoItemUnit}}</td>
    <td>{{RowTwoItemQuantity}}</td>
</tr>

<tr>
    <td>{{RowThreeItemName}}</td>
    <td>{{RowThreeItemMake}}</td>
    <td>{{RowThreeItemUnit}}</td>
    <td>{{RowThreeItemQuantity}}</td>
</tr>

</table>

<p>
To review the RFQ, please click the link below:
</p>

<p>
<a clicktracking="off" href="{{RfqLink}}">
View RFQ
</a>
</p>

<p>
If you are unable to click the link, copy and paste the following URL into your browser:
<br>
{{RfqLink}}
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',
    FALSE
),
(
    32,
    32,
    'SendTestEmailTemplate',
    'Default',
    1,
    'Diagnostic Test Email - eProcurement System',
    '<p>Dear <strong>User</strong>,</p><p>This is a real-time diagnostic test email dispatched from <strong>eProcurement System Health Check</strong>.</p><p>If you received this message, your SMTP Configuration and Email Channel Pipeline are fully operational.</p><p><strong>Diagnostic Reference:</strong> {{DiagnosticId}}<br><strong>Timestamp (UTC):</strong> {{Timestamp}}</p><br><p>Best Regards,<br>{{DefaultEmailSignature}}</p>',
    FALSE
),
(
    33,
    33,
    'SendTestEmailSummaryTemplate',
    'Default',
    1,
    'Health Check Email Diagnostic Report',
    '<p>Dear User,</p><p>The Email diagnosis has completed successfully. All diagnostic pipeline stages are fully operational.</p><p><strong>Diagnostic Reference:</strong> {{DiagnosticId}}<br><strong>Timestamp:</strong> {{Timestamp}}</p><br><hr/><h3>Health Check Stage-Wise Execution Report</h3><table border="1" cellpadding="6" cellspacing="0" style="border-collapse: collapse; width: 100%; text-align: left;"><thead><tr style="background-color: #f2f2f2;"><th>Diagnostic Stage</th><th>Status</th><th>Duration</th></tr></thead><tbody>{{StageTableRows}}</tbody></table><p>Best Regards,<br>{{DefaultEmailSignature}}</p>',
    FALSE
),
(
    34,
    34,
    'RFQ_ContactPerson',
    'Default',
    1,
    'Vendor reversed the decline against RFQ {{RfqDocNoYearly}}',
    '<p>Dear {{ContactPersonName}},</p>

<p>
This is to inform you that the vendor <strong>{{VendorLegalName}}</strong> has <strong>reversed the decline</strong> on the quotation against RFQ <strong>{{RfqDocNoYearly}}</strong>.
</p>

<p>
Below are the details for your reference:
</p>

<table cellpadding="6" cellspacing="0" border="1"
style="
border-collapse: collapse;
width: 100%;
font-family: Arial, sans-serif;
font-size: 14px;
">

    <tr>
        <td><strong>Vendor Name</strong></td>
        <td>{{VendorLegalName}}</td>
    </tr>

    <tr>
        <td><strong>Vendor Location</strong></td>
        <td>{{VendorLocationAddress}}</td>
    </tr>

    <tr>
        <td><strong>RFQ No.</strong></td>
        <td>{{RfqDocNoYearly}}</td>
    </tr>

</table>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',
    FALSE
),
(
    35,
    35,
    'RFQ_VendorAllContact',
    'Default',
    1,
    'Quotation decline successfully reversed against RFQ {{RfqDocNoYearly}}',
    '<p>Dear {{VendorLegalName}},</p>

<p>

You have successfully <strong>reversed the decline</strong> on the quotation against RFQ <strong>{{RfqDocNoYearly}}</strong>.

</p>

<p>
For any queries or assistance, please contact us.
</p>

<p>
This is a system generated mail. Please do not reply to the sender of this mail.
</p>

<p>
Best Regards,<br>
{{DefaultEmailSignature}}
</p>',
    FALSE
)



		ON CONFLICT (id) DO UPDATE SET
		rule_id = EXCLUDED.rule_id,
		template_name = EXCLUDED.template_name,
		tag = EXCLUDED.tag,
		channel_id = EXCLUDED.channel_id,
		subject = EXCLUDED.subject,
		body = EXCLUDED.body,
		inactive = EXCLUDED.inactive;

		--Notification Action Rule Mapping 
		INSERT INTO globaldata.notification_action_rule_mapping
		(id, notification_action_id, notification_rule_id, notification_template_id, channel_id, inactive)
		VALUES
		(1, 1, 1, 1, 1, FALSE),
		(2, 2, 2, 2, 1, FALSE),
        (3, 3, 3, 3, 1, FALSE),
        (4, 4, 4, 4, 1, FALSE),
		(5, 5, 5, 5, 1, FALSE),
		(17, 17, 17, 17, 1, FALSE),
		(18, 18, 18, 18, 1, FALSE),
		(19, 19, 19, 19, 1, FALSE),
		(20, 20, 20, 20, 1, FALSE),
		(21, 21, 21, 21, 1, FALSE),
		(22, 22, 22, 22, 1, FALSE),
		(23, 23, 23, 23, 1, FALSE),
		(24, 24, 24, 24, 1, FALSE),
		(25, 25, 25, 25, 1, FALSE),
        (26, 26, 26, 26, 1, FALSE),
		(27, 27, 27, 27, 1, FALSE),
		(28, 28, 28, 28, 1, FALSE),
		(29, 29, 29, 29, 1, FALSE),
        (30, 30, 30, 30, 1, FALSE),
        (31, 31, 31, 31, 1, FALSE),
        (32, 32, 32, 32, 1, FALSE),
        (33, 33, 33, 33, 1, FALSE),
        (34, 34, 34, 34, 1, FALSE),
        (35, 35, 35, 35, 1, FALSE)

		ON CONFLICT (id) DO UPDATE SET
		notification_action_id = EXCLUDED.notification_action_id,
		notification_rule_id = EXCLUDED.notification_rule_id,
		notification_template_id = EXCLUDED.notification_template_id,
		channel_id = EXCLUDED.channel_id,
		inactive = EXCLUDED.inactive;


        --Company Quotation Edit Policy
        INSERT INTO globaldata.company_quotation_edit_policy (id, company_quotation_edit_policy_name, inactive) VALUES
            (1, 'All Allowed', FALSE),
            (2, 'Not Allowed', FALSE),
            (3, 'Only New Allowed', FALSE),
            (4, 'Only Edit Allowed', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            company_quotation_edit_policy_name = EXCLUDED.company_quotation_edit_policy_name,
            inactive = EXCLUDED.inactive;

        --Payment Mode
        INSERT INTO globaldata.payment_modes (id, payment_mode_name, inactive) VALUES
            (1, 'Cash', false),
            (2, 'DD', false),
            (3, 'NEFT', false),
            (4, 'RTGS', false),
            (5, 'Cheque', false),
            (6, 'LC', false),
            (7, 'NEFT Through Cheque', false),
            (8, 'RTGS Through Cheque', false),
            (9, 'BG', true),
            (10, 'Advance', false),
            (11, 'Next Day Payment', false),
            (12, 'On Credit', false),
            (13, 'Against PDC', false),
            (14, 'S-Advance', false),
            (15, 'Sight LC', false),
            (16, 'Mixed', false)
            ON CONFLICT (id) DO UPDATE SET
            payment_mode_name = EXCLUDED.payment_mode_name,
            inactive = EXCLUDED.inactive;

        --Calc Nature
        INSERT INTO globaldata.calc_nature (id, calc_nature_name, inactive) VALUES
            (1, 'Addition', FALSE),
            (2, 'Subtraction', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            calc_nature_name = EXCLUDED.calc_nature_name,
            inactive = EXCLUDED.inactive;
        
        --Charge Type
        INSERT INTO globaldata.charge_type (id, charge_type_name, inactive) VALUES
            (1, 'Inclusive', FALSE),
            (2, 'Exclusive', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            charge_type_name = EXCLUDED.charge_type_name,
            inactive = EXCLUDED.inactive;

        --Charge On
        INSERT INTO globaldata.charge_on (id, charge_on_name, inactive) VALUES
            (1, 'On Item', FALSE),
            (2, 'On Order', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            charge_on_name = EXCLUDED.charge_on_name,
            inactive = EXCLUDED.inactive;

        --Freight Type
        INSERT INTO globaldata.freight_type (id, freight_type_name, inactive) VALUES
            (1, 'FOR', FALSE),
            (2, 'TOPAY', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            freight_type_name = EXCLUDED.freight_type_name,
            inactive = EXCLUDED.inactive;
        
        --Freight Rate Type
        INSERT INTO globaldata.freight_rate_type (id, freight_rate_type_name, inactive) VALUES
            (1, 'Fixed', FALSE),
            (2, 'Per Unit', FALSE),
            (3, 'Per Trip', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            freight_rate_type_name = EXCLUDED.freight_rate_type_name,
            inactive = EXCLUDED.inactive;

		-- Vendor Selection Basis
		INSERT INTO globaldata.vendor_selection_basis (id, vendor_selection_basis_name, inactive) VALUES
		    (1, 'Quotation Item Wise', FALSE),
		    (2, 'Quotation Wise', FALSE)
			ON CONFLICT (id) DO UPDATE SET
		    vendor_selection_basis_name = EXCLUDED.vendor_selection_basis_name,
		    inactive = EXCLUDED.inactive;

		-- Selection Criteria
		INSERT INTO globaldata.selection_criteria (id, selection_criteria_name, inactive) VALUES
		    (1, 'Lowest', FALSE),
		    (2, 'Highest Wise', FALSE)
			ON CONFLICT (id) DO UPDATE SET
		    selection_criteria_name = EXCLUDED.selection_criteria_name,
		    inactive = EXCLUDED.inactive;

        -- Make Managemet Type

        INSERT INTO globaldata.make_mgmt_type (id, make_mgmt_type_name, inactive) VALUES
            (1, 'All', FALSE),
            (2, 'Selected', FALSE),
            (3, 'None', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            make_mgmt_type_name = EXCLUDED.make_mgmt_type_name,
            inactive = EXCLUDED.inactive;

        -- Vehicle Type
        INSERT INTO globaldata.vehicle_type (id, vehicle_type_name, code, category, "isDefault", inactive) VALUES
            (1, 'Truck', 'T', 'ROAD', true, false),
            (2, 'Dumper', 'D', 'ROAD', false, false),
            (3, 'Auto', 'A', 'ROAD', false, false),
            (4, 'Trailer', 'L', 'ROAD', false, false),
            (5, 'Normal', 'N', 'ROAD', false, false),
            (6, 'Railway Rake', 'R', 'RAIL', false, false),
            (7, 'BUS', 'B', 'ROAD', false, false),
            (8, 'Tanker', 'K', 'ROAD', false, false),
            (9, 'BY-COURIER', 'C', 'COURIER', false, false),
            (10, 'BY-ROAD', 'P', 'ROAD', false, false),
            (11, 'BY-SHIP', 'S', 'SEA', false, false),
            (12, 'BY-AIRWAYS', 'R', 'AIR', false, false)
            ON CONFLICT (id) DO UPDATE SET
            code = EXCLUDED.code,
            vehicle_type_name = EXCLUDED.vehicle_type_name,
            category = EXCLUDED.category,
            "isDefault" = EXCLUDED."isDefault",
            inactive = EXCLUDED.inactive;

        -- Due Basis
        INSERT INTO globaldata.due_basis (id, due_basis_type_name, inactive) VALUES
            (1, 'GRN', FALSE),
            (2, 'Gate Entry', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            due_basis_type_name = EXCLUDED.due_basis_type_name,
            inactive = EXCLUDED.inactive;

        -- Tolerance Type
        INSERT INTO globaldata.tolerance_type (id, tolerance_type_name, inactive) VALUES
            (1, 'Quantity', FALSE),
            (2, 'Percentage', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            tolerance_type_name = EXCLUDED.tolerance_type_name,
            inactive = EXCLUDED.inactive;
        
        --Tax Nature
        INSERT INTO globaldata.tax_nature (id, tax_nature_name, inactive) VALUES
            (1, 'Percentage', FALSE),
            (2, 'Amount', FALSE),
            (3, 'On Unit', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            tax_nature_name = EXCLUDED.tax_nature_name,
            inactive = EXCLUDED.inactive;

         -- Tax Category
        INSERT INTO globaldata.tax_category (id, tax_category_name, is_editable,  inactive) VALUES
            (1, 'Discount', TRUE, FALSE),
            (2, 'GST', FALSE, FALSE),
            (3, 'Other', FALSE, FALSE),
            (4, 'Freight', FALSE, FALSE),
            (5, 'TCS', FALSE, FALSE),
            (6, 'Rounding Adjustment', FALSE, FALSE),
            (7, 'Insurance', FALSE, FALSE),
   (8, 'Loading/Unloading', FALSE, FALSE)
            ON CONFLICT (id) DO UPDATE SET
            tax_category_name = EXCLUDED.tax_category_name,
            is_editable = EXCLUDED.is_editable,
            inactive = EXCLUDED.inactive;

   -- Tax Group
	INSERT INTO globaldata.tax_group
	(
	    id,
	    code,
	    tax_group_name,
	    tax_category_id,
	    inactive,
	    is_charge_on_item_applicable,
	    is_charge_on_order_applicable,
	    is_nature_amount_applicable,
	    is_nature_perc_applicable,
	    is_nature_unit_applicable,
	    formula,
	    seq_no
	)
	VALUES
	    -- GST
	    (1, 'CENGST',  'Central GST',  2, FALSE, TRUE,  TRUE, TRUE, TRUE, TRUE, '(BasicAmount-DISC01+FREBEF)*CENGST*0.01', 6),
	    (2, 'STAGST',  'State GST',  2, FALSE, TRUE,  TRUE, TRUE, TRUE, TRUE, '(BasicAmount-DISC01+FREBEF)*STAGST*0.01', 7),
	    (3, 'INTGST',  'Integrated GST',  2, FALSE, TRUE,  TRUE, TRUE, TRUE, TRUE, '(BasicAmount-DISC01+FREBEF)*INTGST*0.01', 8),
	    (10,'UNTGST',  'UT GST',  2, FALSE, TRUE,  TRUE, TRUE, TRUE, TRUE, '(BasicAmount-DISC01+FREBEF)*UNTGST*0.01', 9),
	    (11,'CESGST', 'Cess GST', 2, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, '(BasicAmount-DISC01+FREBEF)*CESGST*0.01', 10),
	
	    -- Discount
	    (4, 'DISC01',  'DISCOUNT', 1, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, '(BasicAmount*DISC01)*0.01', 1),
	
	    -- Other Categories
	    (5, 'OTHR01',  'OTHER (+)', 3, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, '(BasicAmount*OTHR01)*0.01', 3),

	    (6, 'FREBEF',   'Freight (Taxable)', 4, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, '(BasicAmount-DISC01)*FREBEF*0.01', 2),
	    (7, 'TCS001',   'TCS', 5, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, '(BasicAmount*TCS001)*0.01', 12),
	    (8, 'ROND01', 'ROUNDING ADJUSTMENT (+)', 6, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, NULL, 13),
	    (9, 'INSR01',   'INSURANCE', 7, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, '(BasicAmount*INSR01)*0.01', 15),
            (12, 'FREAFT',   'Freight (Non Taxable)', 4, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, '(BasicAmount-DISC01)*FREAFT*0.01', 11),
            (13, 'OTHR02',  'OTHER (-)', 3, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, '(BasicAmount*OTHR02)*0.01', 4),
            (14, 'ROND02', 'ROUNDING ADJUSTMENT (-)', 6, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, NULL, 14),
	    (15, 'LODUNL',   'Loading / Unloading', 8, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, '(BasicAmount*LODUNL)*0.01', 16)
	
	ON CONFLICT (id) DO UPDATE SET
	    code = EXCLUDED.code,
	    tax_group_name = EXCLUDED.tax_group_name,
	    tax_category_id = EXCLUDED.tax_category_id,
	    inactive = EXCLUDED.inactive,
	    is_charge_on_item_applicable = EXCLUDED.is_charge_on_item_applicable,
	    is_charge_on_order_applicable = EXCLUDED.is_charge_on_order_applicable,
	    is_nature_amount_applicable = EXCLUDED.is_nature_amount_applicable,
	    is_nature_perc_applicable = EXCLUDED.is_nature_perc_applicable,
	    is_nature_unit_applicable = EXCLUDED.is_nature_unit_applicable,
	    formula = EXCLUDED.formula,
	    seq_no = EXCLUDED.seq_no; 

        -- Unit Type
        INSERT INTO globaldata.unit_type (id, unit_type_name, inactive) VALUES
            (1, 'Stock', FALSE),
            (2, 'Purchase', FALSE),
            (3, 'Issue', FALSE)
            ON CONFLICT (id) DO UPDATE SET
            unit_type_name = EXCLUDED.unit_type_name,
            inactive = EXCLUDED.inactive;

		-- Region Setup
		INSERT INTO globaldata.region_setup (id, region_setup_name, inactive) VALUES
		    (1, 'India With GST', FALSE),
		    (2, 'India Without GST', FALSE),
		    (3, 'Other', FALSE)
		ON CONFLICT (id) DO UPDATE SET
		    region_setup_name = EXCLUDED.region_setup_name,
		    inactive = EXCLUDED.inactive;


		-- Country Regulation
		INSERT INTO globaldata.country_regulation (id, country_regulation_name, inactive) VALUES
		    (1, 'None', FALSE),
		    (2, 'India[GST,PAN]', FALSE),
		    (3, 'India[GST,PAN,MSME]', FALSE)
		ON CONFLICT (id) DO UPDATE SET
		    country_regulation_name = EXCLUDED.country_regulation_name,
		    inactive = EXCLUDED.inactive;
		
		
		-- Selection Policy
		INSERT INTO globaldata.selection_policy (id, selection_policy_name, inactive) VALUES
		    (1, 'Hide', FALSE),
		    (2, 'Optional', FALSE),
		    (3, 'Mandatory', FALSE)
		ON CONFLICT (id) DO UPDATE SET
		    selection_policy_name = EXCLUDED.selection_policy_name,
		    inactive = EXCLUDED.inactive;

		-- Comparative Statement Head
		INSERT INTO globaldata.comparative_statement_head 
		    (id, code, group_name, head_name, inactive)
		VALUES
		    (1,  'VD_VNAME',           'Vendor Detail',            'Vendor Name',            FALSE),
		    (2,  'VD_VLOCATION',       'Vendor Detail',            'Vendor Location',        FALSE),
		    (3,  'QD_STATUS',          'Quotation Detail',  'Status',                 FALSE),
		    (4,  'QD_QUOTATION_NO',    'Quotation Detail',  'Quotation No.',          FALSE),
		    (5,  'QD_QUOTATION_DATE',  'Quotation Detail',  'Quotation Date',         FALSE),
		    (6,  'QD_REVISION_NO',     'Quotation Detail',  'Revision No.',           FALSE),
		    (7,  'QD_CURRENCY',        'Quotation Detail',  'Currency',               FALSE),
		    (8,  'QD_REMARKS',         'Quotation Detail',  'Remarks',                FALSE),
		    (9,  'IT_MAKE',            'Item',              'Make',                   FALSE),
		    (10, 'IT_RATE',            'Item',              'Rate',                   FALSE),
		    (11, 'IT_BASIC_AMT',       'Item',              'Basic Amount',           FALSE),
		    (12, 'IT_DISC_AMT',        'Item',              'Discount Amount',        FALSE),
		    (13, 'IT_BASIC_AFTR_DISC', 'Item',              'Basic After Discount',   FALSE),
		    (14, 'IT_RATE_AFTR_DISC',  'Item',              'Rate After Discount',    FALSE),
		    (15, 'IT_REMARKS',         'Item',              'Item Remarks',           FALSE),
		    (16, 'IT_DEL_DAYS',        'Item',              'Delivery Days',          FALSE),
		    (17, 'SM_BASIC_AMT',       'Summary',           'Basic Amount',           FALSE),
		    (18, 'SM_DISC_AMT',        'Summary',           'Discount Amount',        FALSE),
		    (19, 'SM_AVG_DEL_DAYS',    'Summary',           'Avg. Delivery Days',     FALSE),
		    (20, 'SM_NET_AMT',         'Summary',           'Net Amount',             FALSE)
		
		ON CONFLICT (id) DO UPDATE SET
		    code       = EXCLUDED.code,
		    group_name = EXCLUDED.group_name,
		    head_name  = EXCLUDED.head_name,
		    inactive   = EXCLUDED.inactive;

           -- Reason Type
            INSERT INTO globaldata.reason_type
            (
                id,
                reason_type_name,
                inactive
            )
            VALUES
                (1, 'Reduced Qty', FALSE),
                (2, 'Exceed Qty', FALSE)
            ON CONFLICT (id) DO UPDATE SET
                reason_type_name = EXCLUDED.reason_type_name,
                inactive = EXCLUDED.inactive;


                			-- Payment Type
INSERT INTO globaldata.payment_type
(
    id,
    payment_type_name,
    inactive
)
VALUES
    (1, 'Down Payment', FALSE),
    (2, 'Down Payment PI', FALSE),
    (3, 'Against Bill', FALSE)
ON CONFLICT (id) DO UPDATE SET
    payment_type_name = EXCLUDED.payment_type_name,
    inactive = EXCLUDED.inactive;


-- Base Date Type
INSERT INTO globaldata.base_date_type
(
    id,
    base_date_type_name,
    inactive
)
VALUES
    (1, 'Document Date', FALSE),
    (2, 'Posting Date', FALSE),
    (3, 'Transaction Date', FALSE)
ON CONFLICT (id) DO UPDATE SET
    base_date_type_name = EXCLUDED.base_date_type_name,
    inactive = EXCLUDED.inactive;


	-- Pay On
INSERT INTO globaldata.pay_on
(
    id,
    pay_on_name,
    inactive
)
VALUES
    (1, 'Basic Amount', FALSE),
    (2, 'Net Amount', FALSE),
    (3, 'Balance Amount', FALSE)
ON CONFLICT (id) DO UPDATE SET
    pay_on_name = EXCLUDED.pay_on_name,
    inactive = EXCLUDED.inactive;


	-- Expense Nature
INSERT INTO globaldata.expense_nature
(
    id,
    expense_nature_name,
    inactive
)
VALUES
    (1, 'Service', FALSE),
    (2, 'Charges', FALSE)
ON CONFLICT (id) DO UPDATE SET
    expense_nature_name = EXCLUDED.expense_nature_name,
    inactive = EXCLUDED.inactive;


-- Billing Qty Basis
INSERT INTO globaldata.billing_qty_basis
(
    id,
    billing_qty_basis_name,
    inactive
)
VALUES
    (1, 'Accepted Qty', FALSE),
    (2, 'Challan Qty', FALSE),
    (3, 'PO Qty', FALSE),
    (4, 'Received Qty', FALSE)
ON CONFLICT (id) DO UPDATE SET
    billing_qty_basis_name = EXCLUDED.billing_qty_basis_name,
    inactive = EXCLUDED.inactive;

-- Warehouse Type
INSERT INTO globaldata.warehouse_type
(
    id,
    warehouse_type_name,
    inactive
)
VALUES
    (1, 'In-house', FALSE),
    (2, 'External', FALSE)
ON CONFLICT (id) DO UPDATE SET
    warehouse_type_name = EXCLUDED.warehouse_type_name,
    inactive = EXCLUDED.inactive;


-- Ownership
INSERT INTO globaldata.ownership
(
    id,
    ownership_name,
    inactive
)
VALUES
    (1, 'Own', FALSE),
    (2, 'Party', FALSE)
ON CONFLICT (id) DO UPDATE SET
    ownership_name = EXCLUDED.ownership_name,
    inactive = EXCLUDED.inactive;


    	-- Transportation Route Level
INSERT INTO globaldata.transportation_route_level
(
    id,
    transportation_route_level_name,
    inactive
)
VALUES
    (1, 'Document Wise', FALSE),
    (2, 'Item Wise', FALSE)
ON CONFLICT (id) DO UPDATE SET
    transportation_route_level_name = EXCLUDED.transportation_route_level_name,
    inactive = EXCLUDED.inactive;


    -- Announcement Type
	INSERT INTO globaldata.announcement_type
(
    id,
    announcement_type_name,
    inactive
)
VALUES
    (1, 'NewsFeed (Scrolling Ticker)', FALSE),
    (2, 'Banner (Pop-up Alert)', FALSE)
ON CONFLICT (id) DO UPDATE SET
    announcement_type_name = EXCLUDED.announcement_type_name,
    inactive = EXCLUDED.inactive;

	
-- Announcement Audience
INSERT INTO globaldata.announcement_audience
(
    id,
    announcement_audience_name,
    inactive
)
VALUES
    (1, 'Company', FALSE),
    (2, 'Vendor', FALSE),
    (3, 'Both', FALSE),
    (4, 'LandingPage', FALSE)
ON CONFLICT (id) DO UPDATE SET
    announcement_audience_name = EXCLUDED.announcement_audience_name,
    inactive = EXCLUDED.inactive;



-- Announcement Banner Size
	INSERT INTO globaldata.announcement_banner_size
(
    id,
    announcement_banner_size_name,
    inactive
)
VALUES
    (1, 'Small', FALSE),
    (2, 'Medium', FALSE),
    (3, 'Large', FALSE),
    (4, 'Full-Screen', FALSE)
ON CONFLICT (id) DO UPDATE SET
    announcement_banner_size_name = EXCLUDED.announcement_banner_size_name,
    inactive = EXCLUDED.inactive;

INSERT INTO globaldata.current_requirement_data_variant (id, variant_type,inactive) 
	VALUES
	 (1, 'ItemName_SubgroupName_GroupName_CategoryName_TechSpecification_MakeName_Quantity',false),
	 (2, 'ItemName_SubgroupName_GroupName_CategoryName_TechSpecification',false),
	 (3, 'ItemName_SubgroupName_GroupName_CategoryName_TechSpecification_MakeName',false)

	ON CONFLICT (id) DO UPDATE SET
    variant_type = EXCLUDED.variant_type,
    inactive = EXCLUDED.inactive;



    -- Negotiation On
INSERT INTO globaldata.negotiation_on
(
    id,
    negotiation_on_name,
    inactive
)
VALUES
    (1, 'Discount %', FALSE),
    (2, 'Discount Amount', FALSE),
    (3, 'Basic Amount', FALSE)
ON CONFLICT (id) DO UPDATE SET
    negotiation_on_name = EXCLUDED.negotiation_on_name,
    inactive = EXCLUDED.inactive;

    -- Vendor Rating Period Type
    INSERT INTO globaldata.vendor_rating_period_type
(
    id,
    vendor_rating_period_type_name,
    inactive
)
VALUES
    (1, 'Today', FALSE),
    (2, '3 Months', FALSE),
    (3, '6 Months', FALSE)
ON CONFLICT (id) DO UPDATE SET
    vendor_rating_period_type_name = EXCLUDED.vendor_rating_period_type_name,
    inactive = EXCLUDED.inactive;


     -- PO Document Level
        INSERT INTO globaldata.po_document_level
        (
            Id,
            po_document_level_name,
            inactive,
            is_default
        )
        VALUES
            (1, 'LOI', TRUE,  FALSE),
            (2, 'PO',  FALSE, FALSE),
            (3, 'RO',  TRUE,  FALSE)
        ON CONFLICT (Id) DO UPDATE SET
            po_document_level_name = EXCLUDED.po_document_level_name,
            inactive              = EXCLUDED.inactive,
            is_default            = EXCLUDED.is_default;

        -- Purchase Category
        INSERT INTO globaldata.purchase_category
        (
            Id,
            purchase_category_name,
            inactive
        )
        VALUES
            (1, 'Import',  FALSE),
            (2, 'Domestic', FALSE)
        ON CONFLICT (Id) DO UPDATE SET
            purchase_category_name = EXCLUDED.purchase_category_name,
            inactive               = EXCLUDED.inactive;


	    -- Supply Type
		INSERT INTO globaldata.supply_type
		(
			Id,
			supply_type_name,
			inactive
		)
		VALUES
			(1, 'Intrastate',  FALSE),
			(2, 'InterState', FALSE)
		ON CONFLICT (Id) DO UPDATE SET
			supply_type_name = EXCLUDED.supply_type_name,
			inactive         = EXCLUDED.inactive;

		-- Auction Type
		INSERT INTO globaldata.auction_type
		(
			Id,
			auction_type_name,
			inactive
		)
		VALUES
			(1, 'Forward (Sales)',  FALSE),
			(2, 'Reverse (Purchase)', FALSE)
		ON CONFLICT (Id) DO UPDATE SET
			auction_type_name = EXCLUDED.auction_type_name,
			inactive         = EXCLUDED.inactive;

		-- Base Price Setting
		INSERT INTO globaldata.base_price_setting
		(
			Id,
			base_price_setting_name,
			inactive
		)
		VALUES
			(1, 'None',  FALSE),
			(2, 'OverAll', FALSE),
			(3, 'Item-Wise', FALSE)
		ON CONFLICT (Id) DO UPDATE SET
			base_price_setting_name = EXCLUDED.base_price_setting_name,
			inactive         = EXCLUDED.inactive;

		-- Bid Difference Type
		INSERT INTO globaldata.bid_difference_type
		(
			Id,
			bid_difference_type_name,
			inactive
		)
		VALUES
			(1, 'Amount',  FALSE),
			(2, 'Percentage', FALSE)
		ON CONFLICT (Id) DO UPDATE SET
			bid_difference_type_name = EXCLUDED.bid_difference_type_name,
			inactive         = EXCLUDED.inactive;

		-- Extension Type
		INSERT INTO globaldata.extension_type
		(
			Id,
			extension_type_name,
			inactive
		)
		VALUES
			(1, 'Manual',  FALSE),
			(2, 'Auto-Grace', FALSE)
		ON CONFLICT (Id) DO UPDATE SET
			extension_type_name = EXCLUDED.extension_type_name,
			inactive         = EXCLUDED.inactive;

            -- Budget Type
INSERT INTO globaldata.budget_type
(
    id,
    budget_type_name,
    inactive
)
VALUES
    (1, 'Division/Department', FALSE),
    (2, 'Item', FALSE),
    (3, 'Cost Center', FALSE)
ON CONFLICT (id) DO UPDATE SET
    budget_type_name = EXCLUDED.budget_type_name,
    inactive         = EXCLUDED.inactive;


		EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error occurred: %', SQLERRM;
            RAISE;
    END;
END;
$MAIN$ LANGUAGE plpgsql;