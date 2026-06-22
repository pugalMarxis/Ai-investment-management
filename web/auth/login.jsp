<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%
    // Redirect if already logged in
    if (SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/dashboard/dashboard.jsp");
        return;
    }
    String error     = (String) request.getAttribute("error");
    String emailVal  = request.getAttribute("emailValue") != null
                       ? (String) request.getAttribute("emailValue") : "";
    boolean loggedOut   = "true".equals(request.getParameter("logout"));
    boolean registered  = "true".equals(request.getParameter("registered"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Login — InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
    <style>
        body { background: #0d0d1a; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
    </style>
</head>
<body class="auth-body">

<div class="auth-wrapper">

    <!-- Left panel — branding -->
    <div class="auth-left">
        <div class="auth-brand-section">
            <div class="auth-logo">
                <i class="fas fa-chart-line"></i>
            </div>
            <h1 class="auth-brand-name">InvestMS</h1>
            <p class="auth-brand-tagline">AI Powered Investment Management</p>
            <div class="auth-features">
                <div class="auth-feature-item">
                    <i class="fas fa-robot"></i>
                    <span>AI-Driven Recommendations</span>
                </div>
                <div class="auth-feature-item">
                    <i class="fas fa-shield-alt"></i>
                    <span>Risk Analysis & Prediction</span>
                </div>
                <div class="auth-feature-item">
                    <i class="fas fa-chart-pie"></i>
                    <span>Smart Portfolio Analytics</span>
                </div>
                <div class="auth-feature-item">
                    <i class="fas fa-lock"></i>
                    <span>Bank-Level Security</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Right panel — form -->
    <div class="auth-right">
        <div class="auth-card">

            <div class="auth-card-header">
                <h2>Welcome Back</h2>
                <p>Sign in to your investment account</p>
            </div>

            <!-- Alert messages -->
            <% if (loggedOut) { %>
            <div class="alert alert-success alert-dismissible">
                <i class="fas fa-check-circle me-2"></i>You have been logged out successfully.
            </div>
            <% } %>
            <% if (registered) { %>
            <div class="alert alert-success alert-dismissible">
                <i class="fas fa-check-circle me-2"></i>Registration successful! Please sign in.
            </div>
            <% } %>
            <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible">
                <i class="fas fa-exclamation-circle me-2"></i><%= error %>
            </div>
            <% } %>

            <!-- Login Form -->
            <form action="<%= request.getContextPath() %>/LoginServlet"
                  method="POST" class="auth-form" novalidate>

                <div class="form-group-custom">
                    <label class="form-label-custom">Email Address</label>
                    <div class="input-wrapper">
                        <i class="fas fa-envelope input-icon"></i>
                        <input type="email"
                               name="email"
                               class="form-input"
                               placeholder="you@example.com"
                               value="<%= emailVal %>"
                               required autocomplete="email">
                    </div>
                </div>

                <div class="form-group-custom">
                    <div class="label-row">
                        <label class="form-label-custom">Password</label>
                        <a href="#" class="forgot-link">Forgot password?</a>
                    </div>
                    <div class="input-wrapper">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password"
                               name="password"
                               id="loginPassword"
                               class="form-input"
                               placeholder="Enter your password"
                               required autocomplete="current-password">
                        <button type="button"
                                class="toggle-password"
                                onclick="togglePassword('loginPassword', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-check-custom">
                    <input type="checkbox" id="rememberMe" name="rememberMe" class="form-check-input-custom">
                    <label for="rememberMe">Remember me</label>
                </div>

                <button type="submit" class="btn-auth-primary">
                    <i class="fas fa-sign-in-alt me-2"></i>Sign In
                </button>

                <div class="auth-divider"><span>or</span></div>

                <p class="auth-switch-text">
                    Don't have an account?
                    <a href="<%= request.getContextPath() %>/RegisterServlet" class="auth-link">
                        Create Account
                    </a>
                </p>

            </form>

            <!-- Demo credentials hint -->
            <div class="demo-hint">
                <i class="fas fa-info-circle"></i>
                <span>Demo: <strong>admin@investms.com</strong> / <strong>Admin@123</strong></span>
            </div>

        </div>
    </div>

</div>

<script>
function togglePassword(fieldId, btn) {
    const field = document.getElementById(fieldId);
    const icon  = btn.querySelector('i');
    if (field.type === 'password') {
        field.type = 'text';
        icon.classList.replace('fa-eye', 'fa-eye-slash');
    } else {
        field.type = 'password';
        icon.classList.replace('fa-eye-slash', 'fa-eye');
    }
}
</script>

</body>
</html>
