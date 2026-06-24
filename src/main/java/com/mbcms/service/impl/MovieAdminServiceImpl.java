package com.mbcms.service.impl;

import com.mbcms.dao.GenreDAO;
import com.mbcms.dao.MovieAdminDAO;
import com.mbcms.dao.impl.GenreDAOImpl;
import com.mbcms.dao.impl.MovieAdminDAOImpl;
import com.mbcms.model.Genre;
import com.mbcms.model.Movie;
import com.mbcms.service.MovieAdminService;

import java.util.List;
import java.util.Set;

public class MovieAdminServiceImpl implements MovieAdminService {

    private static final Set<String> VALID_STATUS = Set.of("UPCOMING", "NOW_SHOWING", "ENDED");
    private static final Set<String> VALID_RATED = Set.of("P", "C13", "C16", "C18");

    private final MovieAdminDAO movieDAO = new MovieAdminDAOImpl();
    private final GenreDAO genreDAO = new GenreDAOImpl();

    @Override
    public List<Movie> list(String keyword, String status) {
        return movieDAO.findAll(keyword, status);
    }

    @Override
    public Movie get(long movieId) {
        return movieDAO.findById(movieId);
    }

    @Override
    public Set<Integer> getGenreIds(long movieId) {
        return movieDAO.findGenreIds(movieId);
    }

    @Override
    public long create(Movie movie, Set<Integer> genreIds) {
        validate(movie);
        long id = movieDAO.insert(movie);
        movieDAO.replaceGenres(id, genreIds);
        return id;
    }

    @Override
    public boolean update(Movie movie, Set<Integer> genreIds) {
        validate(movie);
        if (movie.getMovieId() <= 0 || movieDAO.findById(movie.getMovieId()) == null) {
            throw new IllegalArgumentException("Phim không tồn tại.");
        }
        boolean ok = movieDAO.update(movie);
        movieDAO.replaceGenres(movie.getMovieId(), genreIds);
        return ok;
    }

    @Override
    public void delete(long movieId) {
        if (movieDAO.findById(movieId) == null) {
            throw new IllegalArgumentException("Phim không tồn tại.");
        }
        int showtimes = movieDAO.countShowtimes(movieId);
        if (showtimes > 0) {
            throw new IllegalArgumentException("Không thể xóa: phim đang có " + showtimes
                    + " suất chiếu. Hãy ẩn phim (chuyển sang Inactive) thay vì xóa.");
        }
        movieDAO.delete(movieId);
    }

    @Override
    public boolean changeStatus(long movieId, String status) {
        if (!VALID_STATUS.contains(status)) {
            throw new IllegalArgumentException("Trạng thái phim không hợp lệ.");
        }
        return movieDAO.updateStatus(movieId, status);
    }

    @Override
    public boolean setActive(long movieId, boolean active) {
        return movieDAO.updateActive(movieId, active);
    }

    @Override
    public List<Genre> allGenres() {
        return genreDAO.findAllWithCount();
    }

    @Override
    public List<String> allLanguages() {
        return movieDAO.findAllLanguages();
    }

    /** Validate khop voi rang buoc CHECK cua bang movies. */
    private void validate(Movie m) {
        if (m.getTitle() == null || m.getTitle().isBlank()) {
            throw new IllegalArgumentException("Tên phim không được để trống.");
        }
        if (m.getTitle().trim().length() > 200) {
            throw new IllegalArgumentException("Tên phim tối đa 200 ký tự.");
        }
        if (m.getDurationMin() <= 0) {
            throw new IllegalArgumentException("Thời lượng phải lớn hơn 0 phút.");
        }
        if (m.getStatus() == null || !VALID_STATUS.contains(m.getStatus())) {
            throw new IllegalArgumentException("Trạng thái phim không hợp lệ.");
        }
        if (m.getRated() != null && !m.getRated().isBlank() && !VALID_RATED.contains(m.getRated())) {
            throw new IllegalArgumentException("Nhãn phân loại không hợp lệ.");
        }
    }
}
