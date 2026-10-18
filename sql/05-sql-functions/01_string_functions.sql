/*
================================================================================
Topic: Scalar String Functions
Objective: Transform, clean, format, and extract substrings from text data 
           using standard SQL string functions.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- String functions operate on character column values and string literals,
-- returning transformed text or numeric metrics (like character length).

-- =============================================================================
-- 2. Case Conversion: UPPER, LOWER
-- =============================================================================

SELECT 
    first_name,
    UPPER(first_name) AS upper_name,
    LOWER(email)      AS normalized_email
FROM students;

-- =============================================================================
-- 3. String Length: LENGTH / CHAR_LENGTH
-- =============================================================================

SELECT 
    department_name,
    LENGTH(department_name) AS char_count
FROM departments
ORDER BY char_count DESC;

-- =============================================================================
-- 4. Concatenation: CONCAT, ||
-- =============================================================================

-- MySQL and PostgreSQL support CONCAT:
SELECT 
    instructor_id,
    CONCAT(first_name, ' ', last_name, ' (', academic_rank, ')') AS instructor_title
FROM instructors;

-- ANSI standard concatenation operator || (PostgreSQL, Oracle, SQLite):
-- SELECT first_name || ' ' || last_name FROM instructors;

-- =============================================================================
-- 5. Substrings: SUBSTRING / SUBSTR
-- =============================================================================
-- Syntax: SUBSTRING(string FROM start FOR length) or SUBSTR(string, start, length)

SELECT 
    course_code,
    SUBSTRING(course_code, 1, 2) AS department_prefix,
    SUBSTRING(course_code, 3, 3) AS course_level_number
FROM courses;

-- =============================================================================
-- 6. Trimming Whitespace: TRIM, LTRIM, RTRIM
-- =============================================================================

SELECT 
    TRIM('   University of Kigali   ') AS cleaned_text,
    LTRIM('   Left space removed')    AS ltrim_example,
    RTRIM('Right space removed   ')    AS rtrim_example;

-- =============================================================================
-- 7. Search & Replace: REPLACE, POSITION / INSTR
-- =============================================================================

-- Replace domain in email address
SELECT 
    email,
    REPLACE(email, '@ulk.ac.rw', '@faculty.ulk.ac.rw') AS new_email
FROM instructors;

-- Find location of '@' character in email
-- ANSI / PostgreSQL: POSITION('@' IN email)
-- MySQL / Oracle: INSTR(email, '@')
SELECT 
    email,
    POSITION('@' IN email) AS at_symbol_position
FROM students;

-- =============================================================================
-- 8. Practice Questions
-- =============================================================================
-- Exercise 1: Format student names as "LASTNAME, Firstname" (e.g., "NIYONSABA, Alice").
-- Exercise 2: Extract just the username portion (before '@') from instructor emails.
