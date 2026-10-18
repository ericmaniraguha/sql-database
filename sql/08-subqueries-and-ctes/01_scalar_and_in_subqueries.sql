/*
================================================================================
Topic: Scalar and Multi-Row Subqueries
Objective: Nest queries inside SELECT and WHERE clauses, comparing row values 
           against scalar aggregates and list sets (IN, ANY, ALL).
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A subquery (or inner query) is a SELECT statement nested inside another SQL statement.
-- - Scalar Subquery: Returns exactly one row and one column (a single value).
-- - Multi-Row Subquery: Returns one column with multiple rows (a list of values).
-- - Subquery in SELECT: Evaluates an independent value for each output row.
-- - Subquery in WHERE: Filters rows based on the result of another query.

-- =============================================================================
-- 2. Scalar Subquery in WHERE Clause
-- =============================================================================

-- Find all instructors who earn more than the university-wide average instructor salary
SELECT 
    instructor_id,
    first_name,
    last_name,
    salary
FROM instructors
WHERE salary > (
    SELECT AVG(salary) 
    FROM instructors
)
ORDER BY salary DESC;

-- Find the student(s) with the highest GPA in the entire university
SELECT 
    student_id,
    first_name,
    last_name,
    gpa
FROM students
WHERE gpa = (
    SELECT MAX(gpa) 
    FROM students
);

-- =============================================================================
-- 3. Scalar Subquery in SELECT Clause
-- =============================================================================

-- Compare each instructor's salary with the overall university average
SELECT 
    first_name,
    last_name,
    salary,
    ROUND((SELECT AVG(salary) FROM instructors), 2) AS overall_avg_salary,
    ROUND(salary - (SELECT AVG(salary) FROM instructors), 2) AS salary_difference
FROM instructors;

-- =============================================================================
-- 4. Multi-Row Subqueries: IN and NOT IN
-- =============================================================================

-- Find all students who are enrolled in at least one course
SELECT student_id, first_name, last_name, email
FROM students
WHERE student_id IN (
    SELECT DISTINCT student_id 
    FROM enrollments
);

-- Find all departments that have NO assigned courses
SELECT department_id, department_name
FROM departments
WHERE department_id NOT IN (
    SELECT DISTINCT department_id 
    FROM courses
);

-- =============================================================================
-- 5. Subqueries with ANY and ALL
-- =============================================================================

-- Find instructors whose salary is greater than ANY instructor in department 2
-- (i.e. greater than the minimum salary in department 2)
SELECT first_name, last_name, salary
FROM instructors
WHERE salary > ANY (
    SELECT salary 
    FROM instructors 
    WHERE department_id = 2
);

-- Find instructors whose salary is greater than ALL instructors in department 2
-- (i.e. greater than the maximum salary in department 2)
SELECT first_name, last_name, salary
FROM instructors
WHERE salary > ALL (
    SELECT salary 
    FROM instructors 
    WHERE department_id = 2
);

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Find all courses whose credits are greater than the average credit of all courses.
-- Exercise 2: Find all students whose GPA is lower than the average GPA of students in department 1.
