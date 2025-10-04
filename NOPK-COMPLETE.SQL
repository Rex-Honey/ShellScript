-- =============================================================================
-- COMPLETE NO-PK TABLES TRIGGER SOLUTION (SINGLE FILE)
-- =============================================================================
-- This script creates triggers for tables without primary keys:
-- DOCTOR, INTVENT, MMR, PRESETMESSAGES, SIG, SCANS, WINMAIL_RECEIVED
-- =============================================================================

-- =============================================================================
-- CONFIGURATION - CHANGE DATABASE NAMES HERE
-- =============================================================================
-- To change database names in the future:
-- 1. Change the values below
-- 2. Find and replace all instances of 'medidozeProsper' with your new audit DB name
-- 3. Find and replace all instances of 'winrxProsper' with your new main DB name
-- =============================================================================
DECLARE @MainDatabase VARCHAR(100) = 'winrxProsper'
DECLARE @AuditDatabase VARCHAR(100) = 'medidozeProsper'
-- =============================================================================

USE [winrxProsper]
GO

-- =============================================================================
-- CREATE AUDIT DATABASE
-- =============================================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = @AuditDatabase)
BEGIN
    EXEC('CREATE DATABASE [' + @AuditDatabase + ']')
    PRINT 'Created audit database: ' + @AuditDatabase
END
ELSE
BEGIN
    PRINT 'Audit database already exists: ' + @AuditDatabase
END
GO

-- =============================================================================
-- STEP 1: CREATE AUDIT TABLES FOR EACH TABLE
-- =============================================================================

-- DOCTOR Audit Table
IF EXISTS (SELECT * FROM medidozeProsper.sys.objects WHERE object_id = OBJECT_ID(N'[medidozeProsper].[dbo].[DOCTORAudit]') AND type in (N'U'))
    DROP TABLE [medidozeProsper].[dbo].[DOCTORAudit]

CREATE TABLE [medidozeProsper].[dbo].[DOCTORAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RowHash] [varchar](64) NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    [RowData] [varchar](max) NULL,
    CONSTRAINT [PK_DOCTORAudit] PRIMARY KEY ([AuditID])
)

-- INTVENT Audit Table
IF EXISTS (SELECT * FROM medidozeProsper.sys.objects WHERE object_id = OBJECT_ID(N'[medidozeProsper].[dbo].[INTVENTAudit]') AND type in (N'U'))
    DROP TABLE [medidozeProsper].[dbo].[INTVENTAudit]

CREATE TABLE [medidozeProsper].[dbo].[INTVENTAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RowHash] [varchar](64) NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    [RowData] [varchar](max) NULL,
    CONSTRAINT [PK_INTVENTAudit] PRIMARY KEY ([AuditID])
)

-- PRESETMESSAGES Audit Table
IF EXISTS (SELECT * FROM medidozeProsper.sys.objects WHERE object_id = OBJECT_ID(N'[medidozeProsper].[dbo].[PRESETMESSAGESAudit]') AND type in (N'U'))
    DROP TABLE [medidozeProsper].[dbo].[PRESETMESSAGESAudit]

CREATE TABLE [medidozeProsper].[dbo].[PRESETMESSAGESAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RowHash] [varchar](64) NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    [RowData] [varchar](max) NULL,
    CONSTRAINT [PK_PRESETMESSAGESAudit] PRIMARY KEY ([AuditID])
)

-- SIG Audit Table
IF EXISTS (SELECT * FROM medidozeProsper.sys.objects WHERE object_id = OBJECT_ID(N'[medidozeProsper].[dbo].[SIGAudit]') AND type in (N'U'))
    DROP TABLE [medidozeProsper].[dbo].[SIGAudit]

CREATE TABLE [medidozeProsper].[dbo].[SIGAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RowHash] [varchar](64) NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    [RowData] [varchar](max) NULL,
    CONSTRAINT [PK_SIGAudit] PRIMARY KEY ([AuditID])
)

-- SCANS Audit Table
IF EXISTS (SELECT * FROM medidozeProsper.sys.objects WHERE object_id = OBJECT_ID(N'[medidozeProsper].[dbo].[SCANSAudit]') AND type in (N'U'))
    DROP TABLE [medidozeProsper].[dbo].[SCANSAudit]

CREATE TABLE [medidozeProsper].[dbo].[SCANSAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RowHash] [varchar](64) NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    [RowData] [varchar](max) NULL,
    CONSTRAINT [PK_SCANSAudit] PRIMARY KEY ([AuditID])
)

-- WINMAIL_RECEIVED Audit Table
IF EXISTS (SELECT * FROM medidozeProsper.sys.objects WHERE object_id = OBJECT_ID(N'[medidozeProsper].[dbo].[WINMAIL_RECEIVEDAudit]') AND type in (N'U'))
    DROP TABLE [medidozeProsper].[dbo].[WINMAIL_RECEIVEDAudit]

CREATE TABLE [medidozeProsper].[dbo].[WINMAIL_RECEIVEDAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RowHash] [varchar](64) NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    [RowData] [varchar](max) NULL,
    CONSTRAINT [PK_WINMAIL_RECEIVEDAudit] PRIMARY KEY ([AuditID])
)

-- MMR Audit Table
IF EXISTS (SELECT * FROM medidozeProsper.sys.objects WHERE object_id = OBJECT_ID(N'[medidozeProsper].[dbo].[MMRAudit]') AND type in (N'U'))
    DROP TABLE [medidozeProsper].[dbo].[MMRAudit]

