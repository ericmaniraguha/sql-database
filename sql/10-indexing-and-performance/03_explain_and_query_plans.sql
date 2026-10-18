/*
================================================================================
Topic: Execution Plans and Query Performance Tuning with EXPLAIN
Objective: Read and interpret query execution plans, identify sequential scans, 
           and verify index usage across PostgreSQL, MySQL, and Oracle.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: The Cost-Based Optimizer (CBO)
-- =============================================================================
-- Before executing any query, the database optimizer parses the SQL, evaluates
-- multiple candidate execution paths, and picks the plan with the lowest estimated cost.
-- The EXPLAIN command lets developers inspect the optimizer's selected plan.
--
-- Key Scan Types:
-- - Sequential Scan / Table Scan (Seq Scan): Scans every single page of the table.
-- - Index Scan: Traverses B-Tree to find matching row pointers, then fetches rows from heap.
-- - Index Only Scan (Covering Index): Retrieves ALL required columns directly from the index.
-- - Bitmap Index Scan: Creates a bitmap of matching pages, then reads them in physical order.

-- =============================================================================
-- 2. PostgreSQL EXPLAIN and EXPLAIN ANALYZE
-- =============================================================================
-- - EXPLAIN: Shows the estimated plan without executing the query.
-- - EXPLAIN ANALYZE: Actually executes the query and shows real runtime vs estimated cost.

-- In PostgreSQL:
/*
EXPLAIN ANALYZE 
SELECT * 
FROM students 
WHERE gpa >= 3.80;

EXPLAIN ANALYZE
SELECT s.first_name, s.last_name, d.department_name
FROM students s
INNER JOIN departments d ON s.department_id = d.department_id;
*/

-- =============================================================================
-- 3. MySQL EXPLAIN
-- =============================================================================

-- MySQL EXPLAIN formats: Traditional tabular and JSON
EXPLAIN
SELECT * 
FROM students 
WHERE department_id = 1;

-- Detailed JSON execution plan in MySQL 8.0+:
EXPLAIN FORMAT=TREE
SELECT s.student_id, s.first_name, c.course_code
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id;

-- =============================================================================
-- 4. Oracle EXPLAIN PLAN
-- =============================================================================
-- In Oracle:
/*
EXPLAIN PLAN FOR
SELECT * FROM students WHERE gpa >= 3.80;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
*/

-- =============================================================================
-- 5. Performance Red Flags to Watch Out For
-- =============================================================================
-- 1. "Seq Scan" or "ALL" type on large tables (missing index).
-- 2. "Temporary" and "Filesort" in MySQL (memory sorting spilled to disk).
-- 3. Applying functions on indexed columns (e.g. WHERE YEAR(hire_date) = 2022).
-- 4. Subqueries with large row counts when a JOIN would be optimized.

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Run EXPLAIN on a query filtering instructors by email. Does it use the index?
-- Exercise 2: What is the difference between EXPLAIN and EXPLAIN ANALYZE?
