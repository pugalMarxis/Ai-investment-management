package com.investms.dao;

import com.investms.db.DBConnection;
import com.investms.model.Portfolio;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for portfolios (uses the vw_portfolio_summary view).
 */
public class PortfolioDAO {

    private static final Logger LOGGER = Logger.getLogger(PortfolioDAO.class.getName());

    // ── Create portfolio ──────────────────────────────────────────────────────
    public boolean create(Portfolio p) {
        String sql = "INSERT INTO portfolios (user_id, portfolio_name, description, risk_level, target_amount, status) "
                   + "VALUES (?, ?, ?, ?, ?, 'ACTIVE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, p.getUserId());
            ps.setString(2, p.getPortfolioName());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getRiskLevel());
            ps.setBigDecimal(5, p.getTargetAmount());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) p.setPortfolioId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Portfolio create failed", e);
        }
        return false;
    }

    // ── Find portfolios by user (with summary from view) ──────────────────────
    public List<Portfolio> findByUser(int userId) {
        List<Portfolio> list = new ArrayList<>();
        String sql = "SELECT * FROM vw_portfolio_summary WHERE user_id = ? ORDER BY portfolio_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapViewRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findByUser portfolios failed", e);
        }
        return list;
    }

    // ── Find all portfolios (admin) ───────────────────────────────────────────
    public List<Portfolio> findAll() {
        List<Portfolio> list = new ArrayList<>();
        String sql = "SELECT * FROM vw_portfolio_summary ORDER BY portfolio_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapViewRow(rs));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findAll portfolios failed", e);
        }
        return list;
    }

    // ── Find by ID ────────────────────────────────────────────────────────────
    public Portfolio findById(int portfolioId) {
        String sql = "SELECT * FROM vw_portfolio_summary WHERE portfolio_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, portfolioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapViewRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findById portfolio failed", e);
        }
        return null;
    }

    // ── Update portfolio ──────────────────────────────────────────────────────
    public boolean update(Portfolio p) {
        String sql = "UPDATE portfolios SET portfolio_name=?, description=?, risk_level=?, target_amount=?, status=? "
                   + "WHERE portfolio_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getPortfolioName());
            ps.setString(2, p.getDescription());
            ps.setString(3, p.getRiskLevel());
            ps.setBigDecimal(4, p.getTargetAmount());
            ps.setString(5, p.getStatus());
            ps.setInt(6, p.getPortfolioId());
            ps.setInt(7, p.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "portfolio update failed", e);
        }
        return false;
    }

    // ── Delete portfolio ──────────────────────────────────────────────────────
    public boolean delete(int portfolioId, int userId) {
        String sql = "DELETE FROM portfolios WHERE portfolio_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, portfolioId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "portfolio delete failed", e);
        }
        return false;
    }

    // ── Count by user ─────────────────────────────────────────────────────────
    public int countByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM portfolios WHERE user_id=? AND status='ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "countByUser portfolio failed", e);
        }
        return 0;
    }

    // ── ResultSet mapper from view ────────────────────────────────────────────
    private Portfolio mapViewRow(ResultSet rs) throws SQLException {
        Portfolio p = new Portfolio();
        p.setPortfolioId(rs.getInt("portfolio_id"));
        p.setUserId(rs.getInt("user_id"));
        p.setUserFullName(rs.getString("full_name"));
        p.setPortfolioName(rs.getString("portfolio_name"));
        p.setRiskLevel(rs.getString("risk_level"));
        p.setTargetAmount(rs.getBigDecimal("target_amount"));
        p.setCurrentValue(rs.getBigDecimal("current_value"));
        p.setStatus(rs.getString("status"));
        p.setTotalInvestments(rs.getInt("total_investments"));

        BigDecimal ti = rs.getBigDecimal("total_invested");
        p.setTotalInvested(ti != null ? ti : BigDecimal.ZERO);

        BigDecimal tc = rs.getBigDecimal("total_current_value");
        p.setTotalCurrentValue(tc != null ? tc : BigDecimal.ZERO);

        BigDecimal tpl = rs.getBigDecimal("total_profit_loss");
        p.setTotalProfitLoss(tpl != null ? tpl : BigDecimal.ZERO);

        BigDecimal rp = rs.getBigDecimal("return_pct");
        p.setReturnPct(rp != null ? rp : BigDecimal.ZERO);
        return p;
    }
}
