<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cinema Management – PentaPlex</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="branches"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Admin / <strong>Cinemas</strong></div>
                <h1 class="lc-page-title">Cinema Management</h1>
                <p class="text-muted small mb-0 mt-1">Manage cinemas, their rooms and operating hours across the network.</p>
            </div>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="lc-alert lc-alert-success alert-dismissible" role="alert">
                <i class="bi bi-check-circle-fill"></i>
                <span>${successMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="lc-alert lc-alert-danger alert-dismissible" role="alert">
                <i class="bi bi-exclamation-circle-fill"></i>
                <span>${errorMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>

        <c:set var="totalCount" value="${branches.size()}"/>
        <c:set var="activeCount" value="0"/>
        <c:forEach items="${branches}" var="b">
            <c:if test="${b.active}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
        </c:forEach>

        <div class="lc-kpi-row lc-kpi-row--3 mb-4">
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-building-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Total cinemas</div>
                    <div class="lc-kpi-value">${totalCount}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-check-circle-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Active</div>
                    <div class="lc-kpi-value">${activeCount}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-x-circle-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Inactive</div>
                    <div class="lc-kpi-value">${totalCount - activeCount}</div>
                </div>
            </div>
        </div>

        <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
            <div class="st-toolbar-track w-100">
                <div class="lc-toolbar-search">
                    <i class="bi bi-search" aria-hidden="true"></i>
                    <input type="search" id="searchInput" placeholder="Search cinemas..." aria-label="Search cinemas">
                </div>
                <div class="st-toolbar-vrule" aria-hidden="true"></div>
                <select id="cityFilter" class="st-toolbar-select" aria-label="Filter by city">
                    <option value="">All cities</option>
                    <c:set var="cities" value=""/>
                    <c:forEach items="${branches}" var="b">
                        <c:if test="${not empty b.city and not cities.contains(b.city)}">
                            <option value="${b.city}">${b.city}</option>
                            <c:set var="cities" value="${cities},${b.city}"/>
                        </c:if>
                    </c:forEach>
                </select>
                <div class="st-toolbar-vrule" aria-hidden="true"></div>
                <select id="statusFilter" class="st-toolbar-select" aria-label="Filter by status">
                    <option value="">All status</option>
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                </select>
                <div class="lc-toolbar-spacer" aria-hidden="true"></div>
                <button type="button" class="st-toolbar-add border-0" data-bs-toggle="modal" data-bs-target="#addModal">
                    <i class="bi bi-plus-lg" aria-hidden="true"></i> Add Cinema</button>
            </div>
        </div>

        <div class="row g-3" id="cardGrid">
            <c:forEach items="${branches}" var="b" varStatus="loop">
                <c:set var="bannerIdx" value="${loop.index % 4}"/>
                <c:choose>
                    <c:when test="${bannerIdx == 0}"><c:set var="bannerCls" value="banner-blue"/></c:when>
                    <c:when test="${bannerIdx == 1}"><c:set var="bannerCls" value="banner-green"/></c:when>
                    <c:when test="${bannerIdx == 2}"><c:set var="bannerCls" value="banner-purple"/></c:when>
                    <c:otherwise><c:set var="bannerCls" value="banner-gray"/></c:otherwise>
                </c:choose>
                <c:if test="${not b.active}"><c:set var="bannerCls" value="banner-gray"/></c:if>

                <div class="col-md-6 cinema-card-col"
                     data-name="${b.name}"
                     data-city="${b.city}"
                     data-status="${b.active ? 'active' : 'inactive'}">
                    <div class="lc-cinema-card h-100">
                        <div class="lc-cinema-banner ${bannerCls}">
                            <div class="lc-cinema-banner-pin"><i class="bi bi-geo-alt-fill"></i></div>
                            <c:choose>
                                <c:when test="${b.active}">
                                    <span class="lc-cinema-status status-active">
                                        <i class="bi bi-circle-fill" style="font-size:.4rem;"></i> Active</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="lc-cinema-status status-inactive">
                                        <i class="bi bi-circle" style="font-size:.4rem;"></i> Inactive</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="lc-cinema-body">
                            <div>
                                <p class="lc-cinema-name">${b.name}</p>
                                <p class="lc-cinema-addr">
                                    <i class="bi bi-geo-alt me-1"></i>${b.address}<c:if test="${not empty b.city}">, ${b.city}</c:if>
                                </p>
                            </div>
                            <div class="lc-cinema-meta">
                                <span><i class="bi bi-telephone me-1"></i>
                                    <c:choose><c:when test="${not empty b.phone}">${b.phone}</c:when><c:otherwise>—</c:otherwise></c:choose>
                                </span>
                                <span><i class="bi bi-envelope me-1"></i>
                                    <c:choose><c:when test="${not empty b.email}">${b.email}</c:when><c:otherwise>—</c:otherwise></c:choose>
                                </span>
                            </div>
                            <div class="lc-cinema-actions">
                                <button type="button" class="lc-btn-outline edit-btn"
                                        data-id="${b.branchId}" data-name="${b.name}"
                                        data-address="${b.address}" data-city="${b.city}"
                                        data-phone="${b.phone}" data-email="${b.email}"
                                        data-open="${b.openingTime}" data-close="${b.closingTime}"
                                        data-active="${b.active}"
                                        data-bs-toggle="modal" data-bs-target="#editModal">
                                    <i class="bi bi-pencil me-1"></i> Edit Details</button>
                                <a href="${pageContext.request.contextPath}/admin/halls?branchId=${b.branchId}" class="lc-btn-fill">
                                    <i class="bi bi-grid me-1"></i> Manage Rooms</a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty branches}">
                <div class="col-12">
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-building fs-1 d-block mb-2 opacity-50"></i>
                        No cinemas found.
                        <button class="btn btn-link p-0" data-bs-toggle="modal" data-bs-target="#addModal">Add one</button>.
                    </div>
                </div>
            </c:if>
        </div>

        <div id="noResults" class="text-center py-5 d-none text-muted">
            <i class="bi bi-search fs-1 d-block mb-2 opacity-50"></i>
            No cinemas match your search.
        </div>

    </div>
</main>

<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/branches">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-building-add me-2 text-primary"></i>Add New Cinema</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body px-4 py-3 d-flex flex-column gap-3">
                    <div>
                        <label class="lc-form-label">Cinema Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="lc-form-control" placeholder="e.g. Cinema Alpha" required>
                    </div>
                    <div>
                        <label class="lc-form-label">Address <span class="text-danger">*</span></label>
                        <input type="text" name="address" class="lc-form-control" placeholder="Street address" required>
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">City <span class="text-danger">*</span></label>
                            <input type="text" name="city" class="lc-form-control" placeholder="e.g. HCMC" required>
                        </div>
                        <div>
                            <label class="lc-form-label">Phone</label>
                            <input type="text" name="phone" class="lc-form-control" placeholder="028 xxxx xxxx">
                        </div>
                    </div>
                    <div>
                        <label class="lc-form-label">Email</label>
                        <input type="email" name="email" class="lc-form-control" placeholder="branch@example.com">
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">Opening Time</label>
                            <input type="time" name="openingTime" class="lc-form-control" value="08:00">
                        </div>
                        <div>
                            <label class="lc-form-label">Closing Time</label>
                            <input type="time" name="closingTime" class="lc-form-control" value="23:00">
                        </div>
                    </div>
                </div>
                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save">
                        <i class="bi bi-plus-lg me-1"></i> Add Cinema</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/branches">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="branchId" id="editId">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-pencil-square me-2 text-primary"></i>Edit Cinema</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body px-4 py-3 d-flex flex-column gap-3">
                    <div>
                        <label class="lc-form-label">Cinema Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" id="editName" class="lc-form-control" required>
                    </div>
                    <div>
                        <label class="lc-form-label">Address <span class="text-danger">*</span></label>
                        <input type="text" name="address" id="editAddress" class="lc-form-control" required>
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">City <span class="text-danger">*</span></label>
                            <input type="text" name="city" id="editCity" class="lc-form-control" required>
                        </div>
                        <div>
                            <label class="lc-form-label">Phone</label>
                            <input type="text" name="phone" id="editPhone" class="lc-form-control">
                        </div>
                    </div>
                    <div>
                        <label class="lc-form-label">Email</label>
                        <input type="email" name="email" id="editEmail" class="lc-form-control">
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">Opening Time</label>
                            <input type="time" name="openingTime" id="editOpen" class="lc-form-control">
                        </div>
                        <div>
                            <label class="lc-form-label">Closing Time</label>
                            <input type="time" name="closingTime" id="editClose" class="lc-form-control">
                        </div>
                    </div>
                    <input type="hidden" name="active" id="editActiveHidden" value="false">
                    <div class="d-flex align-items-center justify-content-between p-3"
                         style="background:var(--lc-light);border-radius:10px;border:1px solid var(--lc-border);">
                        <div>
                            <div style="font-size:.85rem;font-weight:600;color:var(--navy);">Cinema Status</div>
                            <div style="font-size:.75rem;color:var(--lc-muted);">Inactive cinemas are hidden from customer booking</div>
                        </div>
                        <div class="form-check form-switch mb-0">
                            <input class="form-check-input" type="checkbox" role="switch"
                                   id="editActiveToggle" style="width:2.5rem;height:1.3rem;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save" id="editSaveBtn">
                        <i class="bi bi-check-lg me-1"></i> Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<form id="toggleForm" method="post" action="${pageContext.request.contextPath}/admin/branches" class="d-none">
    <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
    <input type="hidden" name="action" value="toggleStatus">
    <input type="hidden" name="branchId" id="toggleBranchId">
    <input type="hidden" name="active" id="toggleActive">
</form>

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
<script>
    document.querySelectorAll('.edit-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            document.getElementById('editId').value      = this.dataset.id;
            document.getElementById('editName').value    = this.dataset.name;
            document.getElementById('editAddress').value = this.dataset.address;
            document.getElementById('editCity').value    = this.dataset.city;
            document.getElementById('editPhone').value   = this.dataset.phone || '';
            document.getElementById('editEmail').value   = this.dataset.email || '';
            document.getElementById('editOpen').value    = this.dataset.open  || '08:00';
            document.getElementById('editClose').value   = this.dataset.close || '23:00';
            const isActive = this.dataset.active === 'true';
            const toggle   = document.getElementById('editActiveToggle');
            const hidden   = document.getElementById('editActiveHidden');
            toggle.checked = isActive;
            hidden.value = isActive ? 'true' : 'false';
            toggle.onchange = function () { hidden.value = this.checked ? 'true' : 'false'; };
        });
    });
    document.getElementById('editSaveBtn').closest('form').addEventListener('submit', function () {
        const toggle = document.getElementById('editActiveToggle');
        document.getElementById('editActiveHidden').value = toggle.checked ? 'true' : 'false';
    });
    function filterCards() {
        const q      = document.getElementById('searchInput').value.toLowerCase();
        const city   = document.getElementById('cityFilter').value.toLowerCase();
        const status = document.getElementById('statusFilter').value;
        const cols   = document.querySelectorAll('.cinema-card-col');
        let   shown  = 0;
        cols.forEach(col => {
            const name   = (col.dataset.name   || '').toLowerCase();
            const cCity  = (col.dataset.city   || '').toLowerCase();
            const cStat  = (col.dataset.status || '');
            const matchQ      = !q      || name.includes(q) || cCity.includes(q);
            const matchCity   = !city   || cCity === city;
            const matchStatus = !status || cStat === status;
            const show = matchQ && matchCity && matchStatus;
            col.classList.toggle('d-none', !show);
            if (show) shown++;
        });
        document.getElementById('noResults').classList.toggle('d-none', shown > 0);
    }
    document.getElementById('searchInput').addEventListener('input',  filterCards);
    document.getElementById('cityFilter').addEventListener('change',  filterCards);
    document.getElementById('statusFilter').addEventListener('change', filterCards);
</script>
</body>
</html>
