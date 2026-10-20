-- MySQL dump 10.13  Distrib 8.0.46, for Linux (aarch64)
--
-- Host: localhost    Database: project
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'OexmiWAp213bpCz1l/vmgg==:Nwg5RPOIAeXRNsen9xr+Ng==');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `author_name` varchar(100) NOT NULL,
  `author_role` varchar(20) NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_question` (`question_id`),
  CONSTRAINT `fk_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answers`
--

LOCK TABLES `answers` WRITE;
/*!40000 ALTER TABLE `answers` DISABLE KEYS */;
INSERT INTO `answers` VALUES (1,1,'Prof. Tushar Deshmukh','faculty','A closure is a function object that remembers values in enclosing scopes even if they are not present in memory. It occurs when a nested function references a value in its enclosing scope.','2026-10-20 10:18:58'),(2,2,'Prof. Jeevan Limaye','faculty','Type 4 JDBC drivers convert JDBC calls directly into vendor-specific database protocols via TCP sockets. They are fast and written entirely in Java.','2026-10-20 10:18:58'),(3,3,'Prof. SreeLalita','faculty','Sprint planning establishes what can be delivered in the sprint and how that work will be achieved, commonly using story points and planning poker.','2026-10-20 10:18:58'),(4,4,'admin','admin','Docker Compose creates an isolated bridge network where container names act as DNS hostnames.','2026-10-20 10:19:45');
/*!40000 ALTER TABLE `answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enroll_for`
--

DROP TABLE IF EXISTS `enroll_for`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enroll_for` (
  `degree` varchar(10) NOT NULL,
  `course` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enroll_for`
--

LOCK TABLES `enroll_for` WRITE;
/*!40000 ALTER TABLE `enroll_for` DISABLE KEYS */;
INSERT INTO `enroll_for` VALUES ('B.Sc','Computer Application'),('B.Sc','Computer Science'),('B.Sc','Data Science'),('M.Sc','Computer Science'),('M.Sc','Computer Application'),('B.A.','English'),('B.A.','Psychology'),('M.A.','English'),('M.A.','Psychology');
/*!40000 ALTER TABLE `enroll_for` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `name` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email_id` varchar(255) NOT NULL,
  `degree` varchar(10) NOT NULL,
  `course` varchar(50) NOT NULL,
  `year` int NOT NULL,
  `subject` varchar(50) NOT NULL,
  `is_approved` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`subject`),
  UNIQUE KEY `username` (`username`),
  CONSTRAINT `CHK_faculty_year` CHECK ((`year` between 1 and 3))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author_name` varchar(100) NOT NULL,
  `author_role` varchar(20) NOT NULL,
  `subject` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questions`
--

LOCK TABLES `questions` WRITE;
/*!40000 ALTER TABLE `questions` DISABLE KEYS */;
INSERT INTO `questions` VALUES (1,'Nishant Nirmal','student','Python Programming','What are Python Closures?','Can someone explain how variable scope works in nested Python functions with an example?','2026-10-20 10:18:58'),(2,'Gaurav Shukla','student','JAVA Programming','What is JDBC Driver Architecture?','How do Type 4 pure Java drivers communicate with relational databases like MySQL?','2026-10-20 10:18:58'),(3,'Swapnil Dalimbe','student','Software Engineering','What is Agile Sprint Planning?','How are user stories estimated during sprint planning meetings?','2026-10-20 10:18:58'),(4,'Alice Wonder','student','Computer Science','How does Docker Compose networking work?','Can someone explain how services resolve each other by container name?','2026-10-20 10:19:40'),(5,'Alice Wonder','student','Security','<script>alert(\'xss\')</script>','<img src=x onerror=alert(1)>','2026-10-20 10:20:07');
/*!40000 ALTER TABLE `questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student` (
  `roll_no` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email_id` varchar(255) NOT NULL,
  `degree` varchar(10) NOT NULL,
  `course` varchar(50) NOT NULL,
  `year` int NOT NULL,
  `is_approved` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`roll_no`),
  CONSTRAINT `CHK_year` CHECK ((`year` between 1 and 3))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES (2001,'Alice Wonder','QN7FUg7NEw2d4fkG1x3mBA==:IrcFnSu3uSoMvmPESE7ydA==','alice@example.com','B.Sc','Computer Science',2,1,'2026-10-20 10:19:31');
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study_materials`
--

DROP TABLE IF EXISTS `study_materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_materials` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `subject` varchar(50) NOT NULL,
  `degree` varchar(10) NOT NULL,
  `description` text,
  `resource_url` varchar(500) NOT NULL,
  `uploaded_by` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_materials`
--

LOCK TABLES `study_materials` WRITE;
/*!40000 ALTER TABLE `study_materials` DISABLE KEYS */;
INSERT INTO `study_materials` VALUES (1,'Python 3 Complete Setup & Environment Guide','Python Programming','B.Sc','Step-by-step guide to installing Python, pip, and VS Code for development.','https://docs.python.org/3/tutorial/','Faculty Dept','2026-10-20 10:18:58'),(2,'Java OOP & Collections Framework Notes','JAVA Programming','B.Sc','Comprehensive reference covering Inheritance, Interfaces, and Collections API.','https://docs.oracle.com/javase/tutorial/','Faculty Dept','2026-10-20 10:18:58'),(3,'Software Development Life Cycle Overview','Software Engineering','B.Sc','Comparison of Waterfall, Agile Scrum, and Kanban methodologies.','https://www.agilealliance.org/agile101/','Faculty Dept','2026-10-20 10:18:58'),(4,'Docker','Containerization','B.Sc','Production deployment guide for multi-container web apps.','https://docs.docker.com/compose/','admin','2026-10-20 10:19:52');
/*!40000 ALTER TABLE `study_materials` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-20 10:20:13
