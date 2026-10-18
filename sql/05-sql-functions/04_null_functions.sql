/*
================================================================================
Topic: NULL Handling Functions: COALESCE and NULLIF
Objective: Provide fallback defaults for NULL values, convert sentinel values 
           to NULL, and prevent division-by-zero errors.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- - COALESCE(val1, val2, ...): Returns the first non-NULL expression from its 
--   argument list. This is the ANSI SQL standard function for handling NULL fallbacks.
-- - NULLIF(expr1, expr2): Returns NULL if expr1 equals expr2; otherwise returns expr1.
--   Extremely useful for avoiding division by zero!

-- =============================================================================
-- 2. Fallback Defaults with COALESCE
-- =============================================================================

-- Display 'Unassigned' when instructor office_number or department is NULL
SELECT 
    instructor_id,
    first_name,
    last_name,
    COALESCE(office_number, 'Pending Assignment') AS office_location
FROM instructors;

-- COALESCE with multiple fallback levels
SELECT 
    student_id,
    first_name,
    COALESCE(status, 'Unknown Status', 'N/A') AS student_status
FROM students;

-- Dialect equivalents:
-- MySQL: IFNULL(office_number, 'Pending Assignment')
-- Oracle: NVL(office_number, 'Pending Assignment')

-- =============================================================================
-- 3. Preventing Division by Zero with NULLIF
-- =============================================================================
-- In mathematics and SQL, dividing by zero causes a runtime error:
-- SELECT 100 / 0; -- Runtime Error: Division by zero!
-- Dividing by NULL, however, gracefully returns NULL.

-- Safe ratio calculation:
SELECT 
    department_name,
    budget,
    established_year,
    -- Prevent division by zero if established_year was 0 or a denominator variable
    ROUND(budget / NULLIF(established_year, 0), 2) AS budget_per_year_factor
FROM departments;

-- =============================================================================
-- 4. Using NULLIF to Convert Empty Strings to NULL
-- =============================================================================

SELECT 
    student_id,
    first_name,
    -- If status is an empty string '', turn it into NULL
    NULLIF(status, '') AS sanitized_status
FROM students;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Query enrollments and display 'In Progress' for any letter_grade that is NULL.
-- Exercise 2: Explain why COALESCE is preferred over vendor-specific functions like 
--             IFNULL (MySQL) or NVL (Oracle).
