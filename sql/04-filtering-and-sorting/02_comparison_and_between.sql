/*
================================================================================
Topic: Comparison Operators and BETWEEN Range Filtering
Objective: Filter numbers, text and dates with comparison operators and the
           inclusive BETWEEN operator, and write safe date ranges.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical syntax (Oracle needs DATE '2026-09-01'
          for date literals)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
--   =          equal to
--   <> or !=   not equal to (<> is the SQL standard)
--   >   <      greater than / less than
--   >=  <=     greater than or equal / less than or equal
--
-- BETWEEN tests an INCLUSIVE range; both ends are included:
--   x BETWEEN low AND high      is the same as      x >= low AND x <= high


-- =============================================================================
-- 2. Comparison Operators on Numbers
-- =============================================================================

-- Courses worth more than 3 credits
SELECT course_code, course_title, credits
FROM courses
WHERE credits > 3;                                      -- 4 rows: the CS courses

-- Lecturers who do NOT earn exactly 1,300,000 RWF
SELECT first_name, last_name, monthly_salary
FROM lecturers
WHERE monthly_salary <> 1300000.00;                     -- 7 of 8 lecturers

-- Payments of 500,000 RWF or more
SELECT payment_id, invoice_id, payment_date, amount
FROM payments
WHERE amount >= 500000
ORDER BY amount DESC;


-- =============================================================================
-- 3. Comparison Operators on Text
-- =============================================================================
-- Text compares alphabetically, character by character.

-- Students whose last name comes before 'I' in the alphabet
SELECT first_name, last_name
FROM students
WHERE last_name < 'I'
ORDER BY last_name;                                     -- Bizimana, Habimana, Hakizimana

-- Text comparison is case-sensitive in PostgreSQL:
SELECT course_code FROM courses WHERE course_code = 'cs101';   -- 0 rows
SELECT course_code FROM courses WHERE course_code = 'CS101';   -- 1 row


-- =============================================================================
-- 4. Range Filtering with BETWEEN
-- =============================================================================

-- Course results in the B range (70 to 79.99 %)
SELECT student_id, course_code, final_percent, letter_grade
FROM final_grades
WHERE final_percent BETWEEN 70 AND 79.99
ORDER BY final_percent DESC;

-- The same filter written with >= and <=
SELECT student_id, course_code, final_percent, letter_grade
FROM final_grades
WHERE final_percent >= 70 AND final_percent <= 79.99
ORDER BY final_percent DESC;

-- NOT BETWEEN: salaries outside 1,000,000 - 2,000,000 RWF
SELECT first_name, last_name, monthly_salary
FROM lecturers
WHERE monthly_salary NOT BETWEEN 1000000 AND 2000000
ORDER BY monthly_salary;                                -- Ange, Joseph, Esther

-- Careful: BETWEEN needs the SMALLER value first.
SELECT course_code FROM courses WHERE credits BETWEEN 4 AND 3;  -- 0 rows!


-- =============================================================================
-- 5. Date Ranges
-- =============================================================================
-- Write dates as 'YYYY-MM-DD'; they compare in calendar order.

-- Lecturers hired from 2015 to 2018 (inclusive)
SELECT first_name, last_name, hire_date
FROM lecturers
WHERE hire_date BETWEEN '2015-01-01' AND '2018-12-31'
ORDER BY hire_date;                                     -- Claudine, Didier, Samuel

-- Students born on or after 1 January 2005
SELECT first_name, last_name, date_of_birth
FROM students
WHERE date_of_birth >= '2005-01-01'
ORDER BY date_of_birth;
-- Kevin (date_of_birth NULL) is not listed: NULL is never >= anything (see file 04).

-- Payments received in September 2026.
-- Best practice for date ranges: ">= first day AND < first day of the NEXT period".
-- It also works for TIMESTAMP columns, where BETWEEN '...-01' AND '...-30'
-- would miss everything after midnight on the 30th.
SELECT payment_id, payment_date, amount, payment_method
FROM payments
WHERE payment_date >= '2026-09-01'
  AND payment_date <  '2026-10-01'
ORDER BY payment_date;


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Find payments with an amount between 100,000 and 400,000 RWF.
-- Exercise 2: Find assessments due in November 2026 (use the >= / < pattern).
-- Exercise 3: Find students admitted from 2023 to 2025. How many are there?
-- Exercise 4: Find course results (final_grades) that are NOT between 50 and 100.
--             Which letter grade do they all have?
