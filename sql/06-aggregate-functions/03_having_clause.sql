/*
================================================================================
Topic: Filtering Groups with HAVING
Objective: Tell WHERE and HAVING apart, filter groups on aggregate values,
           and combine both clauses in one query.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: identical syntax (MySQL also allows SELECT aliases
          in HAVING; PostgreSQL and Oracle do not)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: WHERE vs. HAVING
-- =============================================================================
-- | Clause | Runs                  | Filters        | Aggregates allowed? |
-- |--------|-----------------------|----------------|---------------------|
-- | WHERE  | BEFORE GROUP BY       | single rows    | NO                  |
-- | HAVING | AFTER  GROUP BY       | whole groups   | YES                 |
--
-- Logical order in which the database processes a query:
--   1. FROM / JOIN    which tables
--   2. WHERE          keep only some rows
--   3. GROUP BY       put the remaining rows into groups
--   4. HAVING         keep only some groups
--   5. SELECT         calculate the output columns
--   6. ORDER BY       sort
--   7. LIMIT / FETCH  cut the result


-- =============================================================================
-- 2. HAVING on a Count
-- =============================================================================
-- Departments with more than one lecturer
SELECT
    department_id,
    COUNT(*) AS lecturers
FROM lecturers
GROUP BY department_id
HAVING COUNT(*) > 1
ORDER BY department_id;                           -- departments 1, 2, 3 (not 4)

-- Invoices paid in more than one instalment
SELECT
    invoice_id,
    COUNT(*)    AS instalments,
    SUM(amount) AS total_paid
FROM payments
GROUP BY invoice_id
HAVING COUNT(*) > 1
ORDER BY invoice_id;                              -- invoices 1, 7, 15


-- =============================================================================
-- 3. HAVING on an Average (and the > vs >= Trap)
-- =============================================================================
-- Departments whose average lecturer salary is ABOVE 1,500,000 RWF
SELECT
    department_id,
    ROUND(AVG(monthly_salary), 2) AS average_salary
FROM lecturers
GROUP BY department_id
HAVING AVG(monthly_salary) > 1500000;             -- only department 2

-- Department 1 averages EXACTLY 1,500,000, so it only appears with >=
SELECT
    department_id,
    ROUND(AVG(monthly_salary), 2) AS average_salary
FROM lecturers
GROUP BY department_id
HAVING AVG(monthly_salary) >= 1500000
ORDER BY department_id;                           -- departments 1 and 2


-- =============================================================================
-- 4. WHERE and HAVING Together
-- =============================================================================
-- Current-term courses (WHERE: a row filter) with at least 3 graded students
-- (HAVING: a group filter)
SELECT
    course_code,
    COUNT(*)                     AS students,
    ROUND(AVG(final_percent), 1) AS class_average
FROM final_grades
WHERE academic_year = '2026/2027'                 -- 1) keep current-term rows
GROUP BY course_code                              -- 2) one group per course
HAVING COUNT(*) >= 3                              -- 3) keep the big groups
ORDER BY class_average DESC;                      -- MATH110 (3 students), CS101 (5)

-- Students who owe money for MORE THAN ONE term
SELECT
    student_id,
    student_name,
    COUNT(*)         AS terms_with_debt,
    SUM(balance_due) AS total_owed
FROM student_balances
WHERE balance_due > 0                             -- only invoices with a balance
GROUP BY student_id, student_name
HAVING COUNT(*) >= 2                              -- in 2 or more terms
ORDER BY total_owed DESC;                         -- Fabrice, Kevin


-- =============================================================================
-- 5. Common Mistakes
-- =============================================================================

-- Mistake 1: an aggregate in WHERE. WHERE runs before groups exist.
-- SELECT department_id FROM lecturers WHERE AVG(monthly_salary) > 1500000 GROUP BY department_id;
-- Expected: ERROR: aggregate functions are not allowed in WHERE

-- Mistake 2: a SELECT alias in HAVING. HAVING runs before SELECT names the column.
-- SELECT department_id, COUNT(*) AS lecturer_count FROM lecturers
-- GROUP BY department_id HAVING lecturer_count > 1;
-- Expected: ERROR: column "lecturer_count" does not exist   (MySQL accepts it)
-- Fix: repeat the expression: HAVING COUNT(*) > 1

-- Mistake 3 (works, but wasteful): a plain row condition in HAVING.
-- This filters AFTER grouping all rows:
SELECT department_id, COUNT(*) AS lecturers
FROM lecturers
GROUP BY department_id
HAVING department_id <> 4;
-- Better: filter rows first with WHERE department_id <> 4, then group.


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Find course offerings (offering_id) with more than 2 enrollments.
-- Exercise 2: Find programmes (program_id) with at least 3 ACTIVE students.
-- Exercise 3: Find courses in final_grades whose highest final_percent is
--             above 85.
-- Exercise 4: Find payment methods that brought in more than 1,000,000 RWF in total.
