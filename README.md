# Virtual Classroom — System Architecture & Production Deployment Guide

A multi academic management portal and learning management system (LMS) built on JavaServer Pages (JSP), Apache Tomcat 9, MySQL 8.0, and an Nginx reverse proxy edge gateway.

The application implements role-based access control (RBAC) across Students, Faculty, and System Administrators, backed by connection-pooled database interactions, transparent cryptographic password migration, and containerized deployment.


## 1. System Architecture

### 1.1 Infrastructure Topology

The deployment comprises three isolated containerized tiers interconnected via a private Docker bridge network (`virtual_classroom_default`). Only the Nginx edge gateway and development ports are exposed to the host machine.

```mermaid
flowchart TD
    subgraph Client ["Client Layer"]
        Browser["Web Browser (HTTP / HTTPS)"]
    end

    subgraph Host ["Host Network"]
        subgraph DockerBridge ["Docker Bridge Network (virtual_classroom_default)"]
            subgraph NginxProxy ["Reverse Proxy Container (virtual_classroom_nginx)"]
                Nginx["Nginx 1.25 Alpine<br/>Port: 80"]
            end

            subgraph TomcatApp ["Application Container (virtual_classroom_web)"]
                Tomcat["Apache Tomcat 9.0 (JVM OpenJDK 11)<br/>Port: 8080"]
                subgraph AppRuntime ["ROOT Web Application"]
                    Pages["JSP Endpoints / Scriptlets"]
                    Pool["Tomcat JDBC Connection Pool<br/>org.apache.tomcat.jdbc.pool"]
                end
            end

            subgraph DatabaseContainer ["Database Container (virtual_classroom_db)"]
                MySQL["MySQL 8.0 InnoDB Engine<br/>Port: 3306"]
            end
        end
    end

    subgraph HostStorage ["Persistent Storage / Bind Mounts"]
        VolumeData[("mysql_data<br/>Docker Volume")]
        BindCode["Host Codebase<br/>(./ -> /usr/local/tomcat/webapps/ROOT)"]
        BindNginx["nginx/default.conf<br/>(Host -> /etc/nginx/conf.d/:ro)"]
        BindInit["project_DB.sql<br/>(Host -> /docker-entrypoint-initdb.d/)"]
        Backups["Host backups/<br/>(SQL Snapshots)"]
    end

    Browser -->|HTTP Port 80| Nginx
    Nginx -->|Reverse Proxy HTTP 8080| Tomcat
    Tomcat --> Pages
    Pages --> Pool
    Pool -->|TCP / MySQL Protocol 3306| MySQL

    MySQL --> VolumeData
    BindInit -.->|Initial Seed| MySQL
    BindNginx -.->|Read-Only Mount| Nginx
    BindCode -.->|Live Reload Mount| Tomcat
    MySQL -.->|mysqldump via backup-db.sh| Backups
```


## . Database Schema & Data Models

### 3.1 Entity-Relationship Diagram (ERD)

The database `project` consists of 7 normalized tables managing identity, curriculum boundaries, collaborative learning, and educational assets:

```mermaid
erDiagram
    admin {
        int id PK "auto_increment"
        varchar password "PBKDF2 salt:hash or legacy SHA-1"
    }

    enroll_for {
        varchar degree "Degree identifier (e.g., B.Sc, M.Sc)"
        varchar course "Course specialization (e.g., Data Science)"
    }

    student {
        varchar roll_no PK "Unique Roll Number"
        varchar name "Student Full Name"
        varchar password "PBKDF2 salted hash"
        varchar email_id "Student Email Address"
        varchar degree "Enrolled Degree"
        varchar course "Enrolled Course"
        int year "Current Academic Year (1-3)"
        boolean is_approved "Admin Approval Status (0 or 1)"
        timestamp created_at "Registration Timestamp"
    }

    faculty {
        varchar subject PK "Teaching Subject Key"
        varchar username UK "Unique Faculty Handle"
        varchar name "Faculty Full Name"
        varchar password "PBKDF2 salted hash"
        varchar email_id "Faculty Email Address"
        varchar degree "Department Degree"
        varchar course "Department Course"
        int year "Target Year (1-3)"
        boolean is_approved "Admin Approval Status (0 or 1)"
        timestamp created_at "Registration Timestamp"
    }

    questions {
        int id PK "auto_increment"
        varchar author_name "Display Name of Poster"
        varchar author_role "Role identifier: student | faculty | admin"
        varchar subject "Course Subject"
        varchar title "Question Title"
        text content "Question Description"
        timestamp created_at "Creation Timestamp"
    }

    answers {
        int id PK "auto_increment"
        int question_id FK "References questions(id)"
        varchar author_name "Display Name of Responder"
        varchar author_role "Role identifier: student | faculty | admin"
        text content "Answer Body"
        timestamp created_at "Creation Timestamp"
    }

    study_materials {
        int id PK "auto_increment"
        varchar title "Document / Lecture Title"
        varchar subject "Curriculum Subject"
        varchar degree "Target Degree (or 'All')"
        text description "Overview / Syllabus Mapping"
        varchar resource_url "Direct URI / External Reference"
        varchar uploaded_by "Uploader Name"
        timestamp created_at "Upload Timestamp"
    }

    questions ||--o{ answers : "has answers (CASCADE DELETE)"
```


