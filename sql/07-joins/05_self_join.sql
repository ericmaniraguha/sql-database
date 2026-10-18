/*
================================================================================
Topic: Self Joins and Hierarchical References
Objective: Join a table to itself using distinct aliases to model parent-child 
           hierarchies, prerequisite chains, and compare peer records.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A SELF JOIN is a regular join in which a table is joined with itself.
-- Table aliasing is MANDATORY in a self join to give the query engine distinct
-- names to differentiate between the two roles of the same table (e.g., employee & manager).

-- =============================================================================
-- 2. Setup Hierarchical Mentor Relationship
-- =============================================================================

-- Add mentor_id foreign key referencing instructor_id within instructors
ALTER TABLE instructors
ADD mentor_id INT;

ALTER TABLE instructors
ADD CONSTRAINT fk_instructors_mentor
FOREIGN KEY (mentor_id) REFERENCES instructors(instructor_id)
ON DELETE SET NULL;

-- Assign mentors
UPDATE instructors SET mentor_id = 1 WHERE instructor_id = 2; -- Habimana mentors Mukamana
UPDATE instructors SET mentor_id = 3 WHERE instructor_id = 4; -- Mugabo mentors Uwase
UPDATE instructors SET mentor_id = 1 WHERE instructor_id = 6; -- Habimana mentors Ingabire

-- =============================================================================
-- 3. Querying Hierarchies: Instructor and Assigned Mentor
-- =============================================================================

SELECT 
    junior.instructor_id,
    CONCAT(junior.first_name, ' ', junior.last_name) AS mentee_name,
    junior.academic_rank                            AS mentee_rank,
    COALESCE(CONCAT(senior.first_name, ' ', senior.last_name), 'No Mentor Assigned') AS mentor_name,
    senior.academic_rank                            AS mentor_rank
FROM instructors junior
LEFT JOIN instructors senior 
    ON junior.mentor_id = senior.instructor_id
ORDER BY junior.instructor_id;

-- =============================================================================
-- 4. Course Prerequisites via Self-Joining Courses
-- =============================================================================

-- Populate prerequisite sample data
INSERT INTO course_prerequisites (course_id, prerequisite_course_id, minimum_grade)
VALUES 
    (2, 1, 'B'),  -- CS201 requires CS101
    (3, 2, 'C'),  -- CS301 requires CS201
    (5, 4, 'C');  -- BA205 requires BA101

-- Self join through associative table:
SELECT 
    target_course.course_code AS course,
    target_course.course_name AS course_title,
    prereq_course.course_code AS prerequisite,
    prereq_course.course_name AS prerequisite_title,
    cp.minimum_grade          AS required_grade
FROM courses target_course
INNER JOIN course_prerequisites cp 
    ON target_course.course_id = cp.course_id
INNER JOIN courses prereq_course 
    ON cp.prerequisite_course_id = prereq_course.course_id
ORDER BY target_course.course_code;

-- =============================================================================
-- 5. Peer Row Comparisons: Students Sharing the Same Department
-- =============================================================================

-- Find pairs of different students enrolled in the same department
SELECT 
    s1.first_name AS student_1,
    s2.first_name AS student_2,
    s1.department_id
FROM students s1
INNER JOIN students s2 
    ON s1.department_id = s2.department_id
   AND s1.student_id < s2.student_id -- Avoid self-pairing and duplicate reverse pairs!
ORDER BY s1.department_id;

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Find all senior instructors who mentor 2 or more junior instructors.
-- Exercise 2: Find pairs of instructors who earn the exact same salary.
