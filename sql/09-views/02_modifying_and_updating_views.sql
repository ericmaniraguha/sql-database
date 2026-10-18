/*
================================================================================
Topic: Modifying, Updating, and Dropping Views
Objective: Alter view definitions, understand updatable vs non-updatable views, 
           and enforce boundary conditions using WITH CHECK OPTION.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: Updatable Views
-- =============================================================================
-- In certain conditions, an UPDATE or INSERT executed against a view modifies the
-- underlying base table.
-- A view is generally UPDATABLE only if:
-- 1. It queries exactly ONE base table.
-- 2. It contains NO aggregate functions (COUNT, SUM, AVG, etc.).
-- 3. It contains NO DISTINCT, GROUP BY, or HAVING clauses.
-- 4. It does not use UNION, UNION ALL, or LIMIT/OFFSET.
-- 5. All NOT NULL columns of the base table without default values are included.

-- =============================================================================
-- 2. Creating an Updatable View
-- =============================================================================

CREATE OR REPLACE VIEW v_active_cs_students AS
SELECT 
    student_id,
    first_name,
    last_name,
    email,
    department_id,
    gpa,
    status
FROM students
WHERE department_id = 1 AND status = 'Active';

-- =============================================================================
-- 3. Enforcing Integrity with WITH CHECK OPTION
-- =============================================================================
-- WITH CHECK OPTION prevents any INSERT or UPDATE through the view that would
-- produce a row that the view itself cannot select!

CREATE OR REPLACE VIEW v_active_cs_students_checked AS
SELECT 
    student_id,
    first_name,
    last_name,
    email,
    department_id,
    gpa,
    status
FROM students
WHERE department_id = 1 AND status = 'Active'
WITH CHECK OPTION;

-- The following UPDATE through the view succeeds:
UPDATE v_active_cs_students_checked
SET gpa = 3.95
WHERE student_id = 1;

-- The following UPDATE FAILS because status = 'Suspended' violates the view condition!
-- UPDATE v_active_cs_students_checked 
-- SET status = 'Suspended' 
-- WHERE student_id = 1;
-- ERROR: View CHECK OPTION failed!

-- =============================================================================
-- 4. Dropping Views Safely
-- =============================================================================

-- Drop view syntax:
DROP VIEW IF EXISTS v_active_cs_students;
DROP VIEW IF EXISTS v_active_cs_students_checked;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Why is 'v_department_kpi_summary' (from the previous file) NOT updatable?
-- Exercise 2: Create an updatable view for instructors in department 2 with WITH CHECK OPTION.
