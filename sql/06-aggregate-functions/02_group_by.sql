/*
================================================================================
Topic: Grouping Data with GROUP BY
Objective: Group result rows by one or more attributes to calculate aggregated 
           metrics per degree program, department, and course offering.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The GROUP BY clause collapses rows sharing identical values in specified columns 
-- into summary rows.
--
-- GOLDEN RULE OF GROUP BY:
-- Any column in the SELECT clause that is NOT enclosed in an aggregate function 
-- MUST appear in the GROUP BY clause!


-- =============================================================================
-- 2. Single Column GROUP BY
-- =============================================================================

-- Student count and distribution per degree program:
SELECT 
    program_id,
    COUNT(*)             AS student_count,
    MIN(admission_year)  AS earliest_admission,
    MAX(admission_year)  AS latest_admission
FROM students
GROUP BY program_id
ORDER BY program_id;

-- Department payroll analysis (from lecturers table):
SELECT 
    department_id,
    COUNT(*)                      AS total_lecturers,
    SUM(monthly_salary)           AS total_monthly_cost,
    ROUND(AVG(monthly_salary), 2) AS average_monthly_salary
FROM lecturers
GROUP BY department_id
ORDER BY total_monthly_cost DESC;


-- =============================================================================
-- 3. Multi-Column GROUP BY
-- =============================================================================

-- Lecturer breakdown by department and academic rank:
SELECT 
    department_id,
    academic_rank,
    COUNT(*)                      AS lecturer_count,
    ROUND(AVG(monthly_salary), 2) AS average_salary
FROM lecturers
GROUP BY department_id, academic_rank
ORDER BY department_id, lecturer_count DESC;

-- Payments grouped by method and date:
SELECT 
    payment_method,
    payment_date,
    COUNT(*)    AS transactions_count,
    SUM(amount) AS total_collected
FROM payments
GROUP BY payment_method, payment_date
ORDER BY payment_date, total_collected DESC;


-- =============================================================================
-- 4. Academic Course Performance (From final_grades view)
-- =============================================================================

-- Class results per course: student count, average mark, highest mark, and pass rate:
SELECT 
    course_code,
    COUNT(*)                                                    AS students_enrolled,
    ROUND(AVG(final_percent), 1)                                AS class_average_percent,
    MAX(final_percent)                                          AS highest_score,
    ROUND(100.0 * SUM(CASE WHEN letter_grade <> 'F' THEN 1 ELSE 0 END) 
          / COUNT(*), 0)                                        AS pass_rate_percent
FROM final_grades
GROUP BY course_code
ORDER BY course_code;


-- =============================================================================
-- 5. Practice Exercises
-- =============================================================================
-- Exercise 1: Group courses by department_id and calculate total credits per department.
-- Exercise 2: Group invoices by term_id and count total invoices issued per term.
-- Exercise 3: Group students by admission_year and calculate total admissions per year.
