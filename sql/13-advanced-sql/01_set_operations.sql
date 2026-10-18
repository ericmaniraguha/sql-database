/*
================================================================================
Topic: Set Operations: UNION, UNION ALL, INTERSECT, and EXCEPT
Objective: Combine and compare distinct query result sets using relational 
           algebra set operators.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: The Rules of Set Operations
-- =============================================================================
-- Set operators combine the outputs of two or more independent SELECT queries.
-- Universal Requirements:
-- 1. Each SELECT query MUST return the exact same number of columns.
-- 2. Corresponding columns MUST have compatible data types.
-- 3. Column names in the final result set are determined by the FIRST query.
-- 4. ORDER BY may only appear ONCE, at the very end of the entire statement.

-- =============================================================================
-- 2. UNION vs UNION ALL: Performance and Deduplication
-- =============================================================================
-- - UNION: Combines results AND removes duplicates (requires expensive sorting/hashing).
-- - UNION ALL: Combines results and PRESERVES duplicates (fastest; no deduplication overhead).

-- List all unique university personnel (instructors and students combined):
SELECT first_name, last_name, email, 'Instructor' AS role
FROM instructors
UNION
SELECT first_name, last_name, email, 'Student' AS role
FROM students
ORDER BY last_name, first_name;

-- UNION ALL example (keeps all records):
SELECT department_id FROM instructors
UNION ALL
SELECT department_id FROM students;

-- =============================================================================
-- 3. INTERSECT: Finding Common Elements
-- =============================================================================
-- Returns only rows that appear in BOTH query results.

-- Departments that have BOTH at least one instructor AND at least one student:
SELECT department_id FROM instructors
INTERSECT
SELECT department_id FROM students;

-- MySQL 8.0.31+ supports INTERSECT; in older MySQL emulate with INNER JOIN:
-- SELECT DISTINCT i.department_id 
-- FROM instructors i 
-- INNER JOIN students s ON i.department_id = s.department_id;

-- =============================================================================
-- 4. EXCEPT / MINUS: Set Difference
-- =============================================================================
-- Returns rows present in the first query that are NOT present in the second query.
-- (PostgreSQL & SQLite use EXCEPT; Oracle uses MINUS; MySQL 8.0.31+ uses EXCEPT).

-- Find departments that have instructors but have NO registered students:
SELECT department_id FROM departments
EXCEPT
SELECT department_id FROM students;

-- Oracle syntax:
-- SELECT department_id FROM departments
-- MINUS
-- SELECT department_id FROM students;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Why should you default to UNION ALL unless duplicate elimination is 
--             strictly required by business logic?
-- Exercise 2: Find all course IDs that have been offered in 'Fall' but never in 'Spring'.
