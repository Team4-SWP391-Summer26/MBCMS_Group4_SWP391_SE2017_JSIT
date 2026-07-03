<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Booking Details – PentaPlex</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}">
        <style>
            .back-link {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                color: var(--text-muted);
                text-decoration: none;
                font-size: .9rem;
                font-weight: 600;
                margin-bottom: 1.25rem;
            }
            .back-link:hover { color: var(--primary); }

            .success-banner {
                background: #dcfce7;
                border: 1px solid #86efac;
                border-radius: 12px;
                padding: 1rem 1.25rem;
                text-align: center;
                margin-bottom: 1.5rem;
            }
            .success-banner .title { color: #15803d; font-weight: 700; font-size: 1.05rem; }
            .success-banner .sub   { color: #166534; font-size: .85rem; margin-top: 2px; }

            .ticket-card {
                background: var(--bg-card);
                border-radius: 16px;
                box-shadow: 0 4px 24px rgba(15,30,54,.08);
                overflow: hidden;
            }
            .ticket-header {
                background: linear-gradient(135deg, var(--navy) 0%, #182c54 100%);
                color: #fff;
                padding: 24px 28px;
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                flex-wrap: wrap;
                gap: 12px;
            }
            .ticket-header .code-label {
                font-size: .72rem;
                color: #93c5fd;
                letter-spacing: .1em;
                text-transform: uppercase;
            }
            .ticket-header .code-value {
                font-family: 'Courier New', monospace;
                font-weight: 800;
                font-size: 1.4rem;
                letter-spacing: .05em;
                margin-top: 2px;
            }

            .status-chip {
                font-size: .78rem;
                font-weight: 700;
                padding: 5px 14px;
                border-radius: 999px;
                white-space: nowrap;
            }
            .chip-CONFIRMED { background: #dcfce7; color: #15803d; }
            .chip-PENDING   { background: #fef3c7; color: #b45309; }
            .chip-CANCELLED { background: var(--border); color: #4b5563; }
            .chip-USED      { background: #e0e7ff; color: #4338ca; }

            /* ── Pickup status tracker ── */
            .pickup-track { position: relative; display: flex; justify-content: space-between; padding-top: 2px; }
            .pickup-line, .pickup-line-fill { position: absolute; top: 12px; height: 3px; border-radius: 999px; }
            .pickup-line { left: 12.5%; right: 12.5%; background: var(--border-strong); }
            .pickup-line-fill { left: 12.5%; width: calc(75% * var(--pk-frac, 0)); background: var(--success); transition: width .35s ease; }
            .pk-step { position: relative; z-index: 2; flex: 1; display: flex; flex-direction: column; align-items: center; }
            .pk-dot { width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: .7rem; font-weight: 700; background: var(--border-strong); color: #fff; }
            .pk-step.done .pk-dot { background: var(--success); }
            .pk-step.active .pk-dot { background: var(--primary); box-shadow: 0 0 0 4px rgba(37, 99, 235, .18); }
            .pk-label { font-size: .68rem; margin-top: .35rem; color: var(--text-muted); }
            .pk-step.done .pk-label, .pk-step.active .pk-label { color: var(--text); font-weight: 600; }

            .ticket-divider {
                position: relative;
                height: 0;
                border-top: 2px dashed var(--border);
                margin: 0 28px;
            }
            .ticket-divider::before, .ticket-divider::after {
                content: '';
                position: absolute;
                top: -11px;
                width: 22px;
                height: 22px;
                background: var(--bg-dark);
                border-radius: 50%;
            }
            .ticket-divider::before { left: -39px; }
            .ticket-divider::after  { right: -39px; }

            .ticket-body { padding: 24px 28px; }

            .detail-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 18px 24px;
                margin-bottom: 20px;
            }
            .detail-item .label {
                font-size: .76rem;
                color: var(--text-muted);
                text-transform: uppercase;
                letter-spacing: .04em;
                margin-bottom: 3px;
            }
            .detail-item .value {
                font-weight: 700;
                color: var(--text-dark);
                font-size: .98rem;
            }

            .seat-pill {
                display: inline-block;
                background: var(--primary-50);
                color: var(--primary);
                border: 1px solid var(--primary-200);
                border-radius: 8px;
                padding: 4px 12px;
                font-weight: 700;
                font-size: .85rem;
                margin: 2px 4px 2px 0;
            }

            .price-line {
                display: flex;
                justify-content: space-between;
                padding: 7px 0;
                font-size: .92rem;
                color: var(--text-dark);
            }
            .price-line.discount { color: var(--success); }
            .price-line.total {
                font-weight: 800;
                font-size: 1.15rem;
                border-top: 2px solid var(--border);
                margin-top: 6px;
                padding-top: 14px;
                color: var(--primary);
            }

            .notes-box {
                background: #f9fafb;
                border-radius: 8px;
                padding: 10px 14px;
                font-size: .88rem;
                color: var(--text-dark);
                margin-top: 6px;
            }

            .action-bar {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
                padding: 18px 28px 26px;
            }
            .btn-primary-lc, .btn-cancel-lc {
                border-radius: 9px;
                padding: 10px 22px;
                font-weight: 700;
                font-size: .92rem;
                text-decoration: none;
                border: none;
                cursor: pointer;
                transition: all .15s;
            }
            .btn-cancel-lc {
                background: #fff;
                color: var(--danger);
                border: 1.5px solid #fca5a5;
            }
            .btn-cancel-lc:hover {
                background: #fef2f2;
                border-color: var(--danger);
            }

            .modal-overlay {
                position: fixed;
                inset: 0;
                background: rgba(15,23,42,.55);
                z-index: 999;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 16px;
            }
            .modal-box {
                background: #fff;
                border-radius: 14px;
                padding: 26px;
                max-width: 420px;
                width: 100%;
                box-shadow: 0 20px 60px rgba(0,0,0,.3);
            }
        </style>
    </head>
    <body>
        <jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <div class="container py-4" style="max-width: 680px;">

            <a href="${pageContext.request.contextPath}/customer/booking/history" class="back-link">&#8592; My Bookings</a>

            <c:if test="${confirmed}">
                <div class="success-banner">
                    <div class="title">Booking confirmed!</div>
                    <div class="sub">Thank you. Please present your ticket code at the cinema entrance.</div>
                </div>
            </c:if>

            <c:if test="${foodAdded}">
                <div class="success-banner" style="background:#e0f2fe; border-color:#bae6fd;">
                    <div class="title" style="color:#0369a1;">Concessions saved!</div>
                    <div class="sub" style="color:#075985;">Please pay for concessions at the counter when you pick them up.</div>
                </div>
            </c:if>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger border-0 mb-3" style="border-radius: 10px; font-size: .9rem;">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>

            <div class="ticket-card">
                <div class="ticket-header">
                    <div>
                        <div class="code-label">Booking Code</div>
                        <div class="code-value">${booking.bookingCode}</div>
                    </div>
                    <span class="status-chip chip-${booking.status}">${booking.status}</span>
                </div>

                <div class="ticket-divider"></div>

                <div class="ticket-body">
                    <div class="detail-grid">
                        <div class="detail-item">
                            <div class="label">Showtime</div>
                            <div class="value">#${booking.showtimeId}</div>
                        </div>
                        <div class="detail-item">
                            <div class="label">Booked On</div>
                            <div class="value">
                                <%
                                    java.time.LocalDateTime ldt = ((com.mbcms.model.Booking) request.getAttribute("booking")).getCreatedAt();
                                    if (ldt != null) {
                                        java.util.Date d = com.mbcms.util.DateTimeUtil.utcToVietnamDate(ldt);
                                        pageContext.setAttribute("createdAtDate", d);
                                    }
                                %>
                                <fmt:formatDate value="${createdAtDate}" pattern="dd/MM/yyyy HH:mm" timeZone="Asia/Ho_Chi_Minh"/>
                            </div>
                        </div>
                    </div>

                    <div class="detail-item mb-3">
                        <div class="label">Seats</div>
                        <div class="value mt-1">
                            <c:choose>
                                <c:when test="${not empty booking.seatLabels}">
                                    <c:forEach var="lbl" items="${booking.seatLabels}">
                                        <span class="seat-pill">${lbl}</span>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <c:if test="${booking.status == 'CONFIRMED' || booking.status == 'USED'}">
                        <div class="text-center my-3">
                            <img src="${pageContext.request.contextPath}/booking/qr?bookingId=${booking.bookingId}"
                                 alt="QR ${booking.bookingCode}" width="150" height="150"
                                 style="border:1px solid var(--border); border-radius:10px; padding:6px; background:#fff;">
                            <div style="font-size:.74rem; color:var(--text-subtle); margin-top:4px;">
                                Present this QR code at the entrance to check in
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${not empty concessions}">
                        <div class="ticket-divider" style="margin: 18px 0;"></div>
                        <div class="detail-item mb-3">
                            <div class="label">Food & Drinks Concessions</div>
                            <div class="mt-2">
                                <c:forEach var="entry" items="${concessions}">
                                    <div class="d-flex justify-content-between align-items-center mb-1 small text-dark">
                                        <span>${entry.key.name} <strong class="text-primary">x${entry.value}</strong></span>
                                        <span><fmt:formatNumber value="${entry.key.price * entry.value}" pattern="#,###"/>₫</span>
                                    </div>
                                </c:forEach>
                            </div>
                            
                            <%-- Food Order Status Tracking --%>
                            <c:if test="${not empty foodOrder}">
                                <div class="mt-3 p-3 bg-light rounded-3">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <span class="small fw-semibold text-secondary">Pickup Status:</span>
                                        <span class="badge bg-primary text-white text-uppercase" style="font-size:0.75rem;">${foodOrder.status}</span>
                                    </div>
                                    
                                    <%-- Visual status tracker --%>
                                    <c:set var="statusVal" value="1"/>
                                    <c:if test="${foodOrder.status == 'PREPARING'}"><c:set var="statusVal" value="2"/></c:if>
                                    <c:if test="${foodOrder.status == 'READY'}"><c:set var="statusVal" value="3"/></c:if>
                                    <c:if test="${foodOrder.status == 'DELIVERED'}"><c:set var="statusVal" value="4"/></c:if>

                                    <div class="pickup-track mt-3" style="--pk-frac: ${(statusVal - 1) / 3};">
                                        <div class="pickup-line"></div>
                                        <div class="pickup-line-fill"></div>
                                        <c:forEach var="s" begin="1" end="4">
                                            <div class="pk-step ${s < statusVal ? 'done' : (s == statusVal ? 'active' : '')}">
                                                <span class="pk-dot">
                                                    <c:choose>
                                                        <c:when test="${s < statusVal}"><i class="bi bi-check-lg"></i></c:when>
                                                        <c:otherwise>${s}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <span class="pk-label">
                                                    <c:choose>
                                                        <c:when test="${s == 1}">Pending</c:when>
                                                        <c:when test="${s == 2}">Preparing</c:when>
                                                        <c:when test="${s == 3}">Ready</c:when>
                                                        <c:otherwise>Delivered</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                    
                                    <c:if test="${foodOrder.status == 'PENDING' && booking.status == 'CONFIRMED'}">
                                        <div class="alert alert-warning border-0 mt-3 mb-0 py-2 small d-flex align-items-center gap-2">
                                            <i class="bi bi-info-circle-fill text-warning"></i>
                                            <span>Please pay for concessions at the counter upon pickup (unpaid order).</span>
                                        </div>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>
                    </c:if>

                    <div class="ticket-divider" style="margin: 0 0 4px;"></div>

                    <div class="price-line">
                        <span>Subtotal</span>
                        <span><fmt:formatNumber value="${booking.subtotal}" pattern="#,###"/>₫</span>
                    </div>
                    <c:if test="${booking.discountAmount != null && booking.discountAmount > 0}">
                        <div class="price-line discount">
                            <span>Discount</span>
                            <span>&minus;<fmt:formatNumber value="${booking.discountAmount}" pattern="#,###"/>₫</span>
                        </div>
                    </c:if>
                    <div class="price-line total">
                        <span>Total</span>
                        <span><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/>₫</span>
                    </div>

                    <c:if test="${not empty booking.notes}">
                        <div class="detail-item mt-3">
                            <div class="label">Notes</div>
                            <div class="notes-box">${booking.notes}</div>
                        </div>
                    </c:if>
                </div>

                <div class="action-bar d-flex justify-content-between align-items-center w-100">
                    <div>
                        <c:if test="${booking.status == 'PENDING'}">
                            <a href="${pageContext.request.contextPath}/booking/payment?bookingId=${booking.bookingId}"
                               class="btn btn-primary-lc me-2">Pay Now</a>
                            <button type="button" class="btn-cancel-lc" onclick="showCancelModal()">Cancel Booking</button>
                        </c:if>
                    </div>
                    <div>
                        <c:if test="${booking.status == 'CONFIRMED' && (empty foodOrder || foodOrder.status == 'PENDING')}">
                            <a href="${pageContext.request.contextPath}/booking/food-drinks?bookingId=${booking.bookingId}"
                               class="btn btn-outline-primary fw-bold px-3 py-2" style="border-radius:9px; font-size:.92rem; text-decoration:none;">
                                <i class="bi bi-cart-plus"></i> <c:choose><c:when test="${not empty concessions}">Modify Concessions</c:when><c:otherwise>Add Food & Drinks</c:otherwise></c:choose>
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>

        </div>

        <c:if test="${booking.status == 'PENDING'}">
            <div id="cancelOverlay" class="modal-overlay d-none" onclick="if (event.target === this) hideCancelModal()">
                <div class="modal-box">
                    <div style="font-size:2rem; text-align:center;">&#9888;</div>
                    <h5 class="text-center mt-2 mb-1">Cancel ${booking.bookingCode}?</h5>
                    <p class="text-center text-muted" style="font-size:.9rem;">
                        Your seats will be released immediately. This action cannot be undone.
                    </p>
                    <div class="d-flex gap-2 mt-3">
                        <button type="button" class="btn btn-outline-secondary flex-fill" onclick="hideCancelModal()">Keep Booking</button>
                        <form method="POST" action="${pageContext.request.contextPath}/customer/booking/cancel" class="flex-fill">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <input type="hidden" name="bookingId" value="${booking.bookingId}">
                            <button type="submit" class="btn-cancel-lc w-100">Cancel Booking</button>
                        </form>
                    </div>
                </div>
            </div>
        </c:if>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            function showCancelModal() {
                document.getElementById('cancelOverlay').classList.remove('d-none');
            }
            function hideCancelModal() {
                document.getElementById('cancelOverlay').classList.add('d-none');
            }
        </script>
    </body>
</html>
