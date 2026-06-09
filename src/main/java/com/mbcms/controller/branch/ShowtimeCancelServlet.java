package com.mbcms.controller.branch;

import com.mbcms.service.ShowtimeService;
import com.mbcms.service.impl.ShowtimeServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * ShowtimeCancelServlet - owner: <b>HungNT</b> (UC22 Cancel Showtime).
 *
 * POST /branch/showtimes/cancel (id=N) - huy suat chieu roi redirect ve list (PRG).
 * Chi nhan POST: cancel la hanh dong thay doi du lieu, khong duoc de
 * GET/crawler/prefetch kich hoat. Nut Cancel trong list.jsp la 1 form nho + confirm.
 *
 * Business rule (service): chi huy suat SCHEDULED cua branch minh,
 * va suat CHUA co booking con hieu luc. Notify customers -> module notifications (lam sau).
 */
@WebServlet("/branch/showtimes/cancel")
public class ShowtimeCancelServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        String base = req.getContextPath() + "/branch/showtimes";

        Long id = parseId(req.getParameter("id"));
        if (id == null) {
            resp.sendRedirect(base + "?notFound=1");
            return;
        }

        String result;
        try {
            result = new ShowtimeServiceImpl().cancelShowtime(id, branchId);
        } catch (RuntimeException ex) {
            getServletContext().log("System error while cancelling showtime", ex);
            resp.sendRedirect(base + "?cancelErr=SYSTEM");
            return;
        }

        switch (result) {
            case ShowtimeService.RESULT_OK:
                resp.sendRedirect(base + "?cancelled=1");
                break;
            case ShowtimeService.RESULT_HAS_BOOKINGS:
                resp.sendRedirect(base + "?cancelErr=HAS_BOOKINGS");
                break;
            case ShowtimeService.RESULT_NOT_EDITABLE:
                resp.sendRedirect(base + "?cancelErr=NOT_EDITABLE");
                break;
            case ShowtimeService.RESULT_NOT_FOUND:
            default:
                resp.sendRedirect(base + "?notFound=1");
                break;
        }
    }

    private Long parseId(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
