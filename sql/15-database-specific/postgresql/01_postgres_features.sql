/*
================================================================================
Topic: PostgreSQL-Specific Features and Capabilities
Objective: Explore PostgreSQL specialized tools: RETURNING clause, JSONB data 
           types, Arrays, ILIKE, and DISTINCT ON.
Database: PostgreSQL (v12+)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- PostgreSQL is renowned for its strict adherence to ANSI SQL standards while 
-- offering cutting-edge object-relational extensions, including native JSONB,
-- arrays, and powerful returning clauses.

-- =============================================================================
-- 2. The RETURNING Clause (Insert / Update / Delete)
-- =============================================================================
-- In PostgreSQL, DML statements can return generated IDs or modified rows immediately,
-- eliminating the need for a separate SELECT query:

-- Insert and immediately retrieve the generated primary key:
/*
INSERT INTO students (first_name, last_name, email, birth_date, department_id, gpa)
VALUES ('Kelia', 'Uwineza', 'k.uwineza@student.ulk.ac.rw', '2004-03-10', 1, 3.80)
RETURNING student_id, enrollment_date;

-- Update and return modified rows:
UPDATE instructors
SET salary = salary * 1.05
WHERE department_id = 1
RETURNING instructor_id, first_name, salary AS new_salary;
*/

-- =============================================================================
-- 3. Case-Insensitive Pattern Matching: ILIKE
-- =============================================================================
-- PostgreSQL provides ILIKE, which matches strings case-insensitively without 
-- requiring explicit LOWER() wrapping:

/*
SELECT student_id, first_name, last_name, email
FROM students
WHERE email ILIKE '%ULK.AC.RW';
*/

-- =============================================================================
-- 4. DISTINCT ON (First Row Per Group)
-- =============================================================================
-- PostgreSQL's DISTINCT ON (column) returns the FIRST row for each distinct value,
-- determined by the ORDER BY clause:

/*
-- Find the single top student for each department:
SELECT DISTINCT ON (department_id) 
    department_id,
    first_name,
    last_name,
    gpa
FROM students
ORDER BY department_id, gpa DESC;
*/

-- =============================================================================
-- 5. Native JSONB and GIN Indexing
-- =============================================================================
-- PostgreSQL supports binary JSON (JSONB), enabling semi-structured data storage
-- with indexing:

/*
CREATE TABLE student_profiles (
    student_id  INT PRIMARY KEY,
    metadata    JSONB
);

INSERT INTO student_profiles (student_id, metadata)
VALUES (1, '{"skills": ["SQL", "Python"], "contact": {"emergency": "+250788000000", "city": "Kigali"}}');

-- Extract JSON text value with ->>
SELECT 
    student_id,
    metadata->'contact'->>'city' AS residence_city,
    metadata->'skills'->>0       AS primary_skill
FROM student_profiles;

-- Create GIN index on JSONB column for rapid key/value lookups:
CREATE INDEX idx_student_profiles_metadata ON student_profiles USING GIN (metadata);
*/

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Why is RETURNING useful when building REST APIs (e.g., POST endpoints)?
-- Exercise 2: Compare PostgreSQL DISTINCT ON with standard window functions (ROW_NUMBER).
