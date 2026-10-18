/*
================================================================================
Topic: IN Lists and LIKE Pattern Matching
Objective: Query discrete value sets with IN, match text patterns with LIKE 
           and wildcards, and handle case sensitivity.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- - The IN operator allows checking if a value matches any value in a specified list:
--     column IN (val1, val2, ...)
-- - The LIKE operator searches for patterns in text columns:
--     % matches zero, one, or multiple characters.
--     _ matches exactly one single character.

-- =============================================================================
-- 2. Value Lists with IN and NOT IN
-- =============================================================================

-- Find instructors with specific titles
SELECT instructor_id, first_name, last_name, academic_rank
FROM instructors
WHERE academic_rank IN ('Professor', 'Associate Professor');

-- Equivalent using OR (more verbose):
-- WHERE academic_rank = 'Professor' OR academic_rank = 'Associate Professor';

-- Find students not in departments 1 or 2
SELECT student_id, first_name, last_name, department_id
FROM students
WHERE department_id NOT IN (1, 2);

-- =============================================================================
-- 3. Pattern Matching with LIKE Wildcards
-- =============================================================================

-- 1. Starts with 'CS'
SELECT course_id, course_code, course_name
FROM courses
WHERE course_code LIKE 'CS%';

-- 2. Ends with '@ulk.ac.rw'
SELECT instructor_id, first_name, last_name, email
FROM instructors
WHERE email LIKE '%@ulk.ac.rw';

-- 3. Contains 'Science' anywhere in the name
SELECT department_id, department_name
FROM departments
WHERE department_name LIKE '%Science%';

-- 4. Single-character wildcard '_' (e.g. 5-character course codes starting with 'CS')
SELECT course_id, course_code, course_name
FROM courses
WHERE course_code LIKE 'CS___';

-- =============================================================================
-- 4. Case-Insensitive Matching
-- =============================================================================

-- Standard ANSI cross-database approach:
SELECT student_id, first_name, last_name
FROM students
WHERE LOWER(last_name) LIKE LOWER('%kwi%');

-- PostgreSQL specific (ILIKE is case-insensitive):
-- SELECT student_id, first_name, last_name FROM students WHERE last_name ILIKE '%kwi%';

-- =============================================================================
-- 5. Escaping Wildcard Characters
-- =============================================================================
-- To search for literal '%' or '_' characters, specify an ESCAPE clause:
-- SELECT * FROM notes WHERE content LIKE '%100!%%' ESCAPE '!';

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Find all students whose first name starts with 'A'.
-- Exercise 2: Find all courses where course_code has '101' as the last 3 characters.
-- Exercise 3: Find all students whose email does NOT contain 'student'.
