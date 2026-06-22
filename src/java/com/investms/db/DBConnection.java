package com.investms.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Singleton database connection manager.
 * Uses MySQL Connector/J with XAMPP defaults.
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    // ── Configuration ──────────────────────────────────────────────────────────
    private static final String DRIVER   = "com.mysql.cj.jdbc.Driver";
    private static final String URL      = "jdbc:mysql://localhost:3306/investment_ms"
                                         + "?useSSL=false"
                                         + "&serverTimezone=UTC"
                                         + "&allowPublicKeyRetrieval=true"
                                         + "&characterEncoding=UTF-8";
    private static final String USER     = "root";
    private static final String PASSWORD = "";          // XAMPP default — change in production

    // ── Static initialiser: load driver once ──────────────────────────────────
    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found. Add mysql-connector-j.jar to libs.", e);
            throw new ExceptionInInitializerError(e);
        }
    }

    // ── Private constructor — utility class ───────────────────────────────────
    private DBConnection() {}

    /**
     * Returns a fresh connection from DriverManager.
     * Callers MUST close the connection (use try-with-resources).
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    /**
     * Quietly closes a connection (null-safe).
     */
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Failed to close DB connection", e);
            }
        }
    }

    /**
     * Quick connectivity test — useful for app startup checks.
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB connection test failed", e);
            return false;
        }
    }
}
