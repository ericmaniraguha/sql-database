/*
================================================================================
Topic: Partial Rollbacks with SAVEPOINT
Objective: Mark checkpoints inside a transaction, undo only the work done
           after a checkpoint, and recover from a failed step without losing
           the whole transaction.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same SAVEPOINT / ROLLBACK TO syntax
          (Oracle has no RELEASE SAVEPOINT)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
--   SAVEPOINT name;               -- set a checkpoint inside an open transaction
--   ROLLBACK TO SAVEPOINT name;   -- undo everything AFTER the checkpoint;
--                                 -- the transaction stays open
--   RELEASE SAVEPOINT name;       -- forget the checkpoint (keeps the work)
--
--   BEGIN
--     step 1                      kept
--   SAVEPOINT s1
--     step 2                      undone by ROLLBACK TO s1
--   ROLLBACK TO s1
--     step 3                      kept
--   COMMIT                        -> steps 1 and 3 are saved


-- =============================================================================
-- 2. Scenario: Registering a Student for Several Courses
-- =============================================================================
-- Belinda (student 15) registers for next term. Each course is one step; a
-- course she is not allowed to take is undone without losing the others.
BEGIN;
    -- Step 1: ECO101 (offering 10) has no prerequisites
    INSERT INTO enrollments (student_id, offering_id, enrollment_date, status)
    VALUES (15, 10, '2027-01-29', 'Registered');

    SAVEPOINT after_eco101;

    -- Step 2: CS301 (offering 9)
    INSERT INTO enrollments (student_id, offering_id, enrollment_date, status)
    VALUES (15, 9, '2027-01-29', 'Registered');

    -- Business check: has she passed CS301's prerequisite (CS201)?
    SELECT COUNT(*) AS cs201_passes
    FROM final_grades
    WHERE student_id = 15
      AND course_code = 'CS201'
      AND letter_grade <> 'F';                    -- 0: she has not

    -- So undo step 2 only
    ROLLBACK TO SAVEPOINT after_eco101;

    -- What is left inside the transaction: ECO101 only
    SELECT offering_id, status
    FROM enrollments
    WHERE student_id = 15;                        -- 1 row: offering 10

-- In real life this would be COMMIT, saving the ECO101 registration.
-- We use ROLLBACK so the sample data stays the same for the other lessons.
ROLLBACK;


-- =============================================================================
-- 3. Recovering from an ERROR with a Savepoint (PostgreSQL)
-- =============================================================================
-- File 02 showed that one error aborts the whole PostgreSQL transaction.
-- A savepoint taken BEFORE the risky step lets you recover:
--
-- BEGIN;
--     INSERT INTO enrollments (student_id, offering_id, enrollment_date)
--     VALUES (15, 10, '2027-01-29');                -- OK
--     SAVEPOINT before_duplicate;
--     INSERT INTO enrollments (student_id, offering_id, enrollment_date)
--     VALUES (15, 10, '2027-01-30');                -- ERROR: duplicate key ...
--     ROLLBACK TO SAVEPOINT before_duplicate;       -- transaction usable again
--     SELECT COUNT(*) FROM enrollments WHERE student_id = 15;   -- 1
-- ROLLBACK;
--
-- Uncomment the block above and run it together to see the recovery.
-- Applications and tools (psql's ON_ERROR_ROLLBACK setting) use exactly this
-- trick: an automatic savepoint before every statement.


-- =============================================================================
-- 4. RELEASE SAVEPOINT
-- =============================================================================
-- In a long batch job (e.g. importing 5,000 payments) you might set a savepoint
-- before each row. RELEASE removes savepoints you no longer need, so the
-- database does not keep track of thousands of them.
BEGIN;
    SAVEPOINT row_1;
    UPDATE invoices SET due_date = due_date + 7 WHERE invoice_id = 5;
    RELEASE SAVEPOINT row_1;                      -- the update is kept

    SELECT invoice_id, due_date FROM invoices WHERE invoice_id = 5;   -- 2026-10-07
ROLLBACK;
-- After RELEASE you can no longer ROLLBACK TO row_1, but ROLLBACK of the whole
-- transaction still undoes everything.


-- =============================================================================
-- 5. Practice Exercises
-- =============================================================================
-- Exercise 1: Does ROLLBACK TO SAVEPOINT end the transaction? How can you check?
-- Exercise 2: In one transaction, give lecturers 4 and 8 a 50,000 RWF raise,
--             each after its own savepoint. Undo only lecturer 8's raise, check
--             both salaries, then ROLLBACK.
-- Exercise 3: Why are savepoints useful in a batch job that loads many rows,
--             where a few rows may be invalid?
