/*
================================================================================
Topic: Dropping Tables and Schema Reset (Drop If Needed)
Objective: Safely remove all views and tables in reverse dependency order
           to reset the database schema without dependency errors.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same statements; Oracle 23c+ supports IF EXISTS,
          older Oracle versions do not.
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: The Rule of Reverse Dependency
-- =============================================================================
-- A table CANNOT be dropped while something still depends on it:
--   * a child table whose FOREIGN KEY references it, or
--   * a VIEW whose query reads from it.
--
-- Therefore objects are always dropped in REVERSE dependency order:
--   views first -> child tables -> parent tables last.
--
-- The 'IF EXISTS' clause prevents an error if the object was never created.
--
-- WARNING: This script deletes ALL tables and ALL data. Run
-- 00_master_schema_and_data.sql afterwards to get the sample database back.


-- =============================================================================
-- 2. Drop Views First (they read from the tables below)
-- =============================================================================

-- Views created by the lessons in module 09:
DROP MATERIALIZED VIEW IF EXISTS mv_course_results;
DROP MATERIALIZED VIEW IF EXISTS mv_department_payroll;
DROP VIEW IF EXISTS v_student_directory;
DROP VIEW IF EXISTS v_current_term_offerings;
DROP VIEW IF EXISTS v_active_cs_students;

-- Views created by the master script (student_gpa reads final_grades, so it goes first):
DROP VIEW IF EXISTS student_balances;
DROP VIEW IF EXISTS student_gpa;
DROP VIEW IF EXISTS final_grades;


-- =============================================================================
-- 3. Drop All Tables in Reverse Dependency Order
-- =============================================================================

-- Finance child tables (depend on invoices, students, lecturers, terms):
DROP TABLE IF EXISTS salary_payments;
DROP TABLE IF EXISTS student_scholarships;
DROP TABLE IF EXISTS scholarships;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS invoice_items;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS fee_structures;

-- Grades and assessment child tables (depend on enrollments, offerings):
DROP TABLE IF EXISTS assessment_scores;
DROP TABLE IF EXISTS assessments;
DROP TABLE IF EXISTS grade_scale;

-- Teaching tables (depend on students, courses, lecturers, terms):
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS course_offerings;
DROP TABLE IF EXISTS course_prerequisites;
DROP TABLE IF EXISTS courses;

-- People tables (depend on departments, programs):
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS department_heads;
DROP TABLE IF EXISTS lecturers;

-- Academic structure parent tables (root dependencies):
DROP TABLE IF EXISTS academic_terms;
DROP TABLE IF EXISTS programs;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS faculties;

-- Check: this should now return 0 rows
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public';


-- =============================================================================
-- 4. PostgreSQL Alternative: DROP TABLE ... CASCADE
-- =============================================================================
-- CASCADE also drops every view and foreign key constraint that depends on
-- the table, so the order no longer matters:
--
--   DROP TABLE IF EXISTS faculties CASCADE;
--
-- CAUTION: CASCADE silently removes objects you did not name. Dropping in
-- reverse dependency order (Sections 2-3 above) shows exactly what is removed.
