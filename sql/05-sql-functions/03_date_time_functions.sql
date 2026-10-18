/*
================================================================================
Topic: Date and Time Functions
Objective: Manipulate dates, extract temporal components (year, month, day), 
           calculate differences, and perform date arithmetic.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Handling dates correctly is vital for business applications.
-- Standard SQL defines CURRENT_DATE and CURRENT_TIMESTAMP to obtain the current
-- system date and timestamp without parentheses.

-- =============================================================================
-- 2. Getting Current System Date & Time
-- =============================================================================

SELECT 
    CURRENT_DATE      AS today_date,
    CURRENT_TIMESTAMP AS current_moment;

-- In MySQL: NOW(), CURDATE()
-- In Oracle: SYSDATE, SYSTIMESTAMP

-- =============================================================================
-- 3. Extracting Date Parts: EXTRACT
-- =============================================================================
-- The ANSI SQL standard function EXTRACT retrieves specific fields:

SELECT 
    instructor_id,
    hire_date,
    EXTRACT(YEAR  FROM hire_date) AS hire_year,
    EXTRACT(MONTH FROM hire_date) AS hire_month,
    EXTRACT(DAY   FROM hire_date) AS hire_day
FROM instructors;

-- MySQL alternative functions:
-- SELECT YEAR(hire_date), MONTH(hire_date), DAY(hire_date) FROM instructors;

-- =============================================================================
-- 4. Calculating Age and Tenures
-- =============================================================================

-- Calculate approximate student age in years (Standard cross-database arithmetic):
SELECT 
    student_id,
    first_name,
    last_name,
    birth_date,
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date) AS approximate_age
FROM students;

-- In PostgreSQL (precise AGE function):
-- SELECT first_name, AGE(CURRENT_DATE, birth_date) AS exact_age FROM students;

-- In MySQL (TIMESTAMPDIFF):
-- SELECT first_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS exact_age FROM students;

-- =============================================================================
-- 5. Date Arithmetic (Adding / Subtracting Intervals)
-- =============================================================================

-- In PostgreSQL / ANSI:
-- SELECT CURRENT_DATE + INTERVAL '30 days' AS future_date;
-- SELECT CURRENT_DATE - INTERVAL '1 year'   AS one_year_ago;

-- In MySQL:
-- SELECT DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY) AS future_date;
-- SELECT DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AS one_year_ago;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Find all instructors who have worked at the university for more than 5 years.
-- Exercise 2: Find all students who were born in the month of February or April.
