<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>User Management - PentaPlex Admin</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="users"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Admin / <strong>Users</strong></div>
                <h1 class="lc-page-title">User Management</h1>
                <p class="text-muted small mb-0 mt-1">Manage customers, branch staff and administrators across the system.</p>
            </div>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success py-2 alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i>${successMsg}
                <button class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger py-2 alert-dismissible fade show"><i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMsg}
                <button class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>

        <div class="lc-kpi-row lc-kpi-row--5">
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-people-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Total users</div>
                    <div class="lc-kpi-value">${stats.totalUsers}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-person-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Customers</div>
                    <div class="lc-kpi-value">${stats.customersCount}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--violet"><i class="bi bi-person-badge-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Branch managers</div>
                    <div class="lc-kpi-value">${stats.branchManagersCount}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-person-vcard-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Branch staff</div>
                    <div class="lc-kpi-value">${stats.branchStaffCount}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--rose"><i class="bi bi-shield-fill-check"></i></div>
                <div>
                    <div class="lc-kpi-label">Admins</div>
                    <div class="lc-kpi-value">${stats.adminsCount}</div>
                </div>
            </div>
        </div>

        <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
            <form id="filterForm" method="get" action="${pageContext.request.contextPath}/admin/users"
                  class="st-toolbar-track w-100">
                <div class="lc-toolbar-search">
                    <i class="bi bi-search" aria-hidden="true"></i>
                    <input type="search" name="search" value="<c:out value='${searchQuery}'/>"
                           placeholder="Search by name, email, or username..." aria-label="Search users">
                </div>
                <div class="st-toolbar-vrule" aria-hidden="true"></div>
                <select name="role" class="st-toolbar-select" onchange="this.form.submit()" aria-label="Filter by role">
                    <option value="">All roles</option>
                    <option value="CUSTOMER" ${selectedRole == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                    <option value="BRANCH_MANAGER" ${selectedRole == 'BRANCH_MANAGER' ? 'selected' : ''}>Branch Manager</option>
                    <option value="BRANCH_STAFF" ${selectedRole == 'BRANCH_STAFF' ? 'selected' : ''}>Branch Staff</option>
                    <option value="ADMIN" ${selectedRole == 'ADMIN' ? 'selected' : ''}>Admin</option>
                </select>
                <div class="st-toolbar-vrule" aria-hidden="true"></div>
                <select name="branchId" class="st-toolbar-select" onchange="this.form.submit()" aria-label="Filter by cinema">
                    <option value="">All cinemas</option>
                    <c:forEach items="${branches}" var="b">
                        <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}><c:out value="${b.name}"/></option>
                    </c:forEach>
                </select>
                <div class="st-toolbar-vrule" aria-hidden="true"></div>
                <input type="hidden" id="statusInput" name="status" value="<c:out value='${selectedStatus}'/>">
                <div class="lc-seg" role="tablist" aria-label="Filter by status">
                    <button type="button" class="lc-seg-btn ${empty selectedStatus ? 'active' : ''}" onclick="setStatus('')">All</button>
                    <button type="button" class="lc-seg-btn ${selectedStatus == 'Active' ? 'active' : ''}" onclick="setStatus('Active')">Active</button>
                    <button type="button" class="lc-seg-btn ${selectedStatus == 'Inactive' ? 'active' : ''}" onclick="setStatus('Inactive')">Inactive</button>
                </div>
                <div class="lc-toolbar-spacer" aria-hidden="true"></div>
                <button type="button" onclick="exportCSV()" class="btn btn-light border btn-sm">
                    <i class="bi bi-file-earmark-arrow-down me-1"></i>Export</button>
                <a href="${pageContext.request.contextPath}/admin/users?action=add" class="st-toolbar-add">
                    <i class="bi bi-plus-lg" aria-hidden="true"></i> Add User</a>
            </form>
        </div>

        <div class="card lc-elev p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table lc-table align-middle mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3" style="width:40px;"><input class="form-check-input" type="checkbox" id="selectAll"></th>
                        <th>User</th><th>Email</th><th>Role</th><th>Assigned cinema</th>
                        <th>Last login</th><th>Status</th><th class="text-end pe-3">Actions</th>
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
                                <tr>
                                    <td class="ps-3"><input class="form-check-input user-checkbox" type="checkbox" value="${user.username}"></td>
                                    <td>
                                        <div class="pay-cust">
                                            <div class="pay-avatar"><c:out value="${fn:toUpperCase(initials)}"/></div>
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
                                    <td class="text-end pe-3">
                                        <div class="d-inline-flex gap-1">
                                            <a href="${pageContext.request.contextPath}/admin/users?action=edit&username=${user.username}"
                                               class="u-act a-edit" title="Edit"><i class="bi bi-pencil"></i></a>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/users" class="d-inline"
                                                  onsubmit="return confirm('Send a password-reset email to this user?')">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                                <input type="hidden" name="action" value="resetPassword">
                                                <input type="hidden" name="username" value="${user.username}">
                                                <button type="submit" class="u-act a-key" title="Send reset link"><i class="bi bi-key"></i></button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/users" class="d-inline"
                                                  onsubmit="return confirm('Change this user\'s active status?')">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
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

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
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
