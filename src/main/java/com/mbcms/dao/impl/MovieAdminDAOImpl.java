package com.mbcms.dao.impl;

import com.mbcms.dao.MovieAdminDAO;
import com.mbcms.model.Movie;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * MovieAdminDAOImpl - thao tac CRUD tren bang movies + bridge movie_genres.
 */
public class MovieAdminDAOImpl extends BaseDAO implements MovieAdminDAO {

    private static final String COLUMNS
            = "m.movie_id, m.title, m.description, m.duration_min, m.director, m.cast_list, "
            + "m.language, m.country, m.rated, m.poster_url, m.trailer_url, m.release_date, "
            + "m.status, m.active";

    @Override
    public List<Movie> findAll(String keyword, String status) {
        StringBuilder sql = new StringBuilder(
                "SELECT " + COLUMNS + ", g.name AS genre_name "
                + "FROM movies m "
                + "LEFT JOIN movie_genres mg ON mg.movie_id = m.movie_id "
                + "LEFT JOIN genres g ON g.genre_id = mg.genre_id "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (m.title LIKE ? OR m.director LIKE ? OR m.cast_list LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND m.status = ? ");
            params.add(status);
        }
        sql.append("ORDER BY m.movie_id DESC");

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
            throw new RuntimeException("Loi MovieAdminDAO.findAll: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Movie findById(long movieId) {
        String sql = "SELECT " + COLUMNS + ", g.name AS genre_name "
                + "FROM movies m "
                + "LEFT JOIN movie_genres mg ON mg.movie_id = m.movie_id "
                + "LEFT JOIN genres g ON g.genre_id = mg.genre_id "
                + "WHERE m.movie_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            rs = ps.executeQuery();
            List<Movie> list = mapMovieList(rs);
            return list.isEmpty() ? null : list.get(0);
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Set<Integer> findGenreIds(long movieId) {
        String sql = "SELECT genre_id FROM movie_genres WHERE movie_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            rs = ps.executeQuery();
            Set<Integer> ids = new LinkedHashSet<>();
            while (rs.next()) {
                ids.add(rs.getInt("genre_id"));
            }
            return ids;
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.findGenreIds: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public long insert(Movie m) {
        String sql = "INSERT INTO movies "
                + "(title, description, duration_min, director, cast_list, language, country, "
                + " rated, poster_url, trailer_url, release_date, status, active) "
                + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet keys = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            bindMovie(ps, m);
            ps.executeUpdate();
            keys = ps.getGeneratedKeys();
            if (keys.next()) {
                return keys.getLong(1);
            }
            throw new RuntimeException("Khong lay duoc movie_id sau khi them.");
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.insert: " + e.getMessage(), e);
        } finally {
            closeAll(keys, ps, conn);
        }
    }

    @Override
    public boolean update(Movie m) {
        String sql = "UPDATE movies SET title=?, description=?, duration_min=?, director=?, "
                + "cast_list=?, language=?, country=?, rated=?, poster_url=?, trailer_url=?, "
                + "release_date=?, status=?, active=? WHERE movie_id=?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            int idx = bindMovie(ps, m);
            ps.setLong(idx, m.getMovieId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.update: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean delete(long movieId) {
        String sql = "DELETE FROM movies WHERE movie_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.delete: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public int countShowtimes(long movieId) {
        String sql = "SELECT COUNT(*) FROM showtimes WHERE movie_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.countShowtimes: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean updateStatus(long movieId, String status) {
        String sql = "UPDATE movies SET status = ? WHERE movie_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setLong(2, movieId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.updateStatus: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateActive(long movieId, boolean active) {
        String sql = "UPDATE movies SET active = ? WHERE movie_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setLong(2, movieId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.updateActive: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public void replaceGenres(long movieId, Set<Integer> genreIds) {
        Connection conn = null;
        PreparedStatement del = null;
        PreparedStatement ins = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            del = conn.prepareStatement("DELETE FROM movie_genres WHERE movie_id = ?");
            del.setLong(1, movieId);
            del.executeUpdate();

            if (genreIds != null && !genreIds.isEmpty()) {
                ins = conn.prepareStatement(
                        "INSERT INTO movie_genres (movie_id, genre_id) VALUES (?, ?)");
                for (Integer gid : genreIds) {
                    ins.setLong(1, movieId);
                    ins.setInt(2, gid);
                    ins.addBatch();
                }
                ins.executeBatch();
            }
            conn.commit();
        } catch (SQLException e) {
            rollbackQuiet(conn);
            throw new RuntimeException("Loi MovieAdminDAO.replaceGenres: " + e.getMessage(), e);
        } finally {
            if (ins != null) {
                try { ins.close(); } catch (SQLException ignore) { }
            }
            restoreAutoCommit(conn);
            closeAll(del, conn);
        }
    }

    @Override
    public List<String> findAllLanguages() {
        String sql = "SELECT DISTINCT language FROM movies "
                + "WHERE language IS NOT NULL AND language <> '' ORDER BY language";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            List<String> list = new ArrayList<>();
            while (rs.next()) {
                list.add(rs.getString("language"));
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi MovieAdminDAO.findAllLanguages: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    // ── helpers ────────────────────────────────────────────────────────

    /** Bind 13 cot dau (theo dung thu tu insert/update); tra ve chi so param ke tiep. */
    private int bindMovie(PreparedStatement ps, Movie m) throws SQLException {
        int i = 1;
        ps.setString(i++, m.getTitle());
        setNullableString(ps, i++, m.getDescription());
        ps.setInt(i++, m.getDurationMin());
        setNullableString(ps, i++, m.getDirector());
        setNullableString(ps, i++, m.getCastList());
        setNullableString(ps, i++, m.getLanguage());
        setNullableString(ps, i++, m.getCountry());
        setNullableString(ps, i++, m.getRated());
        setNullableString(ps, i++, m.getPosterUrl());
        setNullableString(ps, i++, m.getTrailerUrl());
        if (m.getReleaseDate() != null) {
            ps.setDate(i++, Date.valueOf(m.getReleaseDate()));
        } else {
            ps.setNull(i++, Types.DATE);
        }
        ps.setString(i++, m.getStatus());
        ps.setBoolean(i++, m.isActive());
        return i;
    }

    private void setNullableString(PreparedStatement ps, int idx, String val) throws SQLException {
        if (val == null || val.isBlank()) {
            ps.setNull(idx, Types.VARCHAR);
        } else {
            ps.setString(idx, val.trim());
        }
    }

    private List<Movie> mapMovieList(ResultSet rs) throws SQLException {
        Map<Long, Movie> map = new LinkedHashMap<>();
        while (rs.next()) {
            long id = rs.getLong("movie_id");
            Movie m = map.get(id);
            if (m == null) {
                m = new Movie();
                m.setMovieId(id);
                m.setTitle(rs.getString("title"));
                m.setDescription(rs.getString("description"));
                m.setDurationMin(rs.getInt("duration_min"));
                m.setDirector(rs.getString("director"));
                m.setCastList(rs.getString("cast_list"));
                m.setLanguage(rs.getString("language"));
                m.setCountry(rs.getString("country"));
                m.setRated(rs.getString("rated"));
                m.setPosterUrl(rs.getString("poster_url"));
                m.setTrailerUrl(rs.getString("trailer_url"));
                Date rd = rs.getDate("release_date");
                if (rd != null) {
                    m.setReleaseDate(rd.toLocalDate());
                }
                m.setStatus(rs.getString("status"));
                m.setActive(rs.getBoolean("active"));
                m.setGenres(new ArrayList<>());
                map.put(id, m);
            }
            String genre = rs.getString("genre_name");
            if (genre != null) {
                m.getGenres().add(genre);
            }
        }
        return new ArrayList<>(map.values());
    }

    private void rollbackQuiet(Connection conn) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ignore) { }
        }
    }

    private void restoreAutoCommit(Connection conn) {
        if (conn != null) {
            try { conn.setAutoCommit(true); } catch (SQLException ignore) { }
        }
    }
}
