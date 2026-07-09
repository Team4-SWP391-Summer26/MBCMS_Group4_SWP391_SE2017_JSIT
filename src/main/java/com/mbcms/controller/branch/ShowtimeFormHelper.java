package com.mbcms.controller.branch;

import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;
import com.mbcms.util.DateTimeUtil;
import com.mbcms.util.ValidationUtil;
import jakarta.servlet.http.HttpServletRequest;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.Arrays;

/**
 * ShowtimeFormHelper - parse + validate form showtime, dung chung cho Create
 * (UC20) va Edit (UC21) de khong lap lai validation. Owner: HungNT. SRS 3.5.2.2
 * Showtime Details Screen.
 */
final class ShowtimeFormHelper {

    // SRS 3.5.2.2: Base Price range 10,000 - 500,000 VND
    private static final BigDecimal PRICE_MIN = new BigDecimal("10000");
    private static final BigDecimal PRICE_MAX = new BigDecimal("500000");

    private ShowtimeFormHelper() {
    }

    /**
     * Doc params tu form, validate, va do vao {@code target} (movieId, roomId,
     * startTime, endTime tu tinh, basePrice, format, subtitleType).
     *
     * @return null neu hop le; nguoc lai tra ve thong bao loi de hien len form.
     */
    static String populate(HttpServletRequest req, Showtime target, long branchId) {
        String movieIdStr = trim(req.getParameter("movieId"));
        String roomIdStr = trim(req.getParameter("roomId"));
        String dateStr = trim(req.getParameter("date"));
        String timeStr = trim(req.getParameter("startTime"));
        String priceStr = trim(req.getParameter("basePrice"));
        String format = trim(req.getParameter("format"));
        String subtitleType = trim(req.getParameter("subtitleType"));

        // --- Required (MSG02) ---
        if (ValidationUtil.isNullOrEmpty(movieIdStr) || ValidationUtil.isNullOrEmpty(roomIdStr)
                || ValidationUtil.isNullOrEmpty(dateStr) || ValidationUtil.isNullOrEmpty(timeStr)
                || ValidationUtil.isNullOrEmpty(priceStr) || ValidationUtil.isNullOrEmpty(format)
                || ValidationUtil.isNullOrEmpty(subtitleType)) {
            return "The * field is required.";
        }

        // --- Movie: phai ton tai va active (dropdown chi hien phim active) ---
        long movieId;
        try {
            movieId = Long.parseLong(movieIdStr);
        } catch (NumberFormatException e) {
            return "Invalid movie.";
        }
        MovieDAO movieDAO = new MovieDAOImpl();
        Movie movie = movieDAO.findById(movieId);
        if (movie == null || !movie.isActive()) {
            return "Invalid movie.";
        }
        // Chi phim dang chieu (NOW_SHOWING) moi duoc xep lich.
        if ("ENDED".equals(movie.getStatus())) {
            return "This movie has ended and can no longer be scheduled.";
        }
        if ("UPCOMING".equals(movie.getStatus())) {
            return "This movie has not been released yet and cannot be scheduled.";
        }
        // Phim phai DA DUOC Admin cap cho chi nhanh nay (movie_branch). Chong tampering:
        // movieId gui tu form co the bi sua tay sang phim chua cap cho rap minh.
        if (!movieDAO.isAssignedToBranch(movieId, branchId)) {
            return "This movie is not available at your branch.";
        }

        long roomId;
        try {
            roomId = Long.parseLong(roomIdStr);
        } catch (NumberFormatException e) {
            return "Invalid room.";
        }

        // --- Start time: hop le + phai o tuong lai ---
        LocalDateTime startTime;
        try {
            startTime = LocalDateTime.of(LocalDate.parse(dateStr), LocalTime.parse(timeStr));
        } catch (DateTimeParseException e) {
            return "Invalid date or start time.";
        }
        // So voi gio Viet Nam (start_time nhap theo gio VN) - khong phu thuoc tz cua server.
        if (!startTime.isAfter(DateTimeUtil.nowVietnam())) {
            return "Start time must be in the future.";
        }

        // --- End time: 2 che do ---
        // AUTO (mac dinh): end = start + duration_min (server tu tinh, khong tin client).
        // CUSTOM: manager tu nhap gio ket thuc cho suat dac biet (premiere/Q&A) - van VALIDATE o server.
        LocalDateTime autoEnd = startTime.plusMinutes(movie.getDurationMin());
        LocalDateTime endTime;
        String endMode = trim(req.getParameter("endMode"));
        if ("custom".equals(endMode)) {
            String endTimeStr = trim(req.getParameter("endTime"));
            if (ValidationUtil.isNullOrEmpty(endTimeStr)) {
                return "Please enter a custom end time.";
            }
            LocalTime endLocalTime;
            try {
                endLocalTime = LocalTime.parse(endTimeStr);
            } catch (DateTimeParseException e) {
                return "Invalid end time.";
            }
            // Cung ngay voi start; neu khong sau start (vd suat dem qua nua dem) -> +1 ngay.
            endTime = LocalDateTime.of(startTime.toLocalDate(), endLocalTime);
            if (!endTime.isAfter(startTime)) {
                endTime = endTime.plusDays(1);
            }
            // Khong duoc ngan hon thoi luong phim (phim phai chieu het).
            if (endTime.isBefore(autoEnd)) {
                return "End time must be at least the movie duration ("
                        + movie.getDurationMin() + " min) after start.";
            }
            // Chan slot phi ly (toi da 12 gio).
            if (endTime.isAfter(startTime.plusHours(12))) {
                return "Showtime slot is too long (max 12 hours). Please check the end time.";
            }
        } else {
            endTime = autoEnd;
        }

        // --- Base price: 10,000 - 500,000 VND ---
        // Chi nhan so nguyen (VND khong co don vi le); chan "10000.5", "1e5", so am...
        if (!priceStr.matches("\\d+")) {
            return "Base price must be a whole number in VND.";
        }
        BigDecimal basePrice;
        try {
            basePrice = new BigDecimal(priceStr);
        } catch (NumberFormatException e) {
            return "Invalid base price.";
        }
        if (basePrice.compareTo(PRICE_MIN) < 0 || basePrice.compareTo(PRICE_MAX) > 0) {
            return "Base price must be between 10,000 and 500,000 VND.";
        }

        // --- Enum whitelist ---
        if (!Arrays.asList("2D", "3D", "IMAX").contains(format)) {
            return "Invalid format.";
        }
        if (!Arrays.asList("SUB", "DUB", "ORIGINAL").contains(subtitleType)) {
            return "Invalid subtitle type.";
        }

        target.setMovieId(movieId);
        target.setRoomId(roomId);
        target.setStartTime(startTime);
        target.setEndTime(endTime);
        target.setBasePrice(basePrice);
        target.setFormat(format);
        target.setSubtitleType(subtitleType);
        return null;
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }
}
