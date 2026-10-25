/*
================================================================================
Topic: Modifying Records with UPDATE
Objective: Change existing rows safely with single-column, multi-column,
           calculated and subquery-based UPDATE statements.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same UPDATE syntax; RETURNING is PostgreSQL-only
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
--   UPDATE table_name
--   SET    column1 = value1, column2 = value2
--   WHERE  condition;              -- which rows to change
--
-- CRITICAL: an UPDATE without WHERE changes EVERY row in the table.
--
-- The safe routine used in this file:
--   1. SELECT with the same WHERE  -> check exactly which rows will change
--   2. UPDATE ... RETURNING        -> see the rows as they are after the change
--   3. ROLLBACK (practice) or COMMIT (for real)
--
-- Every section runs inside BEGIN ... ROLLBACK so the sample data is restored
-- afterwards (transactions are explained in module 12).


-- =============================================================================
-- 2. One Row, One Column
-- =============================================================================
-- Kevin Manzi (student 8) has brought his birth certificate.
BEGIN;
    SELECT student_id, first_name, last_name, date_of_birth
    FROM students
    WHERE student_id = 8;                               -- date_of_birth is NULL

    UPDATE students
    SET date_of_birth = '2005-12-01'
    WHERE student_id = 8
    RETURNING student_id, first_name, date_of_birth;    -- 1 row updated
ROLLBACK;


-- =============================================================================
-- 3. Several Columns at Once
-- =============================================================================
-- ECO101 next term (offering 10) finally gets a lecturer and a room.
BEGIN;
    UPDATE course_offerings
    SET lecturer_id = 8,                                -- Josiane Uwimana
        room        = 'C-210'
    WHERE offering_id = 10
    RETURNING offering_id, course_id, lecturer_id, room;
ROLLBACK;


-- =============================================================================
-- 4. Calculated Updates (the new value uses the old value)
-- =============================================================================
-- 5% raise for Lecturers and Assistant Lecturers.
BEGIN;
    -- Step 1: preview old and new salary side by side
    SELECT first_name, last_name, academic_rank,
           monthly_salary                  AS current_salary,
           ROUND(monthly_salary * 1.05, 2) AS new_salary
    FROM lecturers
    WHERE academic_rank IN ('Assistant Lecturer', 'Lecturer');   -- 4 rows

    -- Step 2: apply it
    UPDATE lecturers
    SET monthly_salary = ROUND(monthly_salary * 1.05, 2)
    WHERE academic_rank IN ('Assistant Lecturer', 'Lecturer')
    RETURNING first_name, last_name, monthly_salary;
ROLLBACK;


-- =============================================================================
-- 5. UPDATE with a Subquery (filter by data from another table)
-- =============================================================================
-- 10% raise for everyone in the Mathematics department, without having to
-- know that its department_id is 2.
BEGIN;
    UPDATE lecturers
    SET monthly_salary = ROUND(monthly_salary * 1.10, 2)
    WHERE department_id = (SELECT department_id
                           FROM departments
                           WHERE department_name = 'Mathematics')
    RETURNING first_name, last_name, monthly_salary;    -- 2 rows: Joseph, Esther
ROLLBACK;


-- =============================================================================
-- 6. The Classic Mistake: Forgetting WHERE
-- =============================================================================
BEGIN;
    UPDATE students
    SET status = 'Graduated';                           -- no WHERE: "UPDATE 15"

    SELECT status, COUNT(*) AS students
    FROM students
    GROUP BY status;                                    -- everyone has graduated!
ROLLBACK;                                               -- saved by the transaction

-- MySQL Workbench protects you with "safe updates" mode, which refuses an
-- UPDATE or DELETE whose WHERE clause does not use a key column:
--   SET SQL_SAFE_UPDATES = 1;


-- =============================================================================
-- 7. Practice Exercises (use BEGIN ... ROLLBACK)
-- =============================================================================
-- Exercise 1: Give every lecturer in department 3 a flat 50,000 RWF increase.
-- Exercise 2: Change the status of all 'Registered' enrollments in offering 9
--             to 'Dropped'. How many rows change?
-- Exercise 3: Set the building of every department whose building is NULL to
--             'Main Campus'. (Hint: building = NULL does not work. Why?)
