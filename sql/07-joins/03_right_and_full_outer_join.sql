/*
================================================================================
Topic: RIGHT JOIN and FULL OUTER JOIN
Objective: Keep unmatched rows from the right table (RIGHT JOIN) or from both
           tables (FULL OUTER JOIN), find mismatches on both sides, and emulate
           FULL OUTER JOIN in MySQL.
Database: PostgreSQL (pgAdmin)
          MySQL: no FULL OUTER JOIN (see Section 5)
          Oracle: identical syntax
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- RIGHT JOIN      : every row of the RIGHT table, plus matches from the left.
--                   A RIGHT JOIN is a LEFT JOIN with the tables swapped;
--                   most teams write LEFT JOIN only, because it reads top-down.
-- FULL OUTER JOIN : every row of BOTH tables. Where there is no match, the
--                   other side's columns are NULL.
--
--   INNER  :   only matches
--   LEFT   :   matches + unmatched LEFT rows
--   RIGHT  :   matches + unmatched RIGHT rows
--   FULL   :   matches + unmatched rows from BOTH sides


-- =============================================================================
-- 2. RIGHT JOIN: Every Course, Offered or Not
-- =============================================================================
SELECT
    c.course_code,
    c.course_title,
    o.offering_id,
    o.term_id
FROM course_offerings o
RIGHT JOIN courses c
    ON c.course_id = o.course_id
ORDER BY c.course_code, o.term_id;
-- CS401 appears with offering_id NULL: it has never been offered.

-- Exactly the same result as a LEFT JOIN (tables swapped):
SELECT
    c.course_code,
    c.course_title,
    o.offering_id,
    o.term_id
FROM courses c
LEFT JOIN course_offerings o
    ON o.course_id = c.course_id
ORDER BY c.course_code, o.term_id;


-- =============================================================================
-- 3. FULL OUTER JOIN: Lecturers and Offerings, Matched or Not
-- =============================================================================
-- Two kinds of "loose ends" exist in our data:
--   * lecturers who teach nothing          (Ange, Josiane)
--   * an offering with no lecturer yet     (offering 10, ECO101 next term)
-- LEFT JOIN would show only the first kind, RIGHT JOIN only the second.
-- FULL OUTER JOIN shows both.
SELECT
    l.first_name || ' ' || l.last_name AS lecturer,
    o.offering_id,
    o.course_id,
    o.term_id
FROM lecturers l
FULL OUTER JOIN course_offerings o
    ON o.lecturer_id = l.lecturer_id
ORDER BY o.offering_id NULLS FIRST, lecturer;     -- 12 rows


-- =============================================================================
-- 4. Only the Mismatches
-- =============================================================================
-- Keep the rows where one side found no partner:
SELECT
    l.first_name || ' ' || l.last_name AS lecturer_without_class,
    o.offering_id                      AS offering_without_lecturer
FROM lecturers l
FULL OUTER JOIN course_offerings o
    ON o.lecturer_id = l.lecturer_id
WHERE l.lecturer_id IS NULL
   OR o.offering_id IS NULL;                      -- 3 rows


-- =============================================================================
-- 5. Emulating FULL OUTER JOIN in MySQL
-- =============================================================================
-- MySQL has no FULL OUTER JOIN. Combine a LEFT JOIN with a RIGHT JOIN:
-- UNION stacks both results and removes the duplicate matched rows.
-- (This query runs in PostgreSQL too.)
SELECT
    l.lecturer_id,
    CONCAT(l.first_name, ' ', l.last_name) AS lecturer,
    o.offering_id
FROM lecturers l
LEFT JOIN course_offerings o ON o.lecturer_id = l.lecturer_id

UNION

SELECT
    l.lecturer_id,
    CONCAT(l.first_name, ' ', l.last_name) AS lecturer,
    o.offering_id
FROM lecturers l
RIGHT JOIN course_offerings o ON o.lecturer_id = l.lecturer_id

ORDER BY offering_id, lecturer_id;                -- 12 rows, same as Section 3
-- Note: CONCAT(NULL, ' ', NULL) gives ' ' (a space), not NULL.


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Why do most teams prefer LEFT JOIN over RIGHT JOIN?
-- Exercise 2: Use FULL OUTER JOIN between programs and students to list every
--             programme and every student. Which programme has no students?
-- Exercise 3: Use FULL OUTER JOIN between departments and department_heads.
--             Which departments have no head?
-- Exercise 4: Rewrite Exercise 2 for MySQL using LEFT JOIN, RIGHT JOIN and UNION.
