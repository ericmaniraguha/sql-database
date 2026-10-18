/*
================================================================================
Topic: Filtering Rows with WHERE, AND, OR, and NOT
Objective: Understand Boolean logic, operator precedence, and compound predicates 
           to filter relational datasets accurately.
Database: PostgreSQL / MySQL / Oracle
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

-- Find all students registered in department 1 (Computer Science)
SELECT student_id, first_name, last_name, department_id, gpa
FROM students
WHERE department_id = 1;

-- =============================================================================
-- 3. Combining Conditions with AND
-- =============================================================================

-- Find students in department 1 who also have a GPA >= 3.50
SELECT student_id, first_name, last_name, department_id, gpa
FROM students
WHERE department_id = 1 
  AND gpa >= 3.50;

-- =============================================================================
-- 4. Alternative Conditions with OR
-- =============================================================================

-- Find students enrolled in either Computer Science (1) or Business (2)
SELECT student_id, first_name, last_name, department_id
FROM students
WHERE department_id = 1 
   OR department_id = 2;

-- =============================================================================
-- 5. Operator Precedence: The Parentheses Trap
-- =============================================================================

-- INTENT: Find active students in either department 1 OR department 2
-- INCORRECT (AND takes precedence over OR):
SELECT student_id, first_name, department_id, status
FROM students
WHERE department_id = 1 OR department_id = 2 AND status = 'Active';
-- This actually evaluates to: department_id = 1 OR (department_id = 2 AND status = 'Active')

-- CORRECT (Explicit parentheses):
SELECT student_id, first_name, department_id, status
FROM students
WHERE (department_id = 1 OR department_id = 2) 
  AND status = 'Active';

-- =============================================================================
-- 6. Negation with NOT
-- =============================================================================

-- Find all instructors who are NOT in department 1
SELECT instructor_id, first_name, last_name, department_id, salary
FROM instructors
WHERE NOT (department_id = 1);

-- =============================================================================
-- 7. Practice Questions
-- =============================================================================
-- Exercise 1: Find all instructors earning more than $60,000 who are NOT Professors.
-- Exercise 2: Find all courses with 4 credits that belong to department 1 OR department 4.
