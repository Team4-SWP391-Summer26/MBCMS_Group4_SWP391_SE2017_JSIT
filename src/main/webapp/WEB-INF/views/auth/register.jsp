<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Register - PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/auth.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="auth-page">

<jsp:include page="../common/header.jsp"/>

<main class="container py-5">
    <div class="row align-items-stretch justify-content-center g-4 auth-shell auth-shell-wide">
        <div class="col-lg-7 d-flex">
            <div class="auth-card auth-panel auth-form-card w-100">
                <div class="auth-kicker-inline auth-reveal" style="--i:0">
                    <i class="bi bi-person-plus"></i> Customer account
                </div>
                <h3 class="fw-bold mb-1 auth-title auth-reveal" style="--i:1">Create your account.</h3>
                <p class="auth-copy mb-4 auth-reveal" style="--i:2">Join PentaPlex and start booking in under a minute.</p>

                    <c:if test="${not empty errorMsg}">
                        <div class="lc-alert is-error py-2 mb-4">${errorMsg}</div>
                    </c:if>

                    <form id="registerForm" method="post" action="${pageContext.request.contextPath}/auth/register" class="auth-reveal" style="--i:3">
                        <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label auth-label">Username</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-person"></i></span>
                                    <input type="text" name="username" class="form-control auth-input"
                                           placeholder="e.g. moviefan24" value="${param.username}" required>
                                </div>
                                <small class="auth-field-note">4-50 characters, must be unique.</small>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label auth-label">Full Name</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-person-badge"></i></span>
                                    <input type="text" name="fullName" class="form-control auth-input"
                                           placeholder="e.g. John Smith" value="${param.fullName}" required>
                                </div>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label auth-label">Email Address</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-envelope"></i></span>
                                    <input type="email" name="email" class="form-control auth-input"
                                           placeholder="name@example.com" value="${param.email}" required>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label auth-label">Phone Number</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-telephone"></i></span>
                                    <input type="tel" name="phone" class="form-control auth-input"
                                           placeholder="e.g. 0912345678" value="${param.phone}">
                                </div>
                                <small class="auth-field-note">10-11 digits.</small>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label auth-label">Password</label>
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

                            <div class="col-md-6">
                                <label class="form-label auth-label">Confirm Password</label>
                                <div class="position-relative">
                                    <span class="auth-input-icon"><i class="bi bi-shield-check"></i></span>
                                    <input type="password" id="confirmPassword" name="confirmPassword"
                                           class="form-control auth-input has-action"
                                           placeholder="Re-enter password" required>
                                    <button type="button" id="toggleConfirmPassword" class="auth-input-action"
                                            aria-label="Show or hide confirm password">
                                        <i class="bi bi-eye" id="eyeIconConfirm"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="mb-3 d-flex align-items-start gap-2 auth-terms">
                            <input type="checkbox" id="terms" class="form-check-input mt-1" required>
                            <label for="terms" class="form-check-label">
                                I agree to the
                                <a href="" aria-disabled="true" class="auth-link lc-disabled-link">Terms of Use</a>
                                and
                                <a href="" aria-disabled="true" class="auth-link lc-disabled-link">Privacy Policy</a>.
                            </label>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 mb-3 d-flex align-items-center justify-content-center gap-2 auth-submit" data-auth-submit>
                            <span class="auth-spinner" aria-hidden="true"></span>
                            <span class="auth-submit-label">Create Account</span>
                        </button>
                    </form>

                <p class="auth-switch-link auth-reveal" style="--i:4">
                    <span class="text-secondary">Already have an account?</span>
                    <a href="${pageContext.request.contextPath}/auth/login" class="auth-link">Sign in</a>
                </p>
            </div>
        </div>

        <div class="col-lg-5 d-none d-lg-flex">
            <div class="branding-card w-100">
                <div class="star star-auth-1"></div>
                <div class="star star-auth-2"></div>
                <div class="star star-auth-3"></div>
                <div class="star star-auth-5"></div>
                <div class="star star-auth-6"></div>
                <div class="galaxy-glow"></div>
                <div class="galaxy-circle"></div>
                <div class="galaxy-core"></div>
                <div class="galaxy-core-dark"></div>

                <div class="auth-brand-content auth-brand-reveal" style="--i:0">
                    <div class="auth-kicker">
                        <i class="bi bi-gift"></i> Join the club
                    </div>
                    <h1 class="fw-bold auth-brand-title">
                        Free to join.<br>Earn on every visit.
                    </h1>
                    <p class="auth-brand-copy">
                        Sign up in seconds and start collecting points, gifts, and early access to new screenings.
                    </p>

                    <div class="auth-feature-list">
                        <div class="auth-feature"><i class="bi bi-check-lg"></i><span>1 point per 1,000 VND spent, no expiry.</span></div>
                        <div class="auth-feature"><i class="bi bi-check-lg"></i><span>Welcome gift for your first booking.</span></div>
                        <div class="auth-feature"><i class="bi bi-check-lg"></i><span>Early access to ticket sales and previews.</span></div>
                    </div>
                </div>

                <div class="auth-brand-proof auth-proof-rule auth-brand-reveal" style="--i:1">
                    <div class="auth-avatar-stack">
                        <span class="avatar-circle">NH</span>
                        <span class="avatar-circle">TL</span>
                        <span class="avatar-circle">LN</span>
                        <span class="avatar-circle">PH</span>
                    </div>
                    <div class="auth-proof-copy">
                        <strong>3,400+ members</strong>
                        <span>already earning rewards</span>
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
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirmPassword');
        const bars = [
            document.getElementById('strength-bar-1'),
            document.getElementById('strength-bar-2'),
            document.getElementById('strength-bar-3')
        ];
        const toggleBtn = document.getElementById('togglePassword');
        const eyeIcon = document.getElementById('eyeIcon');
        const toggleConfirmBtn = document.getElementById('toggleConfirmPassword');
        const eyeIconConfirm = document.getElementById('eyeIconConfirm');
        const registerForm = document.getElementById('registerForm');

        function setStrength(score) {
            bars.forEach(function (bar) {
                bar.classList.remove('is-weak', 'is-medium', 'is-strong');
            });
            if (score === 1) {
                bars[0].classList.add('is-weak');
            } else if (score === 2) {
                bars[0].classList.add('is-medium');
                bars[1].classList.add('is-medium');
            } else if (score === 3) {
                bars.forEach(function (bar) { bar.classList.add('is-strong'); });
            }
        }

        function passwordScore(value) {
            let score = 0;
            if (value.length > 0 && value.length >= 8 && value.length <= 64) score++;
            if (/[A-Z]/.test(value)) score++;
            if (/[0-9]/.test(value)) score++;
            return score;
        }

        if (toggleBtn && passwordInput) {
            toggleBtn.addEventListener('click', function () {
                const show = passwordInput.type === 'password';
                passwordInput.type = show ? 'text' : 'password';
                eyeIcon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
            });
        }

        if (toggleConfirmBtn && confirmPasswordInput) {
            toggleConfirmBtn.addEventListener('click', function () {
                const show = confirmPasswordInput.type === 'password';
                confirmPasswordInput.type = show ? 'text' : 'password';
                eyeIconConfirm.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
            });
        }

        if (passwordInput) {
            passwordInput.addEventListener('input', function () {
                setStrength(passwordScore(passwordInput.value));
            });
        }

        if (registerForm) {
            registerForm.addEventListener('submit', function (e) {
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

        document.querySelectorAll('[data-auth-submit]').forEach(function (btn) {
            var form = btn.closest('form');
            if (!form) return;
            form.addEventListener('submit', function (e) {
                if (e.defaultPrevented) return;
                btn.classList.add('is-loading');
                var label = btn.querySelector('.auth-submit-label');
                if (label) label.textContent = 'Creating account...';
            });
        });
    });
</script>
</body>
</html>
