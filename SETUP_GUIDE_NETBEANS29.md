# Complete Setup Guide for Your Versions
## NetBeans 29 + Tomcat 10 + XAMPP + MySQL

---

## YOUR EXACT VERSIONS
- **NetBeans:** 29
- **Tomcat:** 10.1.x
- **XAMPP:** Apache + MySQL
- **Java:** 17+
- **Servlet API:** jakarta.servlet (Tomcat 10 requirement)

---

## STEP 1 — Download Project from GitHub

1. Go to: https://github.com/pugalMarxis/Ai-investment-management
2. Click `<> Code` -> Download ZIP
3. Extract to: `C:\Projects\Ai-investment-management`

---

## STEP 2 — Setup Tomcat 10 (FIX AUTHENTICATION!)

### 2.1 Open this file in Notepad:
```
C:\apache-tomcat-10\conf\tomcat-users.xml
```

### 2.2 Replace EVERYTHING with this content:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>

  <user username="admin" password="admin"
        roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>

</tomcat-users>
```

### 2.3 Save the file with Ctrl + S

---

## STEP 3 — XAMPP Setup

### 3.1 Open XAMPP Control Panel
### 3.2 STOP Apache (because Tomcat will use the same port)
### 3.3 START MySQL (keep this running)

---

## STEP 4 — Import Database

### 4.1 Open browser: http://localhost/phpmyadmin
### 4.2 Click "New" on left
### 4.3 Database name: `investment_ms`
### 4.4 Click "Create"
### 4.5 Click on `investment_ms` in left panel
### 4.6 Click "Import" tab
### 4.7 Choose File: `Ai-investment-management/sql/investment_ms.sql`
### 4.8 Click "Go"

---

## STEP 5 — Add MySQL JAR

Download: https://dev.mysql.com/downloads/connector/j/
- Choose: Platform Independent
- Download ZIP
- Extract

Copy `mysql-connector-j-9.0.0.jar` into:
```
C:\Projects\Ai-investment-management\web\WEB-INF\lib\
```

---

## STEP 6 — Open Project in NetBeans

### 6.1 File -> Open Project
### 6.2 Select `C:\Projects\Ai-investment-management`
### 6.3 Click "Open Project"

---

## STEP 7 — Setup Tomcat in NetBeans

### 7.1 Click Services tab (left side)
### 7.2 Right-click "Apache Tomcat or TomEE" -> Remove Server (if exists)
### 7.3 Right-click "Servers" -> Add Server

### 7.4 Select "Apache Tomcat or TomEE" -> Next

### 7.5 Fill in EXACTLY:
- Catalina Home: `C:\apache-tomcat-10`
- Catalina Base: (leave empty or same as Home)
- Username: `admin`
- Password: `admin`

### 7.6 Click Finish

---

## STEP 8 — Set Server for Project

### 8.1 Right-click "Ai-investment-management" project
### 8.2 Click Properties
### 8.3 Click "Run" on left
### 8.4 Server: Select "Apache Tomcat or TomEE"
### 8.5 Java EE Version: Select "Jakarta EE 10 Web"
### 8.6 Context Path: `/Ai-investment-management`
### 8.7 Click OK

---

## STEP 9 — Add MySQL JAR to NetBeans Libraries

### 9.1 In Projects panel, right-click "Libraries"
### 9.2 Click "Add JAR/Folder"
### 9.3 Navigate to: `web\WEB-INF\lib\mysql-connector-j-9.0.0.jar`
### 9.4 Click "Add JAR"

---

## STEP 10 — Run

### 10.1 Right-click project -> Clean and Build
### 10.2 Wait for "BUILD SUCCESSFUL"
### 10.3 Right-click project -> Run
### 10.4 Browser opens automatically at:
```
http://localhost:8080/Ai-investment-management/
```

---

## STEP 11 — Login

| Field | Value |
|-------|-------|
| Email | admin@investms.com |
| Password | Admin@123 |

---

## TROUBLESHOOTING

### Port 8080 already in use
- STOP XAMPP Apache
- Or open Task Manager -> end java.exe processes

### Authentication failed
- Make sure tomcat-users.xml has user `admin` / `admin`
- In NetBeans server properties, set username `admin` and password `admin`
- Stop and start the server again

### BUILD FAILED  
- Check JAR is added to Libraries
- Run Clean and Build first

### 404 Page Not Found
- Check Context Path is `/Ai-investment-management`
- Make sure MySQL is running

### Cannot connect to database
- Check XAMPP MySQL is running
- Re-import sql script

---

## FINAL CHECK

```
[ ] tomcat-users.xml updated with admin/admin
[ ] XAMPP MySQL running
[ ] XAMPP Apache STOPPED (port conflict)  
[ ] Database investment_ms imported
[ ] MySQL JAR in web/WEB-INF/lib/
[ ] Tomcat 10 added in NetBeans
[ ] Project properties Run tab configured
[ ] Server username/password = admin/admin
[ ] Clean and Build = SUCCESS
[ ] Run = Browser opens
```
