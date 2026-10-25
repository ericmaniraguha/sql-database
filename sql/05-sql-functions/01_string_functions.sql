/*
================================================================================
Topic: String (Text) Functions
Objective: Change case, measure, join, cut, search, clean and pad text with
           standard SQL string functions.
Database: PostgreSQL (pgAdmin)
          MySQL: no || for text (use CONCAT); LOCATE / INSTR instead of POSITION
          Oracle: SUBSTR / INSTR; no LEFT / RIGHT (use SUBSTR)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- A string function takes text in and returns new text (or a number, such as
-- a length). The stored data is NOT changed: functions only change what the
-- query shows. To change stored data, use them inside an UPDATE.


-- =============================================================================
-- 2. Changing Case: UPPER, LOWER, INITCAP
-- =============================================================================
SELECT
    first_name,
    UPPER(last_name)     AS last_name_upper,
    LOWER(email)         AS email_lower,
    INITCAP('aline UWASE') AS initcap_example    -- 'Aline Uwase' (PostgreSQL, Oracle)
FROM students
ORDER BY student_id
LIMIT 5;


-- =============================================================================
-- 3. Length: LENGTH
-- =============================================================================
SELECT
    department_name,
    LENGTH(department_name) AS characters
FROM departments
ORDER BY characters DESC;                               -- Accounting and Finance: 22


-- =============================================================================
-- 4. Joining Text: ||, CONCAT, CONCAT_WS
-- =============================================================================
SELECT
    first_name || ' ' || last_name                        AS full_name,
    CONCAT(first_name, ' ', last_name, ' (', academic_rank, ')') AS name_and_rank,
    CONCAT_WS(' | ', last_name, academic_rank, email)    AS directory_line
FROM lecturers
ORDER BY last_name;
-- CONCAT_WS = "concat with separator": the first argument goes between the others.
-- Reminder from module 04: || returns NULL if any part is NULL; CONCAT skips NULLs.


-- =============================================================================
-- 5. Cutting Text: SUBSTRING, LEFT, RIGHT
-- =============================================================================
-- SUBSTRING(text, start, length)  -- positions start at 1, not 0

-- Registration numbers look like 2024CS001: year + programme code + number
SELECT
    registration_no,
    SUBSTRING(registration_no, 1, 4) AS admission_year_text,   -- '2024'
    SUBSTRING(registration_no, 5, 2) AS programme_code,        -- 'CS'
    RIGHT(registration_no, 3)        AS sequence_number        -- '001'
FROM students
ORDER BY registration_no;

-- Course codes have a variable-length subject (CS, MATH, ACC) + a 3-digit level
SELECT
    course_code,
    LEFT(course_code, LENGTH(course_code) - 3) AS subject,     -- 'CS', 'MATH', 'ACC'
    RIGHT(course_code, 3)                      AS level_number -- '101', '110'
FROM courses
ORDER BY course_code;


-- =============================================================================
-- 6. Searching Inside Text: POSITION
-- =============================================================================
-- POSITION('x' IN text) returns where 'x' starts (0 if not found).
-- Combine it with SUBSTRING to extract the part BEFORE the '@':
SELECT
    email,
    POSITION('@' IN email)                          AS at_position,
    SUBSTRING(email, 1, POSITION('@' IN email) - 1) AS username
FROM lecturers
ORDER BY lecturer_id;
-- MySQL: LOCATE('@', email)   Oracle: INSTR(email, '@')
-- PostgreSQL shortcut: SPLIT_PART(email, '@', 1)


-- =============================================================================
-- 7. Cleaning Text: TRIM, REPLACE
-- =============================================================================
-- Data typed into forms often has extra spaces:
SELECT
    '[' || TRIM('   aline.uwase@uni.example  ') || ']' AS trimmed,     -- spaces both sides
    '[' || LTRIM('   left side')                || ']' AS left_trimmed,
    '[' || RTRIM('right side   ')               || ']' AS right_trimmed;

-- REPLACE(text, find, replace_with): show phone numbers in local format
SELECT
    first_name,
    phone,
    REPLACE(phone, '+250', '0') AS local_phone        -- +250788000001 -> 0788000001
FROM lecturers
ORDER BY lecturer_id;
-- Samuel and Josiane have no phone: REPLACE(NULL, ...) is NULL.


-- =============================================================================
-- 8. Padding: LPAD, RPAD
-- =============================================================================
-- Build fixed-width receipt numbers such as RCPT-00007
SELECT
    payment_id,
    'RCPT-' || LPAD(payment_id::TEXT, 5, '0') AS receipt_number
FROM payments
ORDER BY payment_id
LIMIT 5;
-- payment_id::TEXT converts the number to text (CAST(payment_id AS TEXT)).


-- =============================================================================
-- 9. Practice Exercises
-- =============================================================================
-- Exercise 1: Show student names as "UWASE, Aline" (last name in capitals,
--             comma, first name).
-- Exercise 2: Extract the domain (the part AFTER '@') from student emails.
-- Exercise 3: List courses whose title is longer than 20 characters.
-- Exercise 4: Show each programme name with the word 'BSc' replaced by
--             'Bachelor of Science'.
