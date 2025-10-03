-- =============================================================================
-- COMPLETE PK TABLES TRIGGER SOLUTION
-- =============================================================================
-- This script creates triggers for tables WITH primary keys:
-- Appointment, CALLBACK, CHANGES, CHGDRUG, Communications, DOCUMENTS, 
-- DRUG, ERX, PACMED, PATIENT, REFILL, RX, TXNS
-- =============================================================================

USE [winrxProsper]
GO

-- =============================================================================
-- STEP 1: CREATE AUDIT TABLES FOR EACH PK TABLE
-- =============================================================================

-- Appointment Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppointmentAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[AppointmentAudit]

CREATE TABLE [dbo].[AppointmentAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [AppID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_AppointmentAudit] PRIMARY KEY ([AuditID])
)

-- CALLBACK Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CALLBACKAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[CALLBACKAudit]

CREATE TABLE [dbo].[CALLBACKAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [CBID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_CALLBACKAudit] PRIMARY KEY ([AuditID])
)

-- CHANGES Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHANGESAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[CHANGESAudit]

CREATE TABLE [dbo].[CHANGESAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [CGID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_CHANGESAudit] PRIMARY KEY ([AuditID])
)

-- CHGDRUG Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHGDRUGAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[CHGDRUGAudit]

CREATE TABLE [dbo].[CHGDRUGAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [CHGDGID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_CHGDRUGAudit] PRIMARY KEY ([AuditID])
)

-- Communications Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CommunicationsAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[CommunicationsAudit]

CREATE TABLE [dbo].[CommunicationsAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [ID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_CommunicationsAudit] PRIMARY KEY ([AuditID])
)

-- DOCUMENTS Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DOCUMENTSAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[DOCUMENTSAudit]

CREATE TABLE [dbo].[DOCUMENTSAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [ID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_DOCUMENTSAudit] PRIMARY KEY ([AuditID])
)

-- DRUG Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DRUGAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[DRUGAudit]

CREATE TABLE [dbo].[DRUGAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [DGDIN] [float] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_DRUGAudit] PRIMARY KEY ([AuditID])
)

-- ERX Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ERXAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[ERXAudit]

CREATE TABLE [dbo].[ERXAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [XKEY] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_ERXAudit] PRIMARY KEY ([AuditID])
)

-- PACMED Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PACMEDAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[PACMEDAudit]

CREATE TABLE [dbo].[PACMEDAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [Id] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_PACMEDAudit] PRIMARY KEY ([AuditID])
)

-- PATIENT Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENTAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[PATIENTAudit]

CREATE TABLE [dbo].[PATIENTAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [PANUM] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_PATIENTAudit] PRIMARY KEY ([AuditID])
)

-- REFILL Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[REFILLAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[REFILLAudit]

CREATE TABLE [dbo].[REFILLAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [REFILLID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_REFILLAudit] PRIMARY KEY ([AuditID])
)

-- RX Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RXAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[RXAudit]

CREATE TABLE [dbo].[RXAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [RXNUM] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_RXAudit] PRIMARY KEY ([AuditID])
)

-- TXNS Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TXNSAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[TXNSAudit]

CREATE TABLE [dbo].[TXNSAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [TXNSID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_TXNSAudit] PRIMARY KEY ([AuditID])
)

-- SCHEDULE Audit Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SCHEDULEAudit]') AND type in (N'U'))
    DROP TABLE [dbo].[SCHEDULEAudit]

CREATE TABLE [dbo].[SCHEDULEAudit] (
    [AuditID] [int] IDENTITY(1,1) NOT NULL,
    [SCID] [int] NULL,
    [Operation] [varchar](10) NOT NULL,
    [ChangeTime] [datetime] NOT NULL,
    [UserName] [varchar](100) NULL,
    [ChangeDetails] [varchar](500) NULL,
    [ChangedColumns] [varchar](500) NULL,
    CONSTRAINT [PK_SCHEDULEAudit] PRIMARY KEY ([AuditID])
)

PRINT 'Created audit tables for all PK tables (including SCHEDULE)'
GO


