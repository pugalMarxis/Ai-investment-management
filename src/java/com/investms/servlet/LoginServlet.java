package com.investms.servlet;

import com.investms.dao.UserDAO;
import com.investms.model.User;
import com.investms.util.PasswordUtil;
import com.investms.util.SessionUtil;
import com.investms.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Handles user login — GET shows form, POST processes credentials.
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Already logged in → go to dashboard
        if (SessionUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/dashboard.jsp");
            return;
        }
        req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        // ── Basic validation ───────────────────────────────────────────────
        if (ValidationUtil.isNullOrEmpty(email) || ValidationUtil.isNullOrEmpty(password)) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
            return;
        }

        if (!ValidationUtil.isValidEmail(email)) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
            return;
        }

        // ── Look up user ───────────────────────────────────────────────────
        User user = userDAO.findByEmail(email.trim().toLowerCase());

        if (user == null || !PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            req.setAttribute("error", "Invalid email or password.");
            req.setAttribute("emailValue", ValidationUtil.sanitize(email));
            req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
            return;
        }

        if (!user.isActive()) {
            req.setAttribute("error", "Your account is " + user.getStatus().toLowerCase()
                    + ". Please contact support.");
            req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
            return;
        }

        // ── Create session ─────────────────────────────────────────────────
        SessionUtil.loginUser(req, user);

        // Redirect based on role
        if (user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/dashboard.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard/dashboard.jsp");
        }
    }
}
