/*
================================================================================
Topic: Primary Keys, Foreign Keys, and Referential Integrity
Objective: Understand surrogate vs. composite primary keys, see foreign keys
           protect relationships, name constraints, and choose referential
           actions (RESTRICT, CASCADE, SET NULL).
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same syntax, except Oracle has no ON UPDATE CASCADE
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- 1. PRIMARY KEY (PK)
--    - Uniquely identifies every row in a table; never NULL, never duplicated.
--    - In this database EVERY table uses a single auto-generated surrogate key:
--        score_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
--
-- 2. FOREIGN KEY (FK)
--    - A column whose value must exist as a PK value in another (parent) table.
--    - Enforces Referential Integrity: no "orphan" rows pointing at nothing.
--
-- 3. REFERENTIAL ACTIONS (what happens to children when a parent is deleted?)
--    - NO ACTION / RESTRICT (default): the DELETE is refused while children exist.
--    - CASCADE  : the children are deleted too.
--    - SET NULL : the child's FK column is set to NULL (column must allow NULL).


-- =============================================================================
-- 2. Surrogate Key + UNIQUE vs. Composite Primary Key
-- =============================================================================
-- "A student has only ONE score per assessment" can be enforced two ways:
--
-- A. What our schema does: surrogate PK + composite UNIQUE
--      score_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--      enrollment_id INTEGER NOT NULL,
--      assessment_id INTEGER NOT NULL,
--      ...
--      UNIQUE (enrollment_id, assessment_id)
--
-- B. Alternative design: composite PRIMARY KEY (no score_id column)
/*
CREATE TABLE assessment_scores (
    enrollment_id   INTEGER      NOT NULL,
    assessment_id   INTEGER      NOT NULL,
    score           DECIMAL(5,2) NOT NULL CHECK (score >= 0),
    PRIMARY KEY (enrollment_id, assessment_id),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments (enrollment_id),
    FOREIGN KEY (assessment_id) REFERENCES assessments (assessment_id)
);
*/
-- Both block duplicates. Design A gives every row a simple one-column ID that
-- other tables can reference; design B saves a column and an index.

-- See the PK and UNIQUE pair that our schema actually has:
SELECT
    tc.constraint_type,
    tc.constraint_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON  kcu.constraint_name   = tc.constraint_name
    AND kcu.constraint_schema = tc.constraint_schema
WHERE tc.table_name = 'assessment_scores'
  AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE')
ORDER BY tc.constraint_type, kcu.ordinal_position;


-- =============================================================================
-- 3. Foreign Keys in Action: RESTRICT (the default)
-- =============================================================================

-- Faculty 1 still has departments, so deleting it is refused.
-- Uncomment to see the error:
-- DELETE FROM faculties WHERE faculty_id = 1;
-- Expected: ERROR: update or delete on table "faculties" violates foreign key
--           constraint "departments_faculty_id_fkey" on table "departments"

-- An INSERT that points at a parent that does not exist is refused too:
-- INSERT INTO departments (department_name, building, faculty_id)
-- VALUES ('Physics', 'Block D', 99);
-- Expected: ERROR: insert or update on table "departments" violates foreign key
--           constraint "departments_faculty_id_fkey"

-- Faculty 3 (Law) has no departments, so deleting it works.
-- BEGIN ... ROLLBACK runs the demo and then undoes it (see module 12),
-- so the sample data stays the same for the next lesson.
BEGIN;
    DELETE FROM faculties WHERE faculty_id = 3;
    SELECT faculty_id, faculty_name FROM faculties;   -- 2 rows left
ROLLBACK;


-- =============================================================================
-- 4. Naming Foreign Keys and Choosing Referential Actions
-- =============================================================================
-- Our CREATE TABLE statements declared foreign keys WITHOUT names, so
-- PostgreSQL generated them as <table>_<column>_fkey:

SELECT
    conrelid::regclass         AS child_table,
    conname                    AS constraint_name,
    pg_get_constraintdef(oid)  AS definition
FROM pg_constraint
WHERE contype = 'f'
  AND connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, conname;

-- Demo: replace the FK on invoice_items with a NAMED one that CASCADEs,
-- then delete an invoice and watch its line items disappear with it.
-- Invoice 9 has 2 items and no payments.
BEGIN;
    ALTER TABLE invoice_items
        DROP CONSTRAINT invoice_items_invoice_id_fkey,
        ADD CONSTRAINT fk_invoice_items_invoice
            FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id)
            ON DELETE CASCADE;

    SELECT COUNT(*) AS items_before FROM invoice_items WHERE invoice_id = 9;  -- 2

    DELETE FROM invoices WHERE invoice_id = 9;

    SELECT COUNT(*) AS items_after FROM invoice_items WHERE invoice_id = 9;   -- 0
ROLLBACK;   -- the constraint change and the delete are both undone

-- Reference: the same named-constraint syntax for other relationships.
-- (Not run: these columns already have foreign keys.)
/*
ALTER TABLE departments
    ADD CONSTRAINT fk_departments_faculty
    FOREIGN KEY (faculty_id) REFERENCES faculties (faculty_id)
    ON DELETE RESTRICT;

-- If a lecturer leaves, keep the course offering but clear the lecturer:
ALTER TABLE course_offerings
    ADD CONSTRAINT fk_offerings_lecturer
    FOREIGN KEY (lecturer_id) REFERENCES lecturers (lecturer_id)
    ON DELETE SET NULL;
*/
-- Note: even with SET NULL on course_offerings, a lecturer still cannot be
-- deleted while salary_payments references them. Real systems rarely delete
-- people with history; they change a status column instead.


-- =============================================================================
-- 5. Inspecting Keys (portable INFORMATION_SCHEMA version)
-- =============================================================================

-- Every foreign key: child column -> parent column, with its delete rule.
SELECT
    kcu.table_name   AS child_table,
    kcu.column_name  AS child_column,
    ccu.table_name   AS parent_table,
    ccu.column_name  AS parent_column,
    rc.delete_rule   AS on_delete
FROM information_schema.referential_constraints rc
JOIN information_schema.key_column_usage kcu
    ON  kcu.constraint_name   = rc.constraint_name
    AND kcu.constraint_schema = rc.constraint_schema
JOIN information_schema.constraint_column_usage ccu
    ON  ccu.constraint_name   = rc.unique_constraint_name
    AND ccu.constraint_schema = rc.unique_constraint_schema
WHERE rc.constraint_schema = 'public'
ORDER BY child_table, child_column;

-- Every primary key column:
SELECT
    tc.table_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON  kcu.constraint_name   = tc.constraint_name
    AND kcu.constraint_schema = tc.constraint_schema
WHERE tc.constraint_type   = 'PRIMARY KEY'
  AND tc.constraint_schema = 'public'
ORDER BY tc.table_name;


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Why is ON DELETE CASCADE sensible for 'invoice_items' but dangerous
--             for 'departments' referencing 'faculties'?
-- Exercise 2: Inside BEGIN ... ROLLBACK, replace the FK from 'students' to
--             'programs' with one named 'fk_students_program' (ON DELETE RESTRICT).
--             Hint: the existing constraint is students_program_id_fkey.
-- Exercise 3: Give one advantage and one disadvantage of our surrogate 'score_id'
--             compared with a composite PRIMARY KEY (enrollment_id, assessment_id).
