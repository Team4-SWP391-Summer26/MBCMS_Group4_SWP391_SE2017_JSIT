package com.mbcms.controller.branch;

import com.mbcms.model.Branch;
import com.mbcms.service.BranchService;
import com.mbcms.service.impl.BranchServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

@WebServlet("/branch/hours")
public class BranchHoursServlet extends HttpServlet {

    private final BranchService branchService = new BranchServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        Long branchId = (session != null) ? (Long) session.getAttribute("currentBranchId") : null;
        
        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý chi nhánh nào.");
            return;
        }

        Branch branch = branchService.getBranchById(branchId);
        req.setAttribute("branch", branch);
        
        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));

        req.getRequestDispatcher("/WEB-INF/views/branch/hours.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        Long branchId = (session != null) ? (Long) session.getAttribute("currentBranchId") : null;

        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý chi nhánh.");
            return;
        }

        String openStr = req.getParameter("openingTime");
        String closeStr = req.getParameter("closingTime");

        try {
            LocalTime open = LocalTime.parse(openStr);
            LocalTime close = LocalTime.parse(closeStr);

            boolean success = branchService.updateOperatingHours(branchId, open, close);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/branch/hours?successMsg=" + java.net.URLEncoder.encode("Cập nhật giờ hoạt động thành công!", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/hours?errorMsg=" + java.net.URLEncoder.encode("Cập nhật giờ hoạt động thất bại.", "UTF-8"));
            }
        } catch (DateTimeParseException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/hours?errorMsg=" + java.net.URLEncoder.encode("Định dạng thời gian không hợp lệ.", "UTF-8"));
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/hours?errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Lỗi trong BranchHoursServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/branch/hours?errorMsg=Đã xảy ra lỗi hệ thống.");
        }
    }
}