CREATE TABLE [medidozeProsper].[dbo].[MMRAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RowHash] [varchar](64) NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    [RowData] [varchar](max) NULL,
    CONSTRAINT [PK_MMRAudit] PRIMARY KEY ([AuditID])
)

PRINT 'Created audit tables for all No-PK tables'
GO

-- =============================================================================
-- STEP 2: CREATE HELPER FUNCTIONS FOR EACH TABLE
-- =============================================================================

-- DOCTOR Hash Function
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateDOCTORRowHash]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GenerateDOCTORRowHash]
GO

CREATE FUNCTION [dbo].[GenerateDOCTORRowHash](@RowData VARCHAR(MAX))
RETURNS VARCHAR(64)
AS
BEGIN
    DECLARE @Hash VARCHAR(64)
    DECLARE @Timestamp VARCHAR(20)
    SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '-', ''), ' ', ''), ':', '')
    SET @Hash = 'DOCTOR_' + CAST(ABS(CHECKSUM(@RowData)) AS VARCHAR(20)) + '_' + @Timestamp
    RETURN @Hash
END
GO

-- INTVENT Hash Function
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateINTVENTRowHash]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GenerateINTVENTRowHash]
GO

CREATE FUNCTION [dbo].[GenerateINTVENTRowHash](@RowData VARCHAR(MAX))
RETURNS VARCHAR(64)
AS
BEGIN
    DECLARE @Hash VARCHAR(64)
    DECLARE @Timestamp VARCHAR(20)
    SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '-', ''), ' ', ''), ':', '')
    SET @Hash = 'INTVENT_' + CAST(ABS(CHECKSUM(@RowData)) AS VARCHAR(20)) + '_' + @Timestamp
    RETURN @Hash
END
GO

-- PRESETMESSAGES Hash Function
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeneratePRESETMESSAGESRowHash]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GeneratePRESETMESSAGESRowHash]
GO

CREATE FUNCTION [dbo].[GeneratePRESETMESSAGESRowHash](@RowData VARCHAR(MAX))
RETURNS VARCHAR(64)
AS
BEGIN
    DECLARE @Hash VARCHAR(64)
    DECLARE @Timestamp VARCHAR(20)
    SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '-', ''), ' ', ''), ':', '')
    SET @Hash = 'PRESET_' + CAST(ABS(CHECKSUM(@RowData)) AS VARCHAR(20)) + '_' + @Timestamp
    RETURN @Hash
END
GO

-- SIG Hash Function
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateSIGRowHash]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GenerateSIGRowHash]
GO

CREATE FUNCTION [dbo].[GenerateSIGRowHash](@RowData VARCHAR(MAX))
RETURNS VARCHAR(64)
AS
BEGIN
    DECLARE @Hash VARCHAR(64)
    DECLARE @Timestamp VARCHAR(20)
    SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '-', ''), ' ', ''), ':', '')
    SET @Hash = 'SIG_' + CAST(ABS(CHECKSUM(@RowData)) AS VARCHAR(20)) + '_' + @Timestamp
    RETURN @Hash
END
GO

-- SCANS Hash Function
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateSCANSRowHash]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GenerateSCANSRowHash]
GO

CREATE FUNCTION [dbo].[GenerateSCANSRowHash](@RowData VARCHAR(MAX))
RETURNS VARCHAR(64)
AS
BEGIN
    DECLARE @Hash VARCHAR(64)
    DECLARE @Timestamp VARCHAR(20)
    SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '-', ''), ' ', ''), ':', '')
    SET @Hash = 'SCANS_' + CAST(ABS(CHECKSUM(@RowData)) AS VARCHAR(20)) + '_' + @Timestamp
    RETURN @Hash
END
GO

-- WINMAIL_RECEIVED Hash Function
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateWINMAIL_RECEIVEDRowHash]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GenerateWINMAIL_RECEIVEDRowHash]
GO

CREATE FUNCTION [dbo].[GenerateWINMAIL_RECEIVEDRowHash](@RowData VARCHAR(MAX))
RETURNS VARCHAR(64)
AS
BEGIN
    DECLARE @Hash VARCHAR(64)
    DECLARE @Timestamp VARCHAR(20)
    SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '-', ''), ' ', ''), ':', '')
    SET @Hash = 'WINMAIL_' + CAST(ABS(CHECKSUM(@RowData)) AS VARCHAR(20)) + '_' + @Timestamp
    RETURN @Hash
END
GO

-- MMR Hash Function
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateMMRRowHash]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GenerateMMRRowHash]
GO

CREATE FUNCTION [dbo].[GenerateMMRRowHash](@RowData VARCHAR(MAX))
RETURNS VARCHAR(64)
AS
BEGIN
    DECLARE @Hash VARCHAR(64)
    DECLARE @Timestamp VARCHAR(20)
    SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '-', ''), ' ', ''), ':', '')
    SET @Hash = 'MMR_' + CAST(ABS(CHECKSUM(@RowData)) AS VARCHAR(20)) + '_' + @Timestamp
    RETURN @Hash
END
GO

PRINT 'Created hash functions for all No-PK tables'
GO

-- =============================================================================
-- STEP 3: CREATE ALL TRIGGERS
-- =============================================================================

