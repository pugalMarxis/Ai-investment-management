<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.User" %>
<%@ page import="com.investms.dao.NotificationDAO" %>
<%
    User topUser = SessionUtil.getLoggedUser(request);
    int unreadCount = 0;
    if (topUser != null) {
        NotificationDAO nDao = new NotificationDAO();
        unreadCount = nDao.countUnread(topUser.getUserId());
    }
%>
<!-- ═══════════════════════════════════════════════════
     TOP NAVIGATION BAR
═══════════════════════════════════════════════════ -->
<header class="topnav" id="topnav">

    <!-- Left: Hamburger + Page Title -->
    <div class="topnav-left">
        <button class="sidebar-toggle" id="sidebarToggle" title="Toggle Sidebar">
            <i class="fas fa-bars"></i>
        </button>
        <div class="page-breadcrumb">
            <span class="breadcrumb-icon"><i class="fas fa-home"></i></span>
            <span class="breadcrumb-sep">/</span>
            <span class="breadcrumb-page" id="pageTitleBreadcrumb">Dashboard</span>
        </div>
    </div>

    <!-- Right: search, notifications, user -->
    <div class="topnav-right">

        <!-- Search -->
        <div class="topnav-search">
            <i class="fas fa-search search-icon"></i>
            <input type="text" class="search-input" placeholder="Search...">
        </div>

        <!-- Notifications -->
        <div class="topnav-item dropdown" id="notifDropdown">
            <button class="topnav-btn" onclick="toggleDropdown('notifMenu')">
                <i class="fas fa-bell"></i>
                <% if (unreadCount > 0) { %>
                <span class="badge-notif"><%= unreadCount %></span>
                <% } %>
            </button>
            <div class="dropdown-menu notif-menu" id="notifMenu">
                <div class="dropdown-header">
                    <span>Notifications</span>
                    <a href="<%= request.getContextPath() %>/NotificationServlet?action=markAllRead"
                       class="mark-read-link">Mark all read</a>
                </div>
                <div class="notif-list" id="notifList">
                    <div class="notif-empty">
                        <i class="fas fa-bell-slash"></i>
                        <p>No new notifications</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- User Menu -->
        <div class="topnav-item dropdown">
            <button class="user-menu-btn" onclick="toggleDropdown('userMenu')">
                <div class="user-avatar-top">
                    <%= topUser != null ? topUser.getInitials() : "?" %>
                </div>
                <div class="user-menu-info">
                    <span class="user-menu-name">
                        <%= topUser != null ? topUser.getFullName() : "Guest" %>
                    </span>
                    <span class="user-menu-role">
                        <%= topUser != null ? topUser.getRoleName() : "" %>
                    </span>
                </div>
                <i class="fas fa-chevron-down chevron-icon"></i>
            </button>
            <div class="dropdown-menu user-dropdown" id="userMenu">
                <a href="<%= request.getContextPath() %>/auth/profile.jsp" class="dropdown-item">
                    <i class="fas fa-user"></i> My Profile
                </a>
                <a href="<%= request.getContextPath() %>/transaction/transactions.jsp" class="dropdown-item">
                    <i class="fas fa-wallet"></i> Wallet
                </a>
                <div class="dropdown-divider"></div>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="dropdown-item text-danger">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>

    </div>
</header>
<!-- END TOPNAV -->
