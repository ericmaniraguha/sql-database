/*
================================================================================
Topic: Basic Querying with SELECT
Objective: Retrieve, project, calculate, and format data from single tables 
           using SELECT, column aliases, arithmetic expressions, and DISTINCT.
Database: PostgreSQL (pgAdmin) / SQLite / MySQL
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The SELECT statement queries data from one or more tables.
-- Projection is the process of choosing which specific attributes (columns) to return.
-- Logical execution of a query evaluates FROM before SELECT!


-- =============================================================================
-- 2. Basic Column Projection
-- =============================================================================

-- Retrieve all columns (useful for ad-hoc inspection in pgAdmin):
SELECT * 
FROM students;

-- Retrieve only specific columns (Recommended practice for performance and clarity):
SELECT 
    student_id, 
    registration_no,
    first_name, 
    last_name, 
    email 
FROM students;


-- =============================================================================
-- 3. Column Aliasing (AS keyword)
-- =============================================================================
-- Aliases rename column headers in the result set for clarity or reporting.

SELECT 
    student_id      AS id,
    registration_no AS student_card_id,
    first_name      AS "Given Name",   -- Double quotes preserve spaces and case in PostgreSQL
    last_name       AS "Family Name",
    status          AS enrollment_status
FROM students;


-- =============================================================================
-- 4. Computed Expressions and String Concatenation
-- =============================================================================

-- Calculate annual salary and projected 10% raise from monthly salary:
SELECT 
    first_name,
    last_name,
    monthly_salary,
    monthly_salary * 12                   AS annual_salary,
    ROUND(monthly_salary * 1.10, 2)       AS projected_monthly_with_raise
FROM lecturers;

-- Concatenate first and last name into full name:
-- Standard ANSI / PostgreSQL / SQLite:
SELECT 
    student_id,
    registration_no,
    first_name || ' ' || last_name AS student_full_name,
    status
FROM students;

-- MySQL alternative:
-- SELECT student_id, CONCAT(first_name, ' ', last_name) AS student_full_name FROM students;


-- =============================================================================
-- 5. Eliminating Duplicates with DISTINCT
-- =============================================================================

-- View all academic ranks among lecturers (returns only unique ranks):
SELECT DISTINCT academic_rank 
FROM lecturers
ORDER BY academic_rank;

-- View all fee types defined in university fee structures:
SELECT DISTINCT fee_type 
FROM fee_structures;

-- DISTINCT across multiple columns (unique pairs of program and degree level):
SELECT DISTINCT 
    degree_level, 
    duration_years 
FROM programs;


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Select course_code and course_title from courses, aliasing them as "Code" and "Title".
-- Exercise 2: Select all unique payment_method values from the payments table.
-- Exercise 3: Compute the weekly salary for lecturers assuming 4 weeks per month (monthly_salary / 4).
