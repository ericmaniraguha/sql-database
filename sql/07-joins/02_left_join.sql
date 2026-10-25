/*
================================================================================
Topic: Preserving Unmatched Rows with LEFT JOIN
Objective: Retrieve all records from the left table regardless of matches, and 
           identify missing or orphaned relationships using anti-join patterns.
Database: PostgreSQL (pgAdmin)
          MySQL: use CONCAT() instead of || ; otherwise identical
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
-- 2. Academic Structure: Faculties, Departments, and Department Heads
-- =============================================================================
-- Preserves all departments even if a department currently has no appointed head:

SELECT 
    f.faculty_name,
    d.department_name,
    COALESCE(l.first_name || ' ' || l.last_name, '(vacant)') AS head_of_department
FROM departments d
INNER JOIN faculties f       ON f.faculty_id    = d.faculty_id
LEFT JOIN department_heads h ON h.department_id = d.department_id
LEFT JOIN lecturers l        ON l.lecturer_id   = h.lecturer_id
ORDER BY f.faculty_name, d.department_name;


-- =============================================================================
-- 3. Lecturer Teaching Load (Keeping Lecturers with No Classes)
-- =============================================================================
-- Summarizes teaching assignments for term 1; lecturers without classes still appear:

SELECT 
    l.first_name || ' ' || l.last_name AS lecturer,
    l.academic_rank,
    COUNT(DISTINCT o.offering_id)      AS courses_taught,
    COUNT(e.enrollment_id)             AS total_students
FROM lecturers l
LEFT JOIN course_offerings o ON o.lecturer_id = l.lecturer_id AND o.term_id = 1
LEFT JOIN enrollments e      ON e.offering_id = o.offering_id
GROUP BY l.lecturer_id, l.first_name, l.last_name, l.academic_rank
ORDER BY total_students DESC;


-- =============================================================================
-- 4. Anti-Join Pattern 1: Courses in Catalog NOT Offered This Term
-- =============================================================================
-- Identifies inactive or dormant courses:

SELECT 
    c.course_id,
    c.course_code,
    c.course_title,
    c.credits
FROM courses c
LEFT JOIN course_offerings o 
    ON c.course_id = o.course_id AND o.term_id = 1
WHERE o.offering_id IS NULL;


-- =============================================================================
-- 5. Anti-Join Pattern 2: Students with Unpaid Invoices (Zero Payments)
-- =============================================================================
-- Finds students who have been issued an invoice but have made no payments:

SELECT 
    s.student_id,
    s.registration_no,
    s.first_name || ' ' || s.last_name AS student_name,
    i.invoice_id,
    i.due_date
FROM invoices i
INNER JOIN students s ON s.student_id = i.student_id
LEFT JOIN payments p  ON p.invoice_id = i.invoice_id
WHERE p.payment_id IS NULL;


-- =============================================================================
-- 6. The ON vs. WHERE Trap
-- =============================================================================
-- A condition on the RIGHT table belongs in ON. In WHERE it removes the
-- NULL rows that LEFT JOIN just kept, so the query behaves like an INNER JOIN.

-- WRONG: lecturers with no current-term class disappear (5 rows, not 8)
SELECT l.first_name, l.last_name, o.offering_id
FROM lecturers l
LEFT JOIN course_offerings o ON o.lecturer_id = l.lecturer_id
WHERE o.term_id = 1
ORDER BY l.last_name;

-- RIGHT: filter the offerings inside ON; every lecturer stays (8 rows)
SELECT l.first_name, l.last_name, o.offering_id
FROM lecturers l
LEFT JOIN course_offerings o ON o.lecturer_id = l.lecturer_id
                            AND o.term_id = 1
ORDER BY l.last_name;


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Write an anti-join to find all scholarships that have NOT been awarded
--             to any student for term 1.
-- Exercise 2: Write a LEFT JOIN between programs and students to list all degree 
--             programs and the count of registered students in each.
