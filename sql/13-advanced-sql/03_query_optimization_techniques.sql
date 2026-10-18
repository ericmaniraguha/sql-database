/*
================================================================================
Topic: SQL Query Optimization Techniques and Best Practices
Objective: Identify query anti-patterns, write SARGable queries that utilize 
           indexes, and optimize relational query performance.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: SARGability (Search Argument Able)
-- =============================================================================
-- A query is SARGable if the database engine can directly exploit an existing index
-- to filter rows.
-- The most common reason queries are NOT SARGable is wrapping indexed columns 
-- inside functions, mathematical operators, or type conversions in the WHERE clause.

-- =============================================================================
-- 2. Technique 1: Avoid Functions on Indexed Columns
-- =============================================================================

-- POOR (Non-SARGable: Database must execute EXTRACT() on every single row; Index is ignored):
SELECT instructor_id, first_name, hire_date
FROM instructors
WHERE EXTRACT(YEAR FROM hire_date) = 2018;

-- OPTIMIZED (SARGable: Direct range filter allows B-Tree index seek):
SELECT instructor_id, first_name, hire_date
FROM instructors
WHERE hire_date >= '2018-01-01' AND hire_date < '2019-01-01';

-- =============================================================================
-- 3. Technique 2: Wildcard Placement in LIKE
-- =============================================================================

-- POOR (Leading wildcard '%CS' requires a Full Table Scan because start is unknown):
-- SELECT * FROM courses WHERE course_code LIKE '%CS';

-- OPTIMIZED (Trailing wildcard 'CS%' allows index range scan on B-Tree):
SELECT course_id, course_code, course_name
FROM courses
WHERE course_code LIKE 'CS%';

-- =============================================================================
-- 4. Technique 3: Avoid SELECT * in Application Code
-- =============================================================================
-- Why SELECT * degrades performance:
-- 1. Forces database to read all columns from disk pages, increasing I/O.
-- 2. Prevents the optimizer from utilizing "Index-Only Scans" (Covering Indexes).
-- 3. Transmits unnecessary data across the network to client applications.
-- 4. Vulnerable to breakage if table schema order or columns change.

-- OPTIMIZED: Specify only necessary columns:
SELECT student_id, first_name, email, gpa
FROM students
WHERE department_id = 1;

-- =============================================================================
-- 5. Technique 4: Prefer EXISTS over IN for Large Datasets
-- =============================================================================

-- POOR (May materialize full subquery list in memory before checking):
-- SELECT * FROM departments WHERE department_id IN (SELECT department_id FROM courses);

-- OPTIMIZED (Stops on first match via early exit semi-join):
SELECT d.department_id, d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1 
    FROM courses c 
    WHERE c.department_id = d.department_id
);

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Rewrite `WHERE salary * 1.10 > 75000` into a SARGable predicate.
-- Exercise 2: Why does `WHERE LOWER(last_name) = 'mugabo'` cause a full table scan 
--             unless a function-based index exists?
