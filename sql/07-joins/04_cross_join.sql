/*
================================================================================
Topic: Cartesian Products with CROSS JOIN
Objective: Understand CROSS JOIN mechanics, identify valid use cases (matrices, 
           permutations), and avoid catastrophic accidental Cartesian products.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A CROSS JOIN produces the Cartesian product of two tables.
-- Every single row in Table A is paired with every single row in Table B.
-- If Table A has N rows and Table B has M rows, the result contains N * M rows.
-- A CROSS JOIN does not use an ON clause.

-- =============================================================================
-- 2. Basic CROSS JOIN Syntax
-- =============================================================================

-- Explicit standard syntax:
SELECT 
    d.department_code,
    s.academic_term
FROM departments d
CROSS JOIN (
    SELECT 'Fall 2026' AS academic_term
    UNION ALL SELECT 'Spring 2027'
    UNION ALL SELECT 'Summer 2027'
) s
ORDER BY d.department_code, s.academic_term;

-- =============================================================================
-- 3. Practical Use Case: Academic Scheduling Matrix
-- =============================================================================
-- Generate every possible combination of classrooms and exam time slots:

-- Virtual time slots and days:
WITH days AS (
    SELECT 'Monday' AS day_name UNION ALL SELECT 'Wednesday' UNION ALL SELECT 'Friday'
),
periods AS (
    SELECT '08:00 - 10:00' AS time_slot UNION ALL SELECT '10:30 - 12:30' UNION ALL SELECT '14:00 - 16:00'
)
SELECT 
    d.day_name,
    p.time_slot
FROM days d
CROSS JOIN periods p
ORDER BY d.day_name, p.time_slot;

-- =============================================================================
-- 4. Dangers of Unintentional Cartesian Products
-- =============================================================================
-- Old ANSI-89 comma-join without a WHERE clause:
-- SELECT * FROM students, courses; 
-- If students has 10,000 rows and courses has 500 rows, this returns 5,000,000 rows!
-- This can exhaust database server memory and lock connection pools.
-- Modern Best Practice: Always use explicit JOIN ... ON syntax.

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Write a CROSS JOIN between all instructors in department 1 and all courses 
--             in department 1 to show all potential teaching assignments.
-- Exercise 2: If table A has 250 rows and table B has 40 rows, how many rows will 
--             SELECT * FROM A CROSS JOIN B return?
