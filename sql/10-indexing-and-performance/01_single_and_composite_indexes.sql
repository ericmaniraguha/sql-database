/*
================================================================================
Topic: Single-Column and Composite B-Tree Indexes
Objective: Accelerate query execution with B-Tree indexes, understand composite 
           indexes, and apply the Leftmost Prefix Rule.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: How Indexes Work
-- =============================================================================
-- An index is a separate data structure (usually a balanced B-Tree) that maintains
-- sorted pointers to rows in a table, similar to an index at the back of a textbook.
-- - Without an index: The database must perform a Full Table Scan (O(N) time complexity).
-- - With a B-Tree index: The database performs an Index Lookup (O(log N) time complexity).
--
-- Trade-Off:
-- Indexes dramatically speed up SELECT queries, but slow down INSERT, UPDATE, and DELETE
-- because every index must be synchronously updated on disk when data changes!

-- =============================================================================
-- 2. Creating Single-Column Indexes
-- =============================================================================

-- Foreign key columns should almost ALWAYS be indexed for fast joins:
CREATE INDEX idx_students_department_id 
ON students(department_id);

CREATE INDEX idx_courses_department_id 
ON courses(department_id);

CREATE INDEX idx_courses_instructor_id 
ON courses(instructor_id);

CREATE INDEX idx_enrollments_student_id 
ON enrollments(student_id);

CREATE INDEX idx_enrollments_course_id 
ON enrollments(course_id);

-- Speed up filtering by student GPA:
CREATE INDEX idx_students_gpa 
ON students(gpa);

-- =============================================================================
-- 3. Composite (Multi-Column) Indexes & The Leftmost Prefix Rule
-- =============================================================================
-- A composite index covers two or more columns in a specific order:

CREATE INDEX idx_enrollments_term_year 
ON enrollments(academic_year, semester);

-- The Leftmost Prefix Rule:
-- A composite index on (A, B) CAN speed up:
--   1. WHERE A = ... AND B = ...  (Both columns)
--   2. WHERE A = ...              (Leftmost prefix)
-- BUT CANNOT speed up:
--   3. WHERE B = ...              (Without column A, the index cannot be traversed!)

-- Efficiently utilizes idx_enrollments_term_year:
SELECT * FROM enrollments WHERE academic_year = 2022 AND semester = 'Fall';
SELECT * FROM enrollments WHERE academic_year = 2022;

-- CANNOT utilize idx_enrollments_term_year directly:
SELECT * FROM enrollments WHERE semester = 'Fall';

-- =============================================================================
-- 4. Dropping Unneeded Indexes
-- =============================================================================

-- MySQL syntax:
-- DROP INDEX idx_students_gpa ON students;

-- PostgreSQL / Oracle syntax:
DROP INDEX IF EXISTS idx_students_gpa;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: If your application frequently executes:
--             WHERE last_name = ? AND first_name = ?
--             What composite index should you create?
-- Exercise 2: Why shouldn't you index a column like 'gender' or 'is_active' that has 
--             only 2 distinct values (low cardinality)?
