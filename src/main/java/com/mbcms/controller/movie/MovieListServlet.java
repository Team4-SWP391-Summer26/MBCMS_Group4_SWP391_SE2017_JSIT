package com.mbcms.controller.movie;

import com.mbcms.model.Branch;
import com.mbcms.model.Genre;
import com.mbcms.model.Movie;
import com.mbcms.service.GuestMovieService;
import com.mbcms.service.impl.GuestMovieServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * MovieListServlet - owner: AnhND.
 *
 * URL: /movies
 * Chức năng:
 * - Browse movies: /movies?status=NOW_SHOWING hoặc /movies?status=UPCOMING
 * - Search movies: /movies?q=ten-phim
 * - Filter movies: /movies?genre=Action&language=English&branchId=1&status=NOW_SHOWING
 * - Sort movies: /movies?sort=title_asc
 */
@WebServlet("/movies")
public class MovieListServlet extends HttpServlet {

    private final GuestMovieService guestMovieService = new GuestMovieServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Lấy parameter từ URL/form filter.
        String status = clean(req.getParameter("status"));
        String keyword = clean(req.getParameter("q"));
        String genre = clean(req.getParameter("genre"));
        String language = clean(req.getParameter("language"));
        Long branchId = parseLong(req.getParameter("branchId"));
        String sort = clean(req.getParameter("sort"));

        // 2. Nếu user bấm menu Movies mà không truyền filter nào -> mặc định hiện phim đang chiếu.
        if (status == null && keyword == null && genre == null && language == null && branchId == null) {
            status = "NOW_SHOWING";
        }

        // 3. Gọi Service. Service sẽ validate input rồi gọi DAO xuống database.
        List<Movie> movies = guestMovieService.browseMovies(status, keyword, genre, language, branchId, sort);
        List<Genre> genres = guestMovieService.getGenres();
        List<String> languages = guestMovieService.getLanguages();
        List<Branch> branches = guestMovieService.getBranches();

        // 4. Đẩy dữ liệu sang JSP để hiển thị.
        req.setAttribute("movies", movies);
        req.setAttribute("genres", genres);
        req.setAttribute("languages", languages);
        req.setAttribute("branches", branches);

        // Giữ lại giá trị filter user đã chọn để form không bị mất trạng thái sau khi submit.
        req.setAttribute("selectedStatus", status);
        req.setAttribute("keyword", keyword);
        req.setAttribute("selectedGenre", genre);
        req.setAttribute("selectedLanguage", language);
        req.setAttribute("selectedBranchId", branchId);
        req.setAttribute("selectedSort", sort == null ? "release_desc" : sort);

        req.getRequestDispatcher("/WEB-INF/views/movie/list.jsp").forward(req, resp);
    }

    private String clean(String value) {
        if (value == null) {
            return null;
        }
        value = value.trim();
        return value.isEmpty() ? null : value;
    }

    private Long parseLong(String value) {
        value = clean(value);
        if (value == null) {
            return null;
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}