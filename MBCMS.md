<div align="center">

<!-- Banner -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,50:16213e,100:0f3460&height=200&section=header&text=MBCMS&fontSize=80&fontColor=e94560&fontAlignY=38&desc=Multi-Branch%20Cinema%20Management%20System&descSize=22&descAlignY=62&descColor=a8b2d8" width="100%"/>

<!-- Badges -->
<p>
  <img src="https://img.shields.io/badge/Java-17_LTS-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white"/>
  <img src="https://img.shields.io/badge/Jakarta_EE-10-4E8CC2?style=for-the-badge&logo=jakartaee&logoColor=white"/>
  <img src="https://img.shields.io/badge/Apache_Tomcat-10.1+-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black"/>
  <img src="https://img.shields.io/badge/SQL_Server-2019+-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white"/>
  <img src="https://img.shields.io/badge/Maven-3.x-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white"/>
</p>
<p>
  <img src="https://img.shields.io/badge/Bootstrap-5.3-7952B3?style=for-the-badge&logo=bootstrap&logoColor=white"/>
  <img src="https://img.shields.io/badge/jQuery-3.7-0769AD?style=for-the-badge&logo=jquery&logoColor=white"/>
  <img src="https://img.shields.io/badge/Chart.js-4.4-FF6384?style=for-the-badge&logo=chartdotjs&logoColor=white"/>
  <img src="https://img.shields.io/badge/Status-In_Development-yellow?style=for-the-badge"/>
</p>

<br/>

> **An integrated multi-branch cinema management platform** — connecting physical branch operations with an  
> interactive web portal for real-time, thread-safe synchronization of seat inventory and ticket sales.

<br/>

</div>

---

## 📋 Table of Contents

