-- Migration: add branch_id to dbo.promotions
-- Reason: admin promotion code (DAO/servlet/JSP) scopes promotions per branch,
--         but the column was missing -> "Invalid column name 'branch_id'" -> HTTP 500.
-- NULL branch_id = promotion applies to ALL branches (system-wide).
-- Run once on the existing database via SSMS.

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.promotions') AND name = 'branch_id'
)
BEGIN
    ALTER TABLE dbo.promotions
        ADD branch_id BIGINT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_promotions_branch'
)
BEGIN
    ALTER TABLE dbo.promotions
        ADD CONSTRAINT FK_promotions_branch
        FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id);
END
GO
