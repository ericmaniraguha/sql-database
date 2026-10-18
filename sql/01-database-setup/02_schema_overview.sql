/*
================================================================================
Topic: Schema Inspection and Metadata Overview
Objective: Query system catalogs and the INFORMATION_SCHEMA to inspect existing 
           tables, columns, and constraints.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The ANSI SQL standard defines INFORMATION_SCHEMA, a set of views providing
-- read-only metadata about the database, including tables, columns, constraints,
-- and data types.

-- =============================================================================
-- 2. Inspecting Tables in INFORMATION_SCHEMA (Standard / MySQL / PostgreSQL)
-- =============================================================================

-- List all tables in current database/schema
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'pg_catalog', 'sys', 'performance_schema')
ORDER BY table_name;

-- =============================================================================
-- 3. Inspecting Column Definitions
-- =============================================================================

-- Inspect columns, data types, nullability, and default values
SELECT 
    table_name,
    column_name,
    ordinal_position,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = DATABASE() -- In PostgreSQL replace DATABASE() with CURRENT_SCHEMA()
ORDER BY table_name, ordinal_position;

-- =============================================================================
-- 4. Database-Specific Quick Metadata Commands
-- =============================================================================

-- MySQL:
-- SHOW FULL TABLES;
-- DESCRIBE students;
-- SHOW CREATE TABLE students;

-- PostgreSQL (psql meta-commands):
-- \dt                 -- List all user tables
-- \d+ students        -- Describe students table in detail
-- \dn                 -- List schemas

-- Oracle Database:
-- SELECT table_name FROM user_tables ORDER BY table_name;
-- SELECT column_name, data_type, data_length, nullable FROM user_tab_columns WHERE table_name = 'STUDENTS';

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Query the INFORMATION_SCHEMA to find all columns in your database 
--             that accept NULL values.
-- Exercise 2: Find all tables in your current schema that contain an 'email' column.
