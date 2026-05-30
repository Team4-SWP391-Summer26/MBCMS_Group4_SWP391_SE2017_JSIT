-- =====================================================================
-- CinemaDB - SQL Server DDL (schema only)
-- Project: SWP391 - Multi-Branch Cinema Management System (MBCMS)
-- Source : 01_Database/CinemaDB_final.dbml  (18 tables, 19 FKs, 15 enums)
-- Target : SQL Server 2019+
--
-- HOW TO RUN (SSMS):
--   1. Open this file, press F5 (it creates DB 'CinemaDB' and all tables).
--   2. Then run CinemaDB_seed.sql to load sample data.
--
-- NOTES:
--   - SQL Server has no ENUM type  -> emulated with VARCHAR + CHECK (... IN (...)).
--   - PK increment columns         -> BIGINT/INT IDENTITY(1,1).
--   - Vietnamese text              -> NVARCHAR; DB collation = Vietnamese_CI_AS.
--   - Re-runnable: drops tables in reverse FK order before creating.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Database
-- ---------------------------------------------------------------------
IF DB_ID('CinemaDB') IS NULL
    CREATE DATABASE CinemaDB COLLATE Vietnamese_CI_AS;
GO

USE CinemaDB;
GO

-- ---------------------------------------------------------------------
-- 1. Drop existing tables (reverse dependency order) - for re-runs
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.booking_food_items', 'U') IS NOT NULL DROP TABLE dbo.booking_food_items;
IF OBJECT_ID('dbo.food_orders',        'U') IS NOT NULL DROP TABLE dbo.food_orders;
IF OBJECT_ID('dbo.food_items',         'U') IS NOT NULL DROP TABLE dbo.food_items;
IF OBJECT_ID('dbo.payments',           'U') IS NOT NULL DROP TABLE dbo.payments;
IF OBJECT_ID('dbo.booking_seats',      'U') IS NOT NULL DROP TABLE dbo.booking_seats;
IF OBJECT_ID('dbo.bookings',           'U') IS NOT NULL DROP TABLE dbo.bookings;
IF OBJECT_ID('dbo.notifications',      'U') IS NOT NULL DROP TABLE dbo.notifications;
IF OBJECT_ID('dbo.feedbacks',          'U') IS NOT NULL DROP TABLE dbo.feedbacks;
IF OBJECT_ID('dbo.promotions',         'U') IS NOT NULL DROP TABLE dbo.promotions;
IF OBJECT_ID('dbo.employees',          'U') IS NOT NULL DROP TABLE dbo.employees;
IF OBJECT_ID('dbo.customers',          'U') IS NOT NULL DROP TABLE dbo.customers;
IF OBJECT_ID('dbo.showtimes',          'U') IS NOT NULL DROP TABLE dbo.showtimes;
IF OBJECT_ID('dbo.seats',              'U') IS NOT NULL DROP TABLE dbo.seats;
IF OBJECT_ID('dbo.rooms',              'U') IS NOT NULL DROP TABLE dbo.rooms;
IF OBJECT_ID('dbo.branches',           'U') IS NOT NULL DROP TABLE dbo.branches;
IF OBJECT_ID('dbo.movie_genres',       'U') IS NOT NULL DROP TABLE dbo.movie_genres;
IF OBJECT_ID('dbo.genres',             'U') IS NOT NULL DROP TABLE dbo.genres;
IF OBJECT_ID('dbo.movies',             'U') IS NOT NULL DROP TABLE dbo.movies;
GO

