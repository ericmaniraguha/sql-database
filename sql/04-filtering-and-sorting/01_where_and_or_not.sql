/*
================================================================================
Topic: Filtering Rows with WHERE, AND, OR, and NOT
Objective: Understand Boolean logic, operator precedence, and compound predicates 
           to filter relational datasets accurately in the university database.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The WHERE clause filters rows returned by a query based on Boolean expressions.
-- Only rows for which the WHERE predicate evaluates to TRUE are included.
--
-- Operator Precedence:
-- 1. Parentheses ()
-- 2. NOT
-- 3. AND
-- 4. OR
-- Always use parentheses when combining AND with OR to prevent logical bugs!


-- =============================================================================
-- 2. Basic WHERE Condition
-- =============================================================================

-- Find all students registered in program 1 (BSc Computer Science):
SELECT student_id, registration_no, first_name, last_name, program_id, admission_year
FROM students
WHERE program_id = 1;


-- =============================================================================
-- 3. Combining Conditions with AND
-- =============================================================================

-- Find lecturers in department 1 who also earn more than 1,500,000 RWF per month:
SELECT lecturer_id, first_name, last_name, academic_rank, monthly_salary, department_id
FROM lecturers
WHERE department_id = 1 
  AND monthly_salary >= 1500000.00;


-- =============================================================================
-- 4. Alternative Conditions with OR
-- =============================================================================

-- Find students enrolled in either Computer Science (program 1) or Mathematics (program 2):
SELECT student_id, registration_no, first_name, last_name, program_id
FROM students
WHERE program_id = 1 
   OR program_id = 2;


-- =============================================================================
-- 5. Operator Precedence: The Parentheses Trap
-- =============================================================================

-- INTENT: Find ACTIVE students in either program 1 OR program 2
-- INCORRECT (AND takes precedence over OR):
SELECT student_id, first_name, program_id, status
FROM students
WHERE program_id = 1 OR program_id = 2 AND status = 'Active';
-- This actually evaluates as: program_id = 1 OR (program_id = 2 AND status = 'Active')
-- Result: 10 rows, including Alice (Graduated) and Fabrice (Suspended)!

-- CORRECT (Explicit parentheses enforce the intended grouping):
SELECT student_id, first_name, program_id, status
FROM students
WHERE (program_id = 1 OR program_id = 2)
  AND status = 'Active';
-- Result: 8 rows, all Active


-- =============================================================================
-- 6. Negation with NOT
-- =============================================================================

-- Find all lecturers who are NOT in department 1:
SELECT lecturer_id, first_name, last_name, academic_rank, department_id
FROM lecturers
WHERE NOT (department_id = 1);

-- Find courses that do not carry 3 credits:
SELECT course_id, course_code, course_title, credits
FROM courses
WHERE NOT (credits = 3);


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Find all lecturers earning more than 1,000,000 RWF who are NOT 'Professor'.
-- Exercise 2: Find all courses with 4 credits that belong to department 1 OR department 2.
-- Exercise 3: Find all students who were admitted before 2024 and whose status is NOT 'Active'.
