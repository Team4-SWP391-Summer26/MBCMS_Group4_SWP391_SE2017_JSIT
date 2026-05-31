<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Quên mật khẩu - MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            .branding-card {
                background: linear-gradient(135deg, #0c1a30 0%, #050b15 100%);
                border-radius: 16px;
                color: #ffffff;
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 3rem;
                border: 1px solid rgba(255, 255, 255, 0.05);
                min-height: 480px;
            }

            /* Custom input styling */
            .form-control:focus {
                border-color: #2563eb;
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
            }

            .step-circle {
                width: 28px;
                height: 28px;
                font-size: 0.85rem;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 50%;
                font-weight: bold;
                flex-shrink: 0;
            }

            .avatar-circle {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                border: 2px solid #0c1a30;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
                font-size: 0.75rem;
                font-weight: 700;
            }
        </style>
    </head>

    <body class="bg-light">

        <jsp:include page="../common/header.jsp" />

        <c:set var="currentStep" value="${empty param.step ? (empty step ? 'email' : step) : (param.step)}" />

        <div class="container py-5">
            <div class="row align-items-stretch justify-content-center g-4"
                 style="max-width: 1000px; margin: 0 auto;">
                <!-- Left Column: Form Card -->
                <div class="col-lg-6 d-flex">
                    <div class="card p-4 p-md-5 border-0 shadow-sm w-100 d-flex flex-column justify-content-between"
                         style="border-radius: 16px; background: #ffffff;">
                        <div>
                            <div class="text-center mb-4">
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

                            <!-- Step Progress Wizard -->
                            <div class="d-flex align-items-center justify-content-center gap-3 gap-md-4 mb-5 px-2"
                                 style="font-size: 0.8rem;">
                                <!-- Step 1 -->
                                <div class="d-flex align-items-center gap-2 text-nowrap">
                                    <c:choose>
                                        <c:when test="${currentStep == 'verify' || currentStep == 'reset'}">
                                            <div class="step-circle text-white" style="background-color: #10b981;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="3" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <polyline points="20 6 9 17 4 12"></polyline>
                                                </svg>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="step-circle text-white animate-pulse"
                                                 style="background-color: #2563eb;">1</div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="text-nowrap">
                                        <div class="fw-bold text-nowrap"
                                             style="color: ${currentStep == 'email' ? '#2563eb' : '#10b981'}; line-height: 1.1;">
                                            Enter Email</div>
                                        <div class="text-muted text-nowrap"
                                             style="font-size: 0.7rem; text-transform: uppercase;">STEP 1</div>
                                    </div>
                                </div>

                                <!-- Divider -->
                                <div class="flex-shrink-0"
                                     style="color: #94a3b8; font-size: 1.1rem; font-weight: 300;">&ndash;</div>

                                <!-- Step 2 -->
                                <div class="d-flex align-items-center gap-2 text-nowrap">
                                    <c:choose>
                                        <c:when test="${currentStep == 'reset'}">
                                            <div class="step-circle text-white" style="background-color: #10b981;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="3" stroke-linecap="round"
                                                     stroke-linejoin="round">
                                                <polyline points="20 6 9 17 4 12"></polyline>
                                                </svg>
                                            </div>
                                        </c:when>
                                        <c:when test="${currentStep == 'verify'}">
                                            <div class="step-circle text-white" style="background-color: #2563eb;">2
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="step-circle text-muted" style="background-color: #e5e7eb;">2
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="text-nowrap">
                                        <div class="fw-bold text-nowrap ${currentStep == 'verify' ? 'text-primary' : (currentStep == 'reset' ? 'text-success' : 'text-secondary')}"
                                             style="line-height: 1.1;">Verify Code</div>
                                        <div class="text-muted text-nowrap"
                                             style="font-size: 0.7rem; text-transform: uppercase;">STEP 2</div>
                                    </div>
                                </div>

                                <!-- Divider -->
                                <div class="flex-shrink-0"
                                     style="color: #94a3b8; font-size: 1.1rem; font-weight: 300;">&ndash;</div>

                                <!-- Step 3 -->
                                <div class="d-flex align-items-center gap-2 text-nowrap">
                                    <div class="step-circle ${currentStep == 'reset' ? 'text-white bg-primary' : 'text-muted bg-light'}"
                                         style="border: ${currentStep == 'reset' ? 'none' : '1px solid #d1d5db'};">3
                                    </div>
                                    <div class="text-nowrap">
                                        <div class="fw-bold text-nowrap ${currentStep == 'reset' ? 'text-primary' : 'text-secondary'}"
                                             style="line-height: 1.1;">New Password</div>
                                        <div class="text-muted text-nowrap"
                                             style="font-size: 0.7rem; text-transform: uppercase;">STEP 3</div>
                                    </div>
                                </div>
                            </div>

                            <c:if test="${not empty errorMsg}">
                                <div class="alert alert-danger py-2 mb-4" style="font-size: 0.85rem;">${errorMsg}
                                </div>
                            </c:if>
                            <c:if test="${not empty successMsg}">
                                <div class="alert alert-success py-2 mb-4" style="font-size: 0.85rem;">${successMsg}
                                </div>
                            </c:if>

                            <!-- STEP 1 FORM: Email recovery input -->
                            <c:if test="${currentStep == 'email'}">
                                <h3 class="fw-bold mb-1" style="color: #0F1E36; font-size: 1.6rem;">Forgot your
                                    password?</h3>
                                <p class="text-muted mb-4" style="font-size: 0.9rem;">
                                    Enter your registered email and we'll send you a 6-digit verification code to
                                    reset your password.
                                </p>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/auth/forgot-password">
                                    <input type="hidden" name="action" value="send-code">
                                    <div class="mb-4">
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
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 44px; font-size: 0.9rem;"
                                                   placeholder="thank0617@gmail.com" value="${param.email}" required>
                                        </div>
                                    </div>

                                    <button type="submit"
                                            class="btn w-100 text-white fw-semibold mb-4 d-flex align-items-center justify-content-center gap-2 border-0"
                                            style="background: #2563eb; height: 46px; border-radius: 8px; font-size: 1rem;">
                                        Send Verification Code
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                             stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                             stroke-linejoin="round">
                                        <line x1="5" y1="12" x2="19" y2="12"></line>
                                        <polyline points="12 5 19 12 12 19"></polyline>
                                        </svg>
                                    </button>
                                </form>
                            </c:if>

                            <!-- STEP 2 FORM: Verification Code input -->
                            <c:if test="${currentStep == 'verify'}">
                                <h3 class="fw-bold mb-1" style="color: #0F1E36; font-size: 1.6rem;">Verify Code</h3>
                                <p class="text-muted mb-4" style="font-size: 0.9rem;">
                                    Please enter the 6-digit verification code sent to your email
                                    <strong>${param.email != null ? param.email : email}</strong>.
                                </p>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/auth/forgot-password">
                                    <input type="hidden" name="action" value="verify-code">
                                    <input type="hidden" name="email"
                                           value="${param.email != null ? param.email : email}">
                                    <div class="mb-4">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">Verification Code</label>
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
                                            <input type="text" name="code" class="form-control text-center fw-bold"
                                                   maxlength="6" pattern="\d{6}"
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 44px; font-size: 1.25rem; letter-spacing: 4px;"
                                                   placeholder="123456" required>
                                        </div>
                                    </div>

                                    <button type="submit"
                                            class="btn w-100 text-white fw-semibold mb-4 d-flex align-items-center justify-content-center gap-2 border-0"
                                            style="background: #2563eb; height: 46px; border-radius: 8px; font-size: 1rem;">
                                        Verify Code
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                             stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                             stroke-linejoin="round">
                                        <line x1="5" y1="12" x2="19" y2="12"></line>
                                        <polyline points="12 5 19 12 12 19"></polyline>
                                        </svg>
                                    </button>
                                </form>
                            </c:if>

                            <!-- STEP 3 FORM: Password Reset input -->
                            <c:if test="${currentStep == 'reset'}">
                                <h3 class="fw-bold mb-1" style="color: #0F1E36; font-size: 1.6rem;">New Password
                                </h3>
                                <p class="text-muted mb-4" style="font-size: 0.9rem;">
                                    Set a strong password to secure your account and recover booking services.
                                </p>

                                <form id="resetPasswordForm" method="post"
                                      action="${pageContext.request.contextPath}/auth/forgot-password">
                                    <input type="hidden" name="action" value="reset-password">
                                    <input type="hidden" name="email"
                                           value="${param.email != null ? param.email : email}">
                                    <input type="hidden" name="code"
                                           value="${param.code != null ? param.code : code}">

                                    <!-- Password -->
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold text-secondary mb-1"
                                               style="font-size: 0.85rem;">New Password</label>
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
                                                   style="padding-left: 40px; padding-right: 40px; border-radius: 8px; border-color: #d1d5db; height: 44px; font-size: 0.9rem;"
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
                                    <div class="mb-4">
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
                                                   style="padding-left: 40px; border-radius: 8px; border-color: #d1d5db; height: 44px; font-size: 0.9rem;"
                                                   placeholder="Re-enter password" required>
                                        </div>
                                    </div>

                                    <button type="submit"
                                            class="btn w-100 text-white fw-semibold mb-4 d-flex align-items-center justify-content-center gap-2 border-0"
                                            style="background: #2563eb; height: 46px; border-radius: 8px; font-size: 1rem;">
                                        Reset Password
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                             stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                             stroke-linejoin="round">
                                        <line x1="5" y1="12" x2="19" y2="12"></line>
                                        <polyline points="12 5 19 12 12 19"></polyline>
                                        </svg>
                                    </button>
                                </form>
                            </c:if>
                        </div>

                        <!-- Back to Login footer link -->
                        <div class="text-center">
                            <a href="${pageContext.request.contextPath}/auth/login"
                               class="text-decoration-none fw-semibold d-inline-flex align-items-center gap-1"
                               style="color: #2563eb; font-size: 0.9rem;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="19" y1="12" x2="5" y2="12"></line>
                                <polyline points="12 19 5 12 12 5"></polyline>
                                </svg>
                                Back to Sign In
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Branding card -->
                <div class="col-lg-6 d-none d-lg-flex">
                    <div class="branding-card w-100">
                        <!-- Custom Background Artwork matching Figma -->
                        <div
                            style="position: absolute; top: 0; right: 0; bottom: 0; left: 0; z-index: 0; pointer-events: none; overflow: hidden;">
                            <!-- Radial glow background -->
                            <div
                                style="position: absolute; bottom: 0; right: 0; width: 100%; height: 100%; background: radial-gradient(circle at bottom right, rgba(37, 99, 235, 0.08) 0%, rgba(0,0,0,0) 70%);">
                            </div>
                            <!-- Inception Text Watermark at the bottom right behind the content -->
                            <div
                                style="position: absolute; bottom: 40px; right: -40px; font-family: 'Inter', 'Montserrat', sans-serif; font-weight: 900; font-size: 5.5rem; color: #ffffff; opacity: 0.035; letter-spacing: 4px; z-index: 1; transform: rotate(-5deg); white-space: nowrap;">
                                INCEPTION
                            </div>
                            <!-- Ticket outline with vertical equalizer/barcode lines -->
                            <svg width="320" height="480" viewBox="0 0 320 480" fill="none"
                                 xmlns="http://www.w3.org/2000/svg"
                                 style="position: absolute; right: -20px; top: 40px; transform: rotate(-5deg); opacity: 0.4;">
                            <!-- Ticket Border -->
                            <rect x="10" y="10" width="300" height="440" rx="16" stroke="#ffffff"
                                  stroke-width="1.5" stroke-opacity="0.08" fill="none" />
                            <circle cx="10" cy="220" r="12" fill="#0c1a30" />
                            <circle cx="310" cy="220" r="12" fill="#0c1a30" />
                            <line x1="22" y1="220" x2="298" y2="220" stroke="#ffffff" stroke-width="1.5"
                                  stroke-dasharray="4 4" stroke-opacity="0.08" />

                            <!-- Equalizer / Barcode Lines in background -->
                            <g opacity="0.06" stroke="#ffffff" stroke-width="5" stroke-linecap="round">
                            <line x1="50" y1="120" x2="50" y2="200" />
                            <line x1="62" y1="90" x2="62" y2="210" />
                            <line x1="74" y1="130" x2="74" y2="180" />
                            <line x1="86" y1="70" x2="86" y2="230" />
                            <line x1="98" y1="110" x2="98" y2="200" />
                            <line x1="110" y1="95" x2="110" y2="215" />
                            <line x1="122" y1="140" x2="122" y2="175" />
                            <line x1="134" y1="80" x2="134" y2="240" />
                            <line x1="146" y1="105" x2="146" y2="210" />
                            <line x1="158" y1="60" x2="158" y2="230" />
                            <line x1="170" y1="130" x2="170" y2="200" />
                            <line x1="182" y1="90" x2="182" y2="220" />
                            <line x1="194" y1="120" x2="194" y2="190" />
                            <line x1="206" y1="75" x2="206" y2="230" />
                            <line x1="218" y1="100" x2="218" y2="195" />
                            <line x1="230" y1="85" x2="230" y2="210" />
                            <line x1="242" y1="135" x2="242" y2="185" />
                            <line x1="254" y1="65" x2="254" y2="225" />
                            <line x1="266" y1="115" x2="266" y2="205" />
                            </g>
                            </svg>
                        </div>

                        <div style="position: relative; z-index: 1;">
                            <!-- Badge -->
                            <div class="d-inline-flex align-items-center px-3 py-1 mb-4"
                                 style="background: rgba(255,255,255,0.06); border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); font-size: 0.72rem; color: #ffffff; font-weight: 600; letter-spacing: 0.5px;">
                                <!-- Yellow Shield Icon with Check -->
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FFC107"
                                     stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="me-2">
                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                                <polyline points="9 11 11 13 15 9" stroke="#FFC107" stroke-width="2.5">
                                </polyline>
                                </svg>
                                SECURE PASSWORD RESET &mdash;
                            </div>

                            <!-- Title & Subtitle -->
                            <h1 class="fw-bold text-white mb-3"
                                style="font-size: 2.25rem; line-height: 1.25; max-width: 400px;">
                                Back to the movies in 3 quick steps.
                            </h1>
                            <p class="text-white-50 mb-5"
                               style="font-size: 0.95rem; line-height: 1.6; max-width: 380px;">
                                We'll email you a one-time code. Once verified, set a new password and you're back
                                to booking.
                            </p>

                            <!-- Benefit Checklist -->
                            <div class="d-flex flex-column gap-3" style="font-size: 0.95rem;">
                                <div class="d-flex align-items-center gap-3">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                         xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" fill="#10b981" />
                                    <path d="M8 12L11 15L16 9" stroke="white" stroke-width="2.5"
                                          stroke-linecap="round" stroke-linejoin="round" />
                                    </svg>
                                    <span class="text-white-50">Codes expire in 15 minutes</span>
                                </div>
                                <div class="d-flex align-items-center gap-3">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                         xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" fill="#10b981" />
                                    <path d="M8 12L11 15L16 9" stroke="white" stroke-width="2.5"
                                          stroke-linecap="round" stroke-linejoin="round" />
                                    </svg>
                                    <span class="text-white-50">Bookings & loyalty points stay intact</span>
                                </div>
                                <div class="d-flex align-items-center gap-3">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                         xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" fill="#10b981" />
                                    <path d="M8 12L11 15L16 9" stroke="white" stroke-width="2.5"
                                          stroke-linecap="round" stroke-linejoin="round" />
                                    </svg>
                                    <span class="text-white-50">End-to-end SSL encryption</span>
                                </div>
                            </div>
                        </div>

                        <!-- Footer statistics (Same layout style as other pages) -->
                        <div class="d-flex align-items-center gap-3" style="position: relative; z-index: 1;">
                            <div class="d-flex">
                                <span class="avatar-circle" style="background: #2563eb; z-index: 4;">NH</span>
                                <span class="avatar-circle"
                                      style="background: #10b981; z-index: 3; margin-left: -8px;">TL</span>
                                <span class="avatar-circle"
                                      style="background: #f59e0b; z-index: 2; margin-left: -8px;">LN</span>
                                <span class="avatar-circle"
                                      style="background: #ef4444; z-index: 1; margin-left: -8px;">PH</span>
                            </div>
                            <div style="font-size: 0.85rem; color: rgba(255,255,255,0.8); line-height: 1.4;">
                                <strong class="text-white">3,400+ customers</strong><br>across HCMC & Hanoi
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
                const resetPasswordForm = document.getElementById('resetPasswordForm');

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

                        bar1.style.backgroundColor = '#e5e7eb';
                        bar2.style.backgroundColor = '#e5e7eb';
                        bar3.style.backgroundColor = '#e5e7eb';

                        if (score === 1) {
                            bar1.style.backgroundColor = '#ef4444'; // Red
                        } else if (score === 2) {
                            bar1.style.backgroundColor = '#f59e0b'; // Orange
                            bar2.style.backgroundColor = '#f59e0b';
                        } else if (score === 3) {
                            bar1.style.backgroundColor = '#10b981'; // Green
                            bar2.style.backgroundColor = '#10b981';
                            bar3.style.backgroundColor = '#10b981';
                        }
                    });
                }

                // Form Validation
                if (resetPasswordForm) {
                    resetPasswordForm.addEventListener('submit', function (e) {
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