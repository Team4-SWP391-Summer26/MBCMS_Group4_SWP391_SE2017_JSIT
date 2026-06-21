<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Xác nhận đặt vé – MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
        <style>
            .checkout-wrap {
                max-width: 760px;
                margin: 32px auto 48px;
                padding: 0 16px;
            }
            .page-title {
                font-weight: 800;
                color: var(--text-dark);
                margin-bottom: 1.25rem;
            }

            .alert-err {
                background: #fee2e2;
                color: #b91c1c;
                border-radius: 10px;
                padding: 10px 16px;
                margin-bottom: 16px;
                font-size: .88rem;
            }
            .alert-info {
                background: #dcfce7;
                color: #15803d;
                border-radius: 10px;
                padding: 10px 16px;
                margin-bottom: 16px;
                font-size: .88rem;
            }
            .alert-pending {
                background: #fef9c3;
                color: #92400e;
                border-radius: 10px;
                padding: 10px 16px;
                margin-bottom: 16px;
                font-size: .88rem;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .checkout-grid {
                display: grid;
                grid-template-columns: 1.2fr 1fr;
                gap: 20px;
                align-items: start;
            }
            @media (max-width: 760px) {
                .checkout-grid {
                    grid-template-columns: 1fr;
                }
            }

            .summary-card {
                background: var(--bg-card);
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                box-shadow: 0 2px 12px rgba(15,30,54,.06);
                padding: 22px 24px;
            }
            .section-title {
                font-size: 1.02rem;
                font-weight: 700;
                color: var(--text-dark);
                margin-bottom: 14px;
            }

            .info-table td {
                padding: 6px 4px;
                font-size: .9rem;
                vertical-align: top;
            }
            .info-table td:first-child {
                color: var(--text-muted);
                font-weight: 600;
                width: 120px;
            }

            .seat-tag {
                display: inline-block;
                background: #eff6ff;
                color: var(--primary);
                border: 1px solid #bfdbfe;
                border-radius: 7px;
                padding: 3px 10px;
                font-size: .82rem;
                font-weight: 700;
                margin: 2px 4px 2px 0;
            }

            .promo-row {
                display: flex;
                gap: 8px;
            }
            .promo-row input {
                flex: 1;
            }
            .promo-applied-badge {
                display: inline-block;
                background: #dcfce7;
                color: #16a34a;
                border-radius: 999px;
                padding: 2px 10px;
                font-size: .76rem;
                font-weight: 700;
            }

            .price-row {
                display: flex;
                justify-content: space-between;
                font-size: .9rem;
                padding: 5px 0;
                color: var(--text-dark);
            }
            .price-row.discount {
                color: #16a34a;
            }
            .price-row.total {
                font-weight: 800;
                font-size: 1.1rem;
                color: var(--primary);
                border-top: 2px solid #e5e7eb;
                padding-top: 12px;
                margin-top: 8px;
            }

            .btn-pay-lc {
                background: var(--primary);
                border: none;
                color: #fff;
                border-radius: 9px;
                padding: 11px 0;
                font-weight: 700;
                width: 100%;
                margin-top: 16px;
                transition: background .15s;
            }
            .btn-pay-lc:hover {
                background: #1d4ed8;
                color: #fff;
            }

            .btn-cancel-lc {
                background: transparent;
                border: 1.5px solid #e5e7eb;
                color: #6b7280;
                border-radius: 9px;
                padding: 9px 0;
                font-weight: 600;
                width: 100%;
                margin-top: 10px;
                font-size: .9rem;
                transition: all .15s;
                cursor: pointer;
            }
            .btn-cancel-lc:hover {
                background: #fef2f2;
                border-color: #dc2626;
                color: #b91c1c;
            }

            /* ── Cancel modal ── */
            .modal-overlay {
                position: fixed;
                inset: 0;
                background: rgba(15,23,42,.55);
                z-index: 1055;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 16px;
                animation: fadeInModal .2s;
            }
            .modal-box {
                background: #fff;
                border-radius: 14px;
                padding: 28px;
                max-width: 420px;
                width: 100%;
                box-shadow: 0 20px 60px rgba(0,0,0,.3);
            }
            
                        /* ── Cancel button ── */
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

            .back-link {
                display: inline-block;
                margin-top: 14px;
                color: var(--text-muted);
                font-size: .85rem;
                text-decoration: none;
            }
            .back-link:hover {
                color: var(--primary);
            }

            /* Countdown timer */
            #countdown-wrap {
                font-size: .82rem;
                color: #92400e;
                font-weight: 700;
            }
            #countdown-wrap.danger {
                color: #b91c1c;
                animation: blink .8s step-start infinite;
            }
            @keyframes blink {
                50% {
                    opacity: .4;
                }
            }
            @keyframes fadeInModal {
                from {
                    opacity: 0;
                }
                to   {
                    opacity: 1;
                }
            }
        </style>
    </head>
    <body>
        <%@ include file="/WEB-INF/views/common/header.jsp" %>

        <div class="checkout-wrap">
            <h5 class="page-title">🎬 Xác nhận đặt vé</h5>

            <%-- Ghế đang được giữ – nhắc người dùng --%>
            <c:if test="${not empty booking}">
                <div class="alert-pending">
                    ⏳ <span>Ghế của bạn đang được <strong>giữ trong 10 phút</strong>. Vui lòng hoàn tất thanh toán trước khi hết giờ.</span>
                    <span id="countdown-wrap" class="ms-auto"></span>
                </div>
            </c:if>

            <%-- Error / info messages --%>
            <c:if test="${not empty checkoutError}">
                <div class="alert-err">⚠️ ${checkoutError}</div>
            </c:if>
            <c:if test="${not empty pricingError}">
                <div class="alert-err">⚠️ ${pricingError}</div>
            </c:if>
            <c:if test="${not empty promoMessage}">
                <div class="alert-info">✅ ${promoMessage}</div>
            </c:if>

            <div class="checkout-grid">

                <%-- LEFT: chi tiết đặt chỗ + promo --%>
                <div class="summary-card">
                    <div class="section-title">Chi tiết đặt chỗ</div>
                    <table class="info-table" style="width:100%">
                        <c:if test="${not empty booking}">
                            <tr>
                                <td>Mã đặt vé</td>
                                <td class="fw-semibold">${booking.bookingCode}</td>
                            </tr>
                        </c:if>
                        <tr>
                            <td>Suất chiếu</td>
                            <td class="fw-semibold">#${showtimeId}</td>
                        </tr>
                        <tr>
                            <td>Ghế</td>
                            <td>
                                <c:forEach var="sid" items="${seatIds}">
                                    <span class="seat-tag">${sid}</span>
                                </c:forEach>
                            </td>
                        </tr>
                        <c:if test="${not empty booking}">
                            <tr>
                                <td>Trạng thái</td>
                                <td><span class="badge bg-warning text-dark">PENDING – Đang giữ ghế</span></td>
                            </tr>
                        </c:if>
                    </table>

                    <hr style="border-color:#e5e7eb; margin: 18px 0;">

                    <div class="section-title" style="margin-bottom:10px;">Mã khuyến mãi</div>
                    <form method="post" action="${pageContext.request.contextPath}/booking/checkout">
                        <input type="hidden" name="showtimeId"  value="${showtimeId}">
                        <input type="hidden" name="applyPromo"  value="true">
                        <input type="hidden" name="bookingId"   value="${booking.bookingId}">
                        <c:forEach var="sid" items="${seatIds}">
                            <input type="hidden" name="seatIds" value="${sid}">
                        </c:forEach>
                        <div class="promo-row">
                            <input class="form-control" type="text" name="promoCode"
                                   value="${promoCode}" placeholder="Nhập mã (VD: SAVE10)">
                            <button class="btn btn-outline-primary" type="submit">Áp dụng</button>
                        </div>
                        <c:if test="${not empty promoCode}">
                            <span class="promo-applied-badge mt-2 d-inline-block">${promoCode}</span>
                        </c:if>
                    </form>
                </div>

                <%-- RIGHT: bảng giá + nút thanh toán + nút huỷ --%>
                <div class="summary-card">
                    <div class="section-title">Tóm tắt thanh toán</div>

                    <c:if test="${not empty pricing}">
                        <div class="price-row">
                            <span>Tạm tính</span>
                            <span><fmt:formatNumber value="${pricing.subtotal}" pattern="#,###"/> đ</span>
                        </div>
                        <c:if test="${pricing.discountAmount > 0}">
                            <div class="price-row discount">
                                <span>
                                    Giảm giá
                                    <c:if test="${not empty promoCode}">
                                        <span class="promo-applied-badge ms-1">${promoCode}</span>
                                    </c:if>
                                </span>
                                <span>− <fmt:formatNumber value="${pricing.discountAmount}" pattern="#,###"/> đ</span>
                            </div>
                        </c:if>
                        <div class="price-row total">
                            <span>Tổng cộng</span>
                            <span><fmt:formatNumber value="${pricing.totalAmount}" pattern="#,###"/> đ</span>
                        </div>
                    </c:if>

                    <%-- Form xác nhận thanh toán --%>
                    <form method="post" action="${pageContext.request.contextPath}/booking/checkout">
                        <input type="hidden" name="showtimeId" value="${showtimeId}">
                        <input type="hidden" name="promoCode"  value="${promoCode}">
                        <input type="hidden" name="bookingId"  value="${booking.bookingId}">
                        <c:forEach var="sid" items="${seatIds}">
                            <input type="hidden" name="seatIds" value="${sid}">
                        </c:forEach>
                        <textarea name="notes"
                                  placeholder="Ghi chú (tuỳ chọn)"
                                  class="form-control mt-3"
                                  rows="2"
                                  style="resize:vertical; font-size:.88rem;"></textarea>
                        <button class="btn-pay-lc" type="submit">💳 Tiến hành thanh toán</button>
                    </form>

                    <%-- Nút Huỷ đặt vé (chỉ hiển thị khi đã có pending booking) --%>
                    <%-- Nút Huỷ đặt vé (chỉ hiển thị khi đã có pending booking) --%>
                    <c:if test="${not empty booking}">
                        <button type="button" class="btn-cancel-lc" onclick="openCancelModal()">
                            ✕ Huỷ đặt vé
                        </button>
                    </c:if>
                </div>
            </div>
            <!-- Cancel modal -->
            <div id="cancel-modal" class="modal-overlay" style="display:none;" onclick="closeCancelModal(event)">
                <div class="modal-box" onclick="event.stopPropagation()">
                    <div style="font-size:2.5rem; text-align:center; margin-bottom:8px;">⚠️</div>
                    <h5 class="text-center fw-bold mb-1">Cancel this booking?</h5>
                    <p class="text-center text-muted mb-4" style="font-size:0.9rem;">
                        Booking <strong>${booking.bookingCode}</strong> will be cancelled
                        and your seats will be released. This cannot be undone.
                    </p>
                    <div class="d-flex gap-2">
                        <button class="btn btn-outline-secondary flex-fill" onclick="closeCancelModal()">Keep Booking</button>
                        <%-- TODO: wire to BookingCancelServlet --%>
                        <form action="${pageContext.request.contextPath}/customer/booking/cancel"
                              method="post" class="flex-fill m-0">
                            <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                            <input type="hidden" name="showtimeId" value="${showtimeId}"/>  <%-- add this --%>
                            <button type="submit" class="btn-cancel-booking w-100" style="justify-content:center;">
                                Yes, Cancel
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <script>
                function openCancelModal() {
                    document.getElementById('cancel-modal').style.display = 'flex';
                    document.body.style.overflow = 'hidden';
                }
                function closeCancelModal(e) {
                    if (e && e.target !== e.currentTarget)
                        return;
                    document.getElementById('cancel-modal').style.display = 'none';
                    document.body.style.overflow = '';
                }
            </script>
        </div>


        <%@ include file="/WEB-INF/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <c:if test="${not empty booking}">
            <script>
                // Đếm ngược 10 phút từ lúc load trang
                (function () {
                    const LIMIT_MS = 10 * 60 * 1000;
                    const start = Date.now();
                    const wrap = document.getElementById('countdown-wrap');
                    if (!wrap)
                        return;

                    function tick() {
                        const elapsed = Date.now() - start;
                        const remaining = Math.max(0, LIMIT_MS - elapsed);
                        const m = Math.floor(remaining / 60000);
                        const s = Math.floor((remaining % 60000) / 1000);
                        wrap.textContent = m + ':' + String(s).padStart(2, '0');
                        if (remaining <= 60000)
                            wrap.classList.add('danger');
                        if (remaining === 0) {
                            clearInterval(timer);
                            wrap.textContent = 'Hết giờ!';
                            alert('Thời gian giữ ghế đã hết. Vui lòng chọn lại ghế.');
                            window.location.href = '${pageContext.request.contextPath}/booking/seats?showtimeId=${showtimeId}';
                                        }
                                    }
                                    tick();
                                    const timer = setInterval(tick, 1000);
                                })();
            </script>
        </c:if>
    </body>
</html>