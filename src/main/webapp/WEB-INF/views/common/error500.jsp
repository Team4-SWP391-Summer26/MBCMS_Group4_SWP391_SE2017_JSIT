<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>500 - Lỗi hệ thống | MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>
    <body class="bg-light">

        <jsp:include page="header.jsp" />

        <div class="container py-5 d-flex align-items-center justify-content-center" style="min-height: 60vh;">
            <div class="card p-5 border-0 shadow-sm text-center" style="max-width: 480px; border-radius: 16px; background: #ffffff;">
                <!-- Icon SVG -->
                <div class="mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #eff6ff; color: #2563eb; margin: 0 auto;">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="3"></circle>
                    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
                    </svg>
                </div>

                <h1 class="fw-bold mb-2" style="font-size: 3rem; color: #1e293b;">500</h1>
                <h4 class="fw-bold mb-3" style="color: #0f1e36;">Lỗi máy chủ nội bộ</h4>
                <p class="text-secondary mb-4" style="font-size: 0.95rem; line-height: 1.6;">
                    Hệ thống đang gặp sự cố kỹ thuật tạm thời. Đội ngũ phát triển của chúng tôi đang tiến hành khắc phục. Vui lòng quay lại sau.
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
