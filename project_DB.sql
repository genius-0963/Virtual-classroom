DROP DATABASE IF EXISTS project;

CREATE DATABASE IF NOT EXISTS project;

USE project;

-- Admin table with VARCHAR(255) for secure salted hashes
CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(255) NOT NULL
) ENGINE = InnoDB;

-- Default Admin Passwords (SHA1 hash for initial bootstrap, verified and upgraded by app)
INSERT INTO admin (password) VALUES (SHA1('admin123'));
INSERT INTO admin (password) VALUES (SHA1('Mypasswordis2425'));

-- Courses and Degrees
CREATE TABLE enroll_for (
    degree VARCHAR(10) NOT NULL,
    course VARCHAR(50) NOT NULL
) ENGINE = InnoDB;

INSERT INTO enroll_for (degree, course) VALUES 
('B.Sc', 'Computer Application'),
('B.Sc', 'Computer Science'),
('B.Sc', 'Data Science'),
('M.Sc', 'Computer Science'),
('M.Sc', 'Computer Application'),
('B.A.', 'English'),
('B.A.', 'Psychology'),
('M.A.', 'English'),
('M.A.', 'Psychology');

-- Students table
CREATE TABLE student (
    roll_no VARCHAR(50) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email_id VARCHAR(255) NOT NULL,
    degree VARCHAR(10) NOT NULL,
    course VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CHK_year CHECK (year BETWEEN 1 AND 3)
) ENGINE = InnoDB;

-- Faculty table
CREATE TABLE faculty (
    name VARCHAR(50) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email_id VARCHAR(255) NOT NULL,
    degree VARCHAR(10) NOT NULL,
    course VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    subject VARCHAR(50) PRIMARY KEY,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CHK_faculty_year CHECK (year BETWEEN 1 AND 3)
) ENGINE = InnoDB;

-- Default Demo Seed Accounts
INSERT INTO student (roll_no, name, password, email_id, degree, course, year, is_approved) VALUES 
('2001', 'Alice Wonder', SHA1('student123'), 'alice@example.com', 'B.Sc', 'Computer Science', 2, TRUE)
ON DUPLICATE KEY UPDATE password = SHA1('student123'), is_approved = TRUE;

INSERT INTO faculty (name, username, password, email_id, degree, course, year, subject, is_approved) VALUES 
('Prof. Rajesh Sharma', 'teacher', SHA1('teacher123'), 'teacher@example.com', 'B.Sc', 'Computer Science', 1, 'Computer Science', TRUE)
ON DUPLICATE KEY UPDATE password = SHA1('teacher123'), is_approved = TRUE;

-- Q&A Forum: Questions
CREATE TABLE questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    author_role VARCHAR(20) NOT NULL,
    subject VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- Q&A Forum: Answers
CREATE TABLE answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    author_name VARCHAR(100) NOT NULL,
    author_role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE = InnoDB;

-- Study Materials & Resources
CREATE TABLE study_materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    subject VARCHAR(50) NOT NULL,
    degree VARCHAR(10) NOT NULL,
    description TEXT,
    resource_url VARCHAR(500) NOT NULL,
    uploaded_by VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- Sample Seed Data for Q&A
INSERT INTO questions (author_name, author_role, subject, title, content) VALUES
('Nishant Nirmal', 'student', 'Python Programming', 'What are Python Closures?', 'Can someone explain how variable scope works in nested Python functions with an example?'),
('Gaurav Shukla', 'student', 'JAVA Programming', 'What is JDBC Driver Architecture?', 'How do Type 4 pure Java drivers communicate with relational databases like MySQL?'),
('Swapnil Dalimbe', 'student', 'Software Engineering', 'What is Agile Sprint Planning?', 'How are user stories estimated during sprint planning meetings?');

INSERT INTO answers (question_id, author_name, author_role, content) VALUES
(1, 'Prof. Tushar Deshmukh', 'faculty', 'A closure is a function object that remembers values in enclosing scopes even if they are not present in memory. It occurs when a nested function references a value in its enclosing scope.'),
(2, 'Prof. Jeevan Limaye', 'faculty', 'Type 4 JDBC drivers convert JDBC calls directly into vendor-specific database protocols via TCP sockets. They are fast and written entirely in Java.'),
(3, 'Prof. SreeLalita', 'faculty', 'Sprint planning establishes what can be delivered in the sprint and how that work will be achieved, commonly using story points and planning poker.');

-- Sample Seed Data for Study Materials
INSERT INTO study_materials (title, subject, degree, description, resource_url, uploaded_by) VALUES
('Python 3 Complete Setup & Environment Guide', 'Python Programming', 'B.Sc', 'Step-by-step guide to installing Python, pip, and VS Code for development.', 'https://docs.python.org/3/tutorial/', 'Faculty Dept'),
('Java OOP & Collections Framework Notes', 'JAVA Programming', 'B.Sc', 'Comprehensive reference covering Inheritance, Interfaces, and Collections API.', 'https://docs.oracle.com/javase/tutorial/', 'Faculty Dept'),
('Software Development Life Cycle Overview', 'Software Engineering', 'B.Sc', 'Comparison of Waterfall, Agile Scrum, and Kanban methodologies.', 'https://www.agilealliance.org/agile101/', 'Faculty Dept');

-- Create dedicated least-privilege application user
CREATE USER IF NOT EXISTS 'vclass_user'@'%' IDENTIFIED BY 'VClassSecret2026!';
GRANT SELECT, INSERT, UPDATE, DELETE ON project.* TO 'vclass_user'@'%';
FLUSH PRIVILEGES;
