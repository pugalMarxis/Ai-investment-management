package com.investms.servlet;

import com.investms.dao.UserDAO;
import com.investms.model.User;
import com.investms.util.PasswordUtil;
import com.investms.util.SessionUtil;
import com.investms.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Handles profile updates and password changes.
 */
@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        User loggedUser = SessionUtil.getLoggedUser(req);
        String action   = req.getParameter("action");

        if ("updateProfile".equals(action)) {
            String fullName = req.getParameter("fullName");
            String phone    = req.getParameter("phone");

            if (ValidationUtil.isNullOrEmpty(fullName)) {
                req.setAttribute("error", "Full name is required.");
                req.getRequestDispatcher("/auth/profile.jsp").forward(req, resp);
                return;
            }

            loggedUser.setFullName(fullName.trim());
            loggedUser.setPhone(phone != null ? phone.trim() : "");

            if (userDAO.updateProfile(loggedUser)) {
                // Refresh session user
                User refreshed = userDAO.findById(loggedUser.getUserId());
                if (refreshed != null) SessionUtil.loginUser(req, refreshed);
                req.setAttribute("success", "Profile updated successfully!");
            } else {
                req.setAttribute("error", "Failed to update profile. Please try again.");
            }
            req.getRequestDispatcher("/auth/profile.jsp").forward(req, resp);

        } else if ("changePassword".equals(action)) {
            String currentPwd  = req.getParameter("currentPassword");
            String newPwd      = req.getParameter("newPassword");
            String confirmPwd  = req.getParameter("confirmPassword");

            if (!PasswordUtil.verifyPassword(currentPwd, loggedUser.getPasswordHash())) {
                req.setAttribute("error", "Current password is incorrect.");
                req.getRequestDispatcher("/auth/profile.jsp").forward(req, resp);
                return;
            }

            if (!ValidationUtil.isStrongPassword(newPwd)) {
                req.setAttribute("error",
                    "New password must be 8+ characters with uppercase, lowercase, number, and symbol.");
                req.getRequestDispatcher("/auth/profile.jsp").forward(req, resp);
                return;
            }

            if (!newPwd.equals(confirmPwd)) {
                req.setAttribute("error", "Passwords do not match.");
                req.getRequestDispatcher("/auth/profile.jsp").forward(req, resp);
                return;
            }

            String newHash = PasswordUtil.hashPassword(newPwd);
            if (userDAO.updatePassword(loggedUser.getUserId(), newHash)) {
                // Force re-login
                SessionUtil.logoutUser(req);
                resp.sendRedirect(req.getContextPath() + "/auth/login.jsp?passwordChanged=true");
            } else {
                req.setAttribute("error", "Password update failed. Please try again.");
                req.getRequestDispatcher("/auth/profile.jsp").forward(req, resp);
            }
        }
    }
}
