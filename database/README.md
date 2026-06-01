# CinemaDB — Database Setup (MBCMS)

This folder contains scripts to create and seed the database for the SWP391 project.

## Files

| File | Purpose |
|---|---|
| `CinemaDB_schema.sql` | Creates the `CinemaDB` database and 18 tables (PK/FK/UNIQUE/CHECK/index) |
| `CinemaDB_seed.sql` | Loads sample data (movies, branches, seats, showtimes, demo bookings, etc.) |

## How to run (SSMS)

1. Open **`CinemaDB_schema.sql`** → press **F5**. (Creates the `CinemaDB` database if it does not exist.)
2. Open **`CinemaDB_seed.sql`** → press **F5**.
3. At the end of the seed file, row counts and two sample report queries (revenue by branch, bookings by status) are printed for a quick sanity check.

> Both files are **safe to re-run** — each file drops or clears existing data at the top. Running the schema again drops all tables and recreates them.

## Connecting from the Java app (DBCP2)

Sample connection string — SQL Server Authentication (adjust `user`/`password` per machine):

```
jdbc:sqlserver://localhost:1433;databaseName=CinemaDB;user=sa;password=YOUR_PASSWORD;encrypt=true;trustServerCertificate=true
```

> For Windows Authentication, omit `user`/`password` and add `integratedSecurity=true`.

## Sample accounts (shared password: `password`)

| Role | Username |
|---|---|
| Admin | `admin` |
| Branch Manager | `mgr_hcm`, `mgr_hn` |
| Branch Staff | `staff_hcm`, `staff_hn` |
| Customer | `hungnt`, `trangnt`, `guest01` |

Hashes in the database are bcrypt work-factor 10 for the string `"password"`, compatible with jBCrypt (`$2a$`).

## What the seed data includes

- **8 genres, 6 movies** (4 NOW_SHOWING/UPCOMING plus multi-genre mappings), **2 branches** (HCM + HN).
- **6 rooms** (3 per branch: STANDARD / VIP / IMAX), **480 seats** (80 per room = rows A–H × 10 columns; rows G–H are VIP).
- **14 showtimes** spanning 05–07 Jun 2026.
- **6 bookings** `BK-000001..BK-000006` covering CONFIRMED / USED / PENDING / CANCELLED, with payments across CASH / MOMO / VNPAY — for revenue and status reporting tests.
- **2 promotions, 6 food items**, food orders, notifications, and feedbacks (including guest feedback without login).

## Design notes

- SQL Server has no ENUM type — status/category fields use `VARCHAR` with `CHECK (... IN (...))` constraints.
- Some business rules are enforced in the database via `CHECK`: `duration_min > 0`, `end_time > start_time`, `total_amount >= 0`, and `CK_employees_branch` (ADMIN → `branch_id` NULL; MANAGER/STAFF → NOT NULL).
- `ON DELETE CASCADE`: `movie_genres`, `booking_seats`, `payments`, `food_orders`, `booking_food_items`, `notifications`. `ON DELETE SET NULL`: `feedbacks.customer_username` (allows guest feedback without an account).
- No triggers, stored procedures, or views — business logic lives in Java (DAO) to keep the database simple and portable.
