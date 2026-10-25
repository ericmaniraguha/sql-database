/*
================================================================================
Topic: Sorting Results and Pagination
Objective: Sort with ORDER BY on one or more columns and expressions, control
           where NULLs go, and return pages of results with LIMIT / OFFSET
           and FETCH FIRST.
Database: PostgreSQL (pgAdmin)
          MySQL: LIMIT / OFFSET only (no FETCH, no NULLS FIRST/LAST)
          Oracle 12c+: OFFSET / FETCH only (no LIMIT)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A table has NO built-in row order. Without ORDER BY the database may return
-- rows in any order, and that order can change from one run to the next.
--   ASC  : smallest first, A-Z, earliest date first (the default)
--   DESC : largest first, Z-A, latest date first


-- =============================================================================
-- 2. Sorting on One Column
-- =============================================================================

-- Best course results first
SELECT student_id, course_code, final_percent, letter_grade
FROM final_grades
ORDER BY final_percent DESC;

-- Lecturers alphabetically by last name (ASC is optional)
SELECT first_name, last_name, academic_rank
FROM lecturers
ORDER BY last_name ASC;

-- Terms in calendar order. Never sort terms by term_id: IDs follow the order
-- rows were INSERTED, and term 2 is actually the earliest term.
SELECT term_id, academic_year, term_name, start_date
FROM academic_terms
ORDER BY start_date;                                    -- term_id 2, 1, 3


-- =============================================================================
-- 3. Sorting on Several Columns
-- =============================================================================
-- Rows are sorted by the first column; ties are broken by the next one.

-- Students by programme, then by last name inside each programme
SELECT program_id, last_name, first_name
FROM students
ORDER BY program_id ASC, last_name ASC;

-- Each column has its own direction: newest admissions first, then A-Z
SELECT admission_year, last_name, first_name
FROM students
ORDER BY admission_year DESC, last_name ASC;


-- =============================================================================
-- 4. Sorting on an Expression or an Alias
-- =============================================================================

-- Net salary is calculated, not stored. ORDER BY may use the SELECT alias:
SELECT l.first_name, l.last_name,
       sp.gross_amount - sp.tax_amount - sp.other_deductions AS net_pay
FROM salary_payments sp
JOIN lecturers l ON l.lecturer_id = sp.lecturer_id
WHERE sp.pay_month = '2026-10'
ORDER BY net_pay DESC;
-- (JOIN is explained in module 07; here it just adds the lecturer's name.)


-- =============================================================================
-- 5. Where Do NULLs Go?
-- =============================================================================
-- PostgreSQL / Oracle: NULLs sort as if LARGER than any value
--   -> last with ASC, first with DESC.
-- MySQL: the opposite (NULLs first with ASC).

SELECT department_name, building
FROM departments
ORDER BY building;                                      -- Economics (NULL) last

-- Choose explicitly with NULLS FIRST / NULLS LAST (PostgreSQL, Oracle):
SELECT department_name, building
FROM departments
ORDER BY building NULLS FIRST;                          -- Economics first

-- Portable alternative (also works in MySQL): sort on "is it NULL?" first
SELECT department_name, building
FROM departments
ORDER BY (building IS NULL) DESC, building;             -- TRUE (NULL) rows first


-- =============================================================================
-- 6. Top-N Queries with LIMIT
-- =============================================================================

-- The 3 highest-paid lecturers
SELECT first_name, last_name, monthly_salary
FROM lecturers
ORDER BY monthly_salary DESC
LIMIT 3;                                                -- Esther, Joseph, Claudine

-- The TIES trap: 3 students share the top GPA of 4.00.
-- "Top 2 by GPA" returns 2 of them, and WHICH 2 is not defined:
SELECT student_name, gpa
FROM student_gpa
ORDER BY gpa DESC
LIMIT 2;

-- FETCH FIRST ... WITH TIES (PostgreSQL 13+, Oracle) also returns every row
-- that ties with the last one:
SELECT student_name, gpa
FROM student_gpa
ORDER BY gpa DESC
FETCH FIRST 2 ROWS WITH TIES;                           -- 3 rows


-- =============================================================================
-- 7. Pagination with LIMIT and OFFSET
-- =============================================================================
-- Page n (page size s):  LIMIT s OFFSET (n - 1) * s
-- ALWAYS sort on something unique (here registration_no), otherwise rows can
-- appear on two pages or on none.

-- Page 1 of the student list, 5 per page
SELECT registration_no, first_name, last_name
FROM students
ORDER BY registration_no
LIMIT 5 OFFSET 0;

-- Page 2
SELECT registration_no, first_name, last_name
FROM students
ORDER BY registration_no
LIMIT 5 OFFSET 5;

-- MySQL also accepts the short form:  LIMIT 5, 5   (offset, count)


-- =============================================================================
-- 8. Standard SQL Pagination: OFFSET ... FETCH
-- =============================================================================
-- Works in PostgreSQL, Oracle 12c+ and SQL Server. Page 3:
SELECT registration_no, first_name, last_name
FROM students
ORDER BY registration_no
OFFSET 10 ROWS
FETCH NEXT 5 ROWS ONLY;


-- =============================================================================
-- 9. Practice Exercises
-- =============================================================================
-- Exercise 1: List the 2 lowest-paid lecturers.
-- Exercise 2: List courses with page size 4: write the queries for page 1 and page 3.
--             How many rows does page 3 return?
-- Exercise 3: List final_grades sorted by course_code, then by final_percent
--             from highest to lowest.
-- Exercise 4: List course offerings sorted by room with the NULL room first.
