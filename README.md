# 🎬 PentaPlex — Multi-Branch Cinema Management System

[![Java](https://img.shields.io/badge/Java-17%2B-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-Servlet%206.0-blue.svg)](https://jakarta.ee/)
[![Database](https://img.shields.io/badge/Database-SQL%20Server%202019%2B-red.svg)](https://www.microsoft.com/sql-server)
[![WebSockets](https://img.shields.io/badge/WebSockets-Realtime-brightgreen.svg)](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
[![Status](https://img.shields.io/badge/SWP391-PASSED-success.svg)](#-project-milestone--passing-celebration)

> **PentaPlex** is an enterprise-grade Multi-Branch Cinema Management System developed as a flagship project for the **SWP391 (SE2017 - Group 4)** course. The system provides an end-to-end web application solution covering online ticket reservation, Point-of-Sale (POS) counter bookings, concessions (F&B) fulfillment pipeline, branch promotion management, and real-time seat occupancy & event log monitoring.

---

## 🚀 Key Features

### 🌐 1. Customer Portal
* **Homepage & Movie Catalog (`/home`):** Browse movies currently showing (`NOW_SHOWING`), upcoming releases (`UPCOMING`), filter by genres and cinema branch locations.
* **Online Booking Flow:** Interactive real-time seat selection, concessions (F&B) combo ordering.
* **VNPay Gateway Integration (`/booking/checkout`):** Secure online payment gateway integration using VNPay QR.
* **Password Recovery (`/auth/forgot-password`):** 3-step password recovery wizard with BCrypt-hashed OTP email verification.

### 🎟️ 2. Counter Operations / Branch Staff
* **Counter Booking Wizard (`/staff/booking`):** 4-step POS wizard for walk-in guests (`guest01`) or registered members with Cash and VNPay QR checkout options.
* **F&B Fulfillment Pipeline (`/staff/food-orders`):** Kitchen fulfillment console tracking popcorn & drink preparation across 4 real-time statuses (`PENDING` → `PREPARING` → `READY` → `DELIVERED`).
* **Instant Ticket Generation:** Printable ticket receipt view (PDF) generated instantly upon transaction completion.

### 📊 3. Branch Manager Console
* **Showtime Scheduling Grid (`/branch/showtimes`):** Visual timeline grid managing movie screening slots per theater room.
* **Real-time Occupancy & Event Monitor (`/branch/showtimes/monitor`):** Bi-directional WebSocket seat grid monitoring with live event activity log console.
* **Branch Promotions (`/branch/promotions`):** Create and manage branch-scoped promo codes and discount campaign rules.
* **Hall & Seat Configuration (`/branch/halls`):** Dynamic seat type assignment (Standard / VIP) with future showtime dependency validation.

### 👑 4. System Administrator
* **Movie Catalog & Distribution (`/admin/movies` & `movie_branch`):** Assign movie screening rights to specific branch cinemas.
* **Global Promotions (`/admin/promotions`):** Create system-wide promotion campaigns applicable across all branches.
* **System Settings (`/admin/settings`):** Configurable system parameters including VIP seat surcharge percentage and pending seat hold timeouts (10 minutes).

---

## 🛠️ Technology Stack

* **Backend Core:** Java 17+, Servlet 6.0 (Jakarta EE), JSP, JSTL, Expression Language (EL).
* **Database & Connectivity:** SQL Server 2019+, JDBC, Apache Commons DBCP2 (Connection Pool).
* **Real-time Communications:** Java WebSockets (`jakarta.websocket`).
* **Frontend:** HTML5, Vanilla CSS3 (Custom Design System), JavaScript (ES6+ Fetch AJAX), Bootstrap 5.3, Bootstrap Icons.
* **Security & Utilities:** BCrypt Password Hashing (`jBCrypt`), Maven, Apache Tomcat 10.1.
* **Payment Gateway:** VNPay Payment Gateway Integration API.

---

## 🗄️ Database Setup & Architecture (CinemaDB)

This section contains scripts and setup instructions to create and seed the database for the **PentaPlex** project.

### Files

| File | Purpose |
|---|---|
| `CinemaDB_schema.sql` | Creates the `CinemaDB` database and 19 tables (PK/FK/UNIQUE/CHECK/index) |
| `CinemaDB_seed.sql` | Loads sample data (movies, branches, seats, showtimes, demo bookings, etc.) |

### How to run (SSMS)

1. Open **`CinemaDB_schema.sql`** → press **F5**. (Creates the `CinemaDB` database if it does not exist.)
2. Open **`CinemaDB_seed.sql`** → press **F5**.
3. At the end of the seed file, row counts and two sample report queries (revenue by branch, bookings by status) are printed for a quick sanity check.

> Both files are **safe to re-run** — each file drops or clears existing data at the top. Running the schema again drops all tables and recreates them.

### Connecting from the Java app (DBCP2)

Sample connection string — SQL Server Authentication (adjust `user`/`password` per machine):

```properties
db.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
db.url=jdbc:sqlserver://localhost:1433;databaseName=CinemaDB;encrypt=false;trustServerCertificate=true
db.username=sa
db.password=YOUR_PASSWORD
```

> For Windows Authentication, omit `user`/`password` and add `integratedSecurity=true`.

### Sample accounts (shared password: `password`)

| Role | Username |
|---|---|
| Admin | `admin` |
| Branch Manager | `mgr_hcm`, `mgr_hn` |
| Branch Staff | `staff_hcm`, `staff_hn` |
| Customer | `hungnt`, `trangnt`, `guest01` |

Hashes in the database are bcrypt work-factor 10 for the string `"password"`, compatible with jBCrypt (`$2a$`).

### What the seed data includes

- **8 genres, 6 movies** (4 NOW_SHOWING/UPCOMING plus multi-genre mappings), **2 branches** (HCM + HN).
- **6 rooms** (3 per branch: STANDARD / VIP / IMAX), **480 seats** (80 per room = rows A–H × 10 columns; rows G–H are VIP).
- **14 showtimes** spanning 05–07 Jun 2026.
- **6 bookings** `BK-000001..BK-000006` covering CONFIRMED / USED / PENDING / CANCELLED, with payments across CASH / VNPAY — for revenue and status reporting tests.
- **2 promotions, 6 food items**, food orders, notifications, and feedbacks (including guest feedback without login).

### Design notes

- SQL Server has no ENUM type — status/category fields use `VARCHAR` with `CHECK (... IN (...))` constraints.
- Some business rules are enforced in the database via `CHECK`: `duration_min > 0`, `end_time > start_time`, `total_amount >= 0`, and `CK_employees_branch` (ADMIN → `branch_id` NULL; MANAGER/STAFF → NOT NULL).
- `ON DELETE CASCADE`: `movie_genres`, `booking_seats`, `payments`, `food_orders`, `booking_food_items`, `notifications`. `ON DELETE SET NULL`: `feedbacks.customer_username` (allows guest feedback without an account).
- No triggers, stored procedures, or views — business logic lives in Java (DAO) to keep the database simple and portable.

---

## 🏆 Project Milestone & Passing Celebration

<div align="center">

### 🎉 WE PASSED SWP COMPLETELY, TOGETHER, AND SUCCESSFULLY! 🎉
📅 **Project Timeline:** `12/05/2026 — 27/07/2026`

***

*Built with passion and dedicated teamwork by Group 4 (SWP391 - SE2017).* ❤️
###  Project Leader: Pham Quoc Anh
###  Instructor: Mr. Ngo Tuan Khiem

</div>
