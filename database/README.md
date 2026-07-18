# CinemaDB — Database Setup (PentaPlex)

This folder contains scripts to create and seed the database for the SWP391 project.

## Files (chỉ 2 file SQL)

| File | Purpose |
|---|---|
| `CinemaDB_schema.sql` | Tạo DB `CinemaDB` + toàn bộ bảng / PK / FK / UNIQUE / CHECK / index + `system_settings` |
| `CinemaDB_seed.sql` | Nạp dữ liệu demo (movies, branches, seats, showtimes, bookings, settings, …) |

Không còn file `patch_*.sql` / `upgrade_*.sql` / `migrations/` — mọi thứ (kể cả `system_settings` + `fn_setting_int`) nằm trong schema + seed. DB lệch schema: chạy lại **schema → seed** (drop + recreate).

**Admin Settings** (`/admin/settings`): VIP surcharge %, max seats/booking, PENDING hold minutes, showtime gap — lưu trong `dbo.system_settings` (SQL dùng `dbo.fn_setting_int`).

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

- **10 genres, 27 real movies** with local posters under `src/main/webapp/assets/img/posters/` (TMDB artwork). NOW_SHOWING includes Dune, Mai, Inside Out 2, Deadpool, Furiosa, Wicked, Despicable Me 4, Lật Mặt 6, Moana 2, Venom, Gladiator II, Twisters, Bad Boys, The Wild Robot, Beetlejuice, Em và Trịnh; plus UPCOMING (Godzilla x Kong, Kung Fu Panda 4, Quiet Place, Sonic 3, Mufasa) and ENDED (Oppenheimer, Barbie, Tro Tàn Rực Rỡ, Alien: Romulus, Joker Folie a Deux, Bố Già). Vietnamese titles keep diacritics in seed.
- **2 branches** only: **Nguyen Hue** and **Ba Trieu** (no brand prefix; PentaPlex is UI-only).
- **6 rooms** (3 per branch: STANDARD / VIP / IMAX), **480 seats** (80 per room = rows A–H × 10 columns; rows G–H are VIP).
- **~80+ showtimes** relative to `CAST(GETDATE() AS DATE)` spanning yesterday → +4 days across all rooms/movies (plus 1 CANCELLED + 1 ENDED sample).
- **7 bookings** `BK-000001..BK-000007` covering CONFIRMED / USED / PENDING / CANCELLED / **NO_SHOW**, with payments across CASH / VNPAY.
- **10 promotions**: global active (`WELCOME10`, `SUMMER50K`, `STUDENT15`, `WEEKEND20K`, `FLASH25`), branch-scoped (`HCMONLY10`, `HNFLASH30K`), near-limit (`NEARLYFULL`), expired (`EXPIRED5`), inactive (`PAUSED20`).
- **6 food items per branch** (Combo Solo **65.000**; Combo for 2 **115.000**), food orders, notifications, and feedbacks.

## Design notes

- SQL Server has no ENUM type — status/category fields use `VARCHAR` with `CHECK (... IN (...))` constraints.
- Booking statuses: `PENDING` → `CONFIRMED` → `USED` (check-in) | `NO_SHOW` (scheduler after `end_time` without check-in) | `CANCELLED`.
- Some business rules are enforced in the database via `CHECK` / `UNIQUE`:
  - `UQ_booking_seats_showtime_seat (showtime_id, seat_id)` — DB safety net against double-booking the same seat for one showtime. App must **delete** `booking_seats` when a booking becomes `CANCELLED` (cancel / 10-min expiry) so the seat is released.
  - `CK_bookings_math`: `total_amount = subtotal - discount_amount`
  - Promotions: `PERCENT` ≤ 100, `used_count <= max_uses` (when `max_uses` is set)
  - `UNIQUE (branch_id, name)` on `rooms` and `food_items`; branch name unique; branch hours `closing > opening` when both set
  - `CK_employees_branch` (ADMIN → `branch_id` NULL; MANAGER/STAFF → NOT NULL)
- `ON DELETE CASCADE`: `movie_genres`, `booking_seats`, `payments`, `food_orders`, `booking_food_items`, `notifications`. `ON DELETE SET NULL`: `feedbacks.customer_username` (allows guest feedback without an account).
- No triggers or views — business logic lives in Java (DAO). Showtime overlap is prevented by a check-then-INSERT inside one JDBC transaction plus `UNIQUE (room_id, start_time)` (one Branch Manager per branch, so no cross-user scheduling race to guard).
