package com.mbcms.dao.impl;

import com.mbcms.dao.GuestMovieDAO;
import com.mbcms.model.Movie;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * GuestMovieDAOImpl - owner: AnhND.
 *
 * Tầng DAO chỉ làm việc với database. Servlet/Service không viết SQL trực tiếp.
 * Code này phục vụ 4 UC của Guest:
 * Browse movies, View movie details, Search movies, Filter movies.
 */
public class GuestMovieDAOImpl extends BaseDAO implements GuestMovieDAO {

    /**
     * SELECT chung cho danh sách và chi tiết phim.
     * LEFT JOIN để phim không có thể loại vẫn hiển thị được.
     */
    private static final String MOVIE_SELECT_WITH_GENRE =
            "SELECT m.movie_id, m.title, m.description, m.duration_min, m.director, m.cast_list, "
            + "m.language, m.country, m.rated, m.poster_url, m.trailer_url, m.release_date, "
            + "m.status, m.active, g.name AS genre_name "
            + "FROM movies m "
            + "LEFT JOIN movie_genres mg ON mg.movie_id = m.movie_id "
            + "LEFT JOIN genres g ON g.genre_id = mg.genre_id  ";

    @Override
    public List<Movie> findMoviesForGuest(String status,
                                          String keyword,
                                          String genre,
                                          String language,
                                          Long branchId,
                                          String sort) {

        StringBuilder sql = new StringBuilder(MOVIE_SELECT_WITH_GENRE);
        List<Object> params = new ArrayList<>();

        // Guest chỉ xem phim active.
        sql.append("WHERE m.active = 1 ");

        // Filter theo trạng thái: NOW_SHOWING / UPCOMING / ENDED.
        if (notBlank(status)) {
            sql.append("AND m.status = ? ");
            params.add(status.trim());
        }

        // Search theo tên phim, nội dung, đạo diễn, diễn viên.
        if (notBlank(keyword)) {
            sql.append("AND (m.title LIKE ? OR m.description LIKE ? OR m.director LIKE ? OR m.cast_list LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        // Filter theo thể loại. Dùng EXISTS để không làm nhân đôi row của phim.
        if (notBlank(genre)) {
            sql.append("AND EXISTS ( ")
               .append("SELECT 1 FROM movie_genres mg2 ")
               .append("JOIN genres g2 ON g2.genre_id = mg2.genre_id ")
               .append("WHERE mg2.movie_id = m.movie_id AND g2.name = ?")
               .append(") ");
            params.add(genre.trim());
        }

        // Filter theo ngôn ngữ.
        if (notBlank(language)) {
            sql.append("AND m.language = ? ");
            params.add(language.trim());
        }

        // Filter theo chi nhánh: phim phải có suất chiếu sắp tới tại branch đó.
        if (branchId != null) {
            sql.append("AND EXISTS ( ")
               .append("SELECT 1 FROM showtimes st ")
               .append("JOIN rooms r ON r.room_id = st.room_id ")
               .append("WHERE st.movie_id = m.movie_id ")
               .append("AND r.branch_id = ? ")
               .append("AND st.status = 'SCHEDULED' ")
               .append("AND st.start_time > GETDATE()")
               .append(") ");
            params.add(branchId);
        }

        // Sort không được nối trực tiếp input của user vào SQL.
        // Chỉ cho phép các case đã khai báo sẵn để tránh SQL Injection.
        sql.append(buildOrderBy(sort));

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            rs = ps.executeQuery();
            return mapMovieList(rs);
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van GuestMovieDAOImpl.findMoviesForGuest: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Movie findMovieDetailForGuest(long movieId) {
        String sql = MOVIE_SELECT_WITH_GENRE
                + "WHERE m.active = 1 AND m.movie_id = ? "
                + "ORDER BY g.name";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            rs = ps.executeQuery();

            List<Movie> movies = mapMovieList(rs);
            return movies.isEmpty() ? null : movies.get(0);
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van GuestMovieDAOImpl.findMovieDetailForGuest: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public List<String> findAllLanguages() {
        String sql = "SELECT DISTINCT language FROM movies "
                + "WHERE active = 1 AND language IS NOT NULL AND LTRIM(RTRIM(language)) <> '' "
                + "ORDER BY language";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            List<String> languages = new ArrayList<>();
            while (rs.next()) {
                languages.add(rs.getString("language"));
            }
            return languages;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van GuestMovieDAOImpl.findAllLanguages: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Gom nhiều row DB thành 1 Movie duy nhất, vì 1 phim có thể có nhiều genre.
     */
    private List<Movie> mapMovieList(ResultSet rs) throws SQLException {
        Map<Long, Movie> movieMap = new LinkedHashMap<>();

        while (rs.next()) {
            long movieId = rs.getLong("movie_id");
            Movie movie = movieMap.get(movieId);

            if (movie == null) {
                movie = new Movie();
                movie.setMovieId(movieId);
                movie.setTitle(rs.getString("title"));
                movie.setDescription(rs.getString("description"));
                movie.setDurationMin(rs.getInt("duration_min"));
                movie.setDirector(rs.getString("director"));
                movie.setCastList(rs.getString("cast_list"));
                movie.setLanguage(rs.getString("language"));
                movie.setCountry(rs.getString("country"));
                movie.setRated(rs.getString("rated"));
                movie.setPosterUrl(rs.getString("poster_url"));
                movie.setTrailerUrl(rs.getString("trailer_url"));

                java.sql.Date releaseDate = rs.getDate("release_date");
                if (releaseDate != null) {
                    movie.setReleaseDate(releaseDate.toLocalDate());
                }

                movie.setStatus(rs.getString("status"));
                movie.setActive(rs.getBoolean("active"));
                movie.setGenres(new ArrayList<>());

                movieMap.put(movieId, movie);
            }

            String genreName = rs.getString("genre_name");
            if (genreName != null && !movie.getGenres().contains(genreName)) {
                movie.getGenres().add(genreName);
            }
        }

        return new ArrayList<>(movieMap.values());
    }

    /**
     * Sort whitelist: input của user chỉ được map sang các câu ORDER BY an toàn.
     */
    private String buildOrderBy(String sort) {
        if (sort == null) {
            return "ORDER BY m.release_date DESC, m.movie_id DESC, g.name";
        }

        switch (sort.trim()) {
            case "title_asc":
                return "ORDER BY m.title ASC, m.movie_id DESC, g.name";
            case "title_desc":
                return "ORDER BY m.title DESC, m.movie_id DESC, g.name";
            case "release_asc":
                return "ORDER BY m.release_date ASC, m.movie_id ASC, g.name";
            case "duration_asc":
                return "ORDER BY m.duration_min ASC, m.title ASC, g.name";
            case "duration_desc":
                return "ORDER BY m.duration_min DESC, m.title ASC, g.name";
            case "release_desc":
            default:
                return "ORDER BY m.release_date DESC, m.movie_id DESC, g.name";
        }
    }

    private boolean notBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }
}