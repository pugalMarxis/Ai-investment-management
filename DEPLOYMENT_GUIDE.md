# InvestMS — Complete Deployment Guide
## AI Powered Investment Management System

---

## SYSTEM REQUIREMENTS

| Component         | Version           |
|-------------------|-------------------|
| Java JDK          | 17 or higher      |
| Apache Tomcat     | 10.1+ (Jakarta EE)|
| MySQL (XAMPP)     | 8.0+              |
| NetBeans IDE      | 17 or higher      |
| MySQL Connector/J | 9.0.0             |
| Browser           | Chrome/Firefox/Edge (latest) |

---

## STEP 1 — INSTALL XAMPP & START SERVICES

1. Download and install **XAMPP** from https://www.apachefriends.org
2. Open **XAMPP Control Panel**
3. Start **Apache** and **MySQL** services
4. Verify MySQL is running on port **3306**

---

## STEP 2 — SET UP THE DATABASE

1. Open **phpMyAdmin**: http://localhost/phpmyadmin
2. Click **"New"** to create a database (or use the SQL tab)
3. Run the SQL script:
   - Go to **Import** tab
   - Click **"Choose File"**
   - Select `InvestmentMS/sql/investment_ms.sql`
   - Click **"Go"**
4. Verify these tables were created:
   - roles, users, portfolios, assets, investments
   - transactions, ai_recommendations, reports
   - notifications, chat_history, user_wallet

**Default Admin Account:**
- Email: `admin@investms.com`
- Password: `Admin@123`

---

## STEP 3 — DOWNLOAD REQUIRED LIBRARIES

### MySQL Connector/J
1. Download from: https://dev.mysql.com/downloads/connector/j/
2. Select **"Platform Independent"** → Download ZIP
3. Extract and copy `mysql-connector-j-X.X.X.jar`

### Jakarta Servlet API (provided by Tomcat)
- Already included in Tomcat's `lib/` folder
- No download needed

### Place JAR files:
```
InvestmentMS/
└── web/
    └── WEB-INF/
        └── lib/
            └── mysql-connector-j-9.0.0.jar   ← Place here
```

Also copy to:
```
InvestmentMS/
└── libs/
    └── mysql-connector-j-9.0.0.jar            ← For compile classpath
```

---

## STEP 4 — CONFIGURE NETBEANS PROJECT

1. Open **NetBeans IDE**
2. Go to **File → Open Project**
3. Navigate to the `InvestmentMS` folder
4. NetBeans will detect it as a Web Application project
5. Click **Open Project**

### Add MySQL Connector to Project:
1. Right-click **Libraries** in the project
2. Click **"Add JAR/Folder"**
3. Select `mysql-connector-j-9.0.0.jar`
4. Click **Add**

### Configure Tomcat Server:
1. Go to **Tools → Servers**
2. Click **"Add Server"**
3. Select **"Apache Tomcat or TomEE"**
4. Browse to your Tomcat installation folder
5. Click **Next → Finish**

---

## STEP 5 — VERIFY DATABASE CONNECTION

Open `src/java/com/investms/db/DBConnection.java`:

```java
private static final String URL = "jdbc:mysql://localhost:3306/investment_ms"
                                 + "?useSSL=false&serverTimezone=UTC";
private static final String USER     = "root";
private static final String PASSWORD = "";   // Change if you set a MySQL password
```

If you set a MySQL password in XAMPP, update `PASSWORD` here.

---

## STEP 6 — BUILD & RUN

### Option A — Run from NetBeans (Recommended)
1. Right-click project → **"Clean and Build"**
2. Right-click project → **"Run"**
3. NetBeans will deploy to Tomcat automatically
4. Browser opens at: `http://localhost:8080/InvestmentMS`

### Option B — Deploy WAR manually
1. Right-click project → **"Clean and Build"**
2. Find the WAR file: `InvestmentMS/dist/InvestmentMS.war`
3. Copy WAR to Tomcat's `webapps/` folder
4. Start Tomcat
5. Access: `http://localhost:8080/InvestmentMS`

---

## STEP 7 — FIRST LOGIN

1. Open: http://localhost:8080/InvestmentMS
2. You'll be redirected to the **Login page**
3. Use the default admin account:
   - **Email:** `admin@investms.com`
   - **Password:** `Admin@123`
4. Or **Register** a new investor account

---

## PROJECT FOLDER STRUCTURE (Complete)

