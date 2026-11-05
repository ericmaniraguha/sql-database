/*
================================================================================
Topic: SQL Operators: Quick Reference
Objective: Know the operators used to build query conditions (comparison,
           logical, BETWEEN, IN, LIKE, IS NULL, ANY / ALL, EXISTS, the set
           operators and CASE) with one runnable example of each.
Database: PostgreSQL (pgAdmin)
          MySQL: INTERSECT and EXCEPT need MySQL 8.0.31+; no ILIKE
          Oracle: MINUS instead of EXCEPT (Oracle 21c+ also accepts EXCEPT)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- An operator is a symbol or keyword that compares, combines or transforms
-- values. Operators let you build conditions such as
--     WHERE status = 'Active' AND program_id IN (1, 2)
--
-- | Operator              | Category    | Purpose                                   | Example                                   | In depth  |
-- |-----------------------|-------------|-------------------------------------------|-------------------------------------------|-----------|
-- | = < > <= >=           | Comparison  | Compare two values                        | credits > 3                               | 04/02     |
-- | <> or != (NOT EQUAL)  | Comparison  | Value is different                        | status <> 'Active'                        | 04/02     |
-- | AND, OR               | Logical     | Combine conditions                        | program_id = 1 AND status = 'Active'      | 04/01     |
-- | NOT                   | Logical     | Reverse a condition                       | NOT (department_id = 1)                   | 04/01     |
-- | BETWEEN ... AND       | Range       | Value inside an inclusive range           | hire_date BETWEEN '2015-01-01' AND ...    | 04/02     |
-- | IN (...)              | Membership  | Value equals one in a list                | status IN ('Graduated', 'Withdrawn')      | 04/03     |
-- | LIKE / ILIKE          | Pattern     | Text matches a pattern (% and _)          | course_code LIKE 'CS%'                    | 04/03     |
-- | IS NULL / IS NOT NULL | NULL test   | Value is missing / present                | phone IS NULL                             | 04/04     |
-- | ANY / ALL             | Subquery    | Compare with every value a subquery gives | salary > ALL (SELECT ...)                 | 08/01     |
-- | EXISTS / NOT EXISTS   | Subquery    | Does the subquery return any row?         | EXISTS (SELECT 1 FROM ... WHERE ...)      | 13/02     |
-- | UNION / UNION ALL     | Set         | Stack two results (UNION drops repeats)   | query1 UNION query2                       | 13/01     |
-- | INTERSECT             | Set         | Rows found in BOTH results                | query1 INTERSECT query2                   | 13/01     |
-- | EXCEPT                | Set         | Rows in the first result, not the second  | query1 EXCEPT query2                      | 13/01     |
-- | CASE                  | Conditional | IF-THEN-ELSE that returns a value         | CASE WHEN ... THEN ... ELSE ... END       | 05/05     |
--
-- Precedence (what is evaluated first, unless you use brackets):
--   arithmetic (* / + -)  ->  comparison (= < > ...)  ->  NOT  ->  AND  ->  OR
-- When AND and OR appear together, ALWAYS add brackets (see section 3).


-- =============================================================================
-- 2. Comparison and NOT EQUAL: = < > <= >= <> !=
-- =============================================================================
-- Courses worth more than 3 credits
SELECT course_code, credits
FROM courses
WHERE credits > 3;                                      -- 4 rows

-- NOT EQUAL: <> is the SQL standard; != means the same in PostgreSQL and MySQL
SELECT registration_no, first_name, status
FROM students
WHERE status <> 'Active';                               -- 3 rows

-- Trap: a NULL is neither equal nor "not equal" to anything (module 04/04).
-- Samuel and Josiane (no phone) are missing from this result:
SELECT first_name, phone
FROM lecturers
WHERE phone <> '+250788000001';                         -- 5 rows, not 7


-- =============================================================================
-- 3. Logical: AND, OR, NOT
-- =============================================================================
-- AND: both conditions must be true
SELECT registration_no, first_name
FROM students
WHERE program_id = 1
  AND status = 'Active';                                -- 5 rows

-- OR: at least one condition must be true. Brackets keep OR inside the AND.
SELECT registration_no, first_name, program_id
FROM students
WHERE (program_id = 1 OR program_id = 2)
  AND status = 'Active';                                -- 8 rows

-- NOT: reverses the condition that follows
SELECT first_name, last_name, department_id
FROM lecturers
WHERE NOT (department_id = 1);                          -- 5 rows


-- =============================================================================
-- 4. BETWEEN ... AND (both ends included)
-- =============================================================================
SELECT first_name, last_name, hire_date
FROM lecturers
WHERE hire_date BETWEEN '2015-01-01' AND '2020-12-31'
ORDER BY hire_date;                                     -- 4 rows: 2015 to 2020

-- NOT BETWEEN: outside the range
SELECT first_name, monthly_salary
FROM lecturers
WHERE monthly_salary NOT BETWEEN 1000000 AND 2000000;   -- 3 rows


-- =============================================================================
-- 5. IN and NOT IN
-- =============================================================================
SELECT registration_no, first_name, status
FROM students
WHERE status IN ('Graduated', 'Suspended', 'Withdrawn');   -- 3 rows

SELECT registration_no, first_name, program_id
FROM students
WHERE program_id NOT IN (1, 2);                             -- 5 rows


-- =============================================================================
-- 6. LIKE and ILIKE (% = any characters, _ = exactly one character)
-- =============================================================================
SELECT course_code, course_title
FROM courses
WHERE course_code LIKE 'CS%';                           -- 4 rows

SELECT course_code, course_title
FROM courses
WHERE course_title ILIKE '%data%';                      -- 4 rows (ILIKE ignores case)


-- =============================================================================
-- 7. IS NULL and IS NOT NULL
-- =============================================================================
-- Never write "= NULL": it is never true. Use IS NULL.
SELECT first_name, last_name
FROM lecturers
WHERE phone IS NULL;                                    -- 2 rows: Samuel, Josiane

SELECT offering_id, room
FROM course_offerings
WHERE room IS NOT NULL;                                 -- 9 rows


-- =============================================================================
-- 8. ANY and ALL (compare with a list of values from a subquery)
-- =============================================================================
-- Salaries in department 3 are 900,000 and 1,750,000.
-- > ANY : greater than at least ONE of them (more than 900,000)
SELECT first_name, monthly_salary
FROM lecturers
WHERE monthly_salary > ANY (SELECT monthly_salary FROM lecturers
                            WHERE department_id = 3);   -- 7 rows

-- > ALL : greater than EVERY one of them (more than 1,750,000)
SELECT first_name, monthly_salary
FROM lecturers
WHERE monthly_salary > ALL (SELECT monthly_salary FROM lecturers
                            WHERE department_id = 3);   -- 3 rows


-- =============================================================================
-- 9. EXISTS and NOT EXISTS (does the subquery find at least one row?)
-- =============================================================================
-- Courses that have been offered in at least one term
SELECT c.course_code, c.course_title
FROM courses c
WHERE EXISTS (SELECT 1
              FROM course_offerings o
              WHERE o.course_id = c.course_id);         -- 8 rows

-- Courses never offered
SELECT c.course_code, c.course_title
FROM courses c
WHERE NOT EXISTS (SELECT 1
                  FROM course_offerings o
                  WHERE o.course_id = c.course_id);     -- 1 row: CS401


-- =============================================================================
-- 10. Set Operators: UNION, UNION ALL, INTERSECT, EXCEPT
-- =============================================================================
-- Set operators combine the RESULTS of two queries (not the columns).
-- Rules:
--   * both queries return the same number of columns, with compatible types;
--   * the column names come from the FIRST query;
--   * one ORDER BY at the very end sorts the combined result.

-- UNION ALL keeps every row; UNION removes repeated rows.
-- Departments that have courses, together with departments that have lecturers:
SELECT department_id FROM courses
UNION ALL
SELECT department_id FROM lecturers;                    -- 17 rows (9 + 8)

SELECT department_id FROM courses
UNION
SELECT department_id FROM lecturers
ORDER BY department_id;                                 -- 4 rows: 1, 2, 3, 4

-- A practical UNION ALL: one contact list of students and lecturers
SELECT first_name, last_name, email, 'Student' AS role FROM students
UNION ALL
SELECT first_name, last_name, email, 'Lecturer'        FROM lecturers
ORDER BY role, last_name;                               -- 23 rows

-- INTERSECT: students enrolled in BOTH the previous term (2) and this term (1)
SELECT e.student_id
FROM enrollments e
JOIN course_offerings o ON o.offering_id = e.offering_id
WHERE o.term_id = 2
INTERSECT
SELECT e.student_id
FROM enrollments e
JOIN course_offerings o ON o.offering_id = e.offering_id
WHERE o.term_id = 1
ORDER BY student_id;                                    -- 6 rows: 4, 5, 6, 7, 8, 10

-- EXCEPT: students billed for this term who are NOT enrolled in any course
SELECT student_id FROM invoices WHERE term_id = 1
EXCEPT
SELECT e.student_id
FROM enrollments e
JOIN course_offerings o ON o.offering_id = e.offering_id
WHERE o.term_id = 1;                                    -- 1 row: 15 (Belinda)
-- Oracle before 21c: write MINUS instead of EXCEPT.


-- =============================================================================
-- 11. CASE (conditional expression)
-- =============================================================================
SELECT
    first_name,
    monthly_salary,
    CASE
        WHEN monthly_salary >= 2000000 THEN 'Senior band'
        WHEN monthly_salary >= 1200000 THEN 'Middle band'
        ELSE 'Junior band'
    END AS salary_band
FROM lecturers
ORDER BY monthly_salary DESC;                           -- 8 rows


-- =============================================================================
-- 12. Putting Operators Together
-- =============================================================================
-- Active students in Computer Science or Mathematics, admitted from 2023,
-- whose phone number is known and whose last name does not start with 'M'
SELECT registration_no, first_name, last_name, program_id, admission_year
FROM students
WHERE status = 'Active'
  AND program_id IN (1, 2)
  AND admission_year >= 2023
  AND phone IS NOT NULL
  AND NOT (last_name LIKE 'M%')
ORDER BY registration_no;                               -- 4 rows: Aline, Grace, Diane, Belinda


-- =============================================================================
-- 13. Practice Exercises
-- =============================================================================
-- Exercise 1: List payments that are NOT 'Cash' and have an amount BETWEEN
--             100,000 and 500,000 RWF.
-- Exercise 2: List lecturers whose rank is IN ('Lecturer', 'Senior Lecturer')
--             and whose phone IS NOT NULL.
-- Exercise 3: Use EXCEPT to find programmes (program_id) that have no students.
-- Exercise 4: Use UNION to list every term_id that appears in course_offerings
--             or in invoices. How many rows does UNION ALL give instead?
