-- =====================================================================
-- CinemaDB - Sample data (seed)
-- Run AFTER CinemaDB_schema.sql
--
-- LOGIN NOTE:
--   All seeded accounts use the SAME password: "password"
--   bcrypt hash below is the canonical work-factor-10 hash for "password".
--   It is jBCrypt-compatible ($2a$). Change in production.
-- =====================================================================
USE CinemaDB;
GO

-- Clean existing data (child -> parent) so this script is re-runnable
DELETE FROM dbo.booking_food_items;
DELETE FROM dbo.food_orders;
DELETE FROM dbo.payments;
DELETE FROM dbo.booking_seats;
DELETE FROM dbo.bookings;
DELETE FROM dbo.notifications;
DELETE FROM dbo.feedbacks;
DELETE FROM dbo.showtimes;
DELETE FROM dbo.seats;
DELETE FROM dbo.rooms;
DELETE FROM dbo.movie_genres;
DELETE FROM dbo.food_items;
DELETE FROM dbo.promotions;
DELETE FROM dbo.employees;
DELETE FROM dbo.customers;
DELETE FROM dbo.branches;
DELETE FROM dbo.movies;
DELETE FROM dbo.genres;
GO

DECLARE @PWD VARCHAR(255) = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'; -- "password"

-- ---------------------------------------------------------------------
-- 1. Genres
-- ---------------------------------------------------------------------
INSERT INTO dbo.genres (name) VALUES
 (N'Action'), (N'Comedy'), (N'Drama'), (N'Horror'),
 (N'Sci-Fi'), (N'Animation'), (N'Romance'), (N'Thriller');

-- ---------------------------------------------------------------------
-- 2. Movies
-- ---------------------------------------------------------------------
INSERT INTO dbo.movies
 (title, description, duration_min, director, cast_list, [language], country, rated, poster_url, trailer_url, release_date, [status])
VALUES
 (N'Dune: Part Three', N'The epic conclusion of the Dune saga.', 165, N'Denis Villeneuve', N'Timothee Chalamet, Zendaya', 'English', 'USA', 'C13', NULL, NULL, '2026-06-05', 'NOW_SHOWING'),
 (N'Mai 2', N'A heartfelt Vietnamese drama sequel.', 130, N'Tran Thanh', N'Phuong Anh Dao', 'Vietnamese', 'Vietnam', 'C16', NULL, NULL, '2026-05-20', 'NOW_SHOWING'),
 (N'The Last Laugh', N'A comedy about a stand-up comedian.', 105, N'Greta Gerwig', N'Emma Stone', 'English', 'USA', 'P', NULL, NULL, '2026-06-12', 'NOW_SHOWING'),
 (N'Silent Shadows', N'A horror film set in an abandoned hospital.', 98, N'James Wan', N'Vera Farmiga', 'English', 'USA', 'C18', NULL, NULL, '2026-07-01', 'UPCOMING'),
 (N'Stellar Voyage', N'A sci-fi journey across galaxies.', 142, N'Christopher Nolan', N'Cillian Murphy', 'English', 'USA', 'C13', NULL, NULL, '2026-06-20', 'UPCOMING'),
 (N'Little Heroes', N'An animated adventure for the whole family.', 92, N'Pete Docter', N'Tom Holland', 'English', 'USA', 'P', NULL, NULL, '2026-04-10', 'ENDED');

-- ---------------------------------------------------------------------
-- 3. movie_genres (map by name to avoid hard-coding IDs)
-- ---------------------------------------------------------------------
INSERT INTO dbo.movie_genres (movie_id, genre_id)
SELECT m.movie_id, g.genre_id
FROM (VALUES
    (N'Dune: Part Three', N'Sci-Fi'), (N'Dune: Part Three', N'Action'),
    (N'Mai 2', N'Drama'),             (N'Mai 2', N'Romance'),
    (N'The Last Laugh', N'Comedy'),
    (N'Silent Shadows', N'Horror'),   (N'Silent Shadows', N'Thriller'),
    (N'Stellar Voyage', N'Sci-Fi'),
    (N'Little Heroes', N'Animation')
) AS x(movie_title, genre_name)
JOIN dbo.movies m ON m.title = x.movie_title
JOIN dbo.genres g ON g.name  = x.genre_name;

