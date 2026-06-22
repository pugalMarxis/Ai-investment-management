package com.investms.servlet;

import com.investms.dao.NotificationDAO;
import com.investms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Notification management servlet.
 */
@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notifDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        int userId = SessionUtil.getLoggedUserId(req);
        String action = req.getParameter("action");

        if ("markAllRead".equals(action)) {
            notifDAO.markAllRead(userId);
        }

        // Redirect back to referrer or dashboard
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard/dashboard.jsp");
        }
    }
}
