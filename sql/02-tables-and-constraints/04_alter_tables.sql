/*
================================================================================
Topic: Table Evolution with ALTER TABLE
Objective: Change existing tables without losing data: add, modify, rename and
           drop columns, change nullability and defaults, and add or drop
           constraints.
Database: PostgreSQL (pgAdmin)
          MySQL: ALTER TABLE t MODIFY COLUMN c VARCHAR(30) to change a type
          Oracle: ALTER TABLE t MODIFY (c VARCHAR2(30))
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A production database cannot simply be dropped and recreated when
-- requirements change: the data must survive. ALTER TABLE changes the
-- structure in place:
-- - ADD COLUMN / DROP COLUMN
-- - ALTER COLUMN ... TYPE           (change data type or length)
-- - ALTER COLUMN ... SET/DROP NOT NULL
-- - ALTER COLUMN ... SET/DROP DEFAULT
-- - RENAME COLUMN / RENAME TO       (rename a column / the table)
-- - ADD CONSTRAINT / DROP CONSTRAINT
--
-- HOW THIS FILE WORKS: each section runs inside BEGIN ... ROLLBACK.
-- In PostgreSQL even ALTER TABLE can be undone, so every change below is
-- shown and then reverted, and the shared sample database stays the same
-- for the next lessons. To keep a change for real, use COMMIT instead.


-- =============================================================================
-- 2. Adding New Columns
-- =============================================================================
BEGIN;
    -- Rwandan National ID (16 digits); optional, so existing rows get NULL
    ALTER TABLE students
        ADD COLUMN national_id VARCHAR(16);

    -- New column that is required: give it a DEFAULT so existing rows get a value
    ALTER TABLE courses
        ADD COLUMN is_elective BOOLEAN NOT NULL DEFAULT FALSE;

    SELECT registration_no, first_name, national_id     -- national_id is NULL for everyone
    FROM students
    ORDER BY student_id
    LIMIT 3;

    SELECT course_code, is_elective                     -- FALSE for every course
    FROM courses;
ROLLBACK;


-- =============================================================================
-- 3. Changing Data Types, Nullability and Defaults
-- =============================================================================
BEGIN;
    -- Make phone columns longer for international formats
    ALTER TABLE students  ALTER COLUMN phone TYPE VARCHAR(30);
    ALTER TABLE lecturers ALTER COLUMN phone TYPE VARCHAR(30);

    -- Make date_of_birth mandatory.
    -- Trying this straight away FAILS, because one student has no birth date:
    --   ALTER TABLE students ALTER COLUMN date_of_birth SET NOT NULL;
    --   Expected: ERROR: column "date_of_birth" of relation "students" contains null values
    --
    -- The safe sequence is: find the NULLs -> fill them in -> add the rule.
    SELECT student_id, first_name, last_name
    FROM students
    WHERE date_of_birth IS NULL;                        -- 1 row: Kevin Manzi

    UPDATE students
    SET date_of_birth = '2005-12-01'                    -- value confirmed with the registrar
    WHERE student_id = 8;

    ALTER TABLE students
        ALTER COLUMN date_of_birth SET NOT NULL;        -- now succeeds

    -- Change a default value
    ALTER TABLE enrollments
        ALTER COLUMN status SET DEFAULT 'Registered';

    -- Inspect the result: date_of_birth is now is_nullable = 'NO'
    SELECT column_name, data_type, character_maximum_length, is_nullable
    FROM information_schema.columns
    WHERE table_name = 'students'
      AND column_name IN ('phone', 'date_of_birth');
ROLLBACK;


-- =============================================================================
-- 4. Renaming Columns and Tables
-- =============================================================================
BEGIN;
    ALTER TABLE course_offerings
        RENAME COLUMN room TO classroom_code;

    SELECT offering_id, classroom_code
    FROM course_offerings
    ORDER BY offering_id;

    ALTER TABLE fee_structures
        RENAME TO tuition_rates;

    SELECT COUNT(*) AS rates FROM tuition_rates;        -- same rows, new name
ROLLBACK;
-- After ROLLBACK the old names (room, fee_structures) are back.


-- =============================================================================
-- 5. Dropping Columns
-- =============================================================================
-- A column that a VIEW uses cannot be dropped. registration_no is used by
-- the student_gpa and student_balances views:
--   ALTER TABLE students DROP COLUMN registration_no;
--   Expected: ERROR: cannot drop column registration_no of table students
--             because other objects depend on it

BEGIN;
    -- lecturers.phone is not used by any view, so it can be dropped
    ALTER TABLE lecturers
        DROP COLUMN phone;

    SELECT * FROM lecturers LIMIT 2;                    -- no phone column any more
ROLLBACK;


-- =============================================================================
-- 6. Adding and Dropping Constraints
-- =============================================================================
BEGIN;
    -- Registration numbers must be at least 8 characters
    ALTER TABLE students
        ADD CONSTRAINT chk_reg_no_length
        CHECK (LENGTH(registration_no) >= 8);

    -- National ID: either missing, or exactly 16 digits
    ALTER TABLE students ADD COLUMN national_id VARCHAR(16);
    ALTER TABLE students
        ADD CONSTRAINT chk_national_id_digits
        CHECK (national_id IS NULL OR national_id ~ '^[0-9]{16}$');

    -- Remove a constraint by name (the column stays)
    ALTER TABLE students
        DROP CONSTRAINT chk_reg_no_length;

    SELECT conname, pg_get_constraintdef(oid) AS definition
    FROM pg_constraint
    WHERE conrelid = 'students'::regclass
      AND contype = 'c';
ROLLBACK;


-- =============================================================================
-- 7. Inspecting Table Structure
-- =============================================================================

-- Columns, types, nullability and defaults of 'students'
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'students'
ORDER BY ordinal_position;

-- Constraints attached to 'students'
SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name   = 'students'
ORDER BY constraint_type, constraint_name;


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: Inside BEGIN ... ROLLBACK, add a 'gender' column to 'students'
--             restricted to ('M', 'F', 'Other') with a CHECK constraint.
-- Exercise 2: Change 'building' in 'departments' from VARCHAR(50) to VARCHAR(100).
-- Exercise 3: Try to make departments.building NOT NULL. Why does it fail,
--             and what would you have to do first?
-- Exercise 4: Why is 'ALTER TABLE ... DROP COLUMN' risky in a production system
--             that applications are already using?
