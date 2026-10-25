/*
================================================================================
Topic: NULL Values and Three-Valued Logic
Objective: Understand NULL (missing / unknown data), avoid the comparison traps
           it causes, and filter correctly with IS NULL and IS NOT NULL.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same rules. Oracle also treats '' as NULL.
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- NULL means "no value / unknown". It is NOT 0 and NOT an empty string ''.
--
-- SQL uses Three-Valued Logic: TRUE, FALSE and UNKNOWN.
-- Any comparison with NULL (=, <>, <, >) gives UNKNOWN, and WHERE keeps only
-- rows that are TRUE. That is why NULL rows "disappear" from filters.
--
-- NULLs in our sample data:
--   students.phone (Yves, Nadia)        students.date_of_birth (Kevin)
--   lecturers.phone (Samuel, Josiane)   departments.building (Economics)
--   course_offerings.lecturer_id/room (offering 10)
--   payments.reference_no (cash)        assessments.due_date (Group Project)


-- =============================================================================
-- 2. Three-Valued Logic in One Query
-- =============================================================================
SELECT
    NULL = NULL      AS null_equals_null,     -- NULL (unknown), not TRUE!
    NULL <> 5        AS null_not_5,           -- NULL
    NULL IS NULL     AS null_is_null,         -- true
    TRUE  AND NULL   AS true_and_null,        -- NULL
    FALSE AND NULL   AS false_and_null,       -- false (FALSE wins)
    TRUE  OR  NULL   AS true_or_null;         -- true  (TRUE wins)


-- =============================================================================
-- 3. The = NULL Trap
-- =============================================================================

-- WRONG: always returns 0 rows, because lecturer_id = NULL is never TRUE
SELECT offering_id, course_id, lecturer_id
FROM course_offerings
WHERE lecturer_id = NULL;                               -- 0 rows

-- RIGHT: IS NULL
SELECT offering_id, course_id, lecturer_id, room
FROM course_offerings
WHERE lecturer_id IS NULL;                              -- 1 row: offering 10

-- IS NOT NULL: offerings that do have a lecturer
SELECT offering_id, course_id, lecturer_id
FROM course_offerings
WHERE lecturer_id IS NOT NULL;                          -- 9 rows

-- Students with no phone number on file
SELECT registration_no, first_name, last_name
FROM students
WHERE phone IS NULL;                                    -- Yves, Nadia


-- =============================================================================
-- 4. The <> Trap: NULL Rows Vanish from Both Sides
-- =============================================================================
-- 15 students. Only one has phone '+250789100001'. How many have a different one?
SELECT COUNT(*) AS students
FROM students
WHERE phone <> '+250789100001';                         -- 12, not 14!

-- The 2 students with NULL phone are neither "equal" nor "different": UNKNOWN.
-- Include them explicitly:
SELECT COUNT(*) AS students
FROM students
WHERE phone <> '+250789100001'
   OR phone IS NULL;                                    -- 14

-- Same thing, shorter (SQL standard; PostgreSQL, not MySQL):
SELECT COUNT(*) AS students
FROM students
WHERE phone IS DISTINCT FROM '+250789100001';           -- 14


-- =============================================================================
-- 5. NULL in Calculations and Text
-- =============================================================================
SELECT
    100 + NULL                 AS add_null,           -- NULL
    NULL * 5                   AS multiply_null,      -- NULL
    'Room ' || NULL            AS concat_operator,    -- NULL: || with NULL gives NULL
    CONCAT('Room ', NULL)      AS concat_function;    -- 'Room ': CONCAT skips NULLs

-- So this "contact line" is NULL for students without a phone:
SELECT first_name,
       first_name || ': ' || phone AS contact_line
FROM students
WHERE student_id IN (5, 6);                             -- Diane has one, Yves gets NULL
-- (COALESCE, in module 05, replaces NULL with a default value.)


-- =============================================================================
-- 6. NULL and Aggregates (preview of module 06)
-- =============================================================================
SELECT
    COUNT(*)      AS all_students,                      -- 15: counts rows
    COUNT(phone)  AS students_with_phone                -- 13: skips NULLs
FROM students;


-- =============================================================================
-- 7. The NOT IN Trap (a real bug with our data)
-- =============================================================================
-- Question: which lecturers are not teaching any course offering?

-- WRONG: returns 0 rows, because the subquery's list contains a NULL
-- (offering 10 has no lecturer). "x NOT IN (1, 2, NULL)" is never TRUE.
SELECT first_name, last_name
FROM lecturers
WHERE lecturer_id NOT IN (SELECT lecturer_id
                          FROM course_offerings);       -- 0 rows!

-- RIGHT: remove the NULLs from the list
SELECT first_name, last_name
FROM lecturers
WHERE lecturer_id NOT IN (SELECT lecturer_id
                          FROM course_offerings
                          WHERE lecturer_id IS NOT NULL);   -- Ange, Josiane

-- ALSO RIGHT (and NULL-proof): NOT EXISTS, covered in module 13
SELECT l.first_name, l.last_name
FROM lecturers l
WHERE NOT EXISTS (SELECT 1
                  FROM course_offerings o
                  WHERE o.lecturer_id = l.lecturer_id);    -- Ange, Josiane


-- =============================================================================
-- 8. Practice Exercises
-- =============================================================================
-- Exercise 1: List lecturers who have no phone number.
-- Exercise 2: List payments with no reference number. Which payment method do
--             they all use?
-- Exercise 3: Find departments whose building is NOT 'Block A'. Why is
--             Economics missing, and how do you include it?
-- Exercise 4: Why does WHERE NULL = NULL return no rows?
