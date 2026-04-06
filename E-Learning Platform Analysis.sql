-- =========================================
-- PROJECT: E-Learning Platform Analysis
-- =========================================

-- Create Database
CREATE DATABASE elearning_db;
USE elearning_db;

-- =========================================
-- 1. TABLE CREATION
-- =========================================

-- Learners Table
CREATE TABLE learners (
    learner_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50)
);

-- Courses Table
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

-- Purchases Table
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    learner_id INT,
    course_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- =========================================
-- 2. DATA INSERTION
-- =========================================

-- Insert Learners
INSERT INTO learners VALUES
(1, 'Amit Sharma', 'India'),
(2, 'Sara Khan', 'UAE'),
(3, 'John Smith', 'USA'),
(4, 'Priya Patel', 'India'),
(5, 'David Lee', 'UK');

-- Insert Courses
INSERT INTO courses VALUES
(101, 'SQL for Beginners', 'Data', 50.00),
(102, 'Python Programming', 'Programming', 75.00),
(103, 'Data Analysis with Excel', 'Data', 40.00),
(104, 'Web Development', 'Development', 80.00),
(105, 'Machine Learning', 'AI', 120.00);

-- Insert Purchases
INSERT INTO purchases VALUES
(1, 1, 101, 2, '2024-01-10'),
(2, 2, 102, 1, '2024-01-15'),
(3, 3, 103, 3, '2024-02-01'),
(4, 1, 104, 1, '2024-02-10'),
(5, 4, 101, 1, '2024-02-15'),
(6, 5, 105, 2, '2024-03-01'),
(7, 2, 103, 2, '2024-03-05'),
(8, 3, 102, 1, '2024-03-10');

-- =========================================
-- 3. DATA EXPLORATION USING JOINS
-- =========================================

-- INNER JOIN: Detailed purchase view
SELECT 
    l.full_name AS learner_name,
    l.country,
    c.course_name,
    c.category,
    p.quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date
FROM purchases p
INNER JOIN learners l ON p.learner_id = l.learner_id
INNER JOIN courses c ON p.course_id = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- LEFT JOIN: All learners with their purchases (including no purchases)
SELECT 
    l.full_name,
    c.course_name
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses c ON p.course_id = c.course_id;

-- RIGHT JOIN: All courses with associated learners
SELECT 
    c.course_name,
    l.full_name
FROM purchases p
RIGHT JOIN courses c ON p.course_id = c.course_id
LEFT JOIN learners l ON p.learner_id = l.learner_id;

-- =========================================
-- 4. ANALYTICAL QUERIES
-- =========================================

-- Q1: Total spending per learner
SELECT 
    l.full_name,
    l.country,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_spent
FROM purchases p
JOIN learners l ON p.learner_id = l.learner_id
JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- Q2: Top 3 most purchased courses
SELECT 
    c.course_name,
    SUM(p.quantity) AS total_quantity
FROM purchases p
JOIN courses c ON p.course_id = c.course_id
GROUP BY c.course_id, c.course_name
ORDER BY total_quantity DESC
LIMIT 3;

-- Q3: Category-wise revenue and unique learners
SELECT 
    c.category,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_revenue,
    COUNT(DISTINCT p.learner_id) AS unique_learners
FROM purchases p
JOIN courses c ON p.course_id = c.course_id
GROUP BY c.category
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- Q4: Learners who purchased from multiple categories
SELECT 
    l.full_name,
    COUNT(DISTINCT c.category) AS category_count
FROM purchases p
JOIN learners l ON p.learner_id = l.learner_id
JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING COUNT(DISTINCT c.category) > 1;

-- Q5: Courses not purchased at all
SELECT 
    c.course_name
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL;

