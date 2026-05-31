<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>404 - Không tìm thấy trang | MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>
    <body class="bg-light">

        <jsp:include page="header.jsp" />

        <div class="container py-5 d-flex align-items-center justify-content-center" style="min-height: 60vh;">
            <div class="card p-5 border-0 shadow-sm text-center" style="max-width: 480px; border-radius: 16px; background: #ffffff;">
                <!-- Icon SVG -->
                <div class="mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #fffbeb; color: #f59e0b; margin: 0 auto;">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                    <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path>
                    <line x1="12" y1="17" x2="12.01" y2="17"></line>
                    </svg>
                </div>

                <h1 class="fw-bold mb-2" style="font-size: 3rem; color: #1e293b;">404</h1>
                <h4 class="fw-bold mb-3" style="color: #0f1e36;">Không tìm thấy trang</h4>
                <p class="text-secondary mb-4" style="font-size: 0.95rem; line-height: 1.6;">
                    Đường dẫn bạn yêu cầu không tồn tại, đã bị di chuyển hoặc tạm thời không khả dụng. Vui lòng quay lại trang chủ.
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
