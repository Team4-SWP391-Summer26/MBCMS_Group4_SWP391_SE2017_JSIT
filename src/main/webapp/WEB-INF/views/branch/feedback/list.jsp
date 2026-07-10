<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Customer Feedback &ndash; Branch Console</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="lc-console">

    <%-- Sidebar --%>
    <c:choose>
        <c:when test="${isStaff}">
            <jsp:include page="/WEB-INF/views/branch/_sidebar_staff.jsp">
                <jsp:param name="active" value="feedbacks"/>
            </jsp:include>
        </c:when>
        <c:otherwise>
            <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
                <jsp:param name="active" value="feedbacks"/>
            </jsp:include>
        </c:otherwise>
    </c:choose>

    <%-- Main --%>
    <main class="lc-admin-main">
        <div class="container-fluid px-4 py-4" style="max-width: 1240px;">

            <%-- Page header --%>
            <div class="mb-4">
                <div class="text-muted small mb-1">Dashboard / Feedback</div>
                <h4 class="text-navy fw-bold mb-0">Customer Feedback</h4>
                <p class="text-muted small mb-0">Branch: ${sessionScope.currentBranchName}</p>
            </div>

            <%-- Flash messages --%>
            <c:if test="${param.success == 'updated'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i>Feedback status updated successfully.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            </c:if>
            <c:if test="${param.error != null && param.error != ''}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${fn:escapeXml(param.error)}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            </c:if>

            <div class="card border-0 shadow-sm p-4" style="border-radius: 14px;">
                <%-- Include shared fragment --%>
                <%@ include file="/WEB-INF/views/common/_feedback-table.jspf" %>
            </div>

        </div>
    </main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
