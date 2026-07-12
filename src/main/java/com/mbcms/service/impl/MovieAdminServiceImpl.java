package com.mbcms.service.impl;

import com.mbcms.dao.GenreDAO;
import com.mbcms.dao.MovieAdminDAO;
import com.mbcms.dao.impl.GenreDAOImpl;
import com.mbcms.dao.impl.MovieAdminDAOImpl;
import com.mbcms.model.Genre;
import com.mbcms.model.Movie;
import com.mbcms.service.MovieAdminService;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

public class MovieAdminServiceImpl implements MovieAdminService {

    private static final Set<String> VALID_STATUS = Set.of("UPCOMING", "NOW_SHOWING", "ENDED");
    private static final Set<String> VALID_RATED = Set.of("P", "C13", "C16", "C18");
    private static final Pattern URL_PATTERN = Pattern.compile(
            "^(https?://|/).+", Pattern.CASE_INSENSITIVE);
    private static final int MAX_DURATION_MIN = 600;

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
        guardStatusChange(movie.getMovieId(), movie.getStatus());
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
                    + " showtimes. Set status to ENDED or Inactive instead of deleting.");
        }
        int bookings = movieDAO.countBookings(movieId);
        if (bookings > 0) {
            throw new IllegalArgumentException("Cannot delete this movie because it has " + bookings
                    + " bookings. Set status to ENDED or Inactive instead of deleting.");
        }
        movieDAO.delete(movieId);
    }

    @Override
    public boolean changeStatus(long movieId, String status) {
        if (!VALID_STATUS.contains(status)) {
            throw new IllegalArgumentException("Invalid movie status.");
        }
        guardStatusChange(movieId, status);
        return movieDAO.updateStatus(movieId, status);
    }

    @Override
    public boolean setActive(long movieId, boolean active) {
        if (!active && movieDAO.hasFutureScheduledShowtimes(movieId)) {
            throw new IllegalArgumentException(
                    "Cannot deactivate: this movie still has SCHEDULED showtimes that have not ended. "
                            + "Cancel or finish those showtimes first.");
        }
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

    private void guardStatusChange(long movieId, String newStatus) {
        if ("ENDED".equals(newStatus) && movieDAO.hasFutureScheduledShowtimes(movieId)) {
            throw new IllegalArgumentException(
                    "Cannot set ENDED while SCHEDULED showtimes with end_time in the future still exist.");
        }
    }

    /** Validate khop voi rang buoc CHECK cua bang movies. */
    private void validate(Movie m) {
        if (m.getTitle() == null || m.getTitle().isBlank()) {
            throw new IllegalArgumentException("Movie title is required.");
        }
        String title = m.getTitle().trim();
        if (title.length() > 200) {
            throw new IllegalArgumentException("Movie title must be 200 characters or fewer.");
        }
        m.setTitle(title);

        if (m.getDurationMin() <= 0 || m.getDurationMin() > MAX_DURATION_MIN) {
            throw new IllegalArgumentException(
                    "Duration must be between 1 and " + MAX_DURATION_MIN + " minutes.");
        }
        if (m.getStatus() == null || !VALID_STATUS.contains(m.getStatus())) {
            throw new IllegalArgumentException("Invalid movie status.");
        }
        if (m.getRated() == null || m.getRated().isBlank() || !VALID_RATED.contains(m.getRated())) {
            throw new IllegalArgumentException("Rating is required (P, C13, C16, or C18).");
        }
        if (m.getReleaseDate() != null) {
            LocalDate rd = m.getReleaseDate();
            LocalDate min = LocalDate.of(1900, 1, 1);
            LocalDate max = LocalDate.now().plusYears(5);
            if (rd.isBefore(min) || rd.isAfter(max)) {
                throw new IllegalArgumentException(
                        "Release date must be between 1900 and 5 years from today.");
            }
        }
        validateOptionalUrl(m.getPosterUrl(), "Poster URL");
        validateOptionalUrl(m.getTrailerUrl(), "Trailer URL");
    }

    private void validateOptionalUrl(String url, String label) {
        if (url == null || url.isBlank()) {
            return;
        }
        String u = url.trim();
        if (u.length() > 500) {
            throw new IllegalArgumentException(label + " is too long.");
        }
        if (!URL_PATTERN.matcher(u).matches()) {
            throw new IllegalArgumentException(
                    label + " must start with http://, https://, or / (site-relative path).");
        }
    }
}
