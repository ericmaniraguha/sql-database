/*
================================================================================
Topic: Date and Time Functions
Objective: Get the current date, extract parts of a date, calculate ages and
           durations, add intervals, and format dates for reports.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle equivalents are given in the comments
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- DATE       a calendar day                    '2026-09-07'
-- TIMESTAMP  a day plus a time                 '2026-09-07 08:30:00'
-- INTERVAL   a length of time                  INTERVAL '3 months'
--
-- Results that use CURRENT_DATE change every day. To get the same answers as
-- the comments in this file, most queries use a fixed reference date:
-- DATE '2026-09-07', the first day of the current term.
--
-- Quick reference (examples use the lecturers table):
--
-- | Function          | Purpose                            | Example                            |
-- |-------------------|------------------------------------|------------------------------------|
-- | CURRENT_DATE      | Returns the current date           | CURRENT_DATE                       |
-- | CURRENT_TIMESTAMP | Returns the current date and time  | CURRENT_TIMESTAMP                  |
-- | AGE()             | Calculates the interval between    | AGE(CURRENT_DATE, hire_date)       |
-- |                   | two dates                          |                                    |
-- | EXTRACT()         | Extracts a date component          | EXTRACT(YEAR FROM hire_date)       |
-- | DATE_PART()       | Extracts a date component          | DATE_PART('month', hire_date)      |
-- | TO_CHAR()         | Formats dates or numbers as text   | TO_CHAR(hire_date, 'DD-Mon-YYYY')  |
--
-- EXTRACT and DATE_PART do the same job: EXTRACT is the SQL standard,
-- DATE_PART is PostgreSQL's own spelling.
-- Other databases:
--   MySQL : NOW() / CURDATE(); no AGE (use TIMESTAMPDIFF); no DATE_PART (use
--           YEAR(), MONTH(), DAY()); DATE_FORMAT() instead of TO_CHAR().
--   Oracle: SYSDATE / CURRENT_DATE; no AGE (use MONTHS_BETWEEN); no DATE_PART
--           (use EXTRACT); TO_CHAR() works as in PostgreSQL.

-- The six at a glance, on every lecturer.
-- CURRENT_DATE and AGE() give a different answer each day you run this.
-- The example values in the comments are Claudine Mukamana's (hired 2015-02-01).
SELECT
    CURRENT_DATE                       AS today,
    CURRENT_TIMESTAMP                  AS right_now,
    first_name,
    hire_date,
    AGE(CURRENT_DATE, hire_date)       AS time_since_hired,   -- e.g. 11 years 9 mons 1 day
    EXTRACT(YEAR FROM hire_date)       AS hire_year,          -- 2015
    DATE_PART('month', hire_date)      AS hire_month,         -- 2
    TO_CHAR(hire_date, 'DD-Mon-YYYY')  AS printed             -- 01-Feb-2015
FROM lecturers
ORDER BY hire_date;                                           -- 8 rows


-- =============================================================================
-- 2. Today's Date and Time
-- =============================================================================
SELECT
    CURRENT_DATE      AS today,
    CURRENT_TIMESTAMP AS right_now,
    NOW()             AS also_right_now;          -- PostgreSQL / MySQL
-- MySQL: CURDATE(), NOW()     Oracle: SYSDATE, SYSTIMESTAMP


-- =============================================================================
-- 3. Extracting Parts of a Date: EXTRACT
-- =============================================================================
SELECT
    first_name,
    last_name,
    hire_date,
    EXTRACT(YEAR  FROM hire_date) AS hire_year,
    EXTRACT(MONTH FROM hire_date) AS hire_month,
    EXTRACT(DAY   FROM hire_date) AS hire_day
FROM lecturers
ORDER BY hire_date;
-- MySQL also has YEAR(hire_date), MONTH(hire_date), DAY(hire_date).

-- Use EXTRACT in WHERE: lecturers hired in a February
SELECT first_name, last_name, hire_date
FROM lecturers
WHERE EXTRACT(MONTH FROM hire_date) = 2;          -- Claudine, Ange, Josiane


-- =============================================================================
-- 4. Ages and Lengths of Service
-- =============================================================================
-- Subtracting years is only APPROXIMATE: it ignores whether the birthday has
-- happened yet this year. AGE() is exact (PostgreSQL).
SELECT
    first_name,
    date_of_birth,
    2026 - EXTRACT(YEAR FROM date_of_birth)                 AS approx_age,
    EXTRACT(YEAR FROM AGE(DATE '2026-09-07', date_of_birth)) AS exact_age
FROM students
ORDER BY date_of_birth;
-- Patrick (born 2003-01-30) is 23 either way; Jean (born 2004-11-02) is
-- approx 22 but exactly 21 on 7 Sept 2026. Kevin has no birth date: NULL age.
-- MySQL: TIMESTAMPDIFF(YEAR, date_of_birth, '2026-09-07')
-- Oracle: TRUNC(MONTHS_BETWEEN(DATE '2026-09-07', date_of_birth) / 12)

-- Years of service on the first day of term
SELECT
    first_name,
    last_name,
    hire_date,
    AGE(DATE '2026-09-07', hire_date)                        AS service_length,
    EXTRACT(YEAR FROM AGE(DATE '2026-09-07', hire_date))     AS full_years
FROM lecturers
ORDER BY hire_date;


-- =============================================================================
-- 5. Differences Between Dates
-- =============================================================================
-- In PostgreSQL, DATE - DATE = a whole number of days.
SELECT
    academic_year,
    term_name,
    end_date - start_date         AS term_length_days,
    (end_date - start_date) / 7   AS term_length_weeks      -- integer division
FROM academic_terms
ORDER BY start_date;

-- How many days each student had to pay their invoice
SELECT
    invoice_id,
    issue_date,
    due_date,
    due_date - issue_date AS days_allowed
FROM invoices
WHERE invoice_id IN (1, 14);                       -- 46 days, 44 days
-- MySQL: DATEDIFF(due_date, issue_date)   Oracle: due_date - issue_date


-- =============================================================================
-- 6. Adding and Subtracting Time
-- =============================================================================
SELECT
    due_date,
    due_date + 14                    AS with_two_week_grace,   -- DATE + integer days
    due_date + INTERVAL '1 month'    AS one_month_later,
    due_date - INTERVAL '1 year'     AS one_year_earlier
FROM invoices
WHERE invoice_id = 1;
-- MySQL:  DATE_ADD(due_date, INTERVAL 14 DAY)
-- Oracle: due_date + 14,  ADD_MONTHS(due_date, 1)

-- Lecturers' 10-year service anniversary
SELECT
    first_name,
    hire_date,
    hire_date + INTERVAL '10 years' AS ten_year_anniversary
FROM lecturers
ORDER BY hire_date;


-- =============================================================================
-- 7. Formatting Dates for Reports: TO_CHAR
-- =============================================================================
SELECT
    payment_id,
    payment_date,
    TO_CHAR(payment_date, 'DD Mon YYYY') AS printed_date,     -- 28 Jan 2026
    TO_CHAR(payment_date, 'Day')         AS weekday,
    TO_CHAR(payment_date, 'YYYY-MM')     AS pay_month
FROM payments
ORDER BY payment_date
LIMIT 5;
-- MySQL: DATE_FORMAT(payment_date, '%d %b %Y')
-- Oracle: TO_CHAR(payment_date, 'DD Mon YYYY')  (same as PostgreSQL)

-- DATE_TRUNC rounds a date DOWN to the start of its month / year (PostgreSQL)
SELECT
    payment_date,
    DATE_TRUNC('month', payment_date)::DATE AS month_start
FROM payments
ORDER BY payment_date
LIMIT 5;


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: List lecturers who had at least 10 full years of service on
--             2026-09-07.
-- Exercise 2: List students born in February or April.
-- Exercise 3: For each payment, show how many days before (negative) or after
--             (positive) its invoice due date it was made. Hint: you need
--             payments and invoices; try it again after module 07 (joins).
-- Exercise 4: Show the date of the last day of each academic term as
--             'Friday, 22 January 2027' using TO_CHAR.
