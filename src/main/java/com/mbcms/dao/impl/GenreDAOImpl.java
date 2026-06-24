package com.mbcms.dao.impl;

import com.mbcms.dao.GenreDAO;
import com.mbcms.model.Genre;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class GenreDAOImpl extends BaseDAO implements GenreDAO {

    @Override
    public List<Genre> findAllWithCount() {
        String sql = "SELECT g.genre_id, g.name, COUNT(mg.movie_id) AS movie_count "
                + "FROM genres g "
                + "LEFT JOIN movie_genres mg ON mg.genre_id = g.genre_id "
                + "GROUP BY g.genre_id, g.name "
                + "ORDER BY g.name";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            List<Genre> list = new ArrayList<>();
            while (rs.next()) {
                Genre g = new Genre();
                g.setGenreId(rs.getInt("genre_id"));
                g.setName(rs.getString("name"));
                g.setMovieCount(rs.getInt("movie_count"));
                list.add(g);
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi GenreDAO.findAllWithCount: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Genre findById(int genreId) {
        String sql = "SELECT genre_id, name FROM genres WHERE genre_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, genreId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Genre g = new Genre();
                g.setGenreId(rs.getInt("genre_id"));
                g.setName(rs.getString("name"));
                return g;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi GenreDAO.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean existsByName(String name, Integer excludeId) {
        String sql = "SELECT 1 FROM genres WHERE LOWER(name) = LOWER(?) "
                + (excludeId != null ? "AND genre_id <> ?" : "");
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name == null ? "" : name.trim());
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi GenreDAO.existsByName: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public int insert(String name) {
        String sql = "INSERT INTO genres (name) VALUES (?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet keys = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, name.trim());
            ps.executeUpdate();
            keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi GenreDAO.insert: " + e.getMessage(), e);
        } finally {
            closeAll(keys, ps, conn);
        }
    }

    @Override
    public boolean update(int genreId, String name) {
        String sql = "UPDATE genres SET name = ? WHERE genre_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name.trim());
            ps.setInt(2, genreId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi GenreDAO.update: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean delete(int genreId) {
        String sql = "DELETE FROM genres WHERE genre_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, genreId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi GenreDAO.delete: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean isInUse(int genreId) {
        String sql = "SELECT 1 FROM movie_genres WHERE genre_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, genreId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi GenreDAO.isInUse: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
}