## . Security Architecture

###  Password Hashing & Transparent Migration

Passwords are processed through a cryptographic layer in `db.jspf`. To maintain backwards compatibility with legacy SHA-1 database hashes without compromising security, the system employs **transparent on-login re-hashing**:

```mermaid
flowchart TD
    Start["User Submits Credentials (Username/Roll No + Password)"] --> FetchDB["Query User Record via PreparedStatement"]
    FetchDB --> Exists{"Record Found?"}
    Exists -- No --> ErrCreds["Reject: Invalid Credentials"]
    Exists -- Yes --> CheckFormat{"Stored Hash contains ':' delimiter?"}

    CheckFormat -- "Yes (PBKDF2 Format)" --> VerifyPBKDF2["Split into Salt + Hash<br/>Compute PBKDF2WithHmacSHA256<br/>(65,536 iterations, 16-byte salt)<br/>Verify via MessageDigest.isEqual()"]
    CheckFormat -- "No (Legacy SHA-1)" --> VerifySHA1["Compute SHA-1 digest<br/>Compare with stored hex string"]

    VerifyPBKDF2 --> PBKDF2Match{"Hash Matches?"}
    PBKDF2Match -- No --> ErrCreds
    PBKDF2Match -- Yes --> CheckApproval{"is_approved == 1?"}

    VerifySHA1 --> SHA1Match{"Hash Matches?"}
    SHA1Match -- No --> ErrCreds
    SHA1Match -- Yes --> TriggerUpgrade["Transparent Upgrade Triggered:<br/>Generate 16-byte SecureRandom salt<br/>Compute PBKDF2WithHmacSHA256<br/>Execute UPDATE to store salt:hash"]
    TriggerUpgrade --> CheckApproval

    CheckApproval -- No --> ErrPending["Reject: Account Pending Admin Approval"]
    CheckApproval -- Yes --> CreateSession["Create HttpSession<br/>Set User Session Attributes<br/>Issue HttpOnly JSESSIONID"]
    CreateSession --> RedirectDashboard["Redirect to Role Dashboard"]
```

#### Cryptographic Parameters
- **Algorithm**: `PBKDF2WithHmacSHA256`
- **Key Length**: 128 bits
- **Iteration Count**: 65,536 iterations
- **Salt Generation**: 16 bytes via `java.security.SecureRandom`
- **Timing Attack Mitigation**: Uses `MessageDigest.isEqual()` for constant-time byte comparisons.
- **Storage Format**: `Base64(salt) + ":" + Base64(hash)` (fits within `VARCHAR(255)`).

### 4.2 Session Management

Session configuration is enforced at the container level in `WEB-INF/web.xml`:

```xml
<session-config>
    <session-timeout>60</session-timeout>
    <cookie-config>
        <http-only>true</http-only>
        <name>JSESSIONID</name>
    </cookie-config>
    <tracking-mode>COOKIE</tracking-mode>
</session-config>
```

- **`http-only=true`**: Eliminates client-side JavaScript access to `JSESSIONID`, mitigating session hijacking via XSS.
- **`tracking-mode=COOKIE`**: Disables URL rewriting (e.g., `;jsessionid=...`), avoiding session leakage in HTTP referrers and server access logs.
- **Session Expiry**: 60-minute inactivity threshold.



### HTTP Security Headers

Nginx injects baseline security headers on every outbound HTTP response:

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

---

## 5. Role-Based Access Control (RBAC) & Lifecycle

### 5.1 User Registration & Approval State Machine

Students and Faculty cannot access the platform immediately upon registration. All accounts pass through an administrative approval workflow before credentials become active:

