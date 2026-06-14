package com.mbcms.dao.impl;

import com.mbcms.dao.BranchDAO;
import com.mbcms.model.Branch;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class BranchDAOImpl extends BaseDAO implements BranchDAO {

    @Override
    public Branch findById(long branchId) {
        String sql = "SELECT branch_id, name, address, city, phone, email, active "
                + "FROM branches WHERE branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van branches.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    private Branch mapRow(ResultSet rs) throws SQLException {
        Branch b = new Branch();
        b.setBranchId(rs.getLong("branch_id"));
        b.setName(rs.getString("name"));
        b.setAddress(rs.getString("address"));
        b.setCity(rs.getString("city"));
        b.setPhone(rs.getString("phone"));
        b.setEmail(rs.getString("email"));
        b.setActive(rs.getBoolean("active"));
        return b;
    }
}
