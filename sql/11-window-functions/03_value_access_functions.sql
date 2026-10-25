/*
================================================================================
Topic: Value Access Functions: LAG, LEAD, FIRST_VALUE, LAST_VALUE, NTH_VALUE
Objective: Read values from the previous / next row or from a fixed position
           in the window, to compare periods and find leaders and runners-up
           without self joins.
Database: PostgreSQL (pgAdmin)
          MySQL 8.0+ / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
--   LAG(col, n, default)   value from n rows BEFORE the current row (n = 1 by default)
--   LEAD(col, n, default)  value from n rows AFTER  the current row
--   FIRST_VALUE(col)       value from the first row of the window frame
--   LAST_VALUE(col)        value from the last row of the window frame (see Section 5!)
--   NTH_VALUE(col, n)      value from the n-th row of the window frame
--
-- "Before" and "after" follow the ORDER BY inside OVER(). With PARTITION BY,
-- LAG / LEAD never look across into another group: they return NULL (or the
-- default) at the group's edges.


-- =============================================================================
-- 2. LAG: This Month vs. Last Month
-- =============================================================================
-- Module 07 needed a self join for this; LAG does it in one pass.
SELECT
    lecturer_id,
    pay_month,
    gross_amount,
    LAG(gross_amount) OVER (PARTITION BY lecturer_id ORDER BY pay_month) AS previous_month,
    gross_amount
      - LAG(gross_amount) OVER (PARTITION BY lecturer_id ORDER BY pay_month) AS change
FROM salary_payments
ORDER BY lecturer_id, pay_month;
-- September rows show NULL: there is no earlier month. Lecturer 2 (Olivier)
-- shows +150,000 in October.


-- =============================================================================
-- 3. LAG on Terms: Is Each Student Improving?
-- =============================================================================
-- Term GPA per student, compared with their previous term.
-- ('2025/2026','Semester 2') sorts before ('2026/2027','Semester 1'), so
-- ORDER BY academic_year, term_name is chronological for these terms.
WITH term_gpa AS (
    SELECT
        student_id,
        academic_year,
        term_name,
        ROUND(SUM(grade_point * credits) / SUM(credits), 2) AS term_gpa
    FROM final_grades
    GROUP BY student_id, academic_year, term_name
)
SELECT
    s.first_name || ' ' || s.last_name AS student,
    tg.academic_year,
    tg.term_name,
    tg.term_gpa,
    LAG(tg.term_gpa) OVER w                       AS previous_term_gpa,
    CASE
        WHEN LAG(tg.term_gpa) OVER w IS NULL     THEN 'first term on record'
        WHEN tg.term_gpa > LAG(tg.term_gpa) OVER w THEN 'improved'
        WHEN tg.term_gpa < LAG(tg.term_gpa) OVER w THEN 'dropped'
        ELSE 'same'
    END                                           AS trend
FROM term_gpa tg
JOIN students s ON s.student_id = tg.student_id
WINDOW w AS (PARTITION BY tg.student_id ORDER BY tg.academic_year, tg.term_name)
ORDER BY student, tg.academic_year;
-- WINDOW w AS (...) names a window once so it can be reused (PostgreSQL,
-- MySQL 8, Oracle 21c+).


-- =============================================================================
-- 4. LEAD: Looking Ahead
-- =============================================================================
-- For invoices paid in instalments: when was the next payment, and how many
-- days later?
SELECT
    invoice_id,
    payment_date,
    amount,
    LEAD(payment_date) OVER (PARTITION BY invoice_id ORDER BY payment_date)  AS next_payment,
    LEAD(payment_date) OVER (PARTITION BY invoice_id ORDER BY payment_date)
      - payment_date                                                         AS days_until_next
FROM payments
WHERE invoice_id IN (1, 7, 15)
ORDER BY invoice_id, payment_date;

-- The third argument replaces NULL at the edge of the window:
SELECT
    lecturer_id,
    pay_month,
    gross_amount,
    LEAD(gross_amount, 1, 0) OVER (PARTITION BY lecturer_id ORDER BY pay_month) AS next_month_or_0
FROM salary_payments
WHERE lecturer_id IN (1, 2)
ORDER BY lecturer_id, pay_month;


-- =============================================================================
-- 5. FIRST_VALUE, and the LAST_VALUE Trap
-- =============================================================================
-- FIRST_VALUE: the best result of every class, shown on each student's row
SELECT
    course_code,
    academic_year,
    student_id,
    final_percent,
    FIRST_VALUE(final_percent) OVER (PARTITION BY offering_id
                                     ORDER BY final_percent DESC) AS class_best,
    FIRST_VALUE(student_id)    OVER (PARTITION BY offering_id
                                     ORDER BY final_percent DESC) AS top_student_id
FROM final_grades
ORDER BY academic_year, course_code, final_percent DESC;

-- LAST_VALUE TRAP: with ORDER BY, the default frame ENDS AT THE CURRENT ROW,
-- so the "last" row of the frame is the current row itself.
SELECT
    course_code,
    academic_year,
    student_id,
    final_percent,
    LAST_VALUE(final_percent) OVER (PARTITION BY offering_id
                                    ORDER BY final_percent DESC)  AS wrong_class_lowest,
    LAST_VALUE(final_percent) OVER (PARTITION BY offering_id
                                    ORDER BY final_percent DESC
                                    ROWS BETWEEN UNBOUNDED PRECEDING
                                         AND UNBOUNDED FOLLOWING) AS class_lowest
FROM final_grades
WHERE course_code = 'CS101' AND academic_year = '2026/2027'
ORDER BY final_percent DESC;
-- wrong_class_lowest just repeats final_percent; class_lowest is 39.80 on every row.


-- =============================================================================
-- 6. NTH_VALUE: the Runner-Up
-- =============================================================================
-- The 2nd-highest salary in each department (NULL if only one lecturer)
SELECT
    department_id,
    first_name,
    last_name,
    monthly_salary,
    NTH_VALUE(monthly_salary, 2) OVER (PARTITION BY department_id
                                       ORDER BY monthly_salary DESC
                                       ROWS BETWEEN UNBOUNDED PRECEDING
                                            AND UNBOUNDED FOLLOWING) AS second_highest
FROM lecturers
ORDER BY department_id, monthly_salary DESC;
-- Department 4 has one lecturer, so second_highest is NULL there.


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: For each lecturer, show the hire_date of the colleague hired just
--             before them (in the whole university) and the number of days between.
-- Exercise 2: Why does LAST_VALUE() need ROWS BETWEEN UNBOUNDED PRECEDING AND
--             UNBOUNDED FOLLOWING to return the true last value?
-- Exercise 3: Use NTH_VALUE to show the 2nd-best result in every class.
-- Exercise 4: Using LAG, show each current-term payment with the number of days
--             since the previous payment received by the university.
