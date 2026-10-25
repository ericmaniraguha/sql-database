/*
================================================================================
Topic: UNIQUE, Partial and Expression Indexes
Objective: Enforce rules with unique indexes (including case-insensitive
           uniqueness), index only the rows that matter, index expressions,
           and write WHERE clauses that can use an index.
Database: PostgreSQL (pgAdmin)
          MySQL 8.0.13+: expression indexes yes, partial indexes NO
          Oracle: function-based indexes yes, partial indexes NO
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- - UNIQUE index     : an index that also refuses duplicate values.
-- - Partial index    : indexes only the rows that match a WHERE condition.
-- - Expression index : indexes the RESULT of an expression, e.g. LOWER(email).
--
-- A testing trick used in this file: on tiny tables PostgreSQL prefers a full
-- scan even when an index exists.
--     SET enable_seqscan = off;
-- tells it to avoid full scans whenever it CAN. If the plan still says
-- "Seq Scan", the index simply cannot be used for that WHERE clause.
--     RESET enable_seqscan;
-- switches the normal behaviour back on. (Experiments only, never production.)


-- =============================================================================
-- 2. UNIQUE Indexes
-- =============================================================================
-- Our UNIQUE constraints already created unique indexes, for example:
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'courses';            -- courses_pkey, courses_course_code_key

-- A gap in our design: UNIQUE (email) is case-sensitive, so
-- 'Aline.Uwase@uni.example' would be accepted as a "different" email.
-- A unique EXPRESSION index closes the gap:
CREATE UNIQUE INDEX IF NOT EXISTS ux_students_email_lower
    ON students (LOWER(email));

-- Test (uncomment): same address, different capitals
-- INSERT INTO students (registration_no, first_name, last_name, email, admission_year, program_id)
-- VALUES ('2026CS099', 'Test', 'Student', 'Aline.Uwase@uni.example', 2026, 1);
-- Expected: ERROR: duplicate key value violates unique constraint "ux_students_email_lower"


-- =============================================================================
-- 3. Partial Indexes (PostgreSQL)
-- =============================================================================
-- Most enrollments end up 'Completed'; the registrar's daily screens only look
-- at the few 'Registered' ones. Index just those rows:
CREATE INDEX IF NOT EXISTS ix_enrollments_registered
    ON enrollments (offering_id)
    WHERE status = 'Registered';

-- Cash payments without a receipt number, which the bursar must follow up:
CREATE INDEX IF NOT EXISTS ix_payments_missing_reference
    ON payments (payment_date)
    WHERE reference_no IS NULL;

SET enable_seqscan = off;

-- The query repeats the index condition, so the partial index applies:
EXPLAIN
SELECT student_id FROM enrollments
WHERE status = 'Registered' AND offering_id = 9;   -- uses ix_enrollments_registered

RESET enable_seqscan;

-- A partial index can also be UNIQUE, e.g. "at most one row per X among the
-- rows that match the WHERE":
--   CREATE UNIQUE INDEX ... ON table (x) WHERE status = 'Active';


-- =============================================================================
-- 4. Expression Indexes and "Index-Friendly" WHERE Clauses
-- =============================================================================
-- An index on a column is only usable when the WHERE clause compares the
-- column ITSELF. Wrapping the column in a function hides it from the index.
CREATE INDEX IF NOT EXISTS ix_lecturers_hire_date ON lecturers (hire_date);

SET enable_seqscan = off;

-- NOT index-friendly: the function is applied to every row first
EXPLAIN
SELECT first_name FROM lecturers
WHERE EXTRACT(YEAR FROM hire_date) = 2015;          -- still "Seq Scan"

-- Index-friendly: the same question as a range on the bare column
EXPLAIN
SELECT first_name FROM lecturers
WHERE hire_date >= '2015-01-01' AND hire_date < '2016-01-01';   -- "Index Scan"

-- When you really must search on an expression, index the expression.
-- The query must use EXACTLY the same expression as the index:
EXPLAIN
SELECT student_id FROM students
WHERE LOWER(email) = 'aline.uwase@uni.example';     -- uses ux_students_email_lower

RESET enable_seqscan;


-- =============================================================================
-- 5. Clean Up
-- =============================================================================
DROP INDEX IF EXISTS ux_students_email_lower;
DROP INDEX IF EXISTS ix_enrollments_registered;
DROP INDEX IF EXISTS ix_payments_missing_reference;
DROP INDEX IF EXISTS ix_lecturers_hire_date;


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Create an expression index on UPPER(last_name) for lecturers and
--             write a query that can use it.
-- Exercise 2: Rewrite WHERE EXTRACT(MONTH FROM payment_date) = 9
--                   AND EXTRACT(YEAR FROM payment_date) = 2026
--             so that an index on payment_date could be used.
-- Exercise 3: Why is a partial index a good fit for a soft-delete design where
--             95% of rows are 'Active' and queries only look at the rest?
