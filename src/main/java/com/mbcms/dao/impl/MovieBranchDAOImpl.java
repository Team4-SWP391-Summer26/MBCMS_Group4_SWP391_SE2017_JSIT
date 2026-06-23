package com.mbcms.dao.impl;

import com.mbcms.dao.MovieBranchDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

/**
 * MovieBranchDAOImpl - SQL cho bang movie_branch. Owner: HungNT.
 */
public class MovieBranchDAOImpl extends BaseDAO implements MovieBranchDAO {

    @Override
    public Set<Long> findMovieIdsByBranch(long branchId) {
        String sql = "SELECT movie_id FROM movie_branch WHERE branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();

            Set<Long> ids = new HashSet<>();
            while (rs.next()) {
                ids.add(rs.getLong("movie_id"));
            }
            return ids;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van movie_branch.findMovieIdsByBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM movie_branch";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van movie_branch.countAll: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public int updateAssignments(long branchId, Set<Long> targetMovieIds) {
        // DIFF trong 1 transaction: load hien tai -> tinh them/bo -> batch INSERT/DELETE.
        // Hoac doi het, hoac khong doi gi (tranh trang thai nua voi).
        Connection conn = null;
        PreparedStatement psSel = null;
        PreparedStatement psIns = null;
        PreparedStatement psDel = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false); // bat dau transaction

            // 1. Phim hien dang duoc cap cho branch nay.
            Set<Long> current = new HashSet<>();
            psSel = conn.prepareStatement("SELECT movie_id FROM movie_branch WHERE branch_id = ?");
            psSel.setLong(1, branchId);
            rs = psSel.executeQuery();
            while (rs.next()) {
                current.add(rs.getLong("movie_id"));
            }

            // 2. Tinh chenh lech.
            Set<Long> toAdd = new HashSet<>(targetMovieIds);
            toAdd.removeAll(current);
            Set<Long> toRemove = new HashSet<>(current);
            toRemove.removeAll(targetMovieIds);

            // 3. INSERT phim moi them.
            if (!toAdd.isEmpty()) {
                psIns = conn.prepareStatement("INSERT INTO movie_branch (movie_id, branch_id) VALUES (?, ?)");
                for (Long movieId : toAdd) {
                    psIns.setLong(1, movieId);
                    psIns.setLong(2, branchId);
                    psIns.addBatch();
                }
                psIns.executeBatch();
            }

            // 4. DELETE phim bo chon.
            if (!toRemove.isEmpty()) {
                psDel = conn.prepareStatement("DELETE FROM movie_branch WHERE movie_id = ? AND branch_id = ?");
                for (Long movieId : toRemove) {
                    psDel.setLong(1, movieId);
                    psDel.setLong(2, branchId);
                    psDel.addBatch();
                }
                psDel.executeBatch();
            }

            conn.commit();
            return toAdd.size() + toRemove.size();
        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("Loi cap nhat movie_branch.updateAssignments: " + e.getMessage(), e);
        } finally {
            restoreAutoCommitQuietly(conn);
            closeAll(rs, psSel, null);
            closeAll(psIns, null);
            closeAll(psDel, conn);
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                System.err.println("Loi rollback movie_branch: " + e.getMessage());
            }
        }
    }

    /** Bat lai autocommit truoc khi connection ve pool (pool ky vong autocommit=true). */
    private void restoreAutoCommitQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("Loi restore autocommit: " + e.getMessage());
            }
        }
    }
}