<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link href="${pageContext.request.contextPath}/assets/css/footer.css?v=${applicationScope.assetVersion}" rel="stylesheet">

<footer class="footer-custom">

    <div class="container public-shell">

        <div class="footer-top-grid">

            <div class="footer-brand-block">

                <div class="footer-brand-row">

                    <a class="lc-brand-link lc-brand-link--footer" href="${pageContext.request.contextPath}/home">

                        <img src="${pageContext.request.contextPath}/assets/img/logo.png"

                             alt="PentaPlex"

                             class="lc-brand-logo lc-brand-logo--footer"

                             width="160"

                             height="32"

                             decoding="async">

                    </a>

                </div>

                <p class="footer-desc">

                    Book films, pick your seats, and check in at PentaPlex branches across Vietnam.

                </p>

                <div class="footer-locations" aria-label="Branch cities">

                    <span><span class="loc-dot" aria-hidden="true"></span>Hanoi</span>

                    <span><span class="loc-dot" aria-hidden="true"></span>Ho Chi Minh City</span>

                </div>



            </div>



            <div class="footer-nav-col">

                <h5>Browse</h5>

                <ul class="footer-links">

                    <li><a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Now Showing</a></li>

                    <li><a href="${pageContext.request.contextPath}/movies?status=UPCOMING">Coming Soon</a></li>

                    <li><a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Showtimes</a></li>

                    <li><a href="" class="lc-disabled-link" aria-disabled="true">Support</a></li>

                </ul>

            </div>



            <div class="footer-nav-col">

                <h5>Account</h5>

                <ul class="footer-links">

                    <li><a href="${pageContext.request.contextPath}/customer/booking/history">My Bookings</a></li>

                    <li><a href="${pageContext.request.contextPath}/customer/profile">Profile</a></li>

                    <li><a href="${pageContext.request.contextPath}/customer/notifications">Notifications</a></li>

                    <li><a href="" class="lc-disabled-link" aria-disabled="true">Help Center</a></li>

                </ul>

            </div>



            <div class="footer-contact-block">

                <h5>Get In Touch</h5>



                <div class="contact-item">

                    <div class="contact-icon"><i class="bi bi-geo-alt"></i></div>

                    <div class="contact-info">

                        <div class="contact-title">Headquarters</div>

                        <div class="contact-text">Hoa Lac Hi-Tech Park, Km29 Thang Long Blvd, Thach That, Hanoi</div>

                    </div>

                </div>



                <div class="contact-item">

                    <div class="contact-icon"><i class="bi bi-telephone"></i></div>

                    <div class="contact-info">

                        <div class="contact-title">Customer support</div>

                        <div class="contact-text">0981583316 &middot; Daily 8:00 &ndash; 23:00</div>

                    </div>

                </div>



                <div class="contact-item">

                    <div class="contact-icon"><i class="bi bi-envelope"></i></div>

                    <div class="contact-info">

                        <div class="contact-title">Email</div>

                        <div><a href="mailto:group4mbcms@gmail.com" class="contact-link">group4mbcms@gmail.com</a></div>

                    </div>

                </div>

            </div>

        </div>



        <div class="bottom-bar">

            <div class="bottom-copy">

                <span>&copy; 2026 PentaPlex. All rights reserved.</span>



            </div>



            <div class="bottom-actions">

                <span class="accept-label">We accept</span>

                <img src="${pageContext.request.contextPath}/assets/img/vnpay-logo.png" alt="VNPAY" height="28" style="object-fit: contain; margin-left: 8px; vertical-align: middle; border-radius: 2px;">

                <div class="language-select" role="button" tabindex="0" aria-label="Language">

                    <i class="bi bi-globe2"></i>

                    <span>EN</span>

                </div>

            </div>

        </div>

    </div>

</footer>

