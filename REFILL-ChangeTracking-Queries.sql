-- REFILL Table Change Tracking Queries
-- Use these SQL commands in SSMS to monitor REFILL table changes

-- =============================================
-- 1. CHECK REFILL TABLE CHANGE TRACKING STATUS
-- =============================================
SELECT 
    t.name AS TableName,
    ct.is_track_columns_updated_on,
    ct.begin_version,
    ct.cleanup_version
FROM sys.change_tracking_tables ct
INNER JOIN sys.tables t ON ct.object_id = t.object_id
WHERE t.name = 'REFILL';

-- =============================================
-- 2. GET CURRENT CHANGE TRACKING VERSION
-- =============================================
SELECT CHANGE_TRACKING_CURRENT_VERSION() AS CurrentVersion;

-- =============================================
-- 3. GET ALL CHANGES FOR REFILL TABLE (FROM VERSION 0)
-- =============================================
DECLARE @last_sync_version bigint = 0;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.SYS_CHANGE_COLUMNS,
    CT.REFILLID,
    R.*  -- Get all current row data
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
LEFT JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 4. GET RECENT CHANGES FOR REFILL TABLE (FROM SPECIFIC VERSION)
-- =============================================
-- Replace 0 with your last known version number
DECLARE @last_sync_version bigint = 0;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.SYS_CHANGE_COLUMNS,
    CT.REFILLID,
    CASE 
        WHEN CT.SYS_CHANGE_OPERATION = 'I' THEN 'INSERT'
        WHEN CT.SYS_CHANGE_OPERATION = 'U' THEN 'UPDATE'
        WHEN CT.SYS_CHANGE_OPERATION = 'D' THEN 'DELETE'
        ELSE CT.SYS_CHANGE_OPERATION
    END AS Operation_Type,
    R.*  -- Get all current row data (NULL for DELETEs)
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
LEFT JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 5. GET CHANGES FOR REFILL TABLE WITH TIMESTAMPS
-- =============================================
DECLARE @last_sync_version bigint = 0;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.SYS_CHANGE_COLUMNS,
    CT.REFILLID,
    CASE 
        WHEN CT.SYS_CHANGE_OPERATION = 'I' THEN 'INSERT'
        WHEN CT.SYS_CHANGE_OPERATION = 'U' THEN 'UPDATE'
        WHEN CT.SYS_CHANGE_OPERATION = 'D' THEN 'DELETE'
        ELSE CT.SYS_CHANGE_OPERATION
    END AS Operation_Type,
    GETDATE() AS Query_Time,
    R.*  -- Get all current row data
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
LEFT JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 6. GET ONLY INSERT OPERATIONS FOR REFILL TABLE
-- =============================================
DECLARE @last_sync_version bigint = 0;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.REFILLID,
    R.*  -- Get all current row data
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
INNER JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
WHERE CT.SYS_CHANGE_OPERATION = 'I'
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 7. GET ONLY UPDATE OPERATIONS FOR REFILL TABLE
-- =============================================
DECLARE @last_sync_version bigint = 0;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.SYS_CHANGE_COLUMNS,
    CT.REFILLID,
    R.*  -- Get all current row data
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
INNER JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
WHERE CT.SYS_CHANGE_OPERATION = 'U'
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 8. GET ONLY DELETE OPERATIONS FOR REFILL TABLE
-- =============================================
DECLARE @last_sync_version bigint = 0;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.REFILLID,
    -- No JOIN here since row is deleted
    NULL AS Deleted_Record_Info
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
WHERE CT.SYS_CHANGE_OPERATION = 'D'
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 9. GET CHANGES FOR SPECIFIC REFILL RECORD
-- =============================================
-- Replace 12345 with the actual REFILLID you want to track
DECLARE @last_sync_version bigint = 0;
DECLARE @refill_id int = 12345;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.SYS_CHANGE_COLUMNS,
    CT.REFILLID,
    CASE 
        WHEN CT.SYS_CHANGE_OPERATION = 'I' THEN 'INSERT'
        WHEN CT.SYS_CHANGE_OPERATION = 'U' THEN 'UPDATE'
        WHEN CT.SYS_CHANGE_OPERATION = 'D' THEN 'DELETE'
        ELSE CT.SYS_CHANGE_OPERATION
    END AS Operation_Type,
    R.*  -- Get all current row data
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
LEFT JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
WHERE CT.REFILLID = @refill_id
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 10. GET CHANGES WITH VERSION RANGE FOR REFILL TABLE
-- =============================================
-- Get changes between specific versions
DECLARE @from_version bigint = 0;
DECLARE @to_version bigint = 100;

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.SYS_CHANGE_COLUMNS,
    CT.REFILLID,
    CASE 
        WHEN CT.SYS_CHANGE_OPERATION = 'I' THEN 'INSERT'
        WHEN CT.SYS_CHANGE_OPERATION = 'U' THEN 'UPDATE'
        WHEN CT.SYS_CHANGE_OPERATION = 'D' THEN 'DELETE'
        ELSE CT.SYS_CHANGE_OPERATION
    END AS Operation_Type,
    R.*  -- Get all current row data
FROM CHANGETABLE(CHANGES [REFILL], @from_version) AS CT
LEFT JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
WHERE CT.SYS_CHANGE_VERSION <= @to_version
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 11. MONITORING QUERY - GET LATEST CHANGES ONLY
-- =============================================
-- Use this query repeatedly to monitor new changes
-- Update @last_checked_version with the highest version from previous run

DECLARE @last_checked_version bigint = 0;  -- Update this with your last checked version

SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.REFILLID,
    CASE 
        WHEN CT.SYS_CHANGE_OPERATION = 'I' THEN 'INSERT'
        WHEN CT.SYS_CHANGE_OPERATION = 'U' THEN 'UPDATE'
        WHEN CT.SYS_CHANGE_OPERATION = 'D' THEN 'DELETE'
        ELSE CT.SYS_CHANGE_OPERATION
    END AS Operation_Type,
    GETDATE() AS Detected_At,
    R.*  -- Get all current row data
FROM CHANGETABLE(CHANGES [REFILL], @last_checked_version) AS CT
LEFT JOIN [REFILL] R ON CT.REFILLID = R.REFILLID
ORDER BY CT.SYS_CHANGE_VERSION;

-- =============================================
-- 12. SUMMARY QUERY - COUNT CHANGES BY OPERATION TYPE
-- =============================================
DECLARE @last_sync_version bigint = 0;

SELECT 
    CASE 
        WHEN CT.SYS_CHANGE_OPERATION = 'I' THEN 'INSERT'
        WHEN CT.SYS_CHANGE_OPERATION = 'U' THEN 'UPDATE'
        WHEN CT.SYS_CHANGE_OPERATION = 'D' THEN 'DELETE'
        ELSE CT.SYS_CHANGE_OPERATION
    END AS Operation_Type,
    COUNT(*) AS Change_Count,
    MIN(CT.SYS_CHANGE_VERSION) AS Min_Version,
    MAX(CT.SYS_CHANGE_VERSION) AS Max_Version
FROM CHANGETABLE(CHANGES [REFILL], @last_sync_version) AS CT
GROUP BY CT.SYS_CHANGE_OPERATION
ORDER BY Operation_Type;
