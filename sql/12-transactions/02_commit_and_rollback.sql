/*
================================================================================
Topic: Transaction Control: COMMIT and ROLLBACK
Objective: Group several changes into one atomic unit, check the result before
           deciding, keep it with COMMIT or cancel it with ROLLBACK, and handle
           errors inside a transaction.
Database: PostgreSQL (pgAdmin)
          MySQL: START TRANSACTION instead of BEGIN
          Oracle: a transaction starts automatically with the first change;
                  end it with COMMIT or ROLLBACK
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Autocommit (the default): every statement is committed immediately.
-- Explicit transaction:
--   BEGIN;          -- from here on nothing is permanent...
--     ...changes...
--     ...SELECTs to check them (you see your own uncommitted changes)...
--   COMMIT;         -- ...until COMMIT saves everything at once
--   ROLLBACK;       -- or ROLLBACK cancels everything at once
--
-- DDL inside a transaction:
--   PostgreSQL: CREATE / ALTER / DROP can be rolled back too.
--   MySQL and Oracle: DDL commits the open transaction automatically.


-- =============================================================================
-- 2. Scenario 1: A Two-Step Change That Must Succeed Together (COMMIT)
-- =============================================================================
-- Aline registered for CS301 next term (enrollment 23) but has not passed its
-- prerequisite CS201. The registrar moves her to ECO101 (offering 10).
-- Dropping the old course and adding the new one must happen TOGETHER:
-- she must never end up in both courses, or in neither.
BEGIN;
    UPDATE enrollments
    SET status = 'Dropped'
    WHERE enrollment_id = 23;                     -- step 1: leave CS301

    INSERT INTO enrollments (student_id, offering_id, enrollment_date, status)
    VALUES (1, 10, '2027-01-28', 'Registered');   -- step 2: join ECO101

    -- Check before deciding: exactly one 'Registered' row for next term
    SELECT e.enrollment_id, e.offering_id, e.status
    FROM enrollments e
    JOIN course_offerings o ON o.offering_id = e.offering_id
    WHERE e.student_id = 1
      AND o.term_id = 3;
COMMIT;                                           -- both steps are now permanent

-- After COMMIT, ROLLBACK can no longer undo it. To restore the sample data
-- for the next lessons, we run the opposite change as a new transaction:
BEGIN;
    DELETE FROM enrollments
    WHERE student_id = 1 AND offering_id = 10;
    UPDATE enrollments
    SET status = 'Registered'
    WHERE enrollment_id = 23;
COMMIT;


-- =============================================================================
-- 3. Scenario 2: Check, Spot a Mistake, Cancel (ROLLBACK)
-- =============================================================================
-- The finance office awards Patrick (student 4) a scholarship for the current
-- term, but types 900,000 instead of 90,000.
BEGIN;
    INSERT INTO student_scholarships (student_id, scholarship_id, term_id, amount_awarded)
    VALUES (4, 1, 1, 900000.00);

    SELECT total_billed, total_scholarships, total_paid, balance_due
    FROM student_balances
    WHERE student_id = 4 AND term_name = 'Semester 1';
    -- balance_due = -400,000: the university would OWE Patrick money. Wrong!
ROLLBACK;                                         -- cancel everything since BEGIN

SELECT COUNT(*) AS patrick_scholarships
FROM student_scholarships
WHERE student_id = 4;                             -- 0: nothing was saved


-- =============================================================================
-- 4. Errors Inside a Transaction
-- =============================================================================
-- In PostgreSQL, once any statement in a transaction fails, the whole
-- transaction is "aborted": every following statement is refused until
-- ROLLBACK. COMMIT on an aborted transaction also performs a ROLLBACK.
--
-- Try it (uncomment all five lines and run them together):
-- BEGIN;
--     UPDATE lecturers SET monthly_salary = monthly_salary + 100000 WHERE lecturer_id = 4;
--     UPDATE lecturers SET monthly_salary = -1 WHERE lecturer_id = 5;   -- CHECK fails
--     SELECT monthly_salary FROM lecturers WHERE lecturer_id = 4;
--     -- Expected: ERROR: current transaction is aborted, commands ignored until
--     --           end of transaction block
-- ROLLBACK;                                      -- the first UPDATE is undone too
--
-- MySQL and Oracle behave differently: only the failing STATEMENT is undone,
-- and the transaction stays open, so YOU must decide to ROLLBACK.
-- To recover from one failed step without losing the rest, use a SAVEPOINT
-- (file 03).


-- =============================================================================
-- 5. Good Habits
-- =============================================================================
-- - Keep transactions SHORT: open transactions hold locks that make other
--   users wait (see the two-window test in file 01).
-- - Check with SELECT before COMMIT, especially after UPDATE or DELETE.
-- - Never leave a transaction open in pgAdmin and walk away. If the status
--   bar shows a transaction in progress, finish it with COMMIT or ROLLBACK.


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: In one transaction, enrol Belinda (student 15) in offering 10 and
--             add a 30,000 'Library' line to her invoice (invoice 13). Check her
--             balance in student_balances, then ROLLBACK.
-- Exercise 2: What happens to an open transaction if the database server loses
--             power before COMMIT? And after COMMIT?
-- Exercise 3: Why did Scenario 1 need a second transaction to restore the data,
--             instead of a ROLLBACK?
