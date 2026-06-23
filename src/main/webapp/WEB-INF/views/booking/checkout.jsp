<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    Review / Checkout (booking step 3) - owner: HungNT.
    Giao dien dong nhat voi seats / payment / confirm (--bk-* + stepper chung trong main.css).
    GIU NGUYEN cac form name/action + JS (promo, notes, cancel modal, countdown).
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Review your order – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* ===== Booking shared design (inline de khong phu thuoc cache main.css) ===== */
        :root {
            --bk-primary:#2563EB; --bk-navy:#0F1E36; --bk-border:#E6EAF2;
            --bk-muted:#64748B; --bk-light:#EFF4FF; --bk-bg:#F5F7FA;
        }
        body.bk-page { background: var(--bk-bg); }
        .bk-wrap { max-width: 1080px; }
        .bk-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px;
            box-shadow:0 4px 12px rgba(15,23,42,.05); }
        .bk-summary { position:sticky; top:18px; }
        .bk-mono { font-family:ui-monospace,Menlo,Consolas,monospace; }

        .bk-ctx { background:#fff; border-bottom:1px solid var(--bk-border); }
        .bk-poster { width:46px; height:60px; border-radius:8px; flex-shrink:0;
            background:linear-gradient(135deg,#1e293b,#0f172a); display:flex;
            align-items:center; justify-content:center; color:#FFC107; font-weight:800; font-size:1.2rem; }
        .bk-reserve { background:#FFF8E1; border:1px solid #FFE082; color:#7a5a00; border-radius:999px;
            padding:.3rem .8rem; font-size:.82rem; font-weight:600; display:inline-flex; align-items:center; gap:.4rem; white-space:nowrap; }
        .bk-reserve.danger { background:#fee2e2; border-color:#fca5a5; color:#b91c1c; }

        .bk-steps { display:flex; align-items:center; }
        .bk-step { display:flex; align-items:center; gap:.5rem; font-size:.9rem; font-weight:600; color:#94a3b8; white-space:nowrap; }
        .bk-step .bk-dot { width:26px; height:26px; border-radius:999px; display:flex; align-items:center;
            justify-content:center; font-size:.78rem; background:#E2E8F0; color:#64748b; flex-shrink:0; }
        .bk-step.done { color:#16a34a; } .bk-step.done .bk-dot { background:#16a34a; color:#fff; }
        .bk-step.active { color:var(--bk-primary); } .bk-step.active .bk-dot { background:var(--bk-primary); color:#fff; }
        .bk-line { flex:1; height:2px; background:#E2E8F0; margin:0 .5rem; min-width:12px; }
        .bk-line.done { background:#16a34a; }
        @media (max-width:640px) { .bk-step span:not(.bk-dot) { display:none; } }

        .bk-sum-line { display:flex; justify-content:space-between; align-items:center; padding:.35rem 0; font-size:.92rem; }
        .bk-sum-total { padding-top:.6rem; margin-top:.2rem; border-top:1px solid var(--bk-border); }
        .bk-seat-tag { display:inline-block; background:var(--bk-light); color:var(--bk-primary);
            border:1px solid #bfdbfe; border-radius:7px; padding:3px 10px; font-size:.82rem; font-weight:700;
            margin:2px 4px 2px 0; font-family:ui-monospace,Menlo,Consolas,monospace; }
        .bk-page .btn-primary { background:var(--bk-primary); border-color:var(--bk-primary); }
        .bk-page .btn-primary:hover { background:#1d4ed8; border-color:#1d4ed8; }

        /* Cancel modal (page-specific) */
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(15,23,42,.55); z-index: 1055;
            display: flex; align-items: center; justify-content: center; padding: 16px;
            animation: fadeInModal .2s;
        }
        .modal-box {
            background: #fff; border-radius: 14px; padding: 28px; max-width: 420px; width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,.3);
        }
        @keyframes fadeInModal { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body class="bk-page">
<jsp:include page="../common/header.jsp" />

<%-- ===== Context bar ===== --%>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <div class="bk-poster"><i class="bi bi-film"></i></div>
            <div class="flex-grow-1">
                <div class="fw-bold" style="color:var(--bk-navy);">
                    <c:choose>
                        <c:when test="${not empty booking}">Booking ${booking.bookingCode}</c:when>
                        <c:otherwise>Review your order</c:otherwise>
                    </c:choose>
                </div>
                <div class="text-muted small">Showtime #${showtimeId}</div>
            </div>
            <div class="text-end">
                <div class="text-muted small">Seats</div>
                <div class="fw-bold bk-mono" style="color:var(--bk-navy);">
                    <c:choose>
                        <c:when test="${not empty booking.seatLabels}">
                            <c:forEach var="lbl" items="${booking.seatLabels}" varStatus="s">${lbl}<c:if test="${not s.last}">, </c:if></c:forEach>
                        </c:when>
                        <c:when test="${not empty seatLabels}">
                            <c:forEach var="lbl" items="${seatLabels}" varStatus="s">${lbl}<c:if test="${not s.last}">, </c:if></c:forEach>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <c:if test="${not empty booking}">
                <span class="bk-reserve" id="reserve-pill">
                    <i class="bi bi-clock-history"></i> Reserved for <span id="countdown">--:--</span>
                </span>
            </c:if>
        </div>
    </div>
</div>

<div class="container bk-wrap py-4">

    <%-- ===== Stepper (4/6 Review) ===== --%>
    <div class="bk-steps mb-4">
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Showtime</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Seats</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Food & Drinks</div>
        <div class="bk-line done"></div>
        <div class="bk-step active"><span class="bk-dot">4</span>Review</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">5</span>Payment</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">6</span>Confirm</div>
    </div>

    <h3 class="fw-bold mb-1" style="color:var(--bk-navy);">Review your order</h3>
    <p class="text-muted mb-4">Double-check everything before you pay.</p>

    <%-- ===== Messages ===== --%>
    <c:if test="${not empty checkoutError}">
        <div class="alert alert-danger d-flex align-items-center gap-2"><i class="bi bi-exclamation-triangle-fill"></i><span>${checkoutError}</span></div>
    </c:if>
    <c:if test="${not empty pricingError}">
        <div class="alert alert-danger d-flex align-items-center gap-2"><i class="bi bi-exclamation-triangle-fill"></i><span>${pricingError}</span></div>
    </c:if>
    <c:if test="${not empty promoMessage}">
        <div class="alert alert-success d-flex align-items-center gap-2"><i class="bi bi-check-circle-fill"></i><span>${promoMessage}</span></div>
    </c:if>

    <div class="row g-4">

        <%-- ===== Left: booking details + promo ===== --%>
        <div class="col-lg-7">
            <div class="bk-card p-4 mb-4">
                <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Booking details</h6>
                <div class="bk-sum-line"><span class="text-muted">Showtime</span>
                    <span class="fw-semibold">#${showtimeId}</span></div>
                <c:if test="${not empty booking}">
                    <div class="bk-sum-line"><span class="text-muted">Booking code</span>
                        <span class="fw-semibold bk-mono">${booking.bookingCode}</span></div>
                    <div class="bk-sum-line"><span class="text-muted">Status</span>
                        <span><span class="badge bg-warning text-dark">PENDING · seats held</span></span></div>
                </c:if>
                <div class="bk-sum-line align-items-start"><span class="text-muted">Seats</span>
                    <span class="text-end">
                        <c:choose>
                            <c:when test="${not empty booking.seatLabels}">
                                <c:forEach var="lbl" items="${booking.seatLabels}"><span class="bk-seat-tag">${lbl}</span></c:forEach>
                            </c:when>
                            <c:when test="${not empty seatLabels}">
                                <c:forEach var="lbl" items="${seatLabels}"><span class="bk-seat-tag">${lbl}</span></c:forEach>
                            </c:when>
                        </c:choose>
                    </span>
                </div>
            </div>

            <div class="bk-card p-4">
                <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Promotion code</h6>
                <form method="post" action="${pageContext.request.contextPath}/booking/checkout">
                    <input type="hidden" name="showtimeId" value="${showtimeId}">
                    <input type="hidden" name="applyPromo" value="true">
                    <input type="hidden" name="bookingId"  value="${booking.bookingId}">
                    <c:forEach var="sid" items="${seatIds}">
                        <input type="hidden" name="seatIds" value="${sid}">
                    </c:forEach>
                    <div class="d-flex gap-2">
                        <input class="form-control" type="text" name="promoCode"
                               value="${promoCode}" placeholder="Enter code (e.g. SAVE10)">
                        <button class="btn btn-outline-primary" type="submit">Apply</button>
                    </div>
                    <c:if test="${not empty promoCode}">
                        <span class="badge bg-success-subtle text-success mt-2"><i class="bi bi-tag-fill"></i> ${promoCode}</span>
                    </c:if>
                </form>
            </div>
        </div>

        <%-- ===== Right: order summary ===== --%>
        <div class="col-lg-5">
            <div class="bk-card p-4 bk-summary">
                <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Order summary</h6>

                <c:choose>
                    <c:when test="${not empty booking}">
                        <div class="bk-sum-line">
                            <span class="text-muted">Tickets Subtotal</span>
                            <span><fmt:formatNumber value="${booking.subtotal - foodSubtotal}" pattern="#,###"/>₫</span>
                        </div>
                        <c:if test="${foodSubtotal > 0}">
                            <div class="bk-sum-line">
                                <span class="text-muted">Concessions Subtotal</span>
                                <span><fmt:formatNumber value="${foodSubtotal}" pattern="#,###"/>₫</span>
                            </div>
                        </c:if>
                        
                        <c:if test="${not empty concessions}">
                            <div class="my-3 pt-3 border-top border-light">
                                <div class="text-muted small mb-2">Selected Concessions</div>
                                <c:forEach var="entry" items="${concessions}">
                                    <div class="d-flex justify-content-between align-items-center mb-1 small text-dark">
                                        <span>${entry.key.name} <strong class="text-primary">x${entry.value}</strong></span>
                                        <span><fmt:formatNumber value="${entry.key.price * entry.value}" pattern="#,###"/>₫</span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>

                        <c:if test="${booking.discountAmount > 0}">
                            <div class="bk-sum-line text-success"><span>Discount
                                <c:if test="${not empty promoCode}"><span class="badge bg-success-subtle text-success ms-1">${promoCode}</span></c:if>
                                </span>
                                <span>−<fmt:formatNumber value="${booking.discountAmount}" pattern="#,###"/>₫</span></div>
                        </c:if>
                        <div class="bk-sum-line bk-sum-total">
                            <span class="fw-bold" style="color:var(--bk-navy);">Total</span>
                            <span class="fw-bold fs-5" style="color:var(--bk-primary);">
                                <fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/>₫</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted small mb-0">Price will appear once your seats are held.</p>
                    </c:otherwise>
                </c:choose>

                <%-- Confirm: tao chuyen sang buoc Payment --%>
                <form method="post" action="${pageContext.request.contextPath}/booking/checkout" class="mt-3">
                    <input type="hidden" name="showtimeId" value="${showtimeId}">
                    <input type="hidden" name="promoCode"  value="${promoCode}">
                    <input type="hidden" name="bookingId"  value="${booking.bookingId}">
                    <c:forEach var="sid" items="${seatIds}">
                        <input type="hidden" name="seatIds" value="${sid}">
                    </c:forEach>
                    <textarea name="notes" placeholder="Notes (optional)" class="form-control mb-3"
                              rows="2" style="resize:vertical; font-size:.88rem;"></textarea>
                    <button class="btn btn-primary w-100 py-2 fw-semibold" type="submit">
                        Proceed to Payment <i class="bi bi-arrow-right"></i>
                    </button>
                </form>
                <div class="text-center text-muted small mt-2">
                    <i class="bi bi-shield-lock"></i> Secure checkout
                </div>

                <c:if test="${not empty booking}">
                    <button type="button" class="btn btn-outline-danger w-100 mt-2" onclick="openCancelModal()">
                        <i class="bi bi-x-lg"></i> Cancel booking
                    </button>
                </c:if>
            </div>
        </div>
    </div>

    <%-- ===== Cancel modal ===== --%>
    <div id="cancel-modal" class="modal-overlay" style="display:none;" onclick="closeCancelModal(event)">
        <div class="modal-box" onclick="event.stopPropagation()">
            <div class="text-center mb-2" style="font-size:2.2rem;color:#dc2626;"><i class="bi bi-exclamation-triangle-fill"></i></div>
            <h5 class="text-center fw-bold mb-1">Cancel this booking?</h5>
            <p class="text-center text-muted mb-4" style="font-size:.9rem;">
                Booking <strong>${booking.bookingCode}</strong> will be cancelled and your seats released. This cannot be undone.
            </p>
            <div class="d-flex gap-2">
                <button class="btn btn-outline-secondary flex-fill" onclick="closeCancelModal()">Keep booking</button>
                <form action="${pageContext.request.contextPath}/customer/booking/cancel" method="post" class="flex-fill m-0">
                    <input type="hidden" name="bookingId"  value="${booking.bookingId}"/>
                    <input type="hidden" name="showtimeId" value="${showtimeId}"/>
                    <button type="submit" class="btn btn-danger w-100">Yes, cancel</button>
                </form>
            </div>
        </div>
    </div>
</div><!-- /container -->

<jsp:include page="../common/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openCancelModal() {
        document.getElementById('cancel-modal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }
    function closeCancelModal(e) {
        if (e && e.target !== e.currentTarget) return;
        document.getElementById('cancel-modal').style.display = 'none';
        document.body.style.overflow = '';
    }
</script>

<c:if test="${not empty booking}">
<script>
    // Dem nguoc 10 phut giu ghe (client-side, tu luc load trang).
    (function () {
        var LIMIT_MS = 10 * 60 * 1000;
        var start = Date.now();
        var cd   = document.getElementById('countdown');
        var pill = document.getElementById('reserve-pill');
        if (!cd) return;
        function tick() {
            var remaining = Math.max(0, LIMIT_MS - (Date.now() - start));
            var m = Math.floor(remaining / 60000);
            var s = Math.floor((remaining % 60000) / 1000);
            cd.textContent = m + ':' + String(s).padStart(2, '0');
            if (remaining <= 60000 && pill) pill.classList.add('danger');
            if (remaining === 0) {
                clearInterval(timer);
                cd.textContent = 'Expired';
                alert('Your seat hold has expired. Please pick seats again.');
                window.location.href = '${pageContext.request.contextPath}/booking/seats?showtimeId=${showtimeId}';
            }
        }
        tick();
        var timer = setInterval(tick, 1000);
    })();
</script>
</c:if>
</body>
</html>
