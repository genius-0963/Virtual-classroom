# Virtual Classroom (Production-Ready)

A Java/JSP-based Virtual Classroom learning portal with role-based access for Students, Teachers (Faculty), and Administrators, secured and orchestrated with Nginx, Apache Tomcat 9, and MySQL 8.

---

## Architecture

* **Edge Gateway / Reverse Proxy**: Nginx (Port 80) with Gzip compression, rate limiting, and HTTP security headers (`X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`).
* **Application Server**: Apache Tomcat 9 (Port 8080) running JavaServer Pages with Tomcat JDBC Connection Pooling.
* **Database**: MySQL 8.0 (Port 3306) with automated database initialization, dedicated application user, and scheduled backups.

---

## Quick Start

### 1. Start the Complete Stack
```bash
./start.sh
```
Or via Docker Compose:
```bash
docker compose up -d --build
```

### 2. Access the Application
* **Primary Gateway (Nginx Reverse Proxy)**:
  ```
  http://localhost
  ```
* **Direct Tomcat Access**:
  ```
  http://localhost:8080
  ```

### 3. Default Credentials
* **Admin Login**:
  * URL: `http://localhost/admin_login.jsp`
  * Password: `Mypasswordis2425`
* **Student Registration**:
  * URL: `http://localhost/student_register.jsp`
  * Register with Roll Number, Name, Email, Password, Degree, Course, and Year.
  * Requires Admin approval at `http://localhost/admin_student_requests.jsp`.
* **Faculty Registration**:
  * URL: `http://localhost/faculty_register.jsp`
  * Register with Name, Username, Email, Password, Degree, Course, Year, and Subject.
  * Requires Admin approval at `http://localhost/admin_faculty_requests.jsp`.

### 4. Database Backups
Create an immediate snapshot of the MySQL database:
```bash
./backup-db.sh
```
Backups are saved to the `backups/` directory.

### 5. Stop the Application
```bash
./stop.sh
```

---

## 4-Phase Enhancements Implemented

### Phase 1: Security Hardening & Safe Hashing
- **Salted PBKDF2 Hashing**: Replaced deprecated `SHA1` with salted `PBKDF2WithHmacSHA256` (65,536 iterations, 16-byte random salt). Legacy SHA1 hashes are transparently verified and auto-upgraded upon login.
- **XSS Sanitization**: Centralized `escapeHtml()` protection across all user outputs.
- **Session Hardening**: Enforced `HttpOnly=true` on `JSESSIONID` cookies, cookie-only session tracking, and strict session timeouts.
- **Environment Secrets**: Decoupled database passwords into [.env](file:///Users/subh/Desktop/virtual-class/Virtual-Classroom/.env) and [.env.example](file:///Users/subh/Desktop/virtual-class/Virtual-Classroom/.env.example).

### Phase 2: Performance & Connection Pooling
- **Tomcat JDBC Connection Pool**: Pooled connections with validation queries (`SELECT 1`), idle eviction, and connection recycling.
- **Dedicated Database User**: Created restricted `vclass_user` for standard application operations instead of executing queries as `root`.

### Phase 3: Dynamic Features
- **Interactive Q&A Forum ([qna.jsp](file:///Users/subh/Desktop/virtual-class/Virtual-Classroom/qna.jsp))**: Post real questions and reply with answers stored dynamically in MySQL.
- **Dynamic Study Materials ([study-material.jsp](file:///Users/subh/Desktop/virtual-class/Virtual-Classroom/study-material.jsp))**: Faculty can publish resources, notes, and external links; students can access and download materials filtered by degree/subject.
- **User Management Hub ([admin_users.jsp](file:///Users/subh/Desktop/virtual-class/Virtual-Classroom/admin_users.jsp))**: Administrator can inspect active enrolled students and faculty, with account removal controls.

### Phase 4: Production Infrastructure
- **Nginx Reverse Proxy**: Configured in [nginx/default.conf](file:///Users/subh/Desktop/virtual-class/Virtual-Classroom/nginx/default.conf) with Gzip compression and security headers.
- **Automated Backup Utility ([backup-db.sh](file:///Users/subh/Desktop/virtual-class/Virtual-Classroom/backup-db.sh))**: Creates standalone SQL dumps on demand.
