/*
================================================================================
Topic: Constraints: UNIQUE, CHECK, NOT NULL, and DEFAULT
Objective: Enforce business rules in the ULK University database with single
           and composite UNIQUE constraints, CHECK expressions, NOT NULL and
           DEFAULT values, and see the database reject bad data.
Database: PostgreSQL (pgAdmin)
          MySQL 8.0.16+ / Oracle: same syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Constraints are business rules enforced by the database itself, so no
-- application, script or typo can store invalid data:
--
-- - NOT NULL : the value is required.
-- - UNIQUE   : no two rows may share the value (or the combination of values).
-- - CHECK    : the row must make a TRUE/FALSE condition TRUE.
-- - DEFAULT  : value used when an INSERT does not supply one.
--
-- Constraints can be written INLINE in CREATE TABLE (as in 01_create_tables.sql)
-- or added later with ALTER TABLE ... ADD CONSTRAINT <name> ...


-- =============================================================================
-- 2. The Constraints Our Tables Already Have
-- =============================================================================
-- Examples from 01_create_tables.sql:
--   email          VARCHAR(100) NOT NULL UNIQUE,              -- single-column UNIQUE
--   UNIQUE (student_id, offering_id)                          -- composite UNIQUE
--   credits        INTEGER NOT NULL CHECK (credits BETWEEN 1 AND 20),
--   status         VARCHAR(20) NOT NULL DEFAULT 'Active'
--                  CHECK (status IN ('Active', 'Suspended', 'Withdrawn', 'Graduated'))
--
-- Inline constraints get generated names such as students_email_key
-- (UNIQUE) or courses_credits_check (CHECK). List them all:

SELECT
    conrelid::regclass         AS table_name,
    conname                    AS constraint_name,
    CASE contype WHEN 'u' THEN 'UNIQUE' WHEN 'c' THEN 'CHECK' END AS constraint_type,
    pg_get_constraintdef(oid)  AS definition
FROM pg_constraint
WHERE contype IN ('u', 'c')
  AND connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, contype, conname;


-- =============================================================================
-- 3. Watching Constraints Reject Bad Data
-- =============================================================================
-- Each statement below breaks one rule. Uncomment one at a time to see the error.

-- NOT NULL: every student needs a last name
-- INSERT INTO students (registration_no, first_name, last_name, email, admission_year, program_id)
-- VALUES ('2026CS099', 'Test', NULL, 'test.student@uni.example', 2026, 1);
-- Expected: ERROR: null value in column "last_name" of relation "students" violates not-null constraint

-- UNIQUE: registration number 2024CS001 already belongs to Aline Uwase
-- INSERT INTO students (registration_no, first_name, last_name, email, admission_year, program_id)
-- VALUES ('2024CS001', 'Test', 'Student', 'test.student@uni.example', 2026, 1);
-- Expected: ERROR: duplicate key value violates unique constraint "students_registration_no_key"

-- Composite UNIQUE: student 1 is already enrolled in offering 1
-- INSERT INTO enrollments (student_id, offering_id, enrollment_date)
-- VALUES (1, 1, '2026-09-10');
-- Expected: ERROR: duplicate key value violates unique constraint "enrollments_student_id_offering_id_key"

-- CHECK: 'Certificate' is not an allowed degree level
-- INSERT INTO programs (program_name, degree_level, duration_years, department_id)
-- VALUES ('Certificate in Coding', 'Certificate', 1, 1);
-- Expected: ERROR: new row for relation "programs" violates check constraint "programs_degree_level_check"

-- CHECK: salaries must be positive
-- UPDATE lecturers SET monthly_salary = -50000 WHERE lecturer_id = 1;
-- Expected: ERROR: new row for relation "lecturers" violates check constraint "lecturers_monthly_salary_check"


-- =============================================================================
-- 4. DEFAULT Values
-- =============================================================================
-- status is not listed in the INSERT, so the DEFAULT 'Active' is used.
-- RETURNING shows the row that was stored. ROLLBACK then removes it again.
BEGIN;
    INSERT INTO students (registration_no, first_name, last_name, email, admission_year, program_id)
    VALUES ('2026CS099', 'Test', 'Student', 'test.student@uni.example', 2026, 1)
    RETURNING student_id, registration_no, status;     -- status = 'Active'
ROLLBACK;


-- =============================================================================
-- 5. Adding NEW Named Business Rules with ALTER TABLE
-- =============================================================================
-- Naming a constraint (chk_..., uq_...) makes error messages readable and
-- lets you drop it later by name.
-- DROP CONSTRAINT IF EXISTS first makes this section safe to run twice.

-- Rule 1 (CHECK): emails must look like name@domain
ALTER TABLE students DROP CONSTRAINT IF EXISTS chk_students_email_format;
ALTER TABLE students
    ADD CONSTRAINT chk_students_email_format
    CHECK (email LIKE '%_@_%');

-- Rule 2 (CHECK across columns): deductions cannot exceed the gross salary
ALTER TABLE salary_payments DROP CONSTRAINT IF EXISTS chk_salary_deductions;
ALTER TABLE salary_payments
    ADD CONSTRAINT chk_salary_deductions
    CHECK (tax_amount + other_deductions <= gross_amount);

-- Rule 3 (composite UNIQUE): a room hosts only one offering per term
ALTER TABLE course_offerings DROP CONSTRAINT IF EXISTS uq_offerings_term_room;
ALTER TABLE course_offerings
    ADD CONSTRAINT uq_offerings_term_room
    UNIQUE (term_id, room);
-- Note: offering 10 has room = NULL. UNIQUE ignores NULLs, so several
-- offerings may still have "no room yet" in the same term.

-- Rule 4 (DEFAULT): enrollment_date defaults to today when not supplied
ALTER TABLE enrollments
    ALTER COLUMN enrollment_date SET DEFAULT CURRENT_DATE;

-- Test Rule 3 (uncomment): offering 1 already uses room A-101 in term 1
-- UPDATE course_offerings SET room = 'A-101' WHERE offering_id = 2;
-- Expected: ERROR: duplicate key value violates unique constraint "uq_offerings_term_room"

-- IMPORTANT: ADD CONSTRAINT checks the rows ALREADY in the table. If any
-- existing row breaks the rule, the ALTER TABLE fails and nothing changes.

-- What a CHECK constraint CANNOT do: compare with another table.
-- "score <= assessments.max_score" needs data from a second table, so it must
-- be enforced with a trigger or by the application instead.


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Add a CHECK constraint named chk_students_phone ensuring 'phone'
--             starts with '+250'. Does it accept students whose phone is NULL? Why?
-- Exercise 2: Add a composite UNIQUE constraint ensuring a lecturer is not paid
--             twice on the same payment_date. Does the existing data allow it?
-- Exercise 3: Why should money columns always have a CHECK (amount >= 0) constraint?
