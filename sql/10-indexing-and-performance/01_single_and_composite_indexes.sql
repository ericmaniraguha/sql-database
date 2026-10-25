/*
================================================================================
Topic: Single-Column and Composite B-Tree Indexes
Objective: See an index turn a full table scan into a fast lookup, build
           composite indexes, apply the leftmost-prefix rule, and weigh the
           cost of indexes.
Database: PostgreSQL (pgAdmin)
          MySQL: DROP INDEX name ON table;  (no IF NOT EXISTS before 8.0.29)
          Oracle: CREATE INDEX works the same; no IF NOT EXISTS before 23c
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: What an Index Is
-- =============================================================================
-- An index is a separate, sorted structure (usually a B-tree) that points to
-- table rows, like the index at the back of a textbook.
--   Without an index : read EVERY row and test it       ("Seq Scan")
--   With an index    : jump to the matching rows         ("Index Scan")
--
-- Trade-off: indexes speed up reads (WHERE, JOIN, ORDER BY) but slow down
-- writes, because every INSERT / UPDATE / DELETE must also update each index,
-- and they take disk space.
--
-- You already have some: PRIMARY KEY and UNIQUE constraints create an index
-- automatically.
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'students';           -- students_pkey, students_email_key, ...


-- =============================================================================
-- 2. A Table Big Enough to Need an Index
-- =============================================================================
-- With 15 students every query is instant, and PostgreSQL rightly ignores
-- indexes. To SEE an index work we build a demo table: the student portal's
-- login log, 300,000 rows for 5,000 students, generated with generate_series.
DROP TABLE IF EXISTS login_events_demo;

CREATE TABLE login_events_demo (
    event_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id  INTEGER     NOT NULL,
    event_time  TIMESTAMP   NOT NULL,
    device      VARCHAR(10) NOT NULL
);

INSERT INTO login_events_demo (student_id, event_time, device)
SELECT
    (g % 5000) + 1,                                        -- students 1..5000
    TIMESTAMP '2026-09-07 07:00' + (g % 100000) * INTERVAL '2 minutes',
    CASE g % 3 WHEN 0 THEN 'mobile' WHEN 1 THEN 'laptop' ELSE 'lab-pc' END
FROM generate_series(1, 300000) AS g;

ANALYZE login_events_demo;              -- refresh the optimiser's statistics


-- =============================================================================
-- 3. Before and After a Single-Column Index
-- =============================================================================
-- EXPLAIN ANALYZE runs the query and shows HOW it was executed (file 03).

-- BEFORE: look for "Seq Scan on login_events_demo" and "Rows Removed by Filter"
EXPLAIN ANALYZE
SELECT * FROM login_events_demo WHERE student_id = 42;

CREATE INDEX ix_login_events_student ON login_events_demo (student_id);

-- AFTER: look for "Index Scan" or "Bitmap Index Scan using ix_login_events_student"
-- and a much smaller "Execution Time"
EXPLAIN ANALYZE
SELECT * FROM login_events_demo WHERE student_id = 42;


-- =============================================================================
-- 4. Composite Indexes and the Leftmost-Prefix Rule
-- =============================================================================
-- A composite index is sorted by its FIRST column, then by the second inside
-- each first-column value (like a phone book: last name, then first name).
DROP INDEX ix_login_events_student;
CREATE INDEX ix_login_events_student_time
    ON login_events_demo (student_id, event_time);

-- Uses the index: both columns
EXPLAIN
SELECT * FROM login_events_demo
WHERE student_id = 42
  AND event_time >= '2026-10-01' AND event_time < '2026-11-01';

-- Uses the index: the leftmost column alone
EXPLAIN
SELECT * FROM login_events_demo
WHERE student_id = 42;

-- Cannot use it efficiently: only the SECOND column. Expect a Seq Scan.
-- (Finding a name in a phone book when you only know the first name.)
EXPLAIN
SELECT * FROM login_events_demo
WHERE event_time >= '2026-10-01 08:00' AND event_time < '2026-10-01 09:00';

-- Rule of thumb for column order: put the column you ALWAYS filter on with
-- "=" first, and the range / sort column second.


-- =============================================================================
-- 5. Indexing Foreign Keys on the Real Tables
-- =============================================================================
-- PostgreSQL does NOT index foreign key columns automatically. On large tables
-- they are the columns used in almost every JOIN, so index them:
CREATE INDEX IF NOT EXISTS ix_enrollments_offering   ON enrollments (offering_id);
CREATE INDEX IF NOT EXISTS ix_assessment_scores_assessment ON assessment_scores (assessment_id);
CREATE INDEX IF NOT EXISTS ix_payments_invoice       ON payments (invoice_id);
-- (enrollments.student_id is already the first column of the UNIQUE
--  (student_id, offering_id) index, so it needs no index of its own.)

SELECT tablename, indexname
FROM pg_indexes
WHERE indexname LIKE 'ix_%'
ORDER BY tablename;


-- =============================================================================
-- 6. When NOT to Add an Index
-- =============================================================================
-- - Small tables: a scan is already instant.
-- - Columns with very few distinct values (status, device, gender): an index
--   that matches a third of the table saves almost nothing.
-- - Write-heavy tables: every extra index slows every INSERT.
-- - Columns never used in WHERE, JOIN or ORDER BY.


-- =============================================================================
-- 7. Clean Up
-- =============================================================================
DROP INDEX IF EXISTS ix_enrollments_offering;
DROP INDEX IF EXISTS ix_assessment_scores_assessment;
DROP INDEX IF EXISTS ix_payments_invoice;
DROP TABLE IF EXISTS login_events_demo;           -- drops its indexes too
-- MySQL: DROP INDEX ix_payments_invoice ON payments;


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: An application often runs WHERE last_name = ? AND first_name = ?
--             on students. Which composite index would you create, and in
--             which column order?
-- Exercise 2: Rebuild login_events_demo and compare EXPLAIN ANALYZE for
--             WHERE device = 'mobile' with and without an index on device.
--             Why does the index barely help?
-- Exercise 3: Name two costs of adding an index.