-- =====================================================================
-- GROUP 01 - MOVIE CATALOG
-- =====================================================================
CREATE TABLE dbo.movies (
    movie_id     BIGINT         IDENTITY(1,1) NOT NULL,
    title        NVARCHAR(200)  NOT NULL,
    description  NVARCHAR(2000) NULL,
    duration_min INT            NOT NULL,
    director     NVARCHAR(100)  NULL,
    cast_list    NVARCHAR(500)  NULL,                 -- renamed from "cast" (reserved word)
    [language]   VARCHAR(50)    NULL,
    country      VARCHAR(50)    NULL,
    rated        VARCHAR(3)     NULL,
    poster_url   VARCHAR(500)   NULL,
    trailer_url  VARCHAR(500)   NULL,
    release_date DATE           NULL,
    [status]     VARCHAR(11)    NOT NULL,
    active       BIT            NOT NULL CONSTRAINT DF_movies_active DEFAULT (1),
    CONSTRAINT PK_movies PRIMARY KEY (movie_id),
    CONSTRAINT CK_movies_duration CHECK (duration_min > 0),
    CONSTRAINT CK_movies_rated    CHECK (rated IS NULL OR rated IN ('P','C13','C16','C18')),
    CONSTRAINT CK_movies_status   CHECK ([status] IN ('UPCOMING','NOW_SHOWING','ENDED'))
);
GO

CREATE TABLE dbo.genres (
    genre_id INT          IDENTITY(1,1) NOT NULL,
    name     NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_genres PRIMARY KEY (genre_id),
    CONSTRAINT UQ_genres_name UNIQUE (name)
);
GO

CREATE TABLE dbo.movie_genres (
    movie_id BIGINT NOT NULL,
    genre_id INT    NOT NULL,
    CONSTRAINT PK_movie_genres PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT FK_movie_genres_movie FOREIGN KEY (movie_id)
        REFERENCES dbo.movies (movie_id) ON DELETE CASCADE,
    CONSTRAINT FK_movie_genres_genre FOREIGN KEY (genre_id)
        REFERENCES dbo.genres (genre_id)            -- NO cascade: deleting an in-use genre is blocked
);
GO
CREATE INDEX IX_movie_genres_genre ON dbo.movie_genres (genre_id);
GO

-- =====================================================================
-- GROUP 02 - BRANCH & SCHEDULING
-- =====================================================================
CREATE TABLE dbo.branches (
    branch_id  BIGINT        IDENTITY(1,1) NOT NULL,
    name       NVARCHAR(100) NOT NULL,
    address    NVARCHAR(255) NOT NULL,
    city       NVARCHAR(50)  NOT NULL,
    phone      VARCHAR(20)   NULL,
    email      VARCHAR(150)  NULL,
    active     BIT           NOT NULL CONSTRAINT DF_branches_active DEFAULT (1),
    created_at DATETIME2     NOT NULL CONSTRAINT DF_branches_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_branches PRIMARY KEY (branch_id)
);
GO

CREATE TABLE dbo.rooms (
    room_id   BIGINT       IDENTITY(1,1) NOT NULL,
    branch_id BIGINT       NOT NULL,
    name      NVARCHAR(50) NOT NULL,
    capacity  INT          NOT NULL,
    room_type VARCHAR(8)   NOT NULL,
    active    BIT          NOT NULL CONSTRAINT DF_rooms_active DEFAULT (1),
    CONSTRAINT PK_rooms PRIMARY KEY (room_id),
    CONSTRAINT FK_rooms_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id),
    CONSTRAINT CK_rooms_capacity CHECK (capacity > 0),
    CONSTRAINT CK_rooms_type     CHECK (room_type IN ('STANDARD','VIP','IMAX'))
);
GO
CREATE INDEX IX_rooms_branch ON dbo.rooms (branch_id);
GO

CREATE TABLE dbo.seats (
    seat_id    BIGINT     IDENTITY(1,1) NOT NULL,
    room_id    BIGINT     NOT NULL,
    row_label  VARCHAR(5) NOT NULL,
    col_number INT        NOT NULL,
    seat_type  VARCHAR(8) NOT NULL,
    active     BIT        NOT NULL CONSTRAINT DF_seats_active DEFAULT (1),
    CONSTRAINT PK_seats PRIMARY KEY (seat_id),
    CONSTRAINT FK_seats_room FOREIGN KEY (room_id) REFERENCES dbo.rooms (room_id),
    CONSTRAINT UQ_seats_position UNIQUE (room_id, row_label, col_number),
    CONSTRAINT CK_seats_col  CHECK (col_number > 0),
    CONSTRAINT CK_seats_type CHECK (seat_type IN ('STANDARD','VIP','COUPLE'))
);
GO
CREATE INDEX IX_seats_room ON dbo.seats (room_id);
GO

