package com.mbcms.controller.branch;

import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Showtime;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * DashboardServlet - Branch Manager Dashboard (owner: HungNT).
 * Layout theo man "29_manager-dashboard" cua Frontend demo prototype.
 *
 * PHAM VI: chi hien du lieu SHOWTIME (phan cua HungNT). Cac so lieu
 * revenue/chart/top-movies thuoc module Reports (AnhND) va occupancy
 * (AnhPQ) - dashboard de san cho trong, KHONG fake so lieu.
 */
@WebServlet("/branch/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/dashboard.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req);

        ShowtimeDAO showtimeDAO = new ShowtimeDAOImpl();
        LocalDate today = LocalDate.now();

        // Suat chieu HOM NAY cua branch (bang chinh tren dashboard)
        List<Showtime> todayShowtimes = showtimeDAO.findByBranch(branchId, null, null, today);

        // KPI tu du lieu showtime co san
        int seatsSoldToday = 0;
        for (Showtime st : todayShowtimes) {
            seatsSoldToday += st.getBookedSeats();
        }
        // Dem suat SCHEDULED trong 7 ngay toi (gom hom nay)
        int weekCount = 0;
        for (Showtime st : showtimeDAO.findByBranch(branchId, null, null, null)) {
            LocalDate d = st.getStartTime().toLocalDate();
            if (Showtime.STATUS_SCHEDULED.equals(st.getStatus())
                    && !d.isBefore(today) && d.isBefore(today.plusDays(7))) {
                weekCount++;
            }
        }

        req.setAttribute("todayShowtimes", todayShowtimes);
        req.setAttribute("kpiTodayCount", todayShowtimes.size());
        req.setAttribute("kpiSeatsSold", seatsSoldToday);
        req.setAttribute("kpiWeekCount", weekCount);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
