package com.investms.dao;

import com.investms.db.DBConnection;
import com.investms.model.Asset;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for the assets table.
 */
public class AssetDAO {

    private static final Logger LOGGER = Logger.getLogger(AssetDAO.class.getName());

    public List<Asset> findAll() {
        List<Asset> list = new ArrayList<>();
        String sql = "SELECT * FROM assets ORDER BY asset_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "AssetDAO.findAll failed", e);
        }
        return list;
    }

    public Asset findById(int assetId) {
        String sql = "SELECT * FROM assets WHERE asset_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "AssetDAO.findById failed", e);
        }
        return null;
    }

    public List<Asset> findByType(String assetType) {
        List<Asset> list = new ArrayList<>();
        String sql = "SELECT * FROM assets WHERE asset_type = ? ORDER BY asset_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, assetType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "AssetDAO.findByType failed", e);
        }
        return list;
    }

    private Asset mapRow(ResultSet rs) throws SQLException {
        Asset a = new Asset();
        a.setAssetId(rs.getInt("asset_id"));
        a.setAssetName(rs.getString("asset_name"));
        a.setAssetType(rs.getString("asset_type"));
        a.setSymbol(rs.getString("symbol"));
        a.setDescription(rs.getString("description"));
        a.setRiskRating(rs.getInt("risk_rating"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        return a;
    }
}
