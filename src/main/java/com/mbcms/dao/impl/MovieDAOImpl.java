package com.mbcms.dao.impl;

import com.mbcms.dao.MovieDAO;
import com.mbcms.model.Movie;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * MovieDAOImpl - chi lay cac cot can cho Showtime Management
 * (dropdown chon phim + duration_min de tinh end_time).
 */
public class MovieDAOImpl extends BaseDAO implements MovieDAO {

    private static final String BASE_SELECT =
            "SELECT movie_id, title, duration_min, status, active FROM movies ";

    @Override
    public List<Movie> findActiveMovies() {
        String sql = BASE_SELECT + "WHERE active = 1 ORDER BY title";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            List<Movie> movies = new ArrayList<>();
            while (rs.next()) {
                movies.add(mapRow(rs));
            }
            return movies;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van movies.findActiveMovies: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public List<Movie> findActiveMoviesForBranch(long branchId) {
        // JOIN movie_branch -> chi phim da duoc cap cho chi nhanh nay. Qualify cot
        // (m.movie_id...) vi movie_branch cung co cot movie_id (tranh ambiguous).
        String sql = "SELECT m.movie_id, m.title, m.duration_min, m.status, m.active "
                + "FROM movies m "
                + "JOIN movie_branch mb ON mb.movie_id = m.movie_id "
                + "WHERE m.active = 1 AND mb.branch_id = ? "
                + "ORDER BY m.title";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();

            List<Movie> movies = new ArrayList<>();
            while (rs.next()) {
                movies.add(mapRow(rs));
            }
            return movies;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van movies.findActiveMoviesForBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean isAssignedToBranch(long movieId, long branchId) {
        String sql = "SELECT 1 FROM movie_branch WHERE movie_id = ? AND branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            ps.setLong(2, branchId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van movie_branch.isAssignedToBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Movie findById(long movieId) {
        String sql = BASE_SELECT + "WHERE movie_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van movies.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
    
    /**
     * DISTINCT movie dang co suat chieu SCHEDULED trong tuong lai tai 1 branch.
     * Can them poster_url + rated (BASE_SELECT khong co) vi day la man hinh
     * customer xem - can hien thi poster/nhan do tuoi, khac voi dropdown noi bo.
     */
    @Override
    public List<Movie> findByBranch(long branchId) {
        String sql = "SELECT DISTINCT m.movie_id, m.title, m.duration_min, m.status, m.active, "
                + "m.poster_url, m.rated "
                + "FROM movies m "
                + "JOIN showtimes st ON st.movie_id = m.movie_id "
                + "JOIN rooms r ON st.room_id = r.room_id "
                + "WHERE r.branch_id = ? AND m.active = 1 "
                + "AND st.status = 'SCHEDULED' AND st.start_time > GETDATE() "
                + "ORDER BY m.title";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();

            List<Movie> movies = new ArrayList<>();
            while (rs.next()) {
                movies.add(mapBrowseRow(rs));
            }
            return movies;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van movies.findByBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
    
    /** Giong mapRow nhung co them poster_url + rated, dung rieng cho findByBranch. */
    private Movie mapBrowseRow(ResultSet rs) throws SQLException {
        Movie m = mapRow(rs);
        m.setPosterUrl(rs.getString("poster_url"));
        m.setRated(rs.getString("rated"));
        return m;
    }
   
    /** Chi map cac cot trong BASE_SELECT (du dung cho showtime). */
    private Movie mapRow(ResultSet rs) throws SQLException {
        Movie m = new Movie();
        m.setMovieId(rs.getLong("movie_id"));
        m.setTitle(rs.getString("title"));
        m.setDurationMin(rs.getInt("duration_min"));
        m.setStatus(rs.getString("status"));
        m.setActive(rs.getBoolean("active"));
        return m;
    }
}
