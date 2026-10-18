/*
================================================================================
Topic: Conditional Logic with CASE Expressions
Objective: Implement IF-THEN-ELSE conditional logic directly inside SQL queries 
           using Simple CASE and Searched CASE expressions.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The CASE expression is SQL's universal conditional construct.
-- It can be used anywhere an expression is valid (SELECT, WHERE, ORDER BY, GROUP BY).
-- - Searched CASE: Evaluates multiple independent Boolean expressions (WHEN condition THEN result).
-- - Simple CASE: Compares a single expression against target values (CASE expr WHEN val THEN result).

-- =============================================================================
-- 2. Searched CASE: Grading and Academic Standing
-- =============================================================================

SELECT 
    student_id,
    first_name,
    last_name,
    gpa,
    CASE 
        WHEN gpa >= 3.80 THEN 'First Class Honours / Summa Cum Laude'
        WHEN gpa >= 3.50 THEN 'Second Class Upper / Magna Cum Laude'
        WHEN gpa >= 3.00 THEN 'Second Class Lower'
        WHEN gpa >= 2.00 THEN 'Pass'
        ELSE 'Academic Probation'
    END AS academic_distinction
FROM students
ORDER BY gpa DESC;

-- =============================================================================
-- 3. Simple CASE: Decoding Value Codes
-- =============================================================================

SELECT 
    course_id,
    course_code,
    department_id,
    CASE department_id
        WHEN 1 THEN 'Computing & Informatics'
        WHEN 2 THEN 'Economics & Management'
        WHEN 3 THEN 'Faculty of Law'
        WHEN 4 THEN 'School of Engineering'
        ELSE 'Other Faculty'
    END AS faculty_group
FROM courses;

-- =============================================================================
-- 4. CASE in ORDER BY Clauses (Custom Sort Order)
-- =============================================================================
-- Sort instructors by seniority rank rather than alphabetical order:

SELECT 
    instructor_id,
    first_name,
    last_name,
    academic_rank
FROM instructors
ORDER BY 
    CASE academic_rank
        WHEN 'Professor'           THEN 1
        WHEN 'Associate Professor' THEN 2
        WHEN 'Senior Lecturer'     THEN 3
        WHEN 'Lecturer'            THEN 4
        WHEN 'Assistant Lecturer'  THEN 5
        ELSE 6
    END ASC;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Categorize instructors into salary brackets: 'High' (> 70k), 
--             'Medium' (50k-70k), and 'Entry' (< 50k).
-- Exercise 2: Use CASE in an UPDATE statement to convert numeric_grade in enrollments 
--             to letter_grade ('A' >= 90, 'B' >= 80, 'C' >= 70, etc.).
