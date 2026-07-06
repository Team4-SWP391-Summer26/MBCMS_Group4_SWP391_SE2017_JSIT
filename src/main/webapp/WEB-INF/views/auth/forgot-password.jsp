<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Forgot Password - PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/auth.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="auth-page">

<jsp:include page="../common/header.jsp"/>

<c:set var="currentStep" value="${empty param.step ? (empty step ? 'email' : step) : (param.step)}"/>
<c:set var="recoveryEmail" value="${param.email != null ? param.email : email}"/>
<c:set var="recoveryCode" value="${param.code != null ? param.code : code}"/>

<main class="container py-5">
    <div class="row align-items-stretch justify-content-center g-4 auth-shell">
        <div class="col-lg-6 d-flex">
            <div class="auth-card auth-panel auth-form-card w-100">
                <div>
                    <div class="auth-stepper">
                        <div class="auth-step ${currentStep == 'email' ? 'is-active' : 'is-done'}">
                            <span class="step-circle">
                                <c:choose>
                                    <c:when test="${currentStep == 'verify' || currentStep == 'reset'}"><i class="bi bi-check-lg"></i></c:when>
                                    <c:otherwise>1</c:otherwise>
                                </c:choose>
                            </span>
                            <span>
                                <span class="d-block fw-bold auth-step-title">Enter Email</span>
                                <span class="auth-step-label">Step 1</span>
                            </span>
                        </div>
                        <span class="auth-step-divider">-</span>
                        <div class="auth-step ${currentStep == 'verify' ? 'is-active' : (currentStep == 'reset' ? 'is-done' : '')}">
                            <span class="step-circle">
                                <c:choose>
                                    <c:when test="${currentStep == 'reset'}"><i class="bi bi-check-lg"></i></c:when>
                                    <c:otherwise>2</c:otherwise>
                                </c:choose>
                            </span>
                            <span>
                                <span class="d-block fw-bold auth-step-title">Verify Code</span>
                                <span class="auth-step-label">Step 2</span>
                            </span>
                        </div>
                        <span class="auth-step-divider">-</span>
                        <div class="auth-step ${currentStep == 'reset' ? 'is-active' : ''}">
                            <span class="step-circle">3</span>
                            <span>
                                <span class="d-block fw-bold auth-step-title">New Password</span>
                                <span class="auth-step-label">Step 3</span>
                            </span>
                        </div>
                    </div>

                    <c:if test="${not empty errorMsg}">
                        <div class="lc-alert is-error py-2 mb-4">${errorMsg}</div>
                    </c:if>
                    <c:if test="${not empty successMsg}">
                        <div class="lc-alert is-success py-2 mb-4">${successMsg}</div>
                    </c:if>

                    <c:if test="${currentStep == 'email'}">
                        <h3 class="fw-bold mb-1 auth-title">Forgot your password?</h3>
                        <p class="auth-copy mb-4">
                            Enter your registered email and we will send you a 6-digit verification code.
                        </p>

                        <form method="post" action="${pageContext.request.contextPath}/auth/forgot-password">
                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <input type="hidden" name="action" value="send-code">

                            <div class="mb-4">
                                <label class="form-label auth-label">Email Address</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-envelope"></i></span>
                                    <input type="email" name="email" class="form-control auth-input"
                                           placeholder="you@example.com" value="${param.email}" required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 mb-4 d-flex align-items-center justify-content-center gap-2 auth-submit">
                                Send Verification Code <i class="bi bi-arrow-right"></i>
                            </button>
                        </form>
                    </c:if>

                    <c:if test="${currentStep == 'verify'}">
                        <h3 class="fw-bold mb-1 auth-title">Verify Code</h3>
                        <p class="auth-copy mb-4">
                            Enter the 6-digit code sent to <strong>${recoveryEmail}</strong>.
                        </p>

                        <form method="post" action="${pageContext.request.contextPath}/auth/forgot-password">
                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <input type="hidden" name="action" value="verify-code">
                            <input type="hidden" name="email" value="${recoveryEmail}">

                            <div class="mb-4">
                                <label class="form-label auth-label">Verification Code</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-shield-lock"></i></span>
                                    <input type="text" name="code" class="form-control auth-input is-code"
                                           maxlength="6" pattern="\d{6}" placeholder="123456" required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 mb-4 d-flex align-items-center justify-content-center gap-2 auth-submit">
                                Verify Code <i class="bi bi-arrow-right"></i>
                            </button>
                        </form>
                    </c:if>

                    <c:if test="${currentStep == 'reset'}">
                        <h3 class="fw-bold mb-1 auth-title">New Password</h3>
                        <p class="auth-copy mb-4">
                            Set a strong password to secure your account and return to booking.
                        </p>

                        <form id="resetPasswordForm" method="post" action="${pageContext.request.contextPath}/auth/forgot-password">
                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <input type="hidden" name="action" value="reset-password">
                            <input type="hidden" name="email" value="${recoveryEmail}">
                            <input type="hidden" name="code" value="${recoveryCode}">

                            <div class="mb-3">
                                <label class="form-label auth-label">New Password</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-shield-lock"></i></span>
                                    <input type="password" id="password" name="password"
                                           class="form-control auth-input has-action"
                                           placeholder="At least 8 characters" required>
                                    <button type="button" id="togglePassword" class="auth-input-action"
                                            aria-label="Show or hide password">
                                        <i class="bi bi-eye" id="eyeIcon"></i>
                                    </button>
                                </div>
                                <small class="auth-field-note">8-64 chars, at least 1 uppercase and 1 digit.</small>
                                <div class="auth-strength">
                                    <div id="strength-bar-1" class="auth-strength-bar"></div>
                                    <div id="strength-bar-2" class="auth-strength-bar"></div>
                                    <div id="strength-bar-3" class="auth-strength-bar"></div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label auth-label">Confirm Password</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-check2-shield"></i></span>
                                    <input type="password" id="confirmPassword" name="confirmPassword"
                                           class="form-control auth-input"
                                           placeholder="Re-enter password" required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 mb-4 d-flex align-items-center justify-content-center gap-2 auth-submit">
                                Reset Password <i class="bi bi-arrow-right"></i>
                            </button>
                        </form>
                    </c:if>
                </div>

                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/auth/login" class="auth-back-link">
                        <i class="bi bi-arrow-left"></i> Back to Sign In
                    </a>
                </div>
            </div>
        </div>

        <div class="col-lg-6 d-none d-lg-flex">
            <div class="branding-card w-100">
                <div class="galaxy-glow"></div>
                <div class="galaxy-circle"></div>
                <div class="galaxy-core"></div>
                <div class="galaxy-core-dark"></div>
                <div class="auth-watermark">SECURE</div>

                <div class="auth-brand-content">
                    <div class="auth-kicker">
                        <i class="bi bi-shield-check"></i> SECURE PASSWORD RESET
                    </div>
                    <h1 class="fw-bold mb-3 auth-brand-title">
                        Back to the movies in 3 quick steps.
                    </h1>
                    <p class="auth-brand-copy mb-0">
                        We email a one-time code. Once verified, set a new password and continue booking.
                    </p>

                    <div class="auth-feature-list">
                        <div class="auth-feature"><i class="bi bi-check-lg"></i><span>Codes expire after a short verification window.</span></div>
                        <div class="auth-feature"><i class="bi bi-check-lg"></i><span>Bookings and loyalty points stay intact.</span></div>
                        <div class="auth-feature"><i class="bi bi-check-lg"></i><span>All recovery requests keep the existing CSRF flow.</span></div>
                    </div>
                </div>

                <div class="auth-brand-proof">
                    <div class="auth-avatar-stack">
                        <span class="avatar-circle">NH</span>
                        <span class="avatar-circle">TL</span>
                        <span class="avatar-circle">LN</span>
                        <span class="avatar-circle">PH</span>
                    </div>
                    <div class="auth-proof-copy">
                        <strong>3,400+ customers</strong><br>across HCMC and Hanoi
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        // Enforce DOM references for input fields and UI indicators
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirmPassword');
        const toggleBtn = document.getElementById('togglePassword');
        const eyeIcon = document.getElementById('eyeIcon');
        const resetPasswordForm = document.getElementById('resetPasswordForm');
        
        // Array mapping to password strength indicator bars
        const bars = [
            document.getElementById('strength-bar-1'),
            document.getElementById('strength-bar-2'),
            document.getElementById('strength-bar-3')
        ];

        /**
         * [Flow Step: JavaScript] Evaluates password complexity matching UC11 rules
         * - Rule 1: Length must be between 8 and 64 characters
         * - Rule 2: Must contain at least one uppercase letter
         * - Rule 3: Must contain at least one numeric digit
         */
        function passwordScore(value) {
            let score = 0;
            if (value.length > 0 && value.length >= 8 && value.length <= 64) score++;
            if (/[A-Z]/.test(value)) score++;
            if (/[0-9]/.test(value)) score++;
            return score;
        }

        /**
         * [Flow Step: JavaScript] Updates strength indicator colors dynamically based on passwordScore
         */
        function setStrength(score) {
            bars.forEach(function (bar) {
                if (!bar) return;
                bar.classList.remove('is-weak', 'is-medium', 'is-strong');
            });
            if (!bars[0]) return;
            if (score === 1) {
                bars[0].classList.add('is-weak'); // Weak indicator: Red
            } else if (score === 2) {
                bars[0].classList.add('is-medium'); // Medium indicator: Yellow
                bars[1].classList.add('is-medium');
            } else if (score === 3) {
                bars.forEach(function (bar) { bar.classList.add('is-strong'); }); // Strong indicator: Green
            }
        }

        // Toggle cleartext visibility in password field
        if (toggleBtn && passwordInput) {
            toggleBtn.addEventListener('click', function () {
                const show = passwordInput.type === 'password';
                passwordInput.type = show ? 'text' : 'password';
                eyeIcon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
            });
        }

        // Bind input event to update strength bars dynamically
        if (passwordInput) {
            passwordInput.addEventListener('input', function () {
                setStrength(passwordScore(passwordInput.value));
            });
        }

        // [Flow Step: JavaScript] Prevent form submit if passwords do not match or fail regex conditions
        if (resetPasswordForm) {
            resetPasswordForm.addEventListener('submit', function (e) {
                const password = passwordInput.value;
                if (passwordScore(password) < 3) {
                    e.preventDefault();
                    lcAlert('Password must be 8-64 characters and contain at least 1 uppercase letter and 1 digit.');
                    return false;
                }
                if (password !== confirmPasswordInput.value) {
                    e.preventDefault();
                    lcAlert('Passwords do not match.');
                    return false;
                }
            });
        }
    });
</script>
</body>
</html>
