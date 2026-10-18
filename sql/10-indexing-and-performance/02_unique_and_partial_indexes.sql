/*
================================================================================
Topic: UNIQUE, Partial (Filtered), and Function-Based Indexes
Objective: Enforce unique constraints via indexes, create storage-efficient 
           partial indexes, and index expressions and function results.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- - UNIQUE Index: Guarantees no two rows have the same index key values while 
--   providing full search performance.
-- - Partial / Filtered Index: Indexes only a subset of table rows (specified by a 
--   WHERE clause), drastically saving disk space and memory cache.
-- - Function-Based Index: Indexes the computed result of an expression or function 
--   (e.g., LOWER(email)) so searches on that function utilize an index.

-- =============================================================================
-- 2. UNIQUE Indexes
-- =============================================================================

CREATE UNIQUE INDEX idx_uq_instructor_email 
ON instructors(email);

-- Enforce uniqueness of course codes
CREATE UNIQUE INDEX idx_uq_course_code 
ON courses(course_code);

-- =============================================================================
-- 3. Partial (Filtered) Indexes (PostgreSQL / SQLite)
-- =============================================================================
-- Scenario: In an academic database with 100,000 students, only 2% are on 
-- 'Academic Warning'. Indexing the entire table wastes 98% of RAM.
-- A partial index indexes ONLY the warning rows:

-- PostgreSQL syntax:
/*
CREATE INDEX idx_students_active_warning 
ON students(student_id, gpa)
WHERE status = 'Academic Warning';

-- This query uses the small partial index:
SELECT student_id, gpa 
FROM students 
WHERE status = 'Academic Warning' AND gpa < 2.00;
*/

-- In MySQL 8.0+:
-- MySQL does not have partial indexes with WHERE, but supports functional indexes.

-- =============================================================================
-- 4. Function-Based (Expression) Indexes
-- =============================================================================
-- Problem: If you execute WHERE LOWER(email) = 'user@example.com', a standard index 
-- on 'email' CANNOT be used because the function wraps the column.
-- Solution: Create an index on the expression itself!

-- PostgreSQL / Oracle / MySQL 8.0+:
CREATE INDEX idx_students_lower_email 
ON students((LOWER(email)));

-- This query now performs an instant Index Scan instead of a full table scan:
SELECT student_id, first_name, last_name, email
FROM students
WHERE LOWER(email) = 'a.niyonsaba@student.ulk.ac.rw';

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Create a function-based index on UPPER(last_name) in instructors.
-- Exercise 2: Why are partial indexes especially beneficial for soft-deleted tables 
--             where 95% of records have is_deleted = FALSE?
