/*
================================================================================
Topic: Preserving Unmatched Rows with LEFT JOIN
Objective: Retrieve all records from the left table regardless of matches, and 
           identify missing or orphaned relationships using anti-join patterns.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A LEFT JOIN (or LEFT OUTER JOIN) returns ALL rows from the left table.
-- If a match is found in the right table, columns are populated.
-- If NO match is found in the right table, the right table columns return NULL.
--
-- Essential Pattern: Anti-Join
-- Adding "WHERE right_table.primary_key IS NULL" filters for records in the left
-- table that have ZERO matches in the right table!

-- =============================================================================
-- 2. Basic LEFT JOIN: All Departments and Their Instructors
-- =============================================================================

SELECT 
    d.department_id,
    d.department_name,
    i.instructor_id,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name,
    i.academic_rank
FROM departments d
LEFT JOIN instructors i 
    ON d.department_id = i.department_id
ORDER BY d.department_id;

-- =============================================================================
-- 3. All Students and Their Enrollments (Including Unenrolled Students)
-- =============================================================================

SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.status,
    e.course_id,
    e.letter_grade
FROM students s
LEFT JOIN enrollments e 
    ON s.student_id = e.student_id
ORDER BY s.student_id;

-- =============================================================================
-- 4. The Anti-Join Pattern: Finding Records with No Matches
-- =============================================================================

-- Find all students who have NEVER enrolled in any course
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.email,
    s.status
FROM students s
LEFT JOIN enrollments e 
    ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL; -- Anti-join condition!

-- Find courses that have zero student enrollments
SELECT 
    c.course_id,
    c.course_code,
    c.course_name
FROM courses c
LEFT JOIN enrollments e 
    ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;

-- =============================================================================
-- 5. LEFT JOIN with Aggregation: Counting with Zero Representation
-- =============================================================================

-- Notice: COUNT(e.enrollment_id) returns 0 for students with no enrollments, 
-- whereas COUNT(*) would incorrectly return 1 because the student row exists!
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    COUNT(e.enrollment_id) AS total_courses_enrolled
FROM students s
LEFT JOIN enrollments e 
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY total_courses_enrolled DESC;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Find all instructors who are not currently assigned to teach any course.
-- Exercise 2: List every department along with the count of instructors hired, 
--             ensuring departments with 0 instructors show 0 (not NULL).
