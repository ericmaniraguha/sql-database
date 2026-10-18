/*
================================================================================
Topic: Table Evolution with ALTER TABLE
Objective: Modify existing schema structures by adding, dropping, modifying columns, 
           and managing constraints without data loss.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- In real-world software engineering, database structures evolve over time.
-- The ALTER TABLE command allows database administrators to modify table definitions
-- without dropping and recreating them.

-- =============================================================================
-- 2. Adding New Columns
-- =============================================================================

-- Add phone_number column to students table
ALTER TABLE students
ADD phone_number VARCHAR(20);

-- Add office_number column to instructors
ALTER TABLE instructors
ADD office_number VARCHAR(15);

-- =============================================================================
-- 3. Modifying Column Data Types and Nullability
-- =============================================================================

-- Standard / PostgreSQL syntax:
-- ALTER TABLE students ALTER COLUMN phone_number TYPE VARCHAR(30);
-- ALTER TABLE students ALTER COLUMN phone_number SET NOT NULL;

-- MySQL syntax:
-- ALTER TABLE students MODIFY phone_number VARCHAR(30);

-- Oracle syntax:
-- ALTER TABLE students MODIFY (phone_number VARCHAR2(30));

-- =============================================================================
-- 4. Renaming Columns and Tables
-- =============================================================================

-- Rename column (Standard SQL supported by PostgreSQL 9.2+, MySQL 8.0+, Oracle):
ALTER TABLE departments
RENAME COLUMN building TO campus_building;

-- Revert column name back
ALTER TABLE departments
RENAME COLUMN campus_building TO building;

-- =============================================================================
-- 5. Dropping Columns
-- =============================================================================

-- Drop phone_number from students if no longer needed
ALTER TABLE students
DROP COLUMN phone_number;

-- =============================================================================
-- 6. Adding and Dropping Constraints Dynamically
-- =============================================================================

-- Add temporary constraint
ALTER TABLE courses
ADD CONSTRAINT chk_temp_course_code_len CHECK (LENGTH(course_code) >= 3);

-- Drop named constraint
-- PostgreSQL / Oracle:
ALTER TABLE courses
DROP CONSTRAINT chk_temp_course_code_len;

-- MySQL (requires DROP CHECK):
-- ALTER TABLE courses DROP CHECK chk_temp_course_code_len;

-- =============================================================================
-- 7. Practice Questions
-- =============================================================================
-- Exercise 1: Write an ALTER TABLE command to add a 'middle_name' column to students.
-- Exercise 2: Write an ALTER TABLE command to set the default value of 'status' in students to 'Active'.
