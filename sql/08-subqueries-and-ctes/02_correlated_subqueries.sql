/*
================================================================================
Topic: Correlated Subqueries
Objective: Understand row-by-row correlated execution where inner queries reference 
           attributes from the outer query.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- In an uncorrelated subquery, the inner query runs ONCE and its result is reused.
-- In a CORRELATED subquery, the inner query depends on the current row of the 
-- outer query, executing repeatedly for each row evaluated by the outer query.
-- Because of this row-by-row dependency, correlated subqueries must be written 
-- carefully to avoid performance bottlenecks on massive datasets.

-- =============================================================================
-- 2. Instructors Earning More Than Their Department's Average Salary
-- =============================================================================

SELECT 
    outer_inst.instructor_id,
    outer_inst.first_name,
    outer_inst.last_name,
    outer_inst.department_id,
    outer_inst.salary
FROM instructors outer_inst
WHERE outer_inst.salary > (
    -- Inner query references outer_inst.department_id!
    SELECT AVG(inner_inst.salary)
    FROM instructors inner_inst
    WHERE inner_inst.department_id = outer_inst.department_id
)
ORDER BY outer_inst.department_id;

-- =============================================================================
-- 3. Top Student(s) in Each Department
-- =============================================================================

SELECT 
    s_out.student_id,
    s_out.first_name,
    s_out.last_name,
    s_out.department_id,
    s_out.gpa
FROM students s_out
WHERE s_out.gpa = (
    -- Find highest GPA within the specific student's department
    SELECT MAX(s_in.gpa)
    FROM students s_in
    WHERE s_in.department_id = s_out.department_id
)
ORDER BY s_out.department_id;

-- =============================================================================
-- 4. Correlated Subquery in SELECT Clause (Counting Related Rows)
-- =============================================================================

-- For each department, dynamically count students without a full table join:
SELECT 
    d.department_id,
    d.department_name,
    (
        SELECT COUNT(*) 
        FROM students s 
        WHERE s.department_id = d.department_id
    ) AS student_count
FROM departments d;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Find all courses whose credits are higher than the average credits 
--             of courses within the same department.
-- Exercise 2: Rewrite the correlated query in section 4 using a standard LEFT JOIN 
--             and GROUP BY. Compare the two approaches.