CREATE TABLE dbo.showtimes (
    showtime_id   BIGINT        IDENTITY(1,1) NOT NULL,
    room_id       BIGINT        NOT NULL,
    movie_id      BIGINT        NOT NULL,
    start_time    DATETIME2     NOT NULL,
    end_time      DATETIME2     NOT NULL,
    base_price    DECIMAL(10,2) NOT NULL,
    format        VARCHAR(4)    NOT NULL,
    subtitle_type VARCHAR(8)    NOT NULL,
    [status]      VARCHAR(9)    NOT NULL,
    CONSTRAINT PK_showtimes PRIMARY KEY (showtime_id),
    CONSTRAINT FK_showtimes_room  FOREIGN KEY (room_id)  REFERENCES dbo.rooms (room_id),
    CONSTRAINT FK_showtimes_movie FOREIGN KEY (movie_id) REFERENCES dbo.movies (movie_id),
    CONSTRAINT UQ_showtimes_room_start UNIQUE (room_id, start_time),
    CONSTRAINT CK_showtimes_time     CHECK (end_time > start_time),
    CONSTRAINT CK_showtimes_price    CHECK (base_price > 0),
    CONSTRAINT CK_showtimes_format   CHECK (format IN ('2D','3D','IMAX')),
    CONSTRAINT CK_showtimes_subtitle CHECK (subtitle_type IN ('SUB','DUB','ORIGINAL')),
    CONSTRAINT CK_showtimes_status   CHECK ([status] IN ('SCHEDULED','CANCELLED','ENDED'))
);
GO
CREATE INDEX IX_showtimes_room  ON dbo.showtimes (room_id);
CREATE INDEX IX_showtimes_movie ON dbo.showtimes (movie_id);
CREATE INDEX IX_showtimes_start ON dbo.showtimes (start_time);
GO

-- =====================================================================
-- GROUP 03 - BOOKING & PAYMENT
-- =====================================================================
CREATE TABLE dbo.customers (
    username       VARCHAR(50)   NOT NULL,           -- natural PK
    email          VARCHAR(150)  NOT NULL,
    password_hash  VARCHAR(255)  NOT NULL,           -- bcrypt, work factor 10
    full_name      NVARCHAR(100) NOT NULL,
    phone          VARCHAR(20)   NULL,
    date_of_birth  DATE          NULL,
    address        NVARCHAR(255) NULL,
    active         BIT           NOT NULL CONSTRAINT DF_customers_active DEFAULT (1),
    email_verified BIT           NOT NULL CONSTRAINT DF_customers_verified DEFAULT (0),
    reset_token    VARCHAR(255)  NULL,
    created_at     DATETIME2     NOT NULL CONSTRAINT DF_customers_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_customers PRIMARY KEY (username),
    CONSTRAINT UQ_customers_email UNIQUE (email)
);
GO

CREATE TABLE dbo.promotions (
    promo_id         BIGINT        IDENTITY(1,1) NOT NULL,
    code             VARCHAR(30)   NOT NULL,
    name             NVARCHAR(150) NOT NULL,
    discount_type    VARCHAR(12)   NOT NULL,
    discount_value   DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) NULL,             -- NULL = no minimum
    valid_from       DATETIME2     NOT NULL,
    valid_to         DATETIME2     NOT NULL,
    max_uses         INT           NULL,             -- NULL = unlimited
    used_count       INT           NOT NULL CONSTRAINT DF_promotions_used DEFAULT (0),
    active           BIT           NOT NULL CONSTRAINT DF_promotions_active DEFAULT (1),
    CONSTRAINT PK_promotions PRIMARY KEY (promo_id),
    CONSTRAINT UQ_promotions_code UNIQUE (code),
    CONSTRAINT CK_promotions_value CHECK (discount_value > 0),
    CONSTRAINT CK_promotions_dates CHECK (valid_to > valid_from),
    CONSTRAINT CK_promotions_type  CHECK (discount_type IN ('PERCENT','FIXED_AMOUNT'))
);
GO

