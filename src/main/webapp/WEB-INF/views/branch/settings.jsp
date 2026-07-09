<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Branch Settings – PentaPlex</title>
    <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
    <style>
        .bs-info {
            display: grid;
            gap: .75rem;
            margin-bottom: 1.25rem;
        }
        @media (min-width: 768px) {
            .bs-info { grid-template-columns: 1.2fr .8fr; }
        }
        .bs-card {
            background: #fff;
            border: 1px solid var(--lc-border, #e5e7eb);
            border-radius: 14px;
            padding: 1.15rem 1.25rem;
            box-shadow: 0 1px 2px rgba(15, 23, 42, .04);
        }
        .bs-card h2 {
            font-size: .95rem;
            font-weight: 700;
            color: var(--lc-navy, #0f172a);
            margin: 0 0 .65rem;
        }
        .bs-meta {
            font-size: .86rem;
            color: #475569;
            line-height: 1.55;
            margin: 0;
        }
        .bs-meta strong { color: var(--lc-navy, #0f172a); }
        .bs-hours {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 1.1rem;
        }
        .bs-hours .lc-form-control { max-width: none; }
        .bs-hint {
            font-size: .78rem;
            color: #64748b;
            margin: 0 0 1rem;
            line-height: 1.45;
        }
        .bs-actions {
            display: flex;
            flex-wrap: wrap;
            gap: .5rem;
            justify-content: flex-end;
        }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
    <jsp:param name="active" value="settings"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Branch / <strong>Settings</strong></div>
                <h1 class="lc-page-title">Branch Settings</h1>
            </div>
            <span class="lc-admin-scope">
                <i class="bi bi-building"></i>
                <c:out value="${empty sessionScope.currentBranchName ? 'Your branch' : sessionScope.currentBranchName}"/>
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

        <div class="bs-info">
            <div class="bs-card lc-rise" style="--i:0;">
                <h2><i class="bi bi-geo-alt-fill text-primary me-1"></i> Cinema profile</h2>
                <p class="bs-meta">
                    <strong><c:out value="${branch.name}"/></strong><br>
                    <c:out value="${branch.address}"/>
                    <c:if test="${not empty branch.city}">, <c:out value="${branch.city}"/></c:if><br>
                    <c:if test="${not empty branch.phone}">
                        <i class="bi bi-telephone me-1"></i><c:out value="${branch.phone}"/>
                    </c:if>
                    <c:if test="${not empty branch.email}">
                        <span class="mx-1">·</span>
                        <i class="bi bi-envelope me-1"></i><c:out value="${branch.email}"/>
                    </c:if>
                </p>
                <p class="bs-hint mb-0 mt-2">
                    Name, address and contact are managed by System Admin.
                    You can change operating hours for scheduling below.
                </p>
            </div>

            <div class="bs-card lc-rise" style="--i:1;">
                <h2><i class="bi bi-clock-history text-primary me-1"></i> Current hours</h2>
                <div class="lc-kpi-value" style="font-size:1.55rem;">
                    ${openingTimeValue}
                    <span style="font-size:1rem;color:#94a3b8;font-weight:600;">–</span>
                    ${closingTimeValue}
                </div>
                <p class="bs-hint mb-0 mt-2">
                    Showtime create/edit must start and end within this window.
                </p>
            </div>
        </div>

        <div class="bs-card lc-rise" style="--i:2; max-width:560px;">
            <h2><i class="bi bi-sliders me-1"></i> Edit operating hours</h2>
            <p class="bs-hint">
                Closing time must be after opening time. Existing showtimes are not moved automatically —
                adjust schedules if they fall outside the new window.
            </p>

            <form method="post" action="${pageContext.request.contextPath}/branch/settings">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <div class="bs-hours">
                    <div>
                        <label class="lc-form-label" for="openingTime">Opening</label>
                        <input type="time" class="lc-form-control" id="openingTime" name="openingTime"
                               required value="${openingTimeValue}">
                    </div>
                    <div>
                        <label class="lc-form-label" for="closingTime">Closing</label>
                        <input type="time" class="lc-form-control" id="closingTime" name="closingTime"
                               required value="${closingTimeValue}">
                    </div>
                </div>
                <div class="bs-actions">
                    <a href="${pageContext.request.contextPath}/branch/dashboard"
                       class="lc-modal-btn lc-modal-btn-cancel text-decoration-none">Cancel</a>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save">
                        <i class="bi bi-check-lg me-1"></i>Save hours
                    </button>
                </div>
            </form>
        </div>

    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
