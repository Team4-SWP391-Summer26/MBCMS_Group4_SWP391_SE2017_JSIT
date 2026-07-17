<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Sign In - PentaPlex</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/auth.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <%-- Auth form + brand panel: auth.css (galaxy panel giữ layout cũ, polish nhẹ) --%>
    </head>
    <body class="auth-page">

        <jsp:include page="../common/header.jsp"/>

        <div class="container py-5">
            <div class="row align-items-stretch justify-content-center g-4 auth-shell">
                <!-- Left Column: Login Form Card -->
                <div class="col-lg-6 d-flex">
                    <div class="auth-card auth-panel w-100">
                            <div class="auth-kicker-inline auth-reveal" style="--i:0">
                                <i class="bi bi-shield-check"></i> Secure sign-in
                            </div>
                            <h3 class="fw-bold mb-1 auth-title auth-reveal" style="--i:1">Welcome back.</h3>
                            <p class="auth-copy mb-4 auth-reveal" style="--i:2">Pick up your booking right where you left off.</p>

                            <c:if test="${not empty errorMsg}">
                                <div class="lc-alert is-error mb-3">${errorMsg}</div>
                            </c:if>
                            <c:if test="${not empty successMsg}">
                                <div class="lc-alert is-success mb-3">${successMsg}</div>
                            </c:if>
                            <%-- Google OAuth error codes tra ve qua query param --%>
                            <c:if test="${param.googleError == 'account_locked'}">
                                <div class="lc-alert is-error mb-3">
                                    Your account has been locked. Please contact support.
                                </div>
                            </c:if>
                            <c:if test="${param.googleError == 'server_error'}">
                                <div class="lc-alert is-error mb-3">
                                    Google sign-in is temporarily unavailable. Please try again or use your email and password.
                                </div>
                            </c:if>
                            <c:if test="${param.googleError == 'invalid_state'}">
                                <div class="lc-alert is-error mb-3">
                                    Security check failed. Please try signing in again.
                                </div>
                            </c:if>
                            <c:if test="${param.verified == 'true'}">
                                <div class="lc-alert is-success mb-3">Account verified successfully! Please sign in.</div>
                            </c:if>

                            <form method="post" action="${pageContext.request.contextPath}/auth/login" class="auth-reveal" style="--i:3">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <!-- Email/Username field -->
                                <div class="mb-3">
                                    <label class="form-label auth-label">Email Address</label>
                                    <div class="position-relative">
                                        <span class="auth-input-icon">
                                            <i class="bi bi-envelope"></i>
                                        </span>
                                        <input type="text" name="email" class="form-control auth-input"
                                               placeholder="you@example.com" value="${param.email}" required>
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}" />
                                    </div>
                                </div>

                                <!-- Password field -->
                                <div class="mb-3">
                                    <label class="form-label auth-label">Password</label>
                                    <div class="position-relative">
                                        <span class="auth-input-icon">
                                            <i class="bi bi-lock"></i>
                                        </span>
                                        <input type="password" id="loginPassword" name="password" class="form-control auth-input has-action"
                                               placeholder="Enter your password" required>
                                        <button type="button" class="auth-input-action" onclick="togglePasswordVisibility('loginPassword')" aria-label="Show or hide password">
                                            <i id="eyeIcon" class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <!-- Remember me and Forgot password -->
                                <div class="d-flex justify-content-between align-items-center mb-4 auth-meta-row">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="rememberMe" name="rememberMe" value="true">
                                        <label class="form-check-label text-secondary" for="rememberMe">
                                            Remember me (7-day session)
                                        </label>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="auth-link">Forgot Password?</a>
                                </div>

                                <!-- Sign In Button -->
                                <button type="submit" class="btn btn-primary w-100 mb-3 d-flex align-items-center justify-content-center gap-2 auth-submit" data-auth-submit>
                                    <span class="auth-spinner" aria-hidden="true"></span>
                                    <span class="auth-submit-label">Sign In</span>
                                </button>
                            </form>

                            <!-- Divider -->
                            <div class="auth-divider auth-reveal" style="--i:4">
                                <span>or continue with</span>
                            </div>

                            <!-- Google Button -->
                            <a href="${pageContext.request.contextPath}/auth/google/login"
                               class="btn w-100 border d-flex align-items-center justify-content-center gap-2 auth-google auth-reveal" style="--i:5">
                                <svg width="18" height="18" viewBox="0 0 24 24">
                                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22c-.62-.62-1.01-1.38-1.18-2.21z"/>
                                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                                </svg>
                                Sign in with Google
                            </a>

                            <p class="auth-switch-link auth-reveal" style="--i:6">
                                <span class="text-secondary">New to PentaPlex?</span>
                                <a href="${pageContext.request.contextPath}/auth/register" class="auth-link">Create an account</a>
                            </p>
                    </div>
                </div>

                <!-- Right Column: Branding Welcome Card -->
                <div class="col-lg-6 d-none d-lg-flex">
                    <div class="branding-card w-100">
                        <div class="star star-auth-1"></div>
                        <div class="star star-auth-2"></div>
                        <div class="star star-auth-3"></div>
                        <div class="star star-auth-4"></div>
                        <div class="star star-auth-5"></div>
                        <div class="star star-auth-6"></div>
                        <div class="star star-auth-7"></div>
                        <div class="star star-auth-8"></div>

                        <div class="galaxy-glow"></div>
                        <div class="galaxy-circle"></div>
                        <div class="galaxy-core"></div>
                        <div class="galaxy-core-dark"></div>

                        <div class="auth-brand-content auth-brand-reveal" style="--i:0">
                            <div class="auth-kicker">
                                <i class="bi bi-film"></i> Welcome
                            </div>
                            <h1 class="fw-bold auth-brand-title">
                                Your Cinema,<br>Your Experience.
                            </h1>
                            <p class="auth-brand-copy">
                                Book tickets across PentaPlex cinemas, choose your seats, and earn points on every visit.
                            </p>
                        </div>

                        <div class="auth-brand-proof auth-brand-reveal" style="--i:1">
                            <div class="auth-avatar-stack">
                                <span class="avatar-circle">NH</span>
                                <span class="avatar-circle">TL</span>
                                <span class="avatar-circle">LN</span>
                                <span class="avatar-circle">PH</span>
                            </div>
                            <div class="auth-proof-copy">
                                <strong>3,400+ customers</strong>
                                <span>across HCMC &amp; Hanoi</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="../common/footer.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                            function togglePasswordVisibility(fieldId) {
                                                var passwordField = document.getElementById(fieldId);
                                                var eyeIcon = document.getElementById('eyeIcon');
                                                if (passwordField.type === "password") {
                                                    passwordField.type = "text";
                                                    eyeIcon.style.opacity = "0.5";
                                                } else {
                                                    passwordField.type = "password";
                                                    eyeIcon.style.opacity = "1";
                                                }
                                            }

                                            (function () {
                                                document.querySelectorAll('[data-auth-submit]').forEach(function (btn) {
                                                    var form = btn.closest('form');
                                                    if (!form) return;
                                                    form.addEventListener('submit', function (e) {
                                                        if (e.defaultPrevented) return;
                                                        btn.classList.add('is-loading');
                                                        var label = btn.querySelector('.auth-submit-label');
                                                        if (label) label.textContent = 'Signing in...';
                                                    });
                                                });
                                            })();
        </script>
    </body>
</html>