```mermaid
stateDiagram-v2
    [*] --> Unregistered: User Visits Registration Page
    Unregistered --> PendingApproval: Submit Form (student_register.jsp / faculty_register.jsp)
    
    state PendingApproval {
        [*] --> InReviewQueue: Insert record into DB with is_approved = 0
        InReviewQueue --> LoginRejected: User Attempts Login
        LoginRejected --> InReviewQueue: Display 'Request pending approval'
    }

    PendingApproval --> ActiveUser: Admin approves in admin_*_requests.jsp<br/>(UPDATE is_approved = 1)
    PendingApproval --> [*]: Admin rejects request<br/>(DELETE FROM table)

    state ActiveUser {
        [*] --> AuthenticatedSession: Valid credentials supplied
        AuthenticatedSession --> AccessFeatures: Access Dashboard, Q&A, Study Materials
        AuthenticatedSession --> SessionTerminated: Logout / 60m Inactivity
        SessionTerminated --> [*]
    }

    ActiveUser --> [*]: Admin removes account via admin_users.jsp
```

### 5.2 Role Matrix

| Capability / Resource | Guest / Public | Student | Faculty | Admin |
| :--- | :---: | :---: | :---: | :---: |
| View Landing Page & Course Catalogs (`index.jsp`) | Yes | Yes | Yes | Yes |
| Submit Account Registration | Yes | No | No | No |
| Access Student Dashboard (`student_dashboard.jsp`) | No | Yes | No | No |
| Access Faculty Dashboard (`faculty_dashboard.jsp`) | No | No | Yes | No |
| Access Admin Dashboard (`admin_dashboard.jsp`) | No | No | No | Yes |
| Browse & Download Study Materials (`study-material.jsp`) | No | Yes | Yes | Yes |
| Publish New Study Materials (`study-material.jsp`) | No | No | Yes | Yes |
| Post Q&A Discussion Questions (`qna.jsp`) | No | Yes | Yes | Yes |
| Submit Answers to Discussion Questions (`qna.jsp`) | No | Yes | Yes | Yes |
| Approve / Reject Student Requests (`admin_student_requests.jsp`)| No | No | No | Yes |
| Approve / Reject Faculty Requests (`admin_faculty_requests.jsp`)| No | No | No | Yes |
| Revoke / Delete User Accounts (`admin_users.jsp`) | No | No | No | Yes |

---

## 6. Configuration & Environment Variables

All runtime credentials and port bindings are decoupled into `.env` (derived from `.env.example`). The stack loads these parameters into the Docker Compose orchestration context:

| Variable | Default Value | Scope | Description |
| :--- | :--- | :--- | :--- |
| `MYSQL_ROOT_PASSWORD` | `Mypasswordis2425` | `db`, backup scripts | Administrative password for MySQL `root` user. |
| `MYSQL_DATABASE` | `project` | `db` | Default database instantiated on first initialization. |
| `MYSQL_USER` | `vclass_user` | `db`, `web` | Restricted application database username. |
| `MYSQL_PASSWORD` | `VClassSecret2026!` | `db`, `web` | Password assigned to `MYSQL_USER`. |
| `DB_HOST` | `db` | `web` | Hostname of the database container within Docker bridge network. |
| `DB_PORT` | `3306` | `web` | MySQL service listening port inside the network. |
| `DB_NAME` | `project` | `web` | Target database catalog name. |
| `DB_USER` | `vclass_user` | `web` | Username consumed by Tomcat JDBC connection pool. |
| `DB_PASSWORD` | `VClassSecret2026!` | `web` | Database password consumed by Tomcat connection pool. |
| `WEB_PORT` | `8080` | Host -> `web` | Host port mapped directly to Tomcat for development inspection. |
| `HTTP_PORT` | `80` | Host -> `nginx` | Host port mapped to Nginx reverse proxy (primary entrypoint). |

---

## 7. Operational Runbook

### 7.1 Prerequisites

- **Docker Engine**: Version 20.10.0+
- **Docker Compose**: Version 2.0.0+ (Compose V2)
- **Bash Shell**: For executing `./start.sh`, `./stop.sh`, and `./backup-db.sh`.
- **Curl**: Required by `start.sh` to poll application health.

### 7.2 Starting the Cluster

To build and start the entire multi-container environment:

```bash
./start.sh
```

Alternatively, run Docker Compose directly:

```bash
docker compose up -d --build
```

The startup script initiates containers in order of health dependencies:
1. `virtual_classroom_db`: Starts MySQL 8.0 and evaluates internal healthcheck (`mysqladmin ping`) every 3 seconds.
2. `virtual_classroom_web`: Waits until `db` reaches a healthy state before starting Tomcat and mounting the web application.
3. `virtual_classroom_nginx`: Starts after `web` is running and begins routing traffic on port 80.

