/*
================================================================================
Topic: Grouping Data with GROUP BY
Objective: Group result rows by one or more attributes to calculate aggregated 
           metrics per category or department.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The GROUP BY clause collapses rows with identical values in specified columns
-- into summary rows.
--
-- GOLDEN RULE OF GROUP BY:
-- Any column in the SELECT clause that is NOT inside an aggregate function MUST
-- be listed in the GROUP BY clause! (Standard SQL & MySQL ONLY_FULL_GROUP_BY).

-- =============================================================================
-- 2. Single Column GROUP BY
-- =============================================================================

-- Calculate student count and average GPA per department
SELECT 
    department_id,
    COUNT(*)             AS student_count,
    ROUND(AVG(gpa), 2)   AS average_gpa,
    ROUND(MIN(gpa), 2)   AS lowest_gpa,
    ROUND(MAX(gpa), 2)   AS highest_gpa
FROM students
GROUP BY department_id
ORDER BY department_id;

-- Department payroll analysis
SELECT 
    department_id,
    COUNT(*)              AS instructor_count,
    SUM(salary)           AS total_salary_cost,
    ROUND(AVG(salary), 2) AS average_salary
FROM instructors
GROUP BY department_id
ORDER BY total_salary_cost DESC;

-- =============================================================================
-- 3. Multi-Column GROUP BY
-- =============================================================================

-- Analyze enrollments grouped by academic year and semester
SELECT 
    academic_year,
    semester,
    COUNT(*)                       AS enrollment_count,
    ROUND(AVG(numeric_grade), 2)   AS term_average_grade
FROM enrollments
GROUP BY academic_year, semester
ORDER BY academic_year DESC, semester ASC;

-- Group instructors by department and academic rank
SELECT 
    department_id,
    academic_rank,
    COUNT(*) AS instructor_count,
    ROUND(AVG(salary), 2) AS avg_rank_salary
FROM instructors
GROUP BY department_id, academic_rank
ORDER BY department_id, avg_rank_salary DESC;

-- =============================================================================
-- 4. Practice Questions
-- =============================================================================
-- Exercise 1: Group courses by credits and count how many courses exist for each credit value.
-- Exercise 2: Group students by status ('Active', 'Graduated', etc.) and calculate average GPA.
