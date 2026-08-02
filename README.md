# 🎬 PentaPlex — Multi-Branch Cinema Management System

[![Java](https://img.shields.io/badge/Java-17%2B-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-Servlet%206.0-blue.svg)](https://jakarta.ee/)
[![Database](https://img.shields.io/badge/Database-SQL%20Server%202019%2B-red.svg)](https://www.microsoft.com/sql-server)
[![WebSockets](https://img.shields.io/badge/WebSockets-Realtime-brightgreen.svg)](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
[![Status](https://img.shields.io/badge/SWP391-PASSED-success.svg)](#-dự-án-hoàn-thành--passing-milestone)

> **PentaPlex** là hệ thống quản lý rạp chiếu phim đa chi nhánh (Multi-Branch Cinema Management System) được nghiên cứu và phát triển trong khuôn khổ môn học **SWP391 (SE2017 - JS(IT) - Group 4)**. Hệ thống cung cấp giải pháp toàn diện cho việc đặt vé trực tuyến, bán vé tại quầy (POS), chế biến & giao đồ ăn bắp nước (F&B Fulfillment), và giám sát sơ đồ ghế thời gian thực (Real-time Occupancy & Event Log Monitor).

---

## 🚀 Tính Năng Nổi Bật (Key Features)

### 🌐 1. Khách Hàng (Customer Portal)
* **Trang chủ & Danh mục Phim (`/home`):** Xem danh sách phim đang chiếu (`NOW_SHOWING`), sắp chiếu (`UPCOMING`), tìm kiếm theo thể loại & chi nhánh rạp.
* **Đặt vé Trực tuyến (Online Booking):** Chọn ghế thời gian thực, chọn bắp nước F&B đi kèm.
* **Thanh toán VNPay QR (`/booking/checkout`):** Tích hợp cổng thanh toán trực tuyến VNPay chính xác và an toàn.
* **Quên Mật Khẩu (`/auth/forgot-password`):** Khôi phục mật khẩu 3 bước gửi mã OTP bảo mật qua Email và mã hóa BCrypt.

### 🎟️ 2. Nhân Viên Quầy (Branch Staff / Counter Operations)
* **Bán vé Tại Quầy (`/staff/booking`):** Giao diện Wizard 4 bước siêu mượt hỗ trợ bán vé, thu tiền mặt/VNPay QR cho khách vãng lai (`guest01`) hoặc thành viên.
* **F&B Fulfillment Pipeline (`/staff/food-orders`):** Quản lý tiến trình chế biến & giao bắp nước tại bếp rạp theo 4 trạng thái real-time (`PENDING` → `PREPARING` → `READY` → `DELIVERED`).
* **In Vé Trực Tiếp:** Xuất vé PDF và giao dịch thành công ngay tại quầy.

### 📊 3. Quản Lý Rạp (Branch Manager Console)
* **Xếp Lịch Suất Chiếu (`/branch/showtimes`):** Bảng lưới Timeline trực quan quản lý giờ chiếu phim theo từng phòng.
* **Giám Sát Real-time (`/branch/showtimes/monitor`):** Theo dõi ma trận ghế phòng chiếu real-time qua WebSocket và nhật ký sự kiện Live Event Log.
* **Quản Lý Khuyến Mãi Chi Nhánh (`/branch/promotions`):** Tạo và quản lý mã voucher áp dụng riêng cho rạp.
* **Cấu Hình Phòng Chiếu & Ghế (`/branch/halls`):** Đổi loại ghế (Standard/VIP) và kiểm tra ràng buộc suất chiếu tương lai.

### 👑 4. Quản Tị Viên Hệ Thống (System Administrator)
* **Danh Mục Phim & Cấp Phim Chi Nhánh (`/admin/movies` & `movie_branch`):** Cấp quyền phân phối phim về các chi nhánh rạp.
* **Quản Lý Khuyến Mãi Toàn Quốc (`/admin/promotions`):** Tạo các chiến dịch giảm giá áp dụng trên toàn bộ rạp.
* **Cấu Hình Hệ Thống (`/admin/settings`):** Điều chỉnh % phụ thu ghế VIP, thời gian giữ chỗ tạm (10 phút)...

---

## 🛠️ Công Nghệ Sử Dụng (Tech Stack)

* **Backend Core:** Java 17+, Servlet 6.0 (Jakarta EE), JSP, JSTL, Expression Language (EL).
* **Database & Connectivity:** SQL Server 2019+, JDBC, Apache Commons DBCP2 (Connection Pool).
* **Real-time Communications:** Java WebSockets (`jakarta.websocket`).
* **Frontend:** HTML5, Vanilla CSS3 (Custom Design System), JavaScript (ES6+ Fetch AJAX), Bootstrap 5.3, Bootstrap Icons.
* **Security & Tools:** BCrypt Password Hashing (`jBCrypt`), Maven, Apache Tomcat 10.1.
* **Payment Integration:** VNPay Payment Gateway API.

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

## 🏆 DỰ ÁN HOÀN THÀNH — PASSING MILESTONE

<div align="center">

### 🎉 We have successfully passed the SWP together and triumphantly! 🎉
📅 **Project duration:** `12/05/2026 — 27/07/2026`
 **Project leader:** Pham Quoc Anh

***



</div>
