/*
================================================================================
Topic: Inserting Records (Data Manipulation Language - DML)
Objective: Learn single-row, multi-row, default value, and query-based INSERT statements
           to populate relational tables with realistic university data.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- The INSERT INTO statement adds new rows of data to a table.
-- Best Practice: Always specify the column list explicitly. This prevents queries
-- from breaking if table column order changes in the future.

-- =============================================================================
-- 2. Populate Departments (Single and Multi-Row Inserts)
-- =============================================================================

INSERT INTO departments (department_code, department_name, building, budget, established_year)
VALUES 
    ('CS',  'Computer Science',        'Turing Hall',       850000.00, 1996),
    ('BA',  'Business Administration', 'Kigali Block A',   720000.00, 1998),
    ('LAW', 'School of Law',           'Justice Pavilion',  610000.00, 2001),
    ('ENG', 'Civil Engineering',       'Newton Complex',    940000.00, 2005),
    ('MED', 'Health Sciences',         'Pasteur Center',   1100000.00, 2012);

-- =============================================================================
-- 3. Populate Instructors
-- =============================================================================

INSERT INTO instructors (first_name, last_name, email, hire_date, department_id, salary, academic_rank)
VALUES
    ('Jean-Paul',   'Habimana', 'jp.habimana@ulk.ac.rw', '2015-08-15', 1, 65000.00, 'Associate Professor'),
    ('Marie-Claire','Mukamana', 'mc.mukamana@ulk.ac.rw', '2017-01-10', 1, 52000.00, 'Senior Lecturer'),
    ('David',       'Mugabo',   'd.mugabo@ulk.ac.rw',   '2012-09-01', 2, 78000.00, 'Professor'),
    ('Grace',       'Uwase',    'g.uwase@ulk.ac.rw',    '2019-03-20', 2, 48000.00, 'Lecturer'),
    ('Emmanuel',    'Kagame',   'e.kagame@ulk.ac.rw',   '2010-06-12', 3, 82000.00, 'Professor'),
    ('Chantal',     'Ingabire', 'c.ingabire@ulk.ac.rw', '2021-11-01', 4, 45000.00, 'Assistant Lecturer'),
    ('Patrick',     'Ndungutse','p.ndungutse@ulk.ac.rw','2018-04-15', 5, 59000.00, 'Senior Lecturer');

-- =============================================================================
-- 4. Populate Students
-- =============================================================================

INSERT INTO students (first_name, last_name, email, birth_date, enrollment_date, department_id, gpa, status)
VALUES
    ('Alice',    'Niyonsaba', 'a.niyonsaba@student.ulk.ac.rw', '2003-04-12', '2021-09-01', 1, 3.85, 'Active'),
    ('Eric',     'Gasana',    'e.gasana@student.ulk.ac.rw',    '2002-11-23', '2020-09-01', 1, 3.40, 'Active'),
    ('Sandrine', 'Kwizera',   's.kwizera@student.ulk.ac.rw',   '2004-01-15', '2022-09-01', 1, 3.92, 'Active'),
    ('Claude',   'Makuza',    'c.makuza@student.ulk.ac.rw',    '2001-08-30', '2019-09-01', 2, 2.75, 'Active'),
    ('Diane',    'Umutoni',   'd.umutoni@student.ulk.ac.rw',   '2003-02-18', '2021-09-01', 2, 3.65, 'Active'),
    ('Olivier',  'Bizimana',  'o.bizimana@student.ulk.ac.rw',  '2000-05-09', '2018-09-01', 3, 3.10, 'Graduated'),
    ('Aline',    'Tuyisenge', 'a.tuyisenge@student.ulk.ac.rw', '2004-07-22', '2022-09-01', 4, 3.50, 'Active'),
    ('Fabrice',  'Rukundo',   'f.rukundo@student.ulk.ac.rw',   '2002-12-05', '2020-09-01', 5, 2.90, 'Suspended');

-- =============================================================================
-- 5. Populate Courses
-- =============================================================================

INSERT INTO courses (course_code, course_name, credits, department_id, instructor_id)
VALUES
    ('CS101',  'Introduction to Programming', 4, 1, 2),
    ('CS201',  'Data Structures & Algorithms',4, 1, 1),
    ('CS301',  'Database Systems',            3, 1, 1),
    ('BA101',  'Principles of Management',    3, 2, 3),
    ('BA205',  'Financial Accounting',        3, 2, 4),
    ('LAW101', 'Constitutional Law',          4, 3, 5),
    ('ENG101', 'Engineering Mechanics',       4, 4, 6),
    ('MED101', 'Human Anatomy',               4, 5, 7);

-- =============================================================================
-- 6. Populate Enrollments
-- =============================================================================

INSERT INTO enrollments (student_id, course_id, semester, academic_year, numeric_grade, letter_grade, status)
VALUES
    (1, 1, 'Fall',   2021, 92.50, 'A',  'Completed'),
    (1, 2, 'Spring', 2022, 88.00, 'A-', 'Completed'),
    (1, 3, 'Fall',   2022, 95.00, 'A',  'Completed'),
    (2, 1, 'Fall',   2020, 78.00, 'B',  'Completed'),
    (2, 3, 'Fall',   2022, 82.50, 'B+', 'Completed'),
    (3, 1, 'Fall',   2022, 96.00, 'A',  'Completed'),
    (3, 3, 'Fall',   2022, 91.00, 'A',  'Completed'),
    (4, 4, 'Fall',   2019, 65.00, 'C',  'Completed'),
    (4, 5, 'Spring', 2020, 71.00, 'B-', 'Completed'),
    (5, 4, 'Fall',   2021, 89.00, 'A-', 'Completed'),
    (7, 7, 'Fall',   2022, 84.00, 'B+', 'Completed');

-- =============================================================================
-- 7. Advanced: INSERT INTO ... SELECT (Archiving Example)
-- =============================================================================

-- Create an archive table structure
CREATE TABLE IF NOT EXISTS honor_roll_students (
    student_id   INT PRIMARY KEY,
    full_name    VARCHAR(120),
    email        VARCHAR(100),
    gpa          DECIMAL(3, 2)
);

-- Populate honor_roll_students dynamically using SELECT
INSERT INTO honor_roll_students (student_id, full_name, email, gpa)
SELECT 
    student_id, 
    CONCAT(first_name, ' ', last_name), 
    email, 
    gpa
FROM students
WHERE gpa >= 3.70;

-- =============================================================================
-- 8. Practice Questions
-- =============================================================================
-- Exercise 1: Insert a new course 'CS401' titled 'Artificial Intelligence' with 4 credits,
--             taught by instructor Jean-Paul Habimana.
-- Exercise 2: Insert 2 new students into the 'School of Law' department.
