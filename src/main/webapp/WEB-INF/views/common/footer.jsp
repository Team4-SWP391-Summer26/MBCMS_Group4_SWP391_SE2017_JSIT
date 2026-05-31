<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<footer class="footer-custom mt-5">
    <div class="container">
        <div class="row g-4">
            <!-- Column 1: Logo & Socials -->
            <div class="col-lg-4 col-md-6">
                <div class="d-flex align-items-center mb-3">
                    <!-- Logo SVG -->
                    <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg"
                         style="border-radius: 8px;">
                        <rect width="32" height="32" rx="8" fill="#182c54" />
                        <!-- film strip dots -->
                        <rect x="4" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <rect x="11" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <rect x="18" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <rect x="25" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <rect x="4" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <rect x="11" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <rect x="18" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <rect x="25" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                        <!-- play triangle -->
                        <path d="M13 11V21L21 16L13 11Z" fill="#FFC107" />
                    </svg>
                    <span class="ms-2 fw-bold text-white" style="font-size: 1.35rem; letter-spacing: -0.5px;">MBCMS</span>
                </div>
                <p class="mb-4 text-secondary" style="line-height: 1.6; max-width: 320px;">
                    Vietnam's multi-branch cinema booking platform. Pick your seat, grab some popcorn, and earn points on every visit.
                </p>
                <div class="mb-4">
                    <a href="#" class="social-icon" title="Facebook">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"></path></svg>
                    </a>
                    <a href="#" class="social-icon" title="Instagram">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line></svg>
                    </a>
                    <a href="#" class="social-icon" title="YouTube">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22.54 6.42a2.78 2.78 0 0 0-1.94-2C18.88 4 12 4 12 4s-6.88 0-8.6.46a2.78 2.78 0 0 0-1.94 2A29 29 0 0 0 1 11.75a29 29 0 0 0 .46 5.33A2.78 2.78 0 0 0 3.4 19c1.72.46 8.6.46 8.6.46s6.88 0 8.6-.46a2.78 2.78 0 0 0 1.94-2 29 29 0 0 0 .46-5.25 29 29 0 0 0-.46-5.33z"></path><polygon points="9.75 15.02 15.5 11.75 9.75 8.48 9.75 15.02"></polygon></svg>
                    </a>
                    <a href="#" class="social-icon" title="TikTok">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12a4 4 0 1 0 4 4V4a5 5 0 0 0 5 5"></path></svg>
                    </a>
                </div>
            </div>

            <!-- Column 2: Browse -->
            <div class="col-lg-2 col-md-6 col-6">
                <h5>Browse</h5>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Now Showing</a></li>
                    <li><a href="${pageContext.request.contextPath}/movies?status=UPCOMING">Coming Soon</a></li>
                    <li><a href="#">Cinemas</a></li>
                    <li><a href="#">Promotions</a></li>
                </ul>
            </div>

            <!-- Column 3: Account -->
            <div class="col-lg-2 col-md-6 col-6">
                <h5>Account</h5>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/customer/bookings">My Bookings</a></li>
                    <li><a href="#">Membership</a></li>
                    <li><a href="${pageContext.request.contextPath}/customer/profile">Profile</a></li>
                    <li><a href="#">Notifications</a></li>
                    <li><a href="#">Help Center</a></li>
                </ul>
            </div>

            <!-- Column 4: Contact -->
            <div class="col-lg-4 col-md-6">
                <h5>Get In Touch</h5>

                <div class="contact-item">
                    <div class="contact-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                    </div>
                    <div class="contact-info">
                        <div class="contact-title">Headquarters</div>
                        <div class="text-secondary">Khu Giáo dục và Đào tạo - Khu Công nghệ cao Hòa Lạc, Km29 Đại lộ Thăng Long, Thạch Thất, Hà Nội</div>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                    </div>
                    <div class="contact-info">
                        <div class="contact-title">Customer support</div>
                        <div class="text-secondary">0981583316 &middot; Daily 8:00 &ndash; 23:00</div>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                    </div>
                    <div class="contact-info">
                        <div class="contact-title">Email</div>
                        <div><a href="mailto:group4mbcms@gmail.com" class="text-secondary hover-white">group4mbcms@gmail.com</a></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bottom Bar -->
        <div class="bottom-bar flex-column flex-md-row gap-3">
            <div class="mb-3 mb-md-0 text-secondary" style="font-size: 0.85rem;">
                <span>&copy; 2026 MBCMS. All rights reserved.</span>
                <span class="mx-2">&middot;</span>
                <a href="#" class="text-secondary hover-white text-decoration-none">Terms</a>
                <span class="mx-1">&middot;</span>
                <a href="#" class="text-secondary hover-white text-decoration-none">Privacy</a>
                <span class="mx-1">&middot;</span>
                <a href="#" class="text-secondary hover-white text-decoration-none">Cookies</a>
            </div>

            <div class="d-flex align-items-center flex-wrap gap-3">
                <span class="text-secondary" style="font-size: 0.85rem;">We accept</span>
                <div class="payment-badges">
                    <span class="payment-badge badge-vnpay">VNPAY</span>
                    <span class="payment-badge badge-momo">MoMo</span>
                    <span class="payment-badge badge-visa">VISA</span>
                    <span class="payment-badge badge-mc">MC</span>
                </div>
                <div class="language-select">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="2" y1="12" x2="22" y2="12"></line>
                        <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
                    </svg>
                    <span>EN</span>
                </div>
            </div>
        </div>
    </div>
</footer>
