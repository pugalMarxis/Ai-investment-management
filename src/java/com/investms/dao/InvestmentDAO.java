package com.investms.dao;

import com.investms.db.DBConnection;
import com.investms.model.Investment;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for the investments table.
 */
public class InvestmentDAO {

    private static final Logger LOGGER = Logger.getLogger(InvestmentDAO.class.getName());

    // ── Create investment ─────────────────────────────────────────────────────
    public boolean create(Investment inv) {
        String sql = "INSERT INTO investments "
                   + "(user_id, portfolio_id, asset_id, plan_name, invested_amount, current_value, "
                   + " units, buy_price, current_price, return_pct, status, notes) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0.0000, 'ACTIVE', ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, inv.getUserId());
            ps.setInt(2, inv.getPortfolioId());
            ps.setInt(3, inv.getAssetId());
            ps.setString(4, inv.getPlanName());
            ps.setBigDecimal(5, inv.getInvestedAmount());
            ps.setBigDecimal(6, inv.getInvestedAmount()); // current = invested initially
            ps.setBigDecimal(7, inv.getUnits());
            ps.setBigDecimal(8, inv.getBuyPrice());
            ps.setBigDecimal(9, inv.getBuyPrice());       // current = buy initially
            ps.setString(10, inv.getNotes());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) inv.setInvestmentId(keys.getInt(1));
                }
                // Recalculate portfolio value
                updatePortfolioValue(inv.getPortfolioId(), conn);
                updateWallet(inv.getUserId(), conn);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "investment create failed", e);
        }
        return false;
    }

    // ── Find by user ──────────────────────────────────────────────────────────
    public List<Investment> findByUser(int userId) {
        return queryInvestments(
            "SELECT i.*, p.portfolio_name, a.asset_name, a.asset_type, a.symbol AS asset_symbol "
          + "FROM investments i "
          + "JOIN portfolios p ON p.portfolio_id = i.portfolio_id "
          + "JOIN assets a ON a.asset_id = i.asset_id "
          + "WHERE i.user_id = ? ORDER BY i.invested_at DESC",
            userId);
    }

    // ── Find by portfolio ──────────────────────────────────────────────────────
    public List<Investment> findByPortfolio(int portfolioId) {
        return queryInvestments(
            "SELECT i.*, p.portfolio_name, a.asset_name, a.asset_type, a.symbol AS asset_symbol "
          + "FROM investments i "
          + "JOIN portfolios p ON p.portfolio_id = i.portfolio_id "
          + "JOIN assets a ON a.asset_id = i.asset_id "
          + "WHERE i.portfolio_id = ? ORDER BY i.invested_at DESC",
            portfolioId);
    }

    // ── Find by ID ────────────────────────────────────────────────────────────
    public Investment findById(int investmentId) {
        String sql = "SELECT i.*, p.portfolio_name, a.asset_name, a.asset_type, a.symbol AS asset_symbol "
                   + "FROM investments i "
                   + "JOIN portfolios p ON p.portfolio_id = i.portfolio_id "
                   + "JOIN assets a ON a.asset_id = i.asset_id "
                   + "WHERE i.investment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, investmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findById investment failed", e);
        }
        return null;
    }

    // ── Update current value & price ──────────────────────────────────────────
    public boolean updateValue(int investmentId, BigDecimal currentPrice, BigDecimal currentValue, BigDecimal returnPct) {
        String sql = "UPDATE investments SET current_price=?, current_value=?, return_pct=?, updated_at=NOW() "
                   + "WHERE investment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, currentPrice);
            ps.setBigDecimal(2, currentValue);
            ps.setBigDecimal(3, returnPct);
            ps.setInt(4, investmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "updateValue investment failed", e);
        }
        return false;
    }

    // ── Mark as SOLD ──────────────────────────────────────────────────────────
    public boolean sellInvestment(int investmentId, int userId) {
        String sql = "UPDATE investments SET status='SOLD', updated_at=NOW() "
                   + "WHERE investment_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, investmentId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "sellInvestment failed", e);
        }
        return false;
    }

    // ── Total invested amount by user ─────────────────────────────────────────
    public BigDecimal getTotalInvestedByUser(int userId) {
        String sql = "SELECT COALESCE(SUM(invested_amount),0) FROM investments WHERE user_id=? AND status='ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getTotalInvested failed", e);
        }
        return BigDecimal.ZERO;
    }

    // ── Total current value by user ───────────────────────────────────────────
    public BigDecimal getTotalCurrentValueByUser(int userId) {
        String sql = "SELECT COALESCE(SUM(current_value),0) FROM investments WHERE user_id=? AND status='ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getTotalCurrentValue failed", e);
        }
        return BigDecimal.ZERO;
    }

    // ── Count by user ─────────────────────────────────────────────────────────
    public int countByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM investments WHERE user_id=? AND status='ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "countByUser investments failed", e);
        }
        return 0;
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private List<Investment> queryInvestments(String sql, int param) {
        List<Investment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "queryInvestments failed", e);
        }
        return list;
    }

    private void updatePortfolioValue(int portfolioId, Connection conn) throws SQLException {
        String sql = "UPDATE portfolios SET current_value = "
                   + "(SELECT COALESCE(SUM(current_value),0) FROM investments "
                   + " WHERE portfolio_id=? AND status='ACTIVE') WHERE portfolio_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, portfolioId);
            ps.setInt(2, portfolioId);
            ps.executeUpdate();
        }
    }

    private void updateWallet(int userId, Connection conn) throws SQLException {
        String sql = "INSERT INTO user_wallet (user_id, total_invested, total_profit) "
                   + "SELECT ?, COALESCE(SUM(invested_amount),0), COALESCE(SUM(current_value - invested_amount),0) "
                   + "FROM investments WHERE user_id=? AND status='ACTIVE' "
                   + "ON DUPLICATE KEY UPDATE "
                   + "  total_invested = VALUES(total_invested), "
                   + "  total_profit   = VALUES(total_profit)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private Investment mapRow(ResultSet rs) throws SQLException {
        Investment inv = new Investment();
        inv.setInvestmentId(rs.getInt("investment_id"));
        inv.setUserId(rs.getInt("user_id"));
        inv.setPortfolioId(rs.getInt("portfolio_id"));
        inv.setPortfolioName(rs.getString("portfolio_name"));
        inv.setAssetId(rs.getInt("asset_id"));
        inv.setAssetName(rs.getString("asset_name"));
        inv.setAssetType(rs.getString("asset_type"));
        inv.setAssetSymbol(rs.getString("asset_symbol"));
        inv.setPlanName(rs.getString("plan_name"));
        inv.setInvestedAmount(rs.getBigDecimal("invested_amount"));
        inv.setCurrentValue(rs.getBigDecimal("current_value"));
        inv.setUnits(rs.getBigDecimal("units"));
        inv.setBuyPrice(rs.getBigDecimal("buy_price"));
        inv.setCurrentPrice(rs.getBigDecimal("current_price"));
        inv.setReturnPct(rs.getBigDecimal("return_pct"));
        inv.setStatus(rs.getString("status"));
        inv.setNotes(rs.getString("notes"));
        Timestamp ia = rs.getTimestamp("invested_at");
        if (ia != null) inv.setInvestedAt(ia.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) inv.setUpdatedAt(ua.toLocalDateTime());
        return inv;
    }
}
