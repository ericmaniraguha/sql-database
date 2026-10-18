/*
================================================================================
Topic: Existence Testing with EXISTS and NOT EXISTS
Objective: Test for the presence of related records using semi-joins and anti-joins, 
           understanding short-circuit evaluation and NULL safety.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: Short-Circuit Evaluation
-- =============================================================================
-- The EXISTS operator tests whether a correlated subquery returns ANY rows.
-- It returns a Boolean: TRUE if at least 1 row exists, FALSE if 0 rows exist.
-- Optimization Advantage:
-- Unlike IN or COUNT(*), the database query engine STOPS searching the moment 
-- the first matching row is found (short-circuit / early exit)!
-- By convention, developers write `SELECT 1` inside the EXISTS subquery.

-- =============================================================================
-- 2. Finding Parent Records with Related Children: EXISTS
-- =============================================================================

-- Find all departments that have at least one active course:
SELECT 
    d.department_id,
    d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1 
    FROM courses c 
    WHERE c.department_id = d.department_id
);

-- Find instructors who actively teach at least one course:
SELECT 
    i.instructor_id,
    i.first_name,
    i.last_name,
    i.email
FROM instructors i
WHERE EXISTS (
    SELECT 1 
    FROM courses c 
    WHERE c.instructor_id = i.instructor_id
);

-- =============================================================================
-- 3. Finding Records Without Matches: NOT EXISTS (Anti-Semi-Join)
-- =============================================================================

-- Find students who have NEVER enrolled in any course:
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.email
FROM students s
WHERE NOT EXISTS (
    SELECT 1 
    FROM enrollments e 
    WHERE e.student_id = s.student_id
);

-- Find courses that have zero enrollments:
SELECT 
    c.course_id,
    c.course_code,
    c.course_name
FROM courses c
WHERE NOT EXISTS (
    SELECT 1 
    FROM enrollments e 
    WHERE e.course_id = c.course_id
);

-- =============================================================================
-- 4. Critical Comparison: NOT EXISTS vs NOT IN with NULLs
-- =============================================================================
-- Why senior database engineers prefer NOT EXISTS over NOT IN:
-- If the inner subquery returns a single row with a NULL value:
--   - NOT IN evaluates to UNKNOWN and returns ZERO rows for the entire query!
--   - NOT EXISTS is completely immune to NULL values and returns the correct result!

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Find all departments that have instructors but NO students using NOT EXISTS.
-- Exercise 2: Why is SELECT 1 conventionally used inside EXISTS subqueries rather than SELECT *?
