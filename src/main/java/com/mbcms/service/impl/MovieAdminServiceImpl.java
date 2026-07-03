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
            throw new IllegalArgumentException("Movie does not exist.");
        }
        boolean ok = movieDAO.update(movie);
        movieDAO.replaceGenres(movie.getMovieId(), genreIds);
        return ok;
    }

    @Override
    public void delete(long movieId) {
        if (movieDAO.findById(movieId) == null) {
            throw new IllegalArgumentException("Movie does not exist.");
        }
        int showtimes = movieDAO.countShowtimes(movieId);
        if (showtimes > 0) {
            throw new IllegalArgumentException("Cannot delete this movie because it has " + showtimes
                    + " showtimes. Hide the movie by setting it to Inactive instead of deleting it.");
        }
        movieDAO.delete(movieId);
    }

    @Override
    public boolean changeStatus(long movieId, String status) {
        if (!VALID_STATUS.contains(status)) {
            throw new IllegalArgumentException("Invalid movie status.");
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
            throw new IllegalArgumentException("Movie title is required.");
        }
        if (m.getTitle().trim().length() > 200) {
            throw new IllegalArgumentException("Movie title must be 200 characters or fewer.");
        }
        if (m.getDurationMin() <= 0) {
            throw new IllegalArgumentException("Duration must be greater than 0 minutes.");
        }
        if (m.getStatus() == null || !VALID_STATUS.contains(m.getStatus())) {
            throw new IllegalArgumentException("Invalid movie status.");
        }
        if (m.getRated() != null && !m.getRated().isBlank() && !VALID_RATED.contains(m.getRated())) {
            throw new IllegalArgumentException("Invalid rating label.");
        }
    }
}