-- ---------------------------------------------------------------------
-- 4. Branches
-- ---------------------------------------------------------------------
INSERT INTO dbo.branches (name, address, city, phone, email) VALUES
 (N'MBCMS Nguyen Hue',  N'72 Nguyen Hue, District 1',        N'Ho Chi Minh', '02838111111', 'nguyenhue@mbcms.vn'),
 (N'MBCMS Ba Trieu',    N'25 Ba Trieu, Hoan Kiem',           N'Ha Noi',      '02438222222', 'batrieu@mbcms.vn');

-- ---------------------------------------------------------------------
-- 5. Rooms (capacity 80 = 8 rows x 10 cols, matches seat generation below)
-- ---------------------------------------------------------------------
INSERT INTO dbo.rooms (branch_id, name, capacity, room_type)
SELECT b.branch_id, r.name, 80, r.room_type
FROM dbo.branches b
CROSS JOIN (VALUES
    (N'Room 1', 'STANDARD'),
    (N'Room 2', 'VIP'),
    (N'IMAX Hall', 'IMAX')
) AS r(name, room_type);

-- ---------------------------------------------------------------------
-- 6. Seats - generate 8 rows (A-H) x 10 cols for every room (set-based)
--    Rows G & H = VIP, the rest = STANDARD.
-- ---------------------------------------------------------------------
;WITH rows_cte AS (
    SELECT n AS rn, CHAR(64 + n) AS row_label
    FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8)) AS r(n)
),
cols_cte AS (
    SELECT n AS col_number
    FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS c(n)
)
INSERT INTO dbo.seats (room_id, row_label, col_number, seat_type)
SELECT rm.room_id,
       rc.row_label,
       cc.col_number,
       CASE WHEN rc.rn >= 7 THEN 'VIP' ELSE 'STANDARD' END
FROM dbo.rooms rm
CROSS JOIN rows_cte rc
CROSS JOIN cols_cte cc;

-- ---------------------------------------------------------------------
-- 7. Showtimes (a few per now-showing movie, early June 2026)
-- ---------------------------------------------------------------------
INSERT INTO dbo.showtimes (room_id, movie_id, start_time, end_time, base_price, format, subtitle_type, [status])
SELECT r.room_id,
       mv.movie_id,
       CAST(s.start_time AS DATETIME2),
       DATEADD(MINUTE, mv.duration_min, CAST(s.start_time AS DATETIME2)),
       s.base_price, s.format, s.subtitle_type, 'SCHEDULED'
