package com.investms.model;

import java.time.LocalDateTime;

/**
 * System notification for a user.
 */
public class Notification {

    private int           notifId;
    private int           userId;
    private String        title;
    private String        message;
    private String        type;       // INFO | SUCCESS | WARNING | DANGER
    private boolean       read;
    private LocalDateTime createdAt;

    public Notification() {}

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int           getNotifId()               { return notifId; }
    public void          setNotifId(int v)           { this.notifId = v; }

    public int           getUserId()                { return userId; }
    public void          setUserId(int v)            { this.userId = v; }

    public String        getTitle()                 { return title; }
    public void          setTitle(String v)          { this.title = v; }

    public String        getMessage()               { return message; }
    public void          setMessage(String v)        { this.message = v; }

    public String        getType()                  { return type; }
    public void          setType(String v)           { this.type = v; }

    public boolean       isRead()                   { return read; }
    public void          setRead(boolean v)          { this.read = v; }

    public LocalDateTime getCreatedAt()              { return createdAt; }
    public void          setCreatedAt(LocalDateTime v) { this.createdAt = v; }

    // ── Helpers ───────────────────────────────────────────────────────────────

    public String getAlertClass() {
        switch (type == null ? "" : type.toUpperCase()) {
            case "SUCCESS": return "alert-success";
            case "WARNING": return "alert-warning";
            case "DANGER":  return "alert-danger";
            default:        return "alert-info";
        }
    }
}
