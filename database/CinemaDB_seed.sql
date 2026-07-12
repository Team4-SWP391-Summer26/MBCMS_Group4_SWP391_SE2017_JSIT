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
DELETE FROM dbo.system_settings;
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
DELETE FROM dbo.movie_branch;
DELETE FROM dbo.food_items;
DELETE FROM dbo.promotions;
DELETE FROM dbo.employees;
DELETE FROM dbo.customers;
DELETE FROM dbo.branches;
DELETE FROM dbo.movies;
DELETE FROM dbo.genres;
GO

-- jBCrypt (org.mindrot) work-factor 10 hash for plaintext "password"
DECLARE @PWD VARCHAR(255) = '$2a$10$Kn8sOp1I8w/yOkiFnuyMLuvefMvn9ljUeUbfFTSnrwRygVe3Lwuju';

-- ---------------------------------------------------------------------
-- 0. system_settings (Admin Settings defaults — editable via /admin/settings)
-- ---------------------------------------------------------------------
INSERT INTO dbo.system_settings (setting_key, setting_value, description) VALUES
 (N'vip_surcharge_percent', N'30', N'VIP seat surcharge percent over showtime base price'),
 (N'max_seats_per_booking', N'8',  N'Maximum seats allowed in one booking'),
 (N'pending_hold_minutes',  N'10', N'Minutes a PENDING booking holds seats before auto-expire'),
 (N'showtime_gap_minutes',  N'30', N'Minimum cleaning gap (minutes) between showtimes in the same room');

-- NOTE: no GO here — @PWD must stay in the same batch through customers/employees below.

-- ---------------------------------------------------------------------
-- 1. Genres
-- ---------------------------------------------------------------------
INSERT INTO dbo.genres (name) VALUES
 (N'Action'), (N'Comedy'), (N'Drama'), (N'Horror'),
 (N'Sci-Fi'), (N'Animation'), (N'Romance'), (N'Thriller'),
 (N'Adventure'), (N'Family');

