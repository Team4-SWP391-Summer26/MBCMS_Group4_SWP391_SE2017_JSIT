package com.mbcms.dao.impl;

import com.mbcms.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * BaseDAO - lop cha cho tat ca DAOs
 * 
 * Cung cap pattern chuan:
 *   Connection conn = null;
 *   try {
 *       conn = getConnection();
 *       ...
 *   } finally {
 *       closeAll(rs, ps, conn);
 *   }
 */
public abstract class BaseDAO {

    protected Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    protected void closeAll(ResultSet rs, PreparedStatement ps, Connection conn) {
        closeResultSet(rs);
        closeStatement(ps);
        closeConnection(conn);
    }

    protected void closeAll(PreparedStatement ps, Connection conn) {
        closeStatement(ps);
        closeConnection(conn);
    }

    private void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) {
                System.err.println("Loi dong ResultSet: " + e.getMessage());
            }
        }
    }

    private void closeStatement(PreparedStatement ps) {
        if (ps != null) {
            try { ps.close(); } catch (SQLException e) {
                System.err.println("Loi dong PreparedStatement: " + e.getMessage());
            }
        }
    }

    private void closeConnection(Connection conn) {
        DBUtil.closeConnection(conn);
    }
}
