-- =====================================================================
-- CinemaDB - Unified Branch Seed Data Script (Showtimes, F&B, Promotions)
-- SWP391 - Multi-Branch Cinema Management System (MBCMS)
-- 
-- Chạy script này để nạp dữ liệu giả định mẫu cho:
--   1. Suất chiếu tương lai (Showtimes) từ ngày 2026-06-25 đến 2026-06-26 cho từng phòng chieu/chi nhánh.
--   2. Thực đơn đồ ăn & uống (F&B / Concessions) gán theo từng chi nhánh cụ thể.
--   3. Mã khuyến mãi (Promotions) áp dụng theo từng chi nhánh cụ thể (hoặc toàn hệ thống).
-- =====================================================================

USE CinemaDB;
GO

-- ---------------------------------------------------------------------
-- 1. Dọn dẹp dữ liệu cũ (theo đúng thứ tự ràng buộc khóa ngoại)
-- ---------------------------------------------------------------------
PRINT 'Dang don dep du lieu cu...';
DELETE FROM dbo.booking_food_items;
DELETE FROM dbo.food_orders;
DELETE FROM dbo.booking_seats;
DELETE FROM dbo.payments;
DELETE FROM dbo.bookings;
DELETE FROM dbo.showtimes;
DELETE FROM dbo.food_items;
DELETE FROM dbo.promotions;
GO

-- ---------------------------------------------------------------------
-- 2. Khởi tạo mã khuyến mãi (Promotions) phân vùng theo chi nhánh
-- ---------------------------------------------------------------------
PRINT 'Dang khoi tao ma khuyen mai (Promotions)...';
DECLARE @b1 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Nguyen Hue');
DECLARE @b2 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Ba Trieu');

-- WELCOME10 gán cho chi nhánh Nguyen Hue (b1)
INSERT INTO dbo.promotions (code, name, discount_type, discount_value, min_order_amount, valid_from, valid_to, max_uses, branch_id)
VALUES ('WELCOME10', N'Welcome 10% off - Nguyen Hue', 'PERCENT', 10.00, NULL, '2026-05-01 00:00:00', '2026-12-31 23:59:59', NULL, @b1);

-- SUMMER50K gán cho chi nhánh Ba Trieu (b2)
INSERT INTO dbo.promotions (code, name, discount_type, discount_value, min_order_amount, valid_from, valid_to, max_uses, branch_id)
VALUES ('SUMMER50K', N'Summer 50K off - Ba Trieu', 'FIXED_AMOUNT', 50000.00, 200000.00, '2026-06-01 00:00:00', '2026-08-31 23:59:59', 1000, @b2);

-- Mã khuyến mãi dùng chung toàn hệ thống (Global - branch_id IS NULL)
INSERT INTO dbo.promotions (code, name, discount_type, discount_value, min_order_amount, valid_from, valid_to, max_uses, branch_id)
VALUES ('GLOBAL20', N'Global Mega Sale 20%', 'PERCENT', 20.00, 150000.00, '2026-06-15 00:00:00', '2026-07-15 23:59:59', 500, NULL);
GO

-- ---------------------------------------------------------------------
-- 3. Khởi tạo thực đơn đồ ăn & uống (F&B / Food Items) gán cho từng chi nhánh
-- ---------------------------------------------------------------------
PRINT 'Dang khoi tao thuc don F&B cho tung chi nhanh...';
INSERT INTO dbo.food_items (name, description, price, category, image_url, branch_id, stock, active)
SELECT 
    f.name, 
    f.description, 
    f.price, 
    f.category, 
    f.image_url, 
    b.branch_id, 
    100 AS stock, 
    1 AS active
FROM dbo.branches b
CROSS JOIN (VALUES
    (N'Popcorn (Large)', N'Salted popcorn, large size',   65000.00,  'SNACK', '/assets/img/concessions/popcorn-large.png'),
    (N'Popcorn (Medium)',N'Caramel popcorn, medium size', 55000.00,  'SNACK', '/assets/img/concessions/popcorn-medium.png'),
    (N'Coca-Cola',       N'Soft drink 500ml',             30000.00,  'DRINK', '/assets/img/concessions/coca-cola.png'),
    (N'Mineral Water',   N'Bottled water 500ml',          20000.00,  'DRINK', '/assets/img/concessions/mineral-water.png'),
    (N'Combo for 2',     N'2 drinks + 1 large popcorn',   120000.00, 'COMBO', '/assets/img/concessions/combo-for-2.png'),
    (N'Combo Solo',      N'1 drink + 1 medium popcorn',   75000.00,  'COMBO', '/assets/img/concessions/combo-solo.png')
) AS f(name, description, price, category, image_url);
GO

-- ---------------------------------------------------------------------
-- 4. Khởi tạo lịch chiếu (Showtimes) tương lai cho từng chi nhánh
-- ---------------------------------------------------------------------
PRINT 'Dang khoi tao lich chieu (Showtimes) cho tung chi nhanh...';

