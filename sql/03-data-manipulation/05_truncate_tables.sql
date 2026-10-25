/*
================================================================================
Topic: Emptying Tables with TRUNCATE
Objective: Compare TRUNCATE with DELETE, control identity values with
           RESTART IDENTITY, and understand why foreign keys block TRUNCATE.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle differences are listed in the table below
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: TRUNCATE vs. DELETE
-- =============================================================================
-- | Feature            | DELETE                     | TRUNCATE                         |
-- |--------------------|----------------------------|----------------------------------|
-- | Category           | DML                        | DDL                              |
-- | WHERE clause       | Yes (choose rows)          | No (always ALL rows)             |
-- | Speed on big tables| Slow (row by row)          | Very fast (frees the pages)      |
-- | Identity counter   | Keeps counting             | PostgreSQL: only with            |
-- |                    |                            |   RESTART IDENTITY               |
-- |                    |                            | MySQL: resets to 1               |
-- |                    |                            | Oracle: keeps counting           |
-- | Row triggers       | Fire                       | Do not fire                      |
-- | Can be rolled back | Yes                        | PostgreSQL: yes                  |
-- |                    |                            | MySQL / Oracle: NO (auto-commit) |


-- =============================================================================
-- 2. TRUNCATE on a Staging Table
-- =============================================================================
-- Staging tables hold temporary imports (e.g. a bank statement) and are
-- emptied often: the perfect job for TRUNCATE.

DROP TABLE IF EXISTS payment_import_staging;            -- safe to re-run

CREATE TABLE payment_import_staging (
    staging_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference_no  VARCHAR(50),
    amount        DECIMAL(12,2)
);

-- Load 3 rows (INSERT ... SELECT from module 03, file 01)
INSERT INTO payment_import_staging (reference_no, amount)
SELECT reference_no, amount
FROM payments
WHERE payment_method = 'Bank Transfer'
ORDER BY payment_id
LIMIT 3;

SELECT * FROM payment_import_staging;                   -- staging_id 1, 2, 3

-- A) Plain TRUNCATE: rows are gone, but the identity counter keeps going
TRUNCATE TABLE payment_import_staging;

INSERT INTO payment_import_staging (reference_no, amount)
VALUES ('TEST-001', 1000.00);

SELECT staging_id, reference_no FROM payment_import_staging;   -- staging_id 4 !

-- B) TRUNCATE ... RESTART IDENTITY: the counter starts again at 1
TRUNCATE TABLE payment_import_staging RESTART IDENTITY;

INSERT INTO payment_import_staging (reference_no, amount)
VALUES ('TEST-002', 2000.00);

SELECT staging_id, reference_no FROM payment_import_staging;   -- staging_id 1

DROP TABLE payment_import_staging;                      -- clean up the demo


-- =============================================================================
-- 3. Foreign Keys Block TRUNCATE
-- =============================================================================
-- invoices is referenced by invoice_items and payments, so this is refused
-- (even though DELETE could remove a single invoice that has no children):
-- TRUNCATE TABLE invoices;
-- Expected: ERROR: cannot truncate a table referenced in a foreign key constraint

-- CASCADE empties every referencing table as well. Look at the NOTICE lines:
-- PostgreSQL tells you which other tables it emptied.
BEGIN;
    TRUNCATE TABLE invoices CASCADE;
    -- NOTICE: truncate cascades to table "invoice_items"
    -- NOTICE: truncate cascades to table "payments"

    SELECT
        (SELECT COUNT(*) FROM invoices)      AS invoices,         -- 0
        (SELECT COUNT(*) FROM invoice_items) AS invoice_items,    -- 0
        (SELECT COUNT(*) FROM payments)      AS payments;         -- 0
ROLLBACK;                                               -- everything restored

-- MySQL has no TRUNCATE ... CASCADE. You would have to switch off the
-- foreign key checks (dangerous: it allows orphan rows):
--   SET FOREIGN_KEY_CHECKS = 0;
--   TRUNCATE TABLE invoices;
--   SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- 4. Practice Exercises
-- =============================================================================
-- Exercise 1: You must clear 10 million test rows from an audit log table
--             during weekend maintenance. DELETE or TRUNCATE? Why?
-- Exercise 2: After a plain TRUNCATE in PostgreSQL, what is the next identity
--             value? And after TRUNCATE ... RESTART IDENTITY?
-- Exercise 3: Inside BEGIN ... ROLLBACK, run TRUNCATE TABLE students CASCADE.
--             Which tables does PostgreSQL list in its NOTICE messages, and why?
