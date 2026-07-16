<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>System Reports - PentaPlex Admin</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
</head>
<body class="lc-console">

    <jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
        <jsp:param name="active" value="reports" />
    </jsp:include>

    <main class="lc-admin-main">
        <div class="lc-page">
            <div class="lc-page-head">
                <div>
                    <div class="lc-page-crumb">System</div>
                    <h1 class="lc-page-title">Reports</h1>
                </div>
            </div>

            <c:set var="isAdmin" value="true" scope="request" />

            <c:choose>
                <c:when test="${activeTab == 'dashboard'}">
                    <!-- New Dashboard Layout -->
                    <%@ include file="/WEB-INF/views/common/_report-dashboard.jspf" %>
                </c:when>
                <c:otherwise>
                    <!-- Legacy Tabbed Layout -->
                    <%@ include file="/WEB-INF/views/common/_report-tabs.jspf" %>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger">${errorMessage}</div>
                    </c:if>

                    <!-- Filter Bar -->
                    <div class="card lc-elev p-3 mb-4">
                        <form action="" method="get" class="row g-3 align-items-end">
                            <input type="hidden" name="tab" value="${activeTab}">
                            <c:if test="${activeTab != 'revenue'}">
                                <div class="col-md-3">
                                    <label class="form-label text-muted small mb-1">Branch ID</label>
                                    <input type="number" class="form-control form-control-sm" name="branchId" value="${param.branchId}" placeholder="All Branches">
                                </div>
                            </c:if>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-1">From Date</label>
                                <input type="date" class="form-control form-control-sm" name="from" value="${param.from}">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-1">To Date</label>
                                <input type="date" class="form-control form-control-sm" name="to" value="${param.to}">
                            </div>
                            <div class="col-md-3">
                                <button type="submit" class="btn btn-sm btn-primary px-3 me-2">Apply Filter</button>
                                <a href="reports/export?tab=${activeTab}&from=${param.from}&to=${param.to}${param.branchId != null ? '&branchId='.concat(param.branchId) : ''}" class="btn btn-sm btn-outline-secondary">
                                    <i class="bi bi-download"></i> Export CSV
                                </a>
                            </div>
                        </form>
                    </div>

                    <!-- Content Area -->
                    <div class="card lc-elev p-4">
                        <%@ include file="/WEB-INF/views/common/_report-charts.jspf" %>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
    <script src="${pageContext.request.contextPath}/assets/js/chart.min.js"></script>
    <script>
        // Chart rendering logic is inside _report-charts.jspf
    </script>
</body>
</html>
