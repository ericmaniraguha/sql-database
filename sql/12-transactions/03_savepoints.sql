/*
================================================================================
Topic: Granular Rollbacks with SAVEPOINT
Objective: Create intermediate checkpoints within a transaction to perform 
           partial rollbacks without abandoning the entire transaction.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A SAVEPOINT creates a named marker inside an active transaction.
-- Instead of rolling back the entire transaction to the beginning, you can roll back
-- to a specific savepoint, discarding only the statements executed after that savepoint.
--
-- Syntax:
-- - SAVEPOINT savepoint_name;
-- - ROLLBACK TO SAVEPOINT savepoint_name;
-- - RELEASE SAVEPOINT savepoint_name; -- Frees the savepoint marker

-- =============================================================================
-- 2. Scenario: Multi-Stage Student Registration with Partial Fallback
-- =============================================================================

START TRANSACTION;

-- Step 1: Insert new student Alice's transfer record
INSERT INTO students (first_name, last_name, email, birth_date, department_id, gpa, status)
VALUES ('Thierry', 'Mugisha', 't.mugisha@student.ulk.ac.rw', '2003-09-14', 1, 3.60, 'Active');

-- Checkpoint 1: Student profile created successfully
SAVEPOINT student_created;

-- Step 2: Attempt primary course enrollment (CS101)
INSERT INTO enrollments (student_id, course_id, semester, academic_year, numeric_grade, status)
VALUES (9, 1, 'Fall', 2026, NULL, 'Enrolled');

-- Checkpoint 2: Primary course enrolled
SAVEPOINT cs101_enrolled;

-- Step 3: Attempt elective enrollment in full/restricted course (Simulate issue)
-- Suppose this step hits a constraint or business rule:
SAVEPOINT before_elective;

-- Hypothetical invalid enrollment or wrong course:
-- Assume business validation detects an issue here:
ROLLBACK TO SAVEPOINT before_elective; -- Only undo the elective attempt!

-- Alice is still registered, and still enrolled in CS101!
-- Commit the valid portions:
COMMIT;

-- Verify Thierry was saved:
SELECT student_id, first_name, last_name, email 
FROM students 
WHERE email = 't.mugisha@student.ulk.ac.rw';

-- Clean up test row:
DELETE FROM enrollments WHERE student_id = 9;
DELETE FROM students WHERE student_id = 9;

-- =============================================================================
-- 3. Practice Questions
-- =============================================================================
-- Exercise 1: Why is RELEASE SAVEPOINT useful in long-running batch transactions?
-- Exercise 2: Does executing ROLLBACK TO SAVEPOINT end the active transaction?
