# 🤖 AI Powered Investment Management System

> **A complete enterprise-grade investment management platform built with Java JSP, MySQL, and Apache Tomcat — featuring 5 intelligent AI engines, a premium dark dashboard UI, and full portfolio analytics.**

![Java](https://img.shields.io/badge/Java-17%2B-orange?style=for-the-badge&logo=openjdk)
![Tomcat](https://img.shields.io/badge/Tomcat-10.1-yellow?style=for-the-badge&logo=apachetomcat)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5-purple?style=for-the-badge&logo=bootstrap)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge)

---

## 🌟 Overview

**InvestMS** is a full-stack web application that empowers users to manage their investment portfolios with the help of artificial intelligence. Built using **Java Servlets + JSP** with a modern dark-themed UI inspired by premium SaaS analytics platforms.

### ✨ What Makes This Special?

- 🧠 **5 AI-Powered Features** — Smart recommendations, risk analysis, chatbot, portfolio analyzer, and intelligent reports
- 🎨 **Premium UI/UX** — Beautiful dark dashboard with red/pink gradients, Chart.js analytics
- 🔒 **Bank-Level Security** — SHA-256 password hashing, prepared statements, role-based access
- 💼 **Complete Portfolio Management** — Create portfolios, track investments, manage risk
- 💳 **Full Transaction System** — Deposits, withdrawals, buy/sell, dividends tracking
- 📊 **Real-Time Analytics** — Interactive charts, P&L tracking, return calculations
- 🌐 **Production-Ready** — Deployable to any Tomcat 10 server with XAMPP MySQL

---

## 🚀 Key Features

### 🔐 Authentication & User Management
- ✅ Secure user registration and login
- ✅ SHA-256 password hashing with random salt
- ✅ Session-based authentication
- ✅ Role-based access control (Admin / Investor)
- ✅ Profile management with password change

### 📊 Dashboard Analytics
- ✅ Real-time portfolio value tracking
- ✅ Interactive performance line charts (Chart.js)
- ✅ Asset allocation doughnut chart
- ✅ Wallet balance overview
- ✅ Profit/Loss summary cards
- ✅ Recent transactions activity feed
- ✅ Top performing investments list
- ✅ Quick AI feature access

### 💼 Portfolio Management
- ✅ Create unlimited portfolios
- ✅ Set risk levels (LOW / MEDIUM / HIGH)
- ✅ Target amount tracking with progress bars
- ✅ Edit/Update/Delete portfolios
- ✅ Real-time portfolio valuation
- ✅ Status tracking (ACTIVE / PAUSED / CLOSED)

### 💰 Investment Tracking
- ✅ Add investments to portfolios
- ✅ Track 10+ pre-loaded assets (stocks, crypto, bonds, ETFs, gold)
- ✅ Buy/Sell with automatic P&L calculation
- ✅ Real-time return percentage tracking
- ✅ Investment notes and history
- ✅ Filter by status (Active/Sold/Matured)

### 💳 Transaction Management
- ✅ Wallet deposits (Bank/Card/Crypto)
- ✅ Withdrawals with balance validation
- ✅ Quick amount selection buttons
- ✅ Complete transaction history
- ✅ Filter by type (Deposit/Withdrawal/Buy/Sell/Dividend)
- ✅ Search by reference number
- ✅ Auto-generated transaction IDs

---

## 🤖 The 5 AI Features

### 🧠 1. AI Investment Recommendation Engine
Analyzes user portfolio data and generates personalized **BUY / SELL / HOLD / REBALANCE / DIVERSIFY** recommendations with **confidence scores (0-100%)**. Considers asset performance, concentration risk, and diversification metrics.

### ⚠️ 2. AI Risk Predictor & Analyzer
Calculates a **composite risk score (0-100)** using:
- Weighted asset type risk ratings
- Portfolio concentration penalty
- P&L drawdown analysis
- Diversification bonus
Includes a beautiful visual gauge with risk-level recommendations.

### 💬 3. AI Financial Chat Assistant
Smart chatbot with **18+ investment topics** knowledge base. Answers contextual questions like:
- "How is my portfolio doing?"
- "What is diversification?"
- "Tell me about crypto risk"
- "What should I invest in?"
Uses real-time portfolio data for personalized answers.

### 📈 4. AI Portfolio Performance Analyzer
Deep portfolio analysis with **health score (0-100)** calculation:
- Asset diversity scoring
- Performance metrics
- Best/Worst performer identification
- Sector allocation breakdown
- Personalized improvement suggestions

### 📄 5. AI Intelligent Report Generator
Generates 4 types of professional reports:
- **📊 Performance Report** — Returns, P&L, investment breakdown
- **⚠️ Risk Assessment Report** — Risk scores, allocation analysis
- **❤️ Portfolio Health Report** — Health score, sector breakdown
- **🧾 Transaction Summary Report** — Cash flow analysis

---

## 🛠️ Technology Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Java 17, Jakarta EE 10 Servlets |
| **Frontend** | JSP, HTML5, CSS3, Bootstrap 5, JavaScript ES6 |
| **Charts** | Chart.js 4.4 |
| **Icons** | Font Awesome 6.5 |
| **Fonts** | Google Fonts (Inter) |
| **Database** | MySQL 8.0 |
| **Driver** | MySQL Connector/J 9.0 |
| **Server** | Apache Tomcat 10.1+ |
| **Build Tool** | Apache Ant (NetBeans) |
| **IDE** | NetBeans 17+ |
| **Local Dev** | XAMPP |

---

## 📁 Project Structure

```
Ai-investment-management/
│
├── 📂 src/java/com/investms/
│   ├── 🧠 ai/              # 5 AI Engine classes
│   │   ├── AIRecommendationEngine.java
│   │   ├── AIRiskAnalyzer.java
│   │   ├── AIChatbot.java
│   │   ├── AIPortfolioAnalyzer.java
│   │   └── AIReportGenerator.java
│   │
│   ├── 🗄️ dao/             # Data Access Objects
│   ├── 🔌 db/              # Database connection
│   ├── 🛡️ filter/          # Character encoding filter
│   ├── 📦 model/           # POJO classes
│   ├── 🌐 servlet/         # 10 HTTP servlet controllers
│   └── 🔧 util/            # Helper utilities
│
├── 📂 web/
│   ├── 🤖 ai/              # 5 AI feature pages
│   ├── 🔐 auth/            # Login, Register, Profile
│   ├── 📊 dashboard/       # Main dashboard
│   ├── 💼 portfolio/       # Portfolio CRUD pages
│   ├── 💰 investment/      # Investment pages
│   ├── 💳 transaction/     # Deposit/Withdraw/History
│   ├── 🧩 includes/        # Sidebar, Topnav, Footer
│   ├── 🎨 assets/          # CSS + JavaScript
│   ├── ⚠️ error/           # 404, 500, 403 pages
│   └── ⚙️ WEB-INF/         # web.xml, libs
│
└── 📂 sql/
    ├── investment_ms.sql      # Database schema
    └── sample_data.sql        # Test data
```

---

## 🗄️ Database Schema

11 normalized tables with proper relationships:

```
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│   users     │──┬──▶│  portfolios  │──┬──▶│ investments  │
└─────────────┘  │   └──────────────┘  │   └──────────────┘
                 │                      │           │
                 │                      │           ▼
                 │                      │   ┌──────────────┐
                 │                      └──▶│ transactions │
                 │                          └──────────────┘
                 │
                 ├──▶ ai_recommendations
                 ├──▶ chat_history  
                 ├──▶ user_wallet
                 ├──▶ notifications
                 └──▶ reports
                 
┌──────────┐       ┌───────────┐
│  roles   │       │  assets   │
└──────────┘       └───────────┘
```

**Tables:** `users`, `roles`, `portfolios`, `assets`, `investments`, `transactions`, `user_wallet`, `ai_recommendations`, `chat_history`, `notifications`, `reports`

**Includes:** Views (`vw_portfolio_summary`, `vw_user_investment_overview`) and stored procedures (`sp_update_portfolio_value`, `sp_update_wallet`)

---

## ⚡ Quick Start

### Prerequisites
- ☑️ Java JDK 17+
- ☑️ Apache Tomcat 10.1+
- ☑️ XAMPP (with MySQL)
- ☑️ NetBeans IDE 17+
- ☑️ MySQL Connector/J 9.0+

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/pugalMarxis/Ai-investment-management.git
```

**2. Setup Database**
- Open phpMyAdmin (`http://localhost/phpmyadmin`)
- Create database: `investment_ms`
- Import: `sql/investment_ms.sql`
- (Optional) Import: `sql/sample_data.sql` for test data

**3. Configure Tomcat** — Update `tomcat-users.xml`:
```xml
<role rolename="manager-script"/>
<user username="admin" password="admin" roles="manager-script"/>
```

**4. Add MySQL JAR** to `web/WEB-INF/lib/`

**5. Run in NetBeans**
- Open Project → Properties → Run
- Set Server: Apache Tomcat 10
- Set Java EE Version: Jakarta EE 10
- Right-click → Clean and Build → Run

**6. Access**
```
http://localhost:8080/Ai-investment-management/
```

### Default Login
| Field | Value |
|-------|-------|
| Email | `admin@investms.com` |
| Password | `Admin@123` |

---

## 🎯 Test Data Available

The `sample_data.sql` script creates:
- 👥 **6 users** (1 admin + 5 investors)
- 💼 **10 portfolios** across risk levels
- 💰 **33 investments** in stocks, crypto, bonds, ETFs
- 💳 **40+ transactions**
- 🤖 **10 AI recommendations**
- 🔔 **10 notifications**

All test passwords = `Admin@123`

| Test User | Best For |
|-----------|----------|
| `admin@investms.com` | Testing all features (admin) |
| `david@test.com` | Profitable diversified portfolio |
| `michael@test.com` | Aggressive tech investor |
| `emma@test.com` | Loss handling UI testing |
| `john@test.com` | Crypto + retirement mix |
| `sarah@test.com` | Balanced beginner |

---

## 📸 Features Showcase

### 🎨 Premium Dark Dashboard
- Modern enterprise SaaS-style UI
- Red/pink gradient highlights
- Smooth animations and transitions
- Fully responsive design

### 📊 Interactive Charts
- **Portfolio Performance** — Line chart with gradient fill
- **Asset Allocation** — Doughnut chart with legend
- **Risk Gauge** — SVG-based risk visualization
- **Sector Breakdown** — Horizontal bar charts
- **Performance Comparison** — Investment vs current value

### 🤖 AI Banner Examples
- "AI Engine Active — Analyzed 8 investments across 2 portfolios"
- "Portfolio Health: Excellent (87/100)"
- "Risk Analysis Complete — MODERATE risk detected"

---

## 🔒 Security Features

- 🔐 **SHA-256 password hashing** with random per-user salt
- 🛡️ **Prepared statements** (SQL injection prevention)
- 🍪 **HTTP-only cookies** for session management
- ⏱️ **30-minute session timeout**
- 🎭 **Role-based access** (Admin/Investor restrictions)
- ✅ **Input validation & sanitization** on all forms
- 🔄 **CSRF protection** ready (filter included)
- 📝 **Audit logging** through transactions table

---

## 🎓 Educational Value

This project demonstrates:
- ✅ Full **MVC architecture** (Model-View-Controller)
- ✅ **DAO pattern** for data access
- ✅ **POJO** (Plain Old Java Object) design
- ✅ **Servlet annotations** (@WebServlet, @WebFilter)
- ✅ **JSP includes** for layout reusability
- ✅ **Session management** in web apps
- ✅ **JDBC** with prepared statements
- ✅ **Connection pooling** ready
- ✅ **Chart.js integration** with Java backend
- ✅ **Bootstrap responsive design**
- ✅ **AI algorithm implementation** (rule-based)
- ✅ **Database normalization** (3NF)
- ✅ **Stored procedures and views**

Perfect for:
- 🎓 Computer Science final year projects
- 💼 Java EE portfolio projects  
- 📚 Learning enterprise Java patterns
- 🚀 Startup MVPs

---

## 🌍 Use Cases

- **🏦 FinTech Startups** — Base for investment apps
- **📚 University Projects** — Complete CS final year project
- **💼 Portfolio Pieces** — Show full-stack Java skills
- **🎯 Learning** — Study enterprise Java + AI integration
- **🔧 Customization** — Extend with real APIs (Alpha Vantage, etc.)

---

## 🚧 Future Enhancements

- [ ] Real-time stock prices via Alpha Vantage API
- [ ] PDF report export
- [ ] Email notifications
- [ ] Two-factor authentication
- [ ] Mobile-responsive PWA
- [ ] Multi-currency support
- [ ] Cryptocurrency live prices
- [ ] Advanced charting (candlesticks)
- [ ] Machine learning model integration
- [ ] REST API endpoints

---

## 📝 Documentation

- 📖 [Deployment Guide](DEPLOYMENT_GUIDE.md) — Complete setup instructions
- 🛠️ [NetBeans 29 Setup](SETUP_GUIDE_NETBEANS29.md) — IDE-specific guide
- 🗄️ Database schema in `sql/investment_ms.sql`
- 💾 Test data in `sql/sample_data.sql`

---

## 🤝 Contributing

This is an educational project. Feel free to:
- 🍴 Fork it
- 🐛 Report issues
- 💡 Suggest improvements
- 🔀 Submit pull requests
- ⭐ Star the repo if you find it useful!

---

## 📄 License

This project is open source and available for educational and personal use.

---

## 👤 Author

**pugalMarxis**

🔗 **GitHub:** [@pugalMarxis](https://github.com/pugalMarxis)

---

## 🎉 Show Your Support

If this project helped you, give it a ⭐ on GitHub!

---

## 📊 Project Stats

- 📁 **70+ files**
- 📝 **11,500+ lines of code**
- ☕ **40 Java classes**
- 📄 **20 JSP pages**  
- 🎨 **1,800+ lines of custom CSS**
- 🗄️ **11 database tables**
- 🤖 **5 AI engines**

---

> *Built with ❤️ using Java, JSP, MySQL, and a passion for clean code.*

---

## 🏆 Why This Project Stands Out

| Feature | This Project | Typical Student Project |
|---------|--------------|------------------------|
| AI Features | ✅ 5 working AI engines | ❌ None or 1 |
| UI Design | ✅ Premium dark dashboard | ❌ Plain Bootstrap |
| Database | ✅ 11 normalized tables + views | ❌ 3-5 simple tables |
| Code Quality | ✅ MVC + DAO patterns | ❌ Mixed logic |
| Security | ✅ Hashing + prepared statements | ❌ Plain text passwords |
| Charts | ✅ Interactive Chart.js | ❌ Static images |
| Documentation | ✅ Complete guides | ❌ Minimal |
| Test Data | ✅ Realistic sample data | ❌ Empty database |

---

**🚀 Ready to revolutionize how you manage investments? Get started today!**
