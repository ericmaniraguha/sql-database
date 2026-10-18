/*
================================================================================
Topic: Basic Aggregate Functions
Objective: Summarize datasets and calculate summary metrics using COUNT, SUM, 
           AVG, MIN, and MAX, understanding how NULLs are treated.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Aggregate functions operate on a set of rows and return a single summary value.
-- Key Rule: Aggregate functions (except COUNT(*)) automatically IGNORE NULL values!
-- - COUNT(*): Counts total number of rows (including NULLs).
-- - COUNT(col): Counts non-NULL entries in that column.
-- - COUNT(DISTINCT col): Counts unique non-NULL entries.
-- - SUM(col): Total sum of values.
-- - AVG(col): Arithmetic mean (SUM / non-null COUNT).
-- - MIN(col) / MAX(col): Lowest and highest values.

-- =============================================================================
-- 2. Counting Rows and Non-NULLs
-- =============================================================================

SELECT 
    COUNT(*)                     AS total_students,
    COUNT(department_id)         AS students_with_department,
    COUNT(DISTINCT department_id) AS distinct_departments_represented
FROM students;

-- =============================================================================
-- 3. Summation, Averages, Minimums, and Maximums
-- =============================================================================

SELECT 
    COUNT(*)                      AS total_instructors,
    SUM(salary)                   AS total_payroll,
    ROUND(AVG(salary), 2)         AS average_salary,
    MIN(salary)                   AS minimum_salary,
    MAX(salary)                   AS maximum_salary
FROM instructors;

-- =============================================================================
-- 4. Aggregates on Filtered Data
-- =============================================================================

-- Calculate metrics only for department 1
SELECT 
    ROUND(AVG(gpa), 2) AS cs_average_gpa,
    MAX(gpa)          AS cs_highest_gpa,
    MIN(gpa)          AS cs_lowest_gpa
FROM students
WHERE department_id = 1;

-- =============================================================================
-- 5. Conditional Aggregation with CASE
-- =============================================================================
-- Count students meeting specific conditions in a single query:

SELECT 
    COUNT(*) AS total_students,
    COUNT(CASE WHEN gpa >= 3.50 THEN 1 END) AS high_achievers,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) AS active_students,
    ROUND(AVG(CASE WHEN department_id = 1 THEN gpa END), 2) AS avg_cs_gpa
FROM students;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Calculate the average numeric_grade across all completed enrollments.
-- Exercise 2: Find the total budget allocated across all university departments.
-- Exercise 3: Explain why AVG(numeric_grade) will differ if missing grades are stored 
--             as 0 versus NULL.
