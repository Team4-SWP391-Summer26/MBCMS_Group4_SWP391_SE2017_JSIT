package com.mbcms.controller.branch;

import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;
import com.mbcms.util.ValidationUtil;
import jakarta.servlet.http.HttpServletRequest;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.Arrays;

/**
 * ShowtimeFormHelper - parse + validate form showtime, dung chung cho
 * Create (UC20) va Edit (UC21) de khong lap lai validation.
 * Owner: HungNT. SRS 3.5.2.2 Showtime Details Screen.
 */
final class ShowtimeFormHelper {

    // SRS 3.5.2.2: Base Price range 10,000 - 500,000 VND
    private static final BigDecimal PRICE_MIN = new BigDecimal("10000");
    private static final BigDecimal PRICE_MAX = new BigDecimal("500000");

    private ShowtimeFormHelper() {}

    /**
     * Doc params tu form, validate, va do vao {@code target}
     * (movieId, roomId, startTime, endTime tu tinh, basePrice, format, subtitleType).
     *
     * @return null neu hop le; nguoc lai tra ve thong bao loi de hien len form.
     */
    static String populate(HttpServletRequest req, Showtime target) {
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
        // Khong xep lich cho phim da ket thuc chieu (movie_status = ENDED).
        // Chi phim UPCOMING / NOW_SHOWING moi co the len lich.
        if ("ENDED".equals(movie.getStatus())) {
            return "This movie has ended and can no longer be scheduled.";
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
        if (!startTime.isAfter(LocalDateTime.now())) {
            return "Start time must be in the future.";
        }

        // --- End time: TINH O SERVER, khong tin client (SRS: auto = start + duration_min) ---
        LocalDateTime endTime = startTime.plusMinutes(movie.getDurationMin());

        // --- Base price: 10,000 - 500,000 VND ---
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
