package com.mbcms.controller.admin;

import com.mbcms.model.Movie;
import com.mbcms.service.MovieAdminService;
import com.mbcms.service.impl.MovieAdminServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashSet;
import java.util.Set;

/**
 * AdminMovieServlet - quan ly phim (Add / Edit / Delete / Upload poster-trailer /
 * Manage movie status). Dung @MultipartConfig de nhan file poster.
 *
 * Luu y CSRF: form multipart truyen _csrf qua QUERY STRING (action="...?_csrf=..")
 * vi CsrfFilter doc getParameter("_csrf") truoc khi servlet phan tich phan body.
 * Query param luon co san nen filter van xac thuc duoc.
 */
@WebServlet({"/admin/movies"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,        // 1 MB
        maxFileSize = 5L * 1024 * 1024,         // 5 MB / file
        maxRequestSize = 10L * 1024 * 1024      // 10 MB / request
)
public class AdminMovieServlet extends HttpServlet {

    private static final String POSTER_DIR = "/assets/img/posters/";
    private static final Set<String> ALLOWED_EXT = Set.of("jpg", "jpeg", "png", "webp", "gif");

    private final MovieAdminService movieService = new MovieAdminServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        try {
            if ("add".equals(action)) {
                showForm(req, resp, null);
            } else if ("edit".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));
                Movie movie = movieService.get(id);
                if (movie == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/movies?errorMsg="
                            + enc("Movie not found."));
                    return;
                }
                showForm(req, resp, movie);
            } else {
                showList(req, resp);
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/movies?errorMsg=" + enc("Invalid parameter."));
        } catch (Exception e) {
            getServletContext().log("Error in AdminMovieServlet#doGet: ", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading movie data.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/movies?errorMsg=" + enc("Invalid action."));
            return;
        }

        try {
            switch (action) {
                case "add":
                    handleSave(req, resp, false);
                    break;
                case "edit":
                    handleSave(req, resp, true);
                    break;
                case "delete":
                    handleDelete(req, resp);
                    break;
                case "changeStatus":
                    handleChangeStatus(req, resp);
                    break;
                case "toggleActive":
                    handleToggleActive(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/movies?errorMsg=" + enc("Unknown action."));
            }
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/movies?errorMsg=" + enc(e.getMessage()));
        } catch (Exception e) {
            getServletContext().log("Error in AdminMovieServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/admin/movies?errorMsg=" + enc("A system error occurred."));
        }
    }

    // ── GET handlers ───────────────────────────────────────────────────

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("q");
        String status = req.getParameter("status");
        req.setAttribute("movies", movieService.list(keyword, status));
        req.setAttribute("q", keyword);
        req.setAttribute("statusFilter", status);
        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));
        req.getRequestDispatcher("/WEB-INF/views/admin/movies.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Movie movie)
            throws ServletException, IOException {
        req.setAttribute("movie", movie);
        req.setAttribute("allGenres", movieService.allGenres());
        req.setAttribute("allLanguages", movieService.allLanguages());
        req.setAttribute("selectedGenreIds",
                movie == null ? new HashSet<Integer>() : movieService.getGenreIds(movie.getMovieId()));
        req.getRequestDispatcher("/WEB-INF/views/admin/movie_form.jsp").forward(req, resp);
    }

    // ── POST handlers ──────────────────────────────────────────────────

    private void handleSave(HttpServletRequest req, HttpServletResponse resp, boolean isEdit)
            throws Exception {
        Movie m = new Movie();
        if (isEdit) {
            m.setMovieId(Long.parseLong(req.getParameter("movieId")));
        }
        m.setTitle(trim(req.getParameter("title")));
        m.setDescription(trim(req.getParameter("description")));
        m.setDurationMin(parseIntSafe(req.getParameter("durationMin")));
        m.setDirector(trim(req.getParameter("director")));
        m.setCastList(trim(req.getParameter("castList")));
        m.setLanguage(trim(req.getParameter("language")));
        m.setCountry(trim(req.getParameter("country")));
        m.setRated(blankToNull(req.getParameter("rated")));
        m.setTrailerUrl(trim(req.getParameter("trailerUrl")));
        m.setReleaseDate(parseDate(req.getParameter("releaseDate")));
        m.setStatus(req.getParameter("status"));
        m.setActive("true".equalsIgnoreCase(req.getParameter("active")));

        // Poster: uu tien file moi upload, neu khong giu poster cu (edit).
        String poster = savePosterIfPresent(req);
        if (poster != null) {
            m.setPosterUrl(poster);
        } else {
            m.setPosterUrl(blankToNull(req.getParameter("currentPoster")));
        }

        Set<Integer> genreIds = parseGenreIds(req);

        if (isEdit) {
            movieService.update(m, genreIds);
            resp.sendRedirect(req.getContextPath() + "/admin/movies?successMsg="
                    + enc("Movie updated successfully!"));
        } else {
            movieService.create(m, genreIds);
            resp.sendRedirect(req.getContextPath() + "/admin/movies?successMsg="
                    + enc("Movie added successfully!"));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = Long.parseLong(req.getParameter("movieId"));
        movieService.delete(id);
        resp.sendRedirect(req.getContextPath() + "/admin/movies?successMsg=" + enc("Movie deleted successfully!"));
    }

    private void handleChangeStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = Long.parseLong(req.getParameter("movieId"));
        String status = req.getParameter("status");
        movieService.changeStatus(id, status);
        resp.sendRedirect(req.getContextPath() + "/admin/movies?successMsg=" + enc("Movie status updated!"));
    }

    private void handleToggleActive(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = Long.parseLong(req.getParameter("movieId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));
        movieService.setActive(id, active);
        String msg = active ? "Movie is visible again!" : "Movie has been hidden from the catalog!";
        resp.sendRedirect(req.getContextPath() + "/admin/movies?successMsg=" + enc(msg));
    }

    // ── helpers ────────────────────────────────────────────────────────

    /**
     * Luu poster neu co file moi. Tra ve duong dan web (/assets/img/posters/..),
     * null neu khong co file upload. Nem IllegalArgumentException neu sai dinh dang.
     */
    private String savePosterIfPresent(HttpServletRequest req) throws IOException, ServletException {
        Part part = req.getPart("poster");
        if (part == null || part.getSize() == 0) {
            return null;
        }
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.isBlank()) {
            return null;
        }
        String ext = extensionOf(submitted);
        if (!ALLOWED_EXT.contains(ext)) {
            throw new IllegalArgumentException("Poster must be an image file (jpg, png, webp, gif).");
        }

        String realDir = getServletContext().getRealPath(POSTER_DIR);
        if (realDir == null) {
            throw new IllegalArgumentException("The server does not support saving poster files.");
        }
        File dir = new File(realDir);
        if (!dir.exists() && !dir.mkdirs()) {
            throw new IllegalArgumentException("Could not create the poster upload directory.");
        }

        String fileName = "movie_" + System.currentTimeMillis() + "." + ext;
        Path target = dir.toPath().resolve(fileName);
        try (var in = part.getInputStream()) {
            Files.copy(in, target);
        }
        return POSTER_DIR + fileName;
    }

    private Set<Integer> parseGenreIds(HttpServletRequest req) {
        Set<Integer> ids = new HashSet<>();
        String[] values = req.getParameterValues("genreIds");
        if (values != null) {
            for (String v : values) {
                try {
                    ids.add(Integer.parseInt(v));
                } catch (NumberFormatException ignore) {
                    // bo qua gia tri rac
                }
            }
        }
        return ids;
    }

    private String extensionOf(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot >= 0 ? fileName.substring(dot + 1).toLowerCase() : "";
    }

    private int parseIntSafe(String s) {
        try {
            return Integer.parseInt(s == null ? "" : s.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Duration must be a valid integer.");
        }
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(s.trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid release date.");
        }
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }

    private String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }

    private String enc(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
    }
}