- [✨ Overview](#-overview)
- [🎯 Key Features](#-key-features)
- [👥 User Roles](#-user-roles)
- [🏗️ System Architecture](#️-system-architecture)
- [🛠️ Tech Stack](#️-tech-stack)
- [🗄️ Database](#️-database)
- [🔐 Security](#-security)
- [📊 Non-Functional Requirements](#-non-functional-requirements)
- [🚀 Getting Started](#-getting-started)
- [👨‍💻 Team](#-team)

---

## ✨ Overview

**MBCMS** (Multi-Branch Cinema Management System) is a full-stack Java web application built for **SE2017 - JS(IT)** at **FPT University, Hanoi**.

The system replaces decentralized manual ticketing logs and localized seat-tracking workflows with a unified digital hub — supporting everything from online seat selection and e-payment to walk-in counter operations, F&B ordering, and consolidated revenue reporting across all branches.

```
Online Customer  ──►  Browse Movies → Select Showtime → Choose Seats → Pay → E-Ticket (QR/PDF)
Walk-in Customer ──►  Branch Staff POS → Select Seats → Cash/Counter Payment → Print Ticket
Branch Manager   ──►  Configure Rooms · Schedule Showtimes · View Revenue Reports
Admin            ──►  Manage All Branches · Global Catalog · Users · Promotions
```

---

## 🎯 Key Features

<table>
<tr>
<td width="50%">

### 🎬 Movie & Showtime

- Browse & search movies (title, genre, cast, status)
- Rich movie details — poster, trailer, duration, age rating
- Schedule showtimes across branches and rooms
- Conflict detection: gap ≥ duration + 30 min enforced
- Vietnamese age ratings: **P / C13 / C16 / C18**

### 🎟️ Ticket Booking

- Interactive seat-map with real-time availability
- End-to-end online booking (11-step flow)
- Walk-in counter booking via Branch Staff POS
- Race condition protection — DB-level seat locking
- 10-minute seat hold with automatic release
- **QR code** e-ticket (ZXing) + **PDF** (iText 7)

</td>
<td width="50%">

### 💳 Payment

- Online: **VNPay** & **MoMo** (HMAC-SHA512 verified callbacks)
- Counter: Cash / card via staff POS
- Promotion / discount code support
- Payment timeout with auto-cancellation

### 🍿 Food & Beverage

- F&B menu management (Snack / Drink / Combo)
- Add F&B to any booking (optional)
- Order lifecycle: `PENDING → PREPARING → READY → DELIVERED`

### 📊 Administration

- Multi-branch management (add / edit / soft-delete)
- Room & seat configuration per branch
- Revenue reports with Chart.js dashboards
- Export PDF & CSV reports
- User management with role assignment

</td>
</tr>
</table>

---

## 👥 User Roles

| Role                  | Access Level  | Key Responsibilities                                                  |
| --------------------- | ------------- | --------------------------------------------------------------------- |
| 🌐 **Guest**          | Public        | Browse movies, view showtimes & branches, register account            |
| 🙋 **Customer**       | Authenticated | Book tickets online, make payments, view booking history, order F&B   |
| 👔 **Branch Staff**   | Branch-scoped | POS walk-in sales, QR ticket validation, F&B order handling           |
| 🏢 **Branch Manager** | Branch-scoped | Room & showtime management, pricing, branch revenue reports           |
| 🛡️ **Admin**          | System-wide   | All branches, users, global catalog, promotions, consolidated reports |

> Access control is enforced by a **3-layer Servlet filter chain**: `AuthFilter → RoleFilter → BranchFilter`

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│          JSP 3.1 Views  ·  Jakarta Servlet 6.0              │
│              com.cinema.view  ·  com.cinema.controller       │
├─────────────────────────────────────────────────────────────┤
│                    CROSS-CUTTING CONCERNS                    │
│         AuthFilter → RoleFilter → BranchFilter               │
│                    com.cinema.filter                         │
├─────────────────────────────────────────────────────────────┤
│                    BUSINESS LOGIC LAYER                      │
│    Booking · Payment · Seat Reservation · Report Generation  │
│                    com.cinema.service                        │
├─────────────────────────────────────────────────────────────┤
│                     DATA ACCESS LAYER                        │
│        JDBC + DAO Pattern · PreparedStatement only           │
│          Apache DBCP2 Connection Pool · No ORM               │
│                     com.cinema.dao                           │
├─────────────────────────────────────────────────────────────┤
│                  SUPPORTING PACKAGES                         │
│   com.cinema.bean (Entities)  ·  com.cinema.util (Helpers)  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────┐
              │  Microsoft SQL Server     │
              │  CinemaDB_final           │
              │  18 tables · 19 FKs       │
              │  15 enums                 │
              └───────────────────────────┘
```

**Design rule (NFR-MNT-01):** call flow is strictly one-way top-down. DAO never calls Service; Service never calls Servlet.

---

## 🛠️ Tech Stack

### Backend

| Component          | Technology                                        |
| ------------------ | ------------------------------------------------- |
| Language           | Java 17 LTS                                       |
| Web Framework      | Jakarta Servlet 6.0 + JSP 3.1 (no Spring Boot)    |
| Application Server | Apache Tomcat 10.1+                               |
| Build Tool         | Apache Maven                                      |
| DB Driver          | Microsoft JDBC Driver for SQL Server              |
| Connection Pool    | Apache DBCP2                                      |
| Password Hashing   | jBCrypt (work factor ≥ 10)                        |
| Email              | JavaMail API (`jakarta.mail`) — SMTP TLS/STARTTLS |
| PDF Generation     | iText 7 (`com.itextpdf:itext7-core`)              |
| QR Code            | ZXing (`com.google.zxing:core`, `javase`)         |
| IDE                | IntelliJ IDEA Ultimate (educational license)      |

### Frontend _(CDN — no Node.js/npm required)_

| Library   | Version |
| --------- | ------- |
| Bootstrap | 5.3     |
| jQuery    | 3.7     |
| Chart.js  | 4.4     |

### External Integrations

| Service         | Purpose                                                              |
| --------------- | -------------------------------------------------------------------- |
| **VNPay**       | Online payment gateway (sandbox)                                     |
| **MoMo**        | E-wallet payment gateway (sandbox)                                   |
| **SMTP Server** | Transactional email (verification, booking confirmation, ticket PDF) |

---

## 🗄️ Database

Schema **`CinemaDB_final`** — **18 tables · 19 foreign keys · 15 enums**

```
INFRASTRUCTURE          CONTENT               OPERATIONS
──────────────          ───────               ──────────
branches                movies                showtimes
rooms                   genres                bookings
seats                   movie_genres          booking_seats
                                              payments

USERS                   F&B                   EXTRAS
─────                   ───                   ──────
customers               food_items            promotions
employees               food_orders           notifications
                        booking_food_items    feedbacks
```

**Key design decisions:**

- 🔄 **Soft-delete** (`active` flag) on Movies, Rooms, Seats, Branches — preserves historical booking integrity
- 💳 **Payments separated** from Bookings — independent lifecycle, supports multiple gateways
- 🔒 **Unique constraints** prevent duplicate seats `(room_id, row_label, col_number)` and showtime conflicts `(room_id, start_time)`
- 📦 **Natural PKs** for Customers & Employees: `username` (per course requirement)
- ⚡ **Cascade DELETE** on bridge tables (`booking_seats`, `booking_food_items`) for automatic cleanup

**Booking lifecycle:**

```
PENDING ──(payment success)──► CONFIRMED ──(QR scan)──► USED
   │
   └──(timeout 10 min / cancel)──► CANCELLED
```

---

## 🔐 Security

| #      | Requirement      | Implementation                                                           |
| ------ | ---------------- | ------------------------------------------------------------------------ |
| SEC-01 | Password storage | bcrypt hash, work factor ≥ 10 — plaintext never stored or logged         |
| SEC-02 | SQL Injection    | `PreparedStatement` for all queries — string concatenation prohibited    |
| SEC-03 | CSRF Protection  | Hidden token in every POST form, validated server-side → 403 on failure  |
| SEC-04 | Session Security | `HttpOnly`, `Secure`, `SameSite=Lax`; session ID regenerated after login |
| SEC-05 | Authorization    | `AuthFilter → RoleFilter → BranchFilter` on all protected URLs           |
| SEC-06 | XSS Prevention   | All JSP output via JSTL `<c:out>` or EL with HTML encoding               |
| SEC-07 | Brute-force      | Account locked 15 min after 5 consecutive failed login attempts          |
| SEC-08 | Payment Security | HMAC-SHA512 signature verification on all VNPay/MoMo callbacks           |

---

## 📊 Non-Functional Requirements

| Category               | Requirement                                                                  |
| ---------------------- | ---------------------------------------------------------------------------- |
| ⚡ **Performance**     | 95% of page loads < 3s at 100 concurrent users; seat map (≤200 seats) < 2s   |
| 🟢 **Availability**    | 99.5% uptime during business hours (08:00–24:00)                             |
| 💾 **Backup**          | Daily full SQL Server backups + hourly transaction log; 7-day retention      |
| 🔧 **Maintainability** | Strict 3-layer separation; Javadoc; JUnit 5 + Mockito; ≥80% coverage target  |
| 📱 **Compatibility**   | Responsive on desktop ≥1280px, laptop ≥1024px, tablet ≥768px (Bootstrap 5.3) |
| ♿ **Accessibility**   | WCAG 2.1 AA — minimum 44×44px touch targets                                  |

---

## 🚀 Getting Started

### Prerequisites

```
Java 17 LTS
Apache Tomcat 10.1+
Microsoft SQL Server 2019+
Apache Maven 3.x
IntelliJ IDEA Ultimate (recommended)
```

### Setup

**1. Clone the repository**

```bash
git clone https://github.com/your-org/mbcms.git
cd mbcms
```

**2. Create the database**

```bash
# Run SQL scripts in order
sqlcmd -S localhost -i 01_Database/01_create_schema.sql
sqlcmd -S localhost -i 01_Database/02_seed_data.sql
```

**3. Configure database connection**

Edit `src/main/resources/db.properties`:

```properties
db.url=jdbc:sqlserver://localhost:1433;databaseName=CinemaDB_final;encrypt=false
db.username=your_username
db.password=your_password
db.pool.maxTotal=20
db.pool.maxIdle=10
```

**4. Configure payment gateways** _(optional — sandbox)_

Edit `src/main/resources/payment.properties`:

```properties
vnpay.tmn_code=YOUR_TMN_CODE
vnpay.hash_secret=YOUR_HASH_SECRET
vnpay.url=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html

momo.partner_code=YOUR_PARTNER_CODE
momo.access_key=YOUR_ACCESS_KEY
momo.secret_key=YOUR_SECRET_KEY
```

**5. Build & deploy**

```bash
mvn clean package
# Copy target/mbcms.war to Tomcat webapps/
# Start Tomcat, visit http://localhost:8080/mbcms
```

### Default Accounts _(seed data)_

| Role           | Username    | Password      |
| -------------- | ----------- | ------------- |
| Admin          | `admin`     | `Admin@123`   |
| Branch Manager | `manager01` | `Manager@123` |
| Branch Staff   | `staff01`   | `Staff@123`   |

> ⚠️ Change all default passwords before any production deployment.

---

## 👨‍💻 Team

<div align="center">

### 🎓 SE2017 - JS(IT) · Group 4 · FPT University Hanoi · May 2026

</div>

<table align="center">
<tr>
  <td align="center" width="200">
    <img src="https://github.com/identicons/phamquocanh.png" width="80" style="border-radius:50%"/><br/>
    <b>Pham Quoc Anh</b><br/>
    <sub>🎨 UI/UX Design · Swimlane Diagrams<br/>Business Process Modeling</sub>
  </td>
  <td align="center" width="200">
    <img src="https://github.com/identicons/nguyenthuytrang.png" width="80" style="border-radius:50%"/><br/>
    <b>Nguyen Thuy Trang</b><br/>
    <sub>📋 Use Case Specifications<br/>UC Diagrams · Customer Flows</sub>
  </td>
  <td align="center" width="200">
    <img src="https://github.com/identicons/nguyenthanhhung.png" width="80" style="border-radius:50%"/><br/>
    <b>Nguyen Thanh Hung</b><br/>
    <sub>🗄️ ERD · Database Design<br/>Schema Architecture (SDS)</sub>
  </td>
</tr>
<tr>
  <td align="center" width="200">
    <img src="https://github.com/identicons/hominhhoang.png" width="80" style="border-radius:50%"/><br/>
    <b>Ho Minh Hoang</b><br/>
    <sub>🔷 Context Diagram<br/>Package Diagram · Architecture</sub>
  </td>
  <td align="center" width="200">
    <img src="https://github.com/identicons/ngoducanh.png" width="80" style="border-radius:50%"/><br/>
    <b>Ngo Duc Anh</b><br/>
    <sub>⚙️ System Functionalities<br/>Screen Flow · Authorization Matrix</sub>
  </td>
  <td align="center" width="200">
    <img src="https://github.com/identicons/ngotuan.png" width="80" style="border-radius:50%"/><br/>
    <b>Ngo Tuan Khiem</b><br/>
    <sub>👨‍🏫 <i>Instructor</i><br/>Software Development<br/>FPT University Hanoi</sub>
  </td>
</tr>
</table>

---

<div align="center">

### 📄 Documentation

[![SRS Document](https://img.shields.io/badge/📄_SRS-Software_Requirement_Specification-2E75B6?style=for-the-badge)](./docs/SRS_Document.pdf)
[![SDS Document](https://img.shields.io/badge/📐_SDS-Software_Design_Specification-7030A0?style=for-the-badge)](./docs/SDS_Document.pdf)

</div>

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,50:16213e,100:0f3460&height=100&section=footer" width="100%"/>

<sub>Made with ❤️ by Group 4 · SE2017-JS(IT) · FPT University Hanoi · 2026</sub>

</div>
