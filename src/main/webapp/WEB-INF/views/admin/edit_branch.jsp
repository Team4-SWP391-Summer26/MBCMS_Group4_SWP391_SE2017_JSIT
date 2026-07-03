<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit Cinema – PentaPlex</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="branches"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-form-actions">
            <div>
                <div class="lc-page-crumb">
                    <a href="${pageContext.request.contextPath}/admin/branches" class="text-decoration-none text-muted">Admin / Cinemas</a>
                    / <strong>Edit</strong>
                </div>
                <h1 class="lc-page-title mb-0">Edit Cinema</h1>
            </div>
            <div class="lc-form-actions-end">
                <a href="${pageContext.request.contextPath}/admin/branches" class="lc-back-link">
                    <i class="bi bi-arrow-left"></i> Back to cinemas</a>
                <button type="submit" form="editBranchForm" class="st-toolbar-add border-0">
                    <i class="bi bi-check-lg" aria-hidden="true"></i> Save Changes</button>
            </div>
        </div>

        <form method="post" id="editBranchForm" action="${pageContext.request.contextPath}/admin/branches">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="branchId" value="${branch.branchId}">

            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card lc-elev p-4 mb-4">
                        <h5 class="text-navy fw-bold mb-3">Cinema Information</h5>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="lc-form-label">Cinema name <span class="text-danger">*</span></label>
                                <input type="text" class="lc-form-control" name="name" value="${branch.name}" required>
                            </div>
                            <div class="col-md-6">
                                <label class="lc-form-label">City <span class="text-danger">*</span></label>
                                <input type="text" class="lc-form-control" name="city" value="${branch.city}" required>
                            </div>
                            <div class="col-12">
                                <label class="lc-form-label">Address <span class="text-danger">*</span></label>
                                <input type="text" class="lc-form-control" name="address" value="${branch.address}" required>
                            </div>
                            <div class="col-md-6">
                                <label class="lc-form-label">Phone</label>
                                <input type="text" class="lc-form-control" name="phone" value="${branch.phone}">
                            </div>
                            <div class="col-md-6">
                                <label class="lc-form-label">Email</label>
                                <input type="email" class="lc-form-control" name="email" value="${branch.email}">
                            </div>
                        </div>
                    </div>

                    <input type="hidden" name="openingTime" value="${branch.openingTime}">
                    <input type="hidden" name="closingTime" value="${branch.closingTime}">

                    <div class="card lc-elev p-4">
                        <h5 class="text-navy fw-bold mb-3">Cinema Status</h5>
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" name="active" role="switch"
                                   style="width:2.5rem;height:1.3rem;"
                                   <c:if test="${branch.active}">checked</c:if>>
                            <label class="form-check-label">Active cinema</label>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card lc-elev p-4 mb-4 text-center">
                        <h5 class="text-navy fw-bold mb-3">Location Preview</h5>
                        <div class="d-flex align-items-center justify-content-center rounded-3 text-muted"
                             style="height:300px;background:#f5f5f5;">
                            <div>
                                <i class="bi bi-geo-alt-fill fs-1"></i>
                                <p class="mb-0 mt-2">Map Preview</p>
                                <small>${branch.city}</small>
                            </div>
                        </div>
                    </div>

                    <div class="card lc-elev p-4 d-grid gap-2">
                        <a href="${pageContext.request.contextPath}/admin/halls?branchId=${branch.branchId}"
                           class="lc-btn-ghost justify-content-center">
                            <i class="bi bi-door-open"></i> View Rooms</a>
                    </div>
                </div>
            </div>
        </form>

    </div>
</main>

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
</body>
</html>
