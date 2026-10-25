/*
================================================================================
Topic: Aggregate Window Functions: SUM, AVG, COUNT, MIN, MAX with OVER
Objective: Show group totals next to every row, compare rows with their group,
           compute percentages of a total, running totals and moving averages,
           and understand window frames (ROWS vs. RANGE).
Database: PostgreSQL (pgAdmin)
          MySQL 8.0+ / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- GROUP BY            : many rows in  -> ONE row per group out
-- aggregate OVER (...) : many rows in  -> the SAME rows out, each one showing
--                                        the aggregate of its window
--
--   SUM(x) OVER ()                         total of ALL rows
--   SUM(x) OVER (PARTITION BY g)           total of the row's group
--   SUM(x) OVER (PARTITION BY g ORDER BY t) RUNNING total inside the group
--
-- When OVER has an ORDER BY, the default frame is
--   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- = "from the first row up to this row AND every row tied with it" (Section 5).


-- =============================================================================
-- 2. Group Totals Next to Every Row
-- =============================================================================
SELECT
    department_id,
    first_name,
    last_name,
    monthly_salary,
    COUNT(*)                     OVER (PARTITION BY department_id) AS dept_lecturers,
    SUM(monthly_salary)          OVER (PARTITION BY department_id) AS dept_payroll,
    ROUND(AVG(monthly_salary)    OVER (PARTITION BY department_id), 0) AS dept_average,
    MIN(monthly_salary)          OVER (PARTITION BY department_id) AS dept_lowest,
    MAX(monthly_salary)          OVER (PARTITION BY department_id) AS dept_highest
FROM lecturers
ORDER BY department_id, monthly_salary DESC;

-- The same numbers with GROUP BY give 4 rows and lose the lecturer names.


-- =============================================================================
-- 3. Comparing Each Row with Its Group
-- =============================================================================
-- Each result compared with its class average and the best result in the class
SELECT
    course_code,
    academic_year,
    student_id,
    final_percent,
    ROUND(AVG(final_percent) OVER (PARTITION BY offering_id), 1)                 AS class_average,
    ROUND(final_percent - AVG(final_percent) OVER (PARTITION BY offering_id), 1) AS vs_average,
    MAX(final_percent) OVER (PARTITION BY offering_id) - final_percent           AS gap_to_best
FROM final_grades
ORDER BY academic_year, course_code, final_percent DESC;


-- =============================================================================
-- 4. Percentage of a Total
-- =============================================================================
SELECT
    first_name,
    last_name,
    department_id,
    monthly_salary,
    ROUND(100.0 * monthly_salary
          / SUM(monthly_salary) OVER (PARTITION BY department_id), 1) AS pct_of_department,
    ROUND(100.0 * monthly_salary
          / SUM(monthly_salary) OVER (), 1)                            AS pct_of_university
FROM lecturers
ORDER BY department_id, monthly_salary DESC;
-- Each department's percentages add up to 100; the last column adds up to 100
-- over the whole table.


-- =============================================================================
-- 5. Running Totals, and ROWS vs. RANGE
-- =============================================================================
-- Fees collected so far this term, payment by payment
SELECT
    payment_date,
    invoice_id,
    amount,
    SUM(amount) OVER (ORDER BY payment_date) AS collected_so_far
FROM payments
WHERE payment_date >= '2026-08-01'
ORDER BY payment_date;

-- ROWS vs. RANGE only matters when the ORDER BY value is TIED.
-- All 8 September salaries were paid on the SAME date:
SELECT
    payment_date,
    lecturer_id,
    gross_amount,
    SUM(gross_amount) OVER (ORDER BY payment_date)            AS range_total,  -- default
    SUM(gross_amount) OVER (ORDER BY payment_date, lecturer_id
                            ROWS BETWEEN UNBOUNDED PRECEDING
                                 AND CURRENT ROW)              AS rows_total
FROM salary_payments
WHERE pay_month = '2026-09'
ORDER BY payment_date, lecturer_id;
-- range_total shows 13,700,000 on EVERY row: RANGE includes all rows tied on
--   payment_date, i.e. the whole day.
-- rows_total grows row by row: 1,800,000 -> 3,100,000 -> ... -> 13,700,000.
-- For running totals, write ROWS explicitly and give ORDER BY a tie-breaker.


-- =============================================================================
-- 6. Running Balance per Invoice (a Statement of Account)
-- =============================================================================
SELECT
    p.invoice_id,
    p.payment_date,
    p.amount,
    sb.total_billed - sb.total_scholarships                    AS net_bill,
    sb.total_billed - sb.total_scholarships
      - SUM(p.amount) OVER (PARTITION BY p.invoice_id
                            ORDER BY p.payment_date
                            ROWS BETWEEN UNBOUNDED PRECEDING
                                 AND CURRENT ROW)              AS still_due
FROM payments p
JOIN student_balances sb ON sb.invoice_id = p.invoice_id
WHERE p.invoice_id IN (1, 7, 15)                  -- the invoices paid in instalments
ORDER BY p.invoice_id, p.payment_date;


-- =============================================================================
-- 7. Moving Averages with a Sliding Frame
-- =============================================================================
-- Average of this payment and the 2 before it (current-term payments)
SELECT
    payment_date,
    amount,
    ROUND(AVG(amount) OVER (ORDER BY payment_date
                            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS moving_avg_3
FROM payments
WHERE payment_date >= '2026-08-01'
ORDER BY payment_date;
-- The first two rows average fewer than 3 payments: there is nothing before them.


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: Show each invoice item with its share (%) of its invoice total,
--             using SUM(amount) OVER (PARTITION BY invoice_id).
-- Exercise 2: Show each course with the number of courses and the average
--             credits in its department, without GROUP BY.
-- Exercise 3: What is the difference between COUNT(*) OVER () and
--             COUNT(*) OVER (PARTITION BY department_id)?
-- Exercise 4: Compute the running total of net pay (gross - tax - deductions)
--             over all salary_payments, ordered by pay_month and lecturer_id.
