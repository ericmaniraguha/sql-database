/*
================================================================================
Topic: Creating Database Views
Objective: Create virtual tables to simplify complex joins, provide data security 
           by hiding sensitive columns, and present consistent reporting interfaces.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A VIEW is a virtual table whose contents are defined by an underlying SELECT query.
-- Views do not store physical data rows on disk (unlike tables). Instead, whenever
-- a view is queried, the database executes the view's definition query.
--
-- Key Benefits:
-- - Simplicity: Encapsulates complex joins, aggregations, and business logic.
-- - Security: Restricts user access to specific columns (e.g. hiding salaries).
-- - Consistency: Ensures all developers and analysts use identical definitions.

-- =============================================================================
-- 2. View 1: Student Public Directory (Security & Column Masking)
-- =============================================================================
-- Exposes student contact and academic standing without revealing sensitive birth dates:

CREATE OR REPLACE VIEW v_student_directory AS
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.email,
    d.department_name,
    s.status
FROM students s
INNER JOIN departments d 
    ON s.department_id = d.department_id;

-- Querying the view just like a physical table:
SELECT * 
FROM v_student_directory 
WHERE status = 'Active';

-- =============================================================================
-- 3. View 2: Complete Course Roster with Instructor Information
-- =============================================================================

CREATE OR REPLACE VIEW v_course_catalog AS
SELECT 
    c.course_id,
    c.course_code,
    c.course_name,
    c.credits,
    d.department_name,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name,
    i.email AS instructor_email
FROM courses c
INNER JOIN departments d 
    ON c.department_id = d.department_id
LEFT JOIN instructors i 
    ON c.instructor_id = i.instructor_id;

-- Query the catalog view:
SELECT course_code, course_name, instructor_name 
FROM v_course_catalog 
ORDER BY course_code;

-- =============================================================================
-- 4. View 3: Department Academic Summary (Pre-aggregated Metrics)
-- =============================================================================

CREATE OR REPLACE VIEW v_department_kpi_summary AS
SELECT 
    d.department_id,
    d.department_code,
    d.department_name,
    COUNT(DISTINCT s.student_id)    AS total_students,
    COUNT(DISTINCT i.instructor_id) AS total_instructors,
    COUNT(DISTINCT c.course_id)     AS total_courses,
    ROUND(AVG(s.gpa), 2)            AS avg_student_gpa
FROM departments d
LEFT JOIN students s 
    ON d.department_id = s.department_id
LEFT JOIN instructors i 
    ON d.department_id = i.department_id
LEFT JOIN courses c 
    ON d.department_id = c.department_id
GROUP BY d.department_id, d.department_code, d.department_name;

-- Query KPIs:
SELECT * 
FROM v_department_kpi_summary;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Create a view named 'v_dean_honor_roll' listing student ID, name, 
--             department name, and GPA for all students with GPA >= 3.75.
-- Exercise 2: Why are standard views called "virtual" tables?
