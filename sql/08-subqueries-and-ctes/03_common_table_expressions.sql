/*
================================================================================
Topic: Common Table Expressions (CTEs)
Objective: Break a complex query into named, readable steps with WITH, chain
           several CTEs, and reuse one result more than once.
Database: PostgreSQL (pgAdmin)
          MySQL 8.0+ / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
--   WITH step_name AS (
--       SELECT ...            -- a temporary named result
--   )
--   SELECT ... FROM step_name;
--
-- A CTE lives only for the one statement that follows it. Compared with a
-- derived table (subquery in FROM) it:
-- - reads top-down, step by step, like a recipe;
-- - can be referenced several times in the same query;
-- - can be RECURSIVE (file 04).


-- =============================================================================
-- 2. A Single CTE
-- =============================================================================
-- Step 1: salary statistics per department. Step 2: add department names.
WITH department_salaries AS (
    SELECT
        department_id,
        COUNT(*)                      AS lecturers,
        ROUND(AVG(monthly_salary), 0) AS average_salary,
        MAX(monthly_salary)           AS highest_salary
    FROM lecturers
    GROUP BY department_id
)
SELECT
    d.department_name,
    ds.lecturers,
    ds.average_salary,
    ds.highest_salary
FROM departments d
JOIN department_salaries ds ON ds.department_id = d.department_id
ORDER BY ds.average_salary DESC;

-- The same query with a derived table: it works, but you read it inside-out.
SELECT d.department_name, ds.lecturers, ds.average_salary, ds.highest_salary
FROM departments d
JOIN (SELECT department_id,
             COUNT(*)                      AS lecturers,
             ROUND(AVG(monthly_salary), 0) AS average_salary,
             MAX(monthly_salary)           AS highest_salary
      FROM lecturers
      GROUP BY department_id) ds ON ds.department_id = d.department_id
ORDER BY ds.average_salary DESC;


-- =============================================================================
-- 3. Chained CTEs: Each Step Uses the One Before
-- =============================================================================
-- Dean's List per term: term GPA >= 3.50 with at least 3 credits.
WITH
-- Step 1: GPA of each student in each term
term_gpa AS (
    SELECT
        student_id,
        academic_year,
        term_name,
        SUM(credits)                                         AS credits,
        ROUND(SUM(grade_point * credits) / SUM(credits), 2)  AS term_gpa
    FROM final_grades
    GROUP BY student_id, academic_year, term_name
),
-- Step 2: label each result (uses step 1)
labelled AS (
    SELECT
        tg.*,
        CASE
            WHEN tg.term_gpa >= 3.50 AND tg.credits >= 3 THEN 'Dean''s List'
            WHEN tg.term_gpa <  2.00                     THEN 'Academic Warning'
            ELSE 'Good Standing'
        END AS standing
    FROM term_gpa tg
)
-- Main query: add the student's name
SELECT
    s.registration_no,
    s.first_name || ' ' || s.last_name AS student_name,
    l.academic_year,
    l.term_name,
    l.credits,
    l.term_gpa,
    l.standing
FROM labelled l
JOIN students s ON s.student_id = l.student_id
ORDER BY l.academic_year, l.term_name, l.term_gpa DESC;
-- Note: 'Dean''s List' - two single quotes put ONE quote inside a string.


-- =============================================================================
-- 4. Using a CTE Twice
-- =============================================================================
-- Compare every course's class average with the university-wide average.
WITH course_averages AS (
    SELECT course_code, ROUND(AVG(final_percent), 1) AS class_average
    FROM final_grades
    GROUP BY course_code
),
overall AS (
    SELECT ROUND(AVG(class_average), 1) AS university_average
    FROM course_averages                          -- 1st use
)
SELECT
    ca.course_code,
    ca.class_average,
    o.university_average,
    ca.class_average - o.university_average AS difference
FROM course_averages ca                           -- 2nd use
CROSS JOIN overall o                              -- 1 row, added to every course
ORDER BY difference DESC;


-- =============================================================================
-- 5. A Finance Report in Steps
-- =============================================================================
-- Outstanding fees per programme, current term only
WITH current_balances AS (
    SELECT sb.student_id, sb.balance_due
    FROM student_balances sb
    WHERE sb.academic_year = '2026/2027'
      AND sb.term_name     = 'Semester 1'
),
per_programme AS (
    SELECT
        s.program_id,
        COUNT(*)                                       AS students_billed,
        SUM(CASE WHEN cb.balance_due > 0 THEN 1 ELSE 0 END) AS students_owing,
        SUM(cb.balance_due)                            AS outstanding
    FROM current_balances cb
    JOIN students s ON s.student_id = cb.student_id
    GROUP BY s.program_id
)
SELECT p.program_name, pp.students_billed, pp.students_owing, pp.outstanding
FROM per_programme pp
JOIN programs p ON p.program_id = pp.program_id
ORDER BY pp.outstanding DESC;


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: With a CTE, compute the average GPA from student_gpa, then list
--             the students above it.
-- Exercise 2: With two chained CTEs, find the department whose courses have the
--             most enrollments (step 1: enrollments per course; step 2: per
--             department).
-- Exercise 3: Rewrite the query in Section 4 without CTEs. Which version is
--             easier to read?
