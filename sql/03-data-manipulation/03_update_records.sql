/*
================================================================================
Topic: Modifying Records with UPDATE
Objective: Modify existing rows in tables using single-column, multi-column, 
           and expression-based UPDATE statements safely.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The UPDATE statement modifies existing data in a table.
-- CRITICAL WARNING: An UPDATE statement without a WHERE clause modifies EVERY row
-- in the table! Always test the WHERE filter with a SELECT query first.

-- =============================================================================
-- 2. Single Record, Single Column Update
-- =============================================================================

-- Update student status for a specific student ID
UPDATE students
SET status = 'Graduated'
WHERE student_id = 6;

-- Verify change
SELECT student_id, first_name, last_name, status 
FROM students 
WHERE student_id = 6;

-- =============================================================================
-- 3. Updating Multiple Columns Simultaneously
-- =============================================================================

-- Update department budget and building for 'Computer Science'
UPDATE departments
SET 
    budget = 900000.00,
    building = 'Alan Turing Innovation Centre'
WHERE department_code = 'CS';

-- =============================================================================
-- 4. Expression-Based Updates (Calculated Values)
-- =============================================================================

-- Award a 5% salary increase to all Assistant Lecturers and Lecturers
UPDATE instructors
SET salary = ROUND(salary * 1.05, 2)
WHERE academic_rank IN ('Assistant Lecturer', 'Lecturer');

-- Increment credits by 1 for all CS courses that currently have 3 credits
UPDATE courses
SET credits = credits + 1
WHERE department_id = 1 AND credits = 3;

-- =============================================================================
-- 5. Safe Updates Best Practice
-- =============================================================================
-- In MySQL, SQL_SAFE_UPDATES mode prevents UPDATE/DELETE without a key in WHERE.
-- SET SQL_SAFE_UPDATES = 1; -- Enforce safe updates

-- Safe pattern: Preview rows before modifying
-- Step 1: Preview rows to be affected
SELECT student_id, gpa, status 
FROM students 
WHERE gpa < 3.00 AND status = 'Active';

-- Step 2: Apply the targeted update
UPDATE students
SET status = 'Academic Warning'
WHERE gpa < 3.00 AND status = 'Active';

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Give all instructors in department 2 a $3,000 flat bonus added to salary.
-- Exercise 2: Update the enrollment status to 'Completed' for all enrollments in year 2022.
