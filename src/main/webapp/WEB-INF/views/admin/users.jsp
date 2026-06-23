<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - LuminaCine</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="users"/>
</jsp:include>

<main class="lc-admin-main">
    <!-- TOP NAVBAR / HEADER -->
    <header class="d-flex justify-content-between align-items-center px-4 py-3 border-bottom bg-white shadow-sm">
        <div class="d-flex align-items-center gap-2">
            <span class="text-muted fs-7">Admin</span>
            <span class="text-muted fs-7">/</span>
            <span class="text-dark fs-7 fw-medium">Users</span>
        </div>
        <div class="d-flex align-items-center gap-3">
            <span class="header-badge-admin">
                <i class="bi bi-shield-lock-fill"></i> ADMIN ACCESS
            </span>
            <button class="btn btn-link p-0 text-muted position-relative">
                <i class="bi bi-bell fs-5"></i>
                <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
            </button>
            <div class="header-profile-circle">SA</div>
        </div>
    </header>

    <div class="container-fluid px-4 py-4" style="max-width: 1300px;">
        <h2 class="fw-bold text-dark mb-4">User Management</h2>

        <!-- ALERTS -->
        <c:if test="${not empty successMsg}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> ${successMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> ${errorMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- KPI SUMMARY CARDS -->
        <div class="row g-3 mb-4">
            <div class="col">
                <div class="card user-stat-card h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="user-stat-icon-wrapper icon-total">
                            <i class="bi bi-people-fill"></i>
                        </div>
                        <div>
                            <div class="text-muted fs-8 fw-semibold text-uppercase">Total users</div>
                            <h3 class="fw-bold mb-0 text-dark">${stats.totalUsers}</h3>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card user-stat-card h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="user-stat-icon-wrapper icon-customer">
                            <i class="bi bi-person-fill"></i>
                        </div>
                        <div>
                            <div class="text-muted fs-8 fw-semibold text-uppercase">Customers</div>
                            <h3 class="fw-bold mb-0 text-dark">${stats.customersCount}</h3>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card user-stat-card h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="user-stat-icon-wrapper icon-manager">
                            <i class="bi bi-person-workspace"></i>
                        </div>
                        <div>
                            <div class="text-muted fs-8 fw-semibold text-uppercase">Branch Managers</div>
                            <h3 class="fw-bold mb-0 text-dark">${stats.branchManagersCount}</h3>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card user-stat-card h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="user-stat-icon-wrapper icon-staff">
                            <i class="bi bi-person-badge-fill"></i>
                        </div>
                        <div>
                            <div class="text-muted fs-8 fw-semibold text-uppercase">Branch Staff</div>
                            <h3 class="fw-bold mb-0 text-dark">${stats.branchStaffCount}</h3>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card user-stat-card h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="user-stat-icon-wrapper icon-admin">
                            <i class="bi bi-shield-fill-check"></i>
                        </div>
                        <div>
                            <div class="text-muted fs-8 fw-semibold text-uppercase">Admins</div>
                            <h3 class="fw-bold mb-0 text-dark">${stats.adminsCount}</h3>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- FILTER & SEARCH PANEL -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body py-3">
                <form id="filterForm" method="get" action="${pageContext.request.contextPath}/admin/users" class="row g-3 align-items-center">
                    <!-- Search input -->
                    <div class="col-lg-4 col-md-6 position-relative">
                        <i class="bi bi-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"></i>
                        <input type="text" name="search" value="<c:out value='${searchQuery}'/>" 
                               class="form-control filter-search-input w-100" placeholder="Search by name, email, or username...">
                    </div>
                    
                    <!-- Role select -->
                    <div class="col-lg-2 col-md-3">
                        <select name="role" class="form-select filter-select" onchange="this.form.submit()">
                            <option value="">All Roles</option>
                            <option value="CUSTOMER" ${selectedRole == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                            <option value="BRANCH_MANAGER" ${selectedRole == 'BRANCH_MANAGER' ? 'selected' : ''}>Branch Manager</option>
                            <option value="BRANCH_STAFF" ${selectedRole == 'BRANCH_STAFF' ? 'selected' : ''}>Branch Staff</option>
                            <option value="ADMIN" ${selectedRole == 'ADMIN' ? 'selected' : ''}>Admin</option>
                        </select>
                    </div>

                    <!-- Cinema select -->
                    <div class="col-lg-2 col-md-3">
                        <select name="branchId" class="form-select filter-select" onchange="this.form.submit()">
                            <option value="">All Cinemas</option>
                            <c:forEach items="${branches}" var="b">
                                <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}>${b.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Hidden status input -->
                    <input type="hidden" id="statusInput" name="status" value="<c:out value='${selectedStatus}'/>">

                    <!-- Status toggle button group -->
                    <div class="col-lg-2 col-md-6">
                        <div class="btn-group w-100" role="group">
                            <button type="button" class="btn filter-toggle-btn ${empty selectedStatus ? 'active btn-primary' : 'btn-outline-secondary'}" 
                                    onclick="setStatus('')">All</button>
                            <button type="button" class="btn filter-toggle-btn ${selectedStatus == 'Active' ? 'active btn-primary' : 'btn-outline-secondary'}" 
                                    onclick="setStatus('Active')">Active</button>
                            <button type="button" class="btn filter-toggle-btn ${selectedStatus == 'Inactive' ? 'active btn-primary' : 'btn-outline-secondary'}" 
                                    onclick="setStatus('Inactive')">Inactive</button>
                        </div>
                    </div>

                    <!-- Export & Add buttons -->
                    <div class="col-lg-2 col-md-6 d-flex gap-2 justify-content-end">
                        <button type="button" onclick="exportCSV()" class="btn btn-outline-secondary d-flex align-items-center gap-1" style="height:38px;">
                            <i class="bi bi-file-earmark-arrow-down"></i> Export
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/users?action=add" class="btn btn-primary d-flex align-items-center gap-1" style="height:38px; white-space:nowrap;">
                            <i class="bi bi-plus-circle"></i> Add User
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- USERS TABLE -->
        <div class="card border-0 shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4" width="40">
                                    <input class="form-check-input" type="checkbox" id="selectAll">
                                </th>
                                <th>User</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Assigned Cinema</th>
                                <th>Last login</th>
                                <th>Status</th>
                                <th class="pe-4 text-end" width="150">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty users}">
                                    <tr>
                                        <td colspan="8" class="text-center py-5 text-muted">
                                            <i class="bi bi-people fs-1 d-block mb-2"></i>
                                            Không tìm thấy người dùng nào phù hợp.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${users}" var="user">
                                        <tr>
                                            <td class="ps-4">
                                                <input class="form-check-input user-checkbox" type="checkbox" value="${user.username}">
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center gap-3">
                                                    <!-- Initials Avatar -->
                                                    <c:set var="words" value="${fn:split(user.fullName, ' ')}" />
                                                    <c:set var="initials" value="" />
                                                    <c:if test="${fn:length(words) > 0}">
                                                        <c:set var="firstWord" value="${words[0]}" />
                                                        <c:set var="lastWord" value="${words[fn:length(words) - 1]}" />
                                                        <c:set var="initials" value="${fn:substring(firstWord, 0, 1)}${fn:substring(lastWord, 0, 1)}" />
                                                    </c:if>
                                                    <c:choose>
                                                        <c:when test="${user.role == 'CUSTOMER'}"><c:set var="avBg" value="#2563eb" /></c:when>
                                                        <c:when test="${user.role == 'BRANCH_MANAGER'}"><c:set var="avBg" value="#8b5cf6" /></c:when>
                                                        <c:when test="${user.role == 'BRANCH_STAFF'}"><c:set var="avBg" value="#f59e0b" /></c:when>
                                                        <c:otherwise><c:set var="avBg" value="#ef4444" /></c:otherwise>
                                                    </c:choose>
                                                    <div class="user-avatar-circle" style="background-color: ${avBg};">
                                                        <c:out value="${fn:toUpperCase(initials)}" />
                                                    </div>
                                                    <div>
                                                        <div class="fw-bold text-dark text-truncate" style="max-width:200px;"><c:out value="${user.fullName}"/></div>
                                                        <div class="text-muted fs-8">@<c:out value="${user.username}"/></div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><c:out value="${user.email}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${user.role == 'CUSTOMER'}">
                                                        <span class="role-badge role-customer">Customer</span>
                                                    </c:when>
                                                    <c:when test="${user.role == 'BRANCH_MANAGER'}">
                                                        <span class="role-badge role-manager">Branch Manager</span>
                                                    </c:when>
                                                    <c:when test="${user.role == 'BRANCH_STAFF'}">
                                                        <span class="role-badge role-staff">Branch Staff</span>
                                                    </c:when>
                                                    <c:when test="${user.role == 'ADMIN'}">
                                                        <span class="role-badge role-admin">Admin</span>
                                                    </c:when>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty user.branchName}">
                                                        <span class="text-navy"><i class="bi bi-geo-alt-fill text-primary"></i> <c:out value="${user.branchName}"/></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">—</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="fs-8 text-muted">
                                                <!-- Mock last login based on username/role, aligned with mockup -->
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
                                                <span class="${user.active ? 'status-badge-active' : 'status-badge-inactive'}">
                                                    ${user.active ? 'Active' : 'Inactive'}
                                                </span>
                                            </td>
                                            <td class="pe-4 text-end">
                                                <div class="d-inline-flex gap-1">
                                                    <!-- Edit link -->
                                                    <a href="${pageContext.request.contextPath}/admin/users?action=edit&username=${user.username}" 
                                                       class="btn-action-icon btn-action-edit" title="Sửa thông tin">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                    
                                                    <!-- Reset password (fake reset link) -->
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn gửi email đặt lại mật khẩu cho người dùng này?')">
                                                        <input type="hidden" name="action" value="resetPassword">
                                                        <input type="hidden" name="username" value="${user.username}">
                                                        <button type="submit" class="btn-action-icon btn-action-key" title="Gửi link reset mật khẩu">
                                                            <i class="bi bi-key"></i>
                                                        </button>
                                                    </form>

                                                    <!-- Toggle active status -->
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn thay đổi trạng thái hoạt động của người dùng này?')">
                                                        <input type="hidden" name="action" value="toggleStatus">
                                                        <input type="hidden" name="username" value="${user.username}">
                                                        <input type="hidden" name="active" value="${user.active ? 'false' : 'true'}">
                                                        <button type="submit" class="btn-action-icon btn-action-suspend" title="${user.active ? 'Vô hiệu hóa' : 'Kích hoạt'}">
                                                            <i class="bi ${user.active ? 'bi-slash-circle' : 'bi-check-circle'}"></i>
                                                        </button>
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

                <!-- PAGINATION FOOTER -->
                <div class="d-flex justify-content-between align-items-center px-4 py-3 border-top bg-light">
                    <div class="text-muted fs-8">
                        Showing <strong>${fn:length(users)}</strong> of <strong>${totalUsersCount}</strong> users
                    </div>
                    <nav>
                        <ul class="pagination pagination-sm mb-0">
                            <!-- Prev page -->
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/users?page=${currentPage - 1}&search=<c:out value='${searchQuery}'/>&role=<c:out value='${selectedRole}'/>&branchId=${selectedBranchId}&status=<c:out value='${selectedStatus}'/>" aria-label="Previous">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>

                            <!-- Page links -->
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/users?page=${p}&search=<c:out value='${searchQuery}'/>&role=<c:out value='${selectedRole}'/>&branchId=${selectedBranchId}&status=<c:out value='${selectedStatus}'/>">${p}</a>
                                </li>
                            </c:forEach>

                            <!-- Next page -->
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/users?page=${currentPage + 1}&search=<c:out value='${searchQuery}'/>&role=<c:out value='${selectedRole}'/>&branchId=${selectedBranchId}&status=<c:out value='${selectedStatus}'/>" aria-label="Next">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function setStatus(statusVal) {
        document.getElementById('statusInput').value = statusVal;
        document.getElementById('filterForm').submit();
    }

    function exportCSV() {
        const form = document.getElementById('filterForm');
        
        // Create a temporary hidden input for action=export
        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'export';
        form.appendChild(actionInput);
        
        form.submit();
        
        // Cleanup
        form.removeChild(actionInput);
    }

    // Select all users checkboxes
    document.getElementById('selectAll').addEventListener('change', function() {
        const checked = this.checked;
        const boxes = document.querySelectorAll('.user-checkbox');
        boxes.forEach(box => box.checked = checked);
    });
</script>
</body>
</html>
