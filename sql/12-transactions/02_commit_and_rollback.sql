/*
================================================================================
Topic: Transaction Control: COMMIT and ROLLBACK
Objective: Control atomic multi-step operations using explicit transactions, 
           persisting successful changes with COMMIT and aborting errors with ROLLBACK.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- In default auto-commit mode, every single SQL statement is treated as a transaction
-- and committed immediately.
-- To group multiple statements into an atomic block:
-- - PostgreSQL: BEGIN TRANSACTION; (or BEGIN;) ... COMMIT; or ROLLBACK;
-- - MySQL: START TRANSACTION; ... COMMIT; or ROLLBACK;
-- - Oracle: Transactions start implicitly with the first DML statement; end with COMMIT; or ROLLBACK;

-- =============================================================================
-- 2. Scenario 1: Successful Department Budget Transfer (COMMIT)
-- =============================================================================
-- Business Rule: Transfer $50,000 budget from Business (BA, id=2) to Computer Science (CS, id=1).
-- Both operations MUST succeed together.

-- Begin the transaction block
-- PostgreSQL / MySQL:
START TRANSACTION;

-- Step 1: Deduct from Department 2
UPDATE departments
SET budget = budget - 50000.00
WHERE department_id = 2;

-- Step 2: Credit to Department 1
UPDATE departments
SET budget = budget + 50000.00
WHERE department_id = 1;

-- Step 3: Verify within the transaction scope before committing
SELECT department_id, department_code, budget 
FROM departments 
WHERE department_id IN (1, 2);

-- Step 4: Persist changes permanently to disk
COMMIT;

-- =============================================================================
-- 3. Scenario 2: Error Handling and Aborting Changes (ROLLBACK)
-- =============================================================================
-- Scenario: An administrative mistake deducts budget for a non-existent department.
-- We must roll back to avoid partial or corrupted state.

START TRANSACTION;

-- Deduct budget from Computer Science
UPDATE departments
SET budget = budget - 100000.00
WHERE department_id = 1;

-- Mistake: Intentionally target invalid department ID 999
UPDATE departments
SET budget = budget + 100000.00
WHERE department_id = 999;

-- Abort! Undo all modifications made since START TRANSACTION
ROLLBACK;

-- Verify Department 1 budget remained untouched:
SELECT department_id, department_code, budget 
FROM departments 
WHERE department_id = 1;

-- =============================================================================
-- 4. Practice Questions
-- =============================================================================
-- Exercise 1: Write an explicit transaction that enrols a student into course 4, 
--             and increments the course's enrolled counter if such a column existed.
-- Exercise 2: What happens if a database server loses power while a transaction is 
--             open before a COMMIT statement is received?
