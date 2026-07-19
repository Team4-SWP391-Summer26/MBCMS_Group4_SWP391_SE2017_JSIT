<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Support Request – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        body { background: var(--bg); }
        .lc-elev { background:#fff;border:none;border-radius:14px;box-shadow:0 1px 3px rgba(15,30,54,.08),0 8px 24px rgba(15,30,54,.04); }
        .lc-avatar { width:72px;height:72px;border-radius:50%;background:linear-gradient(135deg,var(--primary),#1e3a5f);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:1.55rem; }
        .lc-navitem { display:flex;align-items:center;gap:.6rem;padding:.55rem .85rem;border-radius:8px;font-size:.92rem;font-weight:500;color:#475569;text-decoration:none;margin-bottom:2px;transition:background .12s,color .12s; }
        .lc-navitem:hover { background:#f1f5fb;color:var(--primary); }
        .lc-navitem.active { background:#e8f0fe;color:var(--primary);font-weight:600; }
        .lc-navitem i { width:18px;text-align:center;font-size:1rem; }
        .support-card { border-radius:10px;border:1px solid #e5e7eb;transition:box-shadow .15s; }
        .support-card:hover { box-shadow:0 4px 16px rgba(15,30,54,.08); }
        .status-pill { display:inline-block;padding:3px 10px;border-radius:99px;font-size:.75rem;font-weight:600; }
        .status-NEW { background:#fff3cd;color:#856404; }
        .status-IN_PROGRESS { background:#cfe2ff;color:#084298; }
        .status-RESOLVED { background:#d1e7dd;color:#0a3622; }
        .status-CLOSED { background:#e2e3e5;color:#41464b; }
        .subcat-btn { cursor:pointer;user-select:none; }
        .subcat-btn input:checked + .card { border-color:var(--bs-primary);background:#f0f6ff; }
        .subcat-btn .card { border-radius:10px;border:2px solid #e5e7eb;transition:border-color .15s,background .15s;padding:14px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="container py-4" style="max-width:1100px">
<div class="row g-4">

    <%-- Sidebar --%>
    <div class="col-12 col-md-3">
        <div class="card lc-elev p-3">
            <c:set var="cu" value="${sessionScope.currentUser}"/>
            <div class="d-flex flex-column align-items-center text-center py-3 mb-2"
                 style="border-bottom:1px solid #eef1f5;">
                <div class="lc-avatar mb-2">${fn:toUpperCase(fn:substring(cu.fullName, 0, 1))}</div>
                <h6 class="text-navy fw-bold mb-0"><c:out value="${cu.fullName}" /></h6>
                <div class="text-muted small">@<c:out value="${cu.username}" /></div>
                <div class="small mt-1">
                    <c:choose>
                        <c:when test="${cu.emailVerified}">
                            <i class="bi bi-patch-check-fill text-success"></i> <span class="text-muted">Email verified</span>
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-exclamation-circle text-warning"></i> <span class="text-muted">Email not verified</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <nav class="d-flex flex-column">
                <a class="lc-navitem" href="${pageContext.request.contextPath}/customer/profile">
                    <i class="bi bi-person"></i> Profile</a>
                <a class="lc-navitem" href="${pageContext.request.contextPath}/auth/change-password">
                    <i class="bi bi-shield-lock"></i> Security</a>
                <a class="lc-navitem" href="${pageContext.request.contextPath}/customer/booking/history">
                    <i class="bi bi-ticket-perforated"></i> My Bookings</a>
                <a class="lc-navitem" href="${pageContext.request.contextPath}/customer/notifications">
                    <i class="bi bi-bell"></i> Notifications</a>
                <a class="lc-navitem" href="${pageContext.request.contextPath}/customer/complaints">
                    <i class="bi bi-exclamation-circle"></i> Complaints</a>
                <a class="lc-navitem active" href="${pageContext.request.contextPath}/customer/support">
                    <i class="bi bi-headset"></i> Support</a>
                <hr style="margin:10px 0; border-color:#eef1f5;">
                <form method="post" action="${pageContext.request.contextPath}/auth/logout" class="m-0">
                    <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                    <button type="submit" class="lc-navitem" style="color:var(--danger);border:0;background:none;width:100%;text-align:left;cursor:pointer;">
                        <i class="bi bi-box-arrow-right"></i> Sign out</button>
                </form>
            </nav>
        </div>
    </div>

    <%-- Main content --%>
    <div class="col-12 col-md-9">

        <%-- Flash messages --%>
        <c:if test="${param.success == '1'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i><strong>Request submitted!</strong>
            We will get back to you as soon as possible.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        </c:if>
        <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>${fn:escapeXml(errorMsg)}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        </c:if>

        <%-- Submit Form --%>
        <div class="lc-elev p-4 mb-4">
            <h5 class="fw-bold mb-1"><i class="bi bi-headset text-primary me-2"></i>Submit a Support Request</h5>
            <p class="text-muted small mb-4">Select the type of issue you need help with and describe it in detail.</p>

            <form method="post" action="${pageContext.request.contextPath}/customer/support" id="supportForm" novalidate>
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>

                <%-- Sub-category selector --%>
                <div class="mb-4">
                    <label class="form-label fw-semibold d-block mb-2">Request Type <span class="text-danger">*</span></label>
                    <div class="row g-2">
                        <div class="col-md-4">
                            <label class="subcat-btn d-block">
                                <input type="radio" name="subCategory" value="BOOKING" class="visually-hidden subcat-radio" required>
                                <div class="card text-center">
                                    <i class="bi bi-ticket-perforated fs-3 text-primary mb-2"></i>
                                    <div class="fw-semibold small">Booking Issue</div>
                                    <div class="text-muted" style="font-size:.73rem">Tickets, refunds, changes...</div>
                                </div>
                            </label>
                        </div>
                        <div class="col-md-4">
                            <label class="subcat-btn d-block">
                                <input type="radio" name="subCategory" value="ACCOUNT" class="visually-hidden subcat-radio" required>
                                <div class="card text-center">
                                    <i class="bi bi-person-gear fs-3 text-info mb-2"></i>
                                    <div class="fw-semibold small">Account Issue</div>
                                    <div class="text-muted" style="font-size:.73rem">Login, password, profile...</div>
                                </div>
                            </label>
                        </div>
                        <div class="col-md-4">
                            <label class="subcat-btn d-block">
                                <input type="radio" name="subCategory" value="OTHER" class="visually-hidden subcat-radio" required>
                                <div class="card text-center">
                                    <i class="bi bi-question-circle fs-3 text-secondary mb-2"></i>
                                    <div class="fw-semibold small">Other</div>
                                    <div class="text-muted" style="font-size:.73rem">General enquiry...</div>
                                </div>
                            </label>
                        </div>
                    </div>
                </div>

                <%-- Booking selection (shown only when BOOKING is selected) --%>
                <div id="bookingSection" class="mb-3" style="display:none">
                    <label for="relatedBookingId" class="form-label fw-semibold">Related Booking <span class="text-danger">*</span></label>
                    <c:choose>
                        <c:when test="${empty myBookings}">
                            <div class="alert alert-info small mb-0">
                                <i class="bi bi-info-circle me-1"></i>You have no bookings to select.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <select name="relatedBookingId" id="relatedBookingId" class="form-select">
                                <option value="">-- Select a Booking --</option>
                                <c:forEach var="bk" items="${myBookings}">
                                    <option value="${bk.bookingId}">
                                        ${bk.bookingCode}
                                    </option>
                                </c:forEach>
                            </select>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="mb-3">
                    <label for="subject" class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
                    <input type="text" name="subject" id="subject" class="form-control"
                           maxlength="150" minlength="5" required
                           placeholder="Brief summary of your request"
                           value="${fn:escapeXml(param.subject)}">
                    <div class="form-text">5–150 characters.</div>
                </div>

                <div class="mb-4">
                    <label for="message" class="form-label fw-semibold">Details <span class="text-danger">*</span></label>
                    <textarea name="message" id="message" class="form-control"
                              rows="5" maxlength="2000" minlength="10" required
                              placeholder="Describe your issue in detail...">${fn:escapeXml(param.message)}</textarea>
                    <div class="d-flex justify-content-between">
                        <div class="form-text">10–2000 characters.</div>
                        <small class="text-muted" id="msgCount">0/2000</small>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-send me-2"></i>Submit Request
                </button>
            </form>
        </div>

        <%-- History --%>
        <div class="lc-elev p-4">
            <h6 class="fw-bold mb-3"><i class="bi bi-clock-history me-2"></i>Your Support Requests</h6>
            <c:choose>
                <c:when test="${empty mySupports}">
                    <p class="text-muted text-center py-3 mb-0">You have not submitted any support requests yet.</p>
                </c:when>
                <c:otherwise>
                    <c:forEach var="fb" items="${mySupports}">
                    <div class="support-card p-3 mb-2">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="fw-semibold small">${fn:escapeXml(fb.subject)}</div>
                                <div class="text-muted" style="font-size:.78rem">
                                    <c:choose>
                                        <c:when test="${fb.subCategory == 'BOOKING'}"><i class="bi bi-ticket me-1"></i>Booking</c:when>
                                        <c:when test="${fb.subCategory == 'ACCOUNT'}"><i class="bi bi-person me-1"></i>Account</c:when>
                                        <c:otherwise><i class="bi bi-question me-1"></i>Other</c:otherwise>
                                    </c:choose>
                                    &bull;
                                    <c:if test="${fb.createdAt != null}">${fn:substring(fb.createdAt.toString(), 0, 16)}</c:if>
                                </div>
                            </div>
                            <span class="status-pill status-${fb.status}">
                                <c:choose>
                                    <c:when test="${fb.status == 'NEW'}">Pending</c:when>
                                    <c:when test="${fb.status == 'IN_PROGRESS'}">In Progress</c:when>
                                    <c:when test="${fb.status == 'RESOLVED'}">Resolved</c:when>
                                    <c:when test="${fb.status == 'CLOSED'}">Closed</c:when>
                                    <c:otherwise>${fb.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <c:if test="${not empty fb.response}">
                        <div class="mt-2 p-2 bg-light rounded small text-muted border-start border-primary border-3">
                            <i class="bi bi-reply me-1 text-primary"></i><em>Staff response:</em> ${fn:escapeXml(fb.response)}
                        </div>
                        </c:if>
                    </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function(){
    // Sub-category card selection
    var radios = document.querySelectorAll('.subcat-radio');
    var bookingSection = document.getElementById('bookingSection');
    var bookingSelect  = document.getElementById('relatedBookingId');

    radios.forEach(function(r) {
        r.addEventListener('change', function() {
            var isBooking = r.value === 'BOOKING';
            if (bookingSection) {
                bookingSection.style.display = isBooking ? 'block' : 'none';
                if (bookingSelect) bookingSelect.required = isBooking;
            }
        });
    });

    // Char counter
    var msg = document.getElementById('message');
    var cnt = document.getElementById('msgCount');
    if (msg && cnt) {
        function update() { cnt.textContent = msg.value.length + '/2000'; }
        msg.addEventListener('input', update);
        update();
    }
})();
</script>
</body>
</html>
