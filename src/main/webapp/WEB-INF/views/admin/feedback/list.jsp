<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Feedback Management – Admin Console</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="lc-console">

    <%-- Sidebar --%>
    <jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
        <jsp:param name="active" value="feedbacks"/>
    </jsp:include>

    <%-- Main --%>
    <main class="lc-admin-main">
        <div class="container-fluid px-4 py-4" style="max-width:1080px;">

            <%-- Page header --%>
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h4 class="fw-bold mb-0 text-navy">Feedback Management</h4>
                    <p class="text-muted small mb-0">Track and manage customer complaints and support requests across all branches.</p>
                </div>
            </div>

            <%-- Flash messages --%>
            <c:if test="${not empty successMsg}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i>${fn:escapeXml(successMsg)}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            </c:if>
            <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${fn:escapeXml(errorMsg)}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            </c:if>

            <div class="card border-0 shadow-sm p-4" style="border-radius: 14px;">
                <%-- Set variables required by the shared fragment --%>
                <c:set var="baseUrl"   value="/admin/feedbacks"/>
                <c:set var="updateUrl" value="/admin/feedbacks"/>

                <%-- Include shared fragment --%>
                <%@ include file="/WEB-INF/views/common/_feedback-table.jspf" %>
            </div>

        </div>
    </main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
