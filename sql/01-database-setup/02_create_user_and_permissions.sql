/*
================================================================================
Topic: User Creation and Privilege Management (Role-Based Access Control)
Objective: Create a dedicated database administrator/user (ulk_admin) and grant 
           granular privileges across the database, schemas, tables, and sequences.
Database: PostgreSQL / pgAdmin (with MySQL & Oracle reference)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- In modern relational database management systems, security and access control 
-- follow the Principle of Least Privilege (PoLP):
-- 1. Roles & Users: In PostgreSQL, users are simply roles that possess the LOGIN attribute.
-- 2. Granular Privileges: Privileges exist at multiple hierarchical layers:
--    - Database Level: CONNECT, CREATE
--    - Schema Level: USAGE (lookup/access objects), CREATE (create new objects in schema)
--    - Object Level: SELECT, INSERT, UPDATE, DELETE on tables; USAGE on sequences
--    - Default Privileges: Automatically apply privileges to objects created in the future.

-- =============================================================================
-- 2. PostgreSQL & pgAdmin Implementation (ACTIVE)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- PHASE 1: CREATE USER & GRANT DATABASE ACCESS
-- -----------------------------------------------------------------------------
-- Where to run in pgAdmin:
-- 1. In Object Explorer, right-click the default 'postgres' database (or 'ulk_university_db').
-- 2. Select "Query Tool".
-- 3. Execute Phase 1 statements below as superuser (postgres).

-- 1. Create a dedicated login user for university administrative tasks
CREATE USER ulk_admin
    WITH
    LOGIN
    PASSWORD 'admin';

-- 2. Allow ulk_admin to connect to the database
GRANT CONNECT ON DATABASE ulk_university_db
TO ulk_admin;

-- 3. Allow ulk_admin to create new schemas and objects inside the database
GRANT CREATE ON DATABASE ulk_university_db
TO ulk_admin;


-- -----------------------------------------------------------------------------
-- PHASE 2: GRANT SCHEMA, TABLE, AND SEQUENCE PRIVILEGES
-- -----------------------------------------------------------------------------
-- IMPORTANT: The database-level privileges granted in Phase 1 do NOT automatically
-- grant access to tables or schemas inside the database.
--
-- Run Phase 2 while CONNECTED TO ulk_university_db, and after the tables exist
-- (i.e. after 00_master_schema_and_data.sql). Default privileges are stored per
-- database: run in the 'postgres' database, they do nothing for this one.
-- Without Phase 2, ulk_admin gets "permission denied for table ..." errors
-- (for example from the Python scripts in module 16).
--
-- Where to run in pgAdmin:
-- 1. In Object Explorer, right-click 'Databases' and select "Refresh".
-- 2. Locate and right-click 'ulk_university_db'.
-- 3. Select "Query Tool" (to connect this session directly into 'ulk_university_db').
-- 4. Execute Phase 2 statements below:

-- 4. Grant schema access (Essential for PostgreSQL 15+)
-- USAGE allows looking up tables/types; CREATE allows creating new tables in public.
GRANT USAGE, CREATE ON SCHEMA public
TO ulk_admin;

-- 5. Grant CRUD privileges on all EXISTING tables in the public schema
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO ulk_admin;

-- 6. Grant privileges on all EXISTING sequences (required for IDENTITY & SERIAL keys)
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA public
TO ulk_admin;

-- 7. Configure DEFAULT privileges for FUTURE tables and sequences
-- Any table or sequence created in the public schema going forward will
-- automatically inherit these permissions for ulk_admin without manual grants:
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES
TO ulk_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT, UPDATE ON SEQUENCES
TO ulk_admin;


-- -----------------------------------------------------------------------------
-- PHASE 3: VERIFICATION & AUDIT QUERIES
-- -----------------------------------------------------------------------------
-- Run these queries inside 'ulk_university_db' Query Tool to audit permissions:




-- Quick check: must return true
SELECT has_table_privilege('ulk_admin', 'public.students', 'SELECT') AS ulk_admin_can_read_students;

-- Check all table permissions granted to ulk_admin
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'ulk_admin'
ORDER BY table_name, privilege_type;

-- Inspect database-level Access Control List (ACL)
SELECT 
    datname,
    datacl
FROM pg_database
WHERE datname = 'ulk_university_db';


-- =============================================================================
-- 3. MySQL Implementation (Commented for MySQL Workbench / CLI)
-- =============================================================================
-- In MySQL, user management and permissions are granted globally or per database/table.
-- Uncomment and run the block below if using MySQL:

/*
-- Create user with remote & local access
CREATE USER 'ulk_admin'@'%' IDENTIFIED BY 'admin';

-- Grant full permissions on all tables within ulk_university_db
GRANT ALL PRIVILEGES ON ulk_university_db.* TO 'ulk_admin'@'%';

-- Reload privilege tables to apply changes immediately
FLUSH PRIVILEGES;

-- Verify granted privileges
SHOW GRANTS FOR 'ulk_admin'@'%';
*/


-- =============================================================================
-- 4. Oracle Database Implementation
-- =============================================================================
-- In Oracle, creating a user inherently creates a private schema for that user.

/*
ALTER SESSION SET CONTAINER = orclpdb1;

CREATE USER ulk_admin IDENTIFIED BY "admin"
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE TO ulk_admin;
*/


-- =============================================================================
-- 5. Practice Questions & Exercises
-- =============================================================================
-- Exercise 1: Create a read-only role named 'ulk_student_reader' that can only 
--             run SELECT queries on tables in the public schema.
-- Exercise 2: Write the command to revoke DELETE privileges on all tables from 'ulk_admin'.
-- Exercise 3: How does ALTER DEFAULT PRIVILEGES differ from GRANT ON ALL TABLES?
