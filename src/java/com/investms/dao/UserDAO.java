package com.investms.dao;

import com.investms.db.DBConnection;
import com.investms.model.User;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for the users table.
 * All queries use PreparedStatements to prevent SQL injection.
 */
public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    // ── Find user by email (used for login) ───────────────────────────────────
    public User findByEmail(String email) {
        String sql = "SELECT u.*, r.role_name FROM users u "
                   + "JOIN roles r ON r.role_id = u.role_id "
                   + "WHERE u.email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findByEmail failed", e);
        }
        return null;
    }

    // ── Find user by ID ───────────────────────────────────────────────────────
    public User findById(int userId) {
        String sql = "SELECT u.*, r.role_name FROM users u "
                   + "JOIN roles r ON r.role_id = u.role_id "
                   + "WHERE u.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findById failed", e);
        }
        return null;
    }

    // ── Register a new user ───────────────────────────────────────────────────
    public boolean register(User user) {
        String sql = "INSERT INTO users (full_name, email, password_hash, phone, role_id, status) "
                   + "VALUES (?, ?, ?, ?, ?, 'ACTIVE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getPhone());
            ps.setInt(5, user.getRoleId() > 0 ? user.getRoleId() : 2); // default INVESTOR
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) user.setUserId(keys.getInt(1));
                }
                // Create empty wallet for new user
                createWallet(user.getUserId());
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "register failed", e);
        }
        return false;
    }

    // ── Check email exists ────────────────────────────────────────────────────
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "emailExists failed", e);
        }
        return false;
    }

    // ── Update profile ────────────────────────────────────────────────────────
    public boolean updateProfile(User user) {
        String sql = "UPDATE users SET full_name=?, phone=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setInt(3, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "updateProfile failed", e);
        }
        return false;
    }

    // ── Update password ───────────────────────────────────────────────────────
    public boolean updatePassword(int userId, String newHash) {
        String sql = "UPDATE users SET password_hash=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "updatePassword failed", e);
        }
        return false;
    }

    // ── List all users (admin) ────────────────────────────────────────────────
    public List<User> findAll() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_name FROM users u "
                   + "JOIN roles r ON r.role_id = u.role_id ORDER BY u.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) users.add(mapRow(rs));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findAll failed", e);
        }
        return users;
    }

    // ── Count total investors ─────────────────────────────────────────────────
    public int countInvestors() {
        String sql = "SELECT COUNT(*) FROM users WHERE role_id = 2 AND status = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "countInvestors failed", e);
        }
        return 0;
    }

    // ── Create empty wallet ───────────────────────────────────────────────────
    private void createWallet(int userId) {
        String sql = "INSERT IGNORE INTO user_wallet (user_id, balance) VALUES (?, 0.00)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "createWallet failed for userId=" + userId, e);
        }
    }

    // ── ResultSet mapper ──────────────────────────────────────────────────────
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setPhone(rs.getString("phone"));
        u.setRoleId(rs.getInt("role_id"));
        u.setRoleName(rs.getString("role_name"));
        u.setStatus(rs.getString("status"));
        u.setProfilePic(rs.getString("profile_pic"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) u.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) u.setUpdatedAt(ua.toLocalDateTime());
        return u;
    }
}
