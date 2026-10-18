/*
================================================================================
Topic: Common Table Expressions (CTEs)
Objective: Structure complex queries into readable, modular, and maintainable 
           temporary result sets using the WITH clause.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A Common Table Expression (CTE) is a named, temporary result set defined 
-- within the execution scope of a single SELECT, INSERT, UPDATE, or DELETE statement.
-- Advantages over inline derived tables (subqueries in FROM):
-- - Dramatically improves readability and code organization.
-- - Can be referenced multiple times within the same main query.
-- - Enables recursive querying for hierarchical data structures.

-- =============================================================================
-- 2. Basic Single CTE
-- =============================================================================

-- Step 1: Calculate department salary statistics in a CTE
WITH DepartmentSalaryStats AS (
    SELECT 
        department_id,
        COUNT(*)              AS instructor_count,
        ROUND(AVG(salary), 2) AS avg_dept_salary,
        MAX(salary)           AS max_dept_salary
    FROM instructors
    GROUP BY department_id
)
-- Step 2: Query the CTE and join with departments
SELECT 
    d.department_name,
    s.instructor_count,
    s.avg_dept_salary,
    s.max_dept_salary
FROM departments d
INNER JOIN DepartmentSalaryStats s 
    ON d.department_id = s.department_id
ORDER BY s.avg_dept_salary DESC;

-- =============================================================================
-- 3. Chained CTEs (Multiple CTEs in a Single WITH Block)
-- =============================================================================
-- Multiple CTEs can be defined in sequence, separated by commas, where later
-- CTEs can reference earlier CTEs!

WITH 
-- CTE 1: Student academic performance summary
StudentPerformance AS (
    SELECT 
        student_id,
        COUNT(enrollment_id)         AS courses_taken,
        ROUND(AVG(numeric_grade), 2) AS overall_avg_score
    FROM enrollments
    GROUP BY student_id
),
-- CTE 2: Classify students into honour tiers based on CTE 1
ClassifiedStudents AS (
    SELECT 
        sp.student_id,
        sp.courses_taken,
        sp.overall_avg_score,
        CASE 
            WHEN sp.overall_avg_score >= 90.00 THEN 'Dean''s List'
            WHEN sp.overall_avg_score >= 80.00 THEN 'Honour Roll'
            ELSE 'Standard Standing'
        END AS academic_tier
    FROM StudentPerformance sp
)
-- Main Query: Join with student profile details
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    cs.courses_taken,
    cs.overall_avg_score,
    cs.academic_tier
FROM students s
INNER JOIN ClassifiedStudents cs 
    ON s.student_id = cs.student_id
ORDER BY cs.overall_avg_score DESC;

-- =============================================================================
-- 4. Practice Questions
-- =============================================================================
-- Exercise 1: Write a CTE that calculates the average GPA across the university, 
--             then use the main query to select all students with GPA > that average.
-- Exercise 2: Create two chained CTEs to find which department has the highest total 
--             student enrollment count.
