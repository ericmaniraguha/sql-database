/*
================================================================================
Topic: Numeric Functions and Arithmetic
Objective: Calculate with numbers: arithmetic, the integer-division trap,
           rounding (ROUND, TRUNC, CEIL, FLOOR), ABS, MOD, POWER and SQRT.
Database: PostgreSQL (pgAdmin)
          MySQL: TRUNCATE(x, d) instead of TRUNC; 7 / 2 = 3.5000 (no trap)
          Oracle: identical function names; 7 / 2 = 3.5
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Arithmetic operators:  +  -  *  /  and  %  (remainder)
-- Numeric functions return a calculated value; the stored data is unchanged.
--
-- Quick reference:
--
-- | Function  | Purpose                                | Example                        | Result     |
-- |-----------|----------------------------------------|--------------------------------|------------|
-- | ROUND()   | Rounds a number                        | ROUND(monthly_salary / 22, 2)  | 81818.18   |
-- | CEIL()    | Rounds up to the next integer          | CEIL(450.25)                   | 451        |
-- | FLOOR()   | Rounds down to the previous integer    | FLOOR(450.85)                  | 450        |
-- | ABS()     | Returns the absolute value             | ABS(-500)                      | 500        |
-- | MOD()     | Returns the remainder of a division    | MOD(10, 3)                     | 1          |
-- | POWER()   | Raises a number to a power             | POWER(2, 3)                    | 8          |
-- | SQRT()    | Calculates the square root             | SQRT(64)                       | 8          |
--
-- (The ROUND result is for Claudine Mukamana: 1,800,000 / 22 working days.)
-- Other databases: MySQL and Oracle use the same names. MySQL also accepts
-- CEILING() and POW(); SQL Server only has CEILING().

-- The seven functions at a glance, on fixed numbers
SELECT
    CEIL(450.25)  AS ceil_result,     -- 451
    FLOOR(450.85) AS floor_result,    -- 450
    ABS(-500)     AS abs_result,      -- 500
    MOD(10, 3)    AS mod_result,      -- 1
    POWER(2, 3)   AS power_result,    -- 8
    SQRT(64)      AS sqrt_result;     -- 8

-- ... and ROUND on real salaries: daily rate over 22 working days
SELECT
    first_name,
    last_name,
    monthly_salary,
    monthly_salary / 22           AS daily_rate_exact,
    ROUND(monthly_salary / 22, 2) AS daily_rate
FROM lecturers
ORDER BY monthly_salary DESC;                             -- 8 rows


-- =============================================================================
-- 2. Arithmetic on Columns
-- =============================================================================
SELECT
    first_name,
    last_name,
    monthly_salary,
    monthly_salary * 12   AS annual_salary,
    monthly_salary / 22   AS daily_rate             -- about 22 working days a month
FROM lecturers
ORDER BY monthly_salary DESC;

-- Net pay and the tax rate, from the payroll table
SELECT
    lecturer_id,
    pay_month,
    gross_amount - tax_amount - other_deductions AS net_pay,
    tax_amount / gross_amount * 100              AS tax_rate_percent   -- 30.0000...
FROM salary_payments
WHERE pay_month = '2026-09';


-- =============================================================================
-- 3. The Integer Division Trap
-- =============================================================================
-- In PostgreSQL, INTEGER / INTEGER = INTEGER: the decimals are thrown away.
SELECT
    7 / 2              AS integer_division,     -- 3   (!)
    7 / 2.0            AS decimal_division,     -- 3.5
    7.0 / 2            AS also_decimal,         -- 3.5
    CAST(7 AS DECIMAL) / 2 AS with_cast;        -- 3.5

-- Real example: credits are INTEGER. "Average credits per course" goes wrong:
SELECT
    SUM(credits) / COUNT(*)       AS wrong_average,   -- 3   (31 / 9 truncated)
    SUM(credits) * 1.0 / COUNT(*) AS right_average    -- 3.44...
FROM courses;
-- (SUM and COUNT are aggregates: module 06.)
-- This is why the final_grades view writes "sc.score * 1.0 / a.max_score".


-- =============================================================================
-- 4. Rounding: ROUND, TRUNC, CEIL, FLOOR
-- =============================================================================
SELECT
    course_code,
    final_percent,
    ROUND(final_percent)    AS rounded,          -- nearest whole number
    ROUND(final_percent, 1) AS one_decimal,
    TRUNC(final_percent)    AS truncated,        -- just cut the decimals off
    CEIL(final_percent)     AS ceiling,          -- always UP
    FLOOR(final_percent)    AS floor_value       -- always DOWN
FROM final_grades
WHERE student_id IN (1, 6)                       -- Aline and Yves
ORDER BY student_id, course_code;

-- Rounding money: monthly salary divided into 4 weekly payments
SELECT
    first_name,
    monthly_salary / 4           AS exact_weekly,
    ROUND(monthly_salary / 4, 2) AS weekly_to_the_franc
FROM lecturers
WHERE lecturer_id = 7;                           -- 1,750,000 / 4 = 437,500.00


-- =============================================================================
-- 5. ABS, SIGN, MOD and POWER
-- =============================================================================

-- ABS: how far is each result from the pass mark of 50, ignoring direction?
-- SIGN: +1 above the pass mark, -1 below it, 0 exactly on it.
SELECT
    student_id,
    course_code,
    final_percent,
    ABS(final_percent - 50)  AS distance_from_pass_mark,
    SIGN(final_percent - 50) AS above_or_below
FROM final_grades
ORDER BY distance_from_pass_mark
LIMIT 5;

-- MOD (remainder): split students into 2 lab groups by student_id
SELECT
    student_id,
    first_name,
    MOD(student_id, 2) + 1 AS lab_group          -- 1 or 2
FROM students
ORDER BY lab_group, student_id;

-- POWER: tuition projection with a 5% increase every year for 3 years
SELECT
    program_id,
    fee_type,
    amount                             AS tuition_now,
    ROUND(amount * POWER(1.05, 3), 0)  AS tuition_in_3_years
FROM fee_structures
WHERE term_id = 1
  AND fee_type = 'Tuition'
ORDER BY program_id;

-- SQRT for completeness
SELECT SQRT(144) AS square_root, POWER(2, 10) AS two_to_the_10th;


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: For each student in student_gpa, show how far their GPA is from
--             a perfect 4.00, rounded to 2 decimals.
-- Exercise 2: Show each lecturer's monthly_salary divided by 3, with ROUND,
--             CEIL and FLOOR side by side. Which one never pays too little?
-- Exercise 3: What do SELECT 10 / 4 and SELECT 10 / 4.0 return? Explain why.
-- Exercise 4: Show each scholarship award as a percentage of 650,000 RWF,
--             rounded to 1 decimal.
