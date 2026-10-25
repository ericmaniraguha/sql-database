/*
================================================================================
Topic: Basic Aggregate Functions
Objective: Summarize datasets and calculate institutional metrics using COUNT, 
           SUM, AVG, MIN, and MAX on the ULK University database.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Aggregate functions summarize a set of rows into a single numeric metric.
-- Key Rules:
-- 1. Aggregate functions (except COUNT(*)) automatically ignore NULL values!
-- 2. COUNT(*): Counts the total number of records (including rows with NULLs).
-- 3. COUNT(column): Counts non-NULL entries in that column.
-- 4. COUNT(DISTINCT column): Counts unique non-NULL values.
-- 5. SUM, AVG, MIN, MAX: Compute mathematical totals, averages, and extremes.


-- =============================================================================
-- 2. Counting Records and Non-NULLs
-- =============================================================================

-- Analyze student body enrollment and program distribution:
SELECT
    COUNT(*)                     AS total_students,                -- 15: every row
    COUNT(phone)                 AS students_with_phone,           -- 13: 2 phones are NULL
    COUNT(DISTINCT program_id)   AS distinct_programs_represented  -- 4: MSc has no students
FROM students;


-- =============================================================================
-- 3. Payroll Summation, Averages, Minimums, and Maximums
-- =============================================================================

-- Lecturer compensation statistics (amounts in Rwandan Francs - RWF):
SELECT 
    COUNT(*)                          AS total_lecturers,
    SUM(monthly_salary)               AS total_monthly_payroll,
    ROUND(AVG(monthly_salary), 2)     AS average_monthly_salary,
    MIN(monthly_salary)               AS lowest_monthly_salary,
    MAX(monthly_salary)               AS highest_monthly_salary
FROM lecturers;


-- =============================================================================
-- 4. Aggregates on Filtered Data
-- =============================================================================

-- Fee collection summary for the active semester (from payments):
SELECT 
    COUNT(*)                 AS total_payments_received,
    SUM(amount)              AS total_revenue_collected,
    ROUND(AVG(amount), 2)    AS average_payment_amount,
    MAX(amount)              AS largest_single_payment
FROM payments;


-- =============================================================================
-- 5. Institutional Summary Metrics (From student_balances view)
-- =============================================================================

-- Total financial standing across the entire university:
SELECT 
    SUM(total_billed)       AS total_invoiced,
    SUM(total_scholarships) AS total_scholarships_awarded,
    SUM(total_paid)         AS total_fees_collected,
    SUM(balance_due)        AS total_outstanding_debt
FROM student_balances;


-- =============================================================================
-- 6. Conditional Aggregation with CASE
-- =============================================================================
-- Compute multiple category counts in a single pass without subqueries:

SELECT 
    COUNT(*) AS total_students,
    COUNT(CASE WHEN status = 'Active' THEN 1 END)    AS active_students,
    COUNT(CASE WHEN status = 'Suspended' THEN 1 END) AS suspended_students,
    COUNT(CASE WHEN status = 'Graduated' THEN 1 END) AS graduated_students
FROM students;


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Calculate the average capacity of all course offering classrooms.
-- Exercise 2: Find the total amount awarded across all scholarships in student_scholarships.
-- Exercise 3: Calculate the total number of credits across all courses in the catalog.
