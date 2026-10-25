/*
================================================================================
Topic: Self Joins
Objective: Join a table to itself with two aliases to follow hierarchies
           (head of department, course prerequisites), compare rows of the
           same table, and find pairs.
Database: PostgreSQL (pgAdmin)
          MySQL: use CONCAT() instead of || ; otherwise identical
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A SELF JOIN is an ordinary join where both sides are the SAME table.
-- Aliases are compulsory: they give the two copies different names and roles,
-- e.g.  lecturers staff  vs.  lecturers head.


-- =============================================================================
-- 2. Each Lecturer and Their Head of Department
-- =============================================================================
-- Path: lecturer -> their department's head row -> the head's lecturer row
SELECT
    staff.first_name || ' ' || staff.last_name AS lecturer,
    staff.department_id,
    COALESCE(head.first_name || ' ' || head.last_name, '(no head)') AS head_of_department
FROM lecturers staff
LEFT JOIN department_heads h ON h.department_id = staff.department_id
LEFT JOIN lecturers head     ON head.lecturer_id = h.lecturer_id
ORDER BY staff.department_id, staff.last_name;
-- LEFT JOIN keeps departments 3 and 4, which have no head.

-- Compare the two copies: lecturers who earn MORE than their own head
SELECT
    staff.first_name || ' ' || staff.last_name AS lecturer,
    staff.monthly_salary                       AS lecturer_salary,
    head.first_name  || ' ' || head.last_name  AS head_of_department,
    head.monthly_salary                        AS head_salary
FROM lecturers staff
JOIN department_heads h ON h.department_id = staff.department_id
JOIN lecturers head     ON head.lecturer_id = h.lecturer_id
WHERE staff.monthly_salary > head.monthly_salary;   -- Esther earns more than Joseph


-- =============================================================================
-- 3. Course Prerequisites: courses -> course_prerequisites -> courses
-- =============================================================================
-- course_prerequisites stores two course IDs per row, so courses is joined twice.
SELECT
    c.course_code     AS course,
    c.course_title,
    pre.course_code   AS requires,
    pre.course_title  AS requires_title
FROM courses c
JOIN course_prerequisites cp ON cp.course_id = c.course_id
JOIN courses pre             ON pre.course_id = cp.prerequisite_course_id
ORDER BY c.course_code, pre.course_code;          -- 6 rows

-- Two levels deep: the prerequisite of the prerequisite
SELECT
    c.course_code    AS course,
    pre1.course_code AS requires,
    pre2.course_code AS which_requires
FROM courses c
JOIN course_prerequisites cp1 ON cp1.course_id = c.course_id
JOIN courses pre1             ON pre1.course_id = cp1.prerequisite_course_id
JOIN course_prerequisites cp2 ON cp2.course_id = pre1.course_id
JOIN courses pre2             ON pre2.course_id = cp2.prerequisite_course_id
ORDER BY c.course_code;
-- Each extra level needs two more joins. For a chain of unknown depth, use a
-- RECURSIVE CTE instead (module 08, file 04).


-- =============================================================================
-- 4. Comparing Two Rows of the Same Table: Salary This Month vs. Last Month
-- =============================================================================
SELECT
    l.first_name || ' ' || l.last_name AS lecturer,
    sep.gross_amount                   AS september,
    oct.gross_amount                   AS october,
    oct.gross_amount - sep.gross_amount AS change
FROM salary_payments sep
JOIN salary_payments oct ON oct.lecturer_id = sep.lecturer_id
                        AND oct.pay_month   = '2026-10'
JOIN lecturers l         ON l.lecturer_id   = sep.lecturer_id
WHERE sep.pay_month = '2026-09'
ORDER BY change DESC, lecturer;                   -- Olivier: +150,000 overtime
-- Module 11 shows a shorter way with the LAG() window function.


-- =============================================================================
-- 5. Finding Pairs
-- =============================================================================
-- Pairs of students in the same programme.
-- "s1.student_id < s2.student_id" removes self-pairs (Aline-Aline) and
-- mirror pairs (Jean-Aline after Aline-Jean).
SELECT
    s1.program_id,
    s1.first_name AS student_1,
    s2.first_name AS student_2
FROM students s1
JOIN students s2
    ON  s2.program_id = s1.program_id
    AND s1.student_id < s2.student_id
WHERE s1.program_id = 2                           -- Mathematics: 3 students -> 3 pairs
ORDER BY s1.student_id, s2.student_id;

-- Students admitted in the same year as Aline Uwase (excluding Aline)
SELECT
    other.registration_no,
    other.first_name,
    other.last_name
FROM students aline
JOIN students other
    ON  other.admission_year = aline.admission_year
    AND other.student_id    <> aline.student_id
WHERE aline.registration_no = '2024CS001';        -- Grace, Kevin, Thierry


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Find pairs of lecturers who have the same academic rank.
-- Exercise 2: Which courses have more than one prerequisite? (Self join plus
--             GROUP BY / HAVING.)
-- Exercise 3: List lecturers hired BEFORE their head of department.
-- Exercise 4: Find pairs of students born in the same month.
