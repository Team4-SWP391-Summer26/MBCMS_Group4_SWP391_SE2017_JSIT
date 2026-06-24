<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:choose><c:when test="${isAdd}">Add User</c:when><c:otherwise>Edit User</c:otherwise></c:choose> – LuminaCine</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">

    <style>
        /* ── Topbar ─────────────────────────────────────── */
        .lc-topbar {
            display: flex; align-items: center; justify-content: space-between;
            padding: .75rem 1.75rem; background: #fff;
            border-bottom: 1px solid var(--lc-border);
            position: sticky; top: 0; z-index: 100;
        }
        .lc-topbar-breadcrumb { font-size: .82rem; color: var(--lc-muted); }
        .lc-topbar-breadcrumb a { color: var(--lc-muted); text-decoration: none; }
        .lc-topbar-breadcrumb a:hover { color: var(--lc-primary); }
        .lc-topbar-title { font-size: 1.45rem; font-weight: 800; color: #0f1e36; margin-top: 1px; }

        /* ── Panel card ──────────────────────────────────── */
        .lc-panel {
            background: #fff; border: 1px solid var(--lc-border);
            border-radius: 16px; box-shadow: var(--lc-shadow);
        }
        .lc-panel-header {
            padding: 1.1rem 1.4rem;
            border-bottom: 1px solid var(--lc-border);
            font-size: .88rem; font-weight: 700; color: #0f1e36;
            display: flex; align-items: center; gap: .5rem;
        }

        /* ── Avatar ──────────────────────────────────────── */
        .lc-user-avatar {
            width: 80px; height: 80px; border-radius: 999px;
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem; font-weight: 800; color: #fff;
            margin: 0 auto 1rem;
            flex-shrink: 0;
        }

        /* ── Form controls ───────────────────────────────── */
        .lc-label {
            font-size: .78rem; font-weight: 600; color: #374151;
            margin-bottom: .3rem; display: block;
        }
        .lc-input {
            border: 1px solid var(--lc-border); border-radius: 8px;
            padding: .5rem .75rem; font-size: .88rem; width: 100%;
            background: #fff; color: #0f1e36;
            transition: border-color .15s, box-shadow .15s;
        }
        .lc-input:focus {
            outline: none; border-color: var(--lc-primary);
            box-shadow: 0 0 0 3px rgba(37,99,235,.1);
        }
        .lc-input[readonly] { background: #F8FAFC; color: var(--lc-muted); cursor: not-allowed; }
        .lc-input-group { margin-bottom: .9rem; }
        .lc-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: .75rem; }

        /* ── Role picker cards ───────────────────────────── */
        .role-picker-wrap { display: grid; grid-template-columns: 1fr 1fr; gap: .6rem; }
        .role-picker-input { display: none; }
        .role-picker-card {
            border: 1.5px solid var(--lc-border); border-radius: 10px;
            padding: .85rem .9rem; cursor: pointer;
            transition: border-color .15s, background .15s, box-shadow .15s;
            display: flex; flex-direction: column; gap: .3rem;
        }
        .role-picker-card:hover { border-color: #93C5FD; background: #F8FAFF; }
        .role-picker-input:checked + .role-picker-card {
            border-color: var(--lc-primary); background: #EFF6FF;
            box-shadow: 0 0 0 1.5px var(--lc-primary);
        }
        .role-icon {
            width: 32px; height: 32px; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; margin-bottom: .2rem;
        }
        .role-name { font-size: .82rem; font-weight: 700; color: #0f1e36; }
        .role-desc { font-size: .72rem; color: var(--lc-muted); line-height: 1.3; }

        /* ── Status / action cards ───────────────────────── */
        .lc-status-card {
            border: 1px solid var(--lc-border); border-radius: 12px;
            padding: .9rem 1rem; margin-bottom: .75rem;
        }
        .lc-status-title { font-size: .82rem; font-weight: 700; color: #0f1e36; }
        .lc-status-sub   { font-size: .75rem; color: var(--lc-muted); }

        /* ── Buttons ─────────────────────────────────────── */
        .lc-btn {
            padding: .55rem 1.2rem; border-radius: 8px; font-size: .88rem;
            font-weight: 600; border: none; cursor: pointer; display: inline-flex;
            align-items: center; gap: .4rem; text-decoration: none;
            transition: background .12s, opacity .12s;
        }
        .lc-btn-primary { background: var(--lc-primary); color: #fff; }
        .lc-btn-primary:hover { background: var(--lc-primary-700); color: #fff; }
        .lc-btn-ghost { background: var(--lc-light); color: #374151; border: 1px solid var(--lc-border); }
        .lc-btn-ghost:hover { background: #E2E8F0; color: #0f1e36; }
        .lc-btn-danger-soft { background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; }
        .lc-btn-danger-soft:hover { background: #FECACA; }
        .lc-btn-warn-soft { background: #FEF3C7; color: #92400E; border: 1px solid #FDE68A; }
        .lc-btn-warn-soft:hover { background: #FDE68A; }
        .lc-btn-sm { padding: .4rem .9rem; font-size: .8rem; }
        .lc-btn-block { width: 100%; justify-content: center; }

        /* ── Alert ───────────────────────────────────────── */
        .lc-alert {
            border-radius: 10px; font-size: .88rem; padding: .7rem 1rem;
            display: flex; align-items: center; gap: .6rem;
            border: none; margin-bottom: 1.25rem;
        }
        .lc-alert-success { background: #D1FAE5; color: #065F46; }
        .lc-alert-danger  { background: #FEE2E2; color: #991B1B; }

        /* ── Branch dropdown (conditional) ──────────────── */
        #branchSection { display: none; }
        #branchSection.show { display: block; }

        /* ── Divider ─────────────────────────────────────── */
        .lc-divider {
            border: none; border-top: 1px solid var(--lc-border);
            margin: 1rem 0;
        }

        /* ── Account ID chip ─────────────────────────────── */
        .lc-chip {
            display: inline-flex; align-items: center; gap: .35rem;
            background: var(--lc-light); color: var(--lc-primary);
            font-size: .75rem; font-weight: 600; padding: .28rem .7rem;
            border-radius: 999px; border: 1px solid #BFDBFE;
        }
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="users"/>
</jsp:include>

<main class="lc-admin-main">

    <%-- ── Topbar ──────────────────────────────────────────── --%>
    <div class="lc-topbar">
        <div>
            <div class="lc-topbar-breadcrumb">
                <a href="${pageContext.request.contextPath}/admin/dashboard">Admin</a>
                <span class="mx-1">/</span>
                <a href="${pageContext.request.contextPath}/admin/users">Users</a>
                <span class="mx-1">/</span>
                <c:choose>
                    <c:when test="${isAdd}">Add User</c:when>
                    <c:otherwise>Edit User</c:otherwise>
                </c:choose>
            </div>
            <div class="lc-topbar-title">
                <c:choose>
                    <c:when test="${isAdd}">Add New User</c:when>
                    <c:otherwise>Edit User</c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="d-flex align-items-center gap-3">
            <span class="header-badge-admin">
                <i class="bi bi-shield-fill"></i> ADMIN ACCESS
            </span>
            <div class="header-profile-circle">SA</div>
        </div>
    </div>

    <div class="container-fluid px-4 py-4">

        <%-- ── Alerts ────────────────────────────────────────── --%>
        <c:if test="${not empty successMsg}">
            <div class="lc-alert lc-alert-success alert-dismissible">
                <i class="bi bi-check-circle-fill"></i> ${successMsg}
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="lc-alert lc-alert-danger alert-dismissible">
                <i class="bi bi-exclamation-circle-fill"></i> ${errorMsg}
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>

        <%-- ── Back link ─────────────────────────────────────── --%>
        <a href="${pageContext.request.contextPath}/admin/users" class="lc-btn lc-btn-ghost lc-btn-sm mb-3">
            <i class="bi bi-arrow-left"></i> Back to Users
        </a>

        <%-- ── Main form ─────────────────────────────────────── --%>
        <form method="post" action="${pageContext.request.contextPath}/admin/users" id="mainForm">
            <input type="hidden" name="action" value="${isAdd ? 'add' : 'edit'}">
            <c:if test="${not isAdd}">
                <input type="hidden" name="username" value="${user.username}">
            </c:if>

            <div class="row g-4">

                <%-- ══ LEFT COLUMN ══════════════════════════════ --%>
                <div class="col-lg-4">

                    <%-- Avatar + identity card --%>
                    <div class="lc-panel mb-3">
                        <div class="p-4 text-center">

                            <%-- Dynamic avatar colour based on role --%>
                            <c:set var="avatarBg" value="#2563EB"/>
                            <c:if test="${not isAdd}">
                                <c:choose>
                                    <c:when test="${user.role == 'ADMIN'}">          <c:set var="avatarBg" value="#DC2626"/></c:when>
                                    <c:when test="${user.role == 'BRANCH_MANAGER'}"> <c:set var="avatarBg" value="#7C3AED"/></c:when>
                                    <c:when test="${user.role == 'BRANCH_STAFF'}">   <c:set var="avatarBg" value="#D97706"/></c:when>
                                    <c:otherwise>                                    <c:set var="avatarBg" value="#2563EB"/></c:otherwise>
                                </c:choose>
                            </c:if>

                            <div class="lc-user-avatar" id="avatarEl" style="background:${avatarBg};">
                                <c:choose>
                                    <c:when test="${isAdd}"><i class="bi bi-person-plus fs-2"></i></c:when>
                                    <c:otherwise>
                                        <c:set var="initials" value="${fn:toUpperCase(fn:substring(user.fullName,0,1))}"/>
                                        ${not empty initials ? initials : '?'}
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <c:if test="${not isAdd}">
                                <div class="fw-800 fs-6 text-dark mb-1">${user.fullName}</div>
                                <div class="lc-chip mb-2">
                                    <i class="bi bi-person"></i> ${user.username}
                                </div>
                                <div class="mb-3">
                                    <c:choose>
                                        <c:when test="${user.role == 'CUSTOMER'}">         <span class="role-badge role-customer">Customer</span></c:when>
                                        <c:when test="${user.role == 'BRANCH_MANAGER'}">   <span class="role-badge role-manager">Branch Manager</span></c:when>
                                        <c:when test="${user.role == 'BRANCH_STAFF'}">     <span class="role-badge role-staff">Branch Staff</span></c:when>
                                        <c:when test="${user.role == 'ADMIN'}">            <span class="role-badge role-admin">Admin</span></c:when>
                                    </c:choose>
                                </div>
                            </c:if>

                            <c:if test="${isAdd}">
                                <div class="text-muted" style="font-size:.82rem;">Fill in the form to create a new user account.</div>
                            </c:if>
                        </div>

                        <c:if test="${not isAdd}">
                            <hr class="lc-divider m-0">
                            <div class="p-3 d-flex flex-column gap-2">

                                <%-- Active toggle --%>
                                <div class="lc-status-card d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="lc-status-title">Account Status</div>
                                        <div class="lc-status-sub">
                                            <c:choose>
                                                <c:when test="${user.active}"><span style="color:#16A34A;">● Active</span></c:when>
                                                <c:otherwise><span style="color:#94a3b8;">○ Inactive</span></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="form-check form-switch mb-0">
                                        <input class="form-check-input" type="checkbox" role="switch"
                                               name="active" id="activeToggle"
                                               style="width:2.5rem;height:1.3rem;"
                                               ${user.active ? 'checked' : ''}>
                                    </div>
                                </div>

                                <%-- Send reset password --%>
                                <form method="post" action="${pageContext.request.contextPath}/admin/users" id="resetForm">
                                    <input type="hidden" name="action" value="resetPassword">
                                    <input type="hidden" name="username" value="${user.username}">
                                    <button type="submit" class="lc-btn lc-btn-warn-soft lc-btn-sm lc-btn-block"
                                            onclick="return confirm('Send password reset email to ${user.email}?');">
                                        <i class="bi bi-key"></i> Send Password Reset Link
                                    </button>
                                </form>

                                <%-- Delete user --%>
                                <form method="post" action="${pageContext.request.contextPath}/admin/users" id="deleteForm">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="username" value="${user.username}">
                                    <button type="submit" class="lc-btn lc-btn-danger-soft lc-btn-sm lc-btn-block"
                                            onclick="return confirm('Permanently delete user ${user.username}? This cannot be undone.');">
                                        <i class="bi bi-trash"></i> Delete Account
                                    </button>
                                </form>

                            </div>
                        </c:if>
                    </div>

                    <%-- Member since (edit only) --%>
                    <c:if test="${not isAdd and user.createdAt != null}">
                        <div class="lc-panel p-3" style="font-size:.78rem;color:var(--lc-muted);">
                            <i class="bi bi-calendar3 me-1"></i> Member since
                            <strong>
                                ${user.createdAt}
                            </strong>
                            <c:if test="${not empty user.branchName}">
                                <hr class="lc-divider">
                                <i class="bi bi-building me-1"></i> Branch: <strong>${user.branchName}</strong>
                            </c:if>
                        </div>
                    </c:if>

                </div>

                <%-- ══ RIGHT COLUMN ═════════════════════════════ --%>
                <div class="col-lg-8">

                    <%-- Personal Details --%>
                    <div class="lc-panel mb-3">
                        <div class="lc-panel-header">
                            <i class="bi bi-person-lines-fill text-primary"></i> Personal Details
                        </div>
                        <div class="p-4">

                            <%-- Username --%>
                            <div class="lc-input-group">
                                <label class="lc-label" for="username">
                                    Username <span class="text-danger">*</span>
                                    <c:if test="${not isAdd}">
                                        <span style="font-weight:400;color:var(--lc-muted);font-size:.72rem;">(cannot be changed)</span>
                                    </c:if>
                                </label>
                                <c:choose>
                                    <c:when test="${isAdd}">
                                        <input type="text" id="username" name="username" class="lc-input"
                                               placeholder="e.g. john_doe" required
                                               pattern="[A-Za-z0-9_]{4,50}"
                                               title="4–50 characters, letters, numbers and underscore only"
                                               value="${param.username}">
                                    </c:when>
                                    <c:otherwise>
                                        <input type="text" id="username" class="lc-input" value="${user.username}" readonly>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <%-- Full name + Email --%>
                            <div class="lc-form-grid">
                                <div class="lc-input-group">
                                    <label class="lc-label" for="fullName">Full Name <span class="text-danger">*</span></label>
                                    <input type="text" id="fullName" name="fullName" class="lc-input"
                                           placeholder="Nguyen Van A" required maxlength="100"
                                           value="${isAdd ? param.fullName : user.fullName}">
                                </div>
                                <div class="lc-input-group">
                                    <label class="lc-label" for="email">Email <span class="text-danger">*</span></label>
                                    <input type="email" id="email" name="email" class="lc-input"
                                           placeholder="user@example.com" required
                                           value="${isAdd ? param.email : user.email}">
                                </div>
                            </div>

                            <%-- Phone + DOB --%>
                            <div class="lc-form-grid">
                                <div class="lc-input-group">
                                    <label class="lc-label" for="phone">Phone</label>
                                    <input type="text" id="phone" name="phone" class="lc-input"
                                           placeholder="0xx xxxx xxxx"
                                           value="${isAdd ? param.phone : user.phone}">
                                </div>
                                <div class="lc-input-group">
                                    <label class="lc-label" for="dateOfBirth">Date of Birth</label>
                                    <input type="date" id="dateOfBirth" name="dateOfBirth" class="lc-input"
                                           value="${isAdd ? param.dateOfBirth : user.dateOfBirth}">
                                </div>
                            </div>

                            <%-- Address --%>
                            <div class="lc-input-group mb-0">
                                <label class="lc-label" for="address">Address</label>
                                <input type="text" id="address" name="address" class="lc-input"
                                       placeholder="Street, District, City"
                                       value="${isAdd ? param.address : user.address}">
                            </div>

                        </div>
                    </div>

                    <%-- Password --%>
                    <div class="lc-panel mb-3">
                        <div class="lc-panel-header">
                            <i class="bi bi-lock-fill text-primary"></i>
                            <c:choose>
                                <c:when test="${isAdd}">Set Password</c:when>
                                <c:otherwise>Change Password <span style="font-weight:400;color:var(--lc-muted);font-size:.78rem;">(leave blank to keep current)</span></c:otherwise>
                            </c:choose>
                        </div>
                        <div class="p-4">
                            <div class="lc-input-group mb-0">
                                <label class="lc-label" for="password">
                                    Password
                                    <c:if test="${isAdd}"><span class="text-danger">*</span></c:if>
                                </label>
                                <input type="password" id="password" name="password" class="lc-input"
                                       placeholder="${isAdd ? 'Min. 6 characters' : 'New password (optional)'}"
                                       ${isAdd ? 'required minlength="6"' : 'minlength="6"'}>
                            </div>
                        </div>
                    </div>

                    <%-- Role selection --%>
                    <div class="lc-panel mb-3">
                        <div class="lc-panel-header">
                            <i class="bi bi-shield-check text-primary"></i> Role &amp; Permissions
                        </div>
                        <div class="p-4">

                            <label class="lc-label mb-2">Select Role <span class="text-danger">*</span></label>
                            <div class="role-picker-wrap mb-3" id="rolePicker">

                                <%-- CUSTOMER --%>
                                <div>
                                    <input type="radio" name="role" value="CUSTOMER" id="roleCustomer"
                                           class="role-picker-input"
                                           ${(isAdd and empty param.role) or (!isAdd and user.role == 'CUSTOMER') ? 'checked' : (param.role == 'CUSTOMER' ? 'checked' : '')}>
                                    <label for="roleCustomer" class="role-picker-card">
                                        <div class="role-icon" style="background:#EFF6FF;color:#2563EB;">
                                            <i class="bi bi-person"></i>
                                        </div>
                                        <div class="role-name">Customer</div>
                                        <div class="role-desc">End-user who books tickets</div>
                                    </label>
                                </div>

                                <%-- BRANCH MANAGER --%>
                                <div>
                                    <input type="radio" name="role" value="BRANCH_MANAGER" id="roleManager"
                                           class="role-picker-input"
                                           ${(!isAdd and user.role == 'BRANCH_MANAGER') ? 'checked' : (param.role == 'BRANCH_MANAGER' ? 'checked' : '')}>
                                    <label for="roleManager" class="role-picker-card">
                                        <div class="role-icon" style="background:#F5F3FF;color:#7C3AED;">
                                            <i class="bi bi-building-gear"></i>
                                        </div>
                                        <div class="role-name">Branch Manager</div>
                                        <div class="role-desc">Manages a single cinema branch</div>
                                    </label>
                                </div>

                                <%-- BRANCH STAFF --%>
                                <div>
                                    <input type="radio" name="role" value="BRANCH_STAFF" id="roleStaff"
                                           class="role-picker-input"
                                           ${(!isAdd and user.role == 'BRANCH_STAFF') ? 'checked' : (param.role == 'BRANCH_STAFF' ? 'checked' : '')}>
                                    <label for="roleStaff" class="role-picker-card">
                                        <div class="role-icon" style="background:#FFF7ED;color:#EA580C;">
                                            <i class="bi bi-person-badge"></i>
                                        </div>
                                        <div class="role-name">Branch Staff</div>
                                        <div class="role-desc">Staff member at a cinema branch</div>
                                    </label>
                                </div>

                                <%-- ADMIN --%>
                                <div>
                                    <input type="radio" name="role" value="ADMIN" id="roleAdmin"
                                           class="role-picker-input"
                                           ${(!isAdd and user.role == 'ADMIN') ? 'checked' : (param.role == 'ADMIN' ? 'checked' : '')}>
                                    <label for="roleAdmin" class="role-picker-card">
                                        <div class="role-icon" style="background:#FEF2F2;color:#DC2626;">
                                            <i class="bi bi-shield-fill"></i>
                                        </div>
                                        <div class="role-name">Admin</div>
                                        <div class="role-desc">Full system-wide access</div>
                                    </label>
                                </div>

                            </div>

                            <%-- Assigned Cinema — only for Manager / Staff --%>
                            <div id="branchSection">
                                <hr class="lc-divider">
                                <label class="lc-label" for="branchId">
                                    Assigned Cinema <span class="text-danger">*</span>
                                </label>
                                <select id="branchId" name="branchId" class="lc-input">
                                    <option value="">— Select a cinema —</option>
                                    <c:forEach items="${branches}" var="b">
                                        <option value="${b.branchId}"
                                            ${(!isAdd and user.branchId == b.branchId) ? 'selected' : (param.branchId == b.branchId ? 'selected' : '')}>
                                            ${b.name}<c:if test="${not empty b.city}">, ${b.city}</c:if>
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="mt-1" style="font-size:.75rem;color:var(--lc-muted);">
                                    Only Admin can assign or reassign a cinema to this user.
                                </div>
                            </div>

                        </div>
                    </div>

                    <%-- Action buttons --%>
                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/admin/users" class="lc-btn lc-btn-ghost">
                            <i class="bi bi-x-lg"></i> Cancel
                        </a>
                        <button type="submit" class="lc-btn lc-btn-primary">
                            <i class="bi bi-check-lg"></i>
                            <c:choose>
                                <c:when test="${isAdd}">Create User</c:when>
                                <c:otherwise>Save Changes</c:otherwise>
                            </c:choose>
                        </button>
                    </div>

                </div><%-- /col right --%>
            </div><%-- /row --%>
        </form>

    </div><%-- /container --%>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /* ── Branch section visibility ──────────────────────── */
    const BRANCH_ROLES = ['BRANCH_MANAGER', 'BRANCH_STAFF'];
    const branchSection = document.getElementById('branchSection');
    const branchSelect  = document.getElementById('branchId');

    function updateBranchVisibility() {
        const selected = document.querySelector('input[name="role"]:checked');
        const needsBranch = selected && BRANCH_ROLES.includes(selected.value);
        branchSection.classList.toggle('show', needsBranch);
        branchSelect.required = needsBranch;
    }

    document.querySelectorAll('input[name="role"]').forEach(radio => {
        radio.addEventListener('change', updateBranchVisibility);
    });

    // Run on page load
    updateBranchVisibility();

    /* ── Avatar colour update on role change ─────────────── */
    const ROLE_COLORS = {
        'CUSTOMER':       '#2563EB',
        'BRANCH_MANAGER': '#7C3AED',
        'BRANCH_STAFF':   '#D97706',
        'ADMIN':          '#DC2626'
    };
    const avatarEl = document.getElementById('avatarEl');

    document.querySelectorAll('input[name="role"]').forEach(radio => {
        radio.addEventListener('change', function () {
            if (avatarEl) {
                avatarEl.style.background = ROLE_COLORS[this.value] || '#2563EB';
            }
        });
    });

    /* ── Client-side validation before submit ────────────── */
    document.getElementById('mainForm').addEventListener('submit', function (e) {
        const role = document.querySelector('input[name="role"]:checked');
        if (!role) {
            e.preventDefault();
            alert('Please select a role for this user.');
            return;
        }
        if (BRANCH_ROLES.includes(role.value) && !branchSelect.value) {
            e.preventDefault();
            alert('Please select an assigned cinema for Manager / Staff roles.');
            branchSelect.focus();
        }
    });
</script>
</body>
</html>
