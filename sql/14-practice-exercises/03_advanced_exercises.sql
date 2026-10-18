/*
================================================================================
Topic: Advanced Practice Exercises
Objective: Solve complex database problems using CTEs, Recursive Queries, Window 
           Functions, and ACID Transactions.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- -----------------------------------------------------------------------------
-- Exercise 1: Window Functions (DENSE_RANK & Partitioning)
-- -----------------------------------------------------------------------------
-- Task: For each department, rank all students based on their GPA (highest GPA = 1).
--       Ensure ties share the same rank without skipping numbers (DENSE_RANK).
--       Filter the results to show ONLY the top 2 ranked students per department.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
WITH RankedStudents AS (
    SELECT 
        student_id,
        department_id,
        first_name,
        last_name,
        gpa,
        DENSE_RANK() OVER (
            PARTITION BY department_id 
            ORDER BY gpa DESC
        ) AS rank_in_dept
    FROM students
)
SELECT 
    department_id,
    student_id,
    CONCAT(first_name, ' ', last_name) AS student_name,
    gpa,
    rank_in_dept
FROM RankedStudents
WHERE rank_in_dept <= 2
ORDER BY department_id, rank_in_dept;
*/

-- -----------------------------------------------------------------------------
-- Exercise 2: Analytical Navigation with LAG
-- -----------------------------------------------------------------------------
-- Task: List all instructors ordered by hire_date. For each instructor, show their 
--       salary, the salary of the instructor hired immediately before them, and 
--       the difference between the two salaries.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT 
    instructor_id,
    CONCAT(first_name, ' ', last_name) AS instructor_name,
    hire_date,
    salary,
    LAG(salary) OVER (ORDER BY hire_date ASC) AS prev_instructor_salary,
    salary - LAG(salary) OVER (ORDER BY hire_date ASC) AS salary_difference
FROM instructors
ORDER BY hire_date;
*/

-- -----------------------------------------------------------------------------
-- Exercise 3: Cumulative Running Total with Window Framing
-- -----------------------------------------------------------------------------
-- Task: Calculate a running total of department budget allocations ordered by established_year.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
SELECT 
    department_id,
    department_name,
    established_year,
    budget,
    SUM(budget) OVER (
        ORDER BY established_year ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_budget_total
FROM departments
ORDER BY established_year;
*/

-- -----------------------------------------------------------------------------
-- Exercise 4: Recursive CTE Prerequisite Discovery
-- -----------------------------------------------------------------------------
-- Task: Write a recursive CTE that finds all direct and indirect prerequisites 
--       for course_id = 3 (CS301). Output the prerequisite course code and depth.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
WITH RECURSIVE CoursePrereqs AS (
    SELECT 
        cp.course_id,
        cp.prerequisite_course_id,
        1 AS depth_level
    FROM course_prerequisites cp
    WHERE cp.course_id = 3
    
    UNION ALL
    
    SELECT 
        child.course_id,
        parent.prerequisite_course_id,
        child.depth_level + 1
    FROM CoursePrereqs child
    INNER JOIN course_prerequisites parent 
        ON child.prerequisite_course_id = parent.course_id
)
SELECT 
    c.course_code AS prerequisite_code,
    c.course_name AS prerequisite_name,
    cp.depth_level
FROM CoursePrereqs cp
INNER JOIN courses c ON cp.prerequisite_course_id = c.course_id;
*/

-- -----------------------------------------------------------------------------
-- Exercise 5: Atomic Transaction with Error Handling
-- -----------------------------------------------------------------------------
-- Task: Write a transaction that transfers 1 credit from course CS101 to course CS201.
--       Include a verification check and ensure the transaction can commit or roll back.

-- YOUR QUERY HERE:



-- Sample Solution:
/*
START TRANSACTION;

UPDATE courses SET credits = credits - 1 WHERE course_code = 'CS101';
UPDATE courses SET credits = credits + 1 WHERE course_code = 'CS201';

-- Verification:
SELECT course_code, credits FROM courses WHERE course_code IN ('CS101', 'CS201');

COMMIT;
*/
