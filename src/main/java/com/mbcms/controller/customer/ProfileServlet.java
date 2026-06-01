package com.mbcms.controller.customer;

import com.mbcms.model.Customer;
import com.mbcms.service.ProfileService;
import com.mbcms.service.impl.ProfileServiceImpl;
import com.mbcms.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * ProfileServlet - owner: <b>HungNT</b> (UC12 View/Update Profile).
 *
 * GET  /customer/profile  -> show the profile.
 * POST /customer/profile  -> update personal information.
 *
 * Lives under /customer/* so AuthFilter already guarantees the user is logged in.
 * Change password is a separate feature at /auth/change-password (not handled here).
 */
@WebServlet("/customer/profile")
public class ProfileServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/customer/profile.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (currentCustomer(req) == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = currentCustomer(req);
        if (customer == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            handleUpdateProfile(req, customer);
        } catch (RuntimeException ex) {
            // System error (DB...) - log on the server, don't leak details to the UI.
            getServletContext().log("System error while updating profile", ex);
            req.setAttribute("errorMsg", "System error, please try again later.");
        }
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    /** Update personal information. */
    private void handleUpdateProfile(HttpServletRequest req, Customer customer) {
        String fullName = trim(req.getParameter("fullName"));
        String phone    = trim(req.getParameter("phone"));
        String dobStr   = trim(req.getParameter("dateOfBirth"));
        String address  = trim(req.getParameter("address"));

        // --- Validate ---
        if (ValidationUtil.isNullOrEmpty(fullName) || fullName.length() < 2 || fullName.length() > 100) {
            req.setAttribute("errorMsg", "Full name must be 2 to 100 characters.");
            return;
        }
        if (!ValidationUtil.isNullOrEmpty(phone) && !ValidationUtil.isValidPhone(phone)) {
            req.setAttribute("errorMsg", "Invalid phone number (e.g. 0901234567).");
            return;
        }
        LocalDate dob = null;
        if (!ValidationUtil.isNullOrEmpty(dobStr)) {
            try {
                dob = LocalDate.parse(dobStr); // yyyy-MM-dd from the date input
            } catch (DateTimeParseException e) {
                req.setAttribute("errorMsg", "Invalid date of birth.");
                return;
            }
            if (dob.isAfter(LocalDate.now().minusYears(13))) {
                req.setAttribute("errorMsg", "You must be at least 13 years old.");
                return;
            }
        }
        if (address != null && address.length() > 200) {
            req.setAttribute("errorMsg", "Address must be at most 200 characters.");
            return;
        }

        // --- Apply changes (username/email stay read-only) ---
        customer.setFullName(fullName);
        customer.setPhone(ValidationUtil.isNullOrEmpty(phone) ? null : phone);
        customer.setDateOfBirth(dob);
        customer.setAddress(ValidationUtil.isNullOrEmpty(address) ? null : address);

        ProfileService profileService = new ProfileServiceImpl();
        if (profileService.updateProfile(customer)) {
            // Session currentUser is updated (same object) -> header shows the new name.
            req.setAttribute("successMsg", "Profile updated successfully.");
        } else {
            req.setAttribute("errorMsg", "Could not update profile, please try again.");
        }
    }

    /** Get the logged-in Customer from session; null if not a Customer. */
    private Customer currentCustomer(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        Object principal = (session != null) ? session.getAttribute("currentUser") : null;
        return (principal instanceof Customer) ? (Customer) principal : null;
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
