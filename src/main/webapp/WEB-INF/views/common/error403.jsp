<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>403 - Truy cập bị từ chối | MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>
    <body class="bg-light">

        <jsp:include page="header.jsp" />

        <div class="container py-5 d-flex align-items-center justify-content-center" style="min-height: 60vh;">
            <div class="card p-5 border-0 shadow-sm text-center" style="max-width: 480px; border-radius: 16px; background: #ffffff;">
                <!-- Icon SVG -->
                <div class="mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #fef2f2; color: #ef4444; margin: 0 auto;">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                </div>

                <h1 class="fw-bold mb-2" style="font-size: 3rem; color: #1e293b;">403</h1>
                <h4 class="fw-bold mb-3" style="color: #0f1e36;">Truy cập bị từ chối</h4>
                <p class="text-secondary mb-4" style="font-size: 0.95rem; line-height: 1.6;">
                    Xin lỗi, bạn không có quyền truy cập vào tài nguyên hoặc trang này. Vui lòng kiểm tra lại tài khoản hoặc quay lại trang chủ.
                </p>

                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary-lc fw-semibold d-inline-flex align-items-center justify-content-center gap-2 border-0" 
                   style="height: 44px; border-radius: 8px; padding: 0.5rem 1.5rem; font-size: 0.95rem;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                    <polyline points="9 22 9 12 15 12 15 22"></polyline>
                    </svg>
                    Quay lại trang chủ
                </a>
            </div>
        </div>

        <jsp:include page="footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
