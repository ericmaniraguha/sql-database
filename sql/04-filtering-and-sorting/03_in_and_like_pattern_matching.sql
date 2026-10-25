/*
================================================================================
Topic: IN Lists and LIKE Pattern Matching
Objective: Match a value against a list with IN / NOT IN, search text with
           LIKE and its wildcards, and handle upper/lower case.
Database: PostgreSQL (pgAdmin)
          MySQL: LIKE is case-INSENSITIVE by default; there is no ILIKE
          Oracle: LIKE is case-sensitive; there is no ILIKE
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- column IN (v1, v2, v3)    TRUE if the value equals any value in the list
--                           (a short way to write several ORs)
-- column LIKE 'pattern'     text pattern matching with two wildcards:
--     %   any number of characters (including none)
--     _   exactly ONE character


-- =============================================================================
-- 2. Value Lists with IN and NOT IN
-- =============================================================================

-- Senior academic staff
SELECT first_name, last_name, academic_rank
FROM lecturers
WHERE academic_rank IN ('Professor', 'Associate Professor');   -- Joseph, Esther

-- Same result with OR (longer, and easy to get wrong when combined with AND):
SELECT first_name, last_name, academic_rank
FROM lecturers
WHERE academic_rank = 'Professor'
   OR academic_rank = 'Associate Professor';

-- Students who are no longer studying
SELECT registration_no, first_name, last_name, status
FROM students
WHERE status IN ('Graduated', 'Withdrawn', 'Suspended');       -- 3 rows

-- Students NOT in programs 1 or 2 (i.e. Accounting and the Diploma)
SELECT registration_no, first_name, last_name, program_id
FROM students
WHERE program_id NOT IN (1, 2);                                 -- 5 rows


-- =============================================================================
-- 3. Pattern Matching with LIKE
-- =============================================================================

-- Starts with: Computer Science courses
SELECT course_code, course_title
FROM courses
WHERE course_code LIKE 'CS%';                           -- CS101, CS201, CS301, CS401

-- Ends with: introductory "101" courses
SELECT course_code, course_title
FROM courses
WHERE course_code LIKE '%101';                          -- CS101, ACC101, ECO101

-- Contains: department names with "and" anywhere inside
SELECT department_name
FROM departments
WHERE department_name LIKE '%and%';                     -- Accounting and Finance

-- One character with _ : "CS" + any one digit + "01"
SELECT course_code
FROM courses
WHERE course_code LIKE 'CS_01';

-- Registration numbers have the form YYYY + programme code + number,
-- e.g. 2024CS001. Four _ skip the year; then match the programme code:
SELECT registration_no, first_name, last_name
FROM students
WHERE registration_no LIKE '____MA%';                   -- Mathematics students

-- NOT LIKE: students whose phone does not start with +250789
SELECT first_name, last_name, phone
FROM students
WHERE phone NOT LIKE '+250789%';                        -- 0 rows. And students with
                                                        -- NULL phone? See file 04!


-- =============================================================================
-- 4. Upper and Lower Case
-- =============================================================================
-- In PostgreSQL, LIKE is case-sensitive:
SELECT course_title FROM courses WHERE course_title LIKE '%data%';   -- 0 rows
SELECT course_title FROM courses WHERE course_title LIKE '%Data%';   -- 4 rows

-- Portable fix (works in every database): compare in lower case
SELECT course_title
FROM courses
WHERE LOWER(course_title) LIKE '%data%';                -- 4 rows

-- PostgreSQL shortcut: ILIKE = case-insensitive LIKE
SELECT first_name, last_name
FROM students
WHERE last_name ILIKE 'mu%';                            -- Mugisha, Mutesi, Mugabo


-- =============================================================================
-- 5. Searching for a Literal % or _
-- =============================================================================
-- To match a real % or _ character, choose an ESCAPE character and put it
-- in front of the wildcard:
SELECT 'Discount 100%'  LIKE '%100!%'  ESCAPE '!' AS ends_with_100_percent,  -- true
       'Discount 1000'  LIKE '%100!%'  ESCAPE '!' AS same_test_on_1000;      -- false


-- =============================================================================
-- 6. Practice Exercises
-- =============================================================================
-- Exercise 1: Find all students whose first name starts with 'A'.
-- Exercise 2: Find all payments whose reference number starts with 'MM-'
--             (Mobile Money). Compare with WHERE payment_method = 'Mobile Money'.
-- Exercise 3: Find lecturers whose rank is 'Lecturer', 'Senior Lecturer' or
--             'Assistant Lecturer' using IN, then again using LIKE.
-- Exercise 4: Find students admitted in 2024 using only registration_no and LIKE.
