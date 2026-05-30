package com.mbcms.util;

import org.apache.commons.dbcp2.BasicDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * DBUtil - Singleton DBCP2 Connection Pool
 * 
 * Cach dung:
 *   Connection conn = DBUtil.getConnection();
 *   try { ... } finally { DBUtil.closeConnection(conn); }
 */
public class DBUtil {

    private static BasicDataSource dataSource;

    static {
        try {
            Properties props = new Properties();
            InputStream is = DBUtil.class.getClassLoader()
                    .getResourceAsStream("database.properties");
            if (is == null) {
                throw new RuntimeException("Khong tim thay database.properties trong classpath");
            }
            props.load(is);

            dataSource = new BasicDataSource();
            dataSource.setUrl(props.getProperty("db.url"));
            dataSource.setUsername(props.getProperty("db.username"));
            dataSource.setPassword(props.getProperty("db.password"));

            dataSource.setInitialSize(Integer.parseInt(
                    props.getProperty("db.pool.initialSize", "5")));
            dataSource.setMaxTotal(Integer.parseInt(
                    props.getProperty("db.pool.maxTotal", "20")));
            dataSource.setMaxIdle(Integer.parseInt(
                    props.getProperty("db.pool.maxIdle", "10")));
            dataSource.setMinIdle(Integer.parseInt(
                    props.getProperty("db.pool.minIdle", "5")));
            dataSource.setMaxWaitMillis(Long.parseLong(
                    props.getProperty("db.pool.maxWaitMillis", "30000")));
            dataSource.setTestOnBorrow(Boolean.parseBoolean(
                    props.getProperty("db.pool.testOnBorrow", "true")));
            dataSource.setValidationQuery(
                    props.getProperty("db.pool.validationQuery", "SELECT 1"));

        } catch (IOException e) {
            throw new RuntimeException("Loi load database.properties: " + e.getMessage(), e);
        }
    }

    private DBUtil() {}

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /**
     * Dong connection - luon goi trong finally block
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("Loi dong connection: " + e.getMessage());
            }
        }
    }

    /**
     * Tat pool khi undeploy (goi trong ServletContextListener)
     */
    public static void shutdown() {
        if (dataSource != null) {
            try {
                dataSource.close();
            } catch (SQLException e) {
                System.err.println("Loi tat connection pool: " + e.getMessage());
            }
        }
    }
}
