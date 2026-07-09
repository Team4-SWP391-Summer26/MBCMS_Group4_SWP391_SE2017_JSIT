<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>System Settings – PentaPlex</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
    <style>
        .set-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1rem;
            margin-bottom: 1.25rem;
        }
        @media (min-width: 900px) {
            .set-grid { grid-template-columns: 1fr 1fr; }
        }
        .set-card {
            background: #fff;
            border: 1px solid var(--lc-border, #e5e7eb);
            border-radius: 14px;
            padding: 1.15rem 1.25rem 1.25rem;
            box-shadow: 0 1px 2px rgba(15, 23, 42, .04);
            transition: border-color .15s ease, box-shadow .15s ease;
        }
        .set-card:focus-within {
            border-color: rgba(37, 99, 235, .45);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, .1);
        }
        .set-card__top {
            display: flex;
            align-items: flex-start;
            gap: .85rem;
            margin-bottom: .9rem;
        }
        .set-card__icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.05rem;
            flex-shrink: 0;
        }
        .set-card__title {
            font-size: .95rem;
            font-weight: 700;
            color: var(--lc-navy, #0f172a);
            margin: 0 0 .2rem;
            line-height: 1.25;
        }
        .set-card__hint {
            font-size: .78rem;
            color: #64748b;
            margin: 0;
            line-height: 1.4;
        }
        .set-card__field {
            display: flex;
            align-items: center;
            gap: .65rem;
        }
        .set-card__field .lc-form-control {
            max-width: 140px;
            font-weight: 700;
            font-size: 1.05rem;
            text-align: center;
        }
        .set-card__unit {
            font-size: .8rem;
            font-weight: 600;
            color: #64748b;
            letter-spacing: .02em;
        }
        .set-foot {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            padding: 1rem 1.15rem;
            background: #fff;
            border: 1px solid var(--lc-border, #e5e7eb);
            border-radius: 14px;
            box-shadow: 0 1px 2px rgba(15, 23, 42, .04);
        }
        .set-foot__note {
            font-size: .78rem;
            color: #94a3b8;
            margin: 0;
            max-width: 28rem;
            line-height: 1.45;
        }
        .set-foot__actions {
            display: flex;
            gap: .5rem;
            flex-shrink: 0;
        }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="settings"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Admin / <strong>Settings</strong></div>
                <h1 class="lc-page-title">System Settings</h1>
            </div>
            <span class="lc-admin-scope">
                <i class="bi bi-sliders"></i> Business rules
            </span>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="lc-alert lc-alert-success alert-dismissible" role="alert">
                <i class="bi bi-check-circle-fill"></i><span>${successMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="lc-alert lc-alert-danger alert-dismissible" role="alert">
                <i class="bi bi-exclamation-circle-fill"></i><span>${errorMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>

        <div class="lc-kpi-row lc-kpi-row--3" style="margin-bottom:1.25rem;">
            <div class="lc-kpi-card lc-rise" style="--i:0;">
                <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-star-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">VIP surcharge</div>
                    <div class="lc-kpi-value">${vipPercent}%</div>
                    <div class="lc-kpi-hint">Over base ticket price</div>
                </div>
            </div>
            <div class="lc-kpi-card lc-rise" style="--i:1;">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-grid-3x3-gap-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Max seats</div>
                    <div class="lc-kpi-value">${maxSeats}</div>
                    <div class="lc-kpi-hint">Per booking</div>
                </div>
            </div>
            <div class="lc-kpi-card lc-rise" style="--i:2;">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-hourglass-split"></i></div>
                <div>
                    <div class="lc-kpi-label">Seat hold</div>
                    <div class="lc-kpi-value">${pendingMinutes}<span style="font-size:1rem;font-weight:700;color:#64748b;">m</span></div>
                    <div class="lc-kpi-hint">PENDING expire · gap ${gapMinutes}m</div>
                </div>
            </div>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/admin/settings">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>

            <div class="set-grid">
                <div class="set-card lc-rise" style="--i:0;">
                    <div class="set-card__top">
                        <div class="set-card__icon lc-kpi-icon--amber"><i class="bi bi-percent"></i></div>
                        <div>
                            <h2 class="set-card__title">VIP seat surcharge</h2>
                            <p class="set-card__hint">VIP = showtime base × (1 + this %). Range 0–200.</p>
                        </div>
                    </div>
                    <div class="set-card__field">
                        <input type="number" class="lc-form-control" id="vipPercent" name="vipPercent"
                               min="0" max="200" step="1" required value="${vipPercent}" aria-label="VIP surcharge percent">
                        <span class="set-card__unit">percent</span>
                    </div>
                </div>

                <div class="set-card lc-rise" style="--i:1;">
                    <div class="set-card__top">
                        <div class="set-card__icon lc-kpi-icon--blue"><i class="bi bi-people-fill"></i></div>
                        <div>
                            <h2 class="set-card__title">Max seats per booking</h2>
                            <p class="set-card__hint">Applies to online booking and counter sales. Range 1–20.</p>
                        </div>
                    </div>
                    <div class="set-card__field">
                        <input type="number" class="lc-form-control" id="maxSeats" name="maxSeats"
                               min="1" max="20" step="1" required value="${maxSeats}" aria-label="Max seats per booking">
                        <span class="set-card__unit">seats</span>
                    </div>
                </div>

                <div class="set-card lc-rise" style="--i:2;">
                    <div class="set-card__top">
                        <div class="set-card__icon lc-kpi-icon--green"><i class="bi bi-clock-history"></i></div>
                        <div>
                            <h2 class="set-card__title">PENDING seat hold</h2>
                            <p class="set-card__hint">Unpaid bookings keep seats this long, then auto-expire. Range 1–60.</p>
                        </div>
                    </div>
                    <div class="set-card__field">
                        <input type="number" class="lc-form-control" id="pendingMinutes" name="pendingMinutes"
                               min="1" max="60" step="1" required value="${pendingMinutes}" aria-label="Pending hold minutes">
                        <span class="set-card__unit">minutes</span>
                    </div>
                </div>

                <div class="set-card lc-rise" style="--i:3;">
                    <div class="set-card__top">
                        <div class="set-card__icon lc-kpi-icon--violet"><i class="bi bi-calendar2-range"></i></div>
                        <div>
                            <h2 class="set-card__title">Showtime cleaning gap</h2>
                            <p class="set-card__hint">Minimum buffer between showtimes in the same room. Range 0–120.</p>
                        </div>
                    </div>
                    <div class="set-card__field">
                        <input type="number" class="lc-form-control" id="gapMinutes" name="gapMinutes"
                               min="0" max="120" step="1" required value="${gapMinutes}" aria-label="Showtime gap minutes">
                        <span class="set-card__unit">minutes</span>
                    </div>
                </div>
            </div>

            <div class="set-foot">
                <p class="set-foot__note">
                    Seed defaults: VIP 30%, max 8 seats, hold 10 min, gap 30 min.
                    SQL hold/gap rules read these values live from the database.
                </p>
                <div class="set-foot__actions">
                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                       class="lc-modal-btn lc-modal-btn-cancel text-decoration-none">Cancel</a>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save">
                        <i class="bi bi-check-lg me-1"></i>Save settings
                    </button>
                </div>
            </div>
        </form>

    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
