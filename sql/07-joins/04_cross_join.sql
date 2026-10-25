/*
================================================================================
Topic: Cartesian Products with CROSS JOIN
Objective: Understand how CROSS JOIN pairs every row with every row, use it
           to build complete grids (and find gaps in them), and avoid
           accidental Cartesian products.
Database: PostgreSQL (pgAdmin)
          MySQL 8 / Oracle: identical syntax (Oracle 23c+ for VALUES lists)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- CROSS JOIN returns the Cartesian product: every row of table A paired with
-- every row of table B. It has no ON clause.
--   rows in result = rows in A  x  rows in B
-- It is rarely what you want by accident, but very useful on purpose for
-- building "every combination" grids.


-- =============================================================================
-- 2. Basic CROSS JOIN
-- =============================================================================
-- Planning grid: every department for every term (4 x 3 = 12 rows)
SELECT
    d.department_name,
    t.academic_year,
    t.term_name
FROM departments d
CROSS JOIN academic_terms t
ORDER BY d.department_name, t.start_date;


-- =============================================================================
-- 3. Practical Use: Find the Gaps in a Grid
-- =============================================================================
-- Question: which programme/term combinations have NO tuition fee set yet?
-- Step 1 builds every combination (5 programmes x 3 terms = 15).
-- Step 2 LEFT JOINs the real price list; NULL means "missing".
SELECT
    p.program_name,
    t.academic_year,
    t.term_name
FROM programs p
CROSS JOIN academic_terms t
LEFT JOIN fee_structures fs
       ON fs.program_id = p.program_id
      AND fs.term_id    = t.term_id
      AND fs.fee_type   = 'Tuition'
WHERE fs.fee_structure_id IS NULL
ORDER BY p.program_name, t.start_date;            -- 8 missing price-list entries


-- =============================================================================
-- 4. Practical Use: Generating a Timetable Template
-- =============================================================================
-- Every exam day with every time slot (3 x 3 = 9 slots).
-- VALUES (...) AS name(column) builds a small table inside the query.
SELECT
    d.exam_day,
    s.time_slot
FROM (VALUES ('Monday'), ('Wednesday'), ('Friday'))      AS d(exam_day)
CROSS JOIN
     (VALUES ('08:00-10:00'), ('10:30-12:30'), ('14:00-16:00')) AS s(time_slot)
ORDER BY d.exam_day, s.time_slot;


-- =============================================================================
-- 5. The Accidental Cartesian Product
-- =============================================================================
-- The old comma syntax without a join condition is a hidden CROSS JOIN:
SELECT COUNT(*) AS rows_returned
FROM students, courses;                           -- 15 x 9 = 135 rows (!)
-- With 10,000 students and 500 courses that would be 5,000,000 rows.

-- What was meant: students joined to the courses they actually took
SELECT COUNT(*) AS rows_returned
FROM enrollments e
JOIN course_offerings o ON o.offering_id = e.offering_id
JOIN courses c          ON c.course_id   = o.course_id;     -- 25 rows
-- Best practice: always write explicit JOIN ... ON.


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: CROSS JOIN the lecturers of department 1 with the courses of
--             department 1 to list every possible teaching assignment.
--             How many rows do you expect before you run it?
-- Exercise 2: Table A has 250 rows and table B has 40 rows. How many rows does
--             SELECT * FROM A CROSS JOIN B return?
-- Exercise 3: List every student / assessment combination for offering 1 that
--             has NO score yet. (Hint: CROSS JOIN, then LEFT JOIN assessment_scores.)
