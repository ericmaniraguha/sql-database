/*
================================================================================
Topic: Subtotals with ROLLUP, CUBE and GROUPING SETS
Objective: Produce subtotals and grand totals in a single query and tell
           subtotal rows apart from detail rows with GROUPING().
Database: PostgreSQL (pgAdmin)
          MySQL 8: only "GROUP BY a, b WITH ROLLUP" (no CUBE / GROUPING SETS)
          Oracle: identical syntax to PostgreSQL
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Reports often need totals at several levels: per course, per term, per year
-- and overall. Instead of several queries glued with UNION ALL:
--   ROLLUP (a, b)         -> (a, b), (a), ()         a hierarchy, right to left
--   CUBE (a, b)           -> (a, b), (a), (b), ()    every combination
--   GROUPING SETS (...)   -> exactly the levels you list
-- In a subtotal row, the columns that were "rolled up" show NULL.


-- =============================================================================
-- 2. ROLLUP: Finance Report with Term Subtotals and a Grand Total
-- =============================================================================
SELECT
    academic_year,
    term_name,
    SUM(total_billed) AS billed,
    SUM(total_paid)   AS collected,
    SUM(balance_due)  AS outstanding
FROM student_balances
GROUP BY ROLLUP (academic_year, term_name)
ORDER BY academic_year NULLS LAST, term_name NULLS LAST;
-- Rows:  (2025/2026, Semester 2)  detail
--        (2025/2026, NULL)        subtotal for 2025/2026
--        (2026/2027, Semester 1)  detail
--        (2026/2027, NULL)        subtotal for 2026/2027
--        (NULL,      NULL)        grand total

-- MySQL 8 version:
-- SELECT academic_year, term_name, SUM(total_billed) ...
-- FROM student_balances GROUP BY academic_year, term_name WITH ROLLUP;


-- =============================================================================
-- 3. GROUPING(): Labelling Subtotal Rows
-- =============================================================================
-- GROUPING(col) = 1 when col was rolled up in this row (subtotal), else 0.
SELECT
    CASE WHEN GROUPING(department_id) = 1 THEN 'ALL DEPARTMENTS'
         ELSE 'Department ' || department_id
    END AS department,
    CASE WHEN GROUPING(academic_rank) = 1 THEN '-- subtotal --'
         ELSE academic_rank
    END AS academic_rank,
    COUNT(*)            AS lecturers,
    SUM(monthly_salary) AS monthly_payroll
FROM lecturers
GROUP BY ROLLUP (department_id, academic_rank)
ORDER BY GROUPING(department_id), department_id,
         GROUPING(academic_rank), academic_rank;

-- Why GROUPING() matters: real NULLs look exactly like subtotal NULLs.
-- Offering 10 has room = NULL. In this ROLLUP, term 3 shows TWO rows with
-- room NULL: the real "no room yet" row and the term 3 subtotal.
SELECT
    term_id,
    room,
    GROUPING(room) AS is_subtotal,                -- 0 = real row, 1 = subtotal
    COUNT(*)       AS offerings
FROM course_offerings
GROUP BY ROLLUP (term_id, room)
ORDER BY term_id NULLS LAST, GROUPING(room), room NULLS FIRST;


-- =============================================================================
-- 4. CUBE: Every Combination
-- =============================================================================
-- Payments by method AND by month, with totals in both directions
SELECT
    payment_method,
    TO_CHAR(payment_date, 'YYYY-MM') AS pay_month,
    COUNT(*)                         AS payments,
    SUM(amount)                      AS total
FROM payments
WHERE payment_date >= '2026-08-01'                -- current-term payments
GROUP BY CUBE (payment_method, TO_CHAR(payment_date, 'YYYY-MM'))
ORDER BY payment_method NULLS LAST, pay_month NULLS LAST;
-- Includes: totals per method (pay_month NULL), totals per month
-- (payment_method NULL) and the grand total (both NULL).


-- =============================================================================
-- 5. GROUPING SETS: Pick the Exact Levels
-- =============================================================================
-- Student counts by programme, by status, and overall, in one result
SELECT
    program_id,
    status,
    COUNT(*) AS students
FROM students
GROUP BY GROUPING SETS (
    (program_id),     -- one row per programme
    (status),         -- one row per status
    ()                -- the grand total
)
ORDER BY program_id NULLS LAST, status NULLS LAST;

-- The same result without GROUPING SETS needs three queries and UNION ALL:
-- SELECT program_id, NULL, COUNT(*) FROM students GROUP BY program_id
-- UNION ALL
-- SELECT NULL, status, COUNT(*) FROM students GROUP BY status
-- UNION ALL
-- SELECT NULL, NULL, COUNT(*) FROM students;


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Use ROLLUP to count students by program_id and status, with a
--             subtotal per programme and an overall total.
-- Exercise 2: Use ROLLUP on salary_payments to show total net pay per
--             pay_month and lecturer_id, with monthly subtotals.
-- Exercise 3: Label the subtotal rows of Exercise 2 with GROUPING().
-- Exercise 4: What is the advantage of ROLLUP over three separate queries
--             combined with UNION ALL?
