CREATE TABLE IF NOT EXISTS migration.form_mapping (
    new_form_id INTEGER NOT NULL,
    old_form_id INTEGER NOT NULL
);

INSERT INTO migration.form_mapping (new_form_id, old_form_id)
VALUES
(46,185),   -- Role Master, Role Master
(45,186),   -- User Master, User Master
(44,1001),  -- User Access Control, User Access Control
(35,1018),  -- Item Master, Item Master
(33,1015),  -- Category Master, Category Master
(32,1016),  -- Group Master, Group Master
(34,1017),  -- Subgroup Master, Sub Group Master
(19,1029),  -- Unit Master, Unit
(20,1034),  -- Make Master, Make Master
(21,1028),  -- Cost Center Master, Cost Center
(27,1032),  -- Department Master, Department
(16,1033),  -- State Master, State Master
(17,1036),  -- City Master, City Master
(15,1035),  -- Country Master, Country Master
(18,1031),  -- Location Master, Location Master
(24,1030),  -- Division, Division
(49,1058),  -- Vendor Master, Vendor Master List
(36,498),   -- Skip Approval, Skip Auhorization
(37,495),   -- Release Indent, Release Indent
(38,487),   -- Duplicate Item Group, Duplicate Item Group
(39,496),   -- CS Validity, CS Validity
(40,485),   -- Data Fetch Utility, Data Fetch Utility
(42,1005),  -- PO Cancellation, PO Cancellation
(6,1019),   -- Purchase Request, Purchase Request
(7,462),    -- Request For Quotation, RFQ
(8,464),    -- Comparative Statement, Comparative Statement
(9,466),    -- Quotation, Quotation
(10,463),   -- Purchase Order, Purchase Order
(51,1052),  -- Purchase Request Approval, Indent Authorization
(52,491),   -- Purchase Order Approval, PO Authorization
(53,7),     -- Request For Quotation Approval, RFQ
(54,494),   -- Comparative Statement Approval, CS Authorization
(68,1054),  -- Vendor Wise Procurement, Vendor Wise Procurement
(69,467),   -- Indent Register, Indent Register
(70,1042),  -- Purchase Order Amendment Register, PO Amendment Register
(71,474),   -- Purchase Register, PO Register
(72,475),   -- Purchase Summary, PO Summary
(73,1056),  -- Indent Ageing, Indent Item Ageing
(74,1043),  -- PO Rejection History, PO Rejection History Register
(75,475),   -- PO Summary, PO Summary
(76,490),   -- PO L2 Report, PO L2 Report
(77,1058),  -- Vendor List, Vendor Master List
(79,1013),  -- RFQ To PO Report, RFQ To PO Progress Flow
(80,1055),  -- Item Group Wise Procurement, Item Group Wise Procurement
(81,1053),  -- Item Wise Purchase Summary, Item Wise Procurement
(82,460),   -- New Vendors, New Vendors
(82,501),   -- New Vendors, New Vendors
(83,477);   -- Passive Vendors, Passive Vendors