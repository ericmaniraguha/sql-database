/*
================================================================================
Topic: NULL Functions: COALESCE and NULLIF
Objective: Replace NULLs with sensible defaults, pick the first available
           value from several columns, and use NULLIF to avoid division by zero.
Database: PostgreSQL (pgAdmin)
          MySQL: IFNULL(a, b) is a 2-argument COALESCE
          Oracle: NVL(a, b) is a 2-argument COALESCE
          COALESCE and NULLIF work in all three
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- COALESCE(a, b, c, ...)  returns the FIRST argument that is not NULL.
-- NULLIF(a, b)            returns NULL when a = b, otherwise returns a.
--
-- Both are ANSI standard, so prefer them to IFNULL / NVL / ISNULL: the same
-- query then runs on every database.
--
-- Quick reference (examples use the lecturers table):
--
-- | Function   | Purpose                               | Example                         |
-- |------------|---------------------------------------|---------------------------------|
-- | COALESCE() | Returns the first non-NULL value      | COALESCE(phone, 'No phone')     |
-- | NULLIF()   | Returns NULL if two values are equal  | NULLIF(phone, '')               |
--
-- Typical uses:
--   COALESCE(phone, 'No phone')    show a default instead of an empty cell
--   COALESCE(SUM(amount), 0)       treat "no rows" as zero in totals
--   total / NULLIF(count, 0)       avoid "division by zero": dividing by NULL
--                                  gives NULL instead of an error
--   NULLIF(phone, '')              turn empty text into a real NULL
--
-- Why not COALESCE(monthly_salary, 0)? It is valid SQL, but monthly_salary is
-- NOT NULL in our schema, so it would never change anything. Use these
-- functions on columns that can really be NULL (or 0).

-- Both at a glance. Samuel and Josiane have no phone number.
SELECT
    first_name,
    last_name,
    phone,
    COALESCE(phone, 'No phone') AS phone_or_default,
    NULLIF(phone, '')           AS empty_text_as_null
FROM lecturers
ORDER BY last_name;                                       -- 8 rows


-- =============================================================================
-- 2. COALESCE: a Default for Missing Values
-- =============================================================================

-- Show a readable text instead of an empty (NULL) cell
SELECT
    department_name,
    COALESCE(building, 'Not assigned') AS building
FROM departments
ORDER BY department_id;                           -- Economics: 'Not assigned'

SELECT
    offering_id,
    course_id,
    COALESCE(room, 'TBA') AS room                 -- "to be announced"
FROM course_offerings
WHERE term_id = 3;


-- =============================================================================
-- 3. COALESCE with Several Fallbacks
-- =============================================================================
-- Best way to contact each student: phone if we have one, otherwise email.
SELECT
    first_name,
    last_name,
    phone,
    COALESCE(phone, email) AS best_contact
FROM students
WHERE student_id IN (5, 6, 11);                   -- Yves and Nadia fall back to email

-- Cash payments without a receipt number get a generated one
SELECT
    payment_id,
    payment_method,
    COALESCE(reference_no, 'CASH-' || payment_id) AS reference
FROM payments
WHERE payment_method = 'Cash'
ORDER BY payment_id;


-- =============================================================================
-- 4. COALESCE Needs Matching Data Types
-- =============================================================================
-- due_date is a DATE, so the fallback must be a DATE too.
-- This FAILS (uncomment to see):
-- SELECT COALESCE(due_date, 'not set') FROM assessments;
-- Expected: ERROR: invalid input syntax for type date: "not set"

-- Fix: turn the date into text first
SELECT
    assessment_name,
    COALESCE(TO_CHAR(due_date, 'YYYY-MM-DD'), 'not set') AS due
FROM assessments
WHERE offering_id = 9;                            -- Group Project: 'not set'


-- =============================================================================
-- 5. COALESCE Keeps Calculations Working
-- =============================================================================
-- Arithmetic with NULL gives NULL (module 04). Treat "no value" as 0 when it
-- really means zero. Example: an invoice with no payments has paid 0, not NULL.
-- The student_balances view does exactly this:
--     COALESCE((SELECT SUM(p.amount) FROM payments p WHERE ...), 0) AS total_paid
SELECT
    invoice_id,
    student_name,
    total_paid,
    balance_due
FROM student_balances
WHERE invoice_id IN (5, 9);                       -- no payments: total_paid = 0


-- =============================================================================
-- 6. NULLIF: Avoiding Division by Zero
-- =============================================================================
-- Dividing by zero is an error:   SELECT 100 / 0;
--   Expected: ERROR: division by zero
-- Dividing by NULL simply gives NULL. NULLIF(x, 0) turns a 0 into NULL:
SELECT
    budget,
    students,
    budget / NULLIF(students, 0) AS budget_per_student
FROM (VALUES (900000, 3),
             (500000, 0)) AS clubs(budget, students);   -- 2nd row: NULL, no error

-- Real use: share of the net bill (after scholarships) that is still unpaid
SELECT
    student_name,
    academic_year,
    term_name,
    balance_due,
    ROUND(100.0 * balance_due
          / NULLIF(total_billed - total_scholarships, 0), 1) AS percent_unpaid
FROM student_balances
WHERE balance_due > 0
ORDER BY percent_unpaid DESC;


-- =============================================================================
-- 7. NULLIF: Turning Placeholder Values into NULL
-- =============================================================================
-- Imported files often contain '' or 'N/A' instead of a real NULL.
SELECT
    raw_phone,
    NULLIF(TRIM(raw_phone), '')  AS cleaned_phone       -- '' and '   ' become NULL
FROM (VALUES ('+250788000001'), (''), ('   ')) AS import(raw_phone);


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: List all lecturers with their phone number, showing 'No phone'
--             when it is missing.
-- Exercise 2: List course offerings with their lecturer_id, showing 0 when no
--             lecturer is assigned. Is 0 a good choice here? Why or why not?
-- Exercise 3: Rewrite COALESCE(phone, email) using a CASE expression (file 05).
-- Exercise 4: Why is COALESCE preferred over IFNULL (MySQL) or NVL (Oracle)?
