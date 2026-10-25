/*
================================================================================
Topic: Subqueries: Scalar, IN, ANY / ALL and Derived Tables
Objective: Put one query inside another: compare rows with a single computed
           value, filter against a list of values, and query the result of a
           query.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A subquery is a SELECT written inside another statement, in brackets.
-- The inner query runs first; the outer query uses its result.
--
-- - Scalar subquery     : returns ONE value (1 row, 1 column).
--                         Use it wherever a single value is allowed.
-- - Multi-row subquery  : returns a LIST (1 column, many rows).
--                         Use it with IN, NOT IN, ANY, ALL.
-- - Derived table       : a subquery in FROM, used like a table.


-- =============================================================================
-- 2. Scalar Subquery in WHERE
-- =============================================================================
-- Lecturers earning more than the average lecturer salary (1,712,500 RWF)
SELECT first_name, last_name, monthly_salary
FROM lecturers
WHERE monthly_salary > (SELECT AVG(monthly_salary)
                        FROM lecturers)
ORDER BY monthly_salary DESC;                     -- 4 rows

-- The best course result in the whole university
SELECT student_id, course_code, academic_year, final_percent
FROM final_grades
WHERE final_percent = (SELECT MAX(final_percent)
                       FROM final_grades);        -- Jean, CS101, 91.67

-- The highest GPA: a subquery returns ALL tied students (LIMIT 1 would not)
SELECT student_name, gpa
FROM student_gpa
WHERE gpa = (SELECT MAX(gpa) FROM student_gpa);   -- 3 students with 4.00

-- A scalar subquery must return exactly one row. This FAILS:
-- SELECT first_name FROM lecturers
-- WHERE monthly_salary > (SELECT monthly_salary FROM lecturers WHERE department_id = 1);
-- Expected: ERROR: more than one row returned by a subquery used as an expression


-- =============================================================================
-- 3. Scalar Subquery in SELECT
-- =============================================================================
-- Each lecturer's salary compared with the average
SELECT
    first_name,
    last_name,
    monthly_salary,
    (SELECT ROUND(AVG(monthly_salary), 0) FROM lecturers)                 AS average_salary,
    monthly_salary - (SELECT ROUND(AVG(monthly_salary), 0) FROM lecturers) AS difference
FROM lecturers
ORDER BY difference DESC;


-- =============================================================================
-- 4. Multi-Row Subqueries with IN and NOT IN
-- =============================================================================

-- Students who have at least one enrollment
SELECT registration_no, first_name, last_name
FROM students
WHERE student_id IN (SELECT student_id
                     FROM enrollments)
ORDER BY registration_no;                         -- 13 rows (not Alice, not Belinda)

-- Courses that have never been offered
SELECT course_code, course_title
FROM courses
WHERE course_id NOT IN (SELECT course_id
                        FROM course_offerings);   -- CS401
-- Safe here because course_offerings.course_id is NOT NULL.
-- Remember the NOT IN + NULL trap from module 04, file 04!

-- Subqueries can be nested. Students taught by Claudine Mukamana in any term,
-- found by her email only (no IDs typed by hand):
SELECT registration_no, first_name, last_name
FROM students
WHERE student_id IN (
    SELECT student_id
    FROM enrollments
    WHERE offering_id IN (
        SELECT offering_id
        FROM course_offerings
        WHERE lecturer_id = (
            SELECT lecturer_id
            FROM lecturers
            WHERE email = 'c.mukamana@uni.example')))
ORDER BY registration_no;                         -- 7 students
-- (Module 07's joins often express this more clearly.)


-- =============================================================================
-- 5. ANY and ALL
-- =============================================================================
-- Salaries in department 3 are 900,000 and 1,750,000.

-- > ANY : greater than AT LEAST ONE value in the list (> the smallest)
SELECT first_name, last_name, monthly_salary
FROM lecturers
WHERE monthly_salary > ANY (SELECT monthly_salary
                            FROM lecturers
                            WHERE department_id = 3)
ORDER BY monthly_salary;                          -- 7 rows: everyone above 900,000

-- > ALL : greater than EVERY value in the list (> the largest)
SELECT first_name, last_name, monthly_salary
FROM lecturers
WHERE monthly_salary > ALL (SELECT monthly_salary
                            FROM lecturers
                            WHERE department_id = 3)
ORDER BY monthly_salary;                          -- 3 rows: above 1,750,000

-- Note: "= ANY (list)" means the same as "IN (list)".


-- =============================================================================
-- 6. Derived Tables: a Subquery in FROM
-- =============================================================================
-- Average class size. Step 1 (inside): students per offering.
-- Step 2 (outside): the average of those counts.
SELECT
    ROUND(AVG(class_size), 1) AS average_class_size,
    MAX(class_size)           AS largest_class
FROM (
    SELECT offering_id, COUNT(*) AS class_size
    FROM enrollments
    WHERE status <> 'Dropped'
    GROUP BY offering_id
) AS class_sizes;                                 -- the derived table needs an alias
-- A CTE (file 03) gives this inner query a name and puts it first.


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Find courses worth more credits than the average course.
-- Exercise 2: Find students in student_gpa whose GPA is below the average GPA.
-- Exercise 3: Find lecturers who are NOT heads of department (NOT IN on
--             department_heads.lecturer_id).
-- Exercise 4: Find payments larger than ALL payments made by Mobile Money.
