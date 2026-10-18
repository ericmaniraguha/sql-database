/*
================================================================================
Topic: Sorting Results and Result Set Pagination
Objective: Sort output using ORDER BY with single/multiple columns, control NULL 
           ordering, and paginate records with LIMIT, OFFSET, and FETCH FIRST.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Relational tables have no inherent order. Without an explicit ORDER BY clause,
-- the order of returned rows is non-deterministic.
-- - ASC: Ascending order (lowest to highest, A-Z, earliest date first; default).
-- - DESC: Descending order (highest to lowest, Z-A, latest date first).

-- =============================================================================
-- 2. Basic Single-Column Sorting
-- =============================================================================

-- Sort students by GPA descending (highest academic performers first)
SELECT student_id, first_name, last_name, gpa
FROM students
ORDER BY gpa DESC;

-- Sort instructors alphabetically by last name
SELECT instructor_id, first_name, last_name
FROM instructors
ORDER BY last_name ASC;

-- =============================================================================
-- 3. Multi-Column Sorting
-- =============================================================================

-- Sort first by department_id ascending, then by GPA descending within each department
SELECT student_id, department_id, first_name, last_name, gpa
FROM students
ORDER BY department_id ASC, gpa DESC;

-- =============================================================================
-- 4. NULL Ordering: NULLS FIRST and NULLS LAST
-- =============================================================================
-- Standard ANSI / PostgreSQL / Oracle supports explicit NULL placement:

-- In PostgreSQL / Oracle:
-- SELECT course_id, course_name, instructor_id 
-- FROM courses 
-- ORDER BY instructor_id ASC NULLS LAST;

-- In MySQL:
-- NULL values naturally sort first in ASC and last in DESC.

-- =============================================================================
-- 5. Pagination: LIMIT / OFFSET (PostgreSQL & MySQL)
-- =============================================================================

-- Retrieve the top 3 highest paid instructors
SELECT instructor_id, first_name, last_name, salary
FROM instructors
ORDER BY salary DESC
LIMIT 3;

-- Page 2 of students (Page size = 3, skipping first 3)
SELECT student_id, first_name, last_name, gpa
FROM students
ORDER BY student_id ASC
LIMIT 3 OFFSET 3;

-- =============================================================================
-- 6. ANSI SQL Standard Pagination: OFFSET ... FETCH NEXT
-- =============================================================================
-- Supported across modern PostgreSQL (9.0+), Oracle (12c+), and SQL Server:

SELECT student_id, first_name, last_name, gpa
FROM students
ORDER BY gpa DESC
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY;

-- =============================================================================
-- 7. Practice Questions
-- =============================================================================
-- Exercise 1: Retrieve the 2 lowest-earning instructors.
-- Exercise 2: Paginate courses with page size 4, requesting page 2 (rows 5 through 8).
-- Exercise 3: Sort enrollments by academic_year descending, then semester ascending, 
--             then numeric_grade descending.
