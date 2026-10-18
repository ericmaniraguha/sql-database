/*
================================================================================
Topic: Transaction Fundamentals and ACID Properties
Objective: Understand relational transaction guarantees (Atomicity, Consistency, 
           Isolation, Durability) and concurrency control.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: The ACID Guarantee
-- =============================================================================
-- A transaction is a single logical unit of work that may contain one or multiple
-- SQL operations. A database transaction adheres to four ACID properties:
--
-- 1. ATOMICITY ("All or Nothing"):
--    Every statement in the transaction must execute successfully. If any single
--    operation fails, the entire transaction is rolled back as if nothing happened.
--
-- 2. CONSISTENCY ("Valid State to Valid State"):
--    A transaction can only bring the database from one valid state to another,
--    enforcing all constraints (keys, checks, uniques, data types).
--
-- 3. ISOLATION ("Independence of Concurrent Transactions"):
--    Concurrent transactions execute independently without interfering with each
--    other. ANSI SQL defines four isolation levels:
--    - READ UNCOMMITTED (Allows dirty reads)
--    - READ COMMITTED (Default in PostgreSQL & Oracle; prevents dirty reads)
--    - REPEATABLE READ (Default in MySQL InnoDB; prevents non-repeatable reads)
--    - SERIALIZABLE (Highest isolation; prevents phantom reads)
--
-- 4. DURABILITY ("Permanence after Commit"):
--    Once a transaction is committed, its changes survive system crashes or power failures.

-- =============================================================================
-- 2. Transaction Isolation Level Inspection and Configuration
-- =============================================================================

-- In PostgreSQL:
-- SHOW transaction_isolation;
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- In MySQL:
-- SELECT @@transaction_isolation;
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- In Oracle:
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- =============================================================================
-- 3. Practice Questions
-- =============================================================================
-- Exercise 1: What is a "dirty read", and which isolation level permits it?
-- Exercise 2: Why is Atomicity critical during bank fund transfers or student course registration?
