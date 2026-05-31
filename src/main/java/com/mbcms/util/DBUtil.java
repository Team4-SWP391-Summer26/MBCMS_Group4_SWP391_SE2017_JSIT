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

    private static synchronized void initPool() {
        if (dataSource != null) {
            return;
        }
        try {
            Properties props = new Properties();
            InputStream is = DBUtil.class.getClassLoader()
                    .getResourceAsStream("database.properties");
            if (is == null) {
                throw new RuntimeException("Khong tim thay database.properties trong classpath");
            }
            props.load(is);

            BasicDataSource ds = new BasicDataSource();
            // Phai set driverClassName tuong minh: trong Tomcat, driver nam o
            // WEB-INF/lib (webapp classloader) khong tu dang ky duoc voi DriverManager
            // (system classloader) -> "No suitable driver". Set driverClassName de
            // DBCP2 nap driver bang context classloader cua webapp.
            ds.setDriverClassName(props.getProperty(
                    "db.driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver"));
            ds.setUrl(props.getProperty("db.url"));
            ds.setUsername(props.getProperty("db.username"));
            ds.setPassword(props.getProperty("db.password"));

            ds.setInitialSize(Integer.parseInt(
                    props.getProperty("db.pool.initialSize", "5")));
            ds.setMaxTotal(Integer.parseInt(
                    props.getProperty("db.pool.maxTotal", "20")));
            ds.setMaxIdle(Integer.parseInt(
                    props.getProperty("db.pool.maxIdle", "10")));
            ds.setMinIdle(Integer.parseInt(
                    props.getProperty("db.pool.minIdle", "5")));
            ds.setMaxWaitMillis(Long.parseLong(
                    props.getProperty("db.pool.maxWaitMillis", "30000")));
            ds.setTestOnBorrow(Boolean.parseBoolean(
                    props.getProperty("db.pool.testOnBorrow", "true")));
            ds.setValidationQuery(
                    props.getProperty("db.pool.validationQuery", "SELECT 1"));

            dataSource = ds;
        } catch (IOException e) {
            throw new RuntimeException("Loi load database.properties: " + e.getMessage(), e);
        }
    }

    /** Goi khi deploy/redeploy de tao pool moi (tranh pool cu sau hot-reload Tomcat). */
    public static void reinitialize() {
        shutdown();
        initPool();
    }

    static {
        initPool();
    }

    private DBUtil() {}

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            initPool();
        }
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
            } finally {
                dataSource = null;
            }
        }
    }
}
