/*
================================================================================
Topic: Advanced Aggregation: ROLLUP, CUBE, and GROUPING SETS
Objective: Generate multi-level subtotals, grand totals, and multidimensional 
           reporting aggregates in a single query.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- In reporting and Business Intelligence (BI), you frequently need subtotals at
-- various hierarchy levels (e.g., department subtotals, rank subtotals, and grand totals).
-- Instead of running multiple queries and combining them with UNION ALL:
-- - ROLLUP: Generates hierarchical subtotals from right to left, plus a grand total.
-- - CUBE: Generates all possible combinations of subtotals across specified dimensions.
-- - GROUPING SETS: Lets you define exact, custom aggregation levels.

-- =============================================================================
-- 2. Hierarchical Subtotals with ROLLUP
-- =============================================================================

-- Calculate payroll by department and rank, with department subtotals and grand total
-- Standard ANSI / PostgreSQL / Oracle syntax:
SELECT 
    department_id,
    academic_rank,
    COUNT(*)    AS instructor_count,
    SUM(salary) AS total_payroll
FROM instructors
GROUP BY ROLLUP (department_id, academic_rank)
ORDER BY department_id NULLS LAST, academic_rank NULLS LAST;

-- In MySQL 8.0+:
-- SELECT department_id, academic_rank, COUNT(*), SUM(salary) 
-- FROM instructors 
-- GROUP BY department_id, academic_rank WITH ROLLUP;

-- =============================================================================
-- 3. Identifying Subtotal Rows with GROUPING()
-- =============================================================================
-- The GROUPING() function returns 1 if a column was aggregated (is a subtotal), or 0 if it's a detail row.

SELECT 
    CASE 
        WHEN GROUPING(department_id) = 1 THEN 'All Departments (Grand Total)'
        ELSE CAST(department_id AS VARCHAR(10))
    END AS department,
    CASE 
        WHEN GROUPING(academic_rank) = 1 THEN 'All Ranks (Subtotal)'
        ELSE academic_rank
    END AS rank_title,
    SUM(salary) AS payroll
FROM instructors
GROUP BY ROLLUP (department_id, academic_rank);

-- =============================================================================
-- 4. Custom Levels with GROUPING SETS (PostgreSQL / Oracle)
-- =============================================================================

-- Summarize enrollments: (1) by academic_year, (2) by semester, and (3) overall total
SELECT 
    academic_year,
    semester,
    COUNT(*) AS total_enrollments
FROM enrollments
GROUP BY GROUPING SETS (
    (academic_year, semester),
    (academic_year),
    ()
);

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Using ROLLUP, generate student counts grouped by department_id and status,
--             including department subtotals and overall student count.
-- Exercise 2: What is the main advantage of using ROLLUP over running three separate 
--             queries combined with UNION ALL?
