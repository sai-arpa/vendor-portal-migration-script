CREATE TABLE migration.status_mapping (
    old_status_id   INT,
    old_status_name VARCHAR(100),
    new_status_id   INT,
    new_status_name VARCHAR(100)
);

-- Insert data
INSERT INTO migration.status_mapping (
    old_status_id,
    old_status_name,
    new_status_id,
    new_status_name
)
VALUES
(1,  'Authorized',  9,  'Authorize'),
(2,  'Completed',   11, 'Completed'),
(3,  'Hold',        17, 'Hold'),
(4,  'Cancel',      15, 'Cancelled'),
(5,  'Initial',     7,  'Draft'),
(6,  'Release',     14, 'In Review'),
(7,  'Short Close', 16, 'Short Closed'),
(8,  'In Progress', 10, 'In Progress'),
(9,  'Reject',      13, 'Rejected'),
(10, 'Fixed',       12, 'Approved'),
(11, 'Open',        1,  'Active'),
(12, 'Accept',      12, 'Approved'),
(13, 'Approve',     12, 'Approved'),
(14, 'Pending',     3,  'Pending'),
(15, 'Live',        1,  'Active'),
(16, 'Expired',     5,  'Expired'),
(17, 'Skipped',     19, 'Skipped');
