/*
================================================================================
Topic: Conditional Logic with CASE Expressions
Objective: Write IF-THEN-ELSE logic inside SQL with searched and simple CASE,
           use CASE in SELECT, ORDER BY, aggregates and UPDATE, and pick
           the largest or smallest of several values with GREATEST / LEAST.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical CASE syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Searched CASE: each WHEN has its own condition.
--     CASE
--         WHEN condition_1 THEN result_1
--         WHEN condition_2 THEN result_2
--         ELSE default_result
--     END
-- Simple CASE: one expression compared with several values.
--     CASE expression
--         WHEN value_1 THEN result_1
--         ELSE default_result
--     END
--
-- Rules:
-- - The FIRST true WHEN wins; later WHENs are not checked. Order matters!
-- - Without ELSE, a row that matches no WHEN gets NULL.
-- - CASE is an expression: use it wherever a value is allowed.
--
-- Quick reference:
--
-- | Function / Expression | Purpose                     | Example                                    |
-- |-----------------------|-----------------------------|--------------------------------------------|
-- | CASE                  | Applies conditional logic   | CASE WHEN monthly_salary > 1500000         |
-- |                       |                             |      THEN 'High' ELSE 'Low' END            |
-- | GREATEST()            | Returns the greatest value  | GREATEST(100, 200, 300)   -> 300           |
-- | LEAST()               | Returns the smallest value  | LEAST(100, 200, 300)      -> 100           |
--
-- GREATEST / LEAST compare values ACROSS COLUMNS in one row; MAX / MIN
-- (module 06) compare values DOWN one column across many rows.
-- NULL warning: PostgreSQL ignores NULL arguments (GREATEST(100, NULL) = 100),
-- but MySQL and Oracle return NULL if ANY argument is NULL.
-- GREATEST and LEAST are not in the SQL standard, but PostgreSQL, MySQL,
-- Oracle and SQL Server 2022+ all have them.

-- The three at a glance, on fixed numbers
SELECT
    GREATEST(100, 200, 300) AS greatest_value,    -- 300
    LEAST(100, 200, 300)    AS least_value,       -- 100
    GREATEST(100, NULL)     AS greatest_with_null; -- 100 in PostgreSQL

-- ... and on real salaries
SELECT
    first_name,
    last_name,
    monthly_salary,
    CASE WHEN monthly_salary > 1500000 THEN 'High' ELSE 'Low' END AS salary_band,
    LEAST(monthly_salary, 2000000.00)    AS bonus_base_capped,   -- at most 2,000,000
    GREATEST(monthly_salary, 1000000.00) AS raised_to_minimum    -- at least 1,000,000
    -- (writing .00 keeps every result at 2 decimals, like the salary column)
FROM lecturers
ORDER BY monthly_salary DESC;                                 -- 4 High, 4 Low


-- =============================================================================
-- 2. Searched CASE: Classifying Values into Ranges
-- =============================================================================
-- Degree classification from the GPA view
SELECT
    student_name,
    gpa,
    CASE
        WHEN gpa >= 3.60 THEN 'First Class'
        WHEN gpa >= 3.00 THEN 'Second Class Upper'
        WHEN gpa >= 2.00 THEN 'Second Class Lower'
        WHEN gpa >= 1.00 THEN 'Pass'
        ELSE 'Academic Probation'
    END AS classification
FROM student_gpa
ORDER BY gpa DESC;

-- Order matters: if 'gpa >= 1.00' came first, EVERY student with a GPA of
-- 1.00 or more would be labelled 'Pass'.


-- =============================================================================
-- 3. CASE vs. a Lookup Table
-- =============================================================================
-- You could turn percentages into letters with CASE...
SELECT
    student_id,
    course_code,
    final_percent,
    CASE
        WHEN final_percent >= 80 THEN 'A'
        WHEN final_percent >= 70 THEN 'B'
        WHEN final_percent >= 60 THEN 'C'
        WHEN final_percent >= 50 THEN 'D'
        ELSE 'F'
    END          AS letter_from_case,
    letter_grade AS letter_from_grade_scale
FROM final_grades
ORDER BY final_percent DESC;
-- ...but our database stores the rules in the grade_scale TABLE instead.
-- If the university changes the scale, we update 5 rows in grade_scale
-- rather than editing every query that contains this CASE.


-- =============================================================================
-- 4. Simple CASE: Translating Codes
-- =============================================================================
SELECT
    registration_no,
    first_name,
    status,
    CASE status
        WHEN 'Active'    THEN 'May register for courses'
        WHEN 'Suspended' THEN 'Must see the Dean first'
        ELSE 'No longer studying'
    END AS registration_rule
FROM students
ORDER BY status, registration_no;

-- Careful: simple CASE uses "=", so "CASE phone WHEN NULL" never matches.
-- Test for NULL with a searched CASE:
SELECT
    first_name,
    CASE
        WHEN phone IS NULL THEN 'Missing - ask the student'
        ELSE phone
    END AS phone_check
FROM students
WHERE student_id IN (5, 6);


-- =============================================================================
-- 5. CASE in ORDER BY: a Custom Sort Order
-- =============================================================================
-- Sort lecturers by seniority instead of alphabetically
SELECT
    first_name,
    last_name,
    academic_rank
FROM lecturers
ORDER BY
    CASE academic_rank
        WHEN 'Professor'           THEN 1
        WHEN 'Associate Professor' THEN 2
        WHEN 'Senior Lecturer'     THEN 3
        WHEN 'Lecturer'            THEN 4
        WHEN 'Assistant Lecturer'  THEN 5
    END,
    last_name;


-- =============================================================================
-- 6. CASE Inside Aggregates: Counting by Category (preview of module 06)
-- =============================================================================
-- One row that counts students per status
SELECT
    COUNT(*)                                             AS all_students,     -- 15
    SUM(CASE WHEN status = 'Active'    THEN 1 ELSE 0 END) AS active,          -- 12
    SUM(CASE WHEN status = 'Graduated' THEN 1 ELSE 0 END) AS graduated,       -- 1
    SUM(CASE WHEN status IN ('Suspended', 'Withdrawn')
             THEN 1 ELSE 0 END)                          AS inactive          -- 2
FROM students;


-- =============================================================================
-- 7. CASE in an UPDATE
-- =============================================================================
-- Increase capacity: large rooms +10 seats, smaller rooms +5 (practice only).
BEGIN;
    UPDATE course_offerings
    SET capacity = CASE
                       WHEN capacity >= 60 THEN capacity + 10
                       ELSE capacity + 5
                   END
    WHERE term_id = 3
    RETURNING offering_id, capacity;              -- 40 -> 45, 45 -> 50
ROLLBACK;


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: Put lecturers into salary bands: 'Senior' (2,000,000 RWF or more),
--             'Middle' (1,200,000 to 1,999,999) and 'Junior' (below 1,200,000).
-- Exercise 2: Using student_balances, label each invoice 'Paid' (balance 0),
--             'Nothing paid' (total_paid = 0) or 'Partly paid'.
-- Exercise 3: Label each assessment 'Exam' when its type is 'Final Exam' and
--             'Continuous assessment' otherwise.
-- Exercise 4: Count, in one row, how many enrollments are Registered, Completed
--             and Dropped.
