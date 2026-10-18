/*
================================================================================
Topic: Beginner Practice Exercises
Objective: Practice fundamental SQL querying, row filtering, sorting, basic math, 
           and CRUD operations on the university database.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- INSTRUCTIONS FOR STUDENTS:
-- 1. Read each exercise prompt carefully.
-- 2. Write your SQL solution directly beneath the prompt.
-- 3. Execute your query and compare your result with the sample solution.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Exercise 1: Basic Column Projection & Renaming
-- -----------------------------------------------------------------------------
-- Task: Retrieve the first name, last name, and email address of all instructors.
--       Alias the columns as "First Name", "Last Name", and "Email Address".

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT 
    first_name AS "First Name",
    last_name  AS "Last Name",
    email      AS "Email Address"
FROM instructors;
*/

-- -----------------------------------------------------------------------------
-- Exercise 2: Filtering with WHERE and Comparison Operators
-- -----------------------------------------------------------------------------
-- Task: Retrieve all active students whose GPA is 3.50 or higher.
--       Sort the output by GPA descending.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT student_id, first_name, last_name, gpa, status
FROM students
WHERE status = 'Active' AND gpa >= 3.50
ORDER BY gpa DESC;
*/

-- -----------------------------------------------------------------------------
-- Exercise 3: Pattern Matching with LIKE
-- -----------------------------------------------------------------------------
-- Task: Find all courses where the course title contains the word 'Data' or 'Program'.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT course_id, course_code, course_name
FROM courses
WHERE course_name LIKE '%Data%' 
   OR course_name LIKE '%Program%';
*/

-- -----------------------------------------------------------------------------
-- Exercise 4: Range and List Filtering (BETWEEN and IN)
-- -----------------------------------------------------------------------------
-- Task: Find all instructors with salaries between $50,000 and $70,000 who are 
--       either 'Senior Lecturer' or 'Associate Professor'.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT instructor_id, first_name, last_name, salary, academic_rank
FROM instructors
WHERE (salary BETWEEN 50000.00 AND 70000.00)
  AND academic_rank IN ('Senior Lecturer', 'Associate Professor');
*/

-- -----------------------------------------------------------------------------
-- Exercise 5: Pagination with LIMIT / FETCH
-- -----------------------------------------------------------------------------
-- Task: Retrieve the top 3 courses with the highest credit values. 
--       In case of ties, sort alphabetically by course name.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT course_code, course_name, credits
FROM courses
ORDER BY credits DESC, course_name ASC
LIMIT 3;
*/
