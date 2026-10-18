/*
================================================================================
Topic: RIGHT JOIN and FULL OUTER JOIN
Objective: Master RIGHT JOIN semantics, complete bi-directional outer joins with 
           FULL OUTER JOIN, and emulate FULL OUTER JOIN in MySQL.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- - RIGHT JOIN: Preserves all rows from the right table. (Any RIGHT JOIN can be 
--   rewritten as a LEFT JOIN by reversing table order; LEFT JOIN is preferred in practice).
-- - FULL OUTER JOIN: Returns all rows when there is a match in EITHER table.
--   Unmatched columns on either side receive NULL values.

-- =============================================================================
-- 2. RIGHT JOIN Example
-- =============================================================================

-- All courses and any matching enrollments (guaranteeing all courses appear)
SELECT 
    c.course_code,
    c.course_name,
    e.enrollment_id,
    e.student_id,
    e.letter_grade
FROM enrollments e
RIGHT JOIN courses c 
    ON e.course_id = c.course_id
ORDER BY c.course_code;

-- The exact equivalent written as LEFT JOIN (Industry Preferred):
-- SELECT c.course_code, c.course_name, e.enrollment_id, e.student_id, e.letter_grade
-- FROM courses c
-- LEFT JOIN enrollments e ON c.course_id = e.course_id
-- ORDER BY c.course_code;

-- =============================================================================
-- 3. FULL OUTER JOIN (ANSI SQL / PostgreSQL / Oracle)
-- =============================================================================
-- Shows all instructors and all courses, matching them where assigned.
-- Instructors with no courses show NULL course data.
-- Courses with no instructors show NULL instructor data.

-- In PostgreSQL / Oracle:
/*
SELECT 
    i.instructor_id,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name,
    c.course_code,
    c.course_name
FROM instructors i
FULL OUTER JOIN courses c 
    ON i.instructor_id = c.instructor_id
ORDER BY i.instructor_id NULLS LAST, c.course_code;
*/

-- =============================================================================
-- 4. Emulating FULL OUTER JOIN in MySQL
-- =============================================================================
-- MySQL does not natively support FULL OUTER JOIN syntax.
-- To achieve FULL OUTER JOIN in MySQL, combine a LEFT JOIN and a RIGHT JOIN using UNION:

SELECT 
    i.instructor_id,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name,
    c.course_code,
    c.course_name
FROM instructors i
LEFT JOIN courses c 
    ON i.instructor_id = c.instructor_id

UNION

SELECT 
    i.instructor_id,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name,
    c.course_code,
    c.course_name
FROM instructors i
RIGHT JOIN courses c 
    ON i.instructor_id = c.instructor_id;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Why do most software engineering teams prefer LEFT JOIN over RIGHT JOIN?
-- Exercise 2: Write a query using FULL OUTER JOIN (or its UNION emulation) to show 
--             all students and all departments, including unassigned students and empty departments.
