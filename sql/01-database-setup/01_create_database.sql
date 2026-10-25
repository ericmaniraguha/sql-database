/*
================================================================================
Topic: Database Creation and Environment Setup
Objective: Learn how to create, inspect, and select databases across relational 
           database management systems.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A database is an organized collection of structured data stored electronically.
-- In a Relational Database Management System (RDBMS), creating a database provides
-- an isolated namespace containing schemas, tables, views, constraints, and indexes.

-- =============================================================================
-- 2. PostgreSQL & pgAdmin Implementation (ACTIVE)
-- =============================================================================
-- In PostgreSQL, CREATE DATABASE creates a physical database cluster entry.
-- PostgreSQL does NOT support 'IF NOT EXISTS' or the 'USE database_name' command.
--
-- How to run this in pgAdmin:
-- 1. Connect to your PostgreSQL server in pgAdmin.
-- 2. In Object Explorer, right-click the default maintenance database 'postgres'
--    and select "Query Tool" (CREATE DATABASE cannot run inside a transaction block).
-- 3. Execute the statement below to create the database.
-- 4. After creation, right-click 'Databases' in Object Explorer and click "Refresh".
-- 5. Next Step: Open and run '02_create_user_and_permissions.sql' to create your
--    dedicated user ('ulk_admin') and grant schema/table privileges!
--
-- Alternatively via pgAdmin GUI:
-- Right-click 'Databases' -> Create -> Database... -> Name it 'ulk_university_db' -> Save.

-- ============================================
-- 1. CREATE THE UNIVERSITY DATABASE
-- ============================================
CREATE DATABASE ulk_university_db
    WITH
    ENCODING = 'UTF8';

-- Advanced variant with explicit collation and pristine template (optional):
-- CREATE DATABASE ulk_university_db
--     WITH 
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'en_US.UTF-8'
--     LC_CTYPE = 'en_US.UTF-8'
--     TEMPLATE = template0;


-- ============================================
-- 2. VERIFICATION & POST-CREATION COMMANDS
-- ============================================
-- Run in Query Tool connected to ulk_university_db:

-- Verify current active database (replaces MySQL's SELECT DATABASE();)
-- SELECT current_database() AS active_database;

-- Display all non-template databases on the server (replaces SHOW DATABASES;)
-- SELECT datname FROM pg_database WHERE datistemplate = false;

-- Drop database syntax (CAUTION: cannot drop the currently connected database)
-- DROP DATABASE IF EXISTS ulk_university_db;


-- =============================================================================
-- 3. MySQL Implementation (Commented for MySQL Workbench / CLI)
-- =============================================================================
-- In MySQL, a "DATABASE" and a "SCHEMA" are synonyms.
-- Uncomment and run the block below if using MySQL Workbench or MySQL CLI:

/*
-- Check if database exists before creating (prevents errors)
CREATE DATABASE IF NOT EXISTS ulk_university_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Switch context to the new database
USE ulk_university_db;

-- Verify the active database
SELECT DATABASE() AS active_database;

-- Display all available databases on the server
SHOW DATABASES;

-- Drop database syntax (CAUTION: removes all tables and data)
-- DROP DATABASE IF EXISTS ulk_university_db;
*/


-- =============================================================================
-- 4. Oracle Database Implementation
-- =============================================================================
-- In modern Oracle (12c+), databases operate with Pluggable Databases (PDBs).
-- Typically, each application or course has its own user/schema inside a PDB.

/*
-- Administrative setup in Oracle SQL*Plus or SQL Developer:
ALTER SESSION SET CONTAINER = orclpdb1;

CREATE USER ulk_admin IDENTIFIED BY "SecureP@ssw0rd2026"
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE SEQUENCE TO ulk_admin;

-- Connect as the newly created user:
-- CONNECT ulk_admin/SecureP@ssw0rd2026@orclpdb1
*/


-- =============================================================================
-- 5. Practice Questions & Exercises
-- =============================================================================
-- Exercise 1: Write an SQL statement to create a database named 'ulk_library_db' 
--             with UTF-8 encoding support.
-- Exercise 2: Write the command to verify which database is currently selected.
-- Exercise 3: Write a safe command to drop 'ulk_library_db' only if it already exists.
