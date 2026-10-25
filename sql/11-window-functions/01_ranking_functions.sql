/*
================================================================================
Topic: Window Ranking Functions
Objective: Number and rank rows with ROW_NUMBER, RANK and DENSE_RANK, compute
           relative positions with PERCENT_RANK / CUME_DIST, split rows into
           buckets with NTILE, and find the top N per group.
Database: PostgreSQL (pgAdmin)
          MySQL 8.0+ / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A window function calculates a value for EACH row from a "window" of
-- related rows, WITHOUT collapsing the rows like GROUP BY does.
--
--   function() OVER (PARTITION BY ...   -- optional: restart for each group
--                    ORDER BY ...)      -- the order used for ranking
--
-- With ties (equal values) the three ranking functions differ:
--   value    ROW_NUMBER  RANK  DENSE_RANK
--   4.00         1         1       1
--   4.00         2         1       1
--   3.57         3         3       2       RANK skips 2; DENSE_RANK does not
--
-- PERCENT_RANK() = (rank - 1) / (rows - 1)   -> 0 for the first row, 1 for the last
-- CUME_DIST()    = share of rows <= this row -> between 0 and 1
-- NTILE(n)       = split the ordered rows into n buckets of (nearly) equal size


-- =============================================================================
-- 2. ROW_NUMBER, RANK and DENSE_RANK Side by Side
-- =============================================================================
-- student_gpa has real ties: three students on 4.00, two on 3.00, two on 0.00.
SELECT
    student_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS row_number,
    RANK()       OVER (ORDER BY gpa DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS dense_rank
FROM student_gpa
ORDER BY gpa DESC, student_name;
-- ROW_NUMBER breaks ties arbitrarily. To make it repeatable, add a tie-breaker:
--   ROW_NUMBER() OVER (ORDER BY gpa DESC, student_name)


-- =============================================================================
-- 3. Relative Position: PERCENT_RANK and CUME_DIST
-- =============================================================================
SELECT
    first_name,
    last_name,
    monthly_salary,
    RANK() OVER (ORDER BY monthly_salary)                              AS salary_rank,
    ROUND((PERCENT_RANK() OVER (ORDER BY monthly_salary))::NUMERIC, 2) AS percent_rank,
    ROUND((CUME_DIST()    OVER (ORDER BY monthly_salary))::NUMERIC, 2) AS cume_dist
FROM lecturers
ORDER BY monthly_salary;
-- Lowest earner: percent_rank 0.00. Highest: 1.00.
-- ::NUMERIC converts the floating-point result so ROUND(x, 2) can be used.


-- =============================================================================
-- 4. Buckets with NTILE
-- =============================================================================
-- Split the 12 graded students into 4 quartiles (1 = top 25%)
SELECT
    student_name,
    gpa,
    NTILE(4) OVER (ORDER BY gpa DESC, student_name) AS quartile
FROM student_gpa
ORDER BY quartile, gpa DESC;                      -- 3 students per quartile


-- =============================================================================
-- 5. PARTITION BY: Ranking Inside Each Group
-- =============================================================================
-- Class position inside each course offering (the rank restarts at 1)
SELECT
    course_code,
    academic_year,
    term_name,
    student_id,
    final_percent,
    RANK() OVER (PARTITION BY offering_id
                 ORDER BY final_percent DESC) AS class_position
FROM final_grades
ORDER BY academic_year, course_code, class_position;


-- =============================================================================
-- 6. Top N per Group
-- =============================================================================
-- Window functions run AFTER WHERE, so they cannot be used in WHERE:
-- SELECT * FROM final_grades
-- WHERE RANK() OVER (PARTITION BY offering_id ORDER BY final_percent DESC) <= 2;
-- Expected: ERROR: window functions are not allowed in WHERE
--
-- Solution: calculate the rank in a CTE (or subquery), then filter it.

-- The 2 best students of every class
WITH ranked AS (
    SELECT
        course_code,
        academic_year,
        term_name,
        student_id,
        final_percent,
        ROW_NUMBER() OVER (PARTITION BY offering_id
                           ORDER BY final_percent DESC) AS position
    FROM final_grades
)
SELECT r.course_code, r.academic_year, r.term_name,
       s.first_name || ' ' || s.last_name AS student,
       r.final_percent, r.position
FROM ranked r
JOIN students s ON s.student_id = r.student_id
WHERE r.position <= 2
ORDER BY r.academic_year, r.course_code, r.position;

-- The highest-paid lecturer in each department
WITH ranked AS (
    SELECT
        department_id,
        first_name,
        last_name,
        monthly_salary,
        RANK() OVER (PARTITION BY department_id
                     ORDER BY monthly_salary DESC) AS salary_rank
    FROM lecturers
)
SELECT department_id, first_name, last_name, monthly_salary
FROM ranked
WHERE salary_rank = 1
ORDER BY department_id;                           -- 4 rows, one per department


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Use NTILE(3) to split the courses into 3 groups by credits.
-- Exercise 2: Rank lecturers by hire_date (most senior first) within each
--             department. Who is the most senior in each department?
-- Exercise 3: Three students tie for 2nd place. What are the next ranks given by
--             RANK() and by DENSE_RANK()?
-- Exercise 4: List the lowest-scoring student of every class.
