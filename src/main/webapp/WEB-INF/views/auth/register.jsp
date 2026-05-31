<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Đăng ký - MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}"
              rel="stylesheet">
        <style>
            .avatar-circle {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                border: 2px solid #081121;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
                font-size: 0.7rem;
                font-weight: 700;
            }

            .branding-card {
                background: linear-gradient(135deg, #081121 0%, #0d2242 100%);
                border-radius: 16px;
                color: #ffffff;
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 3rem;
            }

            .galaxy-glow {
                position: absolute;
                width: 300px;
                height: 300px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(255, 193, 7, 0.15) 0%, rgba(0, 0, 0, 0) 70%);
                top: 50%;
                right: -50px;
                transform: translateY(-50%);
                z-index: 0;
                pointer-events: none;
            }

            .galaxy-circle {
                position: absolute;
                width: 250px;
                height: 250px;
                border-radius: 50%;
                border: 1px dashed rgba(255, 255, 255, 0.08);
                top: 50%;
                right: -25px;
                transform: translateY(-50%);
                z-index: 0;
                pointer-events: none;
                animation: spin-galaxy 60s linear infinite;
            }

            .galaxy-core {
                position: absolute;
                width: 120px;
                height: 120px;
                border-radius: 50%;
                background: #050a14;
                box-shadow: 0 0 30px rgba(255, 193, 7, 0.35), inset 0 0 15px rgba(255, 255, 255, 0.1);
                top: 50%;
                right: 40px;
                transform: translateY(-50%);
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

        <jsp:include page="../common/header.jsp" />

        <div class="container py-5">
            <div class="row align-items-stretch justify-content-center g-4"
                 style="max-width: 1100px; margin: 0 auto;">
                <!-- Left Column: Registration Form Card -->
                <div class="col-lg-7 d-flex">
                    <div class="card p-4 p-md-5 border-0 shadow-sm w-100 d-flex flex-column justify-content-between"
                         style="border-radius: 16px; background: #ffffff;">
                        <div>
                            <div class="text-center mb-3">
                                <!-- Logo SVG -->
                                <div class="d-inline-flex align-items-center">
                                    <svg width="28" height="28" viewBox="0 0 32 32" fill="none"
                                         xmlns="http://www.w3.org/2000/svg" style="border-radius: 6px;">
                                    <rect width="32" height="32" rx="8" fill="#182c54" />
                                    <rect x="4" y="3" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <rect x="11" y="3" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <rect x="18" y="3" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <rect x="25" y="3" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <rect x="4" y="26" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <rect x="11" y="26" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <rect x="18" y="26" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <rect x="25" y="26" width="3" height="3" rx="1" fill="#FFFFFF"
                                          opacity="0.3" />
                                    <path d="M13 11V21L21 16L13 11Z" fill="#FFC107" />
                                    </svg>
                                    <span class="ms-2 fw-bold text-dark"
                                          style="font-size: 1.25rem; letter-spacing: -0.5px;">MBCMS</span>
                                </div>
                            </div>

                            <h3 class="text-center fw-bold mb-1" style="color: #0F1E36;">Create Your Account</h3>
                            <p class="text-center text-muted mb-4" style="font-size: 0.9rem;">Join MBCMS and start
                                booking in seconds</p>

                            <c:if test="${not empty errorMsg}">
                                <div class="alert alert-danger py-2" style="font-size: 0.85rem;">${errorMsg}</div>
                            </c:if>

                            <form id="registerForm" method="post"
                                  action="${pageContext.request.contextPath}/auth/register">
                                <div class="row g-3 mb-3">
                                    <!-- Username -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">Username</label>
                                        <div class="position-relative">
                                            <span class="position-absolute"
                                                  style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af; display: flex; align-items: center;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                                <circle cx="12" cy="7" r="4"></circle>
                                                </svg>
                                            </span>
                                            <input type="text" name="username" class="form-control"
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 40px; font-size: 0.9rem;"
                                                   placeholder="hung_nguyen" value="${param.username}" required>
                                        </div>
                                        <small class="text-secondary"
                                               style="font-size: 0.72rem; display: block; margin-top: 4px; color: #6b7280 !important;">
                                            4-50 characters &middot; must be unique
                                        </small>
                                    </div>

                                    <!-- Full Name -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">Full Name</label>
                                        <div class="position-relative">
                                            <span class="position-absolute"
                                                  style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af; display: flex; align-items: center;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <rect x="3" y="4" width="18" height="16" rx="2"></rect>
                                                <circle cx="9" cy="10" r="2"></circle>
                                                <path d="M6 16c0-2 2-3 3-3s3 1 3 3"></path>
                                                <line x1="15" y1="8" x2="18" y2="8"></line>
                                                <line x1="15" y1="12" x2="18" y2="12"></line>
                                                </svg>
                                            </span>
                                            <input type="text" name="fullName" class="form-control"
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 40px; font-size: 0.9rem;"
                                                   placeholder="Nguyen Hung" value="${param.fullName}" required>
                                        </div>
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <!-- Email -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">Email Address</label>
                                        <div class="position-relative">
                                            <span class="position-absolute"
                                                  style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af; display: flex; align-items: center;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <path
                                                    d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z">
                                                </path>
                                                <polyline points="22,6 12,13 2,6"></polyline>
                                                </svg>
                                            </span>
                                            <input type="email" name="email" class="form-control"
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 40px; font-size: 0.9rem;"
                                                   placeholder="you@email.com" value="${param.email}" required>
                                        </div>
                                    </div>

                                    <!-- Phone Number -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">Phone Number</label>
                                        <div class="position-relative">
                                            <span class="position-absolute"
                                                  style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af; display: flex; align-items: center;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <path
                                                    d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z">
                                                </path>
                                                </svg>
                                            </span>
                                            <input type="tel" name="phone" class="form-control"
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 40px; font-size: 0.9rem;"
                                                   placeholder="0901234567" value="${param.phone}">
                                        </div>
                                        <small class="text-secondary"
                                               style="font-size: 0.72rem; display: block; margin-top: 4px; color: #6b7280 !important;">
                                            10-11 digits
                                        </small>
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <!-- Password -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">Password</label>
                                        <div class="position-relative">
                                            <span class="position-absolute"
                                                  style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af; display: flex; align-items: center;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                                </svg>
                                            </span>
                                            <input type="password" id="password" name="password"
                                                   class="form-control"
                                                   style="padding-left: 40px; padding-right: 40px; border-radius: 8px; border-color: #d1d5db; height: 40px; font-size: 0.9rem;"
                                                   placeholder="At least 8 character" required>
                                            <button type="button" id="togglePassword"
                                                    class="btn btn-link position-absolute p-0 text-muted"
                                                    style="right: 12px; top: 50%; transform: translateY(-50%); display: flex; align-items: center; border: none; background: none; text-decoration: none;">
                                                <svg id="eyeIcon" width="18" height="18" viewBox="0 0 24 24"
                                                     fill="none" stroke="currentColor" stroke-width="2"
                                                     stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                                </svg>
                                            </button>
                                        </div>
                                        <small class="text-secondary"
                                               style="font-size: 0.72rem; display: block; margin-top: 4px; color: #6b7280 !important;">
                                            8-64 chars &middot; at least 1 uppercase + 1 digit
                                        </small>
                                        <div class="d-flex gap-2 mt-2">
                                            <div id="strength-bar-1" class="flex-grow-1"
                                                 style="height: 4px; background: #e5e7eb; border-radius: 2px; transition: background-color 0.2s ease;">
                                            </div>
                                            <div id="strength-bar-2" class="flex-grow-1"
                                                 style="height: 4px; background: #e5e7eb; border-radius: 2px; transition: background-color 0.2s ease;">
                                            </div>
                                            <div id="strength-bar-3" class="flex-grow-1"
                                                 style="height: 4px; background: #e5e7eb; border-radius: 2px; transition: background-color 0.2s ease;">
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Confirm Password -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">Confirm Password</label>
                                        <div class="position-relative">
                                            <span class="position-absolute"
                                                  style="left: 12px; top: 50%; transform: translateY(-50%); color: #9ca3af; display: flex; align-items: center;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                                                </svg>
                                            </span>
                                            <input type="password" id="confirmPassword" name="confirmPassword"
                                                   class="form-control"
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 40px; font-size: 0.9rem;"
                                                   placeholder="Re-enter password" required>
                                        </div>
                                    </div>
                                </div>

                                <!-- Checkbox Terms -->
                                <div class="mb-3 d-flex align-items-center">
                                    <input type="checkbox" id="terms" class="form-check-input me-2" required>
                                    <label for="terms" class="form-check-label text-secondary"
                                           style="font-size: 0.85rem;">
                                        I agree to the <a href="#" class="text-decoration-none fw-semibold"
                                                          style="color: #2563eb;">Terms of Use</a> and <a href="#"
                                                          class="text-decoration-none fw-semibold" style="color: #2563eb;">Privacy
                                            Policy</a>
                                    </label>
                                </div>

                                <!-- Register Button -->
                                <button type="submit"
                                        class="btn w-100 text-white fw-semibold mb-3 d-flex align-items-center justify-content-center border-0"
                                        style="background: #2563eb; height: 44px; border-radius: 8px; font-size: 1rem;">
                                    Create Account
                                </button>
                            </form>

                            <!-- Google signup and divisor -->
                            <div class="d-flex align-items-center my-3 text-muted" style="font-size: 0.85rem;">
                                <div class="flex-grow-1" style="border-top: 1px solid #e5e7eb;"></div>
                                <span class="px-3" style="font-size: 0.8rem; color: #9ca3af;">or sign up with</span>
                                <div class="flex-grow-1" style="border-top: 1px solid #e5e7eb;"></div>
                            </div>

                            <a href="#"
                               class="btn btn-outline-light w-100 d-flex align-items-center justify-content-center border gap-2 text-dark fw-semibold mb-3"
                               style="border-color: #e5e7eb !important; border-radius: 8px; height: 44px; background: #ffffff; font-size: 0.95rem; text-decoration: none;">
                                <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
                                     alt="Google" width="18" height="18">
                                Sign up with Google
                            </a>
                        </div>

                        <div class="text-center mt-2" style="font-size: 0.9rem;">
                            <span class="text-secondary">Already have an account?</span>
                            <a href="${pageContext.request.contextPath}/auth/login"
                               class="fw-semibold text-decoration-none" style="color: #2563eb;">Sign In</a>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Branding Welcome Card -->
                <div class="col-lg-5 d-none d-lg-flex">
                    <div class="branding-card w-100 d-flex flex-column justify-content-between">
                        <!-- Watermark Background elements -->
                        <!-- Ticket SVG watermark -->
                        <svg width="240" height="150" viewBox="0 0 200 120" fill="none"
                             xmlns="http://www.w3.org/2000/svg"
                             style="position: absolute; bottom: -30px; left: -30px; opacity: 0.04; transform: rotate(15deg); pointer-events: none; z-index: 0;">
                        <rect width="200" height="120" rx="12" fill="none" stroke="white" stroke-width="4"
                              stroke-dasharray="10 10" />
                        <circle cx="0" cy="60" r="16" fill="#081223" />
                        <circle cx="200" cy="60" r="16" fill="#081223" />
                        <circle cx="30" cy="30" r="4" fill="white" />
                        <circle cx="50" cy="30" r="4" fill="white" />
                        <circle cx="70" cy="30" r="4" fill="white" />
                        <rect x="30" y="50" width="80" height="4" fill="white" rx="2" />
                        <rect x="30" y="65" width="50" height="4" fill="white" rx="2" />
                        </svg>

                        <!-- Sparkles/Stars SVG watermark -->
                        <svg width="150" height="150" viewBox="0 0 120 120" fill="none"
                             xmlns="http://www.w3.org/2000/svg"
                             style="position: absolute; top: 30px; right: 20px; opacity: 0.15; pointer-events: none; z-index: 0;">
                        <!-- Star 1 -->
                        <path d="M40 10L44 24L58 28L44 32L40 46L36 32L22 28L36 24L40 10Z" fill="white" />
                        <!-- Star 2 -->
                        <path d="M85 45L88 54L98 57L88 60L85 69L82 60L72 57L82 54L85 45Z" fill="white" />
                        <!-- Star 3 -->
                        <path d="M60 80L61.5 84L66 85.5L61.5 87L60 91L58.5 87L54 85.5L58.5 84L60 80Z"
                              fill="white" />
                        </svg>

                        <div style="position: relative; z-index: 1;">
                            <!-- Badge -->
                            <div class="d-inline-flex align-items-center px-3 py-1 mb-4"
                                 style="background: rgba(255,255,255,0.06); border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); font-size: 0.75rem; color: #ffffff; font-weight: 600; letter-spacing: 1px;">
                                <span class="me-2">✨</span> JOIN THE CLUB &mdash;
                            </div>

                            <!-- Title & Subtitle -->
                            <h1 class="fw-bold text-white mb-3"
                                style="font-size: 2.25rem; line-height: 1.25; max-width: 400px;">
                                Free to Join.<br>Earn on Every Visit.
                            </h1>
                            <p class="text-white-50 mb-5"
                               style="font-size: 0.95rem; line-height: 1.6; max-width: 380px;">
                                Sign up in seconds and start collecting points. Reach Gold tier for an automatic 10%
                                discount on every booking.
                            </p>

                            <!-- Benefit Checklist -->
                            <div class="mb-5 d-flex flex-column gap-3" style="font-size: 0.95rem;">
                                <div class="d-flex align-items-center gap-3">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                         xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" fill="#10b981" />
                                    <path d="M8 12L11 15L16 9" stroke="white" stroke-width="2.5"
                                          stroke-linecap="round" stroke-linejoin="round" />
                                    </svg>
                                    <span class="text-white-50">1 point per 1,000đ spent · no expiry</span>
                                </div>
                                <div class="d-flex align-items-center gap-3">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                         xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" fill="#10b981" />
                                    <path d="M8 12L11 15L16 9" stroke="white" stroke-width="2.5"
                                          stroke-linecap="round" stroke-linejoin="round" />
                                    </svg>
                                    <span class="text-white-50">Welcome gift: 50,000đ off your first booking</span>
                                </div>
                                <div class="d-flex align-items-center gap-3">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                         xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" fill="#10b981" />
                                    <path d="M8 12L11 15L16 9" stroke="white" stroke-width="2.5"
                                          stroke-linecap="round" stroke-linejoin="round" />
                                    </svg>
                                    <span class="text-white-50">Early access to ticket sales & previews</span>
                                </div>
                            </div>
                        </div>

                        <!-- Footer statistics -->
                        <div class="d-flex align-items-center gap-3"
                             style="position: relative; z-index: 1; border-top: 1px solid rgba(255,255,255,0.08); padding-top: 1.5rem;">
                            <div class="d-flex">
                                <span class="avatar-circle" style="background: #2563eb; z-index: 4;">NH</span>
                                <span class="avatar-circle"
                                      style="background: #10b981; z-index: 3; margin-left: -8px;">TL</span>
                                <span class="avatar-circle"
                                      style="background: #f59e0b; z-index: 2; margin-left: -8px;">LN</span>
                                <span class="avatar-circle"
                                      style="background: #ef4444; z-index: 1; margin-left: -8px;">PH</span>
                            </div>
                            <div style="font-size: 0.85rem; color: rgba(255,255,255,0.7); line-height: 1.4;">
                                <strong class="text-white">3,400+ members</strong><br>already earning rewards
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="../common/footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const passwordInput = document.getElementById('password');
                const confirmPasswordInput = document.getElementById('confirmPassword');
                const bar1 = document.getElementById('strength-bar-1');
                const bar2 = document.getElementById('strength-bar-2');
                const bar3 = document.getElementById('strength-bar-3');
                const toggleBtn = document.getElementById('togglePassword');
                const registerForm = document.getElementById('registerForm');

                const eyeOpenSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
        <circle cx="12" cy="12" r="3"></circle>
    </svg>`;
                const eyeClosedSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
        <line x1="1" y1="1" x2="23" y2="23"></line>
    </svg>`;

                // Password Show/Hide Toggle
                if (toggleBtn && passwordInput) {
                    toggleBtn.addEventListener('click', function () {
                        if (passwordInput.type === 'password') {
                            passwordInput.type = 'text';
                            toggleBtn.innerHTML = eyeClosedSvg;
                        } else {
                            passwordInput.type = 'password';
                            toggleBtn.innerHTML = eyeOpenSvg;
                        }
                    });
                }

                // Password Strength Checker
                if (passwordInput) {
                    passwordInput.addEventListener('input', function () {
                        const val = passwordInput.value;

                        // Rules:
                        // 1. Length 8-64 chars
                        // 2. At least 1 uppercase letter
                        // 3. At least 1 digit
                        const hasLength = val.length >= 8 && val.length <= 64;
                        const hasUppercase = /[A-Z]/.test(val);
                        const hasDigit = /[0-9]/.test(val);

                        let score = 0;
                        if (val.length > 0) {
                            if (hasLength)
                                score++;
                            if (hasUppercase)
                                score++;
                            if (hasDigit)
                                score++;
                        }

                        // Reset bars color
                        bar1.style.backgroundColor = '#e5e7eb';
                        bar2.style.backgroundColor = '#e5e7eb';
                        bar3.style.backgroundColor = '#e5e7eb';

                        if (score === 1) {
                            bar1.style.backgroundColor = '#ef4444'; // Red (Weak)
                        } else if (score === 2) {
                            bar1.style.backgroundColor = '#f59e0b'; // Orange (Medium)
                            bar2.style.backgroundColor = '#f59e0b';
                        } else if (score === 3) {
                            bar1.style.backgroundColor = '#10b981'; // Green (Strong)
                            bar2.style.backgroundColor = '#10b981';
                            bar3.style.backgroundColor = '#10b981';
                        }
                    });
                }

                // Form Validation on Submit
                if (registerForm) {
                    registerForm.addEventListener('submit', function (e) {
                        const val = passwordInput.value;
                        const confirmVal = confirmPasswordInput.value;

                        const hasLength = val.length >= 8 && val.length <= 64;
                        const hasUppercase = /[A-Z]/.test(val);
                        const hasDigit = /[0-9]/.test(val);

                        if (!hasLength || !hasUppercase || !hasDigit) {
                            e.preventDefault();
                            alert('Password must be 8-64 characters and contain at least 1 uppercase letter and 1 digit.');
                            return false;
                        }

                        if (val !== confirmVal) {
                            e.preventDefault();
                            alert('Passwords do not match.');
                            return false;
                        }
                    });
                }
            });
        </script>
    </body>

</html>