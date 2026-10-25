/*
================================================================================
Topic: Correlated Subqueries
Objective: Write subqueries that refer to the CURRENT row of the outer query,
           e.g. "compared with the average of THEIR OWN department".
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Ordinary subquery   : runs ONCE; the outer query reuses its result.
-- Correlated subquery : refers to a column of the OUTER query, so it is
--                       (logically) re-run for every outer row.
--
--   SELECT ... FROM lecturers outer_l
--   WHERE outer_l.monthly_salary > (SELECT AVG(inner_l.monthly_salary)
--                                   FROM lecturers inner_l
--                                   WHERE inner_l.department_id = outer_l.department_id)
--                                                                  ^^^^^^^ the link
-- Aliases are essential: they say which copy of the table each column belongs to.


-- =============================================================================
-- 2. Above the Average of Their OWN Group
-- =============================================================================
-- Lecturers who earn more than the average of their own department
SELECT
    outer_l.first_name,
    outer_l.last_name,
    outer_l.department_id,
    outer_l.monthly_salary
FROM lecturers outer_l
WHERE outer_l.monthly_salary > (
    SELECT AVG(inner_l.monthly_salary)
    FROM lecturers inner_l
    WHERE inner_l.department_id = outer_l.department_id
)
ORDER BY outer_l.department_id;                   -- Claudine, Esther, Didier
-- Josiane is alone in department 4: her salary equals her department's
-- average, and "greater than" is false.


-- =============================================================================
-- 3. The Best Row in Each Group
-- =============================================================================
-- Top student of every class (offering). Ties would all be returned.
SELECT
    fg.course_code,
    fg.academic_year,
    fg.term_name,
    fg.student_id,
    fg.final_percent
FROM final_grades fg
WHERE fg.final_percent = (
    SELECT MAX(best.final_percent)
    FROM final_grades best
    WHERE best.offering_id = fg.offering_id
)
ORDER BY fg.academic_year, fg.course_code;        -- 8 classes, 8 top students

-- Each invoice's most recent payment
SELECT p.invoice_id, p.payment_date, p.amount, p.payment_method
FROM payments p
WHERE p.payment_date = (
    SELECT MAX(p2.payment_date)
    FROM payments p2
    WHERE p2.invoice_id = p.invoice_id
)
ORDER BY p.invoice_id;                            -- 18 invoices have payments


-- =============================================================================
-- 4. Correlated Subquery in SELECT: Counting Related Rows
-- =============================================================================
-- Seats taken in every current-term class
SELECT
    o.offering_id,
    o.course_id,
    o.capacity,
    (SELECT COUNT(*)
     FROM enrollments e
     WHERE e.offering_id = o.offering_id
       AND e.status <> 'Dropped') AS seats_taken
FROM course_offerings o
WHERE o.term_id = 1
ORDER BY o.offering_id;

-- Number of students in every programme (0 for MSc Data Science)
SELECT
    p.program_name,
    (SELECT COUNT(*)
     FROM students s
     WHERE s.program_id = p.program_id) AS students
FROM programs p
ORDER BY students DESC;


-- =============================================================================
-- 5. The Same Result with JOIN + GROUP BY
-- =============================================================================
-- Correlated subqueries are easy to read, but on big tables a join is often
-- faster. This gives the same result as the last query in Section 4:
SELECT
    p.program_name,
    COUNT(s.student_id) AS students           -- COUNT(column) gives 0 for no match
FROM programs p
LEFT JOIN students s ON s.program_id = p.program_id
GROUP BY p.program_id, p.program_name
ORDER BY students DESC;
-- Modern optimisers often rewrite one form into the other; check with EXPLAIN
-- (module 10) when performance matters.


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Find courses whose credits are higher than the average credits of
--             courses in the SAME department.
-- Exercise 2: For each student, show their highest final_percent using a
--             correlated subquery in SELECT.
-- Exercise 3: Find invoices whose total paid is less than half of what was billed
--             (correlated SUM on payments and on invoice_items).
-- Exercise 4: Rewrite the "seats taken" query with LEFT JOIN and GROUP BY.
