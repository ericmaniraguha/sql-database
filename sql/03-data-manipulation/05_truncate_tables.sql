/*
================================================================================
Topic: Table Truncation with TRUNCATE
Objective: Compare TRUNCATE TABLE with DELETE, understand transaction logging, 
           and identify when to use each command.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: TRUNCATE vs DELETE
-- =============================================================================
-- | Feature              | DELETE                           | TRUNCATE                         |
-- |----------------------|----------------------------------|----------------------------------|
-- | Command Category     | DML (Data Manipulation Language) | DDL (Data Definition Language)   |
-- | WHERE Clause         | Supported (selective removal)    | Not supported (all rows removed) |
-- | Execution Speed      | Slower (logs row by row)         | Much faster (deallocates pages)  |
-- | Identity / Auto-Inc  | Maintains current sequence value | Resets sequence back to 1        |
-- | Triggers             | Fires ON DELETE triggers         | Does NOT fire row-level triggers |
-- | Rollback             | Fully rollbackable in tx         | Rollbackable in PG/Oracle; not in older MySQL |

-- =============================================================================
-- 2. Truncate Syntax Examples
-- =============================================================================

-- Truncate staging or temporary table
TRUNCATE TABLE honor_roll_students;

-- Verify table is empty
SELECT COUNT(*) AS row_count FROM honor_roll_students;

-- =============================================================================
-- 3. Handling Foreign Key Constraints with TRUNCATE
-- =============================================================================
-- If a table is referenced by a FOREIGN KEY constraint from another table,
-- TRUNCATE is normally rejected by MySQL and PostgreSQL even if child table is empty.

-- In PostgreSQL:
-- TRUNCATE TABLE departments CASCADE; -- Truncates child tables recursively!

-- In MySQL:
-- You must temporarily disable foreign key checks (use with extreme caution):
-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE departments;
-- SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 4. Practice Questions
-- =============================================================================
-- Exercise 1: If you need to clear 10 million test records from an audit log table 
--             during weekend maintenance, would you use DELETE or TRUNCATE? Explain why.
-- Exercise 2: What happens to AUTO_INCREMENT or IDENTITY columns after TRUNCATE?
