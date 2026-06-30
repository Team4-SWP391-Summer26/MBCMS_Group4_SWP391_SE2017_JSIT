package com.mbcms.service.impl;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.GuestMovieDAO;
import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.dao.impl.GuestMovieDAOImpl;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.model.Branch;
import com.mbcms.model.Genre;
import com.mbcms.model.Movie;
import com.mbcms.service.GuestMovieService;

import java.util.List;

/**
 * GuestMovieServiceImpl - owner: AnhND.
 *
 * Business logic cho 4 chức năng:
 * Browse movies / View movie details / Search movies / Filter movies.
 */
public class GuestMovieServiceImpl implements GuestMovieService {

    private final GuestMovieDAO guestMovieDAO;
    private final MovieDAO movieDAO;
    private final BranchDAO branchDAO;

    public GuestMovieServiceImpl() {
        this.guestMovieDAO = new GuestMovieDAOImpl();
        this.movieDAO = new MovieDAOImpl();
        this.branchDAO = new BranchDAOImpl();
    }

    public GuestMovieServiceImpl(GuestMovieDAO guestMovieDAO, MovieDAO movieDAO, BranchDAO branchDAO) {
        this.guestMovieDAO = guestMovieDAO;
        this.movieDAO = movieDAO;
        this.branchDAO = branchDAO;
    }

    @Override
    public List<Movie> browseMovies(String status,
                                    String keyword,
                                    String genre,
                                    String language,
                                    Long branchId,
                                    String sort) {
        // Clean input trước khi đưa xuống DAO.
        status = normalizeStatus(status);
        keyword = clean(keyword);
        genre = clean(genre);
        language = clean(language);
        sort = normalizeSort(sort);

        // Nếu branchId <= 0 thì coi như không lọc branch.
        if (branchId != null && branchId <= 0) {
            branchId = null;
        }

        return guestMovieDAO.findMoviesForGuest(status, keyword, genre, language, branchId, sort);
    }

    @Override
    public Movie getMovieDetail(long movieId) {
        if (movieId <= 0) {
            return null;
        }
        return guestMovieDAO.findMovieDetailForGuest(movieId);
    }

    @Override
    public List<Genre> getGenres() {
        return movieDAO.findAllGenres();
    }

    @Override
    public List<String> getLanguages() {
        return guestMovieDAO.findAllLanguages();
    }

    @Override
    public List<Branch> getBranches() {
        return branchDAO.findAllActive();
    }

    private String clean(String value) {
        if (value == null) {
            return null;
        }
        value = value.trim();
        return value.isEmpty() ? null : value;
    }

    /** Chỉ chấp nhận status đúng theo DB. Sai thì bỏ filter để tránh lỗi. */
    private String normalizeStatus(String status) {
        status = clean(status);
        if ("NOW_SHOWING".equals(status) || "UPCOMING".equals(status) || "ENDED".equals(status)) {
            return status;
        }
        return null;
    }

    /** Chỉ chấp nhận sort có sẵn. Sai thì dùng release_desc. */
    private String normalizeSort(String sort) {
        sort = clean(sort);
        if (sort == null) {
            return "release_desc";
        }
        switch (sort) {
            case "title_asc":
            case "title_desc":
            case "release_asc":
            case "release_desc":
            case "duration_asc":
            case "duration_desc":
                return sort;
            default:
                return "release_desc";
        }
    }
}