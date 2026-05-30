# CinemaDB — Database Setup (MBCMS)

Thư mục này chứa script tạo & seed database cho dự án SWP391.

## File

| File | Mục đích |
|---|---|
| `CinemaDB_schema.sql` | Tạo database `CinemaDB` + 18 bảng (PK/FK/UNIQUE/CHECK/index) |
| `CinemaDB_seed.sql` | Nạp dữ liệu mẫu (phim, chi nhánh, ghế, suất chiếu, booking demo...) |

## Cách chạy (SSMS)

1. Mở **`CinemaDB_schema.sql`** → nhấn **F5**. (Tự tạo DB `CinemaDB` nếu chưa có.)
2. Mở **`CinemaDB_seed.sql`** → nhấn **F5**.
3. Cuối file seed in ra bảng đếm số dòng + 2 query báo cáo mẫu (doanh thu theo chi nhánh, booking theo trạng thái) để kiểm tra nhanh.

> Cả 2 file **chạy lại được nhiều lần** — đầu file đã `DROP` / `DELETE` dữ liệu cũ. Chạy schema lại sẽ xoá sạch bảng và tạo lại.

## Kết nối từ app Java (DBCP2)

Connection string mẫu — SQL Server Authentication (chỉnh `user`/`password` theo máy mỗi người):

```
jdbc:sqlserver://localhost:1433;databaseName=CinemaDB;user=sa;password=YOUR_PASSWORD;encrypt=true;trustServerCertificate=true
```

> Nếu dùng Windows Authentication thì bỏ `user`/`password`, thêm `integratedSecurity=true`.

## Tài khoản mẫu (mật khẩu chung: `password`)

| Role | Username |
|---|---|
| Admin | `admin` |
| Branch Manager | `mgr_hcm`, `mgr_hn` |
| Branch Staff | `staff_hcm`, `staff_hn` |
| Customer | `hungnt`, `trangnt`, `guest01` |

Hash trong DB là bcrypt work-factor-10 chuẩn của chuỗi `"password"`, tương thích jBCrypt (`$2a$`).

## Dữ liệu seed có gì

- **8 genres, 6 phim** (4 NOW_SHOWING/UPCOMING + map nhiều thể loại), **2 chi nhánh** (HCM + HN).
- **6 phòng** (mỗi chi nhánh 3: STANDARD / VIP / IMAX), **480 ghế** (mỗi phòng 80 ghế = 8 hàng A–H × 10 cột, hàng G–H là VIP).
- **14 suất chiếu** trải các ngày 05–07/06/2026.
- **6 bookings** `BK-000001..BK-000006` đủ trạng thái CONFIRMED / USED / PENDING / CANCELLED, thanh toán đủ phương thức CASH / MOMO / VNPAY / CREDIT_CARD → để test báo cáo doanh thu, thống kê trạng thái.
- **2 promotions, 6 food items**, food orders, notifications, feedbacks (gồm cả feedback của Guest không đăng nhập).

## Ghi chú thiết kế

- SQL Server không có kiểu ENUM → các trường trạng thái/loại được biểu diễn bằng `VARCHAR` kèm ràng buộc `CHECK (... IN (...))`.
- Một số quy tắc nghiệp vụ được ràng buộc ngay ở tầng database qua `CHECK`: `duration_min > 0`, `end_time > start_time`, `total_amount >= 0`, và `CK_employees_branch` (ADMIN → `branch_id` NULL; MANAGER/STAFF → NOT NULL).
- `ON DELETE CASCADE`: `movie_genres`, `booking_seats`, `payments`, `food_orders`, `booking_food_items`, `notifications`. `ON DELETE SET NULL`: `feedbacks.customer_username` (cho phép Guest gửi feedback mà không cần tài khoản).
- Không dùng trigger / stored procedure / view — business logic được xử lý ở tầng Java (DAO), giữ database đơn giản và độc lập.
