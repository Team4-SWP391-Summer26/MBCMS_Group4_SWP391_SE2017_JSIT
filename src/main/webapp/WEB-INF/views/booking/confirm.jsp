<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    Booking confirmation - e-ticket (owner: HungNT). Booking step 5/5.
    Dung view-model `ticket` (BookingTicket) co day du movie/showtime/room/seat labels.
    Neu thieu `ticket` (fallback) van hien bookingCode + total tu `booking`.
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Booking Confirmed – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* ===== Booking shared stepper (inline, khong phu thuoc cache main.css) ===== */
        :root { --bk-primary:#2563EB; --bk-navy:#0F1E36; --bk-bg:#F5F7FA; }
        body.bk-page { background: var(--bk-bg); }
        .bk-wrap { max-width: 1080px; }
        .bk-steps { display:flex; align-items:center; }
        .bk-step { display:flex; align-items:center; gap:.5rem; font-size:.9rem; font-weight:600; color:#94a3b8; white-space:nowrap; }
        .bk-step .bk-dot { width:26px; height:26px; border-radius:999px; display:flex; align-items:center;
            justify-content:center; font-size:.78rem; background:#E2E8F0; color:#64748b; flex-shrink:0; }
        .bk-step.done { color:#16a34a; } .bk-step.done .bk-dot { background:#16a34a; color:#fff; }
        .bk-step.active { color:var(--bk-primary); } .bk-step.active .bk-dot { background:var(--bk-primary); color:#fff; }
        .bk-line { flex:1; height:2px; background:#E2E8F0; margin:0 .5rem; min-width:12px; }
        .bk-line.done { background:#16a34a; }
        @media (max-width:640px){ .bk-step span:not(.bk-dot){ display:none; } }

        /* ===== Success header ===== */
        .cf-hero { text-align:center; padding: 1.5rem 0 .5rem; }
        .cf-check { width:64px; height:64px; border-radius:50%; background:#dcfce7; color:#16a34a;
            display:inline-flex; align-items:center; justify-content:center; font-size:2rem; margin-bottom:.6rem;
            animation:popIn .4s cubic-bezier(.34,1.56,.64,1) both; }
        @keyframes popIn { from{opacity:0; transform:scale(.5);} to{opacity:1; transform:scale(1);} }
        .cf-hero h2 { font-weight:800; color:#15803d; font-size:1.7rem; margin:0; }
        .cf-hero p  { color:#64748b; margin:.25rem 0 0; }

        /* ===== E-ticket ===== */
        .ticket { max-width:620px; margin:1rem auto 0; background:#fff; border-radius:18px;
            box-shadow:0 10px 40px rgba(15,30,54,.12); overflow:hidden; }
        .ticket-top { background:linear-gradient(135deg,#1e3a8a 0%,#2563eb 100%); color:#fff; padding:22px 26px;
            display:flex; gap:16px; align-items:flex-start; }
        .ticket-poster { width:54px; height:74px; border-radius:8px; object-fit:cover; flex-shrink:0;
            background:linear-gradient(135deg,#0f172a,#1e293b); display:flex; align-items:center; justify-content:center;
            color:#FFC107; font-size:1.5rem; }
        .ticket-kicker { font-size:.7rem; letter-spacing:.16em; color:#bfdbfe; text-transform:uppercase; font-weight:700; }
        .ticket-title { font-weight:800; font-size:1.35rem; line-height:1.2; margin:.15rem 0 .4rem; }
        .ticket-badge { display:inline-block; font-size:.7rem; font-weight:700; padding:2px 8px; border-radius:6px;
            background:rgba(255,255,255,.18); color:#fff; margin:0 4px 4px 0; }
        .ticket-badge.rated { background:#FFC107; color:#0f1e36; }
        .ticket-status { margin-left:auto; background:#dcfce7; color:#15803d; font-size:.72rem; font-weight:700;
            padding:5px 12px; border-radius:999px; white-space:nowrap; display:inline-flex; align-items:center; gap:5px; }

        .ticket-perf { position:relative; height:0; border-top:2px dashed #e5e7eb; margin:0 26px; }
        .ticket-perf::before, .ticket-perf::after { content:''; position:absolute; top:-12px; width:24px; height:24px;
            background:var(--bk-bg); border-radius:50%; }
        .ticket-perf::before { left:-38px; } .ticket-perf::after { right:-38px; }

        .ticket-body { padding:22px 26px; display:flex; gap:20px; flex-wrap:wrap; }
        .ticket-grid { flex:1; min-width:240px; display:grid; grid-template-columns:1fr 1fr; gap:14px 18px; }
        .tk-item .tk-label { font-size:.7rem; color:#94a3b8; text-transform:uppercase; letter-spacing:.05em; margin-bottom:2px; }
        .tk-item .tk-value { font-weight:700; color:var(--bk-navy); font-size:.96rem; }
        .tk-seat { display:inline-block; background:#eff6ff; color:var(--bk-primary); border:1px solid #bfdbfe;
            border-radius:7px; padding:2px 9px; font-weight:700; font-size:.84rem; margin:2px 4px 0 0; font-family:ui-monospace,Menlo,Consolas,monospace; }
        .ticket-qr { text-align:center; flex-shrink:0; }
        .ticket-qr .qr-box { display:inline-block; padding:8px; background:#fff; border:1px solid #e5e7eb; border-radius:10px; }
        .ticket-qr .qr-box img { display:block; width:150px; height:150px; }
        .ticket-qr .qr-hint { font-size:.72rem; color:#94a3b8; margin-top:6px; max-width:150px; }

        .ticket-foot { border-top:1px solid #f1f5f9; padding:16px 26px; display:flex; flex-wrap:wrap; gap:14px;
            justify-content:space-between; align-items:flex-end; }
        .ft-label { font-size:.7rem; color:#94a3b8; text-transform:uppercase; letter-spacing:.05em; }
        .ft-code { font-family:ui-monospace,Menlo,Consolas,monospace; font-weight:800; color:var(--bk-navy); font-size:1rem; letter-spacing:.04em; }
        .ft-total { font-weight:800; color:var(--bk-primary); font-size:1.25rem; }

        .cf-actions { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; margin:1.5rem 0 .5rem; }
        .cf-note { max-width:620px; margin:1rem auto 0; background:#eff6ff; border:1px solid #cfe0fb; color:#1e40af;
            border-radius:10px; padding:.7rem 1rem; font-size:.84rem; display:flex; gap:.5rem; align-items:flex-start; }

        /* Error card */
        .cf-error { max-width:480px; margin:2rem auto; background:#fff; border-radius:16px; overflow:hidden;
            box-shadow:0 4px 24px rgba(0,0,0,.08); }
        .cf-error-top { background:linear-gradient(135deg,#7f1d1d,#b91c1c); color:#fff; text-align:center; padding:2rem 1.5rem; }
    </style>
</head>
<body class="bk-page">

<jsp:include page="../common/header.jsp"/>

<%-- ===== Stepper (5/5 Confirm) ===== --%>
<div class="container bk-wrap pt-4">
    <div class="bk-steps">
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Showtime</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Seats</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Review</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Payment</div>
        <div class="bk-line done"></div>
        <div class="bk-step active"><span class="bk-dot">5</span>Confirm</div>
    </div>
</div>

<div class="container px-3 pb-5">
<c:choose>
<c:when test="${not empty booking and booking.status eq 'CONFIRMED'}">

    <%-- Convert LocalDateTime -> Date de fmt:formatDate (chi khi co ticket) --%>
    <%
        com.mbcms.model.BookingTicket _t =
            (com.mbcms.model.BookingTicket) request.getAttribute("ticket");
        if (_t != null && _t.getStartTime() != null) {
            pageContext.setAttribute("startDate",
                java.util.Date.from(_t.getStartTime()
                    .atZone(java.time.ZoneId.systemDefault()).toInstant()));
        }
    %>

    <div class="cf-hero">
        <div class="cf-check"><i class="bi bi-check-lg"></i></div>
        <h2>Booking Confirmed!</h2>
        <p>
            <c:choose>
                <c:when test="${not empty ticket.customerEmail}">Your e-ticket has been sent to <strong>${ticket.customerEmail}</strong></c:when>
                <c:when test="${not empty sessionScope.currentUser.email}">Your e-ticket has been sent to <strong>${sessionScope.currentUser.email}</strong></c:when>
                <c:otherwise>Your booking is confirmed. Enjoy the show!</c:otherwise>
            </c:choose>
        </p>
    </div>

    <div class="ticket">
        <%-- ===== Top: movie + status ===== --%>
        <div class="ticket-top">
            <c:choose>
                <c:when test="${not empty ticket.posterUrl}">
                    <img class="ticket-poster" src="${ticket.posterUrl}" alt="poster">
                </c:when>
                <c:otherwise><div class="ticket-poster"><i class="bi bi-film"></i></div></c:otherwise>
            </c:choose>
            <div class="flex-grow-1">
                <div class="ticket-kicker">MBCMS · Admit One · E-Ticket</div>
                <div class="ticket-title">
                    <c:choose>
                        <c:when test="${not empty ticket.movieTitle}">${ticket.movieTitle}</c:when>
                        <c:otherwise>Movie ticket</c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <c:if test="${not empty ticket.movieRated}"><span class="ticket-badge rated">${ticket.movieRated}</span></c:if>
                    <c:if test="${not empty ticket.format}"><span class="ticket-badge">${ticket.format}</span></c:if>
                    <c:if test="${not empty ticket.subtitleType}">
                        <span class="ticket-badge">
                            <c:choose>
                                <c:when test="${ticket.subtitleType eq 'SUB'}">Subtitled</c:when>
                                <c:when test="${ticket.subtitleType eq 'DUB'}">Dubbed</c:when>
                                <c:otherwise>Original</c:otherwise>
                            </c:choose>
                        </span>
                    </c:if>
                    <c:if test="${ticket.durationMin > 0}"><span class="ticket-badge">${ticket.durationMin} min</span></c:if>
                </div>
            </div>
            <span class="ticket-status"><i class="bi bi-check-circle-fill"></i> CONFIRMED</span>
        </div>

        <div class="ticket-perf"></div>

        <%-- ===== Body: details + QR ===== --%>
        <div class="ticket-body">
            <div class="ticket-grid">
                <div class="tk-item">
                    <div class="tk-label">Date</div>
                    <div class="tk-value">
                        <c:choose>
                            <c:when test="${not empty startDate}"><fmt:formatDate value="${startDate}" pattern="EEE, dd MMM yyyy"/></c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="tk-item">
                    <div class="tk-label">Time</div>
                    <div class="tk-value">
                        <c:choose>
                            <c:when test="${not empty startDate}"><fmt:formatDate value="${startDate}" pattern="HH:mm"/></c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="tk-item">
                    <div class="tk-label">Cinema</div>
                    <div class="tk-value">${not empty ticket.branchName ? ticket.branchName : '—'}</div>
                </div>
                <div class="tk-item">
                    <div class="tk-label">Room</div>
                    <div class="tk-value">${not empty ticket.roomName ? ticket.roomName : '—'}</div>
                </div>
                <div class="tk-item" style="grid-column:1 / -1;">
                    <div class="tk-label">Seats</div>
                    <div class="tk-value">
                        <c:choose>
                            <c:when test="${not empty ticket.seatLabels}">
                                <c:forEach var="lbl" items="${ticket.seatLabels}"><span class="tk-seat">${lbl}</span></c:forEach>
                            </c:when>
                            <c:when test="${not empty booking.seatLabels}">
                                <c:forEach var="lbl" items="${booking.seatLabels}"><span class="tk-seat">${lbl}</span></c:forEach>
                            </c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <div class="ticket-qr">
                <div class="qr-box">
                    <img src="${pageContext.request.contextPath}/booking/qr?bookingId=${booking.bookingId}"
                         alt="QR ${booking.bookingCode}">
                </div>
                <div class="qr-hint">Scan at the entrance to check in</div>
            </div>
        </div>

        <%-- ===== Footer: code + customer + total ===== --%>
        <div class="ticket-foot">
            <div>
                <div class="ft-label">Booking Code</div>
                <div class="ft-code">${booking.bookingCode}</div>
            </div>
            <c:if test="${not empty ticket.customerFullName}">
                <div>
                    <div class="ft-label">Customer</div>
                    <div class="fw-semibold" style="color:var(--bk-navy);">${ticket.customerFullName}</div>
                </div>
            </c:if>
            <div class="text-end">
                <div class="ft-label">Total Paid</div>
                <div class="ft-total"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/>₫</div>
            </div>
        </div>
    </div>

    <div class="cf-actions">
        <a href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${booking.bookingId}"
           class="btn btn-outline-primary"><i class="bi bi-receipt"></i> View Receipt</a>
        <a href="${pageContext.request.contextPath}/customer/booking/history"
           class="btn btn-outline-secondary"><i class="bi bi-calendar2-week"></i> My Bookings</a>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary"><i class="bi bi-house"></i> Back to Home</a>
    </div>

    <div class="cf-note">
        <i class="bi bi-info-circle-fill"></i>
        <span>Please arrive at least <strong>15 minutes</strong> before showtime. Show this QR code (or your booking code
            <strong>${booking.bookingCode}</strong>) at the entrance.</span>
    </div>

</c:when>

<%-- ===== ERROR / NOT FOUND ===== --%>
<c:otherwise>
    <div class="cf-error">
        <div class="cf-error-top">
            <div style="font-size:2.5rem;"><i class="bi bi-exclamation-triangle-fill"></i></div>
            <h2 class="fw-bold mt-2 mb-1" style="font-size:1.3rem;">Booking Not Found</h2>
            <p class="mb-0" style="color:#fca5a5; font-size:.9rem;">We couldn't retrieve your booking details.</p>
        </div>
        <div class="p-4 text-center">
            <c:if test="${not empty errorMessage}">
                <p class="text-muted mb-4" style="font-size:.9rem;">${errorMessage}</p>
            </c:if>
            <div class="d-flex gap-2 justify-content-center flex-wrap">
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Back to Home</a>
                <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn btn-outline-secondary">My Bookings</a>
            </div>
        </div>
    </div>
</c:otherwise>
</c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
