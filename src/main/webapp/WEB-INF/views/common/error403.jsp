<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>403 - Access Denied | PentaPlex</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>
    <body class="bg-light">

        <jsp:include page="header.jsp" />

        <div class="container py-5 d-flex align-items-center justify-content-center lc-error-shell">
            <div class="card p-5 border-0 shadow-sm text-center lc-error-card">
                <div class="mb-4 d-inline-flex align-items-center justify-content-center rounded-circle lc-error-icon lc-error-icon-danger">
                    <i class="bi bi-lock"></i>
                </div>

                <h1 class="fw-bold mb-2 lc-error-code">403</h1>
                <h4 class="fw-bold mb-3 lc-error-title">Access denied</h4>
                <p class="text-secondary mb-4 lc-error-copy">
                    Sorry, you do not have permission to access this page or resource. Please check your account or return to the home page.
                </p>

                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary-lc fw-semibold d-inline-flex align-items-center justify-content-center gap-2 border-0 lc-error-action">
                    <i class="bi bi-house-door"></i>
                    Back to Home
                </a>
            </div>
        </div>

        <jsp:include page="footer.jsp" />
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
