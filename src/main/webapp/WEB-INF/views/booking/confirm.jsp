<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Booking Confirmed – MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* ── Confirm card ── */
            .confirm-wrapper {
                min-height: 70vh;
                display: flex;
                align-items: center;
                padding: 3rem 0;
            }
            .confirm-card {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 4px 24px rgba(0,0,0,.1);
                border: 1px solid #f1f5f9;
                overflow: hidden;
                max-width: 540px;
                margin: 0 auto;
                width: 100%;
            }

            /* ── Success header ── */
            .confirm-success-top {
                background: linear-gradient(135deg, #065f46, #047857);
                padding: 2rem 1.5rem;
                text-align: center;
            }
            .confirm-success-top .check-anim {
                width: 64px;
                height: 64px;
                background: rgba(255,255,255,.15);
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 2rem;
                margin-bottom: 12px;
                animation: popIn .4s cubic-bezier(.34,1.56,.64,1) both;
            }
            @keyframes popIn {
                from {
                    opacity:0;
                    transform: scale(.5);
                }
                to   {
                    opacity:1;
                    transform: scale(1);
                }
            }
            .confirm-success-top h2 {
                color: #fff;
                font-weight: 800;
                font-size: 1.4rem;
                margin: 0 0 4px;
            }
            .confirm-success-top p {
                color: #a7f3d0;
                font-size: 0.88rem;
                margin: 0;
            }

            /* ── Error header ── */
            .confirm-error-top {
                background: linear-gradient(135deg, #7f1d1d, #b91c1c);
                padding: 2rem 1.5rem;
                text-align: center;
            }
            .confirm-error-top .error-icon {
                font-size: 2.5rem;
                margin-bottom: 10px;
            }
            .confirm-error-top h2 {
                color: #fff;
                font-weight: 800;
                font-size: 1.3rem;
                margin: 0 0 4px;
            }
            .confirm-error-top p {
                color: #fca5a5;
                font-size: 0.88rem;
                margin: 0;
            }

            /* ── Booking code box ── */
            .code-box {
                background: #eff6ff;
                border: 2px dashed #bfdbfe;
                border-radius: 10px;
                padding: 14px 20px;
                text-align: center;
                margin: 1.5rem 0;
            }
            .code-box .label {
                font-size: 0.78rem;
                color: #6b7280;
                font-weight: 600;
                letter-spacing: 0.08em;
                text-transform: uppercase;
                margin-bottom: 4px;
            }
            .code-box .code {
                font-family: monospace;
                font-weight: 800;
                font-size: 1.6rem;
                color: #1d4ed8;
                letter-spacing: 0.1em;
            }

            /* ── Info rows ── */
            .info-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 9px 0;
                border-bottom: 1px solid #f1f5f9;
                font-size: 0.9rem;
            }
            .info-row:last-child {
                border-bottom: none;
            }
            .info-row .lbl {
                color: #6b7280;
            }
            .info-row .val {
                font-weight: 600;
                color: #1e293b;
            }
            .info-row.total-row .lbl {
                font-weight: 700;
                font-size: 0.95rem;
                color: #1e293b;
            }
            .info-row.total-row .val {
                font-weight: 800;
                font-size: 1.05rem;
                color: #1d4ed8;
            }
            .info-row.discount-row .val {
                color: #16a34a;
                font-weight: 700;
            }

            /* ── Seat badge ── */
            .seat-badge {
                display: inline-block;
                background: #eff6ff;
                color: #1d4ed8;
                border: 1px solid #bfdbfe;
                border-radius: 6px;
                padding: 2px 8px;
                font-size: 0.8rem;
                font-weight: 700;
                margin: 2px 2px 2px 0;
                font-family: monospace;
            }

            /* ── Action buttons ── */
            .btn-home-primary {
                background: #2563eb;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 11px 28px;
                font-weight: 700;
                font-size: 0.95rem;
                text-decoration: none;
                transition: background 0.15s;
                display: inline-block;
            }
            .btn-home-primary:hover {
                background: #1d4ed8;
                color: #fff;
            }
            .btn-history-link {
                color: #6b7280;
                text-decoration: none;
                font-size: 0.88rem;
                font-weight: 500;
                transition: color 0.15s;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }
            .btn-history-link:hover {
                color: #2563eb;
            }
        </style>
    </head>
    <body>

        <jsp:include page="../common/header.jsp"/>

        <div class="confirm-wrapper">
            <div class="container px-3">
                <c:choose>

                    <%-- ══ SUCCESS STATE ══ --%>
                    <c:when test="${not empty booking and booking.status eq 'CONFIRMED'}">
                        <div class="confirm-card">

                            <!-- Green top banner -->
                            <div class="confirm-success-top">
                                <div class="check-anim">✓</div>
                                <h2>Payment Successful!</h2>
                                <p>Your booking is confirmed. Enjoy the show!</p>
                            </div>

                            <!-- Body -->
                            <div class="p-4">

                                <!-- Booking code -->
                                <div class="code-box">
                                    <div class="label">Your Booking Code</div>
                                    <div class="code">${booking.bookingCode}</div>
                                </div>

                                <!-- Info rows -->
                                <div class="mb-3">
                                    <div class="info-row">
                                        <span class="lbl">Showtime</span>
                                        <span class="val">#${booking.showtimeId}</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="lbl">Seats</span>
                                        <span class="val">
                                            <c:forEach var="sid" items="${booking.seatIds}" varStatus="st">
                                                <span class="seat-badge">#${sid}</span>
                                            </c:forEach>
                                        </span>
                                    </div>
                                    <div class="info-row">
                                        <span class="lbl">Subtotal</span>
                                        <span class="val"><fmt:formatNumber value="${booking.subtotal}" pattern="#,###"/> ₫</span>
                                    </div>
                                    <c:if test="${booking.discountAmount > 0}">
                                        <div class="info-row discount-row">
                                            <span class="lbl">Discount</span>
                                            <span class="val">− <fmt:formatNumber value="${booking.discountAmount}" pattern="#,###"/> ₫</span>
                                        </div>
                                    </c:if>
                                    <div class="info-row total-row">
                                        <span class="lbl">Total Paid</span>
                                        <span class="val"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/> ₫</span>
                                    </div>
                                </div>

                                <!-- Tip -->
                                <div style="background:#f8fafc; border-radius:8px; padding:10px 14px; font-size:0.8rem; color:#4b5563; margin-bottom:1.25rem;">
                                    💡 Present this booking code at the cinema entrance. A copy has been sent to your email.
                                </div>

                                <!-- Action buttons -->
                                <div class="d-flex flex-column align-items-center gap-3">
                                    <div class="d-flex gap-3 align-items-center flex-wrap justify-content-center">
                                        <a href="${pageContext.request.contextPath}/home" class="btn-home-primary">
                                            Back to Home
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-history-link">
                                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <rect x="3" y="4" width="18" height="18" rx="2"></rect>
                                            <line x1="16" y1="2" x2="16" y2="6"></line>
                                            <line x1="8" y1="2" x2="8" y2="6"></line>
                                            <line x1="3" y1="10" x2="21" y2="10"></line>
                                            </svg>
                                            My Bookings
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:when>

                    <%-- ══ ERROR / NOT FOUND STATE ══ --%>
                    <c:otherwise>
                        <div class="confirm-card">
                            <div class="confirm-error-top">
                                <div class="error-icon">⚠️</div>
                                <h2>Booking Not Found</h2>
                                <p>We couldn't retrieve your booking details.</p>
                            </div>
                            <div class="p-4 text-center">
                                <c:if test="${not empty errorMessage}">
                                    <p class="text-muted mb-4" style="font-size:0.9rem;">${errorMessage}</p>
                                </c:if>
                                <div class="d-flex gap-3 justify-content-center flex-wrap">
                                    <a href="${pageContext.request.contextPath}/home" class="btn-home-primary">
                                        Back to Home
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-history-link">
                                        My Bookings
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>

                </c:choose>
            </div>
        </div>

        <jsp:include page="../common/footer.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>