FROM (VALUES
    (N'MBCMS Nguyen Hue', N'Room 1',    N'Dune: Part Three', '2026-06-05 10:00', CAST(90000  AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'MBCMS Nguyen Hue', N'Room 1',    N'Dune: Part Three', '2026-06-05 14:00', CAST(90000  AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'MBCMS Nguyen Hue', N'IMAX Hall', N'Dune: Part Three', '2026-06-05 19:00', CAST(180000 AS DECIMAL(10,2)), 'IMAX', 'SUB'),
    (N'MBCMS Nguyen Hue', N'Room 2',    N'Mai 2',            '2026-06-05 18:00', CAST(110000 AS DECIMAL(10,2)), '2D',   'ORIGINAL'),
    (N'MBCMS Ba Trieu',   N'Room 1',    N'The Last Laugh',   '2026-06-06 16:00', CAST(85000  AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'MBCMS Ba Trieu',   N'Room 2',    N'Mai 2',            '2026-06-06 20:00', CAST(120000 AS DECIMAL(10,2)), '2D',   'ORIGINAL'),
    -- extra showtimes (spread over several days, for a fuller schedule page)
    (N'MBCMS Nguyen Hue', N'Room 1',    N'Dune: Part Three', '2026-06-05 20:00', CAST(95000  AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'MBCMS Nguyen Hue', N'Room 1',    N'The Last Laugh',   '2026-06-06 10:00', CAST(80000  AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'MBCMS Nguyen Hue', N'IMAX Hall', N'Dune: Part Three', '2026-06-06 19:00', CAST(180000 AS DECIMAL(10,2)), 'IMAX', 'SUB'),
    (N'MBCMS Nguyen Hue', N'Room 2',    N'Mai 2',            '2026-06-06 18:00', CAST(110000 AS DECIMAL(10,2)), '2D',   'ORIGINAL'),
    (N'MBCMS Nguyen Hue', N'Room 1',    N'The Last Laugh',   '2026-06-07 13:00', CAST(80000  AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'MBCMS Ba Trieu',   N'Room 1',    N'The Last Laugh',   '2026-06-07 16:00', CAST(85000  AS DECIMAL(10,2)), '2D',   'SUB'),
    (N'MBCMS Ba Trieu',   N'IMAX Hall', N'Dune: Part Three', '2026-06-07 19:00', CAST(190000 AS DECIMAL(10,2)), 'IMAX', 'SUB'),
    (N'MBCMS Ba Trieu',   N'Room 2',    N'Mai 2',            '2026-06-07 20:00', CAST(120000 AS DECIMAL(10,2)), '2D',   'ORIGINAL')
) AS s(branch_name, room_name, movie_title, start_time, base_price, format, subtitle_type)
JOIN dbo.branches b ON b.name = s.branch_name
JOIN dbo.rooms    r ON r.branch_id = b.branch_id AND r.name = s.room_name
JOIN dbo.movies   mv ON mv.title = s.movie_title;

-- ---------------------------------------------------------------------
-- 8. Customers
-- ---------------------------------------------------------------------
INSERT INTO dbo.customers (username, email, password_hash, full_name, phone, date_of_birth, address, email_verified) VALUES
 ('hungnt',  'hungnt@gmail.com',  @PWD, N'Nguyen Thanh Hung', '0901111111', '2003-06-17', N'Thu Duc, HCM', 1),
 ('trangnt', 'trangnt@gmail.com', @PWD, N'Nguyen Thuy Trang', '0902222222', '2003-01-10', N'Hoan Kiem, HN', 1),
 ('guest01', 'guest01@gmail.com', @PWD, N'Le Van Khach',      '0903333333', '2000-12-25', N'Go Vap, HCM',  0);

-- ---------------------------------------------------------------------
-- 9. Employees (1 admin, 2 managers, 2 staff)
-- ---------------------------------------------------------------------
DECLARE @b1 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Nguyen Hue');
DECLARE @b2 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Ba Trieu');

INSERT INTO dbo.employees (username, email, password_hash, full_name, phone, role, branch_id) VALUES
 ('admin',     'admin@mbcms.vn',     @PWD, N'System Admin',      '0900000000', 'ADMIN',          NULL),
 ('mgr_hcm',   'mgr.hcm@mbcms.vn',   @PWD, N'Pham Quoc Anh',     '0911111111', 'BRANCH_MANAGER',  @b1),
 ('mgr_hn',    'mgr.hn@mbcms.vn',    @PWD, N'Ho Minh Hoang',     '0911222222', 'BRANCH_MANAGER',  @b2),
 ('staff_hcm', 'staff.hcm@mbcms.vn', @PWD, N'Ngo Duc Anh',       '0922111111', 'BRANCH_STAFF',    @b1),
 ('staff_hn',  'staff.hn@mbcms.vn',  @PWD, N'Tran Thi Staff',    '0922222222', 'BRANCH_STAFF',    @b2);

-- ---------------------------------------------------------------------
-- 10. Promotions
-- ---------------------------------------------------------------------
INSERT INTO dbo.promotions (code, name, discount_type, discount_value, min_order_amount, valid_from, valid_to, max_uses) VALUES
 ('WELCOME10',  N'Welcome 10% off',     'PERCENT',      10, NULL,   '2026-05-01', '2026-12-31', NULL),
 ('SUMMER50K',  N'Summer 50,000 off',   'FIXED_AMOUNT', 50000, 200000, '2026-06-01', '2026-08-31', 1000);

-- ---------------------------------------------------------------------
-- 11. Food items
-- ---------------------------------------------------------------------
INSERT INTO dbo.food_items (name, description, price, category) VALUES
 (N'Popcorn (Large)', N'Salted popcorn, large size',   65000,  'SNACK'),
 (N'Popcorn (Medium)',N'Caramel popcorn, medium size', 55000,  'SNACK'),
 (N'Coca-Cola',       N'Soft drink 500ml',             30000,  'DRINK'),
 (N'Mineral Water',   N'Bottled water 500ml',          20000,  'DRINK'),
 (N'Combo for 2',     N'2 drinks + 1 large popcorn',   120000, 'COMBO'),
 (N'Combo Solo',      N'1 drink + 1 medium popcorn',   75000,  'COMBO');

PRINT 'Base data seeded (genres, movies, branches, rooms, seats, showtimes, customers, employees, promotions, food).';
GO

-- ---------------------------------------------------------------------
-- 12. One full demo booking (booking -> seats -> payment -> food order)
--     Customer 'hungnt' books 2 seats for the 10:00 Dune showtime.
-- ---------------------------------------------------------------------
DECLARE @showtime_id BIGINT = (
    SELECT TOP 1 st.showtime_id
    FROM dbo.showtimes st
    JOIN dbo.movies m ON m.movie_id = st.movie_id
    WHERE m.title = N'Dune: Part Three' AND st.start_time = '2026-06-05 10:00'
);
DECLARE @room_id BIGINT = (SELECT room_id FROM dbo.showtimes WHERE showtime_id = @showtime_id);
DECLARE @base DECIMAL(10,2) = (SELECT base_price FROM dbo.showtimes WHERE showtime_id = @showtime_id);

-- Pick 2 seats (A1, A2) in that room
DECLARE @seat1 BIGINT = (SELECT seat_id FROM dbo.seats WHERE room_id = @room_id AND row_label = 'A' AND col_number = 1);
DECLARE @seat2 BIGINT = (SELECT seat_id FROM dbo.seats WHERE room_id = @room_id AND row_label = 'A' AND col_number = 2);

DECLARE @subtotal DECIMAL(10,2) = @base * 2;
DECLARE @discount DECIMAL(10,2) = @subtotal * 0.10;          -- WELCOME10 promo
DECLARE @promo_id BIGINT = (SELECT promo_id FROM dbo.promotions WHERE code = 'WELCOME10');
DECLARE @total DECIMAL(10,2) = @subtotal - @discount;

INSERT INTO dbo.bookings (customer_username, showtime_id, promo_id, booking_code, subtotal, discount_amount, total_amount, [status])
VALUES ('hungnt', @showtime_id, @promo_id, 'BK-000001', @subtotal, @discount, @total, 'CONFIRMED');
DECLARE @booking_id BIGINT = SCOPE_IDENTITY();

INSERT INTO dbo.booking_seats (booking_id, seat_id) VALUES (@booking_id, @seat1), (@booking_id, @seat2);

INSERT INTO dbo.payments (booking_id, method, amount, [status], transaction_ref, paid_at)
VALUES (@booking_id, 'MOMO', @total, 'SUCCESS', 'MOMO-TXN-0001', SYSUTCDATETIME());

UPDATE dbo.promotions SET used_count = used_count + 1 WHERE promo_id = @promo_id;

-- Food order attached to the booking
INSERT INTO dbo.food_orders (booking_id, [status]) VALUES (@booking_id, 'PREPARING');
DECLARE @food_order_id BIGINT = SCOPE_IDENTITY();

INSERT INTO dbo.booking_food_items (food_order_id, food_id, quantity)
SELECT @food_order_id, food_id, 1 FROM dbo.food_items WHERE name = N'Combo for 2';

-- ---------------------------------------------------------------------
-- 13. Notification + feedback samples
-- ---------------------------------------------------------------------
INSERT INTO dbo.notifications (customer_username, title, content, type, reference_id) VALUES
 ('hungnt', N'Booking confirmed', N'Your booking BK-000001 is confirmed. Enjoy the movie!', 'BOOKING', @booking_id);

DECLARE @branch_hcm BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Nguyen Hue');
INSERT INTO dbo.feedbacks (customer_username, branch_id, name, email, subject, message, [status]) VALUES
 ('trangnt', @branch_hcm, N'Nguyen Thuy Trang', 'trangnt@gmail.com', N'Great experience', N'The IMAX hall sound was amazing!', 'NEW'),
 (NULL, NULL, N'Anonymous Guest', 'guest@example.com', N'Website slow', N'The booking page loads slowly on mobile.', 'NEW');

PRINT 'Demo booking + notification + feedback seeded.';
GO

-- ---------------------------------------------------------------------
-- 14. Extra bookings (varied status / branch / payment) for reports.
--     Approach: put each booking definition in a temp table #plan,
--     then resolve IDs and insert via set-based JOINs.
--     Each plan row uses a DISTINCT showtime, so seat picks never collide.
-- ---------------------------------------------------------------------
-- COLLATE DATABASE_DEFAULT: temp tables live in tempdb (Latin1 collation);
-- this forces the DB collation so JOINs to CinemaDB columns don't conflict.
CREATE TABLE #plan (
    booking_code VARCHAR(20)   COLLATE DATABASE_DEFAULT,
    customer     VARCHAR(50)   COLLATE DATABASE_DEFAULT,
    branch_name  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
    room_name    NVARCHAR(50)  COLLATE DATABASE_DEFAULT,
    movie_title  NVARCHAR(200) COLLATE DATABASE_DEFAULT,
    start_time   DATETIME2,
    num_seats    INT,
    [status]     VARCHAR(9)    COLLATE DATABASE_DEFAULT,
    promo_code   VARCHAR(30)   COLLATE DATABASE_DEFAULT NULL,   -- NULL = no promo
    pay_method   VARCHAR(11)   COLLATE DATABASE_DEFAULT NULL,   -- NULL = no payment row (e.g. PENDING booking)
    pay_status   VARCHAR(8)    COLLATE DATABASE_DEFAULT NULL,
    booked_at    DATETIME2           -- explicit date so revenue-by-day has spread
);

INSERT INTO #plan VALUES
 ('BK-000002','trangnt', N'MBCMS Ba Trieu',   N'Room 2',    N'Mai 2',            '2026-06-06 20:00', 2, 'CONFIRMED', 'SUMMER50K', 'VNPAY',       'SUCCESS', '2026-06-04 09:15'),
 ('BK-000003','hungnt',  N'MBCMS Nguyen Hue', N'IMAX Hall', N'Dune: Part Three', '2026-06-05 19:00', 3, 'USED',      NULL,        'CREDIT_CARD', 'SUCCESS', '2026-06-03 20:05'),
 ('BK-000004','guest01', N'MBCMS Nguyen Hue', N'Room 2',    N'Mai 2',            '2026-06-05 18:00', 1, 'CONFIRMED', NULL,        'CASH',        'SUCCESS', '2026-06-05 17:40'),
 ('BK-000005','trangnt', N'MBCMS Ba Trieu',   N'Room 1',    N'The Last Laugh',   '2026-06-06 16:00', 2, 'PENDING',   NULL,        NULL,          NULL,      '2026-06-06 15:50'),
 ('BK-000006','hungnt',  N'MBCMS Nguyen Hue', N'Room 1',    N'Dune: Part Three', '2026-06-05 14:00', 2, 'CANCELLED', NULL,        'MOMO',        'FAILED',  '2026-06-02 11:30');

-- 14a. bookings (resolve showtime_id + promo_id; compute discount/total)
INSERT INTO dbo.bookings
 (customer_username, showtime_id, promo_id, booking_code, subtotal, discount_amount, total_amount, [status], created_at)
SELECT
    p.customer,
    st.showtime_id,
    pr.promo_id,
    p.booking_code,
    st.base_price * p.num_seats AS subtotal,
    CASE
        WHEN pr.discount_type = 'PERCENT'      THEN st.base_price * p.num_seats * pr.discount_value / 100
        WHEN pr.discount_type = 'FIXED_AMOUNT' THEN pr.discount_value
        ELSE 0
    END AS discount_amount,
    st.base_price * p.num_seats -
    CASE
        WHEN pr.discount_type = 'PERCENT'      THEN st.base_price * p.num_seats * pr.discount_value / 100
        WHEN pr.discount_type = 'FIXED_AMOUNT' THEN pr.discount_value
        ELSE 0
    END AS total_amount,
    p.[status],
    p.booked_at
FROM #plan p
JOIN dbo.branches  b  ON b.name = p.branch_name
JOIN dbo.rooms     r  ON r.branch_id = b.branch_id AND r.name = p.room_name
JOIN dbo.movies    mv ON mv.title = p.movie_title
JOIN dbo.showtimes st ON st.room_id = r.room_id AND st.movie_id = mv.movie_id AND st.start_time = p.start_time
LEFT JOIN dbo.promotions pr ON pr.code = p.promo_code;

-- 14b. booking_seats (pick the first N seats of the room; USED => checked in)
INSERT INTO dbo.booking_seats (booking_id, seat_id, is_checked_in, check_in_time)
SELECT bk.booking_id, s.seat_id,
       CASE WHEN bk.[status] = 'USED' THEN 1 ELSE 0 END,
       CASE WHEN bk.[status] = 'USED' THEN bk.created_at ELSE NULL END
FROM dbo.bookings bk
JOIN #plan p        ON p.booking_code = bk.booking_code
JOIN dbo.showtimes st ON st.showtime_id = bk.showtime_id
JOIN (
    SELECT seat_id, room_id,
           ROW_NUMBER() OVER (PARTITION BY room_id ORDER BY row_label, col_number) AS rn
    FROM dbo.seats
) s ON s.room_id = st.room_id AND s.rn <= p.num_seats;

-- 14c. payments (only for plan rows that define a payment method)
INSERT INTO dbo.payments (booking_id, method, amount, [status], transaction_ref, paid_at)
SELECT bk.booking_id, p.pay_method, bk.total_amount, p.pay_status,
       CASE WHEN p.pay_method = 'CASH' THEN NULL
            ELSE p.pay_method + '-TXN-' + RIGHT(bk.booking_code, 6) END,
       CASE WHEN p.pay_status = 'SUCCESS' THEN bk.created_at ELSE NULL END
FROM dbo.bookings bk
JOIN #plan p ON p.booking_code = bk.booking_code
WHERE p.pay_method IS NOT NULL;

-- 14d. one more food order (BK-000003 added popcorn + drinks)
INSERT INTO dbo.food_orders (booking_id, [status], ready_at, delivered_at)
SELECT booking_id, 'DELIVERED', created_at, created_at
FROM dbo.bookings WHERE booking_code = 'BK-000003';

INSERT INTO dbo.booking_food_items (food_order_id, food_id, quantity)
SELECT fo.food_order_id, fi.food_id, q.qty
FROM dbo.food_orders fo
JOIN dbo.bookings b ON b.booking_id = fo.booking_id AND b.booking_code = 'BK-000003'
JOIN (VALUES (N'Popcorn (Large)', 1), (N'Coca-Cola', 3)) AS q(food_name, qty) ON 1 = 1
JOIN dbo.food_items fi ON fi.name = q.food_name;

-- 14e. recompute promotion usage from actual bookings (keeps used_count correct)
UPDATE pr
SET used_count = (SELECT COUNT(*) FROM dbo.bookings b WHERE b.promo_id = pr.promo_id)
FROM dbo.promotions pr;

-- 14f. a couple more notifications
INSERT INTO dbo.notifications (customer_username, title, content, type, reference_id, is_read)
SELECT b.customer_username, N'Payment successful',
       N'Payment for ' + b.booking_code + N' was received. Thank you!', 'PAYMENT', b.booking_id, 0
FROM dbo.bookings b WHERE b.booking_code IN ('BK-000002', 'BK-000003');

DROP TABLE #plan;
PRINT 'Extra bookings seeded (BK-000002..BK-000006).';
GO

-- ---------------------------------------------------------------------
-- Quick verification
-- ---------------------------------------------------------------------
SELECT 'movies' AS tbl, COUNT(*) AS rows FROM dbo.movies
UNION ALL SELECT 'genres', COUNT(*) FROM dbo.genres
UNION ALL SELECT 'branches', COUNT(*) FROM dbo.branches
UNION ALL SELECT 'rooms', COUNT(*) FROM dbo.rooms
UNION ALL SELECT 'seats', COUNT(*) FROM dbo.seats
UNION ALL SELECT 'showtimes', COUNT(*) FROM dbo.showtimes
UNION ALL SELECT 'customers', COUNT(*) FROM dbo.customers
UNION ALL SELECT 'employees', COUNT(*) FROM dbo.employees
UNION ALL SELECT 'bookings', COUNT(*) FROM dbo.bookings
UNION ALL SELECT 'food_items', COUNT(*) FROM dbo.food_items;
GO

-- Sample report 1: revenue by branch (only successful payments)
SELECT b.name AS branch, COUNT(DISTINCT bk.booking_id) AS paid_bookings, SUM(p.amount) AS revenue
FROM dbo.payments p
JOIN dbo.bookings bk  ON bk.booking_id = p.booking_id
JOIN dbo.showtimes st ON st.showtime_id = bk.showtime_id
JOIN dbo.rooms r      ON r.room_id = st.room_id
JOIN dbo.branches b   ON b.branch_id = r.branch_id
WHERE p.[status] = 'SUCCESS'
GROUP BY b.name
ORDER BY revenue DESC;
GO

-- Sample report 2: bookings by status
SELECT [status], COUNT(*) AS cnt FROM dbo.bookings GROUP BY [status] ORDER BY cnt DESC;
GO