CREATE TABLE dbo.bookings (
    booking_id        BIGINT        IDENTITY(1,1) NOT NULL,
    customer_username VARCHAR(50)   NOT NULL,
    showtime_id       BIGINT        NOT NULL,
    promo_id          BIGINT        NULL,
    booking_code      VARCHAR(20)   NOT NULL,        -- e.g. BK-000001
    subtotal          DECIMAL(10,2) NOT NULL,
    discount_amount   DECIMAL(10,2) NOT NULL CONSTRAINT DF_bookings_discount DEFAULT (0),
    total_amount      DECIMAL(10,2) NOT NULL,        -- = subtotal - discount_amount
    [status]          VARCHAR(9)    NOT NULL,
    notes             NVARCHAR(500) NULL,
    created_at        DATETIME2     NOT NULL CONSTRAINT DF_bookings_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_bookings PRIMARY KEY (booking_id),
    CONSTRAINT UQ_bookings_code UNIQUE (booking_code),
    CONSTRAINT FK_bookings_customer FOREIGN KEY (customer_username) REFERENCES dbo.customers (username),
    CONSTRAINT FK_bookings_showtime FOREIGN KEY (showtime_id)       REFERENCES dbo.showtimes (showtime_id),
    CONSTRAINT FK_bookings_promo    FOREIGN KEY (promo_id)          REFERENCES dbo.promotions (promo_id),
    CONSTRAINT CK_bookings_subtotal CHECK (subtotal >= 0),
    CONSTRAINT CK_bookings_discount CHECK (discount_amount >= 0),
    CONSTRAINT CK_bookings_total    CHECK (total_amount >= 0),
    CONSTRAINT CK_bookings_status   CHECK ([status] IN ('PENDING','CONFIRMED','USED','CANCELLED'))
);
GO
CREATE INDEX IX_bookings_customer ON dbo.bookings (customer_username);
CREATE INDEX IX_bookings_showtime ON dbo.bookings (showtime_id);
CREATE INDEX IX_bookings_promo    ON dbo.bookings (promo_id);
CREATE INDEX IX_bookings_status   ON dbo.bookings ([status]);
CREATE INDEX IX_bookings_created  ON dbo.bookings (created_at);
GO

