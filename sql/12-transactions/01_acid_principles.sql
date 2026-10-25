/*
================================================================================
Topic: Transactions and the ACID Properties
Objective: Understand what a transaction is, what Atomicity, Consistency,
           Isolation and Durability guarantee, and how isolation levels control
           what concurrent users can see.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle differences are noted in the comments
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: What Is a Transaction?
-- =============================================================================
-- A transaction is a group of SQL statements that the database treats as ONE
-- unit of work: either ALL of them take effect, or NONE of them do.
--
--   BEGIN;              -- start (MySQL: START TRANSACTION)
--     statement 1;
--     statement 2;
--   COMMIT;             -- make every change permanent
--   -- or ROLLBACK;     -- undo every change since BEGIN
--
-- Without BEGIN, each statement is its own transaction and is committed at
-- once ("autocommit", the default in pgAdmin, psql and MySQL).
--
-- You have already used BEGIN ... ROLLBACK in modules 02-11 to try changes
-- safely. This module explains what is happening.


-- =============================================================================
-- 2. The ACID Properties
-- =============================================================================
-- A - ATOMICITY: all or nothing.
--     Registering a student = add the enrollment AND add the invoice line.
--     If the second step fails, the first is undone too.
--
-- C - CONSISTENCY: valid state -> valid state.
--     Every constraint (PRIMARY KEY, FOREIGN KEY, CHECK, UNIQUE, NOT NULL)
--     must hold when the transaction ends; otherwise it is refused.
--
-- I - ISOLATION: concurrent transactions do not see each other's
--     unfinished work. How strictly is set by the isolation level (Section 3).
--
-- D - DURABILITY: once COMMIT returns, the change survives a crash or power
--     cut. PostgreSQL writes it to its write-ahead log (WAL) on disk first.


-- =============================================================================
-- 3. Isolation Levels
-- =============================================================================
-- What can one transaction see of another's changes?
--
-- | Level            | Dirty read | Non-repeatable read | Phantom read |
-- |------------------|------------|---------------------|--------------|
-- | READ UNCOMMITTED | possible*  | possible            | possible     |
-- | READ COMMITTED   | no         | possible            | possible     |
-- | REPEATABLE READ  | no         | no                  | possible*    |
-- | SERIALIZABLE     | no         | no                  | no           |
--
-- Dirty read          : seeing another transaction's UNCOMMITTED change
-- Non-repeatable read : the same row reads differently twice in one transaction
-- Phantom read        : the same WHERE returns new rows the second time
-- * PostgreSQL is stricter than the table: READ UNCOMMITTED behaves like READ
--   COMMITTED, and its REPEATABLE READ also prevents phantoms.
--
-- Defaults: PostgreSQL and Oracle = READ COMMITTED; MySQL InnoDB = REPEATABLE READ.

-- Choose a level for ONE transaction by naming it in BEGIN.
-- The level must be set before the transaction runs any query. That is why
-- this block is the first statement in the file: when pgAdmin runs a whole
-- script (F5), statements written before a BEGIN become part of it.
BEGIN ISOLATION LEVEL REPEATABLE READ;
    SHOW transaction_isolation;                   -- 'repeatable read'
ROLLBACK;

SHOW transaction_isolation;                       -- back to the default: 'read committed'

-- The same in two steps (SET TRANSACTION must come straight after BEGIN):
--   BEGIN;
--   SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- MySQL:  SELECT @@transaction_isolation;
--         SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Oracle: SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;


-- =============================================================================
-- 4. Atomicity in Action
-- =============================================================================
-- A cash payment for Diane's invoice (invoice 5) is recorded in two steps.
-- The second step is wrong (negative amount), so the whole unit must fail.
BEGIN;
    INSERT INTO payments (invoice_id, payment_date, amount, payment_method, reference_no)
    VALUES (5, '2026-10-05', 300000.00, 'Cash', 'CS-2026-0090');

    SELECT total_paid, balance_due
    FROM student_balances
    WHERE invoice_id = 5;                         -- inside: paid 300,000

    -- Uncomment to make the transaction fail (CHECK amount > 0):
    -- INSERT INTO payments (invoice_id, payment_date, amount, payment_method)
    -- VALUES (5, '2026-10-05', -50000.00, 'Cash');
    -- Expected: ERROR: new row for relation "payments" violates check constraint
    --           "payments_amount_check"
    -- After an error PostgreSQL refuses every further statement in the block:
    --           ERROR: current transaction is aborted, commands ignored until
    --           end of transaction block
ROLLBACK;                                         -- nothing was saved

SELECT total_paid, balance_due
FROM student_balances
WHERE invoice_id = 5;                             -- outside: still paid 0


-- =============================================================================
-- 5. Try It: Isolation with Two Windows
-- =============================================================================
-- Open TWO Query Tool tabs in pgAdmin (two separate sessions, A and B) and run
-- these steps in order, one at a time:
--
-- A: BEGIN;
-- A: UPDATE lecturers SET monthly_salary = 2000000 WHERE lecturer_id = 2;
-- B: SELECT monthly_salary FROM lecturers WHERE lecturer_id = 2;
--      -> 1300000.00 : B cannot see A's uncommitted change (no dirty read)
-- B: UPDATE lecturers SET monthly_salary = 1500000 WHERE lecturer_id = 2;
--      -> B WAITS: A holds a lock on that row
-- A: ROLLBACK;
--      -> B continues immediately and its UPDATE succeeds
-- B: ROLLBACK;     (keep the sample data unchanged)


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: What is a dirty read? Which isolation level would allow it in
--             theory, and why can it never happen in PostgreSQL?
-- Exercise 2: Why is atomicity essential when a student registers for a course
--             and is billed for it at the same time?
-- Exercise 3: In the two-window test, what happens if A runs COMMIT instead of
--             ROLLBACK? What salary does B's UPDATE then overwrite?
