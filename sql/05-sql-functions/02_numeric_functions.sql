/*
================================================================================
Topic: Mathematical and Numeric Functions
Objective: Perform calculations, rounding, truncations, and mathematical operations 
           on numeric columns.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- SQL provides standard arithmetic and mathematical scalar functions to perform
-- precision rounding, absolute value calculation, modular division, and powers.

-- =============================================================================
-- 2. Precision Rounding and Truncation: ROUND, TRUNC / TRUNCATE
-- =============================================================================

SELECT 
    student_id,
    gpa,
    ROUND(gpa, 1) AS gpa_rounded_one_dec,
    ROUND(gpa, 0) AS gpa_rounded_integer
FROM students;

-- In MySQL: TRUNCATE(val, decimals)
-- In PostgreSQL / Oracle: TRUNC(val, decimals)
SELECT 
    salary,
    ROUND(salary / 12, 2) AS rounded_monthly,
    FLOOR(salary / 12)    AS floor_monthly,    -- Round down to nearest whole number
    CEIL(salary / 12)     AS ceiling_monthly   -- Round up to nearest whole number
FROM instructors;

-- =============================================================================
-- 3. Absolute Values and Signs: ABS, SIGN
-- =============================================================================

SELECT 
    ABS(-150.75) AS absolute_value,
    SIGN(25)     AS positive_sign,   -- Returns 1
    SIGN(0)      AS zero_sign,       -- Returns 0
    SIGN(-42)    AS negative_sign;   -- Returns -1

-- =============================================================================
-- 4. Modulo (Remainder) and Exponents: MOD, POWER / SQRT
-- =============================================================================

-- Modulo returns remainder after division (useful for even/odd checking)
SELECT 
    student_id,
    MOD(student_id, 2) AS remainder,
    CASE 
        WHEN MOD(student_id, 2) = 0 THEN 'Even Cohort'
        ELSE 'Odd Cohort'
    END AS cohort_group
FROM students;

-- Power and Square Root
SELECT 
    POWER(3, 2) AS three_squared,
    SQRT(144)   AS square_root_144;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Calculate the difference between each student's GPA and a perfect 4.00,
--             using ROUND to display 2 decimal places.
-- Exercise 2: Calculate the monthly income of instructors and show both FLOOR and CEIL 
--             values alongside the raw value.
