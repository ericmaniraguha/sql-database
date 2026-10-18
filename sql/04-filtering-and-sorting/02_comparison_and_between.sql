/*
================================================================================
Topic: Comparison Operators and BETWEEN Range Filtering
Objective: Filter numeric, text, and temporal data using relational comparison 
           operators and the inclusive BETWEEN operator.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Comparison operators compare two expressions:
--   =   Equal to
--   != or <>  Not equal to
--   >   Greater than
--   <   Less than
--   >=  Greater than or equal to
--   <=  Less than or equal to
--
-- The BETWEEN operator tests whether a value falls within an INCLUSIVE range:
--   expression BETWEEN low AND high
--   is equivalent to:
--   expression >= low AND expression <= high

-- =============================================================================
-- 2. Basic Comparison Operators
-- =============================================================================

-- Find courses with strictly more than 3 credits
SELECT course_id, course_code, course_name, credits
FROM courses
WHERE credits > 3;

-- Find all instructors with salaries not equal to 50000
SELECT instructor_id, first_name, last_name, salary
FROM instructors
WHERE salary <> 50000.00;

-- =============================================================================
-- 3. Range Filtering with BETWEEN (Numbers)
-- =============================================================================

-- Find students with GPA between 3.40 and 3.90 (Inclusive: 3.40 and 3.90 are included)
SELECT student_id, first_name, last_name, gpa
FROM students
WHERE gpa BETWEEN 3.40 AND 3.90;

-- Equivalent explicit syntax:
SELECT student_id, first_name, last_name, gpa
FROM students
WHERE gpa >= 3.40 AND gpa <= 3.90;

-- Find instructors whose salary is NOT between 50000 and 70000
SELECT instructor_id, first_name, last_name, salary
FROM instructors
WHERE salary NOT BETWEEN 50000.00 AND 70000.00;

-- =============================================================================
-- 4. Date Range Comparisons
-- =============================================================================

-- Find instructors hired between January 1, 2015 and December 31, 2018
SELECT instructor_id, first_name, last_name, hire_date
FROM instructors
WHERE hire_date BETWEEN '2015-01-01' AND '2018-12-31'
ORDER BY hire_date;

-- Find students born on or after the year 2003
SELECT student_id, first_name, last_name, birth_date
FROM students
WHERE birth_date >= '2003-01-01';

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Find all departments with a budget between $700,000 and $1,000,000.
-- Exercise 2: Find all enrollments with numeric_grade between 80.00 and 89.99.