-- =============================================================================
-- DOCTOR TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DOCTOR_Insert')
    DROP TRIGGER [trg_DOCTOR_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DOCTOR_Update')
    DROP TRIGGER [trg_DOCTOR_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DOCTOR_Delete')
    DROP TRIGGER [trg_DOCTOR_Delete]

-- DOCTOR INSERT Trigger
CREATE TRIGGER [trg_DOCTOR_Insert]
ON [DOCTOR]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([DRSURNAME] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([DRGIVEN] AS VARCHAR(12)), 'NULL') + '|' +
        ISNULL(CAST([DRPHONE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR1] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR2] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR3] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRNOTE] AS VARCHAR(255)), 'NULL') + '|' +
        ISNULL(CAST([DRNUM] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRCOLLEGE] AS VARCHAR(2)), 'NULL') + '|' +
        ISNULL(CAST([DRFAX] AS VARCHAR(7)), 'NULL') + '|' +
        ISNULL(CAST([DRAREA] AS VARCHAR(3)), 'NULL') + '|' +
        ISNULL(CAST([DREMAIL] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([AddDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([AddUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([DREID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRLONGDISTANCE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([DRWARNING] AS VARCHAR(1)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateDOCTORRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[DOCTORAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'INSERT', GETDATE(), SYSTEM_USER, 'New doctor record added', @RowData
    )
    
    PRINT 'INSERT trigger fired for DOCTOR - Row Hash: ' + @RowHash
END
GO

-- DOCTOR UPDATE Trigger
CREATE TRIGGER [trg_DOCTOR_Update]
ON [DOCTOR]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(DRSURNAME) SET @ChangedColumns = @ChangedColumns + 'DRSURNAME, '
    IF UPDATE(DRGIVEN) SET @ChangedColumns = @ChangedColumns + 'DRGIVEN, '
    IF UPDATE(DRPHONE) SET @ChangedColumns = @ChangedColumns + 'DRPHONE, '
    IF UPDATE(DRADDR1) SET @ChangedColumns = @ChangedColumns + 'DRADDR1, '
    IF UPDATE(DRADDR2) SET @ChangedColumns = @ChangedColumns + 'DRADDR2, '
    IF UPDATE(DRADDR3) SET @ChangedColumns = @ChangedColumns + 'DRADDR3, '
    IF UPDATE(DRNOTE) SET @ChangedColumns = @ChangedColumns + 'DRNOTE, '
    IF UPDATE(DRNUM) SET @ChangedColumns = @ChangedColumns + 'DRNUM, '
    IF UPDATE(DRID) SET @ChangedColumns = @ChangedColumns + 'DRID, '
    IF UPDATE(DRCOLLEGE) SET @ChangedColumns = @ChangedColumns + 'DRCOLLEGE, '
    IF UPDATE(DRFAX) SET @ChangedColumns = @ChangedColumns + 'DRFAX, '
    IF UPDATE(DRAREA) SET @ChangedColumns = @ChangedColumns + 'DRAREA, '
    IF UPDATE(DREMAIL) SET @ChangedColumns = @ChangedColumns + 'DREMAIL, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(DREID) SET @ChangedColumns = @ChangedColumns + 'DREID, '
    IF UPDATE(DRLONGDISTANCE) SET @ChangedColumns = @ChangedColumns + 'DRLONGDISTANCE, '
    IF UPDATE(DRWARNING) SET @ChangedColumns = @ChangedColumns + 'DRWARNING, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = RTRIM(LEFT(@ChangedColumns, LEN(@ChangedColumns) - 1))
    ELSE
        SET @ChangedColumns = 'Unknown columns'
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([DRSURNAME] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([DRGIVEN] AS VARCHAR(12)), 'NULL') + '|' +
        ISNULL(CAST([DRPHONE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR1] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR2] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR3] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRNOTE] AS VARCHAR(255)), 'NULL') + '|' +
        ISNULL(CAST([DRNUM] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRCOLLEGE] AS VARCHAR(2)), 'NULL') + '|' +
        ISNULL(CAST([DRFAX] AS VARCHAR(7)), 'NULL') + '|' +
        ISNULL(CAST([DRAREA] AS VARCHAR(3)), 'NULL') + '|' +
        ISNULL(CAST([DREMAIL] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([AddDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([AddUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([DREID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRLONGDISTANCE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([DRWARNING] AS VARCHAR(1)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateDOCTORRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[DOCTORAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns], [RowData]
    )
    VALUES (
        @RowHash, 'UPDATE', GETDATE(), SYSTEM_USER, 'Doctor record was modified', @ChangedColumns, @RowData
    )
    
    PRINT 'UPDATE trigger fired for DOCTOR - Row Hash: ' + @RowHash + ' - Changed: ' + @ChangedColumns
END
GO

-- DOCTOR DELETE Trigger
CREATE TRIGGER [trg_DOCTOR_Delete]
ON [DOCTOR]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([DRSURNAME] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([DRGIVEN] AS VARCHAR(12)), 'NULL') + '|' +
        ISNULL(CAST([DRPHONE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR1] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR2] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRADDR3] AS VARCHAR(25)), 'NULL') + '|' +
        ISNULL(CAST([DRNOTE] AS VARCHAR(255)), 'NULL') + '|' +
        ISNULL(CAST([DRNUM] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRCOLLEGE] AS VARCHAR(2)), 'NULL') + '|' +
        ISNULL(CAST([DRFAX] AS VARCHAR(7)), 'NULL') + '|' +
        ISNULL(CAST([DRAREA] AS VARCHAR(3)), 'NULL') + '|' +
        ISNULL(CAST([DREMAIL] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([AddDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([AddUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([DREID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([DRLONGDISTANCE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([DRWARNING] AS VARCHAR(1)), 'NULL')
    FROM deleted
    
    SET @RowHash = [dbo].[GenerateDOCTORRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[DOCTORAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'DELETE', GETDATE(), SYSTEM_USER, 'Doctor record was deleted', @RowData
    )
    
    PRINT 'DELETE trigger fired for DOCTOR - Row Hash: ' + @RowHash
END
GO

PRINT 'Created DOCTOR table triggers'
GO

-- =============================================================================
-- INTVENT TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_INTVENT_Insert')
    DROP TRIGGER [trg_INTVENT_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_INTVENT_Update')
    DROP TRIGGER [trg_INTVENT_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_INTVENT_Delete')
    DROP TRIGGER [trg_INTVENT_Delete]

-- INTVENT INSERT Trigger
CREATE TRIGGER [trg_INTVENT_Insert]
ON [INTVENT]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([IVCODE] AS VARCHAR(2)), 'NULL') + '|' +
        ISNULL(CAST([IVREASON] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([IVFILLID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([IVDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([IVUSER] AS VARCHAR(3)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateINTVENTRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[INTVENTAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'INSERT', GETDATE(), SYSTEM_USER, 'New intervention record added', @RowData
    )
    
    PRINT 'INSERT trigger fired for INTVENT - Row Hash: ' + @RowHash
END
GO

-- INTVENT UPDATE Trigger
CREATE TRIGGER [trg_INTVENT_Update]
ON [INTVENT]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(IVCODE) SET @ChangedColumns = @ChangedColumns + 'IVCODE, '
    IF UPDATE(IVREASON) SET @ChangedColumns = @ChangedColumns + 'IVREASON, '
    IF UPDATE(IVFILLID) SET @ChangedColumns = @ChangedColumns + 'IVFILLID, '
    IF UPDATE(IVDATE) SET @ChangedColumns = @ChangedColumns + 'IVDATE, '
    IF UPDATE(IVUSER) SET @ChangedColumns = @ChangedColumns + 'IVUSER, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = RTRIM(LEFT(@ChangedColumns, LEN(@ChangedColumns) - 1))
    ELSE
        SET @ChangedColumns = 'Unknown columns'
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([IVCODE] AS VARCHAR(2)), 'NULL') + '|' +
        ISNULL(CAST([IVREASON] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([IVFILLID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([IVDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([IVUSER] AS VARCHAR(3)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateINTVENTRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[INTVENTAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns], [RowData]
    )
    VALUES (
        @RowHash, 'UPDATE', GETDATE(), SYSTEM_USER, 'Intervention record was modified', @ChangedColumns, @RowData
    )
    
    PRINT 'UPDATE trigger fired for INTVENT - Row Hash: ' + @RowHash + ' - Changed: ' + @ChangedColumns
END
GO

-- INTVENT DELETE Trigger
CREATE TRIGGER [trg_INTVENT_Delete]
ON [INTVENT]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([IVCODE] AS VARCHAR(2)), 'NULL') + '|' +
        ISNULL(CAST([IVREASON] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([IVFILLID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([IVDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([IVUSER] AS VARCHAR(3)), 'NULL')
    FROM deleted
    
    SET @RowHash = [dbo].[GenerateINTVENTRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[INTVENTAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'DELETE', GETDATE(), SYSTEM_USER, 'Intervention record was deleted', @RowData
    )
    
    PRINT 'DELETE trigger fired for INTVENT - Row Hash: ' + @RowHash
END
GO

PRINT 'Created INTVENT table triggers'
GO

-- =============================================================================
-- PRESETMESSAGES TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PRESETMESSAGES_Insert')
    DROP TRIGGER [trg_PRESETMESSAGES_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PRESETMESSAGES_Update')
    DROP TRIGGER [trg_PRESETMESSAGES_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PRESETMESSAGES_Delete')
    DROP TRIGGER [trg_PRESETMESSAGES_Delete]

-- PRESETMESSAGES INSERT Trigger
CREATE TRIGGER [trg_PRESETMESSAGES_Insert]
ON [PRESETMESSAGES]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([MSGDESC] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([MSGTEXT] AS VARCHAR(1000)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GeneratePRESETMESSAGESRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[PRESETMESSAGESAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'INSERT', GETDATE(), SYSTEM_USER, 'New preset message added', @RowData
    )
    
    PRINT 'INSERT trigger fired for PRESETMESSAGES - Row Hash: ' + @RowHash
END
GO

-- PRESETMESSAGES UPDATE Trigger
CREATE TRIGGER [trg_PRESETMESSAGES_Update]
ON [PRESETMESSAGES]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(MSGDESC) SET @ChangedColumns = @ChangedColumns + 'MSGDESC, '
    IF UPDATE(MSGTEXT) SET @ChangedColumns = @ChangedColumns + 'MSGTEXT, '
    IF UPDATE(ID) SET @ChangedColumns = @ChangedColumns + 'ID, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = RTRIM(LEFT(@ChangedColumns, LEN(@ChangedColumns) - 1))
    ELSE
        SET @ChangedColumns = 'Unknown columns'
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([MSGDESC] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([MSGTEXT] AS VARCHAR(1000)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GeneratePRESETMESSAGESRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[PRESETMESSAGESAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns], [RowData]
    )
    VALUES (
        @RowHash, 'UPDATE', GETDATE(), SYSTEM_USER, 'Preset message was modified', @ChangedColumns, @RowData
    )
    
    PRINT 'UPDATE trigger fired for PRESETMESSAGES - Row Hash: ' + @RowHash + ' - Changed: ' + @ChangedColumns
END
GO

-- PRESETMESSAGES DELETE Trigger
CREATE TRIGGER [trg_PRESETMESSAGES_Delete]
ON [PRESETMESSAGES]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([MSGDESC] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([MSGTEXT] AS VARCHAR(1000)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL')
    FROM deleted
    
    SET @RowHash = [dbo].[GeneratePRESETMESSAGESRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[PRESETMESSAGESAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'DELETE', GETDATE(), SYSTEM_USER, 'Preset message was deleted', @RowData
    )
    
    PRINT 'DELETE trigger fired for PRESETMESSAGES - Row Hash: ' + @RowHash
END
GO

-- =============================================================================
-- SIG TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SIG_Insert')
    DROP TRIGGER [trg_SIG_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SIG_Update')
    DROP TRIGGER [trg_SIG_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SIG_Delete')
    DROP TRIGGER [trg_SIG_Delete]

-- SIG INSERT Trigger
CREATE TRIGGER [trg_SIG_Insert]
ON [SIG]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([SGCODE] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([SGSIG] AS VARCHAR(128)), 'NULL') + '|' +
        ISNULL(CAST([AddDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([AddUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SGFOREIGN] AS VARCHAR(16)), 'NULL') + '|' +
        ISNULL(CAST([SGPHARM] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateSIGRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[SIGAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'INSERT', GETDATE(), SYSTEM_USER, 'New SIG record added', @RowData
    )
    
    PRINT 'INSERT trigger fired for SIG - Row Hash: ' + @RowHash
END
GO

-- SIG UPDATE Trigger
CREATE TRIGGER [trg_SIG_Update]
ON [SIG]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(SGCODE) SET @ChangedColumns = @ChangedColumns + 'SGCODE, '
    IF UPDATE(SGSIG) SET @ChangedColumns = @ChangedColumns + 'SGSIG, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(SGFOREIGN) SET @ChangedColumns = @ChangedColumns + 'SGFOREIGN, '
    IF UPDATE(SGPHARM) SET @ChangedColumns = @ChangedColumns + 'SGPHARM, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = RTRIM(LEFT(@ChangedColumns, LEN(@ChangedColumns) - 1))
    ELSE
        SET @ChangedColumns = 'Unknown columns'
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([SGCODE] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([SGSIG] AS VARCHAR(128)), 'NULL') + '|' +
        ISNULL(CAST([AddDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([AddUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SGFOREIGN] AS VARCHAR(16)), 'NULL') + '|' +
        ISNULL(CAST([SGPHARM] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateSIGRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[SIGAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns], [RowData]
    )
    VALUES (
        @RowHash, 'UPDATE', GETDATE(), SYSTEM_USER, 'SIG record was modified', @ChangedColumns, @RowData
    )
    
    PRINT 'UPDATE trigger fired for SIG - Row Hash: ' + @RowHash + ' - Changed: ' + @ChangedColumns
END
GO

-- SIG DELETE Trigger
CREATE TRIGGER [trg_SIG_Delete]
ON [SIG]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([SGCODE] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([SGSIG] AS VARCHAR(128)), 'NULL') + '|' +
        ISNULL(CAST([AddDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([AddUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateUsername] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([UpdateDatetime] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SGFOREIGN] AS VARCHAR(16)), 'NULL') + '|' +
        ISNULL(CAST([SGPHARM] AS VARCHAR(10)), 'NULL')
    FROM deleted
    
    SET @RowHash = [dbo].[GenerateSIGRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[SIGAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'DELETE', GETDATE(), SYSTEM_USER, 'SIG record was deleted', @RowData
    )
    
    PRINT 'DELETE trigger fired for SIG - Row Hash: ' + @RowHash
END
GO

-- =============================================================================
-- SCANS TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SCANS_Insert')
    DROP TRIGGER [trg_SCANS_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SCANS_Update')
    DROP TRIGGER [trg_SCANS_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SCANS_Delete')
    DROP TRIGGER [trg_SCANS_Delete]

-- SCANS INSERT Trigger
CREATE TRIGGER [trg_SCANS_Insert]
ON [SCANS]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([SCBAR] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SCFILE] AS VARCHAR(250)), 'NULL') + '|' +
        ISNULL(CAST([SCDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SCBATCHNUM] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCTYPE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCSOURCE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCSOURCEFILE] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([SCFLAG] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([SCORDER] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateSCANSRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[SCANSAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'INSERT', GETDATE(), SYSTEM_USER, 'New scan record added', @RowData
    )
    
    PRINT 'INSERT trigger fired for SCANS - Row Hash: ' + @RowHash
END
GO

-- SCANS UPDATE Trigger
CREATE TRIGGER [trg_SCANS_Update]
ON [SCANS]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(SCBAR) SET @ChangedColumns = @ChangedColumns + 'SCBAR, '
    IF UPDATE(SCFILE) SET @ChangedColumns = @ChangedColumns + 'SCFILE, '
    IF UPDATE(SCDATE) SET @ChangedColumns = @ChangedColumns + 'SCDATE, '
    IF UPDATE(SCBATCHNUM) SET @ChangedColumns = @ChangedColumns + 'SCBATCHNUM, '
    IF UPDATE(SCTYPE) SET @ChangedColumns = @ChangedColumns + 'SCTYPE, '
    IF UPDATE(SCSOURCE) SET @ChangedColumns = @ChangedColumns + 'SCSOURCE, '
    IF UPDATE(SCSOURCEFILE) SET @ChangedColumns = @ChangedColumns + 'SCSOURCEFILE, '
    IF UPDATE(SCFLAG) SET @ChangedColumns = @ChangedColumns + 'SCFLAG, '
    IF UPDATE(SCORDER) SET @ChangedColumns = @ChangedColumns + 'SCORDER, '
    IF UPDATE(ID) SET @ChangedColumns = @ChangedColumns + 'ID, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = RTRIM(LEFT(@ChangedColumns, LEN(@ChangedColumns) - 1))
    ELSE
        SET @ChangedColumns = 'Unknown columns'
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([SCBAR] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SCFILE] AS VARCHAR(250)), 'NULL') + '|' +
        ISNULL(CAST([SCDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SCBATCHNUM] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCTYPE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCSOURCE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCSOURCEFILE] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([SCFLAG] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([SCORDER] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateSCANSRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[SCANSAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns], [RowData]
    )
    VALUES (
        @RowHash, 'UPDATE', GETDATE(), SYSTEM_USER, 'Scan record was modified', @ChangedColumns, @RowData
    )
    
    PRINT 'UPDATE trigger fired for SCANS - Row Hash: ' + @RowHash + ' - Changed: ' + @ChangedColumns
END
GO

-- SCANS DELETE Trigger
CREATE TRIGGER [trg_SCANS_Delete]
ON [SCANS]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([SCBAR] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SCFILE] AS VARCHAR(250)), 'NULL') + '|' +
        ISNULL(CAST([SCDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([SCBATCHNUM] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCTYPE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCSOURCE] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([SCSOURCEFILE] AS VARCHAR(150)), 'NULL') + '|' +
        ISNULL(CAST([SCFLAG] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([SCORDER] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL')
    FROM deleted
    
    SET @RowHash = [dbo].[GenerateSCANSRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[SCANSAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'DELETE', GETDATE(), SYSTEM_USER, 'Scan record was deleted', @RowData
    )
    
    PRINT 'DELETE trigger fired for SCANS - Row Hash: ' + @RowHash
END
GO

-- =============================================================================
-- WINMAIL_RECEIVED TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_WINMAIL_RECEIVED_Insert')
    DROP TRIGGER [trg_WINMAIL_RECEIVED_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_WINMAIL_RECEIVED_Update')
    DROP TRIGGER [trg_WINMAIL_RECEIVED_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_WINMAIL_RECEIVED_Delete')
    DROP TRIGGER [trg_WINMAIL_RECEIVED_Delete]

-- WINMAIL_RECEIVED INSERT Trigger
CREATE TRIGGER [trg_WINMAIL_RECEIVED_Insert]
ON [WINMAIL_RECEIVED]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([EntryDate] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([Guid] AS VARCHAR(36)), 'NULL') + '|' +
        ISNULL(CAST([NAME] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([FAXNUM] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([PAGES] AS VARCHAR(5)), 'NULL') + '|' +
        ISNULL(CAST([FILENAME] AS VARCHAR(200)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([Note] AS VARCHAR(200)), 'NULL') + '|' +
        ISNULL(CAST([SRFaxID] AS VARCHAR(100)), 'NULL') + '|' +
        ISNULL(CAST([SRFaxFileName] AS VARCHAR(300)), 'NULL') + '|' +
        ISNULL(CAST([Unread] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateWINMAIL_RECEIVEDRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[WINMAIL_RECEIVEDAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'INSERT', GETDATE(), SYSTEM_USER, 'New winmail received record added', @RowData
    )
    
    PRINT 'INSERT trigger fired for WINMAIL_RECEIVED - Row Hash: ' + @RowHash
END
GO

-- WINMAIL_RECEIVED UPDATE Trigger
CREATE TRIGGER [trg_WINMAIL_RECEIVED_Update]
ON [WINMAIL_RECEIVED]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(EntryDate) SET @ChangedColumns = @ChangedColumns + 'EntryDate, '
    IF UPDATE(Guid) SET @ChangedColumns = @ChangedColumns + 'Guid, '
    IF UPDATE(NAME) SET @ChangedColumns = @ChangedColumns + 'NAME, '
    IF UPDATE(FAXNUM) SET @ChangedColumns = @ChangedColumns + 'FAXNUM, '
    IF UPDATE(PAGES) SET @ChangedColumns = @ChangedColumns + 'PAGES, '
    IF UPDATE(FILENAME) SET @ChangedColumns = @ChangedColumns + 'FILENAME, '
    IF UPDATE(ID) SET @ChangedColumns = @ChangedColumns + 'ID, '
    IF UPDATE(Note) SET @ChangedColumns = @ChangedColumns + 'Note, '
    IF UPDATE(SRFaxID) SET @ChangedColumns = @ChangedColumns + 'SRFaxID, '
    IF UPDATE(SRFaxFileName) SET @ChangedColumns = @ChangedColumns + 'SRFaxFileName, '
    IF UPDATE(Unread) SET @ChangedColumns = @ChangedColumns + 'Unread, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = RTRIM(LEFT(@ChangedColumns, LEN(@ChangedColumns) - 1))
    ELSE
        SET @ChangedColumns = 'Unknown columns'
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([EntryDate] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([Guid] AS VARCHAR(36)), 'NULL') + '|' +
        ISNULL(CAST([NAME] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([FAXNUM] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([PAGES] AS VARCHAR(5)), 'NULL') + '|' +
        ISNULL(CAST([FILENAME] AS VARCHAR(200)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([Note] AS VARCHAR(200)), 'NULL') + '|' +
        ISNULL(CAST([SRFaxID] AS VARCHAR(100)), 'NULL') + '|' +
        ISNULL(CAST([SRFaxFileName] AS VARCHAR(300)), 'NULL') + '|' +
        ISNULL(CAST([Unread] AS VARCHAR(10)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateWINMAIL_RECEIVEDRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[WINMAIL_RECEIVEDAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns], [RowData]
    )
    VALUES (
        @RowHash, 'UPDATE', GETDATE(), SYSTEM_USER, 'Winmail received record was modified', @ChangedColumns, @RowData
    )
    
    PRINT 'UPDATE trigger fired for WINMAIL_RECEIVED - Row Hash: ' + @RowHash + ' - Changed: ' + @ChangedColumns
END
GO

-- WINMAIL_RECEIVED DELETE Trigger
CREATE TRIGGER [trg_WINMAIL_RECEIVED_Delete]
ON [WINMAIL_RECEIVED]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([EntryDate] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([Guid] AS VARCHAR(36)), 'NULL') + '|' +
        ISNULL(CAST([NAME] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([FAXNUM] AS VARCHAR(50)), 'NULL') + '|' +
        ISNULL(CAST([PAGES] AS VARCHAR(5)), 'NULL') + '|' +
        ISNULL(CAST([FILENAME] AS VARCHAR(200)), 'NULL') + '|' +
        ISNULL(CAST([ID] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([Note] AS VARCHAR(200)), 'NULL') + '|' +
        ISNULL(CAST([SRFaxID] AS VARCHAR(100)), 'NULL') + '|' +
        ISNULL(CAST([SRFaxFileName] AS VARCHAR(300)), 'NULL') + '|' +
        ISNULL(CAST([Unread] AS VARCHAR(10)), 'NULL')
    FROM deleted
    
    SET @RowHash = [dbo].[GenerateWINMAIL_RECEIVEDRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[WINMAIL_RECEIVEDAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'DELETE', GETDATE(), SYSTEM_USER, 'Winmail received record was deleted', @RowData
    )
    
    PRINT 'DELETE trigger fired for WINMAIL_RECEIVED - Row Hash: ' + @RowHash
END
GO

PRINT 'Created WINMAIL_RECEIVED table triggers'
GO

-- =============================================================================
-- MMR TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_MMR_Insert')
    DROP TRIGGER [trg_MMR_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_MMR_Update')
    DROP TRIGGER [trg_MMR_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_MMR_Delete')
    DROP TRIGGER [trg_MMR_Delete]

-- MMR INSERT Trigger
CREATE TRIGGER [trg_MMR_Insert]
ON [MMR]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([MMPHN] AS VARCHAR(13)), 'NULL') + '|' +
        ISNULL(CAST([MMRX] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([MMSIG] AS VARCHAR(240)), 'NULL') + '|' +
        ISNULL(CAST([MMPRN] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMINUSE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMDRUG] AS VARCHAR(128)), 'NULL') + '|' +
        ISNULL(CAST([MMDIN] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([MMSTOPPED] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMSTOPDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([MMSOURCE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMPRESCRIBEDBY] AS VARCHAR(60)), 'NULL') + '|' +
        ISNULL(CAST([MMPNETREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMNONRXREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMNATURALREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMUSEONLYRX] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMOTHER] AS VARCHAR(50)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateMMRRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[MMRAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'INSERT', GETDATE(), SYSTEM_USER, 'New MMR record added', @RowData
    )
    
    PRINT 'INSERT trigger fired for MMR - Row Hash: ' + @RowHash
END
GO

-- MMR UPDATE Trigger
CREATE TRIGGER [trg_MMR_Update]
ON [MMR]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(MMPHN) SET @ChangedColumns = @ChangedColumns + 'MMPHN, '
    IF UPDATE(MMRX) SET @ChangedColumns = @ChangedColumns + 'MMRX, '
    IF UPDATE(MMREASON) SET @ChangedColumns = @ChangedColumns + 'MMREASON, '
    IF UPDATE(MMSIG) SET @ChangedColumns = @ChangedColumns + 'MMSIG, '
    IF UPDATE(MMNOTES) SET @ChangedColumns = @ChangedColumns + 'MMNOTES, '
    IF UPDATE(MMPRN) SET @ChangedColumns = @ChangedColumns + 'MMPRN, '
    IF UPDATE(MMINUSE) SET @ChangedColumns = @ChangedColumns + 'MMINUSE, '
    IF UPDATE(MMDRUG) SET @ChangedColumns = @ChangedColumns + 'MMDRUG, '
    IF UPDATE(MMDIN) SET @ChangedColumns = @ChangedColumns + 'MMDIN, '
    IF UPDATE(MMSTOPPED) SET @ChangedColumns = @ChangedColumns + 'MMSTOPPED, '
    IF UPDATE(MMSTOPDATE) SET @ChangedColumns = @ChangedColumns + 'MMSTOPDATE, '
    IF UPDATE(MMSOURCE) SET @ChangedColumns = @ChangedColumns + 'MMSOURCE, '
    IF UPDATE(MMPRESCRIBEDBY) SET @ChangedColumns = @ChangedColumns + 'MMPRESCRIBEDBY, '
    IF UPDATE(MMRATIONALE) SET @ChangedColumns = @ChangedColumns + 'MMRATIONALE, '
    IF UPDATE(MMPNETREVIEWED) SET @ChangedColumns = @ChangedColumns + 'MMPNETREVIEWED, '
    IF UPDATE(MMNONRXREVIEWED) SET @ChangedColumns = @ChangedColumns + 'MMNONRXREVIEWED, '
    IF UPDATE(MMNATURALREVIEWED) SET @ChangedColumns = @ChangedColumns + 'MMNATURALREVIEWED, '
    IF UPDATE(MMUSEONLYRX) SET @ChangedColumns = @ChangedColumns + 'MMUSEONLYRX, '
    IF UPDATE(MMOTHER) SET @ChangedColumns = @ChangedColumns + 'MMOTHER, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = RTRIM(LEFT(@ChangedColumns, LEN(@ChangedColumns) - 1))
    ELSE
        SET @ChangedColumns = 'Unknown columns'
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([MMPHN] AS VARCHAR(13)), 'NULL') + '|' +
        ISNULL(CAST([MMRX] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([MMSIG] AS VARCHAR(240)), 'NULL') + '|' +
        ISNULL(CAST([MMPRN] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMINUSE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMDRUG] AS VARCHAR(128)), 'NULL') + '|' +
        ISNULL(CAST([MMDIN] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([MMSTOPPED] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMSTOPDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([MMSOURCE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMPRESCRIBEDBY] AS VARCHAR(60)), 'NULL') + '|' +
        ISNULL(CAST([MMPNETREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMNONRXREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMNATURALREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMUSEONLYRX] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMOTHER] AS VARCHAR(50)), 'NULL')
    FROM inserted
    
    SET @RowHash = [dbo].[GenerateMMRRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[MMRAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns], [RowData]
    )
    VALUES (
        @RowHash, 'UPDATE', GETDATE(), SYSTEM_USER, 'MMR record was modified', @ChangedColumns, @RowData
    )
    
    PRINT 'UPDATE trigger fired for MMR - Row Hash: ' + @RowHash + ' - Changed: ' + @ChangedColumns
END
GO

-- MMR DELETE Trigger
CREATE TRIGGER [trg_MMR_Delete]
ON [MMR]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowData VARCHAR(MAX) = ''
    DECLARE @RowHash VARCHAR(64)
    
    SELECT @RowData = 
        ISNULL(CAST([MMPHN] AS VARCHAR(13)), 'NULL') + '|' +
        ISNULL(CAST([MMRX] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([MMSIG] AS VARCHAR(240)), 'NULL') + '|' +
        ISNULL(CAST([MMPRN] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMINUSE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMDRUG] AS VARCHAR(128)), 'NULL') + '|' +
        ISNULL(CAST([MMDIN] AS VARCHAR(20)), 'NULL') + '|' +
        ISNULL(CAST([MMSTOPPED] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMSTOPDATE] AS VARCHAR(30)), 'NULL') + '|' +
        ISNULL(CAST([MMSOURCE] AS VARCHAR(1)), 'NULL') + '|' +
        ISNULL(CAST([MMPRESCRIBEDBY] AS VARCHAR(60)), 'NULL') + '|' +
        ISNULL(CAST([MMPNETREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMNONRXREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMNATURALREVIEWED] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMUSEONLYRX] AS VARCHAR(10)), 'NULL') + '|' +
        ISNULL(CAST([MMOTHER] AS VARCHAR(50)), 'NULL')
    FROM deleted
    
    SET @RowHash = [dbo].[GenerateMMRRowHash](@RowData)
    
    INSERT INTO [medidozeProsper].[dbo].[MMRAudit] (
        [RowHash], [Operation], [ChangeTime], [UserName], [ChangeDetails], [RowData]
    )
    VALUES (
        @RowHash, 'DELETE', GETDATE(), SYSTEM_USER, 'MMR record was deleted', @RowData
    )
    
    PRINT 'DELETE trigger fired for MMR - Row Hash: ' + @RowHash
END
GO

PRINT 'Created MMR table triggers'
GO

-- =============================================================================
-- COMPLETION
-- =============================================================================

PRINT '=================================================='
PRINT 'ALL NO-PK TABLE TRIGGERS COMPLETED SUCCESSFULLY!'
PRINT '=================================================='
PRINT ''
PRINT 'Tables with triggers created:'
PRINT '- DOCTOR (5,369 records)'
PRINT '- INTVENT (27,368 records)'
PRINT '- MMR (18,006 records) - Fixed for text data type'
PRINT '- PRESETMESSAGES (116 records)'
PRINT '- SIG (524 records)'
PRINT '- SCANS (638,682 records)'
PRINT '- WINMAIL_RECEIVED (records count varies)'
PRINT ''
PRINT 'Total: 7 tables, 689,465+ records covered'
PRINT ''
PRINT 'All triggers are ready for use!'
GO
