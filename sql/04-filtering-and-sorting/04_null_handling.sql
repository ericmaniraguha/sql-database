/*
================================================================================
Topic: NULL Values and Three-Valued Logic
Objective: Understand the concept of NULL (unknown/missing data), avoid comparison 
           pitfalls, and correctly filter using IS NULL and IS NOT NULL.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- In SQL, NULL represents missing, unknown, or inapplicable information.
-- NULL is NOT equal to 0, and NULL is NOT an empty string ('').
-- SQL uses Three-Valued Logic (3VL):
--   TRUE, FALSE, and UNKNOWN.
-- Any direct comparison with NULL (e.g., column = NULL or column <> NULL) 
-- evaluates to UNKNOWN, which the WHERE clause filters out!

-- =============================================================================
-- 2. The Dangerous NULL Trap
-- =============================================================================

-- INCORRECT: This will ALWAYS return 0 rows!
SELECT course_id, course_name, instructor_id
FROM courses
WHERE instructor_id = NULL; -- Never evaluates to TRUE!

-- CORRECT: Use the IS NULL operator
SELECT course_id, course_name, instructor_id
FROM courses
WHERE instructor_id IS NULL;

-- Find all courses that DO have an assigned instructor
SELECT course_id, course_name, instructor_id
FROM courses
WHERE instructor_id IS NOT NULL;

-- =============================================================================
-- 3. NULL in Arithmetic and Concatenation
-- =============================================================================
-- Any mathematical operation with NULL yields NULL:
-- 100 + NULL = NULL
-- NULL * 5 = NULL

-- Find enrollments that do not yet have a letter grade assigned
SELECT enrollment_id, student_id, course_id, numeric_grade, letter_grade
FROM enrollments
WHERE letter_grade IS NULL;

-- =============================================================================
-- 4. NOT IN Pitfall with NULL Values
-- =============================================================================
-- WARNING: If a subquery or list passed to NOT IN contains a single NULL,
-- the entire condition evaluates to UNKNOWN, returning 0 rows!

-- Safe pattern: Always filter out NULL when using NOT IN:
-- SELECT student_id FROM students 
-- WHERE student_id NOT IN (
--     SELECT student_id FROM enrollments WHERE student_id IS NOT NULL
-- );

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Find all instructors whose office_number is currently NULL.
-- Exercise 2: Why does `WHERE 1 = 1 AND NULL` fail to return rows?
