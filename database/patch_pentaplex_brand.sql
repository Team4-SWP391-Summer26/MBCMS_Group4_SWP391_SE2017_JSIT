-- =====================================================================
-- PentaPlex rebrand patch (run on existing CinemaDB without full re-seed)
-- Safe to run multiple times — only updates rows that still use old names.
-- =====================================================================
USE CinemaDB;
GO

UPDATE dbo.branches
SET name = REPLACE(name, N'MBCMS ', N'PentaPlex ')
WHERE name LIKE N'MBCMS %';

UPDATE dbo.branches
SET email = REPLACE(email, N'@mbcms.vn', N'@pentaplex.vn')
WHERE email LIKE N'%@mbcms.vn';

PRINT N'PentaPlex brand patch applied.';
