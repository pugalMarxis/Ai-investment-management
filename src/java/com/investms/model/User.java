package com.investms.model;

import java.time.LocalDateTime;

/**
 * Represents a system user (Admin or Investor).
 */
public class User {

    private int           userId;
    private String        fullName;
    private String        email;
    private String        passwordHash;
    private String        phone;
    private int           roleId;
    private String        roleName;   // joined from roles table
    private String        status;
    private String        profilePic;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Constructors ──────────────────────────────────────────────────────────

    public User() {}

    public User(int userId, String fullName, String email, String roleName, String status) {
        this.userId   = userId;
        this.fullName = fullName;
        this.email    = email;
        this.roleName = roleName;
        this.status   = status;
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int           getUserId()       { return userId; }
    public void          setUserId(int v)  { this.userId = v; }

    public String        getFullName()          { return fullName; }
    public void          setFullName(String v)  { this.fullName = v; }

    public String        getEmail()          { return email; }
    public void          setEmail(String v)  { this.email = v; }

    public String        getPasswordHash()          { return passwordHash; }
    public void          setPasswordHash(String v)  { this.passwordHash = v; }

    public String        getPhone()          { return phone; }
    public void          setPhone(String v)  { this.phone = v; }

    public int           getRoleId()        { return roleId; }
    public void          setRoleId(int v)   { this.roleId = v; }

    public String        getRoleName()          { return roleName; }
    public void          setRoleName(String v)  { this.roleName = v; }

    public String        getStatus()          { return status; }
    public void          setStatus(String v)  { this.status = v; }

    public String        getProfilePic()          { return profilePic; }
    public void          setProfilePic(String v)  { this.profilePic = v; }

    public LocalDateTime getCreatedAt()           { return createdAt; }
    public void          setCreatedAt(LocalDateTime v) { this.createdAt = v; }

    public LocalDateTime getUpdatedAt()           { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v) { this.updatedAt = v; }

    // ── Helpers ───────────────────────────────────────────────────────────────

    public boolean isAdmin()    { return "ADMIN".equalsIgnoreCase(roleName); }
    public boolean isActive()   { return "ACTIVE".equalsIgnoreCase(status); }
    public String  getInitials() {
        if (fullName == null || fullName.isEmpty()) return "?";
        String[] parts = fullName.trim().split("\\s+");
        return parts.length >= 2
               ? ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
               : ("" + parts[0].charAt(0)).toUpperCase();
    }

    @Override
    public String toString() {
        return "User{userId=" + userId + ", email='" + email + "', role='" + roleName + "'}";
    }
}