Verify running containers:

```bash
docker compose ps
```

Expected status:
```text
NAME                     IMAGE                      STATUS                   PORTS
virtual_classroom_db     mysql:8.0                  Up (healthy)             0.0.0.0:3306->3306/tcp
virtual_classroom_web    virtual-classroom-web      Up                       0.0.0.0:8080->8080/tcp
virtual_classroom_nginx  nginx:alpine               Up                       0.0.0.0:80->80/tcp
```

### 7.3 Stopping the Cluster

To stop containers gracefully while preserving database volumes:

```bash
./stop.sh
```

Or via Compose:

```bash
docker compose down
```

> [!WARNING]
> To wipe all persistent database records and reset to baseline seed data, run:
> ```bash
> docker compose down -v
> ```

### 7.4 Database Backups & Point-in-Time Recovery

#### Creating an Immediate Snapshot
Run the automated backup utility:

```bash
./backup-db.sh
```

The script extracts the `MYSQL_ROOT_PASSWORD` from `.env` (or defaults) and executes a non-blocking `mysqldump` stream directly out of the container:

```bash
docker exec virtual_classroom_db mysqldump -u root -p"$ROOT_PASS" project > backups/project_backup_<TIMESTAMP>.sql
```

Snapshots are written to the host `backups/` directory with UNIX timestamps.

#### Restoring from a Snapshot
To restore the database from an existing `.sql` snapshot file:

```bash
docker exec -i virtual_classroom_db mysql -u root -p"$MYSQL_ROOT_PASSWORD" project < backups/project_backup_YYYYMMDD_HHMMSS.sql
```

### 7.5 Default Bootstrap Credentials

Initial seed records configured in `project_DB.sql`:

| Role | Username / Identifier | Password | Access URL |
| :--- | :--- | :--- | :--- |
| **Administrator** | N/A (Master Key) | `admin123` *(or `Mypasswordis2425`)* | `http://localhost/admin_login.jsp` |
| **Faculty (Teacher)** | `teacher` | `teacher123` | `http://localhost/faculty_login.jsp` |
| **Student** | Roll No: `2001` | `student123` | `http://localhost/student_login.jsp` |

---

## 8. Repository Structure

```text
Virtual-Classroom/
├── Dockerfile                          # Multi-stage/Slim Tomcat 9 OpenJDK 11 container definition
├── docker-compose.yml                  # 3-tier service topology (Nginx, Tomcat, MySQL)
├── nginx/
│   └── default.conf                    # Nginx reverse proxy configuration & security headers
├── project_DB.sql                      # DDL schema definition & initial seed datasets
├── db.jspf                             # Centralized JDBC connection pool, PBKDF2 hashing, XSS escaper
├── WEB-INF/
│   └── web.xml                         # Deployment descriptor (HttpOnly sessions, welcome file)
├── start.sh                            # Cluster bootstrap & health check polling script
├── stop.sh                             # Graceful container shutdown script
├── backup-db.sh                        # Automated mysqldump backup utility
├── backups/                            # Local persistent storage directory for SQL dumps
├── .env.example                        # Blueprint for environment variables
├── .env                                # Local secrets & host configuration (Git-ignored)
│
├── index.jsp                           # Public landing page with course listings
├── quick_login_box.jspf                # Reusable navigation login modal
│
├── student_register.jsp                # Student onboarding form (inserts with is_approved=0)
├── student_login.jsp                   # Student authentication handler & session initializer
├── student_dashboard.jsp               # Student home portal
├── student_logout.jsp                  # Student session invalidation
│
├── faculty_register.jsp                # Faculty onboarding form (inserts with is_approved=0)
├── faculty_login.jsp                   # Faculty authentication handler & session initializer
├── faculty_dashboard.jsp               # Faculty home portal
├── faculty_logout.jsp                  # Faculty session invalidation
│
├── admin_login.jsp                     # Administrator authentication handler
├── admin_dashboard.jsp                 # Administrator control center
├── admin_student_requests.jsp          # Student registration review queue
├── admin_student_requests_action.jsp   # Student approval / rejection transaction handler
├── admin_faculty_requests.jsp          # Faculty registration review queue
├── admin_faculty_requests_action.jsp   # Faculty approval / rejection transaction handler
├── admin_users.jsp                     # User directory & active account deletion hub
├── admin_logout.jsp                    # Administrator session invalidation
│
├── qna.jsp                             # Interactive question and answer forum
└── study-material.jsp                  # Subject-wise educational resource distribution hub
```

---
