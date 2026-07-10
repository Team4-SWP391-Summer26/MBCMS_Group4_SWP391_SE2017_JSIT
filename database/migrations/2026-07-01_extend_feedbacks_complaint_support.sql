-- =====================================================================
-- Migration: Extend dbo.feedbacks for Complaint & Support Request features
-- Date: 2026-07-01
-- Adds: category, sub_category, related_booking_id, related_showtime_id, handled_by
-- Adds: indexes for category, showtime, and created_at
-- Updates: CK_feedbacks_status to include 'CLOSED' (already exists)
-- Updates: notifications CK_notifications_type to allow 'FEEDBACK'
-- =====================================================================

USE CinemaDB;
GO

-- 1. Add category column (NOT NULL with DEFAULT so existing rows get 'GENERAL')
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'category'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD category VARCHAR(10) NOT NULL CONSTRAINT DF_feedbacks_category DEFAULT ('GENERAL');
    PRINT 'Added column: feedbacks.category';
END
GO

-- 2. Add CHECK constraint for category values
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID('dbo.feedbacks') AND name = 'CK_feedbacks_category'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD CONSTRAINT CK_feedbacks_category
            CHECK (category IN ('COMPLAINT', 'SUPPORT', 'GENERAL'));
    PRINT 'Added constraint: CK_feedbacks_category';
END
GO

-- 3. Add sub_category (nullable, used only for SUPPORT category)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'sub_category'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD sub_category VARCHAR(10) NULL;
    PRINT 'Added column: feedbacks.sub_category';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID('dbo.feedbacks') AND name = 'CK_feedbacks_sub_category'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD CONSTRAINT CK_feedbacks_sub_category
            CHECK (sub_category IS NULL OR sub_category IN ('BOOKING', 'ACCOUNT', 'OTHER'));
    PRINT 'Added constraint: CK_feedbacks_sub_category';
END
GO

-- 4. Add related_booking_id (nullable FK to bookings)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'related_booking_id'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD related_booking_id BIGINT NULL;
    PRINT 'Added column: feedbacks.related_booking_id';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('dbo.feedbacks') AND name = 'FK_feedbacks_booking'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD CONSTRAINT FK_feedbacks_booking FOREIGN KEY (related_booking_id)
            REFERENCES dbo.bookings (booking_id) ON DELETE SET NULL;
    PRINT 'Added FK: FK_feedbacks_booking';
END
GO

-- 5. Add related_showtime_id (nullable FK to showtimes)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'related_showtime_id'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD related_showtime_id BIGINT NULL;
    PRINT 'Added column: feedbacks.related_showtime_id';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('dbo.feedbacks') AND name = 'FK_feedbacks_showtime'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD CONSTRAINT FK_feedbacks_showtime FOREIGN KEY (related_showtime_id)
            REFERENCES dbo.showtimes (showtime_id) ON DELETE SET NULL;
    PRINT 'Added FK: FK_feedbacks_showtime';
END
GO

-- 6. Add handled_by (nullable, employee username who processed the feedback)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'handled_by'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD handled_by VARCHAR(50) NULL;
    PRINT 'Added column: feedbacks.handled_by';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('dbo.feedbacks') AND name = 'FK_feedbacks_handler'
)
BEGIN
    ALTER TABLE dbo.feedbacks
        ADD CONSTRAINT FK_feedbacks_handler FOREIGN KEY (handled_by)
            REFERENCES dbo.employees (username) ON DELETE SET NULL;
    PRINT 'Added FK: FK_feedbacks_handler';
END
GO

-- 7. Add performance indexes
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'IX_feedbacks_category')
BEGIN
    CREATE INDEX IX_feedbacks_category ON dbo.feedbacks (category);
    PRINT 'Added index: IX_feedbacks_category';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'IX_feedbacks_showtime')
BEGIN
    CREATE INDEX IX_feedbacks_showtime ON dbo.feedbacks (related_showtime_id) WHERE related_showtime_id IS NOT NULL;
    PRINT 'Added index: IX_feedbacks_showtime';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.feedbacks') AND name = 'IX_feedbacks_created')
BEGIN
    CREATE INDEX IX_feedbacks_created ON dbo.feedbacks (created_at DESC);
    PRINT 'Added index: IX_feedbacks_created';
END
GO

-- 8. Update notifications CK_notifications_type to allow 'FEEDBACK'
-- Drop old constraint and re-add with FEEDBACK included
IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID('dbo.notifications') AND name = 'CK_notifications_type'
)
BEGIN
    -- Check if FEEDBACK is already in the constraint definition
    DECLARE @constraint_def NVARCHAR(MAX);
    SELECT @constraint_def = definition FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID('dbo.notifications') AND name = 'CK_notifications_type';

    IF @constraint_def NOT LIKE '%FEEDBACK%'
    BEGIN
        ALTER TABLE dbo.notifications DROP CONSTRAINT CK_notifications_type;
        ALTER TABLE dbo.notifications
            ADD CONSTRAINT CK_notifications_type
                CHECK ([type] IN ('BOOKING','PAYMENT','PROMOTION','REMINDER','SYSTEM','FEEDBACK'));
        PRINT 'Updated CK_notifications_type to include FEEDBACK';
    END
    ELSE
    BEGIN
        PRINT 'CK_notifications_type already includes FEEDBACK - skipped';
    END
END
GO

PRINT 'Migration 2026-07-01: feedbacks extension completed.';
GO
