/*
================================================================================
Topic: Reading Query Plans with EXPLAIN
Objective: Read execution plans, recognise the main scan and join types, use
           EXPLAIN ANALYZE safely, and spot common performance red flags.
Database: PostgreSQL (pgAdmin: also try the "Explain" button for a diagram)
          MySQL and Oracle versions are shown in Section 7 (not run here)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: The Query Optimiser
-- =============================================================================
-- SQL says WHAT you want, not HOW to get it. Before running a query the
-- optimiser compares possible plans using table statistics and picks the one
-- with the lowest estimated cost.
--
--   EXPLAIN          shows the chosen plan WITHOUT running the query
--   EXPLAIN ANALYZE  RUNS the query and adds real times and row counts
--
-- Reading a plan line:
--   Seq Scan on payments  (cost=0.00..1.26 rows=21 width=40)
--                                ^start ^total ^estimated rows ^bytes per row
-- Plans are trees: the most indented lines run FIRST and feed the lines above.
--
-- Common nodes:
--   Seq Scan          read the whole table
--   Index Scan        find rows through an index, then read them
--   Index Only Scan   answer from the index alone (no table visit)
--   Bitmap Heap Scan  collect matches from an index, then read pages in order
--   Hash Join / Nested Loop / Merge Join   three ways to join two inputs
--   Sort, Aggregate / HashAggregate, Limit


-- =============================================================================
-- 2. Plans on Our Small Tables
-- =============================================================================
-- On small tables a Seq Scan is the cheapest plan, and that is CORRECT.
EXPLAIN
SELECT * FROM students WHERE program_id = 1;

-- A join plan: which table is read first, and which join method is used?
EXPLAIN
SELECT s.registration_no, p.program_name
FROM students s
JOIN programs p ON p.program_id = s.program_id
WHERE s.status = 'Active';

-- Plans of views: the view's query is expanded into the plan
EXPLAIN
SELECT * FROM student_gpa WHERE gpa >= 3.5;


-- =============================================================================
-- 3. EXPLAIN ANALYZE Really Runs the Statement
-- =============================================================================
-- EXPLAIN alone is always safe. EXPLAIN ANALYZE executes the statement, so
-- for UPDATE / DELETE wrap it in a transaction and roll back:
BEGIN;
    EXPLAIN ANALYZE
    DELETE FROM payments WHERE payment_method = 'Cash';   -- "actual rows=5"
ROLLBACK;                                                   -- the payments are back

SELECT COUNT(*) AS cash_payments FROM payments WHERE payment_method = 'Cash';   -- 5


-- =============================================================================
-- 4. A Bigger Table: Seq Scan vs. Index Scan vs. Index Only Scan
-- =============================================================================
DROP TABLE IF EXISTS login_events_demo;
CREATE TABLE login_events_demo (
    event_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id  INTEGER     NOT NULL,
    event_time  TIMESTAMP   NOT NULL,
    device      VARCHAR(10) NOT NULL
);
INSERT INTO login_events_demo (student_id, event_time, device)
SELECT (g % 5000) + 1,
       TIMESTAMP '2026-09-07 07:00' + (g % 100000) * INTERVAL '2 minutes',
       CASE g % 3 WHEN 0 THEN 'mobile' WHEN 1 THEN 'laptop' ELSE 'lab-pc' END
FROM generate_series(1, 300000) AS g;
ANALYZE login_events_demo;

-- (a) No index: Seq Scan, "Rows Removed by Filter: ~299,940"
EXPLAIN ANALYZE
SELECT event_time FROM login_events_demo WHERE student_id = 42;

-- (b) Index on student_id: Bitmap/Index Scan, far fewer rows touched
CREATE INDEX ix_login_student ON login_events_demo (student_id);
EXPLAIN ANALYZE
SELECT event_time FROM login_events_demo WHERE student_id = 42;

-- (c) Covering index: it holds EVERY column the query needs (student_id to
--     search, event_time to return), so the table itself need not be read.
DROP INDEX ix_login_student;
CREATE INDEX ix_login_student_time ON login_events_demo (student_id, event_time);
EXPLAIN ANALYZE
SELECT event_time FROM login_events_demo WHERE student_id = 42;
-- Still a "Bitmap Heap Scan"? PostgreSQL only trusts the index alone after
-- VACUUM has marked the table pages as "all visible". VACUUM cannot run inside
-- a script, so select the line below, run it ON ITS OWN, then run the EXPLAIN
-- above again: it becomes "Index Only Scan ... Heap Fetches: 0".
--   VACUUM login_events_demo;

-- (d) Most rows match -> the optimiser goes back to a Seq Scan on purpose:
--     reading the whole table is cheaper than 200,000 index lookups.
EXPLAIN
SELECT * FROM login_events_demo WHERE device <> 'mobile';


-- =============================================================================
-- 5. ORDER BY ... LIMIT Can Use an Index Too
-- =============================================================================
-- The 5 most recent logins of one student: the index is already sorted by
-- (student_id, event_time), so no Sort node is needed.
EXPLAIN
SELECT event_time, device
FROM login_events_demo
WHERE student_id = 42
ORDER BY event_time DESC
LIMIT 5;

DROP TABLE login_events_demo;       -- clean up the demo table


-- =============================================================================
-- 6. Red Flags in a Plan
-- =============================================================================
-- 1. Seq Scan on a LARGE table that returns only a few rows -> missing index.
-- 2. Estimated rows far from actual rows (EXPLAIN ANALYZE) -> stale statistics:
--    run ANALYZE table_name;
-- 3. A function on an indexed column in WHERE (file 02) -> index not usable.
-- 4. Nested Loop over two large inputs -> often a missing join index.
-- 5. "Sort Method: external merge  Disk" -> the sort spilled to disk.


-- =============================================================================
-- 7. The Same Tools in MySQL and Oracle (reference only)
-- =============================================================================
-- MySQL 8:
--   EXPLAIN SELECT * FROM students WHERE program_id = 1;
--   EXPLAIN FORMAT=TREE SELECT ...;     -- tree view, similar to PostgreSQL
--   EXPLAIN ANALYZE SELECT ...;         -- MySQL 8.0.18+
--   Red flags: type = ALL (full scan), "Using temporary", "Using filesort".
--
-- Oracle:
--   EXPLAIN PLAN FOR SELECT * FROM students WHERE program_id = 1;
--   SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: Run EXPLAIN on SELECT * FROM lecturers WHERE email = 'c.mukamana@uni.example'.
--             Which index exists for email, and why might the plan still be a Seq Scan?
-- Exercise 2: What is the difference between EXPLAIN and EXPLAIN ANALYZE? Why is
--             EXPLAIN ANALYZE on a DELETE dangerous without ROLLBACK?
-- Exercise 3: Rebuild the demo table and find a WHERE clause for which the
--             optimiser prefers a Seq Scan even though an index exists. Explain why.
