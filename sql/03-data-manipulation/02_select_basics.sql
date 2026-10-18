/*
================================================================================
Topic: Basic Querying with SELECT
Objective: Retrieve, project, calculate, and format data from single tables 
           using SELECT, aliases, computed columns, and DISTINCT.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The SELECT statement retrieves rows and columns from one or more tables.
-- Projection is the process of choosing which specific columns to return.
-- Logical execution of a query evaluates FROM before SELECT!

-- =============================================================================
-- 2. Basic Column Projection
-- =============================================================================

-- Retrieve all columns (Avoid in production application code; useful for ad-hoc inspection)
SELECT * 
FROM students;

-- Retrieve only specific columns (Recommended practice)
SELECT 
    student_id, 
    first_name, 
    last_name, 
    email 
FROM students;

-- =============================================================================
-- 3. Column Aliasing (AS keyword)
-- =============================================================================
-- Aliases rename column headers in the result set for clarity or reporting.

SELECT 
    student_id AS id,
    first_name AS "Given Name",   -- Double quotes preserve spaces and case
    last_name  AS "Family Name",
    gpa        AS grade_point_average
FROM students;

-- =============================================================================
-- 4. Computed Expressions and Literal Values
-- =============================================================================

-- Calculate monthly salary from annual salary
SELECT 
    first_name,
    last_name,
    salary AS annual_salary,
    ROUND(salary / 12, 2) AS monthly_salary,
    ROUND(salary * 1.08, 2) AS projected_salary_with_8pct_raise
FROM instructors;

-- Concatenate strings (ANSI standard uses ||, MySQL supports CONCAT())
-- ANSI / PostgreSQL / Oracle:
-- SELECT first_name || ' ' || last_name AS full_name FROM students;

-- Cross-compatible or MySQL:
SELECT 
    student_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    status
FROM students;

-- =============================================================================
-- 5. Eliminating Duplicates with DISTINCT
-- =============================================================================

-- View all department IDs associated with enrolled students (may have duplicates)
SELECT department_id 
FROM students;

-- Return only unique department IDs present in the students table
SELECT DISTINCT department_id 
FROM students;

-- DISTINCT across multiple columns (finds unique pairs of semester and year)
SELECT DISTINCT 
    semester, 
    academic_year 
FROM enrollments;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Select course_code and course_name from courses, aliasing them as 
--             "Code" and "Title".
-- Exercise 2: Select all unique academic_rank values from instructors.
-- Exercise 3: Compute the tuition cost per credit if tuition is $150 per credit hour 
--             for each course in the courses table.
