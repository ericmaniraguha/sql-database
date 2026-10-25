/*
================================================================================
Topic: Recursive CTEs
Objective: Write CTEs that refer to themselves to generate series (numbers,
           dates) and to walk hierarchies of any depth (course prerequisites).
Database: PostgreSQL (pgAdmin)
          MySQL 8.0+: identical (WITH RECURSIVE)
          Oracle 11gR2+: write WITH without the word RECURSIVE, and list the
          CTE's columns: WITH chain (course_id, depth) AS (...)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
--   WITH RECURSIVE cte_name AS (
--       anchor query            -- runs once: the starting rows
--       UNION ALL
--       recursive query         -- uses cte_name: runs again and again on the
--                               -- rows produced by the previous round
--   )
--   SELECT ... FROM cte_name;
--
-- The recursion STOPS when a round produces no new rows. Always make sure
-- that happens (a WHERE limit, or data that eventually runs out).


-- =============================================================================
-- 2. Generating a Number Series
-- =============================================================================
WITH RECURSIVE numbers AS (
    SELECT 1 AS n                   -- anchor: start at 1
    UNION ALL
    SELECT n + 1                    -- recursive step: add 1
    FROM numbers
    WHERE n < 5                     -- stop condition
)
SELECT n FROM numbers;              -- 1, 2, 3, 4, 5


-- =============================================================================
-- 3. Generating Dates: the Teaching Weeks of the Current Term
-- =============================================================================
WITH RECURSIVE teaching_weeks AS (
    SELECT 1 AS week_no, start_date AS week_start, end_date
    FROM academic_terms
    WHERE term_id = 1
    UNION ALL
    SELECT week_no + 1, week_start + 7, end_date
    FROM teaching_weeks
    WHERE week_start + 7 <= end_date
)
SELECT
    week_no,
    week_start,
    week_start + 4 AS week_end_friday
FROM teaching_weeks
ORDER BY week_no;                   -- 20 weeks, from 2026-09-07
-- PostgreSQL shortcut for series: generate_series(start, stop, step)
--   SELECT generate_series(DATE '2026-09-07', DATE '2027-01-22', INTERVAL '7 days');


-- =============================================================================
-- 4. Walking a Hierarchy: Everything Needed Before CS401
-- =============================================================================
-- Direct prerequisites of CS401 are CS301 and MATH210, but THEY have
-- prerequisites too. A self join (module 07) needs one join per level;
-- a recursive CTE follows the chain however long it is.
WITH RECURSIVE needed AS (
    -- Anchor: direct prerequisites of CS401
    SELECT
        cp.prerequisite_course_id AS course_id,
        1                         AS depth
    FROM course_prerequisites cp
    JOIN courses c ON c.course_id = cp.course_id
    WHERE c.course_code = 'CS401'
    UNION ALL
    -- Recursive step: prerequisites of the courses found in the previous round
    SELECT
        cp.prerequisite_course_id,
        n.depth + 1
    FROM needed n
    JOIN course_prerequisites cp ON cp.course_id = n.course_id
)
SELECT
    n.depth,
    c.course_code,
    c.course_title
FROM needed n
JOIN courses c ON c.course_id = n.course_id
ORDER BY n.depth, c.course_code;
-- depth 1: CS301, MATH210   depth 2: CS201, MATH110   depth 3: CS101


-- =============================================================================
-- 5. The Other Direction, with a Readable Path
-- =============================================================================
-- Which courses does CS101 unlock, directly or indirectly?
WITH RECURSIVE unlocks AS (
    SELECT
        cp.course_id,
        1 AS depth,
        CAST('CS101 -> ' || c.course_code AS VARCHAR(200)) AS path
    FROM course_prerequisites cp
    JOIN courses c ON c.course_id = cp.course_id
    WHERE cp.prerequisite_course_id = (SELECT course_id FROM courses
                                       WHERE course_code = 'CS101')
    UNION ALL
    SELECT
        cp.course_id,
        u.depth + 1,
        CAST(u.path || ' -> ' || c.course_code AS VARCHAR(200))
    FROM unlocks u
    JOIN course_prerequisites cp ON cp.prerequisite_course_id = u.course_id
    JOIN courses c               ON c.course_id = cp.course_id
)
SELECT depth, path
FROM unlocks
ORDER BY depth;                     -- CS101 -> CS201 -> CS301 -> CS401
-- The CAST gives the path column one fixed type in both halves of UNION ALL.


-- =============================================================================
-- 6. Putting It to Work: Registrations That Break the Rules
-- =============================================================================
-- Students registered next term for a course, who have NOT passed every course
-- in its full prerequisite chain.
WITH RECURSIVE chain AS (
    -- Anchor: every course with its direct prerequisites
    SELECT course_id AS target_course_id, prerequisite_course_id AS required_course_id
    FROM course_prerequisites
    UNION ALL
    -- Recursive step: add the prerequisites of each required course
    SELECT ch.target_course_id, cp.prerequisite_course_id
    FROM chain ch
    JOIN course_prerequisites cp ON cp.course_id = ch.required_course_id
),
registrations AS (
    SELECT e.student_id, o.course_id
    FROM enrollments e
    JOIN course_offerings o ON o.offering_id = e.offering_id
    WHERE e.status = 'Registered'
),
passed AS (
    SELECT DISTINCT fg.student_id, c.course_id
    FROM final_grades fg
    JOIN courses c ON c.course_code = fg.course_code
    WHERE fg.letter_grade <> 'F'
)
SELECT
    s.first_name || ' ' || s.last_name AS student,
    target.course_code                 AS registered_for,
    missing.course_code                AS has_not_passed
FROM registrations r
JOIN chain ch         ON ch.target_course_id = r.course_id
LEFT JOIN passed p    ON p.student_id = r.student_id
                     AND p.course_id  = ch.required_course_id
JOIN students s       ON s.student_id = r.student_id
JOIN courses target   ON target.course_id  = r.course_id
JOIN courses missing  ON missing.course_id = ch.required_course_id
WHERE p.student_id IS NULL                        -- anti-join: no pass found
ORDER BY student, missing.course_code;            -- Aline: CS301 without CS201


-- =============================================================================
-- 7. Safety: Avoiding Endless Recursion
-- =============================================================================
-- If the data contained a loop (A needs B, B needs A), the recursion would
-- never stop. Two protections:
--   * a depth limit in the recursive step:   WHERE n.depth < 20
--   * PostgreSQL 14+: CYCLE course_id SET is_cycle USING visited
-- UNION (instead of UNION ALL) also stops on exact duplicate rows, but it costs
-- extra work each round, so UNION ALL is the usual choice.


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: Generate the dates of the next 7 days starting from CURRENT_DATE.
-- Exercise 2: List everything required before CS301, with its depth.
-- Exercise 3: Add a path column to Section 4 that shows e.g.
--             'CS401 <- CS301 <- CS201'.
-- Exercise 4: Generate the months '2026-09' to '2027-01' (one row each) with a
--             recursive CTE, and LEFT JOIN salary_payments to find months with
--             no payroll yet.
