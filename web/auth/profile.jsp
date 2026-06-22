<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.User" %>
<%@ page import="com.investms.dao.TransactionDAO" %>
<%@ page import="com.investms.dao.InvestmentDAO" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }
    User profileUser = SessionUtil.getLoggedUser(request);
    TransactionDAO tDao  = new TransactionDAO();
    InvestmentDAO  iDao  = new InvestmentDAO();
    BigDecimal walletBal  = tDao.getWalletBalance(profileUser.getUserId());
    BigDecimal totalInv   = iDao.getTotalInvestedByUser(profileUser.getUserId());
    int invCount          = iDao.countByUser(profileUser.getUserId());

    String success = (String) request.getAttribute("success");
    String error   = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>My Profile — InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
</head>
<body class="app-body">

<div class="app-layout">
    <%@ include file="/includes/sidebar.jsp" %>

    <div class="main-content">
        <%@ include file="/includes/topnav.jsp" %>

        <div class="content-area">
            <div class="page-header">
                <div>
                    <h1 class="page-title">My Profile</h1>
                    <p class="page-subtitle">Manage your personal information</p>
                </div>
            </div>

            <% if (success != null) { %>
            <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i><%= success %></div>
            <% } %>
            <% if (error != null) { %>
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i><%= error %></div>
            <% } %>

            <div class="row">
                <!-- Profile Card -->
                <div class="col-lg-4 mb-4">
                    <div class="card-panel text-center">
                        <div class="profile-avatar-large">
                            <%= profileUser.getInitials() %>
                        </div>
                        <h3 class="profile-name"><%= profileUser.getFullName() %></h3>
                        <p class="profile-email"><%= profileUser.getEmail() %></p>
                        <span class="badge badge-role-lg"><%= profileUser.getRoleName() %></span>

                        <div class="profile-stats mt-4">
                            <div class="profile-stat">
                                <span class="stat-value">$<%= String.format("%,.2f", walletBal) %></span>
                                <span class="stat-label">Wallet Balance</span>
                            </div>
                            <div class="profile-stat">
                                <span class="stat-value">$<%= String.format("%,.2f", totalInv) %></span>
                                <span class="stat-label">Total Invested</span>
                            </div>
                            <div class="profile-stat">
                                <span class="stat-value"><%= invCount %></span>
                                <span class="stat-label">Investments</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Edit Profile -->
                <div class="col-lg-8 mb-4">
                    <div class="card-panel">
                        <h4 class="card-panel-title">Edit Profile</h4>
                        <form action="<%= request.getContextPath() %>/ProfileServlet"
                              method="POST" class="profile-form">
                            <input type="hidden" name="action" value="updateProfile">

                            <div class="form-group-custom">
                                <label class="form-label-custom">Full Name</label>
                                <div class="input-wrapper">
                                    <i class="fas fa-user input-icon"></i>
                                    <input type="text" name="fullName" class="form-input"
                                           value="<%= profileUser.getFullName() %>" required>
                                </div>
                            </div>

                            <div class="form-group-custom">
                                <label class="form-label-custom">Email (read-only)</label>
                                <div class="input-wrapper">
                                    <i class="fas fa-envelope input-icon"></i>
                                    <input type="email" class="form-input"
                                           value="<%= profileUser.getEmail() %>" disabled>
                                </div>
                            </div>

                            <div class="form-group-custom">
                                <label class="form-label-custom">Phone Number</label>
                                <div class="input-wrapper">
                                    <i class="fas fa-phone input-icon"></i>
                                    <input type="tel" name="phone" class="form-input"
                                           value="<%= profileUser.getPhone() != null ? profileUser.getPhone() : "" %>">
                                </div>
                            </div>

                            <button type="submit" class="btn-primary-custom">
                                <i class="fas fa-save me-2"></i>Save Changes
                            </button>
                        </form>

                        <hr class="divider-line">

                        <h4 class="card-panel-title">Change Password</h4>
                        <form action="<%= request.getContextPath() %>/ProfileServlet"
                              method="POST" class="profile-form">
                            <input type="hidden" name="action" value="changePassword">

                            <div class="form-group-custom">
                                <label class="form-label-custom">Current Password</label>
                                <div class="input-wrapper">
                                    <i class="fas fa-lock input-icon"></i>
                                    <input type="password" name="currentPassword"
                                           class="form-input" placeholder="Enter current password" required>
                                </div>
                            </div>

                            <div class="form-row-two">
                                <div class="form-group-custom">
                                    <label class="form-label-custom">New Password</label>
                                    <div class="input-wrapper">
                                        <i class="fas fa-lock input-icon"></i>
                                        <input type="password" name="newPassword"
                                               class="form-input" placeholder="New password" required>
                                    </div>
                                </div>
                                <div class="form-group-custom">
                                    <label class="form-label-custom">Confirm New Password</label>
                                    <div class="input-wrapper">
                                        <i class="fas fa-lock input-icon"></i>
                                        <input type="password" name="confirmPassword"
                                               class="form-input" placeholder="Confirm" required>
                                    </div>
                                </div>
                            </div>

                            <button type="submit" class="btn-danger-custom">
                                <i class="fas fa-key me-2"></i>Update Password
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

</body>
</html>
