-- LearnAI: Dummy SQL Dataset for Graded Project
-- Designed for MySQL Workbench

DROP DATABASE IF EXISTS learnai;
CREATE DATABASE learnai;
USE learnai;

-- 1. Learners
CREATE TABLE learners (
    learner_id INT PRIMARY KEY,
    learner_name VARCHAR(50),
    experience_level VARCHAR(20),
    join_date DATE
);

INSERT INTO learners VALUES
(101,'Asha','Beginner','2026-06-01'),
(102,'Rahul','Intermediate','2026-06-03'),
(103,'Meera','Beginner','2026-06-05'),
(104,'Arjun','Advanced','2026-06-06'),
(105,'Priya','Intermediate','2026-06-08'),
(106,'Kiran','Beginner','2026-06-10'),
(107,'Neha','Intermediate','2026-06-12'),
(108,'Vikram','Advanced','2026-06-15'),
(109,'Ananya','Beginner','2026-06-18'),
(110,'Rohit','Intermediate','2026-06-20'),
(111,'Sneha','Beginner','2026-06-22'),
(112,'Manoj','Advanced','2026-06-25');

-- 2. Learning programs
CREATE TABLE programs (
    program_id INT PRIMARY KEY,
    program_name VARCHAR(50),
    category VARCHAR(30),
    duration_weeks INT
);

INSERT INTO programs VALUES
(201,'SQL Foundations','Data','8'),
(202,'Python for Data','Programming','8'),
(203,'Generative AI','AI','6'),
(204,'Data Visualization','Analytics','6');

-- 3. Enrollment + learner outcome/engagement data
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    learner_id INT,
    program_id INT,
    enrollment_date DATE,
    sessions_completed INT,
    learning_hours DECIMAL(5,1),
    progress_pct INT,
    completion_status VARCHAR(15),
    final_score DECIMAL(5,2),
    last_activity_date DATE,
    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

INSERT INTO enrollments VALUES
(1,101,201,'2026-06-02',18,22.0,100,'Completed',88,'2026-08-01'),
(2,102,201,'2026-06-04',20,25.0,100,'Completed',91,'2026-08-03'),
(3,103,201,'2026-06-06',7,7.5,42,'Active',NULL,'2026-07-20'),
(4,104,201,'2026-06-07',22,28.0,100,'Completed',94,'2026-08-04'),

(5,105,202,'2026-06-09',19,24.0,100,'Completed',89,'2026-08-05'),
(6,106,202,'2026-06-11',5,5.0,31,'Dropped',NULL,'2026-06-28'),
(7,107,202,'2026-06-13',17,21.0,88,'Active',78,'2026-08-02'),
(8,108,202,'2026-06-16',21,27.0,100,'Completed',92,'2026-08-06'),

(9,109,203,'2026-06-19',24,31.0,100,'Completed',86,'2026-08-08'),
(10,110,203,'2026-06-21',23,30.0,100,'Completed',84,'2026-08-07'),
(11,111,203,'2026-06-23',6,6.0,35,'Dropped',NULL,'2026-07-01'),
(12,112,203,'2026-06-26',25,33.0,100,'Completed',87,'2026-08-09'),

(13,101,204,'2026-06-15',12,14.0,100,'Completed',95,'2026-07-30'),
(14,105,204,'2026-06-18',10,12.0,100,'Completed',93,'2026-08-01'),
(15,107,204,'2026-06-20',4,4.5,38,'Active',81,'2026-07-18'),
(16,110,204,'2026-06-22',3,3.0,25,'Dropped',NULL,'2026-07-05');

-- Quick checks
SELECT * FROM learners;
SELECT * FROM programs;
SELECT * FROM enrollments;
