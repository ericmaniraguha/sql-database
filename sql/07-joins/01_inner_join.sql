/*
================================================================================
Topic: Combining Tables with INNER JOIN
Objective: Link related tables using primary and foreign keys to retrieve 
           matched records across normalized relational structures.
Database: PostgreSQL (pgAdmin)
          MySQL: use CONCAT() instead of || ; otherwise identical
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- An INNER JOIN matches rows from two or more tables based on a specified join predicate (ON).
-- Rows are included in the result set ONLY if the condition evaluates to TRUE
-- in both tables. If a row in table A has no corresponding match in table B,
-- it is excluded from the output.


-- =============================================================================
-- 2. Two-Table INNER JOIN: Programs & Departments
-- =============================================================================

SELECT 
    p.program_id,
    p.program_name,
    p.degree_level,
    p.duration_years,
    d.department_name,
    d.building
FROM programs p
INNER JOIN departments d 
    ON p.department_id = d.department_id
ORDER BY d.department_name, p.program_name;


-- =============================================================================
-- 3. Two-Table INNER JOIN: Students & Programs
-- =============================================================================

SELECT 
    s.student_id,
    s.registration_no,
    s.first_name || ' ' || s.last_name AS student_name,
    s.email,
    p.program_name,
    p.degree_level
FROM students s
INNER JOIN programs p 
    ON s.program_id = p.program_id
ORDER BY s.student_id;


-- =============================================================================
-- 4. Three-Table Hierarchy: Faculties -> Departments -> Programs
-- =============================================================================

SELECT 
    f.faculty_name,
    d.department_name,
    p.program_name,
    p.degree_level
FROM faculties f
INNER JOIN departments d ON d.faculty_id = f.faculty_id
INNER JOIN programs p    ON p.department_id = d.department_id
ORDER BY f.faculty_name, d.department_name, p.program_name;


-- =============================================================================
-- 5. Multi-Table Relational Join: Course Offerings & Lecturers
-- =============================================================================
-- Combines course catalog with the running term offering and assigned lecturer:

SELECT 
    c.course_code,
    c.course_title,
    c.credits,
    o.room                  AS classroom,
    o.capacity,
    t.academic_year,
    t.term_name,
    l.first_name || ' ' || l.last_name AS lecturer_name,
    l.academic_rank
FROM course_offerings o
INNER JOIN courses c        ON c.course_id = o.course_id
INNER JOIN academic_terms t ON t.term_id = o.term_id
INNER JOIN lecturers l      ON l.lecturer_id = o.lecturer_id
ORDER BY c.course_code;


-- =============================================================================
-- 6. Payroll Join: Salary Payments & Lecturers & Departments
-- =============================================================================

SELECT 
    sp.salary_payment_id,
    sp.pay_month,
    l.first_name || ' ' || l.last_name AS lecturer_name,
    d.department_name,
    sp.gross_amount,
    sp.tax_amount,
    sp.other_deductions,
    (sp.gross_amount - sp.tax_amount - sp.other_deductions) AS net_pay
FROM salary_payments sp
INNER JOIN lecturers l   ON l.lecturer_id = sp.lecturer_id
INNER JOIN departments d ON d.department_id = l.department_id
WHERE sp.pay_month = '2026-09'
ORDER BY sp.gross_amount DESC;


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Join 'invoices' and 'invoice_items' to display invoice_id, issue_date, 
--             fee_type, and amount.
-- Exercise 2: Join 'payments' with 'invoices' and 'students' to display payment_date, 
--             student_name, payment_method, and amount.