```
InvestmentMS/
│
├── sql/
│   └── investment_ms.sql               ← Run this in phpMyAdmin
│
├── src/java/
│   └── com/investms/
│       ├── db/
│       │   └── DBConnection.java        ← Database connection
│       │
│       ├── model/
│       │   ├── User.java
│       │   ├── Portfolio.java
│       │   ├── Investment.java
│       │   ├── Asset.java
│       │   ├── Transaction.java
│       │   ├── AiRecommendation.java
│       │   └── Notification.java
│       │
│       ├── dao/
│       │   ├── UserDAO.java
│       │   ├── PortfolioDAO.java
│       │   ├── InvestmentDAO.java
│       │   ├── TransactionDAO.java
│       │   ├── AssetDAO.java
│       │   ├── NotificationDAO.java
│       │   └── AiRecommendationDAO.java
│       │
│       ├── servlet/
│       │   ├── LoginServlet.java
│       │   ├── RegisterServlet.java
│       │   ├── LogoutServlet.java
│       │   ├── ProfileServlet.java
│       │   ├── DashboardServlet.java
│       │   ├── PortfolioServlet.java
│       │   ├── InvestmentServlet.java
│       │   ├── TransactionServlet.java
│       │   ├── NotificationServlet.java
│       │   └── AIServlet.java
│       │
│       ├── ai/
│       │   ├── AIRecommendationEngine.java  ← AI Feature #1
│       │   ├── AIRiskAnalyzer.java          ← AI Feature #2
│       │   ├── AIChatbot.java               ← AI Feature #3
│       │   ├── AIPortfolioAnalyzer.java     ← AI Feature #4
│       │   └── AIReportGenerator.java       ← AI Feature #5
│       │
│       ├── filter/
│       │   └── CharacterEncodingFilter.java
│       │
│       └── util/
│           ├── PasswordUtil.java
│           ├── SessionUtil.java
│           └── ValidationUtil.java
│
├── web/
│   ├── index.jsp                           ← Root redirect
│   │
│   ├── WEB-INF/
│   │   ├── web.xml                         ← Servlet configuration
│   │   ├── context.xml                     ← Tomcat context
│   │   └── lib/
│   │       └── mysql-connector-j-9.0.0.jar ← Place here!
│   │
│   ├── assets/
│   │   ├── css/
│   │   │   └── style.css                   ← Main stylesheet
│   │   └── js/
│   │       └── main.js                     ← Main JavaScript
│   │
│   ├── includes/
│   │   ├── head.jsp
│   │   ├── sidebar.jsp
│   │   ├── topnav.jsp
│   │   └── footer.jsp
│   │
│   ├── auth/
│   │   ├── login.jsp
│   │   ├── register.jsp
│   │   └── profile.jsp
│   │
│   ├── dashboard/
│   │   └── dashboard.jsp
│   │
│   ├── portfolio/
│   │   ├── portfolios.jsp
│   │   ├── add-portfolio.jsp
│   │   └── edit-portfolio.jsp
│   │
│   ├── investment/
│   │   ├── investments.jsp
│   │   ├── add-investment.jsp
│   │   └── view-investment.jsp
│   │
│   ├── transaction/
│   │   ├── transactions.jsp
│   │   ├── deposit.jsp
│   │   └── withdraw.jsp
│   │
│   ├── ai/
│   │   ├── recommendations.jsp
│   │   ├── risk-analyzer.jsp
│   │   ├── chatbot.jsp
│   │   ├── portfolio-analyzer.jsp
│   │   └── reports.jsp
│   │
│   └── error/
│       ├── 404.jsp
│       ├── 500.jsp
│       └── 403.jsp
│
├── nbproject/
│   ├── project.xml
│   └── project.properties
│
├── build.xml
└── DEPLOYMENT_GUIDE.md
```

---

## COMMON TROUBLESHOOTING

### "ClassNotFoundException: com.mysql.cj.jdbc.Driver"
- MySQL Connector JAR is missing from `WEB-INF/lib/`
- Add it via: Right-click Libraries → Add JAR/Folder

### "Access denied for user 'root'@'localhost'"
- MySQL password is wrong
- Update `PASSWORD` in `DBConnection.java`

### "Table 'investment_ms.users' doesn't exist"
- Database not imported
- Re-run `investment_ms.sql` in phpMyAdmin

### "HTTP Status 404 — /InvestmentMS"
- Project not deployed
- Right-click project → Run, or check Tomcat logs

### "Cannot connect to database" on startup
- Ensure XAMPP MySQL is running
- Check port 3306 is not blocked

### Password login fails for admin
- The default admin uses SHA-256 hashing
- Re-insert with PasswordUtil.hashPassword("Admin@123")

---

## AI FEATURES GUIDE

| Feature              | URL                              | Description                          |
|----------------------|----------------------------------|--------------------------------------|
| AI Recommendations   | /AIServlet?action=recommendations| BUY/SELL/HOLD advice with confidence |
| Risk Analyzer        | /AIServlet?action=risk           | Portfolio risk score 0–100           |
| AI Chatbot           | /AIServlet?action=chatbot        | Ask investment questions             |
| Portfolio Analyzer   | /AIServlet?action=portfolio-analyzer | Health score + sector analysis  |
| AI Reports           | /AIServlet?action=reports        | Generate 4 types of AI reports       |

---

## SECURITY NOTES FOR PRODUCTION

1. Change MySQL password and update `DBConnection.java`
2. Enable HTTPS on Tomcat
3. Set `<secure>true</secure>` in web.xml cookie-config
4. Replace SHA-256 password with BCrypt (add bcrypt dependency)
5. Set strong session secret in Tomcat's `server.xml`
6. Enable CSRF protection filter
7. Set proper CORS headers

---

## TECHNOLOGY STACK SUMMARY

| Layer        | Technology                |
|--------------|---------------------------|
| Frontend     | JSP, HTML5, CSS3, Bootstrap 5, Chart.js |
| Backend      | Java Servlets (Jakarta EE 10) |
| Database     | MySQL 8.0 with XAMPP      |
| Server       | Apache Tomcat 10.1+       |
| AI Engine    | Java rule-based engine (no external API) |
| Styling      | Custom CSS dark theme      |
| IDE          | NetBeans 17+              |

---

*InvestmentMS v1.0.0 — AI Powered Investment Management*
*Built with Java + JSP + MySQL + Apache Tomcat*
