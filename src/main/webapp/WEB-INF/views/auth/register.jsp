<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dang ky - MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body style="background:#0f0f1a; color:#f0f0f0;">
<div class="container py-5 d-flex justify-content-center">
    <div class="card p-4" style="width:480px;background:#1a1a2e;border:none;">
        <h5 class="text-white mb-3">Tao tai khoan moi</h5>

        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger py-2">${errorMsg}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/auth/register">
            <div class="mb-3">
                <label class="form-label text-muted">Ho va ten</label>
                <input type="text" name="fullName" class="form-control"
                       style="background:#0f0f1a;color:#fff;border-color:#333;"
                       value="${param.fullName}" required>
            </div>
            <div class="mb-3">
                <label class="form-label text-muted">Email</label>
                <input type="email" name="email" class="form-control"
                       style="background:#0f0f1a;color:#fff;border-color:#333;"
                       value="${param.email}" required>
            </div>
            <div class="mb-3">
                <label class="form-label text-muted">So dien thoai</label>
                <input type="tel" name="phone" class="form-control"
                       style="background:#0f0f1a;color:#fff;border-color:#333;"
                       value="${param.phone}" placeholder="0912345678">
            </div>
            <div class="mb-3">
                <label class="form-label text-muted">Mat khau</label>
                <input type="password" name="password" class="form-control"
                       style="background:#0f0f1a;color:#fff;border-color:#333;" required>
                <small class="text-muted">Toi thieu 8 ky tu, co chu hoa, chu thuong va so</small>
            </div>
            <div class="mb-4">
                <label class="form-label text-muted">Xac nhan mat khau</label>
                <input type="password" name="confirmPassword" class="form-control"
                       style="background:#0f0f1a;color:#fff;border-color:#333;" required>
            </div>
            <button type="submit" class="btn w-100 text-white"
                    style="background:#e94560;">Dang ky</button>
        </form>

        <p class="text-center text-muted mt-3 mb-0" style="font-size:0.9rem;">
            Da co tai khoan?
            <a href="${pageContext.request.contextPath}/auth/login" style="color:#e94560;">Dang nhap</a>
        </p>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
