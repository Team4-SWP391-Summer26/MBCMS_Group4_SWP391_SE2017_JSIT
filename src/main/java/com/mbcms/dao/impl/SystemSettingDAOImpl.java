package com.mbcms.dao.impl;

import com.mbcms.dao.SystemSettingDAO;
import com.mbcms.model.SystemSetting;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class SystemSettingDAOImpl extends BaseDAO implements SystemSettingDAO {

    @Override
    public List<SystemSetting> findAll() {
        String sql = "SELECT setting_key, setting_value, description, updated_at "
                + "FROM dbo.system_settings ORDER BY setting_key";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<SystemSetting> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van system_settings.findAll: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public String findValue(String key) {
        String sql = "SELECT setting_value FROM dbo.system_settings WHERE setting_key = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, key);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("setting_value");
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van system_settings.findValue: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public void upsert(String key, String value) {
        String sql = "MERGE dbo.system_settings AS t "
                + "USING (SELECT ? AS setting_key, ? AS setting_value) AS s "
                + "ON t.setting_key = s.setting_key "
                + "WHEN MATCHED THEN UPDATE SET setting_value = s.setting_value, updated_at = SYSUTCDATETIME() "
                + "WHEN NOT MATCHED THEN INSERT (setting_key, setting_value) "
                + "VALUES (s.setting_key, s.setting_value);";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, key);
            ps.setString(2, value);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Loi upsert system_settings: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public void upsertAll(Map<String, String> values) {
        if (values == null || values.isEmpty()) {
            return;
        }
        String sql = "MERGE dbo.system_settings AS t "
                + "USING (SELECT ? AS setting_key, ? AS setting_value) AS s "
                + "ON t.setting_key = s.setting_key "
                + "WHEN MATCHED THEN UPDATE SET setting_value = s.setting_value, updated_at = SYSUTCDATETIME() "
                + "WHEN NOT MATCHED THEN INSERT (setting_key, setting_value) "
                + "VALUES (s.setting_key, s.setting_value);";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            ps = conn.prepareStatement(sql);
            for (Map.Entry<String, String> e : values.entrySet()) {
                ps.setString(1, e.getKey());
                ps.setString(2, e.getValue());
                ps.addBatch();
            }
            ps.executeBatch();
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                    // ignore
                }
            }
            throw new RuntimeException("Loi upsertAll system_settings: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                    // ignore
                }
            }
            closeAll(ps, conn);
        }
    }

    private SystemSetting mapRow(ResultSet rs) throws SQLException {
        SystemSetting s = new SystemSetting();
        s.setSettingKey(rs.getString("setting_key"));
        s.setSettingValue(rs.getString("setting_value"));
        s.setDescription(rs.getString("description"));
        Timestamp ts = rs.getTimestamp("updated_at");
        if (ts != null) {
            s.setUpdatedAt(ts.toLocalDateTime());
        }
        return s;
    }
}
