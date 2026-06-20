-- =====================================================================
-- Migration: them bang movie_branch (M:N) - "Assign movie to branch"
-- Owner: HungNT.
-- Muc dich: Admin (head office) CAP phim cho tung chi nhanh; Branch Manager
--           chi xep lich (showtimes) tu danh sach phim chi nhanh minh duoc cap.
-- Ap dung tren DB da co dbo.movies + dbo.branches. Idempotent: chay lai an toan.
-- =====================================================================
USE CinemaDB;   -- QUAN TRONG: chay dung DB (khong phai master)
GO

IF OBJECT_ID('dbo.movie_branch', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.movie_branch (
        movie_id    BIGINT    NOT NULL,
        branch_id   BIGINT    NOT NULL,
        assigned_at DATETIME2 NOT NULL CONSTRAINT DF_movie_branch_assigned DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_movie_branch PRIMARY KEY (movie_id, branch_id),
        CONSTRAINT FK_movie_branch_movie  FOREIGN KEY (movie_id)
            REFERENCES dbo.movies (movie_id) ON DELETE CASCADE,   -- xoa phim -> bo cap phat
        CONSTRAINT FK_movie_branch_branch FOREIGN KEY (branch_id)
            REFERENCES dbo.branches (branch_id)   -- KHONG cascade: tranh nhieu duong cascade
    );
    CREATE INDEX IX_movie_branch_branch ON dbo.movie_branch (branch_id);
END
GO

-- Seed bao toan: cap moi phim active cho moi chi nhanh -> Showtime hien tai khong gay.
-- Chi them cap CHUA co (chay lai khong nhan ban).
INSERT INTO dbo.movie_branch (movie_id, branch_id)
SELECT m.movie_id, b.branch_id
FROM dbo.movies m
CROSS JOIN dbo.branches b
WHERE m.active = 1
  AND NOT EXISTS (
      SELECT 1 FROM dbo.movie_branch mb
      WHERE mb.movie_id = m.movie_id AND mb.branch_id = b.branch_id
  );
GO

PRINT 'movie_branch created + seeded (all active movies x all branches).';
GO
