<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Đăng nhập - MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            .avatar-circle {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                border: 2px solid #09152b;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
                font-size: 0.75rem;
                font-weight: 700;
                letter-spacing: -0.5px;
            }
            .branding-card {
                background: linear-gradient(135deg, #09152b 0%, #050b18 100%);
                border-radius: 16px;
                color: #ffffff;
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 3.5rem;
            }
            .galaxy-glow {
                position: absolute;
                width: 450px;
                height: 450px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(245, 158, 11, 0.15) 0%, rgba(239, 68, 68, 0.06) 45%, rgba(0,0,0,0) 70%);
                top: 50%;
                right: -130px;
                transform: translateY(-50%);
                z-index: 0;
                pointer-events: none;
                filter: blur(10px);
            }
            .galaxy-circle {
                position: absolute;
                width: 480px;
                height: 480px;
                border-radius: 50%;
                border: 1px solid rgba(255, 255, 255, 0.08);
                top: 50%;
                right: -145px;
                transform: translateY(-50%);
                z-index: 0;
                pointer-events: none;
                animation: spin-galaxy 80s linear infinite;
            }
            /* Small orbit beads */
            .galaxy-circle::before {
                content: '';
                position: absolute;
                width: 5px;
                height: 5px;
                background: rgba(255, 255, 255, 0.35);
                border-radius: 50%;
                top: 15%;
                left: 15%;
            }
            .galaxy-circle::after {
                content: '';
                position: absolute;
                width: 5px;
                height: 5px;
                background: rgba(255, 255, 255, 0.25);
                border-radius: 50%;
                bottom: 25%;
                right: 8%;
            }
            .galaxy-core {
                position: absolute;
                width: 260px;
                height: 260px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(254, 240, 138, 0.8) 0%, rgba(245, 158, 11, 0.6) 30%, rgba(234, 88, 12, 0.2) 55%, transparent 70%);
                top: 50%;
                right: -35px;
                transform: translateY(-50%);
                z-index: 0;
                pointer-events: none;
                filter: blur(4px);
            }
            .galaxy-core-dark {
                position: absolute;
                width: 170px;
                height: 170px;
                border-radius: 50%;
                background: #060d1b;
                top: 50%;
                right: 10px;
                transform: translateY(-50%);
                z-index: 0;
                pointer-events: none;
                box-shadow: inset 0 0 25px rgba(0, 0, 0, 0.95), 0 0 10px rgba(245, 158, 11, 0.1);
            }
            .star {
                position: absolute;
                width: 2px;
                height: 2px;
                background: rgba(255, 255, 255, 0.4);
                border-radius: 50%;
                z-index: 0;
                pointer-events: none;
            }
            @keyframes spin-galaxy {
                100% {
                    transform: translateY(-50%) rotate(360deg);
                }
            }
        </style>
    </head>
    <body class="bg-light">

        <jsp:include page="../common/header.jsp"/>

        <div class="container py-5">
            <div class="row align-items-stretch justify-content-center g-4" style="max-width: 1000px; margin: 0 auto;">
                <!-- Left Column: Login Form Card -->
                <div class="col-lg-6 d-flex">
                    <div class="card p-4 p-md-5 border-0 shadow-sm w-100 d-flex flex-column justify-content-between" style="border-radius: 16px; background: #ffffff;">
                        <div>
                            <div class="text-center mb-4">
                                <!-- Logo SVG -->
                                <div class="d-inline-flex align-items-center">
                                    <svg width="28" height="28" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" style="border-radius: 6px;">
                                    <rect width="32" height="32" rx="8" fill="#182c54" />
                                    <rect x="4" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <rect x="11" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <rect x="18" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <rect x="25" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <rect x="4" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <rect x="11" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <rect x="18" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <rect x="25" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3"/>
                                    <path d="M13 11V21L21 16L13 11Z" fill="#FFC107" />
                                    </svg>
                                    <span class="ms-2 fw-bold text-dark" style="font-size: 1.25rem; letter-spacing: -0.5px;">MBCMS</span>
                                </div>
                            </div>

                            <h3 class="text-center fw-bold mb-1" style="color: #0F1E36;">Welcome Back</h3>
                            <p class="text-center text-muted mb-4" style="font-size: 0.9rem;">Sign in to your MBCMS account</p>

                            <c:if test="${not empty errorMsg}">
                                <div class="alert alert-danger py-2" style="font-size: 0.85rem;">${errorMsg}</div>
                            </c:if>
                            <c:if test="${not empty successMsg}">
                                <div class="alert alert-success py-2" style="font-size: 0.85rem;">${successMsg}</div>
                            </c:if>

                            <form method="post" action="${pageContext.request.contextPath}/auth/login">
                                <!-- Email/Username field -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold text-secondary" style="font-size: 0.85rem;">Email Address</label>
                                    <div class="position-relative">
                                        <span class="position-absolute" style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af;">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                                        </span>
                                        <input type="text" name="email" class="form-control" 
                                               style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 44px; font-size: 0.9rem;"
                                               placeholder="thank0617@gmail.com" value="${param.email}" required>
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}" />
                                    </div>
                                </div>

                                <!-- Password field -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold text-secondary" style="font-size: 0.85rem;">Password</label>
                                    <div class="position-relative">
                                        <span class="position-absolute" style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af;">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                                        </span>
                                        <input type="password" id="loginPassword" name="password" class="form-control" 
                                               style="padding-left: 40px; padding-right: 40px; border-radius: 8px; border-color: #d1d5db; height: 44px; font-size: 0.9rem;"
                                               placeholder="••••••••••••" required>
                                        <span class="position-absolute" style="right: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af; cursor: pointer;" onclick="togglePasswordVisibility('loginPassword')">
                                            <svg id="eyeIcon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                        </span>
                                    </div>
                                </div>

                                <!-- Remember me and Forgot password -->
                                <div class="d-flex justify-content-between align-items-center mb-4" style="font-size: 0.85rem;">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="rememberMe">
                                        <label class="form-check-label text-secondary" for="rememberMe">
                                            Remember me (7-day session)
                                        </label>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="text-decoration-none fw-semibold" style="color: #2563eb;">Forgot Password?</a>
                                </div>

                                <!-- Sign In Button -->
                                <button type="submit" class="btn w-100 text-white fw-semibold mb-3 d-flex align-items-center justify-content-center border-0" 
                                        style="background: #2563eb; height: 44px; border-radius: 8px;">
                                    Sign In
                                </button>
                            </form>

                            <!-- Divider -->
                            <div class="d-flex align-items-center my-3">
                                <hr class="flex-grow-1" style="border-color: #e5e7eb;">
                                <span class="mx-3 text-secondary" style="font-size: 0.75rem;">or continue with</span>
                                <hr class="flex-grow-1" style="border-color: #e5e7eb;">
                            </div>

                            <!-- Google Button -->
                            <button class="btn w-100 border d-flex align-items-center justify-content-center gap-2 mb-4" 
                                    style="background: #ffffff; border-color: #d1d5db; height: 44px; border-radius: 8px; font-weight: 500; font-size: 0.9rem; color: #4b5563;">
                                <svg width="18" height="18" viewBox="0 0 24 24">
                                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22c-.62-.62-1.01-1.38-1.18-2.21z"/>
                                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                                </svg>
                                Sign in with Google
                            </button>
                        </div>

                        <div class="text-center mt-2" style="font-size: 0.9rem;">
                            <span class="text-secondary">Don't have an account?</span>
                            <a href="${pageContext.request.contextPath}/auth/register" class="fw-semibold text-decoration-none" style="color: #2563eb;">Register now</a>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Branding Welcome Card -->
                <div class="col-lg-6 d-none d-lg-flex">
                    <div class="branding-card w-100">
                        <!-- Stars -->
                        <div class="star" style="top: 12%; left: 15%;"></div>
                        <div class="star" style="top: 8%; left: 65%; opacity: 0.6; width: 3px; height: 3px;"></div>
                        <div class="star" style="top: 25%; left: 40%; opacity: 0.3;"></div>
                        <div class="star" style="top: 35%; left: 80%; opacity: 0.5;"></div>
                        <div class="star" style="top: 55%; left: 12%; opacity: 0.4; width: 3px; height: 3px;"></div>
                        <div class="star" style="top: 72%; left: 55%; opacity: 0.6;"></div>
                        <div class="star" style="top: 85%; left: 22%; opacity: 0.3;"></div>
                        <div class="star" style="top: 90%; left: 75%; opacity: 0.5; width: 3px; height: 3px;"></div>

                        <!-- Celestial Background elements -->
                        <div class="galaxy-glow"></div>
                        <div class="galaxy-circle"></div>
                        <div class="galaxy-core"></div>
                        <div class="galaxy-core-dark"></div>

                        <div style="position: relative; z-index: 1;">
                            <!-- Badge -->
                            <div class="d-inline-flex align-items-center mb-4" 
                                 style="background: rgba(255,255,255,0.06); border-radius: 24px; border: 1px solid rgba(255,255,255,0.12); padding: 6px 16px; font-size: 0.75rem; color: rgba(255,255,255,0.85); font-weight: 600; letter-spacing: 1px;">
                                <span style="color: #fbbf24; margin-right: 8px;">✨</span> WELCOME <span style="margin-left: 8px; opacity: 0.5;">──</span>
                            </div>

                            <!-- Title & Subtitle -->
                            <h1 class="fw-bold text-white mb-3" style="font-size: 2.6rem; line-height: 1.2; letter-spacing: -0.02em; font-family: 'Segoe UI', sans-serif;">
                                Your Cinema,<br>Your Experience.
                            </h1>
                            <p class="text-white-50" style="font-size: 0.95rem; line-height: 1.6; max-width: 380px;">
                                Book tickets across all MBCMS locations, choose your seats, and earn points on every booking.
                            </p>
                        </div>

                        <!-- Footer statistics -->
                        <div class="d-flex align-items-center gap-3" style="position: relative; z-index: 1;">
                            <div class="d-flex">
                                <span class="avatar-circle" style="background: #2563eb; z-index: 4;">NH</span>
                                <span class="avatar-circle" style="background: #10b981; z-index: 3; margin-left: -10px;">TL</span>
                                <span class="avatar-circle" style="background: #f97316; z-index: 2; margin-left: -10px;">LN</span>
                                <span class="avatar-circle" style="background: #eab308; z-index: 1; margin-left: -10px;">PH</span>
                            </div>
                            <div style="font-size: 0.9rem; color: rgba(255,255,255,0.7); line-height: 1.4;">
                                <strong class="text-white fw-semibold" style="font-size: 0.95rem;">3,400+ customers</strong><br>
                                <span style="font-size: 0.85rem; color: rgba(255, 255, 255, 0.5);">across HCMC & Hanoi</span>
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
        </script>
    </body>
</html>
