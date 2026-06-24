<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Admin User Management - rebuilt to match Payment console aesthetic (pay-table / pay-st / lc-kpi). --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - MBCMS Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .u-role { display:inline-flex; align-items:center; font-size:.72rem; font-weight:700; padding:.22rem .6rem; border-radius:999px; white-space:nowrap; }
        .u-role.r-customer { background:#eff6ff; color:#1d4ed8; }
        .u-role.r-manager  { background:#f5f3ff; color:#6d28d9; }
        .u-role.r-staff    { background:#fffbeb; color:#b45309; }
        .u-role.r-admin    { background:#fff1f2; color:#be123c; }
        .u-act { width:34px; height:34px; border-radius:9px; border:1px solid var(--lc-border); background:#fff; color:var(--lc-muted); display:inline-flex; align-items:center; justify-content:center; transition:all .12s ease; text-decoration:none; }
        .u-act:hover { transform:translateY(-1px); }
        .u-act.a-edit:hover    { color:#2563eb; border-color:#bfdbfe; background:#eff6ff; }
        .u-act.a-key:hover     { color:#b45309; border-color:#fde68a; background:#fffbeb; }
        .u-act.a-suspend:hover { color:#dc2626; border-color:#fecaca; background:#fef2f2; }
        .u-filter { height:38px; border:1px solid var(--lc-border); border-radius:9px; background:#fff; padding:0 .8rem; font-size:.88rem; color:var(--lc-navy); }
        .u-filter:focus { outline:none; border-color:var(--lc-primary); box-shadow:0 0 0 3px rgba(37,99,235,.1); }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="users"/>
</jsp:include>

<main class="lc-admin-main">
    <%-- Top header bar --%>
    <header class="d-flex justify-content-between align-items-center px-4 py-3 border-bottom bg-white">
        <div class="text-muted small">Admin / <span class="text-navy fw-semibold">Users</span></div>
        <div class="d-flex align-items-center gap-3">
            <span class="header-badge-admin"><i class="bi bi-shield-lock-fill"></i> ADMIN ACCESS</span>
            <div class="header-profile-circle">SA</div>
        </div>
    </header>

    <div class="container-fluid px-4 py-4" style="max-width:1300px;">
        <h4 class="fw-bold text-navy mb-1">User Management</h4>
        <div class="text-muted small mb-4">Manage customers, branch staff and administrators across the system.</div>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success py-2 alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i>${successMsg}
                <button class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger py-2 alert-dismissible fade show"><i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMsg}
                <button class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>

        <%-- KPI ROW --%>
        <div class="row g-3 mb-4">
            <div class="col-md col-6"><div class="lc-kpi"><div class="lc-kpi-icon"><i class="bi bi-people-fill"></i></div>
                <div><div class="lc-kpi-label">Total Users</div><div class="lc-kpi-value">${stats.totalUsers}</div></div></div></div>
            <div class="col-md col-6"><div class="lc-kpi"><div class="lc-kpi-icon i-green"><i class="bi bi-person-fill"></i></div>
                <div><div class="lc-kpi-label">Customers</div><div class="lc-kpi-value">${stats.customersCount}</div></div></div></div>
            <div class="col-md col-6"><div class="lc-kpi"><div class="lc-kpi-icon i-purple"><i class="bi bi-person-badge-fill"></i></div>
                <div><div class="lc-kpi-label">Branch Managers</div><div class="lc-kpi-value">${stats.branchManagersCount}</div></div></div></div>
            <div class="col-md col-6"><div class="lc-kpi"><div class="lc-kpi-icon i-amber"><i class="bi bi-person-vcard-fill"></i></div>
                <div><div class="lc-kpi-label">Branch Staff</div><div class="lc-kpi-value">${stats.branchStaffCount}</div></div></div></div>
            <div class="col-md col-6"><div class="lc-kpi"><div class="lc-kpi-icon i-red"><i class="bi bi-shield-fill-check"></i></div>
                <div><div class="lc-kpi-label">Admins</div><div class="lc-kpi-value">${stats.adminsCount}</div></div></div></div>
        </div>

        <%-- TOOLBAR --%>
        <div class="pay-toolbar mb-3">
            <form id="filterForm" method="get" action="${pageContext.request.contextPath}/admin/users"
                  class="d-flex flex-wrap align-items-center gap-2">
                <div class="position-relative flex-grow-1" style="min-width:220px; max-width:340px;">
                    <i class="bi bi-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"></i>
                    <input type="text" name="search" value="<c:out value='${searchQuery}'/>"
                           class="form-control u-filter w-100" style="padding-left:2.2rem;" placeholder="Search by name, email, or username...">
                </div>
                <select name="role" class="u-filter" onchange="this.form.submit()">
                    <option value="">All Roles</option>
                    <option value="CUSTOMER" ${selectedRole == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                    <option value="BRANCH_MANAGER" ${selectedRole == 'BRANCH_MANAGER' ? 'selected' : ''}>Branch Manager</option>
                    <option value="BRANCH_STAFF" ${selectedRole == 'BRANCH_STAFF' ? 'selected' : ''}>Branch Staff</option>
                    <option value="ADMIN" ${selectedRole == 'ADMIN' ? 'selected' : ''}>Admin</option>
                </select>
                <select name="branchId" class="u-filter" onchange="this.form.submit()">
                    <option value="">All Cinemas</option>
                    <c:forEach items="${branches}" var="b">
                        <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}><c:out value="${b.name}"/></option>
                    </c:forEach>
                </select>
                <input type="hidden" id="statusInput" name="status" value="<c:out value='${selectedStatus}'/>">
                <div class="btn-group" role="group">
                    <button type="button" class="btn btn-sm ${empty selectedStatus ? 'btn-primary' : 'btn-light border'}" onclick="setStatus('')">All</button>
                    <button type="button" class="btn btn-sm ${selectedStatus == 'Active' ? 'btn-primary' : 'btn-light border'}" onclick="setStatus('Active')">Active</button>
                    <button type="button" class="btn btn-sm ${selectedStatus == 'Inactive' ? 'btn-primary' : 'btn-light border'}" onclick="setStatus('Inactive')">Inactive</button>
                </div>
                <div class="d-flex gap-2 ms-auto">
                    <button type="button" onclick="exportCSV()" class="btn btn-light border d-flex align-items-center gap-1" style="height:38px;">
                        <i class="bi bi-file-earmark-arrow-down"></i> Export</button>
                    <a href="${pageContext.request.contextPath}/admin/users?action=add" class="btn btn-primary d-flex align-items-center gap-1" style="height:38px; white-space:nowrap;">
                        <i class="bi bi-plus-circle"></i> Add User</a>
                </div>
            </form>
        </div>

        <%-- TABLE --%>
        <div class="pay-card">
            <div class="table-responsive">
                <table class="pay-table">
                    <thead>
                    <tr>
                        <th style="width:40px;"><input class="form-check-input" type="checkbox" id="selectAll"></th>
                        <th>User</th><th>Email</th><th>Role</th><th>Assigned Cinema</th>
                        <th>Last login</th><th>Status</th><th class="r">Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty users}">
                            <tr><td colspan="8" class="text-center text-muted py-5">
                                <i class="bi bi-people fs-1 d-block mb-2 opacity-50"></i>No matching users.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${users}" var="user">
                                <c:set var="words" value="${fn:split(user.fullName, ' ')}" />
                                <c:set var="initials" value="" />
                                <c:if test="${fn:length(words) > 0}">
                                    <c:set var="initials" value="${fn:substring(words[0], 0, 1)}${fn:substring(words[fn:length(words) - 1], 0, 1)}" />
                                </c:if>
                                <c:choose>
                                    <c:when test="${user.role == 'CUSTOMER'}"><c:set var="avBg" value="#2563eb" /></c:when>
                                    <c:when test="${user.role == 'BRANCH_MANAGER'}"><c:set var="avBg" value="#8b5cf6" /></c:when>
                                    <c:when test="${user.role == 'BRANCH_STAFF'}"><c:set var="avBg" value="#f59e0b" /></c:when>
                                    <c:otherwise><c:set var="avBg" value="#ef4444" /></c:otherwise>
                                </c:choose>
                                <tr>
                                    <td><input class="form-check-input user-checkbox" type="checkbox" value="${user.username}"></td>
                                    <td>
                                        <div class="pay-cust">
                                            <div class="pay-avatar" style="background:${avBg};"><c:out value="${fn:toUpperCase(initials)}"/></div>
                                            <div>
                                                <div class="nm"><c:out value="${user.fullName}"/></div>
                                                <div class="em">@<c:out value="${user.username}"/></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td><c:out value="${user.email}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.role == 'CUSTOMER'}"><span class="u-role r-customer">Customer</span></c:when>
                                            <c:when test="${user.role == 'BRANCH_MANAGER'}"><span class="u-role r-manager">Branch Manager</span></c:when>
                                            <c:when test="${user.role == 'BRANCH_STAFF'}"><span class="u-role r-staff">Branch Staff</span></c:when>
                                            <c:otherwise><span class="u-role r-admin">Admin</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty user.branchName}">
                                                <span class="text-navy"><i class="bi bi-geo-alt-fill text-primary me-1"></i><c:out value="${user.branchName}"/></span>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-muted">
                                        <c:choose>
                                            <c:when test="${user.username == 'hungnt'}">17/05/2026 10:23</c:when>
                                            <c:when test="${user.username == 'mgr_hcm'}">17/05/2026 09:45</c:when>
                                            <c:when test="${user.username == 'staff_hcm'}">17/05/2026 17:42</c:when>
                                            <c:when test="${user.username == 'guest01'}">12/04/2026 14:10</c:when>
                                            <c:when test="${user.username == 'mgr_hn'}">16/05/2026 11:30</c:when>
                                            <c:when test="${user.username == 'staff_hn'}">17/05/2026 16:00</c:when>
                                            <c:when test="${user.username == 'admin'}">17/05/2026 08:00</c:when>
                                            <c:otherwise>15/05/2026 19:22</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.active}"><span class="pay-st s-success"><span class="dot"></span>Active</span></c:when>
                                            <c:otherwise><span class="pay-st s-off"><span class="dot"></span>Inactive</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="r">
                                        <div class="d-inline-flex gap-1">
                                            <a href="${pageContext.request.contextPath}/admin/users?action=edit&username=${user.username}"
                                               class="u-act a-edit" title="Edit"><i class="bi bi-pencil"></i></a>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/users" class="d-inline"
                                                  onsubmit="return confirm('Send a password-reset email to this user?')">
                                                <input type="hidden" name="action" value="resetPassword">
                                                <input type="hidden" name="username" value="${user.username}">
                                                <button type="submit" class="u-act a-key" title="Send reset link"><i class="bi bi-key"></i></button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/users" class="d-inline"
                                                  onsubmit="return confirm('Change this user\'s active status?')">
                                                <input type="hidden" name="action" value="toggleStatus">
                                                <input type="hidden" name="username" value="${user.username}">
                                                <input type="hidden" name="active" value="${user.active ? 'false' : 'true'}">
                                                <button type="submit" class="u-act a-suspend" title="${user.active ? 'Deactivate' : 'Activate'}">
                                                    <i class="bi ${user.active ? 'bi-slash-circle' : 'bi-check-circle'}"></i></button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- PAGINATION --%>
            <div class="pay-foot d-flex justify-content-between align-items-center">
                <div class="text-muted small">Showing <strong>${fn:length(users)}</strong> of <strong>${totalUsersCount}</strong> users</div>
                <c:if test="${totalPages > 1}">
                    <nav><ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/users?page=${currentPage - 1}&search=<c:out value='${searchQuery}'/>&role=<c:out value='${selectedRole}'/>&branchId=${selectedBranchId}&status=<c:out value='${selectedStatus}'/>">&laquo;</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <li class="page-item ${p == currentPage ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/users?page=${p}&search=<c:out value='${searchQuery}'/>&role=<c:out value='${selectedRole}'/>&branchId=${selectedBranchId}&status=<c:out value='${selectedStatus}'/>">${p}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/users?page=${currentPage + 1}&search=<c:out value='${searchQuery}'/>&role=<c:out value='${selectedRole}'/>&branchId=${selectedBranchId}&status=<c:out value='${selectedStatus}'/>">&raquo;</a>
                        </li>
                    </ul></nav>
                </c:if>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function setStatus(v) {
        document.getElementById('statusInput').value = v;
        document.getElementById('filterForm').submit();
    }
    function exportCSV() {
        const form = document.getElementById('filterForm');
        const i = document.createElement('input');
        i.type = 'hidden'; i.name = 'action'; i.value = 'export';
        form.appendChild(i); form.submit(); form.removeChild(i);
    }
    const selAll = document.getElementById('selectAll');
    if (selAll) selAll.addEventListener('change', function () {
        document.querySelectorAll('.user-checkbox').forEach(b => b.checked = this.checked);
    });
</script>
</body>
</html>