-- A. Suất chiếu cho chi nhánh: MBCMS Nguyen Hue (Ho Chi Minh)
INSERT INTO dbo.showtimes (room_id, movie_id, start_time, end_time, base_price, format, subtitle_type, [status])
SELECT 
    r.room_id, 
    mv.movie_id, 
    CAST(s.start_time AS DATETIME2), 
    DATEADD(MINUTE, mv.duration_min, CAST(s.start_time AS DATETIME2)), 
    s.base_price, 
    s.format, 
    s.subtitle_type, 
    'SCHEDULED'
FROM (VALUES
    -- Room 1 (STANDARD)
    (N'Room 1', N'Dune: Part Three', '2026-06-25 10:00:00', CAST(90000.00 AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'Room 1', N'The Last Laugh',   '2026-06-25 13:30:00', 85000.00,  '2D',   'SUB'),
    (N'Room 1', N'Dune: Part Three', '2026-06-25 17:00:00', 90000.00,  '2D',   'SUB'),
    (N'Room 1', N'The Last Laugh',   '2026-06-25 20:30:00', 85000.00,  '2D',   'SUB'),
    
    (N'Room 1', N'The Last Laugh',   '2026-06-26 10:00:00', 80000.00,  '2D',   'SUB'),
    (N'Room 1', N'Dune: Part Three', '2026-06-26 13:30:00', 90000.00,  '2D',   'SUB'),
    (N'Room 1', N'The Last Laugh',   '2026-06-26 17:00:00', 80000.00,  '2D',   'SUB'),
    (N'Room 1', N'Dune: Part Three', '2026-06-26 20:30:00', 90000.00,  '2D',   'SUB'),

    -- Room 2 (VIP)
    (N'Room 2', N'Mai 2',            '2026-06-25 10:30:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-25 15:00:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-25 19:00:00', 120000.00, '2D',   'ORIGINAL'),
    
    (N'Room 2', N'Mai 2',            '2026-06-26 10:30:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-26 15:00:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-26 19:00:00', 120000.00, '2D',   'ORIGINAL'),

    -- IMAX Hall (IMAX)
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-25 11:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-25 16:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-25 20:00:00', 190000.00, 'IMAX', 'SUB'),
    
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-26 11:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-26 16:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-26 20:00:00', 190000.00, 'IMAX', 'SUB')
) AS s(room_name, movie_title, start_time, base_price, format, subtitle_type)
JOIN dbo.rooms r ON r.name = s.room_name AND r.branch_id = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Nguyen Hue')
JOIN dbo.movies mv ON mv.title = s.movie_title;

-- B. Suất chiếu cho chi nhánh: MBCMS Ba Trieu (Ha Noi)
INSERT INTO dbo.showtimes (room_id, movie_id, start_time, end_time, base_price, format, subtitle_type, [status])
SELECT 
    r.room_id, 
    mv.movie_id, 
    CAST(s.start_time AS DATETIME2), 
    DATEADD(MINUTE, mv.duration_min, CAST(s.start_time AS DATETIME2)), 
    s.base_price, 
    s.format, 
    s.subtitle_type, 
    'SCHEDULED'
FROM (VALUES
    -- Room 1 (STANDARD)
    (N'Room 1', N'The Last Laugh',   '2026-06-25 10:00:00', CAST(85000.00 AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'Room 1', N'Dune: Part Three', '2026-06-25 13:30:00', 95000.00,  '2D',   'SUB'),
    (N'Room 1', N'The Last Laugh',   '2026-06-25 17:00:00', 85000.00,  '2D',   'SUB'),
    (N'Room 1', N'Dune: Part Three', '2026-06-25 20:30:00', 95000.00,  '2D',   'SUB'),
    
    (N'Room 1', N'Dune: Part Three', '2026-06-26 10:00:00', 95000.00,  '2D',   'SUB'),
    (N'Room 1', N'The Last Laugh',   '2026-06-26 13:30:00', 85000.00,  '2D',   'SUB'),
    (N'Room 1', N'Dune: Part Three', '2026-06-26 17:00:00', 95000.00,  '2D',   'SUB'),
    (N'Room 1', N'The Last Laugh',   '2026-06-26 20:30:00', 85000.00,  '2D',   'SUB'),

    -- Room 2 (VIP)
    (N'Room 2', N'Mai 2',            '2026-06-25 10:30:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-25 15:00:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-25 19:00:00', 120000.00, '2D',   'ORIGINAL'),
    
    (N'Room 2', N'Mai 2',            '2026-06-26 10:30:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-26 15:00:00', 110000.00, '2D',   'ORIGINAL'),
    (N'Room 2', N'Mai 2',            '2026-06-26 19:00:00', 120000.00, '2D',   'ORIGINAL'),

    -- IMAX Hall (IMAX)
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-25 11:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-25 16:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-25 20:00:00', 190000.00, 'IMAX', 'SUB'),
    
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-26 11:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-26 16:00:00', 180000.00, 'IMAX', 'SUB'),
    (N'IMAX Hall', N'Dune: Part Three', '2026-06-26 20:00:00', 190000.00, 'IMAX', 'SUB')
) AS s(room_name, movie_title, start_time, base_price, format, subtitle_type)
JOIN dbo.rooms r ON r.name = s.room_name AND r.branch_id = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Ba Trieu')
JOIN dbo.movies mv ON mv.title = s.movie_title;
GO

PRINT 'Hoan tat nap du lieu gia dinh!';
GO
