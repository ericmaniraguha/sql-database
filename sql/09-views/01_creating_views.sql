/*
================================================================================
Topic: Creating Database Views
Objective: Create virtual tables to encapsulate complex joins, compute dynamic 
           grades and financial balances, and present consistent reporting interfaces.
Database: PostgreSQL (pgAdmin)
          MySQL: use CONCAT() instead of || ; otherwise identical
NOTE: 00_master_schema_and_data.sql already creates these three views.
      CREATE OR REPLACE makes it safe to run this file again.
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A VIEW is a stored query that acts as a virtual table.
-- Views do NOT physically store duplicate data rows on disk. Instead, every time
-- a view is queried, the database dynamically executes its definition query.
--
-- Architectural Rule:
-- "Values that can be calculated are NOT stored in tables; they live in VIEWS"
-- (e.g., final percentage marks, GPAs, and student financial balances).


-- =============================================================================
-- 2. View 1: Final Grades & Letter Grades per Enrollment
-- =============================================================================
-- Calculates scaled component scores (score / max_score * weight_percent),
-- aggregates them into final percentage, and maps to the grade scale.

CREATE OR REPLACE VIEW final_grades AS
SELECT f.*,
       g.letter_grade,
       g.grade_point
FROM (
    SELECT e.enrollment_id,
           e.student_id,
           o.offering_id,
           c.course_code,
           c.course_title,
           c.credits,
           t.academic_year,
           t.term_name,
           ROUND(SUM(sc.score * 1.0 / a.max_score * a.weight_percent), 2) AS final_percent
    FROM enrollments e
    JOIN course_offerings  o  ON o.offering_id   = e.offering_id
    JOIN courses           c  ON c.course_id     = o.course_id
    JOIN academic_terms    t  ON t.term_id       = o.term_id
    JOIN assessment_scores sc ON sc.enrollment_id = e.enrollment_id
    JOIN assessments       a  ON a.assessment_id = sc.assessment_id
    GROUP BY e.enrollment_id, e.student_id, o.offering_id, c.course_code,
             c.course_title, c.credits, t.academic_year, t.term_name
) f
JOIN grade_scale g ON f.final_percent BETWEEN g.min_percent AND g.max_percent;

-- Query the view:
SELECT course_code, course_title, credits, final_percent, letter_grade, grade_point
FROM final_grades
WHERE student_id = 1;


-- =============================================================================
-- 3. View 2: Credit-Weighted Student GPA
-- =============================================================================
-- Dynamically aggregates grade points weighted by course credits.

CREATE OR REPLACE VIEW student_gpa AS
SELECT s.student_id,
       s.registration_no,
       s.first_name || ' ' || s.last_name                             AS student_name,
       SUM(fg.credits)                                                AS credits_attempted,
       ROUND(SUM(fg.grade_point * fg.credits) * 1.0 / SUM(fg.credits), 2) AS gpa
FROM students s
JOIN final_grades fg ON fg.student_id = s.student_id
GROUP BY s.student_id, s.registration_no, s.first_name, s.last_name;

-- Query GPA rankings:
SELECT registration_no, student_name, credits_attempted, gpa
FROM student_gpa
ORDER BY gpa DESC;


-- =============================================================================
-- 4. View 3: Student Financial Balances (Billed - Scholarships - Paid)
-- =============================================================================
-- Calculates total billed, scholarships awarded, payments made, and net balance.

CREATE OR REPLACE VIEW student_balances AS
SELECT b.*,
       b.total_billed - b.total_scholarships - b.total_paid AS balance_due
FROM (
    SELECT i.invoice_id,
           s.student_id,
           s.registration_no,
           s.first_name || ' ' || s.last_name AS student_name,
           t.academic_year,
           t.term_name,
           i.due_date,
           COALESCE((SELECT SUM(ii.amount) FROM invoice_items ii
                     WHERE ii.invoice_id = i.invoice_id), 0)          AS total_billed,
           COALESCE((SELECT SUM(ss.amount_awarded) FROM student_scholarships ss
                     WHERE ss.student_id = i.student_id
                       AND ss.term_id    = i.term_id), 0)             AS total_scholarships,
           COALESCE((SELECT SUM(p.amount) FROM payments p
                     WHERE p.invoice_id = i.invoice_id), 0)           AS total_paid
    FROM invoices i
    JOIN students       s ON s.student_id = i.student_id
    JOIN academic_terms t ON t.term_id    = i.term_id
) b;

-- Query outstanding balances:
SELECT registration_no, student_name, total_billed, total_scholarships, total_paid, balance_due
FROM student_balances
WHERE balance_due > 0
ORDER BY balance_due DESC;


-- =============================================================================
-- 5. Practice Exercises
-- =============================================================================
-- Exercise 1: Query 'student_balances' to compute total revenue collected across all terms.
-- Exercise 2: Why is storing 'final_percent' directly in 'enrollments' an anti-pattern?
