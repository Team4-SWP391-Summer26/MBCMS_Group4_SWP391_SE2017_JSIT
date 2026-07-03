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
 * POST /branch/showtimes/cancel (id=N) - huy suat chieu roi redirect ve list
 * (PRG). Chi nhan POST: cancel la hanh dong thay doi du lieu, khong duoc de
 * GET/crawler/prefetch kich hoat. Nut Cancel trong list.jsp la 1 form nho +
 * confirm.
 *
 * Business rule (service): chi huy suat SCHEDULED cua branch minh, va suat CHUA
 * co booking con hieu luc. Notify customers -> module notifications (lam sau).
 */
@WebServlet("/branch/showtimes/cancel")
public class ShowtimeCancelServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        Long id = parseId(req.getParameter("id"));
        if (id == null) {
            resp.sendRedirect(buildListRedirect(req, "notFound", null));
            return;
        }

        String result;
        try {
            result = new ShowtimeServiceImpl().cancelShowtime(id, branchId);
        } catch (RuntimeException ex) {
            getServletContext().log("System error while cancelling showtime", ex);
            resp.sendRedirect(buildListRedirect(req, "cancelErr=SYSTEM", "showtime-" + id));
            return;
        }

        switch (result) {
            case ShowtimeService.RESULT_OK:
                resp.sendRedirect(buildListRedirect(req, "cancelled", "showtime-list"));
                break;
            case ShowtimeService.RESULT_HAS_BOOKINGS:
                resp.sendRedirect(buildListRedirect(req, "cancelErr=HAS_BOOKINGS", "showtime-" + id));
                break;
            case ShowtimeService.RESULT_NOT_EDITABLE:
                resp.sendRedirect(buildListRedirect(req, "cancelErr=NOT_EDITABLE", "showtime-" + id));
                break;
            case ShowtimeService.RESULT_NOT_FOUND:
            default:
                resp.sendRedirect(buildListRedirect(req, "notFound", null));
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

    private String buildListRedirect(HttpServletRequest req, String param, String fragment) {
        StringBuilder url = new StringBuilder(req.getContextPath()).append("/branch/showtimes?");
        String date = req.getParameter("returnDate");
        if (isIsoDate(date)) {
            url.append("date=").append(date.trim()).append("&");
        }
        if (param.contains("=")) {
            url.append(param);
        } else {
            url.append(param).append("=1");
        }
        if (fragment != null && !fragment.trim().isEmpty()) {
            url.append("#").append(fragment);
        }
        return url.toString();
    }

    private boolean isIsoDate(String value) {
        return value != null && value.trim().matches("\\d{4}-\\d{2}-\\d{2}");
    }
}
