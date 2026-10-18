/*
================================================================================
Topic: Filtering Groups with the HAVING Clause
Objective: Distinguish between WHERE and HAVING, filter grouped results based 
           on aggregate metrics, and understand query processing phases.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: WHERE vs HAVING
-- =============================================================================
-- | Clause  | Execution Phase          | Operates On  | Can Use Aggregate Functions? |
-- |---------|--------------------------|--------------|------------------------------|
-- | WHERE   | BEFORE grouping happens  | Individual rows | NO                          |
-- | HAVING  | AFTER grouping happens   | Aggregated groups | YES                       |
--
-- Logical Query Execution Order:
-- 1. FROM & JOIN
-- 2. WHERE (filters raw rows)
-- 3. GROUP BY (collapses rows into groups)
-- 4. HAVING (filters summarized groups)
-- 5. SELECT (projections & computed expressions)
-- 6. DISTINCT
-- 7. ORDER BY (sorts final output)
-- 8. LIMIT / OFFSET / FETCH FIRST

-- =============================================================================
-- 2. Basic HAVING Filter
-- =============================================================================

-- Find departments with more than 1 instructor
SELECT 
    department_id,
    COUNT(*) AS instructor_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM instructors
GROUP BY department_id
HAVING COUNT(*) > 1;

-- Find departments where average instructor salary exceeds $60,000
SELECT 
    department_id,
    ROUND(AVG(salary), 2) AS avg_salary
FROM instructors
GROUP BY department_id
HAVING AVG(salary) > 60000.00;

-- =============================================================================
-- 3. Combining WHERE and HAVING in the Same Query
-- =============================================================================

-- Consider only 'Active' students (WHERE), group by department, 
-- and return only departments with at least 2 active students and an average GPA >= 3.50 (HAVING)
SELECT 
    department_id,
    COUNT(*) AS active_student_count,
    ROUND(AVG(gpa), 2) AS dept_avg_gpa
FROM students
WHERE status = 'Active'               -- Filter individual student rows first
GROUP BY department_id               -- Group remaining rows by department
HAVING COUNT(*) >= 2                 -- Filter groups: must have >= 2 active students
   AND AVG(gpa) >= 3.50              -- Filter groups: group avg GPA must be >= 3.50
ORDER BY dept_avg_gpa DESC;

-- =============================================================================
-- 4. Common Error: Using WHERE with Aggregate
-- =============================================================================
-- INCORRECT:
-- SELECT department_id FROM students WHERE AVG(gpa) > 3.00 GROUP BY department_id;
-- ERROR: Aggregate function not allowed in WHERE clause! Use HAVING instead.

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Find all courses that have more than 2 student enrollments.
-- Exercise 2: Find departments where the maximum student GPA is greater than 3.80.
