/*
================================================================================
Topic: Deleting Records with DELETE
Objective: Remove rows safely, see how foreign keys protect related data,
           delete in child -> parent order, and compare hard and soft deletion.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same DELETE syntax; RETURNING is PostgreSQL-only
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
--   DELETE FROM table_name
--   WHERE condition;
--
-- - Without WHERE, DELETE removes EVERY row in the table.
-- - A parent row cannot be deleted while child rows reference it through a
--   FOREIGN KEY (the default RESTRICT behaviour from module 02).
--
-- Every section runs inside BEGIN ... ROLLBACK, so nothing is really lost.


-- =============================================================================
-- 2. Deleting One Specific Row
-- =============================================================================
-- Chantal's dropped ACC101 enrollment (enrollment 21) has no scores.
BEGIN;
    DELETE FROM enrollments
    WHERE enrollment_id = 21
    RETURNING enrollment_id, student_id, offering_id, status;   -- 1 row
ROLLBACK;


-- =============================================================================
-- 3. Deleting Several Rows
-- =============================================================================
-- Remove every enrollment that was dropped.
BEGIN;
    SELECT enrollment_id, student_id, offering_id      -- preview first: 2 rows
    FROM enrollments
    WHERE status = 'Dropped';

    DELETE FROM enrollments
    WHERE status = 'Dropped';                           -- "DELETE 2"
ROLLBACK;

-- Delete using a subquery: remove scholarships that nobody has received.
BEGIN;
    DELETE FROM scholarships
    WHERE scholarship_id NOT IN (SELECT scholarship_id
                                 FROM student_scholarships)
    RETURNING scholarship_name;                         -- Sports Excellence Award
ROLLBACK;


-- =============================================================================
-- 4. Foreign Keys Protect Related Data
-- =============================================================================
-- Aline (student 1) has enrollments and an invoice, so this is refused.
-- Uncomment to see the error:
-- DELETE FROM students WHERE student_id = 1;
-- Expected: ERROR: update or delete on table "students" violates foreign key
--           constraint "enrollments_student_id_fkey" on table "enrollments"

-- Alice (student 9, graduated) has no related rows, so she can be deleted.
BEGIN;
    DELETE FROM students
    WHERE student_id = 9
    RETURNING registration_no, first_name, last_name;
ROLLBACK;

-- To remove a student WITH related rows, delete the children first.
-- Belinda (student 15): 1 invoice (13) -> 2 invoice items + 1 payment.
BEGIN;
    DELETE FROM payments      WHERE invoice_id = 13;     -- grandchildren first
    DELETE FROM invoice_items WHERE invoice_id = 13;
    DELETE FROM invoices      WHERE student_id = 15;     -- then the child
    DELETE FROM students      WHERE student_id = 15;     -- the parent last
ROLLBACK;


-- =============================================================================
-- 5. Hard Delete vs. Soft Delete
-- =============================================================================
-- A HARD delete physically removes the row; its history (grades, payments)
-- must go too, as Section 4 showed. Universities and banks rarely do this.
--
-- A SOFT delete keeps the row and marks it as no longer active. Our students
-- table already supports this through its status column.
BEGIN;
    -- Emmanuel (student 12) leaves the university:
    UPDATE students
    SET status = 'Withdrawn'
    WHERE student_id = 12;

    -- Day-to-day queries simply ignore withdrawn students...
    SELECT registration_no, first_name, last_name
    FROM students
    WHERE status <> 'Withdrawn'
    ORDER BY registration_no;

    -- ...but his transcript and payments are still there for the records office.
    SELECT course_code, final_percent, letter_grade
    FROM final_grades
    WHERE student_id = 12;
ROLLBACK;


-- =============================================================================
-- 6. Practice Exercises (use BEGIN ... ROLLBACK)
-- =============================================================================
-- Exercise 1: Delete all invoice items with an amount of 0 (if any). How many
--             rows are deleted?
-- Exercise 2: CS401 has never been offered, yet DELETE FROM courses WHERE
--             course_code = 'CS401' is refused. Which table still references it,
--             and what would you have to delete first?
-- Exercise 3: Why is soft deletion preferred for student grades and payments?
