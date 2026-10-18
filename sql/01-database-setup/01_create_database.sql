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
-- 2. MySQL Implementation
-- =============================================================================
-- In MySQL, a "DATABASE" and a "SCHEMA" are synonyms.

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


-- =============================================================================
-- 3. PostgreSQL Implementation
-- =============================================================================
-- In PostgreSQL, CREATE DATABASE creates a physical database cluster entry.
-- Schemas (namespaces) are created inside a database (default schema is 'public').

/*
-- Run in psql or administrative connection (cannot run inside transaction block):
CREATE DATABASE ulk_university_db
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0;

-- In psql client, connect to the database:
-- \c ulk_university_db

-- Optional: Create a dedicated schema inside the database
CREATE SCHEMA IF NOT EXISTS academics;
SET search_path TO academics, public;
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
