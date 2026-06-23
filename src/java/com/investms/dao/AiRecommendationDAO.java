package com.investms.dao;

import com.investms.db.DBConnection;
import com.investms.model.AiRecommendation;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Persists and retrieves AI recommendations from the database.
 */
public class AiRecommendationDAO {

    private static final Logger LOGGER = Logger.getLogger(AiRecommendationDAO.class.getName());

    // ── Save a single recommendation ──────────────────────────────────────────
    public boolean save(AiRecommendation rec) {
        String sql = "INSERT INTO ai_recommendations "
                   + "(user_id, recommendation, confidence_score, rec_type, asset_id, is_read) "
                   + "VALUES (?,?,?,?,?,0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, rec.getUserId());
            ps.setString(2, rec.getRecommendation());
            ps.setBigDecimal(3, rec.getConfidenceScore());
            ps.setString(4, rec.getRecType());
            if (rec.getAssetId() != null) ps.setInt(5, rec.getAssetId());
            else ps.setNull(5, Types.INTEGER);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) rec.setRecId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "AiRecommendationDAO.save failed", e);
        }
        return false;
    }

    // ── Save multiple at once ─────────────────────────────────────────────────
    public void saveAll(List<AiRecommendation> recs) {
        for (AiRecommendation r : recs) save(r);
    }

    // ── Find by user (most recent 20) ─────────────────────────────────────────
    public List<AiRecommendation> findByUser(int userId) {
        List<AiRecommendation> list = new ArrayList<>();
        String sql = "SELECT r.*, a.asset_name, a.symbol AS asset_symbol "
                   + "FROM ai_recommendations r "
                   + "LEFT JOIN assets a ON a.asset_id = r.asset_id "
                   + "WHERE r.user_id = ? ORDER BY r.generated_at DESC LIMIT 20";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findByUser ai_recs failed", e);
        }
        return list;
    }

    // ── Count unread ──────────────────────────────────────────────────────────
    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM ai_recommendations WHERE user_id=? AND is_read=0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "countUnread ai_recs failed", e);
        }
        return 0;
    }

    // ── Mark all read ─────────────────────────────────────────────────────────
    public void markAllRead(int userId) {
        String sql = "UPDATE ai_recommendations SET is_read=1 WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "markAllRead ai_recs failed", e);
        }
    }

    // ── Delete old recommendations (keep last 20) ─────────────────────────────
    public void pruneOld(int userId) {
        String sql = "DELETE FROM ai_recommendations WHERE user_id=? "
                   + "AND rec_id NOT IN ("
                   + "  SELECT rec_id FROM (SELECT rec_id FROM ai_recommendations "
                   + "  WHERE user_id=? ORDER BY generated_at DESC LIMIT 20) t)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "pruneOld ai_recs failed", e);
        }
    }

    // ── Save chat message ─────────────────────────────────────────────────────
    public boolean saveChatMessage(int userId, String role, String message) {
        String sql = "INSERT INTO chat_history (user_id, role, message) VALUES (?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, role);
            ps.setString(3, message);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "saveChatMessage failed", e);
        }
        return false;
    }

    // ── Load chat history ─────────────────────────────────────────────────────
    public List<String[]> getChatHistory(int userId, int limit) {
        List<String[]> msgs = new ArrayList<>();
        String sql = "SELECT role, message, created_at FROM chat_history "
                   + "WHERE user_id=? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    msgs.add(new String[]{rs.getString("role"), rs.getString("message"),
                                         rs.getString("created_at")});
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getChatHistory failed", e);
        }
        Collections.reverse(msgs);
        return msgs;
    }

    private AiRecommendation mapRow(ResultSet rs) throws SQLException {
        AiRecommendation r = new AiRecommendation();
        r.setRecId(rs.getInt("rec_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRecommendation(rs.getString("recommendation"));
        r.setConfidenceScore(rs.getBigDecimal("confidence_score"));
        r.setRecType(rs.getString("rec_type"));
        int aid = rs.getInt("asset_id");
        if (!rs.wasNull()) r.setAssetId(aid);
        r.setAssetName(rs.getString("asset_name"));
        r.setAssetSymbol(rs.getString("asset_symbol"));
        r.setRead(rs.getBoolean("is_read"));
        Timestamp ga = rs.getTimestamp("generated_at");
        if (ga != null) r.setGeneratedAt(ga.toLocalDateTime());
        return r;
    }
}
