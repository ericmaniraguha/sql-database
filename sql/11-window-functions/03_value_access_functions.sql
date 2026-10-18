/*
================================================================================
Topic: Value Access Functions: LAG, LEAD, FIRST_VALUE, LAST_VALUE, and NTH_VALUE
Objective: Access values from prior, subsequent, boundary, or arbitrary nth rows 
           in a window frame without complex self-joins.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: Value Access Functions
-- =============================================================================
-- Value access functions retrieve values from specific rows relative to the current
-- row, or from absolute positions (first, last, nth) within the window frame.
--
-- The 5 Core Value Access Functions:
-- 1. LAG(col, offset, default)  : Accesses a value from a PREVIOUS row.
-- 2. LEAD(col, offset, default) : Accesses a value from a SUBSEQUENT row.
-- 3. FIRST_VALUE(col)           : Returns the FIRST value in the window frame.
-- 4. LAST_VALUE(col)            : Returns the LAST value in the window frame.
-- 5. NTH_VALUE(col, n)          : Returns the Nth value in the window frame.

-- =============================================================================
-- 2. Prior and Subsequent Offsets: LAG() and LEAD()
-- =============================================================================

-- Compare each instructor's salary with the preceding and next hired colleague:
SELECT 
    instructor_id,
    first_name,
    last_name,
    hire_date,
    salary,
    -- LAG: Access salary of previous hire (fallback to 0.00 if first row)
    LAG(salary, 1, 0.00) OVER (ORDER BY hire_date ASC) AS prev_hire_salary,
    -- LEAD: Access salary of next hire (fallback to 0.00 if last row)
    LEAD(salary, 1, 0.00) OVER (ORDER BY hire_date ASC) AS next_hire_salary,
    -- Calculate salary change compared to previous hire
    salary - LAG(salary, 1, salary) OVER (ORDER BY hire_date ASC) AS salary_diff_vs_prev
FROM instructors
ORDER BY hire_date ASC;

-- =============================================================================
-- 3. Absolute Boundary Values: FIRST_VALUE()
-- =============================================================================
-- Compare each student's GPA against the top student in their department:

SELECT 
    student_id,
    department_id,
    first_name,
    last_name,
    gpa,
    -- FIRST_VALUE: Returns the highest GPA in this department
    FIRST_VALUE(gpa) OVER (
        PARTITION BY department_id 
        ORDER BY gpa DESC
    ) AS highest_dept_gpa,
    -- FIRST_VALUE: Returns the name of the top student in this department
    FIRST_VALUE(first_name || ' ' || last_name) OVER (
        PARTITION BY department_id 
        ORDER BY gpa DESC
    ) AS valedictorian_name
FROM students
ORDER BY department_id, gpa DESC;

-- =============================================================================
-- 4. The Critical LAST_VALUE() Framing Gotcha!
-- =============================================================================
-- CRITICAL GOTCHA:
-- By default, when ORDER BY is present, the window frame is:
--   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- Because the window stops at the "CURRENT ROW", calling LAST_VALUE() without 
-- an explicit frame will simply return the CURRENT ROW's value!
--
-- FIX: You MUST specify `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`
-- so the window covers the entire partition from start to end:

SELECT 
    student_id,
    department_id,
    first_name,
    last_name,
    gpa,
    -- INCORRECT (returns current row value because frame ends at current row):
    LAST_VALUE(gpa) OVER (
        PARTITION BY department_id 
        ORDER BY gpa DESC
    ) AS incorrect_last_value,
    -- CORRECT: Explicitly expand frame to entire partition
    LAST_VALUE(gpa) OVER (
        PARTITION BY department_id 
        ORDER BY gpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_dept_gpa
FROM students
ORDER BY department_id, gpa DESC;

-- =============================================================================
-- 5. Positional Arbitrary Lookups: NTH_VALUE()
-- =============================================================================
-- Retrieve the 2nd highest earner's salary in each department (Runner-up):
-- (Supported in PostgreSQL, MySQL 8.0+, Oracle):

SELECT 
    department_id,
    first_name,
    last_name,
    salary,
    -- NTH_VALUE(col, 2): Returns the 2nd value in the department
    NTH_VALUE(salary, 2) OVER (
        PARTITION BY department_id 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_highest_dept_salary
FROM instructors
ORDER BY department_id, salary DESC;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Using LAG, calculate the percentage increase in salary between 
--             consecutive instructor hires.
-- Exercise 2: Why does LAST_VALUE() require `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` 
--             to find the minimum/last value in an ordered window?
-- Exercise 3: Using NTH_VALUE(), find the 3rd highest student GPA in each department.