CREATE TABLE dbo.booking_seats (
    booking_id BIGINT NOT NULL,
    seat_id    BIGINT NOT NULL,
    is_checked_in BIT     NOT NULL CONSTRAINT DF_booking_seats_checkin DEFAULT (0),
    check_in_time DATETIME2 NULL,
    CONSTRAINT PK_booking_seats PRIMARY KEY (booking_id, seat_id),
    CONSTRAINT FK_booking_seats_booking FOREIGN KEY (booking_id)
        REFERENCES dbo.bookings (booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_booking_seats_seat FOREIGN KEY (seat_id)
        REFERENCES dbo.seats (seat_id)
);
GO
CREATE INDEX IX_booking_seats_seat ON dbo.booking_seats (seat_id);
GO

CREATE TABLE dbo.payments (
    payment_id      BIGINT        IDENTITY(1,1) NOT NULL,
    booking_id      BIGINT        NOT NULL,
    method          VARCHAR(11)   NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    [status]        VARCHAR(8)    NOT NULL,
    transaction_ref VARCHAR(100)  NULL,              -- NULL for CASH
    paid_at         DATETIME2     NULL,              -- NULL until status = SUCCESS
    CONSTRAINT PK_payments PRIMARY KEY (payment_id),
    CONSTRAINT UQ_payments_booking UNIQUE (booking_id),   -- enforces 1:1
    CONSTRAINT FK_payments_booking FOREIGN KEY (booking_id)
        REFERENCES dbo.bookings (booking_id) ON DELETE CASCADE,
    CONSTRAINT CK_payments_amount CHECK (amount >= 0),
    CONSTRAINT CK_payments_method CHECK (method IN ('CASH','MOMO','VNPAY','CREDIT_CARD')),
    CONSTRAINT CK_payments_status CHECK ([status] IN ('PENDING','SUCCESS','FAILED','REFUNDED'))
);
GO

-- =====================================================================
-- GROUP 04 - FOOD ORDERING
-- =====================================================================
CREATE TABLE dbo.food_items (
    food_id     BIGINT        IDENTITY(1,1) NOT NULL,
    name        NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,
    price       DECIMAL(10,2) NOT NULL,
    category    VARCHAR(5)    NOT NULL,
    image_url   VARCHAR(500)  NULL,
    active      BIT           NOT NULL CONSTRAINT DF_food_items_active DEFAULT (1),
    CONSTRAINT PK_food_items PRIMARY KEY (food_id),
    CONSTRAINT CK_food_items_price    CHECK (price >= 0),
    CONSTRAINT CK_food_items_category CHECK (category IN ('SNACK','DRINK','COMBO'))
);
GO

CREATE TABLE dbo.food_orders (
    food_order_id BIGINT    IDENTITY(1,1) NOT NULL,
    booking_id    BIGINT    NOT NULL,
    [status]      VARCHAR(9) NOT NULL CONSTRAINT DF_food_orders_status DEFAULT ('PENDING'),
    created_at    DATETIME2 NOT NULL CONSTRAINT DF_food_orders_created DEFAULT (SYSUTCDATETIME()),
    ready_at      DATETIME2 NULL,
    delivered_at  DATETIME2 NULL,
    CONSTRAINT PK_food_orders PRIMARY KEY (food_order_id),
    CONSTRAINT UQ_food_orders_booking UNIQUE (booking_id),    -- enforces 1:0..1
    CONSTRAINT FK_food_orders_booking FOREIGN KEY (booking_id)
        REFERENCES dbo.bookings (booking_id) ON DELETE CASCADE,
    CONSTRAINT CK_food_orders_status CHECK ([status] IN ('PENDING','PREPARING','READY','DELIVERED'))
);
GO

CREATE TABLE dbo.booking_food_items (
    food_order_id BIGINT NOT NULL,
    food_id       BIGINT NOT NULL,
    quantity      INT    NOT NULL CONSTRAINT DF_bfi_quantity DEFAULT (1),
    CONSTRAINT PK_booking_food_items PRIMARY KEY (food_order_id, food_id),
    CONSTRAINT FK_bfi_order FOREIGN KEY (food_order_id)
        REFERENCES dbo.food_orders (food_order_id) ON DELETE CASCADE,
    CONSTRAINT FK_bfi_food FOREIGN KEY (food_id)
        REFERENCES dbo.food_items (food_id),
    CONSTRAINT CK_bfi_quantity CHECK (quantity > 0)
);
GO
CREATE INDEX IX_booking_food_items_food ON dbo.booking_food_items (food_id);
GO

-- =====================================================================
-- GROUP 05 - STAFF & SUPPORT
-- =====================================================================
CREATE TABLE dbo.employees (
    username      VARCHAR(50)   NOT NULL,            -- natural PK
    email         VARCHAR(150)  NOT NULL,
    password_hash VARCHAR(255)  NOT NULL,
    full_name     NVARCHAR(100) NOT NULL,
    phone         VARCHAR(20)   NULL,
    role          VARCHAR(14)   NOT NULL,
    branch_id     BIGINT        NULL,                -- NULL only when role = ADMIN
    active        BIT           NOT NULL CONSTRAINT DF_employees_active DEFAULT (1),
    created_at    DATETIME2     NOT NULL CONSTRAINT DF_employees_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_employees PRIMARY KEY (username),
    CONSTRAINT UQ_employees_email UNIQUE (email),
    CONSTRAINT FK_employees_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches (branch_id),
    CONSTRAINT CK_employees_role CHECK (role IN ('ADMIN','BRANCH_MANAGER','BRANCH_STAFF')),
    -- business rule: ADMIN has no branch; managers/staff must have one
    CONSTRAINT CK_employees_branch CHECK (
        (role = 'ADMIN' AND branch_id IS NULL)
        OR (role IN ('BRANCH_MANAGER','BRANCH_STAFF') AND branch_id IS NOT NULL)
    )
);
GO
CREATE INDEX IX_employees_branch ON dbo.employees (branch_id);
GO

CREATE TABLE dbo.notifications (
    noti_id           BIGINT         IDENTITY(1,1) NOT NULL,
    customer_username VARCHAR(50)    NOT NULL,
    title             NVARCHAR(150)  NOT NULL,
    content           NVARCHAR(1000) NOT NULL,
    type              VARCHAR(9)     NOT NULL,
    is_read           BIT            NOT NULL CONSTRAINT DF_notifications_read DEFAULT (0),
    reference_id      BIGINT         NULL,           -- loose ref, no FK
    created_at        DATETIME2      NOT NULL CONSTRAINT DF_notifications_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_notifications PRIMARY KEY (noti_id),
    CONSTRAINT FK_notifications_customer FOREIGN KEY (customer_username)
        REFERENCES dbo.customers (username) ON DELETE CASCADE,
    CONSTRAINT CK_notifications_type CHECK (type IN ('BOOKING','PAYMENT','PROMOTION','REMINDER','SYSTEM'))
);
GO
CREATE INDEX IX_notifications_customer ON dbo.notifications (customer_username);
-- filtered index: only unread rows (DBML note)
CREATE INDEX IX_notifications_unread ON dbo.notifications (customer_username) WHERE is_read = 0;
GO

CREATE TABLE dbo.feedbacks (
    feedback_id       BIGINT         IDENTITY(1,1) NOT NULL,
    customer_username VARCHAR(50)    NULL,          -- NULL for Guest submissions
    branch_id         BIGINT         NULL,          -- NULL for system-wide complaints
    name              NVARCHAR(100)  NOT NULL,
    email             VARCHAR(150)   NOT NULL,
    subject           NVARCHAR(150)  NOT NULL,
    message           NVARCHAR(2000) NOT NULL,
    [status]          VARCHAR(11)    NOT NULL CONSTRAINT DF_feedbacks_status DEFAULT ('NEW'),
    response          NVARCHAR(2000) NULL,
    created_at        DATETIME2      NOT NULL CONSTRAINT DF_feedbacks_created DEFAULT (SYSUTCDATETIME()),
    resolved_at       DATETIME2      NULL,
    CONSTRAINT PK_feedbacks PRIMARY KEY (feedback_id),
    CONSTRAINT FK_feedbacks_customer FOREIGN KEY (customer_username)
        REFERENCES dbo.customers (username) ON DELETE SET NULL,
    CONSTRAINT FK_feedbacks_branch FOREIGN KEY (branch_id)
        REFERENCES dbo.branches (branch_id),
    CONSTRAINT CK_feedbacks_status CHECK ([status] IN ('NEW','IN_PROGRESS','RESOLVED','CLOSED'))
);
GO
CREATE INDEX IX_feedbacks_customer ON dbo.feedbacks (customer_username);
CREATE INDEX IX_feedbacks_branch   ON dbo.feedbacks (branch_id);
CREATE INDEX IX_feedbacks_status   ON dbo.feedbacks ([status]);
GO

PRINT 'CinemaDB schema created: 18 tables.';
GO
