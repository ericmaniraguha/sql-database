/*
================================================================================
Topic: Window Ranking Functions
Objective: Assign sequential numbers, ranks, percentiles, and bucket quantiles 
           to rows using ROW_NUMBER, RANK, DENSE_RANK, PERCENT_RANK, and NTILE.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: Ranking Functions
-- =============================================================================
-- Ranking window functions calculate a rank or category for each row within a
-- partition, based on an ORDER BY specification.
--
-- Supported Ranking Functions:
-- 1. ROW_NUMBER()   : Assigns a unique, sequential integer (1, 2, 3...) with no ties.
-- 2. RANK()         : Assigns ranks with gaps for ties (1, 2, 2, 4...).
-- 3. DENSE_RANK()   : Assigns ranks without gaps for ties (1, 2, 2, 3...).
-- 4. PERCENT_RANK() : Computes the relative rank as a percentage between 0.0 and 1.0:
--                     Formula: (rank - 1) / (total_rows - 1)
-- 5. NTILE(n)       : Divides ordered rows into 'n' equal buckets (e.g. quartiles, deciles).

-- =============================================================================
-- 2. Side-by-Side Comparison of ROW_NUMBER, RANK, and DENSE_RANK
-- =============================================================================

SELECT 
    student_id,
    first_name,
    last_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS row_num,
    RANK()       OVER (ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS dense_rnk
FROM students
ORDER BY gpa DESC;

-- =============================================================================
-- 3. Relative Ranking: PERCENT_RANK()
-- =============================================================================
-- Evaluates the percentile standing of each instructor's salary across the university:

SELECT 
    instructor_id,
    first_name,
    last_name,
    salary,
    RANK()         OVER (ORDER BY salary ASC) AS salary_asc_rank,
    -- PERCENT_RANK: 0.0 = lowest earner, 1.0 = highest earner
    ROUND(CAST(PERCENT_RANK() OVER (ORDER BY salary ASC) AS NUMERIC), 4) AS salary_percentile
FROM instructors
ORDER BY salary ASC;

-- =============================================================================
-- 4. Bucketing Rows with NTILE(n)
-- =============================================================================
-- Divide students into 4 performance quartiles (Quartile 1 = Top 25% performers):

SELECT 
    student_id,
    first_name,
    last_name,
    gpa,
    NTILE(4) OVER (ORDER BY gpa DESC) AS performance_quartile
FROM students
ORDER BY performance_quartile ASC, gpa DESC;

-- Divide instructors into 2 salary tiers (Higher Half vs Lower Half):
SELECT 
    instructor_id,
    first_name,
    last_name,
    salary,
    NTILE(2) OVER (ORDER BY salary DESC) AS salary_tier_group
FROM instructors
ORDER BY salary DESC;

-- =============================================================================
-- 5. Partitioned Ranking: Top Performers Per Department
-- =============================================================================
-- Ranks reset to 1 inside each department:

SELECT 
    department_id,
    student_id,
    first_name,
    last_name,
    gpa,
    DENSE_RANK() OVER (
        PARTITION BY department_id 
        ORDER BY gpa DESC
    ) AS dept_rank,
    NTILE(2) OVER (
        PARTITION BY department_id 
        ORDER BY gpa DESC
    ) AS dept_half
FROM students
ORDER BY department_id, dept_rank;

-- =============================================================================
-- 6. Classic Query Pattern: Filtering Top N Per Group (via CTE)
-- =============================================================================
-- Note: Window functions cannot be placed directly in a WHERE clause!
-- Use a Common Table Expression (CTE) to filter by window results:

WITH RankedDeptInstructors AS (
    SELECT 
        instructor_id,
        first_name,
        last_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id 
            ORDER BY salary DESC
        ) AS salary_rank
    FROM instructors
)
SELECT 
    department_id,
    instructor_id,
    first_name,
    last_name,
    salary,
    salary_rank
FROM RankedDeptInstructors
WHERE salary_rank <= 2
ORDER BY department_id, salary_rank;

-- =============================================================================
-- 7. Practice Questions
-- =============================================================================
-- Exercise 1: Using NTILE(3), divide all courses into 3 difficulty tiers based on credit hours.
-- Exercise 2: Using PERCENT_RANK(), find the percentile rank of students by GPA within 
--             their respective department.
-- Exercise 3: Explain the difference in output between RANK() and DENSE_RANK() when 
--             three students tie for 2nd place.
