/*
================================================================================
Topic: Intermediate Practice Exercises
Objective: Apply multi-table JOINs, aggregation with GROUP BY & HAVING, scalar/list 
           subqueries, and views to solve real-world university reporting tasks.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- -----------------------------------------------------------------------------
-- Exercise 1: Multi-Table INNER JOIN
-- -----------------------------------------------------------------------------
-- Task: Produce a course schedule report displaying:
--       Course Code, Course Name, Department Name, and Instructor's Full Name.
--       Only include courses that have an assigned instructor.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT 
    c.course_code,
    c.course_name,
    d.department_name,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name
FROM courses c
INNER JOIN departments d ON c.department_id = d.department_id
INNER JOIN instructors i ON c.instructor_id = i.instructor_id
ORDER BY c.course_code;
*/

-- -----------------------------------------------------------------------------
-- Exercise 2: LEFT JOIN with Anti-Join
-- -----------------------------------------------------------------------------
-- Task: Find all departments that currently have NO students enrolled in them.
--       Display Department Code and Department Name.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT 
    d.department_code,
    d.department_name
FROM departments d
LEFT JOIN students s ON d.department_id = s.department_id
WHERE s.student_id IS NULL;
*/

-- -----------------------------------------------------------------------------
-- Exercise 3: Aggregation with GROUP BY and HAVING
-- -----------------------------------------------------------------------------
-- Task: Find all departments that have at least 2 instructors and an average 
--       instructor salary greater than $55,000. Display department name, instructor 
--       count, and the rounded average salary.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT 
    d.department_name,
    COUNT(i.instructor_id) AS instructor_count,
    ROUND(AVG(i.salary), 2) AS average_salary
FROM departments d
INNER JOIN instructors i ON d.department_id = i.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(i.instructor_id) >= 2 
   AND AVG(i.salary) > 55000.00
ORDER BY average_salary DESC;
*/

-- -----------------------------------------------------------------------------
-- Exercise 4: Correlated Subquery
-- -----------------------------------------------------------------------------
-- Task: Find all students who have a GPA higher than the average GPA of students 
--       in their own respective department.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.department_id,
    s.gpa
FROM students s
WHERE s.gpa > (
    SELECT AVG(dept_s.gpa)
    FROM students dept_s
    WHERE dept_s.department_id = s.department_id
)
ORDER BY s.department_id, s.gpa DESC;
*/

-- -----------------------------------------------------------------------------
-- Exercise 5: Creating an Analytical View
-- -----------------------------------------------------------------------------
-- Task: Create a view named 'v_course_enrollment_stats' that displays course_code, 
--       course_name, total students enrolled, and the average numeric grade.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
CREATE OR REPLACE VIEW v_course_enrollment_stats AS
SELECT 
    c.course_code,
    c.course_name,
    COUNT(e.enrollment_id)         AS total_enrolled,
    ROUND(AVG(e.numeric_grade), 2) AS average_grade
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_name;
*/
