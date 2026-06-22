package com.investms.util;

import com.investms.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Session management helpers — login, logout, role checks, redirects.
 */
public class SessionUtil {

    public static final String SESSION_USER     = "loggedUser";
    public static final String SESSION_USER_ID  = "userId";
    public static final String SESSION_ROLE     = "userRole";
    public static final int    SESSION_TIMEOUT  = 1800; // 30 minutes

    private SessionUtil() {}

    /** Store user in session after successful login. */
    public static void loginUser(HttpServletRequest req, User user) {
        HttpSession session = req.getSession(true);
        session.setMaxInactiveInterval(SESSION_TIMEOUT);
        session.setAttribute(SESSION_USER,    user);
        session.setAttribute(SESSION_USER_ID, user.getUserId());
        session.setAttribute(SESSION_ROLE,    user.getRoleName());
    }

    /** Clear session on logout. */
    public static void logoutUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }

    /** Returns true if a user is logged in. */
    public static boolean isLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute(SESSION_USER) != null;
    }

    /** Returns the logged-in User object, or null. */
    public static User getLoggedUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute(SESSION_USER);
    }

    /** Returns logged-in user ID, or -1. */
    public static int getLoggedUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return -1;
        Object id = session.getAttribute(SESSION_USER_ID);
        return (id instanceof Integer) ? (Integer) id : -1;
    }

    /** Returns role name of logged-in user, or empty string. */
    public static String getLoggedUserRole(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return "";
        Object role = session.getAttribute(SESSION_ROLE);
        return role != null ? role.toString() : "";
    }

    /** Redirect to login if not authenticated. */
    public static boolean requireLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return false;
        }
        return true;
    }

    /** Redirect to dashboard if not ADMIN. */
    public static boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!requireLogin(req, resp)) return false;
        if (!"ADMIN".equalsIgnoreCase(getLoggedUserRole(req))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/dashboard.jsp");
            return false;
        }
        return true;
    }
}
