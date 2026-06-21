<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Cancel Booking – MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* ── Page hero ── */
            .page-hero {
                background: linear-gradient(135deg, #0f1e36 0%, #182c54 100%);
                padding: 2rem 0 1.5rem;
                margin-bottom: 2rem;
            }
            .page-hero .breadcrumb {
                margin: 0;
                padding: 0;
                background: none;
            }
            .page-hero .breadcrumb-item a {
                color: #90b4d8;
                text-decoration: none;
                font-size: 0.85rem;
            }
            .page-hero .breadcrumb-item a:hover {
                color: #fff;
            }
            .page-hero .breadcrumb-item.active {
                color: #d1d5db;
                font-size: 0.85rem;
            }
            .page-hero .breadcrumb-item + .breadcrumb-item::before {
                color: #4b6a8a;
            }

            /* ── Cancel card ── */
            .cancel-card {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 4px 24px rgba(0, 0, 0, .10);
                border: 1px solid #f1f5f9;
                overflow: hidden;
                max-width: 540px;
                margin: 0 auto;
                width: 100%;
            }

            /* ── Result header (danger / success) ── */
            .cancel-header-danger {
                background: linear-gradient(135deg, #7f1d1d, #b91c1c);
                padding: 2rem 1.5rem;
                text-align: center;
            }
            .cancel-header-success {
                background: linear-gradient(135deg, #065f46, #047857);
                padding: 2rem 1.5rem;
                text-align: center;
            }
            .cancel-icon-wrap {
                width: 64px;
                height: 64px;
                background: rgba(255, 255, 255, .15);
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 2rem;
                margin-bottom: 12px;
                animation: popIn .4s cubic-bezier(.34, 1.56, .64, 1) both;
            }
            @keyframes popIn {
                from {
                    opacity: 0;
                    transform: scale(.5);
                }
                to   {
                    opacity: 1;
                    transform: scale(1);
                }
            }
            .cancel-header-danger h2,
            .cancel-header-success h2 {
                color: #fff;
                font-weight: 700;
                font-size: 1.35rem;
                margin: 0 0 6px;
            }
            .cancel-header-danger p  {
                color: #fca5a5;
                font-size: 0.88rem;
                margin: 0;
            }
            .cancel-header-success p {
                color: #a7f3d0;
                font-size: 0.88rem;
                margin: 0;
            }

            /* ── Booking code ── */
            .booking-code {
                font-family: monospace;
                font-weight: 800;
                font-size: 1.25rem;
                color: #1d4ed8;
                letter-spacing: 0.08em;
            }

            /* ── Status pills ── */
            .status-pill {
                padding: 4px 14px;
                border-radius: 99px;
                font-size: 0.8rem;
                font-weight: 700;
                display: inline-block;
            }
            .sp-CONFIRMED {
                background: #dcfce7;
                color: #16a34a;
            }
            .sp-PENDING   {
                background: #fef3c7;
                color: #b45309;
            }
            .sp-CANCELLED {
                background: #f1f5f9;
                color: #64748b;
            }
            .sp-USED      {
                background: #ede9fe;
                color: #6d28d9;
            }

            /* ── Info rows ── */
            .info-table {
                width: 100%;
                border-collapse: collapse;
            }
            .info-table td {
                padding: 10px 0;
                vertical-align: top;
            }
            .info-table tr {
                border-bottom: 1px solid #f1f5f9;
            }
            .info-table tr:last-child {
                border-bottom: none;
            }
            .info-table .lbl {
                color: #6b7280;
                font-size: 0.85rem;
                font-weight: 600;
                width: 140px;
                padding-right: 16px;
            }
            .info-table .val {
                color: #1e293b;
                font-size: 0.9rem;
                font-weight: 500;
            }

            /* ── Seat badge ── */
            .seat-badge {
                display: inline-block;
                background: #eff6ff;
                color: #1d4ed8;
                border: 1px solid #bfdbfe;
                border-radius: 6px;
                padding: 2px 10px;
                font-size: 0.82rem;
                font-weight: 700;
                margin: 2px 3px 2px 0;
                font-family: monospace;
            }

            /* ── Price rows ── */
            .price-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-size: 0.9rem;
                padding: 7px 0;
            }
            .price-row .lbl {
                color: #6b7280;
            }
            .price-row.total-row {
                border-top: 2px solid #e5e7eb;
                margin-top: 6px;
                padding-top: 12px;
                font-weight: 700;
                font-size: 1.05rem;
            }
            .price-row.total-row .val {
                color: #1d4ed8;
            }

            /* ── Error notice ── */
            .error-notice {
                background: #fef2f2;
                border: 1px solid #fca5a5;
                border-radius: 10px;
                padding: 14px 18px;
                display: flex;
                align-items: flex-start;
                gap: 10px;
                margin-bottom: 1.25rem;
            }
            .error-notice .icon {
                font-size: 1.2rem;
                flex-shrink: 0;
                margin-top: 1px;
            }
            .error-notice .text strong {
                color: #991b1b;
                font-size: 0.88rem;
                display: block;
            }
            .error-notice .text span   {
                color: #7f1d1d;
                font-size: 0.82rem;
            }

            /* ── Cancelled stamp ── */
            .cancelled-stamp {
                display: inline-block;
                border: 2.5px solid #9ca3af;
                border-radius: 6px;
                color: #6b7280;
                font-weight: 800;
                font-size: 1rem;
                letter-spacing: 0.15em;
                padding: 4px 14px;
                transform: rotate(-4deg);
                opacity: 0.75;
                text-transform: uppercase;
                margin-bottom: 0.25rem;
            }

            /* ── Action buttons ── */
            .btn-cancel-booking {
                background: #fff;
                color: #dc2626;
                border: 1.5px solid #fca5a5;
                border-radius: 8px;
                padding: 10px 22px;
                font-weight: 600;
                font-size: 0.9rem;
                cursor: pointer;
                transition: all 0.15s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-cancel-booking:hover {
                background: #fef2f2;
                border-color: #dc2626;
                color: #b91c1c;
            }
            .btn-primary-lc {
                background: #2563eb;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 10px 22px;
                font-weight: 600;
                font-size: 0.9rem;
                cursor: pointer;
                transition: background 0.15s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-primary-lc:hover {
                background: #1d4ed8;
                color: #fff;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <!-- Page hero / breadcrumb -->
        <div class="page-hero">
            <div class="container" style="max-width: 580px;">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/home">Home</a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/customer/booking/history">My Bookings</a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${booking.bookingId}">Booking Detail</a>
                        </li>
                        <li class="breadcrumb-item active">Cancel</li>
                    </ol>
                </nav>
            </div>
        </div>

        <div class="container pb-5" style="max-width: 580px;">

            <%
                /* Convert LocalDateTime → java.util.Date for fmt:formatDate */
                com.mbcms.model.Booking bk = (com.mbcms.model.Booking) request.getAttribute("booking");
                if (bk != null && bk.getCreatedAt() != null) {
                    java.util.Date d = java.util.Date.from(
                        bk.getCreatedAt().atZone(java.time.ZoneId.systemDefault()).toInstant()
                    );
                    pageContext.setAttribute("createdAtDate", d);
                }
            %>

            <div class="cancel-card">

                <!-- ── Case A: cancellation just succeeded ── -->
                <c:if test="${param.cancelled == '1' || booking.status == 'CANCELLED'}">

                    <div class="cancel-header-success">
                        <div class="cancel-icon-wrap">✓</div>
                        <h2>Booking Cancelled</h2>
                        <p>Your booking has been cancelled and your seats have been released.</p>
                    </div>

                    <div class="p-4">

                        <div class="text-center mb-4">
                            <div class="cancelled-stamp">Cancelled</div>
                            <div class="booking-code mt-2">${booking.bookingCode}</div>
                            <div style="font-size: 0.8rem; color: #9ca3af; margin-top: 2px;">Booking Code</div>
                        </div>

                        <table class="info-table mb-4">
                            <tr>
                                <td class="lbl">Showtime</td>
                                <td class="val">#${booking.showtimeId}</td>
                            </tr>
                            <tr>
                                <td class="lbl">Booked on</td>
                                <td class="val">
                                    <fmt:formatDate value="${createdAtDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                            </tr>
                            <tr>
                                <td class="lbl">Seats</td>
                                <td class="val">
                                    <c:forEach var="seatId" items="${booking.seatIds}">
                                        <span class="seat-badge">Seat #${seatId}</span>
                                    </c:forEach>
                                </td>
                            </tr>
                            <tr>
                                <td class="lbl">Status</td>
                                <td class="val">
                                    <span class="status-pill sp-CANCELLED">CANCELLED</span>
                                </td>
                            </tr>
                        </table>

                        <!-- Price breakdown (read-only reference) -->
                        <div style="background: #f8fafc; border-radius: 10px; padding: 16px 18px; margin-bottom: 1.5rem;">
                            <div class="price-row">
                                <span class="lbl">Subtotal</span>
                                <span class="val"><fmt:formatNumber value="${booking.subtotal}" pattern="#,###"/> ₫</span>
                            </div>
                            <c:if test="${booking.discountAmount != null && booking.discountAmount > 0}">
                                <div class="price-row">
                                    <span class="lbl">Discount</span>
                                    <span class="val" style="color: #16a34a; font-weight: 600;">
                                        − <fmt:formatNumber value="${booking.discountAmount}" pattern="#,###"/> ₫
                                    </span>
                                </div>
                            </c:if>
                            <div class="price-row total-row">
                                <span>Total (refund reference)</span>
                                <span class="val"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/> ₫</span>
                            </div>
                        </div>

                        <div style="font-size: 0.82rem; color: #6b7280; background: #f8fafc;
                             border-radius: 8px; padding: 12px 14px; margin-bottom: 1.5rem; line-height: 1.6;">
                            💡 If you paid online, a refund will be processed according to our refund policy within
                            <strong>3–5 business days</strong>.
                            Contact <a href="mailto:group4mbcms@gmail.com" style="color: #2563eb;">group4mbcms@gmail.com</a>
                            if you have any questions.
                        </div>

                        <div class="d-flex flex-wrap gap-2">
                            <a href="${pageContext.request.contextPath}/customer/booking/history"
                               class="btn-primary-lc">
                                ← Back to My Bookings
                            </a>
                            <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING"
                               class="btn btn-outline-secondary" style="border-radius: 8px; font-size: 0.9rem; font-weight: 600;">
                                Browse Movies
                            </a>
                        </div>
                    </div>
                </c:if>

                <!-- ── Case B: cancel failed / not cancellable ── -->
                <c:if test="${not empty param.cancelErr}">

                    <div class="cancel-header-danger">
                        <div class="cancel-icon-wrap">✕</div>
                        <h2>Cancellation Failed</h2>
                        <p>We couldn't cancel this booking.</p>
                    </div>

                    <div class="p-4">

                        <!-- Error detail -->
                        <div class="error-notice mb-4">
                            <div class="icon">⛔</div>
                            <div class="text">
                                <c:choose>
                                    <c:when test="${param.cancelErr == 'NOT_CANCELLABLE'}">
                                        <strong>Booking cannot be cancelled</strong>
                                        <span>
                                            Only bookings with status <strong>PENDING</strong> or
                                            <strong>CONFIRMED</strong> can be cancelled, and only by the original customer.
                                            This booking may have already been used, cancelled, or belongs to another account.
                                        </span>
                                    </c:when>
                                    <c:when test="${param.cancelErr == 'SYSTEM'}">
                                        <strong>System error</strong>
                                        <span>
                                            An unexpected error occurred while processing your request.
                                            Please try again later or contact support.
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <strong>Unknown error</strong>
                                        <span>Something went wrong. Please try again or contact support.</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Booking summary (so user can see which booking failed) -->
                        <c:if test="${not empty booking}">
                            <div style="border: 1px solid #f1f5f9; border-radius: 10px; padding: 16px 18px; margin-bottom: 1.5rem;">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div>
                                        <div class="booking-code">${booking.bookingCode}</div>
                                        <div style="font-size: 0.78rem; color: #9ca3af; margin-top: 2px;">Booking Code</div>
                                    </div>
                                    <span class="status-pill sp-${booking.status}">${booking.status}</span>
                                </div>
                                <table class="info-table">
                                    <tr>
                                        <td class="lbl">Showtime</td>
                                        <td class="val">#${booking.showtimeId}</td>
                                    </tr>
                                    <tr>
                                        <td class="lbl">Seats</td>
                                        <td class="val">
                                            <c:forEach var="seatId" items="${booking.seatIds}">
                                                <span class="seat-badge">Seat #${seatId}</span>
                                            </c:forEach>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </c:if>

                        <div class="d-flex flex-wrap gap-2">
                            <a href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${booking.bookingId}"
                               class="btn-primary-lc">
                                ← Back to Booking Detail
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/booking/history"
                               class="btn btn-outline-secondary" style="border-radius: 8px; font-size: 0.9rem; font-weight: 600;">
                                My Bookings
                            </a>
                        </div>
                    </div>
                </c:if>

                <!-- ── Case C: direct GET with no result params — show confirmation form ── -->
                <c:if test="${empty param.cancelled && empty param.cancelErr && booking.status != 'CANCELLED'}">

                    <div class="cancel-header-danger">
                        <div class="cancel-icon-wrap">⚠️</div>
                        <h2>Cancel Your Booking?</h2>
                        <p>Please review the details below before confirming.</p>
                    </div>

                    <div class="p-4">

                        <!-- Booking summary -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <div class="booking-code">${booking.bookingCode}</div>
                                <div style="font-size: 0.78rem; color: #9ca3af; margin-top: 2px;">Booking Code</div>
                            </div>
                            <span class="status-pill sp-${booking.status}">${booking.status}</span>
                        </div>

                        <table class="info-table mb-4">
                            <tr>
                                <td class="lbl">Showtime</td>
                                <td class="val">#${booking.showtimeId}</td>
                            </tr>
                            <tr>
                                <td class="lbl">Booked on</td>
                                <td class="val">
                                    <fmt:formatDate value="${createdAtDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                            </tr>
                            <tr>
                                <td class="lbl">Seats</td>
                                <td class="val">
                                    <c:forEach var="seatId" items="${booking.seatIds}">
                                        <span class="seat-badge">Seat #${seatId}</span>
                                    </c:forEach>
                                </td>
                            </tr>
                            <c:if test="${not empty booking.notes}">
                                <tr>
                                    <td class="lbl">Notes</td>
                                    <td class="val">${booking.notes}</td>
                                </tr>
                            </c:if>
                        </table>

                        <!-- Price breakdown -->
                        <div style="background: #f8fafc; border-radius: 10px; padding: 16px 18px; margin-bottom: 1.5rem;">
                            <div class="price-row">
                                <span class="lbl">Subtotal</span>
                                <span class="val"><fmt:formatNumber value="${booking.subtotal}" pattern="#,###"/> ₫</span>
                            </div>
                            <c:if test="${booking.discountAmount != null && booking.discountAmount > 0}">
                                <div class="price-row">
                                    <span class="lbl">Discount</span>
                                    <span class="val" style="color: #16a34a; font-weight: 600;">
                                        − <fmt:formatNumber value="${booking.discountAmount}" pattern="#,###"/> ₫
                                    </span>
                                </div>
                            </c:if>
                            <div class="price-row total-row">
                                <span>Total paid</span>
                                <span class="val"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/> ₫</span>
                            </div>
                        </div>

                        <!-- Warning -->
                        <div style="font-size: 0.82rem; color: #78350f; background: #fffbeb;
                             border: 1px solid #fde68a; border-radius: 8px;
                             padding: 12px 14px; margin-bottom: 1.5rem; line-height: 1.6;">
                            ⚠️ <strong>This action is irreversible.</strong>
                            Your seats will be immediately released and made available to other customers.
                        </div>

                        <!-- Action buttons -->
                        <div class="d-flex flex-wrap gap-2">
                            <a href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${booking.bookingId}"
                               class="btn btn-outline-secondary flex-fill text-center"
                               style="border-radius: 8px; font-size: 0.9rem; font-weight: 600; padding: 10px;">
                                Keep My Booking
                            </a>

                            <form action="${pageContext.request.contextPath}/customer/booking/cancel"
                                  method="post" class="flex-fill m-0">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                                <button type="submit" class="btn-cancel-booking w-100" style="justify-content: center;">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                         stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                    <line x1="18" y1="6" x2="6" y2="18"></line>
                                    <line x1="6" y1="6" x2="18" y2="18"></line>
                                    </svg>
                                    Yes, Cancel Booking
                                </button>
                            </form>
                        </div>

                    </div>
                </c:if>

            </div><!-- /.cancel-card -->
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
