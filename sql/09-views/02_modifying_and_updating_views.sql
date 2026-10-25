/*
================================================================================
Topic: Changing, Updating Through, and Dropping Views
Objective: Change a view's definition, update base tables THROUGH a view,
           protect a view's filter with WITH CHECK OPTION, and drop views
           that other objects depend on.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same ideas; error messages differ
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: When Can You UPDATE a View?
-- =============================================================================
-- A view stores a query, not data. An UPDATE / INSERT / DELETE on a view is
-- passed on to the base table, but only when the database can tell exactly
-- which base row to change. PostgreSQL makes a view updatable automatically
-- when it:
--   1. reads from exactly ONE table (or one updatable view),
--   2. has no GROUP BY, HAVING, DISTINCT, aggregates, UNION or LIMIT,
--   3. selects plain columns (calculated columns are read-only).
-- Join views and summary views (like final_grades) are read-only.


-- =============================================================================
-- 2. An Updatable View with WITH CHECK OPTION
-- =============================================================================
-- DROP first so this file can be run again after changes in Section 4.
DROP VIEW IF EXISTS v_active_cs_students;

CREATE VIEW v_active_cs_students AS
SELECT
    student_id,
    registration_no,
    first_name,
    last_name,
    email,
    phone,
    admission_year,
    status,
    program_id
FROM students
WHERE program_id = 1                              -- BSc Computer Science
  AND status = 'Active'
WITH CHECK OPTION;   -- changes made through the view must still match the WHERE

SELECT registration_no, first_name, last_name
FROM v_active_cs_students
ORDER BY registration_no;                         -- 5 students


-- =============================================================================
-- 3. Changing Data Through the View
-- =============================================================================
BEGIN;
    -- UPDATE through the view: the change lands in the students table
    UPDATE v_active_cs_students
    SET phone = '+250789199999'
    WHERE student_id = 1;

    SELECT student_id, phone FROM students WHERE student_id = 1;    -- changed

    -- INSERT through the view: a new CS student
    INSERT INTO v_active_cs_students
        (registration_no, first_name, last_name, email, admission_year, status, program_id)
    VALUES
        ('2026CS050', 'Clarisse', 'Uwamahoro', 'clarisse.uwamahoro@uni.example', 2026, 'Active', 1)
    RETURNING student_id, registration_no;
ROLLBACK;

-- WITH CHECK OPTION blocks changes that would make the row leave the view.
-- Suspending a student through an "active students" view is refused:
-- UPDATE v_active_cs_students SET status = 'Suspended' WHERE student_id = 1;
-- Expected: ERROR: new row violates check option for view "v_active_cs_students"

-- So is inserting a Mathematics student (program 2) through a CS view:
-- INSERT INTO v_active_cs_students (registration_no, first_name, last_name, email, admission_year, status, program_id)
-- VALUES ('2026MA050', 'Test', 'Student', 'test.ma@uni.example', 2026, 'Active', 2);
-- Expected: ERROR: new row violates check option for view "v_active_cs_students"


-- =============================================================================
-- 4. Changing a View's Definition
-- =============================================================================
-- CREATE OR REPLACE VIEW may ADD columns at the END, but cannot remove,
-- rename or retype existing ones.
CREATE OR REPLACE VIEW v_active_cs_students AS
SELECT
    student_id, registration_no, first_name, last_name, email, phone,
    admission_year, status, program_id,
    date_of_birth                                 -- new column, added at the end
FROM students
WHERE program_id = 1
  AND status = 'Active'
WITH CHECK OPTION;

-- Removing a column this way fails:
-- CREATE OR REPLACE VIEW v_active_cs_students AS
-- SELECT student_id, first_name FROM students WHERE program_id = 1;
-- Expected: ERROR: cannot drop columns from view
-- For bigger changes: DROP VIEW, then CREATE VIEW again.

-- Renaming a view:
-- ALTER VIEW v_active_cs_students RENAME TO v_cs_students_active;


-- =============================================================================
-- 5. A Read-Only Join View
-- =============================================================================
DROP VIEW IF EXISTS v_student_directory;

CREATE VIEW v_student_directory AS
SELECT
    s.student_id,
    s.registration_no,
    s.first_name || ' ' || s.last_name AS student_name,
    s.email,
    s.status,
    p.program_name,
    d.department_name
FROM students s
JOIN programs    p ON p.program_id    = s.program_id
JOIN departments d ON d.department_id = p.department_id;

SELECT registration_no, student_name, program_name, department_name
FROM v_student_directory
WHERE status = 'Active'
ORDER BY department_name, student_name;

-- It joins three tables, so it is NOT automatically updatable:
-- UPDATE v_student_directory SET email = 'x@uni.example' WHERE student_id = 1;
-- Expected: ERROR: cannot update view "v_student_directory"
--           DETAIL: Views that do not select from a single table or view
--                   are not automatically updatable.


-- =============================================================================
-- 6. Dropping Views and Their Dependencies
-- =============================================================================
-- student_gpa is built on final_grades, so final_grades cannot simply be dropped:
-- DROP VIEW final_grades;
-- Expected: ERROR: cannot drop view final_grades because other objects depend on it
-- DROP VIEW final_grades CASCADE would silently drop student_gpa as well.

-- Clean up this lesson's views (remove these lines to keep them):
DROP VIEW IF EXISTS v_active_cs_students;
DROP VIEW IF EXISTS v_student_directory;


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Why is the student_gpa view NOT updatable? Name two reasons.
-- Exercise 2: Create an updatable view of the lecturers in department 2 WITH
--             CHECK OPTION. Inside BEGIN ... ROLLBACK, try to move one of them
--             to department 1 through the view. What happens?
-- Exercise 3: Create a view v_current_term_offerings showing, for term 1, the
--             course code, title, lecturer name and room. Is it updatable?
