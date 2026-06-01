<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Doi mat khau - MBCMS</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>

    <body class="bg-light">
        <jsp:include page="../common/header.jsp"/>

        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-md-6 col-lg-5">
                    <div class="card border-0 shadow-sm p-4" style="border-radius: 16px;">
                        <h3 class="fw-bold text-center mb-2" style="color: #0F1E36;">Doi mat khau</h3>

                        <p class="text-muted text-center mb-4" style="font-size: 0.9rem;">
                            Nhap mat khau cu va mat khau moi cua ban
                        </p>

                        <c:if test="${not empty errorMsg}">
                            <div class="alert alert-danger py-2" style="font-size: 0.9rem;">
                                ${errorMsg}
                            </div>
                        </c:if>

                        <c:if test="${not empty successMsg}">
                            <div class="alert alert-success py-2" style="font-size: 0.9rem;">
                                ${successMsg}
                            </div>
                        </c:if>

                        <form method="post" action="${pageContext.request.contextPath}/auth/change-password">
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Mat khau cu</label>
                                <input type="password"
                                       name="oldPassword"
                                       class="form-control"
                                       placeholder="Nhap mat khau cu"
                                       required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Mat khau moi</label>
                                <input type="password"
                                       name="newPassword"
                                       class="form-control"
                                       placeholder="Nhap mat khau moi"
                                       minlength="6"
                                       required>

                                <small class="text-muted">
                                    Mat khau moi phai co it nhat 6 ky tu.
                                </small>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-semibold">Xac nhan mat khau moi</label>
                                <input type="password"
                                       name="confirmPassword"
                                       class="form-control"
                                       placeholder="Nhap lai mat khau moi"
                                       minlength="6"
                                       required>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 py-2">
                                Doi mat khau
                            </button>

                            <a href="${pageContext.request.contextPath}/home"
                               class="btn btn-link w-100 mt-2 text-decoration-none">
                                Quay lai trang chu
                            </a>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>