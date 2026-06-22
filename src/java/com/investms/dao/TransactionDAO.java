package com.investms.dao;

import com.investms.db.DBConnection;
import com.investms.model.Transaction;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for the transactions table.
 */
public class TransactionDAO {

    private static final Logger LOGGER = Logger.getLogger(TransactionDAO.class.getName());

    // ── Create transaction ────────────────────────────────────────────────────
    public boolean create(Transaction txn) {
        String sql = "INSERT INTO transactions "
                   + "(user_id, investment_id, type, amount, fee, balance_after, description, status, reference_no) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        if (txn.getReferenceNo() == null || txn.getReferenceNo().isEmpty()) {
            txn.setReferenceNo("TXN-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase());
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, txn.getUserId());
            if (txn.getInvestmentId() != null) ps.setInt(2, txn.getInvestmentId());
            else ps.setNull(2, Types.INTEGER);
            ps.setString(3, txn.getType());
            ps.setBigDecimal(4, txn.getAmount());
            ps.setBigDecimal(5, txn.getFee() != null ? txn.getFee() : BigDecimal.ZERO);
            ps.setBigDecimal(6, txn.getBalanceAfter() != null ? txn.getBalanceAfter() : BigDecimal.ZERO);
            ps.setString(7, txn.getDescription());
            ps.setString(8, txn.getStatus() != null ? txn.getStatus() : "COMPLETED");
            ps.setString(9, txn.getReferenceNo());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) txn.setTransactionId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "transaction create failed", e);
        }
        return false;
    }

    // ── Find by user (recent 100) ─────────────────────────────────────────────
    public List<Transaction> findByUser(int userId) {
        return queryTransactions(
            "SELECT t.*, u.full_name AS user_full_name, i.plan_name "
          + "FROM transactions t "
          + "JOIN users u ON u.user_id = t.user_id "
          + "LEFT JOIN investments i ON i.investment_id = t.investment_id "
          + "WHERE t.user_id = ? ORDER BY t.created_at DESC LIMIT 100",
            userId);
    }

    // ── Find all (admin) ──────────────────────────────────────────────────────
    public List<Transaction> findAll() {
        List<Transaction> list = new ArrayList<>();
        String sql = "SELECT t.*, u.full_name AS user_full_name, i.plan_name "
                   + "FROM transactions t "
                   + "JOIN users u ON u.user_id = t.user_id "
                   + "LEFT JOIN investments i ON i.investment_id = t.investment_id "
                   + "ORDER BY t.created_at DESC LIMIT 200";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "findAll transactions failed", e);
        }
        return list;
    }

    // ── Find by type & user ───────────────────────────────────────────────────
    public List<Transaction> findByUserAndType(int userId, String type) {
        return queryTransactions(
            "SELECT t.*, u.full_name AS user_full_name, i.plan_name "
          + "FROM transactions t "
          + "JOIN users u ON u.user_id = t.user_id "
          + "LEFT JOIN investments i ON i.investment_id = t.investment_id "
          + "WHERE t.user_id = ? AND t.type = ? ORDER BY t.created_at DESC",
            userId, type);
    }

    // ── Deposit (updates wallet balance) ─────────────────────────────────────
    public boolean deposit(int userId, BigDecimal amount, String description) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Get current balance
                BigDecimal current = getWalletBalance(userId, conn);
                BigDecimal newBalance = current.add(amount);

                // Update wallet
                updateWalletBalance(userId, newBalance, conn);

                // Record transaction
                Transaction txn = new Transaction();
                txn.setUserId(userId);
                txn.setType("DEPOSIT");
                txn.setAmount(amount);
                txn.setBalanceAfter(newBalance);
                txn.setDescription(description);
                txn.setStatus("COMPLETED");
                insertTxn(txn, conn);

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "deposit failed", e);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "deposit connection failed", e);
        }
        return false;
    }

    // ── Withdrawal ────────────────────────────────────────────────────────────
    public boolean withdraw(int userId, BigDecimal amount, String description) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                BigDecimal current = getWalletBalance(userId, conn);
                if (current.compareTo(amount) < 0) {
                    conn.rollback();
                    return false; // insufficient funds
                }
                BigDecimal newBalance = current.subtract(amount);
                updateWalletBalance(userId, newBalance, conn);

                Transaction txn = new Transaction();
                txn.setUserId(userId);
                txn.setType("WITHDRAWAL");
                txn.setAmount(amount);
                txn.setBalanceAfter(newBalance);
                txn.setDescription(description);
                txn.setStatus("COMPLETED");
                insertTxn(txn, conn);

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "withdrawal failed", e);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "withdrawal connection failed", e);
        }
        return false;
    }

    // ── Wallet balance ────────────────────────────────────────────────────────
    public BigDecimal getWalletBalance(int userId) {
        try (Connection conn = DBConnection.getConnection()) {
            return getWalletBalance(userId, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getWalletBalance failed", e);
            return BigDecimal.ZERO;
        }
    }

    // ── Total deposited ───────────────────────────────────────────────────────
    public BigDecimal getTotalDeposited(int userId) {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM transactions "
                   + "WHERE user_id=? AND type='DEPOSIT' AND status='COMPLETED'";
        return querySingleDecimal(sql, userId);
    }

    // ── Total withdrawn ───────────────────────────────────────────────────────
    public BigDecimal getTotalWithdrawn(int userId) {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM transactions "
                   + "WHERE user_id=? AND type='WITHDRAWAL' AND status='COMPLETED'";
        return querySingleDecimal(sql, userId);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private BigDecimal getWalletBalance(int userId, Connection conn) throws SQLException {
        String sql = "SELECT COALESCE(balance,0) FROM user_wallet WHERE user_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        }
        return BigDecimal.ZERO;
    }

    private void updateWalletBalance(int userId, BigDecimal newBalance, Connection conn) throws SQLException {
        String sql = "INSERT INTO user_wallet (user_id, balance) VALUES (?,?) "
                   + "ON DUPLICATE KEY UPDATE balance=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setBigDecimal(2, newBalance);
            ps.setBigDecimal(3, newBalance);
            ps.executeUpdate();
        }
    }

    private void insertTxn(Transaction txn, Connection conn) throws SQLException {
        if (txn.getReferenceNo() == null) {
            txn.setReferenceNo("TXN-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase());
        }
        String sql = "INSERT INTO transactions "
                   + "(user_id, investment_id, type, amount, fee, balance_after, description, status, reference_no) "
                   + "VALUES (?,?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, txn.getUserId());
            if (txn.getInvestmentId() != null) ps.setInt(2, txn.getInvestmentId());
            else ps.setNull(2, Types.INTEGER);
            ps.setString(3, txn.getType());
            ps.setBigDecimal(4, txn.getAmount());
            ps.setBigDecimal(5, BigDecimal.ZERO);
            ps.setBigDecimal(6, txn.getBalanceAfter());
            ps.setString(7, txn.getDescription());
            ps.setString(8, txn.getStatus());
            ps.setString(9, txn.getReferenceNo());
            ps.executeUpdate();
        }
    }

    private List<Transaction> queryTransactions(String sql, int param) {
        List<Transaction> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "queryTransactions(1) failed", e);
        }
        return list;
    }

    private List<Transaction> queryTransactions(String sql, int userId, String type) {
        List<Transaction> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "queryTransactions(2) failed", e);
        }
        return list;
    }

    private BigDecimal querySingleDecimal(String sql, int userId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "querySingleDecimal failed", e);
        }
        return BigDecimal.ZERO;
    }

    private Transaction mapRow(ResultSet rs) throws SQLException {
        Transaction t = new Transaction();
        t.setTransactionId(rs.getInt("transaction_id"));
        t.setUserId(rs.getInt("user_id"));
        t.setUserFullName(rs.getString("user_full_name"));
        int invId = rs.getInt("investment_id");
        if (!rs.wasNull()) t.setInvestmentId(invId);
        t.setPlanName(rs.getString("plan_name"));
        t.setType(rs.getString("type"));
        t.setAmount(rs.getBigDecimal("amount"));
        t.setFee(rs.getBigDecimal("fee"));
        t.setBalanceAfter(rs.getBigDecimal("balance_after"));
        t.setDescription(rs.getString("description"));
        t.setStatus(rs.getString("status"));
        t.setReferenceNo(rs.getString("reference_no"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) t.setCreatedAt(ca.toLocalDateTime());
        return t;
    }
}
