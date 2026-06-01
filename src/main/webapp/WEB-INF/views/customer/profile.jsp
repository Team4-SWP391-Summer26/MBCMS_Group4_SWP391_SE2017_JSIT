<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>My Profile - MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* Profile-specific styles, aligned with the tones in main.css */
            .lc-elev { background:#fff; border:none; border-radius:14px; box-shadow:0 1px 3px rgba(15,30,54,.08), 0 8px 24px rgba(15,30,54,.04); }
            .text-navy { color: var(--text-dark); }
            .lc-avatar { width:84px; height:84px; border-radius:999px; background:linear-gradient(135deg,#2563eb,#1e3a5f);
                         color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:1.75rem; }
            .lc-navitem { display:flex; align-items:center; gap:.6rem; padding:.55rem .85rem; border-radius:8px;
                          font-size:.92rem; font-weight:500; color:#475569; text-decoration:none; margin-bottom:2px; }
            .lc-navitem:hover { background:#f1f5fb; color:var(--primary); }
            .lc-navitem.active { background:#e8f0fe; color:var(--primary); font-weight:600; }
            .lc-navitem.disabled { color:#9aa4b2; cursor:not-allowed; }
            .lc-navitem i { width:18px; text-align:center; }
            .lc-soon { font-size:.62rem; background:#eef1f5; color:#9aa4b2; padding:.05rem .4rem; border-radius:999px; margin-left:auto; }
            .profile-form .form-label { font-size:.82rem; font-weight:600; color:var(--text-dark); }
            /* View-mode (disabled) fields look soft, not harshly locked */
            .profile-form .form-control:disabled { background:#f3f4f6; color:#374151; border-color:#e5e7eb; opacity:1; }
        </style>
    </head>

    <body class="bg-light">

        <jsp:include page="/WEB-INF/views/common/header.jsp" />

        <c:set var="cu" value="${sessionScope.currentUser}" />
        <%-- Auto-open Edit mode if the profile submit failed (so the user can fix it) --%>
        <c:set var="startEdit" value="${not empty errorMsg}" />

        <div class="container py-4" style="max-width: 1140px;">

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success py-2">${successMsg}</div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger py-2">${errorMsg}</div>
            </c:if>

            <div class="row g-4">

                <%-- ===================== SIDEBAR ===================== --%>
                <div class="col-lg-3">
                    <div class="card lc-elev p-3">
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
                            <a class="lc-navitem active" href="${pageContext.request.contextPath}/customer/profile">
                                <i class="bi bi-person"></i> Profile</a>
                            <%-- Change password is a separate feature (owner AnhND, page by HoangHM) --%>
                            <a class="lc-navitem" href="${pageContext.request.contextPath}/auth/change-password">
                                <i class="bi bi-shield-lock"></i> Security</a>
                            <%-- Not-yet-built items: shown but not clickable (avoid 404) --%>
                            <span class="lc-navitem disabled"><i class="bi bi-ticket-perforated"></i> My Bookings <span class="lc-soon">Soon</span></span>
                            <span class="lc-navitem disabled"><i class="bi bi-bell"></i> Notifications <span class="lc-soon">Soon</span></span>
                            <span class="lc-navitem disabled"><i class="bi bi-chat-dots"></i> Feedback <span class="lc-soon">Soon</span></span>
                            <hr style="margin:10px 0; border-color:#eef1f5;">
                            <a class="lc-navitem" style="color:#dc3545;" href="${pageContext.request.contextPath}/auth/logout">
                                <i class="bi bi-box-arrow-right"></i> Sign out</a>
                        </nav>
                    </div>
                </div>

                <%-- ===================== CONTENT ===================== --%>
                <div class="col-lg-9">

                    <%-- ---------- Personal Information ---------- --%>
                    <form method="post" action="${pageContext.request.contextPath}/customer/profile" class="profile-form">
                        <div class="card lc-elev p-4 mb-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <h4 class="text-navy fw-bold mb-1">Personal Information</h4>
                                    <p class="text-muted small mb-0">Update your personal details. Username and email can't be changed.</p>
                                </div>
                                <button type="button" id="editBtn" class="btn btn-outline-primary btn-sm">
                                    <i class="bi bi-pencil me-1"></i>Edit</button>
                                <div id="editActions" class="d-none gap-2">
                                    <button type="button" class="btn btn-outline-secondary btn-sm" onclick="location.reload()">Cancel</button>
                                    <button type="submit" class="btn btn-primary btn-sm">Save changes</button>
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Full Name</label>
                                    <input type="text" name="fullName" class="form-control editable-field"
                                           value="<c:out value='${cu.fullName}'/>" maxlength="100" required disabled>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Username</label>
                                    <input type="text" class="form-control" value="<c:out value='${cu.username}'/>" disabled>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label d-flex justify-content-between">
                                        <span>Email</span>
                                        <c:if test="${cu.emailVerified}">
                                            <span class="text-success"><i class="bi bi-patch-check-fill me-1"></i>Verified</span>
                                        </c:if>
                                    </label>
                                    <input type="email" class="form-control" value="<c:out value='${cu.email}'/>" disabled>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Phone Number</label>
                                    <input type="text" name="phone" class="form-control editable-field"
                                           value="<c:out value='${cu.phone}'/>" placeholder="e.g. 0901234567" disabled>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Date of Birth</label>
                                    <input type="date" name="dateOfBirth" class="form-control editable-field"
                                           value="<c:out value='${cu.dateOfBirth}'/>" disabled>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Address</label>
                                    <input type="text" name="address" class="form-control editable-field"
                                           value="<c:out value='${cu.address}'/>" maxlength="200" disabled>
                                </div>
                            </div>
                        </div>
                    </form>

                    <%-- ---------- Security (delegates to the Change Password feature) ---------- --%>
                    <div class="card lc-elev p-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h5 class="text-navy fw-bold mb-1"><i class="bi bi-shield-lock me-2" style="color:var(--primary);"></i>Security</h5>
                                <p class="text-muted small mb-0">Keep your account safe. Change your password regularly.</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/auth/change-password" class="btn btn-outline-primary">
                                <i class="bi bi-key me-1"></i>Change Password</a>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (function () {
                var editBtn = document.getElementById('editBtn');
                var editActions = document.getElementById('editActions');
                var fields = document.querySelectorAll('.editable-field');
                function enterEdit() {
                    fields.forEach(function (f) { f.disabled = false; });
                    editBtn.classList.add('d-none');
                    editActions.classList.remove('d-none');
                    editActions.classList.add('d-flex');
                }
                editBtn.addEventListener('click', enterEdit);
                <c:if test="${startEdit}">enterEdit();</c:if>
            })();
        </script>
    </body>

</html>