-- ---------------------------------------------------------------------
-- 2. Movies — phim that (TMDB), poster local /assets/img/posters/*
-- ---------------------------------------------------------------------
INSERT INTO dbo.movies
 (title, description, duration_min, director, cast_list, [language], country, rated, poster_url, trailer_url, release_date, [status])
VALUES
 (N'Dune: Part Two',
  N'Paul Atreides unites with Chani and the Fremen while seeking revenge against those who destroyed his family.',
  166, N'Denis Villeneuve', N'Timothee Chalamet, Zendaya, Rebecca Ferguson',
  'English', 'USA', 'C13', N'/assets/img/posters/dune-part-two.jpg',
  N'https://www.youtube.com/watch?v=Way9Dexny3w',
  CAST(DATEADD(DAY, -30, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Mai',
  N'A 37-year-old massage therapist with a painful past finds her life changed by a younger man who pursues her.',
  131, N'Tran Thanh', N'Phuong Anh Dao, Tuan Tran, Uyen An',
  'Vietnamese', 'Vietnam', 'C16', N'/assets/img/posters/mai.jpg',
  N'https://www.youtube.com/watch?v=HXWRTGbhb4U',
  CAST(DATEADD(DAY, -45, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Inside Out 2',
  N'Teenager Riley faces new Emotions as Anxiety arrives at headquarters — and she is not alone.',
  96, N'Kelsey Mann', N'Amy Poehler, Maya Hawke, Kensington Tallman',
  'English', 'USA', 'P', N'/assets/img/posters/inside-out-2.jpg',
  N'https://www.youtube.com/watch?v=LEjhY15eCx0',
  CAST(DATEADD(DAY, -14, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Deadpool & Wolverine',
  N'Wade Wilson suits up again with a reluctant Wolverine when his world faces an existential threat.',
  128, N'Shawn Levy', N'Ryan Reynolds, Hugh Jackman, Emma Corrin',
  'English', 'USA', 'C18', N'/assets/img/posters/deadpool-wolverine.jpg',
  N'https://www.youtube.com/watch?v=73_1biulkYk',
  CAST(DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Furiosa: A Mad Max Saga',
  N'Young Furiosa is taken from the Green Place and must survive the wasteland to find her way home.',
  148, N'George Miller', N'Anya Taylor-Joy, Chris Hemsworth, Tom Burke',
  'English', 'Australia', 'C16', N'/assets/img/posters/furiosa.jpg',
  N'https://www.youtube.com/watch?v=XJMuhwVlca4',
  CAST(DATEADD(DAY, -10, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Wicked',
  N'Elphaba and Glinda form an unlikely friendship at Shiz University before becoming the Wicked Witch and Glinda the Good.',
  160, N'Jon M. Chu', N'Cynthia Erivo, Ariana Grande, Jonathan Bailey',
  'English', 'USA', 'P', N'/assets/img/posters/wicked.jpg',
  N'https://www.youtube.com/watch?v=6COmYeLsz4c',
  CAST(DATEADD(DAY, -5, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Despicable Me 4',
  N'Gru and Lucy welcome Gru Jr. while facing a new nemesis, Maxime Le Mal, forcing the family on the run.',
  94, N'Chris Renaud', N'Steve Carell, Kristen Wiig, Will Ferrell',
  'English', 'USA', 'P', N'/assets/img/posters/despicable-me-4.jpg',
  N'https://www.youtube.com/watch?v=qQlr9-rF32A',
  CAST(DATEADD(DAY, -20, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Lật Mặt 6: Tấm Vé Định Mệnh',
  N'Friends win the lottery jackpot, but the ticket holder dies — and the group must decide what to do next.',
  132, N'Ly Hai', N'Ly Hai, Quoc Khanh, Minh Du',
  'Vietnamese', 'Vietnam', 'C13', N'/assets/img/posters/lat-mat-6.jpg',
  N'https://www.youtube.com/watch?v=L-XhraxUsAs',
  CAST(DATEADD(DAY, -12, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Godzilla x Kong: The New Empire',
  N'Godzilla and Kong reunite against a colossal threat hidden within our world.',
  115, N'Adam Wingard', N'Rebecca Hall, Brian Tyree Henry, Dan Stevens',
  'English', 'USA', 'C13', N'/assets/img/posters/godzilla-x-kong.jpg',
  N'https://www.youtube.com/watch?v=qqrpMRDuPfc',
  CAST(DATEADD(DAY, 21, CAST(GETDATE() AS DATE)) AS DATE), 'UPCOMING'),
 (N'Kung Fu Panda 4',
  N'Po trains a new Dragon Warrior while facing the Chameleon, who conjures villains from the past.',
  94, N'Mike Mitchell', N'Jack Black, Awkwafina, Viola Davis',
  'English', 'USA', 'P', N'/assets/img/posters/kung-fu-panda-4.jpg',
  N'https://www.youtube.com/watch?v=_inKs4eeHiI',
  CAST(DATEADD(DAY, 14, CAST(GETDATE() AS DATE)) AS DATE), 'UPCOMING'),
 (N'A Quiet Place: Day One',
  N'As New York is invaded by sound-hunting creatures, Sam fights to survive with her cat.',
  99, N'Michael Sarnoski', N'Lupita Nyong''o, Joseph Quinn, Djimon Hounsou',
  'English', 'USA', 'C16', N'/assets/img/posters/quiet-place-day-one.jpg',
  N'https://www.youtube.com/watch?v=YPY7J-flzE8',
  CAST(DATEADD(DAY, 28, CAST(GETDATE() AS DATE)) AS DATE), 'UPCOMING'),
 (N'Oppenheimer',
  N'The story of J. Robert Oppenheimer and the development of the atomic bomb during World War II.',
  180, N'Christopher Nolan', N'Cillian Murphy, Emily Blunt, Robert Downey Jr.',
  'English', 'USA', 'C16', N'/assets/img/posters/oppenheimer.jpg',
  N'https://www.youtube.com/watch?v=uYPbbksJxIg',
  CAST(DATEADD(DAY, -120, CAST(GETDATE() AS DATE)) AS DATE), 'ENDED'),
 (N'Barbie',
  N'Barbie and Ken leave Barbie Land for the real world and discover the joys and perils of living among humans.',
  114, N'Greta Gerwig', N'Margot Robbie, Ryan Gosling, America Ferrera',
  'English', 'USA', 'P', N'/assets/img/posters/barbie.jpg',
  N'https://www.youtube.com/watch?v=pBk4NYhWNMM',
  CAST(DATEADD(DAY, -200, CAST(GETDATE() AS DATE)) AS DATE), 'ENDED'),
 (N'Tro Tàn Rực Rỡ',
  N'Three women in a Mekong Delta village navigate unusual love lives in Glorious Ashes (Tro Tàn Rực Rỡ).',
  128, N'Bui Thac Chuyen', N'Phuong Anh Dao, Le Cong Hoang, NSND Le Khanh',
  'Vietnamese', 'Vietnam', 'C16', N'/assets/img/posters/glorious-ashes.jpg',
  N'https://www.youtube.com/watch?v=If7oCdc4LXY',
  CAST(DATEADD(DAY, -180, CAST(GETDATE() AS DATE)) AS DATE), 'ENDED'),
 -- Batch 2 — more real titles (TMDB posters under /assets/img/posters/)
 (N'Moana 2',
  N'After an unexpected call from her ancestors, Moana journeys with Maui into dangerous, long-lost waters.',
  100, N'Dana Ledoux Miller', N'Auli''i Cravalho, Dwayne Johnson, Hualalai Chung',
  'English', 'USA', 'P', N'/assets/img/posters/moana-2.jpg',
  N'https://www.youtube.com/watch?v=hDZ7y8RP5HE',
  CAST(DATEADD(DAY, -18, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Venom: The Last Dance',
  N'Eddie and Venom are on the run, forced into a devastating decision that ends their last dance.',
  109, N'Kelly Marcel', N'Tom Hardy, Chiwetel Ejiofor, Juno Temple',
  'English', 'USA', 'C16', N'/assets/img/posters/venom-last-dance.jpg',
  N'https://www.youtube.com/watch?v=__2bjWbetsA',
  CAST(DATEADD(DAY, -22, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Gladiator II',
  N'Years after Maximus, Lucius must enter the Colosseum and fight to restore glory to Rome.',
  148, N'Ridley Scott', N'Paul Mescal, Pedro Pascal, Denzel Washington',
  'English', 'USA', 'C16', N'/assets/img/posters/gladiator-2.jpg',
  N'https://www.youtube.com/watch?v=4rgYUipGJNo',
  CAST(DATEADD(DAY, -16, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Twisters',
  N'Former storm chaser Kate and social-media star Tyler collide as unprecedented storms hit Oklahoma.',
  123, N'Lee Isaac Chung', N'Daisy Edgar-Jones, Glen Powell, Anthony Ramos',
  'English', 'USA', 'C13', N'/assets/img/posters/twisters.jpg',
  N'https://www.youtube.com/watch?v=wdok0rZdmx4',
  CAST(DATEADD(DAY, -25, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Bad Boys: Ride or Die',
  N'After their late captain is framed, Lowrey and Burnett try to clear his name — and end up on the run.',
  116, N'Adil El Arbi', N'Will Smith, Martin Lawrence, Vanessa Hudgens',
  'English', 'USA', 'C16', N'/assets/img/posters/bad-boys-ride-or-die.jpg',
  N'https://www.youtube.com/watch?v=hRFY_Fesa9Q',
  CAST(DATEADD(DAY, -28, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'The Wild Robot',
  N'Shipwrecked robot Roz bonds with island animals and raises an orphaned goose to survive.',
  102, N'Chris Sanders', N'Lupita Nyong''o, Pedro Pascal, Kit Connor',
  'English', 'USA', 'P', N'/assets/img/posters/the-wild-robot.jpg',
  N'https://www.youtube.com/watch?v=67vbA5ZJdKQ',
  CAST(DATEADD(DAY, -15, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Beetlejuice Beetlejuice',
  N'Three generations of the Deetz family return home; Astrid accidentally opens a portal to the Afterlife.',
  105, N'Tim Burton', N'Michael Keaton, Winona Ryder, Jenna Ortega',
  'English', 'USA', 'C13', N'/assets/img/posters/beetlejuice-beetlejuice.jpg',
  N'https://www.youtube.com/watch?v=CoZqL9N6Rx4',
  CAST(DATEADD(DAY, -11, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Em và Trịnh',
  N'The life of musician Trinh Cong Son and the muses who shaped his songs across decades.',
  136, N'Phan Gia Nhat Linh', N'Avin Lu, Tran Nghia, Lan Ngoc',
  'Vietnamese', 'Vietnam', 'C13', N'/assets/img/posters/em-va-trinh.jpg',
  N'https://www.youtube.com/watch?v=IosqnBOkk2I',
  CAST(DATEADD(DAY, -9, CAST(GETDATE() AS DATE)) AS DATE), 'NOW_SHOWING'),
 (N'Sonic the Hedgehog 3',
  N'Sonic, Knuckles and Tails face Shadow, a powerful new adversary threatening the planet.',
  110, N'Jeff Fowler', N'Ben Schwartz, Jim Carrey, Keanu Reeves',
  'English', 'USA', 'P', N'/assets/img/posters/sonic-3.jpg',
  N'https://www.youtube.com/watch?v=qSu6i2iFMO0',
  CAST(DATEADD(DAY, 10, CAST(GETDATE() AS DATE)) AS DATE), 'UPCOMING'),
 (N'Mufasa: The Lion King',
  N'Orphaned cub Mufasa meets Taka; together they search for destiny and a royal bloodline.',
  118, N'Barry Jenkins', N'Aaron Pierre, Kelvin Harrison Jr., John Kani',
  'English', 'USA', 'P', N'/assets/img/posters/mufasa.jpg',
  N'https://www.youtube.com/watch?v=o17MF9vnabg',
  CAST(DATEADD(DAY, 17, CAST(GETDATE() AS DATE)) AS DATE), 'UPCOMING'),
 (N'Alien: Romulus',
  N'Young space colonizers scavenging a derelict station face the most terrifying life form in the universe.',
  119, N'Fede Alvarez', N'Cailee Spaeny, David Jonsson, Archie Renaux',
  'English', 'USA', 'C18', N'/assets/img/posters/alien-romulus.jpg',
  N'https://www.youtube.com/watch?v=OzY2r2JXsDM',
  CAST(DATEADD(DAY, -150, CAST(GETDATE() AS DATE)) AS DATE), 'ENDED'),
 (N'Joker: Folie a Deux',
  N'Arthur Fleck struggles with dual identity, finds love, and the music that was always inside him.',
  138, N'Todd Phillips', N'Joaquin Phoenix, Lady Gaga, Brendan Gleeson',
  'English', 'USA', 'C18', N'/assets/img/posters/joker-folie-a-deux.jpg',
  N'https://www.youtube.com/watch?v=_OKAwz2MsJs',
  CAST(DATEADD(DAY, -140, CAST(GETDATE() AS DATE)) AS DATE), 'ENDED'),
 (N'Bố Già',
  N'Ba Sang, a meddling but kind father, clashes with his YouTuber son Quan in a noisy Saigon family.',
  128, N'Tran Thanh', N'Tran Thanh, Le Giang, Ngoc Giau',
  'Vietnamese', 'Vietnam', 'C13', N'/assets/img/posters/bo-gia.jpg',
  N'https://www.youtube.com/watch?v=jluSu8Rw6YE',
  CAST(DATEADD(DAY, -400, CAST(GETDATE() AS DATE)) AS DATE), 'ENDED');

-- ---------------------------------------------------------------------
-- 3. movie_genres (map by name to avoid hard-coding IDs)
-- ---------------------------------------------------------------------
INSERT INTO dbo.movie_genres (movie_id, genre_id)
SELECT m.movie_id, g.genre_id
FROM (VALUES
    (N'Dune: Part Two', N'Sci-Fi'), (N'Dune: Part Two', N'Adventure'),
    (N'Mai', N'Drama'), (N'Mai', N'Romance'),
    (N'Inside Out 2', N'Animation'), (N'Inside Out 2', N'Comedy'), (N'Inside Out 2', N'Family'),
    (N'Deadpool & Wolverine', N'Action'), (N'Deadpool & Wolverine', N'Comedy'),
    (N'Furiosa: A Mad Max Saga', N'Action'), (N'Furiosa: A Mad Max Saga', N'Adventure'),
    (N'Wicked', N'Drama'), (N'Wicked', N'Romance'),
    (N'Despicable Me 4', N'Animation'), (N'Despicable Me 4', N'Comedy'), (N'Despicable Me 4', N'Family'),
    (N'Lật Mặt 6: Tấm Vé Định Mệnh', N'Thriller'),
    (N'Godzilla x Kong: The New Empire', N'Action'), (N'Godzilla x Kong: The New Empire', N'Sci-Fi'),
    (N'Kung Fu Panda 4', N'Animation'), (N'Kung Fu Panda 4', N'Adventure'), (N'Kung Fu Panda 4', N'Family'),
    (N'A Quiet Place: Day One', N'Horror'), (N'A Quiet Place: Day One', N'Thriller'),
    (N'Oppenheimer', N'Drama'),
    (N'Barbie', N'Comedy'), (N'Barbie', N'Adventure'),
    (N'Tro Tàn Rực Rỡ', N'Drama'),
    (N'Moana 2', N'Animation'), (N'Moana 2', N'Adventure'), (N'Moana 2', N'Family'),
    (N'Venom: The Last Dance', N'Action'), (N'Venom: The Last Dance', N'Sci-Fi'),
    (N'Gladiator II', N'Action'), (N'Gladiator II', N'Adventure'), (N'Gladiator II', N'Drama'),
    (N'Twisters', N'Action'), (N'Twisters', N'Thriller'),
    (N'Bad Boys: Ride or Die', N'Action'), (N'Bad Boys: Ride or Die', N'Comedy'),
    (N'The Wild Robot', N'Animation'), (N'The Wild Robot', N'Adventure'), (N'The Wild Robot', N'Family'),
    (N'Beetlejuice Beetlejuice', N'Comedy'), (N'Beetlejuice Beetlejuice', N'Horror'),
    (N'Em và Trịnh', N'Drama'), (N'Em và Trịnh', N'Romance'),
    (N'Sonic the Hedgehog 3', N'Action'), (N'Sonic the Hedgehog 3', N'Comedy'), (N'Sonic the Hedgehog 3', N'Family'),
    (N'Mufasa: The Lion King', N'Animation'), (N'Mufasa: The Lion King', N'Adventure'), (N'Mufasa: The Lion King', N'Family'),
    (N'Alien: Romulus', N'Horror'), (N'Alien: Romulus', N'Sci-Fi'),
    (N'Joker: Folie a Deux', N'Drama'), (N'Joker: Folie a Deux', N'Thriller'),
    (N'Bố Già', N'Comedy'), (N'Bố Già', N'Drama'), (N'Bố Già', N'Family')
) AS x(movie_title, genre_name)
JOIN dbo.movies m ON m.title = x.movie_title
JOIN dbo.genres g ON g.name  = x.genre_name;

-- ---------------------------------------------------------------------
-- 4. Branches
-- ---------------------------------------------------------------------
-- Ten chi nhanh KHONG gan prefix brand (PentaPlex chi hien o UI/footer).
INSERT INTO dbo.branches (name, address, city, phone, email, opening_time, closing_time) VALUES
 (N'Nguyen Hue',  N'72 Nguyen Hue, District 1',        N'TP. Ho Chi Minh', '02838111111', 'nguyenhue@pentaplex.vn', '08:00', '23:00'),
 (N'Ba Trieu',    N'25 Ba Trieu, Hoan Kiem',           N'Ha Noi',          '02438222222', 'batrieu@pentaplex.vn',   '09:00', '22:30');

-- ---------------------------------------------------------------------
-- 4b. Movie-branch assignment: Admin cap moi phim active cho moi chi nhanh
--     (du lieu nen de BM xep lich duoc ngay; Admin tinh chinh sau).
-- ---------------------------------------------------------------------
INSERT INTO dbo.movie_branch (movie_id, branch_id)
SELECT m.movie_id, b.branch_id
FROM dbo.movies m
CROSS JOIN dbo.branches b
WHERE m.active = 1;

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
-- 7. Showtimes — dense schedule relative to today (demo + test).
--    UNIQUE(room_id, start_time). Keep slots used by seed bookings below.
-- ---------------------------------------------------------------------
DECLARE @today DATE = CAST(GETDATE() AS DATE);

INSERT INTO dbo.showtimes (room_id, movie_id, start_time, end_time, base_price, format, subtitle_type, [status])
SELECT r.room_id,
       mv.movie_id,
       s.start_at,
       DATEADD(MINUTE, mv.duration_min, s.start_at),
       s.base_price, s.format, s.subtitle_type, s.st_status
FROM (
    -- ===== Nguyen Hue / Room 1 =====
    SELECT N'Nguyen Hue' AS branch_name, N'Room 1' AS room_name, N'Dune: Part Two' AS movie_title,
           CAST(DATEADD(HOUR, 10, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2) AS start_at,
           CAST(90000 AS DECIMAL(10,2)) AS base_price, '2D' AS format, 'SUB' AS subtitle_type, 'SCHEDULED' AS st_status
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Inside Out 2',
           CAST(DATEADD(HOUR, 10, CAST(@today AS DATETIME2)) AS DATETIME2), 80000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Wicked',
           CAST(DATEADD(HOUR, 13, CAST(@today AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 16, CAST(@today AS DATETIME2)) AS DATETIME2), 90000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Lật Mặt 6: Tấm Vé Định Mệnh',
           CAST(DATEADD(MINUTE, 30, DATEADD(HOUR, 19, CAST(@today AS DATETIME2))) AS DATETIME2), 85000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'The Wild Robot',
           CAST(DATEADD(HOUR, 13, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 80000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Wicked',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(MINUTE, 30, DATEADD(HOUR, 19, CAST(DATEADD(DAY, 1, @today) AS DATETIME2))) AS DATETIME2), 90000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Moana 2',
           CAST(DATEADD(HOUR, 11, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 75000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 100000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Mai',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 110000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Beetlejuice Beetlejuice',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Wicked',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    -- ===== Nguyen Hue / Room 2 (VIP) =====
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 110000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 11, CAST(@today AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Venom: The Last Dance',
           CAST(DATEADD(HOUR, 14, CAST(@today AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 18, CAST(@today AS DATETIME2)) AS DATETIME2), 110000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 21, CAST(@today AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Twisters',
           CAST(DATEADD(HOUR, 12, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 110000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Wicked',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 105000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 21, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 13, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Inside Out 2',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 110000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Bad Boys: Ride or Die',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    -- ===== Nguyen Hue / IMAX =====
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 14, CAST(@today AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Gladiator II',
           CAST(DATEADD(HOUR, 19, CAST(@today AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Gladiator II',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Gladiator II',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    -- ===== Ba Trieu / Room 1 =====
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Em và Trịnh',
           CAST(DATEADD(HOUR, 11, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Wicked',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Lật Mặt 6: Tấm Vé Định Mệnh',
           CAST(DATEADD(HOUR, 10, CAST(@today AS DATETIME2)) AS DATETIME2), 85000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 13, CAST(@today AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'The Wild Robot',
           CAST(DATEADD(HOUR, 16, CAST(@today AS DATETIME2)) AS DATETIME2), 85000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 19, CAST(@today AS DATETIME2)) AS DATETIME2), 90000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Moana 2',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 80000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Wicked',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Twisters',
           CAST(DATEADD(HOUR, 11, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Em và Trịnh',
           CAST(DATEADD(HOUR, 17, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Mai',
           CAST(DATEADD(HOUR, 13, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 110000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Wicked',
           CAST(DATEADD(HOUR, 17, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    -- ===== Ba Trieu / Room 2 =====
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 115000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Venom: The Last Dance',
           CAST(DATEADD(HOUR, 12, CAST(@today AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 15, CAST(@today AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 20, CAST(@today AS DATETIME2)) AS DATETIME2), 120000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Wicked',
           CAST(DATEADD(HOUR, 11, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 105000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Bad Boys: Ride or Die',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 120000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Deadpool & Wolverine',
           CAST(DATEADD(HOUR, 12, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 115000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Furiosa: A Mad Max Saga',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 100000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Beetlejuice Beetlejuice',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Mai',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 120000, '2D', 'ORIGINAL', 'SCHEDULED'
    -- ===== Ba Trieu / IMAX =====
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, -1, @today) AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'ENDED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 15, CAST(@today AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Gladiator II',
           CAST(DATEADD(HOUR, 20, CAST(@today AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, 1, @today) AS DATETIME2)) AS DATETIME2), 190000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Gladiator II',
           CAST(DATEADD(HOUR, 20, CAST(DATEADD(DAY, 2, @today) AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, 3, @today) AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    -- ===== Day +4 — extra slots for new titles (no UNIQUE clash with day -1..+3) =====
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Moana 2',
           CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 80000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Em và Trịnh',
           CAST(DATEADD(HOUR, 17, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'The Wild Robot',
           CAST(DATEADD(HOUR, 11, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Venom: The Last Dance',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Beetlejuice Beetlejuice',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Gladiator II',
           CAST(DATEADD(HOUR, 18, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Twisters',
           CAST(DATEADD(HOUR, 12, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Bad Boys: Ride or Die',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 90000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Moana 2',
           CAST(DATEADD(HOUR, 13, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Em và Trịnh',
           CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'ORIGINAL', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'IMAX Hall', N'Gladiator II',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 185000, 'IMAX', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Despicable Me 4',
           CAST(DATEADD(HOUR, 11, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 75000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 1', N'Despicable Me 4',
           CAST(DATEADD(HOUR, 10, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 75000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'Room 2', N'Despicable Me 4',
           CAST(DATEADD(HOUR, 13, CAST(DATEADD(DAY, 5, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'DUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'The Wild Robot',
           CAST(DATEADD(HOUR, 11, CAST(DATEADD(DAY, 5, @today) AS DATETIME2)) AS DATETIME2), 85000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Ba Trieu', N'Room 2', N'Venom: The Last Dance',
           CAST(DATEADD(HOUR, 15, CAST(DATEADD(DAY, 5, @today) AS DATETIME2)) AS DATETIME2), 95000, '2D', 'SUB', 'SCHEDULED'
    UNION ALL SELECT N'Nguyen Hue', N'IMAX Hall', N'Dune: Part Two',
           CAST(DATEADD(HOUR, 16, CAST(DATEADD(DAY, 5, @today) AS DATETIME2)) AS DATETIME2), 180000, 'IMAX', 'SUB', 'SCHEDULED'
    -- Cancelled sample (admin/list filter)
    UNION ALL SELECT N'Nguyen Hue', N'Room 1', N'Inside Out 2',
           CAST(DATEADD(HOUR, 9, CAST(DATEADD(DAY, 4, @today) AS DATETIME2)) AS DATETIME2), 80000, '2D', 'SUB', 'CANCELLED'
) AS s
JOIN dbo.branches b ON b.name = s.branch_name
JOIN dbo.rooms    r ON r.branch_id = b.branch_id AND r.name = s.room_name
JOIN dbo.movies   mv ON mv.title = s.movie_title;

-- ---------------------------------------------------------------------
-- 8. Customers
-- ---------------------------------------------------------------------
INSERT INTO dbo.customers (username, email, password_hash, full_name, phone, date_of_birth, address, email_verified, google_id) VALUES
 ('hungnt',     'hungnt@gmail.com',     @PWD, N'Nguyen Thanh Hung', '0901111111', '2003-06-17', N'Thu Duc, HCM', 1, NULL),
 ('trangnt',    'trangnt@gmail.com',    @PWD, N'Nguyen Thuy Trang', '0902222222', '2003-01-10', N'Hoan Kiem, HN', 1, NULL),
 ('guest01',    'guest01@gmail.com',    @PWD, N'Le Van Khach',      '0903333333', '2000-12-25', N'Go Vap, HCM',  0, NULL),
 -- Google sign-in account: no local password (NULL), email pre-verified by Google
 ('googleuser', 'googleuser@gmail.com', NULL, N'Google Demo User',  '0904444444', '2001-03-03', NULL,           1, 'google-oauth2|108273645091827364501');

-- ---------------------------------------------------------------------
-- 9. Employees (1 admin, 2 managers, 2 staff)
-- ---------------------------------------------------------------------
DECLARE @b1 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'Nguyen Hue');
DECLARE @b2 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'Ba Trieu');

INSERT INTO dbo.employees (username, email, password_hash, full_name, phone, role, branch_id) VALUES
 ('admin',     'admin@pentaplex.vn',     @PWD, N'System Admin',      '0900000000', 'ADMIN',          NULL),
 ('mgr_hcm',   'mgr.hcm@pentaplex.vn',   @PWD, N'Pham Quoc Anh',     '0911111111', 'BRANCH_MANAGER',  @b1),
 ('mgr_hn',    'mgr.hn@pentaplex.vn',    @PWD, N'Ho Minh Hoang',     '0911222222', 'BRANCH_MANAGER',  @b2),
 ('staff_hcm', 'staff.hcm@pentaplex.vn', @PWD, N'Ngo Duc Anh',       '0922111111', 'BRANCH_STAFF',    @b1),
 ('staff_hn',  'staff.hn@pentaplex.vn',  @PWD, N'Tran Thi Staff',    '0922222222', 'BRANCH_STAFF',    @b2);

-- ---------------------------------------------------------------------
-- 10. Promotions (global + branch-scoped + expired + near-limit)
-- ---------------------------------------------------------------------
DECLARE @promo_b1 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'Nguyen Hue');
DECLARE @promo_b2 BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'Ba Trieu');

INSERT INTO dbo.promotions
 (code, name, discount_type, discount_value, min_order_amount, valid_from, valid_to, max_uses, used_count, active, branch_id)
VALUES
 -- Global active
 ('WELCOME10',  N'Welcome 10% off',           'PERCENT',      10,    NULL,
  CAST(DATEADD(DAY, -60, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 180, CAST(GETDATE() AS DATE)) AS DATETIME2), NULL, 0, 1, NULL),
 ('SUMMER50K',  N'Summer 50,000 off',         'FIXED_AMOUNT', 50000, 200000,
  CAST(DATEADD(DAY, -30, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 90, CAST(GETDATE() AS DATE)) AS DATETIME2), 1000, 0, 1, NULL),
 ('STUDENT15',  N'Student 15% off',           'PERCENT',      15,    100000,
  CAST(DATEADD(DAY, -14, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 60, CAST(GETDATE() AS DATE)) AS DATETIME2), 500, 0, 1, NULL),
 ('WEEKEND20K', N'Weekend 20,000 off',        'FIXED_AMOUNT', 20000, 150000,
  CAST(DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 45, CAST(GETDATE() AS DATE)) AS DATETIME2), NULL, 0, 1, NULL),
 ('FLASH25',    N'Flash sale 25%',            'PERCENT',      25,    250000,
  CAST(DATEADD(DAY, -3, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 10, CAST(GETDATE() AS DATE)) AS DATETIME2), 200, 0, 1, NULL),
 -- Branch-scoped
 ('HCMONLY10',  N'Nguyen Hue member 10%',     'PERCENT',      10,    NULL,
  CAST(DATEADD(DAY, -20, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 120, CAST(GETDATE() AS DATE)) AS DATETIME2), NULL, 0, 1, @promo_b1),
 ('HNFLASH30K', N'Ba Trieu flash 30,000',     'FIXED_AMOUNT', 30000, 180000,
  CAST(DATEADD(DAY, -5, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) AS DATETIME2), 300, 0, 1, @promo_b2),
 -- Near max_uses (test promo exhausted path)
 ('NEARLYFULL', N'Almost sold-out promo 5%',  'PERCENT',      5,     NULL,
  CAST(DATEADD(DAY, -10, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 20, CAST(GETDATE() AS DATE)) AS DATETIME2), 5, 4, 1, NULL),
 -- Expired (should fail validate)
 ('EXPIRED5',   N'Expired spring 5%',         'PERCENT',      5,     NULL,
  CAST(DATEADD(DAY, -90, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) AS DATETIME2), NULL, 12, 1, NULL),
 -- Inactive (hidden from apply)
 ('PAUSED20',   N'Paused 20% (inactive)',     'PERCENT',      20,    NULL,
  CAST(DATEADD(DAY, -10, CAST(GETDATE() AS DATE)) AS DATETIME2),
  CAST(DATEADD(DAY, 40, CAST(GETDATE() AS DATE)) AS DATETIME2), NULL, 0, 0, NULL);

-- ---------------------------------------------------------------------
-- 11. Food items
-- ---------------------------------------------------------------------
-- Moi chi nhanh co menu F&B rieng (food_items.branch_id NOT NULL).
-- CROSS JOIN bo mon mau voi tung chi nhanh -> moi branch co day du 6 mon.
INSERT INTO dbo.food_items (name, description, price, category, branch_id, stock)
SELECT f.name, f.description, f.price, f.category, b.branch_id, f.stock
FROM (VALUES
    (N'Popcorn (Large)', N'Salted popcorn, large size',   CAST(65000  AS DECIMAL(10,2)), 'SNACK', 100),
    (N'Popcorn (Medium)',N'Caramel popcorn, medium size', CAST(55000  AS DECIMAL(10,2)), 'SNACK', 100),
    (N'Coca-Cola',       N'Soft drink 500ml',             CAST(30000  AS DECIMAL(10,2)), 'DRINK', 200),
    (N'Mineral Water',   N'Bottled water 500ml',          CAST(20000  AS DECIMAL(10,2)), 'DRINK', 200),
    (N'Combo for 2',     N'2 soft drinks + 1 large popcorn', CAST(115000 AS DECIMAL(10,2)), 'COMBO', 50),
    -- Solo: medium popcorn 55k + water 20k - light combo discount
    (N'Combo Solo',      N'1 mineral water + 1 medium popcorn', CAST(65000 AS DECIMAL(10,2)), 'COMBO', 50)
) AS f(name, description, price, category, stock)
CROSS JOIN dbo.branches b;

PRINT 'Base data seeded (genres, movies, branches, rooms, seats, showtimes, customers, employees, promotions, food).';
GO

-- ---------------------------------------------------------------------
-- 12. One full demo booking (booking -> seats -> payment -> food order)
--     hungnt: 2 seats for tomorrow IMAX Dune (CONFIRMED + F&B) — stays bookable.
-- ---------------------------------------------------------------------
DECLARE @today12 DATE = CAST(GETDATE() AS DATE);
DECLARE @showtime_id BIGINT = (
    SELECT TOP 1 st.showtime_id
    FROM dbo.showtimes st
    JOIN dbo.movies m ON m.movie_id = st.movie_id
    JOIN dbo.rooms r ON r.room_id = st.room_id
    JOIN dbo.branches b ON b.branch_id = r.branch_id
    WHERE m.title = N'Dune: Part Two'
      AND b.name = N'Ba Trieu'
      AND r.name = N'IMAX Hall'
      AND st.start_time = CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, 1, @today12) AS DATETIME2)) AS DATETIME2)
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

INSERT INTO dbo.booking_seats (booking_id, seat_id, showtime_id)
VALUES (@booking_id, @seat1, @showtime_id), (@booking_id, @seat2, @showtime_id);

INSERT INTO dbo.payments (booking_id, method, amount, [status], transaction_ref, paid_at)
VALUES (@booking_id, 'VNPAY', @total, 'SUCCESS', 'VNPAY-TXN-0001', SYSUTCDATETIME());

UPDATE dbo.promotions SET used_count = used_count + 1 WHERE promo_id = @promo_id;

-- Food order attached to the booking
INSERT INTO dbo.food_orders (booking_id, [status]) VALUES (@booking_id, 'PREPARING');
DECLARE @food_order_id BIGINT = SCOPE_IDENTITY();

-- Chon mon thuoc dung chi nhanh cua suat chieu (@room_id -> branch)
DECLARE @demo_branch_id BIGINT = (SELECT branch_id FROM dbo.rooms WHERE room_id = @room_id);
INSERT INTO dbo.booking_food_items (food_order_id, food_id, quantity)
SELECT @food_order_id, food_id, 1
FROM dbo.food_items
WHERE name = N'Combo for 2' AND branch_id = @demo_branch_id;

-- ---------------------------------------------------------------------
-- 13. Notification + feedback samples
-- ---------------------------------------------------------------------
INSERT INTO dbo.notifications (customer_username, title, content, type, reference_id) VALUES
 ('hungnt', N'Booking confirmed', N'Your booking BK-000001 is confirmed. Enjoy the movie!', 'BOOKING', @booking_id);

DECLARE @branch_hcm BIGINT = (SELECT branch_id FROM dbo.branches WHERE name = N'MBCMS Nguyen Hue');
INSERT INTO dbo.feedbacks (customer_username, branch_id, category, sub_category, name, email, subject, message, [status]) VALUES
 ('trangnt', @branch_hcm, 'GENERAL', NULL, N'Nguyen Thuy Trang', 'trangnt@gmail.com', N'Great experience', N'The IMAX hall sound was amazing!', 'NEW'),
 (NULL, NULL, 'GENERAL', NULL, N'Anonymous Guest', 'guest@example.com', N'Website slow', N'The booking page loads slowly on mobile.', 'NEW'),
 ('hungnt', @branch_hcm, 'COMPLAINT', NULL, N'Nguyen The Hung', 'hungnt@gmail.com', N'Lỗi âm thanh phòng chiếu', N'Âm thanh bị rè ở góc trái màn hình phòng VIP.', 'NEW'),
 ('trangnt', NULL, 'SUPPORT', 'BOOKING', N'Nguyen Thuy Trang', 'trangnt@gmail.com', N'Yêu cầu hoàn tiền vé', N'Tôi đã đặt nhầm vé suất chiếu tối nay, mong được hoàn tiền hoặc đổi suất.', 'NEW');

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
DECLARE @today14 DATE = CAST(GETDATE() AS DATE);

CREATE TABLE #plan (
    booking_code VARCHAR(20)   COLLATE DATABASE_DEFAULT,
    customer     VARCHAR(50)   COLLATE DATABASE_DEFAULT,
    branch_name  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
    room_name    NVARCHAR(50)  COLLATE DATABASE_DEFAULT,
    movie_title  NVARCHAR(200) COLLATE DATABASE_DEFAULT,
    start_time   DATETIME2,
    num_seats    INT,
    [status]     VARCHAR(9)    COLLATE DATABASE_DEFAULT,
    promo_code   VARCHAR(20)   COLLATE DATABASE_DEFAULT NULL,   -- NULL = no promo
    pay_method   VARCHAR(5)    COLLATE DATABASE_DEFAULT NULL,   -- NULL = no payment row (e.g. PENDING booking)
    pay_status   VARCHAR(7)    COLLATE DATABASE_DEFAULT NULL,
    booked_at    DATETIME2           -- explicit date so revenue-by-day has spread
);

INSERT INTO #plan VALUES
 ('BK-000002','trangnt', N'Ba Trieu',   N'Room 2',    N'Mai',            CAST(DATEADD(HOUR, 20, CAST(@today14 AS DATETIME2)) AS DATETIME2), 2, 'CONFIRMED', 'SUMMER50K', 'VNPAY', 'SUCCESS', DATEADD(DAY, -2, SYSUTCDATETIME())),
 ('BK-000003','hungnt',  N'Nguyen Hue', N'IMAX Hall', N'Dune: Part Two', CAST(DATEADD(HOUR, 19, CAST(DATEADD(DAY, -1, @today14) AS DATETIME2)) AS DATETIME2), 3, 'USED', NULL, 'VNPAY', 'SUCCESS', DATEADD(DAY, -3, SYSUTCDATETIME())),
 ('BK-000004','guest01', N'Nguyen Hue', N'Room 2',    N'Mai',            CAST(DATEADD(HOUR, 18, CAST(@today14 AS DATETIME2)) AS DATETIME2), 1, 'CONFIRMED', NULL, 'CASH', 'SUCCESS', DATEADD(HOUR, -1, SYSUTCDATETIME())),
 -- PENDING "tuoi" (tao 3 phut truoc): hien thi giao dich dang cho thanh toan ngay
 -- sau khi seed. Sau 10 phut, BookingExpiryScheduler se cancel booking + chuyen
 -- payment nay -> FAILED (minh hoa Option A: khong giu pending xac song).
 ('BK-000005','trangnt', N'Ba Trieu',   N'Room 1',    N'The Wild Robot', CAST(DATEADD(HOUR, 16, CAST(@today14 AS DATETIME2)) AS DATETIME2), 2, 'PENDING', NULL, 'VNPAY', 'PENDING', DATEADD(MINUTE, -3, SYSUTCDATETIME())),
 ('BK-000006','hungnt',  N'Nguyen Hue', N'Room 1',    N'Dune: Part Two', CAST(DATEADD(HOUR, 14, CAST(DATEADD(DAY, -1, @today14) AS DATETIME2)) AS DATETIME2), 2, 'CANCELLED', NULL, 'VNPAY', 'FAILED', DATEADD(DAY, -4, SYSUTCDATETIME())),
 -- NO_SHOW: CONFIRMED het suat, chua check-in (scheduler cung se set trang thai nay)
 ('BK-000007','guest01', N'Nguyen Hue', N'Room 1',    N'Dune: Part Two', CAST(DATEADD(HOUR, 10, CAST(DATEADD(DAY, -1, @today14) AS DATETIME2)) AS DATETIME2), 2, 'NO_SHOW', NULL, 'VNPAY', 'SUCCESS', DATEADD(DAY, -2, SYSUTCDATETIME()));

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

-- 14b. booking_seats (pick the first N seats of the room; USED => checked in).
-- CANCELLED: khong insert ghe (khop app: huy/het han xoa booking_seats de UNIQUE nha ghe).
INSERT INTO dbo.booking_seats (booking_id, seat_id, showtime_id, is_checked_in, check_in_time)
SELECT bk.booking_id, s.seat_id, bk.showtime_id,
       CASE WHEN bk.[status] = 'USED' THEN 1 ELSE 0 END,
       CASE WHEN bk.[status] = 'USED' THEN bk.created_at ELSE NULL END
FROM dbo.bookings bk
JOIN #plan p        ON p.booking_code = bk.booking_code
JOIN dbo.showtimes st ON st.showtime_id = bk.showtime_id
JOIN (
    SELECT seat_id, room_id,
           ROW_NUMBER() OVER (PARTITION BY room_id ORDER BY row_label, col_number) AS rn
    FROM dbo.seats
) s ON s.room_id = st.room_id AND s.rn <= p.num_seats
WHERE bk.[status] <> 'CANCELLED';

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
JOIN dbo.bookings b   ON b.booking_id = fo.booking_id AND b.booking_code = 'BK-000003'
JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id
JOIN dbo.rooms r      ON r.room_id = st.room_id
JOIN (VALUES (N'Popcorn (Large)', 1), (N'Coca-Cola', 3)) AS q(food_name, qty) ON 1 = 1
JOIN dbo.food_items fi ON fi.name = q.food_name AND fi.branch_id = r.branch_id;

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
PRINT 'Extra bookings seeded (BK-000002..BK-000007).';
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
UNION ALL SELECT 'promotions', COUNT(*) FROM dbo.promotions
UNION ALL SELECT 'food_items', COUNT(*) FROM dbo.food_items;
GO

-- Sample: active promotions (for demo checklist)
SELECT code, discount_type, discount_value, max_uses, used_count, active,
       CASE WHEN branch_id IS NULL THEN N'GLOBAL' ELSE CAST(branch_id AS NVARCHAR(20)) END AS scope
FROM dbo.promotions
ORDER BY active DESC, code;
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