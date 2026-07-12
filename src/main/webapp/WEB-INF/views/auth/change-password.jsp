<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Change Password - PentaPlex</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>

    <body class="bg-light">
        <jsp:include page="../common/header.jsp"/>

        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-md-7 col-lg-5">
                    <div class="auth-card p-4 p-md-5">
                        <div class="text-center mb-4">
                            <div class="auth-icon-tile mb-3">
                                <i class="bi bi-shield-lock"></i>
                            </div>
                            <h3 class="fw-bold mb-1 auth-title">Change Password</h3>
                            <p class="auth-copy mb-0">
                                Enter your current password and choose a new one.
                            </p>
                        </div>

                        <c:if test="${not empty errorMsg}">
                            <div class="lc-alert is-error mb-3">
                                <i class="bi bi-exclamation-circle"></i> <span>${errorMsg}</span>
                            </div>
                        </c:if>
                        <c:if test="${not empty successMsg}">
                            <div class="lc-alert is-success mb-3">
                                <i class="bi bi-check-circle"></i> <span>${successMsg}</span>
                            </div>
                        </c:if>

                        <form method="post" action="${pageContext.request.contextPath}/auth/change-password">
                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <div class="mb-3">
                                <label class="form-label auth-label">Current Password</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white"><i class="bi bi-key text-muted"></i></span>
                                    <input type="password" name="oldPassword" class="form-control"
                                           placeholder="Enter your current password" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label auth-label">New Password</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white"><i class="bi bi-lock text-muted"></i></span>
                                    <input type="password" name="newPassword" class="form-control"
                                           placeholder="Enter your new password" minlength="6" maxlength="64" required>
                                </div>
                                <small class="auth-help-text">Your new password must be at least 6 characters.</small>
                            </div>

                            <div class="mb-4">
                                <label class="form-label auth-label">Confirm New Password</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white"><i class="bi bi-lock-fill text-muted"></i></span>
                                    <input type="password" name="confirmPassword" class="form-control"
                                           placeholder="Re-enter your new password" minlength="6" maxlength="64" required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">
                                <i class="bi bi-shield-check me-1"></i> Change Password
                            </button>

                            <a href="${pageContext.request.contextPath}/home"
                               class="btn btn-link w-100 mt-2 text-decoration-none">
                                Back to Home
                            </a>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
