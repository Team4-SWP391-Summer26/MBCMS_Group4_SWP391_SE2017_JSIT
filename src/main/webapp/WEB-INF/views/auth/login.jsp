<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dang nhap - MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body style="background:#0f0f1a; color:#f0f0f0;">
<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
    <div class="card p-4" style="width:400px;background:#1a1a2e;border:none;">
        <h4 class="text-center text-white mb-4">
            <span style="color:#e94560;">&#9670;</span> MBCMS
        </h4>
        <h5 class="text-white mb-3">Dang nhap</h5>

        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger py-2">${errorMsg}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/auth/login">
            <div class="mb-3">
                <label class="form-label text-muted">Tai khoan (username)</label>
                <input type="text" name="username" class="form-control"
                       style="background:#0f0f1a;color:#fff;border-color:#333;"
                       value="${param.username}" required>
            </div>
            <div class="mb-3">
                <label class="form-label text-muted">Mat khau</label>
                <input type="password" name="password" class="form-control"
                       style="background:#0f0f1a;color:#fff;border-color:#333;" required>
            </div>
            <button type="submit" class="btn w-100 text-white"
                    style="background:#e94560;">Dang nhap</button>
        </form>

        <div class="text-center mt-3">
            <a href="${pageContext.request.contextPath}/auth/forgot-password"
               class="text-muted text-decoration-none" style="font-size:0.85rem;">Quen mat khau?</a>
        </div>
        <hr style="border-color:#333;">
        <p class="text-center text-muted mb-0" style="font-size:0.9rem;">
            Chua co tai khoan?
            <a href="${pageContext.request.contextPath}/auth/register"
               style="color:#e94560;">Dang ky ngay</a>
        </p>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
