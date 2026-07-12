<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ticket Validation - PentaPlex Staff</title>
        <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
        <style>
            /* Ticket validation — page-specific only */
            .tv-code-input {
                font-family: var(--font-mono);
                font-size: 1.25rem;
                font-weight: 700;
                letter-spacing: .12em;
                text-transform: uppercase;
                text-align: center;
                height: 56px;
                border-color: rgba(226, 232, 240, 1);
                transition: all 0.2s ease;
            }
            .tv-code-input::placeholder {
                letter-spacing: 0;
                font-weight: 500;
                font-size: 0.95rem;
                text-transform: none;
            }
            .tv-check-btn {
                height: 56px;
                font-weight: 700;
                font-size: 1.05rem;
                box-shadow: 0 4px 12px rgba(37, 99, 235, 0.18);
                transition: all 0.2s ease;
            }
            .tv-check-btn:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 16px rgba(37, 99, 235, 0.28);
            }
            .input-group:focus-within {
                box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
                border-radius: var(--radius-lg);
            }

            /* ── Ticket Stub Separator & Notches ────────────────── */
            .ticket-stub-divider {
                position: relative;
                height: 1px;
                border-top: 2px dashed rgba(203, 213, 225, 0.8);
                margin: 24px 0;
            }
            .ticket-stub-divider::before,
            .ticket-stub-divider::after {
                content: "";
                position: absolute;
                top: -10px;
                width: 20px;
                height: 20px;
                background: var(--lc-bg);
                border-radius: 50%;
                z-index: 5;
                border: 1px solid rgba(226, 232, 240, 0.8);
            }
            .ticket-stub-divider::before {
                left: -35px;
            }
            .ticket-stub-divider::after {
                right: -35px;
            }

            /* ── Result Card / Banner ───────────────────────────── */
            .tv-result {
                border-radius: var(--radius-xl);
                overflow: hidden;
                display: none;
                animation: tvPop .28s cubic-bezier(0.34, 1.56, 0.64, 1);
            }
            @keyframes tvPop {
                from { transform: translateY(12px); opacity: 0; }
                to   { transform: translateY(0);   opacity: 1; }
            }
            .tv-banner {
                display: flex;
                align-items: center;
                gap: 16px;
                padding: 20px 24px;
                color: #fff;
                font-family: var(--font-display);
            }
            .tv-banner-title {
                font-weight: 800;
                font-size: 1.25rem;
                letter-spacing: .02em;
                line-height: 1.2;
            }
            .tv-banner-sub {
                font-weight: 500;
                font-size: .88rem;
                opacity: .95;
                margin-top: 2px;
            }
            .tv-banner.tv-valid    { background: linear-gradient(135deg, #059669 0%, #10B981 100%); }
            .tv-banner.tv-success  { background: linear-gradient(135deg, #1D4ED8 0%, #3B82F6 100%); }
            .tv-banner.tv-danger   { background: linear-gradient(135deg, #DC2626 0%, #EF4444 100%); }
            .tv-banner.tv-warning  { background: linear-gradient(135deg, #D97706 0%, #F59E0B 100%); }
            .tv-banner.tv-muted    { background: linear-gradient(135deg, #4B5563 0%, #6B7280 100%); }

            .tv-ticket-body {
                padding: 24px;
                background: #fff;
            }
            .tv-detail-label {
                font-size: .68rem;
                text-transform: uppercase;
                letter-spacing: .08em;
                color: #64748B;
                font-weight: 700;
                margin-bottom: 6px;
            }
            .tv-detail-value {
                font-size: 0.95rem;
                font-weight: 700;
                color: #0F172A;
            }
            .tv-seat-chip {
                display: inline-flex;
                align-items: center;
                gap: 5px;
                background: var(--primary-50);
                color: var(--primary-700);
                border: 1px solid var(--primary-200);
                border-radius: 8px;
                padding: 4px 10px;
                font-weight: 700;
                font-family: var(--font-mono);
                font-size: .85rem;
                margin: 3px;
                box-shadow: 0 1px 2px rgba(37, 99, 235, 0.04);
            }
            .tv-poster {
                width: 86px;
                height: 124px;
                object-fit: cover;
                border-radius: var(--radius-md);
                box-shadow: var(--shadow-sm);
                background: var(--surface-3);
                border: 1px solid var(--border);
            }

            /* ── Progress bar in showtimes table ────────────────── */
            .tv-prog {
                height: 6px;
                background: var(--surface-3);
                border-radius: 999px;
                overflow: hidden;
            }
            .tv-prog > span {
                display: block;
                height: 100%;
                border-radius: 999px;
                background: linear-gradient(90deg, #10B981, #34D399);
                transition: width .4s ease;
            }
            .tv-prog > span.low  { background: linear-gradient(90deg, #F59E0B, #FBBF24); }
            .tv-prog > span.zero { background: var(--border-strong); }

            /* ── Stat card hovers ────────────────────────────────── */
            .stat-card {
                border: 1px solid rgba(226, 232, 240, 0.8);
                border-radius: var(--radius-lg);
                transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            }
            .stat-card-sold:hover {
                border-color: rgba(37, 99, 235, 0.2) !important;
                box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.08);
                transform: translateY(-2px);
            }
            .stat-card-admitted:hover {
                border-color: rgba(16, 185, 129, 0.2) !important;
                box-shadow: 0 10px 25px -5px rgba(16, 185, 129, 0.08);
                transform: translateY(-2px);
            }

            #checkinBtn {
                border-radius: 12px;
                font-family: var(--font-sans);
                font-weight: 700;
                letter-spacing: 0.05em;
                box-shadow: 0 4px 15px rgba(22, 163, 74, 0.2);
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            }
            #checkinBtn:hover:not(:disabled) {
                transform: translateY(-1px);
                box-shadow: 0 8px 20px rgba(22, 163, 74, 0.3);
            }
            #checkinBtn:active:not(:disabled) {
                transform: translateY(0);
            }
        </style>
    </head>
    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar_staff.jsp">
            <jsp:param name="active" value="ticket-validate" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="lc-page">

                <div class="lc-page-head">
                    <div>
                        <div class="lc-page-section">Counter Operations</div>
                        <h1 class="lc-page-title">Ticket Validation</h1>
                    </div>
                    <div class="lc-branch-chip">
                        <i class="bi bi-geo-alt-fill" aria-hidden="true"></i>
                        <span><c:out value="${sessionScope.currentBranchName}" /></span>
                    </div>
                </div>

                <div class="row g-4">
                    <%-- ══════════ LEFT: Validate & Check-in ══════════ --%>
                    <div class="col-lg-7">
                        <div class="card lc-elev p-4 mb-4">
                            <div class="d-flex align-items-center gap-2 mb-1">
                                <h5 class="text-navy fw-bold mb-0">Entry Gate Check-in</h5>
                            </div>
                            <p class="text-muted small mb-3">
                                Enter the ticket code printed on the customer's e-ticket (for example <span class="font-monospace fw-bold">BK-A1B2C3</span>), then click
                                <strong>Verify</strong>. This screen is optimized for entry gate staff.
                            </p>
                            <form id="verifyForm" autocomplete="off">
                                <div class="input-group shadow-sm" style="border-radius: var(--radius-lg); overflow: hidden;">
                                    <span class="input-group-text bg-white border-end-0 border-2 px-3 text-muted" style="border-color: rgba(226, 232, 240, 1);">
                                        <i class="bi bi-qr-code-scan fs-5"></i>
                                    </span>
                                    <input type="text" id="codeInput" class="form-control border-start-0 border-2 tv-code-input"
                                           placeholder="Enter ticket code, e.g. BK-A1B2C3" maxlength="20" spellcheck="false"
                                           style="border-top-left-radius: 0; border-bottom-left-radius: 0; height: 56px;">
                                    <button type="submit" class="btn btn-primary tv-check-btn px-4" id="verifyBtn"
                                            style="height: 56px; border-top-left-radius: 0; border-bottom-left-radius: 0; border-top-right-radius: var(--radius-lg); border-bottom-right-radius: var(--radius-lg);">
                                        <i class="bi bi-shield-check me-2 fs-5"></i>Verify
                                    </button>
                                </div>
                            </form>
                        </div>

                        <%-- ===== Result card (filled by JS) ===== --%>
                        <div class="card lc-elev p-0 tv-result" id="resultCard">
                            <div class="tv-banner" id="resultBanner">
                                <i class="bi bi-check-circle-fill fs-2" id="resultIcon"></i>
                                <div>
                                    <div class="tv-banner-title" id="resultTitle">&nbsp;</div>
                                    <div class="tv-banner-sub" id="resultSub"></div>
                                </div>
                            </div>
                            <div class="tv-ticket-body" id="ticketBody" style="display:none;">
                                <div class="d-flex gap-3 align-items-center">
                                    <img id="tPoster" class="tv-poster" src="" alt="Poster"
                                         onerror="this.style.visibility='hidden'">
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                                            <div>
                                                <div class="fw-bold text-navy fs-5" id="tMovie"></div>
                                                <div class="text-muted small mt-1" id="tMeta"></div>
                                            </div>
                                            <span class="badge bg-light text-primary font-monospace fw-bold fs-6 border border-primary-subtle px-2.5 py-1.5" id="tCode"></span>
                                        </div>
                                    </div>
                                </div>

                                <%-- Ticket Stub Divider --%>
                                <div class="ticket-stub-divider"></div>

                                <div class="row g-3">
                                    <div class="col-sm-4">
                                        <div class="tv-detail-label">Showtime</div>
                                        <div class="tv-detail-value" id="tTime"></div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="tv-detail-label">Room</div>
                                        <div class="tv-detail-value" id="tRoom"></div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="tv-detail-label">Customer</div>
                                        <div class="tv-detail-value" id="tCustomer"></div>
                                    </div>
                                </div>
                                <div class="mt-4">
                                    <div class="tv-detail-label">Seats (<span id="tSeatCount"></span>)</div>
                                    <div id="tSeats" class="d-flex flex-wrap gap-1 mt-1"></div>
                                </div>
                                <div class="mt-4" id="checkinWrap" style="display:none;">
                                    <div class="d-grid">
                                        <button type="button" class="btn btn-success btn-lg fw-bold py-3 text-uppercase" id="checkinBtn">
                                            <i class="bi bi-door-open-fill me-2 fs-5"></i>Confirm Entry — Check-in
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- ══════════ RIGHT: Attendance tracking ══════════ --%>
                    <div class="col-lg-5">
                        <div class="card lc-elev p-4">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
                                <h5 class="text-navy fw-bold mb-0">Attendance Today</h5>
                                <form method="get" action="${pageContext.request.contextPath}/staff/ticket-validate" class="m-0">
                                    <div class="input-group input-group-sm shadow-xs" style="max-width: 160px; border-radius: var(--radius-md); overflow: hidden; border: 1px solid rgba(226, 232, 240, 0.8);">
                                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-calendar3"></i></span>
                                        <input type="date" name="date" class="form-control border-start-0 ps-0 text-navy fw-semibold"
                                               value="${selectedDate}" onchange="this.form.submit()">
                                    </div>
                                </form>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-6">
                                    <div class="card stat-card stat-card-sold p-3 h-100 bg-light-subtle">
                                        <div class="d-flex align-items-center gap-2 mb-2">
                                            <div class="lc-stat-icon" style="width: 36px; height: 36px; font-size: 1.1rem; border-radius: 8px;">
                                                <i class="bi bi-ticket-perforated"></i>
                                            </div>
                                            <div class="text-muted small fw-bold" style="font-size: 0.7rem; letter-spacing: 0.05em; text-transform: uppercase;">Sold</div>
                                        </div>
                                        <div class="text-navy fw-bold" style="font-size: 1.6rem; line-height: 1.2;">${totalBooked}</div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="card stat-card stat-card-admitted p-3 h-100 bg-light-subtle">
                                        <div class="d-flex align-items-center gap-2 mb-2">
                                            <div class="lc-stat-icon" style="width: 36px; height: 36px; font-size: 1.1rem; border-radius: 8px; background: #e7f6ee; color: #15803d;">
                                                <i class="bi bi-person-check"></i>
                                            </div>
                                            <div class="text-muted small fw-bold" style="font-size: 0.7rem; letter-spacing: 0.05em; text-transform: uppercase;">Admitted</div>
                                        </div>
                                        <div class="text-navy fw-bold" style="font-size: 1.6rem; line-height: 1.2;">${totalCheckedIn}</div>
                                    </div>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <table class="table lc-table align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Showtime</th>
                                            <th class="text-center">In / Sold</th>
                                            <th style="width: 34%;">Attendance</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty attendance}">
                                                <tr>
                                                    <td colspan="3" class="text-center text-muted py-5">
                                                        <div class="my-3">
                                                            <i class="bi bi-calendar-x text-subtle d-block mb-2" style="font-size: 2.2rem; opacity: 0.5;"></i>
                                                            <span class="fw-semibold text-navy d-block mb-1 fs-6">No Showtimes Found</span>
                                                            <span class="small text-muted">There are no showtimes scheduled on this date.</span>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="a" items="${attendance}">
                                                    <tr>
                                                        <td>
                                                            <div class="fw-semibold text-navy small text-truncate" style="max-width: 170px;"
                                                                 title="${a.movieTitle}"><c:out value="${a.movieTitle}" /></div>
                                                            <div class="small text-muted mt-0.5">
                                                                <span class="fw-semibold text-primary">${a.startTime.toLocalTime()}</span> &middot; ${a.roomName} &middot; <span class="badge bg-light text-secondary border px-1.5 py-0.5 rounded" style="font-size: 0.65rem;">${a.format}</span>
                                                            </div>
                                                        </td>
                                                        <td class="text-center">
                                                            <span class="fw-bold text-navy">${a.checkedInSeats}</span>
                                                            <span class="text-muted">/ ${a.bookedSeats}</span>
                                                        </td>
                                                        <td>
                                                            <div class="d-flex align-items-center gap-2">
                                                                <div class="tv-prog flex-grow-1">
                                                                    <span class="${a.bookedSeats == 0 ? 'zero' : (a.attendancePercent < 50 ? 'low' : '')}"
                                                                          style="width: ${a.attendancePercent}%;"></span>
                                                                </div>
                                                                <span class="small fw-semibold text-muted" style="min-width: 34px;">${a.attendancePercent}%</span>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>

        <%-- ===== Toast Feedback ===== --%>
        <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1080;">
            <div id="toastFeedback" class="toast align-items-center text-white border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true" style="border-radius: var(--radius-md);">
                <div class="d-flex">
                    <div class="toast-body fw-semibold" id="toastMessage"></div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            const CONTEXT_PATH = '${pageContext.request.contextPath}';
            const API_URL = '${pageContext.request.contextPath}/staff/ticket-validate';
            const CSRF = '${sessionScope.csrfToken}';

            const codeInput = document.getElementById('codeInput');
            const verifyBtn = document.getElementById('verifyBtn');
            const resultCard = document.getElementById('resultCard');
            const banner = document.getElementById('resultBanner');
            const checkinWrap = document.getElementById('checkinWrap');
            const checkinBtn = document.getElementById('checkinBtn');

            // Style theo status code tu server
            const STATUS_UI = {
                VALID:        { cls: 'tv-valid',   icon: 'bi-check-circle-fill',        title: 'VALID TICKET' },
                CHECKED_IN:   { cls: 'tv-success', icon: 'bi-door-open-fill',           title: 'CHECKED IN — WELCOME' },
                ALREADY_USED: { cls: 'tv-danger',  icon: 'bi-x-octagon-fill',           title: 'DENIED — ALREADY USED' },
                NOT_PAID:     { cls: 'tv-warning', icon: 'bi-hourglass-split',          title: 'NOT PAID' },
                CANCELLED:    { cls: 'tv-danger',  icon: 'bi-slash-circle-fill',        title: 'CANCELLED TICKET' },
                NO_SHOW:      { cls: 'tv-muted',   icon: 'bi-person-x-fill',            title: 'NO SHOW' },
                TOO_EARLY:    { cls: 'tv-warning', icon: 'bi-clock-history',            title: 'TOO EARLY' },
                EXPIRED:      { cls: 'tv-muted',   icon: 'bi-calendar-x-fill',          title: 'SHOWTIME ENDED' },
                WRONG_BRANCH: { cls: 'tv-danger',  icon: 'bi-geo-alt-fill',             title: 'WRONG BRANCH' },
                NOT_FOUND:    { cls: 'tv-muted',   icon: 'bi-question-circle-fill',     title: 'TICKET NOT FOUND' },
                ERROR:        { cls: 'tv-muted',   icon: 'bi-exclamation-triangle-fill',title: 'SYSTEM ERROR' }
            };

            document.getElementById('verifyForm').addEventListener('submit', function (e) {
                e.preventDefault();
                callApi('validate');
            });

            checkinBtn.addEventListener('click', function () {
                callApi('checkin');
            });

            function showToast(message, type = 'success') {
                const toastEl = document.getElementById('toastFeedback');
                const msgEl = document.getElementById('toastMessage');
                msgEl.textContent = message;
                
                toastEl.className = 'toast align-items-center text-white border-0 shadow-lg ' + 
                    (type === 'success' ? 'bg-success' : (type === 'danger' ? 'bg-danger' : 'bg-warning'));
                
                const bsToast = new bootstrap.Toast(toastEl, { delay: 3500 });
                bsToast.show();
            }

            function callApi(action) {
                const code = codeInput.value.trim();
                if (!code) { codeInput.focus(); return; }

                verifyBtn.disabled = true;
                checkinBtn.disabled = true;

                const body = new URLSearchParams();
                body.append('action', action);
                body.append('code', code);
                body.append('_csrf', CSRF);

                fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                    body: body.toString()
                })
                .then(res => res.json())
                .then(data => {
                    render(data);
                    if (data.status === 'CHECKED_IN') {
                        showToast('Check-in successful. Please let the guest enter the auditorium.', 'success');
                        // Attendance panel refresh sau khi cho khach vao
                        setTimeout(() => window.location.reload(), 1600);
                    } else if (data.status === 'VALID' && action === 'validate') {
                        showToast('Valid ticket. Click Check-in to confirm entry.', 'success');
                    } else {
                        showToast(data.message || 'Invalid action.', 'danger');
                    }
                })
                .catch(() => {
                    showToast('Cannot connect to the server. Please try again.', 'danger');
                    render({ status: 'ERROR', message: 'Cannot connect to the server. Try again.' });
                })
                .finally(() => {
                    verifyBtn.disabled = false;
                    checkinBtn.disabled = false;
                });
            }

            function render(data) {
                const ui = STATUS_UI[data.status] || STATUS_UI.ERROR;

                banner.className = 'tv-banner ' + ui.cls;
                document.getElementById('resultIcon').className = 'bi ' + ui.icon;
                document.getElementById('resultTitle').textContent = ui.title;

                let sub = data.message || '';
                if (data.checkInTime) {
                    sub += ' (Check-in: ' + data.checkInTime + ')';
                }
                document.getElementById('resultSub').textContent = sub;

                const body = document.getElementById('ticketBody');
                if (data.ticket) {
                    const t = data.ticket;
                    document.getElementById('tMovie').textContent = t.movieTitle || '';
                    document.getElementById('tMeta').textContent =
                        (t.rated ? t.rated + ' · ' : '') + (t.format || '') + (t.subtitleType ? ' · ' + t.subtitleType : '');
                    document.getElementById('tCode').textContent = t.bookingCode || '';
                    document.getElementById('tTime').textContent = t.startTime || '';
                    document.getElementById('tRoom').textContent = t.roomName || '';
                    document.getElementById('tCustomer').textContent = t.customerName || '';
                    document.getElementById('tSeatCount').textContent = t.seatCount || 0;

                    const poster = document.getElementById('tPoster');
                    const posterUrl = resolveAssetUrl(t.posterUrl || '');
                    if (posterUrl) {
                        poster.style.visibility = 'visible';
                        poster.src = posterUrl;
                    } else {
                        poster.removeAttribute('src');
                        poster.style.visibility = 'hidden';
                    }

                    const seats = document.getElementById('tSeats');
                    seats.innerHTML = '';
                    (t.seats || []).forEach(s => {
                        const chip = document.createElement('span');
                        chip.className = 'tv-seat-chip';
                        chip.innerHTML = '<i class="bi bi-ticket-perforated text-primary-400 small"></i> ' + s;
                        seats.appendChild(chip);
                    });

                    body.style.display = '';
                } else {
                    body.style.display = 'none';
                }

                // Fix bootstrap d-grid important display overriding style display:none
                checkinWrap.style.display = data.allowEntry ? 'block' : 'none';
                resultCard.style.display = 'block';
                // Re-trigger pop animation
                resultCard.style.animation = 'none';
                void resultCard.offsetWidth;
                resultCard.style.animation = '';
            }

            function resolveAssetUrl(url) {
                if (!url) {
                    return '';
                }
                if (/^(https?:|data:|blob:)/i.test(url)) {
                    return url;
                }
                if (url.startsWith(CONTEXT_PATH + '/')) {
                    return url;
                }
                if (url.startsWith('/')) {
                    return CONTEXT_PATH + url;
                }
                return CONTEXT_PATH + '/' + url;
            }

            // Autofocus + auto-uppercase cho tay nhap nhanh
            codeInput.focus();
            codeInput.addEventListener('input', () => {
                codeInput.value = codeInput.value.toUpperCase();
            });
        </script>
    </body>
</html>
