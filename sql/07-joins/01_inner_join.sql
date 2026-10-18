/*
================================================================================
Topic: Combining Tables with INNER JOIN
Objective: Link related tables using foreign keys and primary keys to retrieve 
           matched records across normalized relational structures.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- An INNER JOIN matches rows from two or more tables based on a join condition (ON).
-- Rows are included in the result set ONLY if the condition evaluates to TRUE
-- in both tables. If a row in table A has no corresponding match in table B,
-- it is excluded from the output.

-- =============================================================================
-- 2. Two-Table INNER JOIN: Students & Departments
-- =============================================================================

SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.email,
    d.department_code,
    d.department_name
FROM students s
INNER JOIN departments d 
    ON s.department_id = d.department_id
ORDER BY s.student_id;

-- =============================================================================
-- 3. Two-Table INNER JOIN: Courses & Instructors
-- =============================================================================

SELECT 
    c.course_code,
    c.course_name,
    c.credits,
    i.first_name AS instructor_first_name,
    i.last_name  AS instructor_last_name,
    i.email      AS instructor_email
FROM courses c
INNER JOIN instructors i 
    ON c.instructor_id = i.instructor_id;

-- =============================================================================
-- 4. Multi-Table Join: 4 Tables (Students -> Enrollments -> Courses -> Instructors)
-- =============================================================================
-- Complete transcript view: Student, Course, Instructor, and Final Grade:

SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    c.course_code,
    c.course_name,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name,
    e.semester,
    e.academic_year,
    e.numeric_grade,
    e.letter_grade
FROM students s
INNER JOIN enrollments e 
    ON s.student_id = e.student_id
INNER JOIN courses c 
    ON e.course_id = c.course_id
INNER JOIN instructors i 
    ON c.instructor_id = i.instructor_id
ORDER BY s.student_id, e.academic_year, e.semester;

-- =============================================================================
-- 5. INNER JOIN with Aggregation
-- =============================================================================

-- Total enrolled students per department
SELECT 
    d.department_name,
    COUNT(s.student_id) AS enrolled_students,
    ROUND(AVG(s.gpa), 2) AS dept_average_gpa
FROM departments d
INNER JOIN students s 
    ON d.department_id = s.department_id
GROUP BY d.department_id, d.department_name
ORDER BY enrolled_students DESC;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Write an INNER JOIN between courses and departments to show course title, 
--             credits, and department building.
-- Exercise 2: List all students who enrolled in 'CS101' with their letter grade.
