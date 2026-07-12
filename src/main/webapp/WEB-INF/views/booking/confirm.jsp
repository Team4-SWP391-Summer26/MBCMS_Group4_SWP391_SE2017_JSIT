<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="en_US"/>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
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
    <title>Booking Confirmed – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/booking.css?v=${applicationScope.assetVersion}" rel="stylesheet">
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
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Food &amp; Drinks</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Review</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Payment</div>
        <div class="bk-line done"></div>
        <div class="bk-step active"><span class="bk-dot">6</span>Confirm</div>
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
                com.mbcms.util.DateTimeUtil.vietnamLocalToDate(_t.getStartTime()));
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
                    <img class="ticket-poster" src="<c:url value='${ticket.posterUrl}'/>" alt="poster">
                </c:when>
                <c:otherwise><div class="ticket-poster"><i class="bi bi-film"></i></div></c:otherwise>
            </c:choose>
            <div class="flex-grow-1">
                <div class="ticket-kicker">PentaPlex · Admit One · E-Ticket</div>
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
                            <c:when test="${not empty startDate}"><fmt:formatDate value="${startDate}" pattern="h:mm a"/></c:when>
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
                <div class="tk-item is-wide">
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
                    <div class="fw-semibold ft-customer">${ticket.customerFullName}</div>
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
            <div class="cf-error-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
            <h2 class="fw-bold mt-2 mb-1 cf-error-title">Booking Not Found</h2>
            <p class="mb-0 cf-error-copy">We couldn't retrieve your booking details.</p>
        </div>
        <div class="p-4 text-center">
            <c:if test="${not empty errorMessage}">
                <p class="text-muted mb-4 cf-error-detail">${errorMessage}</p>
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