-- =============================================================================
-- APPOINTMENT TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Appointment_Insert')
    DROP TRIGGER [trg_Appointment_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Appointment_Update')
    DROP TRIGGER [trg_Appointment_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Appointment_Delete')
    DROP TRIGGER [trg_Appointment_Delete]

-- APPOINTMENT INSERT Trigger
CREATE TRIGGER [trg_Appointment_Insert]
ON [Appointment]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[AppointmentAudit] (
        [AppID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.AppID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New appointment record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for Appointment'
END
GO

-- APPOINTMENT UPDATE Trigger
CREATE TRIGGER [trg_Appointment_Update]
ON [Appointment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(AppDateTime) SET @ChangedColumns = @ChangedColumns + 'AppDateTime, '
    IF UPDATE(Pharmacist) SET @ChangedColumns = @ChangedColumns + 'Pharmacist, '
    IF UPDATE(AddUser) SET @ChangedColumns = @ChangedColumns + 'AddUser, '
    IF UPDATE(CustomerPHN) SET @ChangedColumns = @ChangedColumns + 'CustomerPHN, '
    IF UPDATE(CustomerName) SET @ChangedColumns = @ChangedColumns + 'CustomerName, '
    IF UPDATE(CustomerAddress) SET @ChangedColumns = @ChangedColumns + 'CustomerAddress, '
    IF UPDATE(CustomerPhone) SET @ChangedColumns = @ChangedColumns + 'CustomerPhone, '
    IF UPDATE(AppNote) SET @ChangedColumns = @ChangedColumns + 'AppNote, '
    IF UPDATE(AppCreatedDateTime) SET @ChangedColumns = @ChangedColumns + 'AppCreatedDateTime, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[AppointmentAudit] (
        [AppID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.AppID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Appointment was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for Appointment - Changed: ' + @ChangedColumns
END
GO

-- APPOINTMENT DELETE Trigger
CREATE TRIGGER [trg_Appointment_Delete]
ON [Appointment]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[AppointmentAudit] (
        [AppID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.AppID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Appointment was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for Appointment'
END
GO

-- =============================================================================
-- CALLBACK TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CALLBACK_Insert')
    DROP TRIGGER [trg_CALLBACK_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CALLBACK_Update')
    DROP TRIGGER [trg_CALLBACK_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CALLBACK_Delete')
    DROP TRIGGER [trg_CALLBACK_Delete]

-- CALLBACK INSERT Trigger
CREATE TRIGGER [trg_CALLBACK_Insert]
ON [CALLBACK]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CALLBACKAudit] (
        [CBID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.CBID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New callback record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for CALLBACK'
END
GO

-- CALLBACK UPDATE Trigger
CREATE TRIGGER [trg_CALLBACK_Update]
ON [CALLBACK]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(CBDATE) SET @ChangedColumns = @ChangedColumns + 'CBDATE, '
    IF UPDATE(CBSURNAME) SET @ChangedColumns = @ChangedColumns + 'CBSURNAME, '
    IF UPDATE(CBGIVEN) SET @ChangedColumns = @ChangedColumns + 'CBGIVEN, '
    IF UPDATE(CBDRUG) SET @ChangedColumns = @ChangedColumns + 'CBDRUG, '
    IF UPDATE(CBNOTE) SET @ChangedColumns = @ChangedColumns + 'CBNOTE, '
    IF UPDATE(CBPHONE) SET @ChangedColumns = @ChangedColumns + 'CBPHONE, '
    IF UPDATE(CBRXNUM) SET @ChangedColumns = @ChangedColumns + 'CBRXNUM, '
    IF UPDATE(CBPREV) SET @ChangedColumns = @ChangedColumns + 'CBPREV, '
    IF UPDATE(CBUSER) SET @ChangedColumns = @ChangedColumns + 'CBUSER, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(CBCOMID) SET @ChangedColumns = @ChangedColumns + 'CBCOMID, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[CALLBACKAudit] (
        [CBID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.CBID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Callback was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for CALLBACK - Changed: ' + @ChangedColumns
END
GO

-- CALLBACK DELETE Trigger
CREATE TRIGGER [trg_CALLBACK_Delete]
ON [CALLBACK]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CALLBACKAudit] (
        [CBID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.CBID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Callback was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for CALLBACK'
END
GO

-- =============================================================================
-- CHANGES TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CHANGES_Insert')
    DROP TRIGGER [trg_CHANGES_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CHANGES_Update')
    DROP TRIGGER [trg_CHANGES_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CHANGES_Delete')
    DROP TRIGGER [trg_CHANGES_Delete]

-- CHANGES INSERT Trigger
CREATE TRIGGER [trg_CHANGES_Insert]
ON [CHANGES]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CHANGESAudit] (
        [CGID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.CGID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New changes record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for CHANGES'
END
GO

-- CHANGES UPDATE Trigger
CREATE TRIGGER [trg_CHANGES_Update]
ON [CHANGES]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(CGNUM) SET @ChangedColumns = @ChangedColumns + 'CGNUM, '
    IF UPDATE(CGLIM) SET @ChangedColumns = @ChangedColumns + 'CGLIM, '
    IF UPDATE(CGQTY) SET @ChangedColumns = @ChangedColumns + 'CGQTY, '
    IF UPDATE(CGBR) SET @ChangedColumns = @ChangedColumns + 'CGBR, '
    IF UPDATE(CGDEA) SET @ChangedColumns = @ChangedColumns + 'CGDEA, '
    IF UPDATE(CGDRLAST) SET @ChangedColumns = @ChangedColumns + 'CGDRLAST, '
    IF UPDATE(CGDR1ST) SET @ChangedColumns = @ChangedColumns + 'CGDR1ST, '
    IF UPDATE(CGDATE) SET @ChangedColumns = @ChangedColumns + 'CGDATE, '
    IF UPDATE(CGUSER) SET @ChangedColumns = @ChangedColumns + 'CGUSER, '
    IF UPDATE(CGSIG) SET @ChangedColumns = @ChangedColumns + 'CGSIG, '
    IF UPDATE(CGMSG) SET @ChangedColumns = @ChangedColumns + 'CGMSG, '
    IF UPDATE(CGDRCOLL) SET @ChangedColumns = @ChangedColumns + 'CGDRCOLL, '
    IF UPDATE(CGACT) SET @ChangedColumns = @ChangedColumns + 'CGACT, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(CGDRUG) SET @ChangedColumns = @ChangedColumns + 'CGDRUG, '
    IF UPDATE(CGDIN) SET @ChangedColumns = @ChangedColumns + 'CGDIN, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[CHANGESAudit] (
        [CGID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.CGID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Changes record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for CHANGES - Changed: ' + @ChangedColumns
END
GO

-- CHANGES DELETE Trigger
CREATE TRIGGER [trg_CHANGES_Delete]
ON [CHANGES]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CHANGESAudit] (
        [CGID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.CGID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Changes record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for CHANGES'
END
GO

PRINT 'Created triggers for Appointment, CALLBACK, and CHANGES tables'
GO


-- =============================================================================
-- CHGDRUG TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CHGDRUG_Insert')
    DROP TRIGGER [trg_CHGDRUG_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CHGDRUG_Update')
    DROP TRIGGER [trg_CHGDRUG_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CHGDRUG_Delete')
    DROP TRIGGER [trg_CHGDRUG_Delete]

-- CHGDRUG INSERT Trigger
CREATE TRIGGER [trg_CHGDRUG_Insert]
ON [CHGDRUG]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CHGDRUGAudit] (
        [CHGDGID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.CHGDGID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New CHGDRUG record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for CHGDRUG'
END
GO

-- CHGDRUG UPDATE Trigger
CREATE TRIGGER [trg_CHGDRUG_Update]
ON [CHGDRUG]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(DGDIN) SET @ChangedColumns = @ChangedColumns + 'DGDIN, '
    IF UPDATE(DGDESC) SET @ChangedColumns = @ChangedColumns + 'DGDESC, '
    IF UPDATE(DGDATE) SET @ChangedColumns = @ChangedColumns + 'DGDATE, '
    IF UPDATE(DGUSER) SET @ChangedColumns = @ChangedColumns + 'DGUSER, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(ORDERSTATUS) SET @ChangedColumns = @ChangedColumns + 'ORDERSTATUS, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[CHGDRUGAudit] (
        [CHGDGID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.CHGDGID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'CHGDRUG record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for CHGDRUG - Changed: ' + @ChangedColumns
END
GO

-- CHGDRUG DELETE Trigger
CREATE TRIGGER [trg_CHGDRUG_Delete]
ON [CHGDRUG]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CHGDRUGAudit] (
        [CHGDGID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.CHGDGID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'CHGDRUG record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for CHGDRUG'
END
GO

-- =============================================================================
-- COMMUNICATIONS TABLE TRIGGERS (FIXED FOR TEXT DATA TYPE)
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Communications_Insert')
    DROP TRIGGER [trg_Communications_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Communications_Update')
    DROP TRIGGER [trg_Communications_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Communications_Delete')
    DROP TRIGGER [trg_Communications_Delete]

-- COMMUNICATIONS INSERT Trigger (Fixed for text data type)
CREATE TRIGGER [trg_Communications_Insert]
ON [Communications]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CommunicationsAudit] (
        [ID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.ID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New communications record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for Communications'
END
GO

-- COMMUNICATIONS UPDATE Trigger (Fixed for text data type)
CREATE TRIGGER [trg_Communications_Update]
ON [Communications]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(PHN) SET @ChangedColumns = @ChangedColumns + 'PHN, '
    IF UPDATE(Type) SET @ChangedColumns = @ChangedColumns + 'Type, '
    IF UPDATE(EventDateTime) SET @ChangedColumns = @ChangedColumns + 'EventDateTime, '
    IF UPDATE(Reference) SET @ChangedColumns = @ChangedColumns + 'Reference, '
    IF UPDATE(Resource) SET @ChangedColumns = @ChangedColumns + 'Resource, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[CommunicationsAudit] (
        [ID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.ID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Communications record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for Communications - Changed: ' + @ChangedColumns
END
GO

-- COMMUNICATIONS DELETE Trigger
CREATE TRIGGER [trg_Communications_Delete]
ON [Communications]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[CommunicationsAudit] (
        [ID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.ID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Communications record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for Communications'
END
GO

-- =============================================================================
-- DOCUMENTS TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DOCUMENTS_Insert')
    DROP TRIGGER [trg_DOCUMENTS_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DOCUMENTS_Update')
    DROP TRIGGER [trg_DOCUMENTS_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DOCUMENTS_Delete')
    DROP TRIGGER [trg_DOCUMENTS_Delete]

-- DOCUMENTS INSERT Trigger
CREATE TRIGGER [trg_DOCUMENTS_Insert]
ON [DOCUMENTS]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[DOCUMENTSAudit] (
        [ID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.ID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New documents record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for DOCUMENTS'
END
GO

-- DOCUMENTS UPDATE Trigger
CREATE TRIGGER [trg_DOCUMENTS_Update]
ON [DOCUMENTS]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(DTNUM) SET @ChangedColumns = @ChangedColumns + 'DTNUM, '
    IF UPDATE(DTDATE) SET @ChangedColumns = @ChangedColumns + 'DTDATE, '
    IF UPDATE(DTTYPE) SET @ChangedColumns = @ChangedColumns + 'DTTYPE, '
    IF UPDATE(DTNAME) SET @ChangedColumns = @ChangedColumns + 'DTNAME, '
    IF UPDATE(DTBATCHNUM) SET @ChangedColumns = @ChangedColumns + 'DTBATCHNUM, '
    IF UPDATE(DTSOURCE) SET @ChangedColumns = @ChangedColumns + 'DTSOURCE, '
    IF UPDATE(DTSOURCEFILE) SET @ChangedColumns = @ChangedColumns + 'DTSOURCEFILE, '
    IF UPDATE(DTFLAG) SET @ChangedColumns = @ChangedColumns + 'DTFLAG, '
    IF UPDATE(DTAILMENT) SET @ChangedColumns = @ChangedColumns + 'DTAILMENT, '
    IF UPDATE(DTNOTE) SET @ChangedColumns = @ChangedColumns + 'DTNOTE, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[DOCUMENTSAudit] (
        [ID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.ID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Documents record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for DOCUMENTS - Changed: ' + @ChangedColumns
END
GO

-- DOCUMENTS DELETE Trigger
CREATE TRIGGER [trg_DOCUMENTS_Delete]
ON [DOCUMENTS]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[DOCUMENTSAudit] (
        [ID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.ID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Documents record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for DOCUMENTS'
END
GO

-- =============================================================================
-- DRUG TABLE TRIGGERS (FIXED FOR TEXT DATA TYPE)
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DRUG_Insert')
    DROP TRIGGER [trg_DRUG_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DRUG_Update')
    DROP TRIGGER [trg_DRUG_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DRUG_Delete')
    DROP TRIGGER [trg_DRUG_Delete]

-- DRUG INSERT Trigger (Fixed for text data type)
CREATE TRIGGER [trg_DRUG_Insert]
ON [DRUG]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[DRUGAudit] (
        [DGDIN], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.DGDIN,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New drug record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for DRUG'
END
GO

-- DRUG UPDATE Trigger (Fixed for text data type)
CREATE TRIGGER [trg_DRUG_Update]
ON [DRUG]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(DGDESC) SET @ChangedColumns = @ChangedColumns + 'DGDESC, '
    IF UPDATE(DGUM) SET @ChangedColumns = @ChangedColumns + 'DGUM, '
    IF UPDATE(DGTYPE) SET @ChangedColumns = @ChangedColumns + 'DGTYPE, '
    IF UPDATE(DGQ1) SET @ChangedColumns = @ChangedColumns + 'DGQ1, '
    IF UPDATE(DGQ2) SET @ChangedColumns = @ChangedColumns + 'DGQ2, '
    IF UPDATE(DGQ3) SET @ChangedColumns = @ChangedColumns + 'DGQ3, '
    IF UPDATE(DGC1) SET @ChangedColumns = @ChangedColumns + 'DGC1, '
    IF UPDATE(DGC2) SET @ChangedColumns = @ChangedColumns + 'DGC2, '
    IF UPDATE(DGC3) SET @ChangedColumns = @ChangedColumns + 'DGC3, '
    IF UPDATE(DGSHELF) SET @ChangedColumns = @ChangedColumns + 'DGSHELF, '
    IF UPDATE(DGINVNO) SET @ChangedColumns = @ChangedColumns + 'DGINVNO, '
    IF UPDATE(DGGEN1) SET @ChangedColumns = @ChangedColumns + 'DGGEN1, '
    IF UPDATE(DGGEN2) SET @ChangedColumns = @ChangedColumns + 'DGGEN2, '
    IF UPDATE(DGDATE) SET @ChangedColumns = @ChangedColumns + 'DGDATE, '
    IF UPDATE(DGHAS1) SET @ChangedColumns = @ChangedColumns + 'DGHAS1, '
    IF UPDATE(DGHAS2) SET @ChangedColumns = @ChangedColumns + 'DGHAS2, '
    IF UPDATE(DGHAS3) SET @ChangedColumns = @ChangedColumns + 'DGHAS3, '
    IF UPDATE(DGSUPPLIER) SET @ChangedColumns = @ChangedColumns + 'DGSUPPLIER, '
    IF UPDATE(DGLINE1) SET @ChangedColumns = @ChangedColumns + 'DGLINE1, '
    IF UPDATE(DGLINE2) SET @ChangedColumns = @ChangedColumns + 'DGLINE2, '
    IF UPDATE(DGLINE3) SET @ChangedColumns = @ChangedColumns + 'DGLINE3, '
    IF UPDATE(DGORDER1) SET @ChangedColumns = @ChangedColumns + 'DGORDER1, '
    IF UPDATE(DGORDER2) SET @ChangedColumns = @ChangedColumns + 'DGORDER2, '
    IF UPDATE(DGORDER3) SET @ChangedColumns = @ChangedColumns + 'DGORDER3, '
    IF UPDATE(DGMKUP) SET @ChangedColumns = @ChangedColumns + 'DGMKUP, '
    IF UPDATE(DGINVNO2) SET @ChangedColumns = @ChangedColumns + 'DGINVNO2, '
    IF UPDATE(DGINVNO3) SET @ChangedColumns = @ChangedColumns + 'DGINVNO3, '
    IF UPDATE(DGTRADE) SET @ChangedColumns = @ChangedColumns + 'DGTRADE, '
    IF UPDATE(DGSIG) SET @ChangedColumns = @ChangedColumns + 'DGSIG, '
    IF UPDATE(DGEXPIRE) SET @ChangedColumns = @ChangedColumns + 'DGEXPIRE, '
    IF UPDATE(DG2OLD) SET @ChangedColumns = @ChangedColumns + 'DG2OLD, '
    IF UPDATE(DGWARN) SET @ChangedColumns = @ChangedColumns + 'DGWARN, '
    IF UPDATE(DGU1) SET @ChangedColumns = @ChangedColumns + 'DGU1, '
    IF UPDATE(DGU2) SET @ChangedColumns = @ChangedColumns + 'DGU2, '
    IF UPDATE(DGU3) SET @ChangedColumns = @ChangedColumns + 'DGU3, '
    IF UPDATE(DGU4) SET @ChangedColumns = @ChangedColumns + 'DGU4, '
    IF UPDATE(DGU5) SET @ChangedColumns = @ChangedColumns + 'DGU5, '
    IF UPDATE(DGU6) SET @ChangedColumns = @ChangedColumns + 'DGU6, '
    IF UPDATE(DGU7) SET @ChangedColumns = @ChangedColumns + 'DGU7, '
    IF UPDATE(DGU8) SET @ChangedColumns = @ChangedColumns + 'DGU8, '
    IF UPDATE(DGU9) SET @ChangedColumns = @ChangedColumns + 'DGU9, '
    IF UPDATE(DGU10) SET @ChangedColumns = @ChangedColumns + 'DGU10, '
    IF UPDATE(DGU11) SET @ChangedColumns = @ChangedColumns + 'DGU11, '
    IF UPDATE(DGU12) SET @ChangedColumns = @ChangedColumns + 'DGU12, '
    IF UPDATE(DGUMON) SET @ChangedColumns = @ChangedColumns + 'DGUMON, '
    IF UPDATE(DGPACK) SET @ChangedColumns = @ChangedColumns + 'DGPACK, '
    IF UPDATE(DGSIGCODE) SET @ChangedColumns = @ChangedColumns + 'DGSIGCODE, '
    IF UPDATE(DGCOUNSEL) SET @ChangedColumns = @ChangedColumns + 'DGCOUNSEL, '
    IF UPDATE(DGMSP) SET @ChangedColumns = @ChangedColumns + 'DGMSP, '
    IF UPDATE(DGDAYRATE) SET @ChangedColumns = @ChangedColumns + 'DGDAYRATE, '
    IF UPDATE(DGWKRATE) SET @ChangedColumns = @ChangedColumns + 'DGWKRATE, '
    IF UPDATE(DGMONRATE) SET @ChangedColumns = @ChangedColumns + 'DGMONRATE, '
    IF UPDATE(DGPST) SET @ChangedColumns = @ChangedColumns + 'DGPST, '
    IF UPDATE(DGGST) SET @ChangedColumns = @ChangedColumns + 'DGGST, '
    IF UPDATE(DGGRACE) SET @ChangedColumns = @ChangedColumns + 'DGGRACE, '
    IF UPDATE(DGLCADIN) SET @ChangedColumns = @ChangedColumns + 'DGLCADIN, '
    IF UPDATE(DGLCACOST) SET @ChangedColumns = @ChangedColumns + 'DGLCACOST, '
    IF UPDATE(DGPACMED) SET @ChangedColumns = @ChangedColumns + 'DGPACMED, '
    IF UPDATE(DGPRICE) SET @ChangedColumns = @ChangedColumns + 'DGPRICE, '
    IF UPDATE(DGTXMKUP) SET @ChangedColumns = @ChangedColumns + 'DGTXMKUP, '
    IF UPDATE(DGBIN) SET @ChangedColumns = @ChangedColumns + 'DGBIN, '
    IF UPDATE(DGUSED) SET @ChangedColumns = @ChangedColumns + 'DGUSED, '
    IF UPDATE(DGUSE) SET @ChangedColumns = @ChangedColumns + 'DGUSE, '
    IF UPDATE(DGUPC) SET @ChangedColumns = @ChangedColumns + 'DGUPC, '
    IF UPDATE(DGCATEGORY) SET @ChangedColumns = @ChangedColumns + 'DGCATEGORY, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(DGNOTE1) SET @ChangedColumns = @ChangedColumns + 'DGNOTE1, '
    IF UPDATE(DGNOTE2) SET @ChangedColumns = @ChangedColumns + 'DGNOTE2, '
    IF UPDATE(DGNOTE3) SET @ChangedColumns = @ChangedColumns + 'DGNOTE3, '
    IF UPDATE(DGNOTE4) SET @ChangedColumns = @ChangedColumns + 'DGNOTE4, '
    IF UPDATE(DGNOTE5) SET @ChangedColumns = @ChangedColumns + 'DGNOTE5, '
    IF UPDATE(DGCOLOR) SET @ChangedColumns = @ChangedColumns + 'DGCOLOR, '
    IF UPDATE(DGMARKINGS) SET @ChangedColumns = @ChangedColumns + 'DGMARKINGS, '
    IF UPDATE(DGMAN) SET @ChangedColumns = @ChangedColumns + 'DGMAN, '
    IF UPDATE(DGPNET) SET @ChangedColumns = @ChangedColumns + 'DGPNET, '
    IF UPDATE(DGCOMPOUND) SET @ChangedColumns = @ChangedColumns + 'DGCOMPOUND, '
    IF UPDATE(DGNOTE) SET @ChangedColumns = @ChangedColumns + 'DGNOTE, '
    IF UPDATE(DGLOT) SET @ChangedColumns = @ChangedColumns + 'DGLOT, '
    IF UPDATE(DGSUPPLY) SET @ChangedColumns = @ChangedColumns + 'DGSUPPLY, '
    IF UPDATE(DGLONGNAME) SET @ChangedColumns = @ChangedColumns + 'DGLONGNAME, '
    IF UPDATE(DGPRNTCMPD) SET @ChangedColumns = @ChangedColumns + 'DGPRNTCMPD, '
    IF UPDATE(DGUNIT) SET @ChangedColumns = @ChangedColumns + 'DGUNIT, '
    IF UPDATE(DGIUQTY) SET @ChangedColumns = @ChangedColumns + 'DGIUQTY, '
    IF UPDATE(DGIUUNIT) SET @ChangedColumns = @ChangedColumns + 'DGIUUNIT, '
    IF UPDATE(DGQ4) SET @ChangedColumns = @ChangedColumns + 'DGQ4, '
    IF UPDATE(DGQ5) SET @ChangedColumns = @ChangedColumns + 'DGQ5, '
    IF UPDATE(DGC4) SET @ChangedColumns = @ChangedColumns + 'DGC4, '
    IF UPDATE(DGC5) SET @ChangedColumns = @ChangedColumns + 'DGC5, '
    IF UPDATE(DGIUDRGQTY) SET @ChangedColumns = @ChangedColumns + 'DGIUDRGQTY, '
    IF UPDATE(DGGROUPID) SET @ChangedColumns = @ChangedColumns + 'DGGROUPID, '
    IF UPDATE(DGFORMULA) SET @ChangedColumns = @ChangedColumns + 'DGFORMULA, '
    IF UPDATE(DGAUXLABEL) SET @ChangedColumns = @ChangedColumns + 'DGAUXLABEL, '
    IF UPDATE(DGHAZARD) SET @ChangedColumns = @ChangedColumns + 'DGHAZARD, '
    IF UPDATE(DGPRIORITY) SET @ChangedColumns = @ChangedColumns + 'DGPRIORITY, '
    IF UPDATE(DGCOSTX) SET @ChangedColumns = @ChangedColumns + 'DGCOSTX, '
    IF UPDATE(DGUPC2) SET @ChangedColumns = @ChangedColumns + 'DGUPC2, '
    IF UPDATE(DGUPC3) SET @ChangedColumns = @ChangedColumns + 'DGUPC3, '
    IF UPDATE(DGGENERIC) SET @ChangedColumns = @ChangedColumns + 'DGGENERIC, '
    IF UPDATE(DGDIV) SET @ChangedColumns = @ChangedColumns + 'DGDIV, '
    IF UPDATE(DGCMPDPRICE) SET @ChangedColumns = @ChangedColumns + 'DGCMPDPRICE, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[DRUGAudit] (
        [DGDIN], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.DGDIN,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Drug record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for DRUG - Changed: ' + @ChangedColumns
END
GO

-- DRUG DELETE Trigger
CREATE TRIGGER [trg_DRUG_Delete]
ON [DRUG]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[DRUGAudit] (
        [DGDIN], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.DGDIN,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Drug record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for DRUG'
END
GO

PRINT 'Created triggers for CHGDRUG, Communications, DOCUMENTS, and DRUG tables'
GO


-- =============================================================================
-- ERX TABLE TRIGGERS (FIXED FOR TEXT DATA TYPE)
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_ERX_Insert')
    DROP TRIGGER [trg_ERX_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_ERX_Update')
    DROP TRIGGER [trg_ERX_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_ERX_Delete')
    DROP TRIGGER [trg_ERX_Delete]

-- ERX INSERT Trigger (Fixed for text data type)
CREATE TRIGGER [trg_ERX_Insert]
ON [ERX]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[ERXAudit] (
        [XKEY], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.XKEY,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New ERX record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for ERX'
END
GO

-- ERX UPDATE Trigger (Fixed for text data type)
CREATE TRIGGER [trg_ERX_Update]
ON [ERX]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(XNUM) SET @ChangedColumns = @ChangedColumns + 'XNUM, '
    IF UPDATE(XBR) SET @ChangedColumns = @ChangedColumns + 'XBR, '
    IF UPDATE(XID) SET @ChangedColumns = @ChangedColumns + 'XID, '
    IF UPDATE(XSUPPLY) SET @ChangedColumns = @ChangedColumns + 'XSUPPLY, '
    IF UPDATE(XPERIOD) SET @ChangedColumns = @ChangedColumns + 'XPERIOD, '
    IF UPDATE(XREFILLS) SET @ChangedColumns = @ChangedColumns + 'XREFILLS, '
    IF UPDATE(XQTY) SET @ChangedColumns = @ChangedColumns + 'XQTY, '
    IF UPDATE(XDRUG) SET @ChangedColumns = @ChangedColumns + 'XDRUG, '
    IF UPDATE(XSIG) SET @ChangedColumns = @ChangedColumns + 'XSIG, '
    IF UPDATE(XDIN) SET @ChangedColumns = @ChangedColumns + 'XDIN, '
    IF UPDATE(XDEA) SET @ChangedColumns = @ChangedColumns + 'XDEA, '
    IF UPDATE(XDRSURNAME) SET @ChangedColumns = @ChangedColumns + 'XDRSURNAME, '
    IF UPDATE(XDRGIVEN) SET @ChangedColumns = @ChangedColumns + 'XDRGIVEN, '
    IF UPDATE(XCOLL) SET @ChangedColumns = @ChangedColumns + 'XCOLL, '
    IF UPDATE(XDATE) SET @ChangedColumns = @ChangedColumns + 'XDATE, '
    IF UPDATE(XSTATUS) SET @ChangedColumns = @ChangedColumns + 'XSTATUS, '
    IF UPDATE(XPHN) SET @ChangedColumns = @ChangedColumns + 'XPHN, '
    IF UPDATE(XSURNAME) SET @ChangedColumns = @ChangedColumns + 'XSURNAME, '
    IF UPDATE(XGIVEN) SET @ChangedColumns = @ChangedColumns + 'XGIVEN, '
    IF UPDATE(XSTREET1) SET @ChangedColumns = @ChangedColumns + 'XSTREET1, '
    IF UPDATE(XSTREET2) SET @ChangedColumns = @ChangedColumns + 'XSTREET2, '
    IF UPDATE(XCITY) SET @ChangedColumns = @ChangedColumns + 'XCITY, '
    IF UPDATE(XPROV) SET @ChangedColumns = @ChangedColumns + 'XPROV, '
    IF UPDATE(XPC) SET @ChangedColumns = @ChangedColumns + 'XPC, '
    IF UPDATE(XCTRY) SET @ChangedColumns = @ChangedColumns + 'XCTRY, '
    IF UPDATE(XNOSUB) SET @ChangedColumns = @ChangedColumns + 'XNOSUB, '
    IF UPDATE(XRETADDR) SET @ChangedColumns = @ChangedColumns + 'XRETADDR, '
    IF UPDATE(XSEX) SET @ChangedColumns = @ChangedColumns + 'XSEX, '
    IF UPDATE(XBIRTH) SET @ChangedColumns = @ChangedColumns + 'XBIRTH, '
    IF UPDATE(XEXTERNALID) SET @ChangedColumns = @ChangedColumns + 'XEXTERNALID, '
    IF UPDATE(XNOTE) SET @ChangedColumns = @ChangedColumns + 'XNOTE, '
    IF UPDATE(XHOME) SET @ChangedColumns = @ChangedColumns + 'XHOME, '
    IF UPDATE(XRB) SET @ChangedColumns = @ChangedColumns + 'XRB, '
    IF UPDATE(XAREA) SET @ChangedColumns = @ChangedColumns + 'XAREA, '
    IF UPDATE(XPHONE) SET @ChangedColumns = @ChangedColumns + 'XPHONE, '
    IF UPDATE(XENDDATE) SET @ChangedColumns = @ChangedColumns + 'XENDDATE, '
    IF UPDATE(XPRN) SET @ChangedColumns = @ChangedColumns + 'XPRN, '
    IF UPDATE(XSTAT) SET @ChangedColumns = @ChangedColumns + 'XSTAT, '
    IF UPDATE(XORIGRX) SET @ChangedColumns = @ChangedColumns + 'XORIGRX, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(XPKG) SET @ChangedColumns = @ChangedColumns + 'XPKG, '
    IF UPDATE(XADAPT) SET @ChangedColumns = @ChangedColumns + 'XADAPT, '
    IF UPDATE(XFREQ) SET @ChangedColumns = @ChangedColumns + 'XFREQ, '
    IF UPDATE(XCREATED) SET @ChangedColumns = @ChangedColumns + 'XCREATED, '
    IF UPDATE(XORIGERX) SET @ChangedColumns = @ChangedColumns + 'XORIGERX, '
    IF UPDATE(XMSG1) SET @ChangedColumns = @ChangedColumns + 'XMSG1, '
    IF UPDATE(XMSG2) SET @ChangedColumns = @ChangedColumns + 'XMSG2, '
    IF UPDATE(XMSG3) SET @ChangedColumns = @ChangedColumns + 'XMSG3, '
    IF UPDATE(XALLERGY) SET @ChangedColumns = @ChangedColumns + 'XALLERGY, '
    IF UPDATE(XSITE) SET @ChangedColumns = @ChangedColumns + 'XSITE, '
    IF UPDATE(XROUTE) SET @ChangedColumns = @ChangedColumns + 'XROUTE, '
    IF UPDATE(XADMIN) SET @ChangedColumns = @ChangedColumns + 'XADMIN, '
    IF UPDATE(XCELL) SET @ChangedColumns = @ChangedColumns + 'XCELL, '
    IF UPDATE(XEMAIL) SET @ChangedColumns = @ChangedColumns + 'XEMAIL, '
    IF UPDATE(XPLANS) SET @ChangedColumns = @ChangedColumns + 'XPLANS, '
    IF UPDATE(XPRICE) SET @ChangedColumns = @ChangedColumns + 'XPRICE, '
    IF UPDATE(XADMNO) SET @ChangedColumns = @ChangedColumns + 'XADMNO, '
    IF UPDATE(XUSERNOTE) SET @ChangedColumns = @ChangedColumns + 'XUSERNOTE, '
    IF UPDATE(XAIG) SET @ChangedColumns = @ChangedColumns + 'XAIG, '
    IF UPDATE(XSOURCE) SET @ChangedColumns = @ChangedColumns + 'XSOURCE, '
    IF UPDATE(XFAX) SET @ChangedColumns = @ChangedColumns + 'XFAX, '
    IF UPDATE(XRECORDINUSE) SET @ChangedColumns = @ChangedColumns + 'XRECORDINUSE, '
    IF UPDATE(XPRIORITY) SET @ChangedColumns = @ChangedColumns + 'XPRIORITY, '
    IF UPDATE(XDRFISRTTXID) SET @ChangedColumns = @ChangedColumns + 'XDRFISRTTXID, '
    IF UPDATE(XDRFISRTMEDID) SET @ChangedColumns = @ChangedColumns + 'XDRFISRTMEDID, '
    IF UPDATE(XCONDITION) SET @ChangedColumns = @ChangedColumns + 'XCONDITION, '
    IF UPDATE(XAssignToERxUser) SET @ChangedColumns = @ChangedColumns + 'XAssignToERxUser, '
    IF UPDATE(XPickUp) SET @ChangedColumns = @ChangedColumns + 'XPickUp, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[ERXAudit] (
        [XKEY], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.XKEY,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'ERX record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for ERX - Changed: ' + @ChangedColumns
END
GO

-- ERX DELETE Trigger
CREATE TRIGGER [trg_ERX_Delete]
ON [ERX]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[ERXAudit] (
        [XKEY], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.XKEY,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'ERX record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for ERX'
END
GO

-- =============================================================================
-- PACMED TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PACMED_Insert')
    DROP TRIGGER [trg_PACMED_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PACMED_Update')
    DROP TRIGGER [trg_PACMED_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PACMED_Delete')
    DROP TRIGGER [trg_PACMED_Delete]

-- PACMED INSERT Trigger
CREATE TRIGGER [trg_PACMED_Insert]
ON [PACMED]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[PACMEDAudit] (
        [Id], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.Id,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New PACMED record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for PACMED'
END
GO

-- PACMED UPDATE Trigger
CREATE TRIGGER [trg_PACMED_Update]
ON [PACMED]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    -- Note: PACMED table structure not fully provided, using generic approach
    IF UPDATE(Id) SET @ChangedColumns = @ChangedColumns + 'Id, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[PACMEDAudit] (
        [Id], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.Id,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'PACMED record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for PACMED - Changed: ' + @ChangedColumns
END
GO

-- PACMED DELETE Trigger
CREATE TRIGGER [trg_PACMED_Delete]
ON [PACMED]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[PACMEDAudit] (
        [Id], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.Id,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'PACMED record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for PACMED'
END
GO

-- =============================================================================
-- PATIENT TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PATIENT_Insert')
    DROP TRIGGER [trg_PATIENT_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PATIENT_Update')
    DROP TRIGGER [trg_PATIENT_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PATIENT_Delete')
    DROP TRIGGER [trg_PATIENT_Delete]

-- PATIENT INSERT Trigger
CREATE TRIGGER [trg_PATIENT_Insert]
ON [PATIENT]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[PATIENTAudit] (
        [PANUM], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.PANUM,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New patient record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for PATIENT'
END
GO

-- PATIENT UPDATE Trigger
CREATE TRIGGER [trg_PATIENT_Update]
ON [PATIENT]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    -- Note: PATIENT table structure not fully provided, using generic approach
    IF UPDATE(PANUM) SET @ChangedColumns = @ChangedColumns + 'PANUM, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[PATIENTAudit] (
        [PANUM], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.PANUM,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Patient record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for PATIENT - Changed: ' + @ChangedColumns
END
GO

-- PATIENT DELETE Trigger
CREATE TRIGGER [trg_PATIENT_Delete]
ON [PATIENT]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[PATIENTAudit] (
        [PANUM], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.PANUM,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Patient record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for PATIENT'
END
GO

-- =============================================================================
-- REFILL TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_REFILL_Insert')
    DROP TRIGGER [trg_REFILL_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_REFILL_Update')
    DROP TRIGGER [trg_REFILL_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_REFILL_Delete')
    DROP TRIGGER [trg_REFILL_Delete]

-- REFILL INSERT Trigger
CREATE TRIGGER [trg_REFILL_Insert]
ON [REFILL]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[REFILLAudit] (
        [REFILLID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.REFILLID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New refill record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for REFILL'
END
GO

-- REFILL UPDATE Trigger
CREATE TRIGGER [trg_REFILL_Update]
ON [REFILL]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    -- Note: REFILL table structure not fully provided, using generic approach
    IF UPDATE(REFILLID) SET @ChangedColumns = @ChangedColumns + 'REFILLID, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[REFILLAudit] (
        [REFILLID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.REFILLID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Refill record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for REFILL - Changed: ' + @ChangedColumns
END
GO

-- REFILL DELETE Trigger
CREATE TRIGGER [trg_REFILL_Delete]
ON [REFILL]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[REFILLAudit] (
        [REFILLID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.REFILLID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Refill record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for REFILL'
END
GO

-- =============================================================================
-- RX TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_RX_Insert')
    DROP TRIGGER [trg_RX_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_RX_Update')
    DROP TRIGGER [trg_RX_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_RX_Delete')
    DROP TRIGGER [trg_RX_Delete]

-- RX INSERT Trigger
CREATE TRIGGER [trg_RX_Insert]
ON [RX]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[RXAudit] (
        [RXNUM], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.RXNUM,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New RX record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for RX'
END
GO

-- RX UPDATE Trigger
CREATE TRIGGER [trg_RX_Update]
ON [RX]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    -- Note: RX table structure not fully provided, using generic approach
    IF UPDATE(RXNUM) SET @ChangedColumns = @ChangedColumns + 'RXNUM, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[RXAudit] (
        [RXNUM], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.RXNUM,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'RX record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for RX - Changed: ' + @ChangedColumns
END
GO

-- RX DELETE Trigger
CREATE TRIGGER [trg_RX_Delete]
ON [RX]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[RXAudit] (
        [RXNUM], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.RXNUM,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'RX record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for RX'
END
GO

-- =============================================================================
-- TXNS TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_TXNS_Insert')
    DROP TRIGGER [trg_TXNS_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_TXNS_Update')
    DROP TRIGGER [trg_TXNS_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_TXNS_Delete')
    DROP TRIGGER [trg_TXNS_Delete]

-- TXNS INSERT Trigger
CREATE TRIGGER [trg_TXNS_Insert]
ON [TXNS]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[TXNSAudit] (
        [TXNSID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.TXNSID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New TXNS record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for TXNS'
END
GO

-- TXNS UPDATE Trigger
CREATE TRIGGER [trg_TXNS_Update]
ON [TXNS]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    -- Note: TXNS table structure not fully provided, using generic approach
    IF UPDATE(TXNSID) SET @ChangedColumns = @ChangedColumns + 'TXNSID, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[TXNSAudit] (
        [TXNSID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.TXNSID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'TXNS record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for TXNS - Changed: ' + @ChangedColumns
END
GO

-- TXNS DELETE Trigger
CREATE TRIGGER [trg_TXNS_Delete]
ON [TXNS]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[TXNSAudit] (
        [TXNSID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.TXNSID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'TXNS record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for TXNS'
END
GO

-- =============================================================================
-- SCHEDULE TABLE TRIGGERS
-- =============================================================================

-- Drop existing triggers if they exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SCHEDULE_Insert')
    DROP TRIGGER [trg_SCHEDULE_Insert]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SCHEDULE_Update')
    DROP TRIGGER [trg_SCHEDULE_Update]
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_SCHEDULE_Delete')
    DROP TRIGGER [trg_SCHEDULE_Delete]

-- SCHEDULE INSERT Trigger
CREATE TRIGGER [trg_SCHEDULE_Insert]
ON [SCHEDULE]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[SCHEDULEAudit] (
        [SCID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        i.SCID,
        'INSERT',
        GETDATE(),
        SYSTEM_USER,
        'New schedule record added'
    FROM inserted i
    
    PRINT 'INSERT trigger fired for SCHEDULE'
END
GO

-- SCHEDULE UPDATE Trigger
CREATE TRIGGER [trg_SCHEDULE_Update]
ON [SCHEDULE]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ChangedColumns VARCHAR(500) = ''
    
    IF UPDATE(SCRXNUM) SET @ChangedColumns = @ChangedColumns + 'SCRXNUM, '
    IF UPDATE(SCNAME) SET @ChangedColumns = @ChangedColumns + 'SCNAME, '
    IF UPDATE(SCDRUG) SET @ChangedColumns = @ChangedColumns + 'SCDRUG, '
    IF UPDATE(SCDAYS) SET @ChangedColumns = @ChangedColumns + 'SCDAYS, '
    IF UPDATE(SCQTY) SET @ChangedColumns = @ChangedColumns + 'SCQTY, '
    IF UPDATE(SCBR) SET @ChangedColumns = @ChangedColumns + 'SCBR, '
    IF UPDATE(SCID) SET @ChangedColumns = @ChangedColumns + 'SCID, '
    IF UPDATE(AddDatetime) SET @ChangedColumns = @ChangedColumns + 'AddDatetime, '
    IF UPDATE(AddUsername) SET @ChangedColumns = @ChangedColumns + 'AddUsername, '
    IF UPDATE(UpdateUsername) SET @ChangedColumns = @ChangedColumns + 'UpdateUsername, '
    IF UPDATE(UpdateDatetime) SET @ChangedColumns = @ChangedColumns + 'UpdateDatetime, '
    IF UPDATE(SCPHN) SET @ChangedColumns = @ChangedColumns + 'SCPHN, '
    IF UPDATE(SCCYCLE) SET @ChangedColumns = @ChangedColumns + 'SCCYCLE, '
    IF UPDATE(SCSTART) SET @ChangedColumns = @ChangedColumns + 'SCSTART, '
    IF UPDATE(SCCARRY) SET @ChangedColumns = @ChangedColumns + 'SCCARRY, '
    
    IF LEN(@ChangedColumns) > 0
        SET @ChangedColumns = LEFT(@ChangedColumns, LEN(@ChangedColumns) - 2)
    ELSE
        SET @ChangedColumns = 'No specific columns detected'
    
    INSERT INTO [dbo].[SCHEDULEAudit] (
        [SCID], [Operation], [ChangeTime], [UserName], [ChangeDetails], [ChangedColumns]
    )
    SELECT
        i.SCID,
        'UPDATE',
        GETDATE(),
        SYSTEM_USER,
        'Schedule record was modified',
        @ChangedColumns
    FROM inserted i
    
    PRINT 'UPDATE trigger fired for SCHEDULE - Changed: ' + @ChangedColumns
END
GO

-- SCHEDULE DELETE Trigger
CREATE TRIGGER [trg_SCHEDULE_Delete]
ON [SCHEDULE]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[SCHEDULEAudit] (
        [SCID], [Operation], [ChangeTime], [UserName], [ChangeDetails]
    )
    SELECT
        d.SCID,
        'DELETE',
        GETDATE(),
        SYSTEM_USER,
        'Schedule record was deleted'
    FROM deleted d
    
    PRINT 'DELETE trigger fired for SCHEDULE'
END
GO

-- =============================================================================
-- COMPLETION
-- =============================================================================

PRINT '=================================================='
PRINT 'ALL PK TABLE TRIGGERS COMPLETED SUCCESSFULLY!'
PRINT '=================================================='
PRINT ''
PRINT 'Tables with triggers created:'
PRINT '- Appointment (AppID)'
PRINT '- CALLBACK (CBID)'
PRINT '- CHANGES (CGID)'
PRINT '- CHGDRUG (CHGDGID)'
PRINT '- Communications (ID) - Fixed for text data type'
PRINT '- DOCUMENTS (ID)'
PRINT '- DRUG (DGDIN) - Fixed for text data type'
PRINT '- ERX (XKEY) - Fixed for text data type'
PRINT '- PACMED (Id)'
PRINT '- PATIENT (PANUM)'
PRINT '- REFILL (REFILLID)'
PRINT '- RX (RXNUM)'
PRINT '- TXNS (TXNSID)'
PRINT '- SCHEDULE (SCID)'
PRINT ''
PRINT 'Total: 14 tables with primary keys covered'
PRINT ''
PRINT 'All PK table triggers are ready for use!'
GO