/*
================================================================================
Topic: Aggregate Window Functions: AVG, MAX, MIN, SUM, and COUNT
Objective: Calculate window-scoped averages, maximums, minimums, running sums, 
           and row counts while preserving individual row details.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: The 5 Core Aggregate Window Functions
-- =============================================================================
-- Unlike standard aggregate functions with GROUP BY (which collapse multiple rows 
-- into a single row), Aggregate Window Functions compute metrics over a specified 
-- window of rows while keeping each individual row distinct in the output.
--
-- The Core Aggregate Window Functions:
-- 1. AVG()   : Calculates the average value in the window.
-- 2. MAX()   : Finds the maximum value in the window.
-- 3. MIN()   : Finds the minimum value in the window.
-- 4. SUM()   : Calculates the total sum of values in the window.
-- 5. COUNT() : Counts the number of rows or non-null values in the window.

-- =============================================================================
-- 2. Comprehensive Demonstration: All 5 Aggregates in One Query
-- =============================================================================
-- Inspect each instructor's salary alongside department-level aggregate benchmarks:

SELECT 
    instructor_id,
    first_name,
    last_name,
    department_id,
    salary,
    -- 1. COUNT: Total instructors in this department
    COUNT(*)               OVER (PARTITION BY department_id) AS dept_instructor_count,
    -- 2. SUM: Total payroll for this department
    SUM(salary)            OVER (PARTITION BY department_id) AS dept_total_payroll,
    -- 3. AVG: Average salary in this department
    ROUND(AVG(salary)      OVER (PARTITION BY department_id), 2) AS dept_avg_salary,
    -- 4. MIN: Lowest salary in this department
    MIN(salary)            OVER (PARTITION BY department_id) AS dept_min_salary,
    -- 5. MAX: Highest salary in this department
    MAX(salary)            OVER (PARTITION BY department_id) AS dept_max_salary
FROM instructors
ORDER BY department_id, salary DESC;

-- =============================================================================
-- 3. Comparative Analytics: Deviation from Window Benchmarks
-- =============================================================================
-- Compare each student's GPA to both the department average and department maximum:

SELECT 
    student_id,
    first_name,
    last_name,
    department_id,
    gpa,
    ROUND(AVG(gpa) OVER (PARTITION BY department_id), 2) AS dept_avg_gpa,
    MAX(gpa)       OVER (PARTITION BY department_id)     AS dept_max_gpa,
    MIN(gpa)       OVER (PARTITION BY department_id)     AS dept_min_gpa,
    -- Difference from department average
    ROUND(gpa - AVG(gpa) OVER (PARTITION BY department_id), 2) AS diff_from_dept_avg,
    -- Gap from department top performer
    ROUND(MAX(gpa) OVER (PARTITION BY department_id) - gpa, 2) AS gap_to_first_place
FROM students
ORDER BY department_id, gpa DESC;

-- =============================================================================
-- 4. Cumulative Running Totals with SUM() and Window Framing
-- =============================================================================
-- When ORDER BY is present inside OVER(), the default frame is:
--   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- Cumulative department payroll expenditure as faculty joined over time:
SELECT 
    department_id,
    first_name,
    last_name,
    hire_date,
    salary,
    -- Cumulative running sum within department
    SUM(salary) OVER (
        PARTITION BY department_id 
        ORDER BY hire_date ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_dept_payroll
FROM instructors
ORDER BY department_id, hire_date ASC;

-- =============================================================================
-- 5. Moving Averages with AVG() and Explicit Window Slices
-- =============================================================================
-- Calculate a 3-row moving average (current row + 1 preceding + 1 following):

SELECT 
    enrollment_id,
    student_id,
    academic_year,
    semester,
    numeric_grade,
    ROUND(AVG(numeric_grade) OVER (
        ORDER BY academic_year ASC, semester ASC
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ), 2) AS moving_avg_3_terms
FROM enrollments
WHERE numeric_grade IS NOT NULL
ORDER BY academic_year, semester;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Calculate each instructor's salary as an exact percentage of their 
--             department's total payroll using SUM() OVER (PARTITION BY department_id).
-- Exercise 2: Write a query showing each course along with the total count and average 
--             credits of all courses in the same department.
-- Exercise 3: What is the difference between `COUNT(*) OVER ()` and `COUNT(*) OVER (PARTITION BY department_id)`?
