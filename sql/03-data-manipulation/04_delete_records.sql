/*
================================================================================
Topic: Deleting Records with DELETE
Objective: Understand row removal, foreign key constraint enforcement during 
           deletion, and contrast hard deletion with soft deletion.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The DELETE statement removes specific rows from a table based on a condition.
-- Like UPDATE, executing DELETE without a WHERE clause removes ALL rows in the table.
-- Referential integrity constraints prevent deleting parent rows if active child
-- records reference them (unless ON DELETE CASCADE is configured).

-- =============================================================================
-- 2. Deleting a Specific Record
-- =============================================================================

-- Delete a specific enrollment record
DELETE FROM enrollments
WHERE enrollment_id = 11;

-- =============================================================================
-- 3. Conditional Multi-Row Deletions
-- =============================================================================

-- Delete all enrollments where status is 'Dropped'
DELETE FROM enrollments
WHERE status = 'Dropped';

-- Delete records using a subquery (delete honor roll students whose GPA dropped below 3.7)
DELETE FROM honor_roll_students
WHERE student_id IN (
    SELECT student_id 
    FROM students 
    WHERE gpa < 3.70
);

-- =============================================================================
-- 4. Foreign Key Restraint Demonstration
-- =============================================================================
-- The following statement will fail if student 1 has active enrollments and 
-- the foreign key is set to RESTRICT:
-- DELETE FROM students WHERE student_id = 1;
-- Because fk_enrollments_student has ON DELETE CASCADE, child enrollments are
-- deleted automatically along with the student.

-- =============================================================================
-- 5. Hard Delete vs Soft Delete Pattern
-- =============================================================================
-- In enterprise systems, physically removing data (hard delete) is often avoided.
-- Instead, a 'soft delete' flag is updated so data can be audited or recovered.

-- Step 1: Add is_deleted flag
ALTER TABLE students 
ADD is_deleted BOOLEAN DEFAULT FALSE;

-- Step 2: Soft delete instead of DELETE FROM
UPDATE students
SET is_deleted = TRUE
WHERE student_id = 8;

-- Step 3: Query only active, non-deleted records
SELECT student_id, first_name, last_name 
FROM students
WHERE is_deleted = FALSE;

-- Clean up demonstration column
ALTER TABLE students DROP COLUMN is_deleted;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Write a DELETE query to remove courses with 0 credits if any exist.
-- Exercise 2: Why is Soft Deletion preferred in banking and student grading systems?
