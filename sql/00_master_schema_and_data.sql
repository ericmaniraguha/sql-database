/*
================================================================================
Topic: Master University Database Schema, Views, and Sample Data Setup
Objective: Provide a single, complete, executable master script to initialize the 
           entire ULK University sample database with auto-generated identity primary 
           keys, constraints, views, and sample records for hands-on practice.
Database: PostgreSQL 12+ (pgAdmin / psql)
          The lesson files show MySQL / Oracle equivalents in comments where the
          syntax differs.
================================================================================
*/

-- =====================================================================
--  UNIVERSITY DATABASE
--  Academic structure, lecturers, students, courses, grades and finance
--
--  Naming rules used everywhere (teach these first!):
--    * table names are plural, lowercase, snake_case      -> lecturers
--    * primary keys are AUTO-GENERATED and CANNOT be inserted manually:
--      -> INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
--      (PostgreSQL rejects manual primary key values in INSERT statements)
--    * a foreign key has the SAME name as the key it uses  -> lecturer_id
--    * no abbreviations: first_name, not fname
--    * money is DECIMAL(12,2), never FLOAT
--    * values that can be calculated are NOT stored; they live in VIEWS
--      (final grades, GPA, fee balances)
--
--  Table map
--    A. ACADEMIC STRUCTURE : faculties, departments, programs, academic_terms
--    B. PEOPLE             : lecturers, department_heads, students
--    C. TEACHING           : courses, course_prerequisites,
--                            course_offerings, enrollments
--    D. GRADES             : grade_scale, assessments, assessment_scores
--    E. FINANCE            : fee_structures, invoices, invoice_items,
--                            payments, scholarships, student_scholarships,
--                            salary_payments
--    F. VIEWS              : final_grades, student_gpa, student_balances
-- =====================================================================


-- -----------------------------------------------------------------------------
-- Step 1: Clean Up Existing Views and Tables (reverse dependency order)
-- -----------------------------------------------------------------------------
DROP VIEW  IF EXISTS student_balances;
DROP VIEW  IF EXISTS student_gpa;
DROP VIEW  IF EXISTS final_grades;
DROP TABLE IF EXISTS salary_payments;
DROP TABLE IF EXISTS student_scholarships;
DROP TABLE IF EXISTS scholarships;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS invoice_items;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS fee_structures;
DROP TABLE IF EXISTS assessment_scores;
DROP TABLE IF EXISTS assessments;
DROP TABLE IF EXISTS grade_scale;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS course_offerings;
DROP TABLE IF EXISTS course_prerequisites;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS department_heads;
DROP TABLE IF EXISTS lecturers;
DROP TABLE IF EXISTS academic_terms;
DROP TABLE IF EXISTS programs;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS faculties;


-- =====================================================================
--  A. ACADEMIC STRUCTURE
-- =====================================================================

-- One row per faculty / school / college of the university
CREATE TABLE faculties (
    faculty_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_name    VARCHAR(100) NOT NULL UNIQUE
);

-- One row per department. Every department belongs to one faculty.
CREATE TABLE departments (
    department_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building        VARCHAR(50),
    faculty_id      INTEGER      NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculties (faculty_id)
);

-- One row per degree programme a student can register for
CREATE TABLE programs (
    program_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_name    VARCHAR(100) NOT NULL UNIQUE,   -- 'BSc Computer Science'
    degree_level    VARCHAR(20)  NOT NULL
                    CHECK (degree_level IN ('Diploma', 'Bachelor', 'Master', 'PhD')),
    duration_years  INTEGER      NOT NULL CHECK (duration_years BETWEEN 1 AND 7),
    department_id   INTEGER      NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

-- One row per semester / term
CREATE TABLE academic_terms (
    term_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    academic_year   VARCHAR(9)   NOT NULL,          -- '2026/2027'
    term_name       VARCHAR(20)  NOT NULL,          -- 'Semester 1'
    start_date      DATE         NOT NULL,
    end_date        DATE         NOT NULL,
    CHECK (end_date > start_date),
    UNIQUE (academic_year, term_name)
);


-- =====================================================================
--  B. PEOPLE
-- =====================================================================

-- One row per lecturer. Personal and employment details live only here.
CREATE TABLE lecturers (
    lecturer_id     INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR(50)   NOT NULL,
    last_name       VARCHAR(50)   NOT NULL,
    email           VARCHAR(100)  NOT NULL UNIQUE,
    phone           VARCHAR(20),
    academic_rank   VARCHAR(30)   NOT NULL
                    CHECK (academic_rank IN ('Assistant Lecturer', 'Lecturer',
                           'Senior Lecturer', 'Associate Professor', 'Professor')),
    hire_date       DATE          NOT NULL,
    monthly_salary  DECIMAL(12,2) NOT NULL CHECK (monthly_salary > 0),
    department_id   INTEGER       NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

-- Who heads each department (auto-generated department_head_id)
CREATE TABLE department_heads (
    department_head_id INTEGER   GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id      INTEGER   NOT NULL UNIQUE,   -- one head per department
    lecturer_id        INTEGER   NOT NULL UNIQUE,   -- a lecturer heads at most one
    start_date         DATE      NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id),
    FOREIGN KEY (lecturer_id)   REFERENCES lecturers (lecturer_id)
);

-- One row per student
CREATE TABLE students (
    student_id      INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_no VARCHAR(20)  NOT NULL UNIQUE,   -- number printed on the student card
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    date_of_birth   DATE,
    admission_year  INTEGER      NOT NULL CHECK (admission_year >= 1990),
    status          VARCHAR(20)  NOT NULL DEFAULT 'Active'
                    CHECK (status IN ('Active', 'Suspended', 'Withdrawn', 'Graduated')),
    program_id      INTEGER      NOT NULL,
    FOREIGN KEY (program_id) REFERENCES programs (program_id)
);


-- =====================================================================
--  C. TEACHING
-- =====================================================================

-- The course CATALOGUE: what can be taught (does not change each term)
CREATE TABLE courses (
    course_id       INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code     VARCHAR(10)  NOT NULL UNIQUE,   -- 'CS101'
    course_title    VARCHAR(100) NOT NULL,
    credits         INTEGER      NOT NULL CHECK (credits BETWEEN 1 AND 20),
    department_id   INTEGER      NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

-- Which course must be passed before another (a course can need several).
-- Both columns point at courses, so this table forms a hierarchy that
-- recursive CTEs can walk (module 08).
CREATE TABLE course_prerequisites (
    course_prerequisite_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id              INTEGER NOT NULL,        -- the course being taken
    prerequisite_course_id INTEGER NOT NULL,        -- the course required first
    FOREIGN KEY (course_id)              REFERENCES courses (course_id),
    FOREIGN KEY (prerequisite_course_id) REFERENCES courses (course_id),
    UNIQUE (course_id, prerequisite_course_id),
    CHECK (course_id <> prerequisite_course_id)
);

-- A course actually RUNNING in a given term, taught by a given lecturer.
CREATE TABLE course_offerings (
    offering_id     INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id       INTEGER      NOT NULL,
    term_id         INTEGER      NOT NULL,
    lecturer_id     INTEGER,                        -- NULL = not yet assigned
    room            VARCHAR(20),
    capacity        INTEGER      NOT NULL CHECK (capacity > 0),
    FOREIGN KEY (course_id)   REFERENCES courses (course_id),
    FOREIGN KEY (term_id)     REFERENCES academic_terms (term_id),
    FOREIGN KEY (lecturer_id) REFERENCES lecturers (lecturer_id),
    UNIQUE (course_id, term_id)
);

-- Junction table: which student is registered in which offering.
CREATE TABLE enrollments (
    enrollment_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id      INTEGER      NOT NULL,
    offering_id     INTEGER      NOT NULL,
    enrollment_date DATE         NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'Registered'
                    CHECK (status IN ('Registered', 'Dropped', 'Completed')),
    FOREIGN KEY (student_id)  REFERENCES students (student_id),
    FOREIGN KEY (offering_id) REFERENCES course_offerings (offering_id),
    UNIQUE (student_id, offering_id)                -- no double registration
);


-- =====================================================================
--  D. GRADES
-- =====================================================================

-- Converts a final percentage into a letter grade and grade point.
CREATE TABLE grade_scale (
    grade_id        INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    letter_grade    VARCHAR(2)   NOT NULL UNIQUE,
    min_percent     DECIMAL(5,2) NOT NULL,
    max_percent     DECIMAL(5,2) NOT NULL,
    grade_point     DECIMAL(3,2) NOT NULL,
    description     VARCHAR(30),
    CHECK (min_percent <= max_percent)
);

-- The pieces of work in an offering: CAT, assignment, final exam...
CREATE TABLE assessments (
    assessment_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    offering_id     INTEGER      NOT NULL,
    assessment_name VARCHAR(50)  NOT NULL,          -- 'CAT 1'
    assessment_type VARCHAR(20)  NOT NULL
                    CHECK (assessment_type IN ('CAT', 'Assignment', 'Project',
                           'Lab', 'Final Exam')),
    max_score       DECIMAL(5,2) NOT NULL CHECK (max_score > 0),
    weight_percent  DECIMAL(5,2) NOT NULL CHECK (weight_percent BETWEEN 0 AND 100),
    due_date        DATE,
    FOREIGN KEY (offering_id) REFERENCES course_offerings (offering_id),
    UNIQUE (offering_id, assessment_name)
);

-- One mark per student per assessment (auto-generated score_id)
CREATE TABLE assessment_scores (
    score_id        INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    enrollment_id   INTEGER      NOT NULL,
    assessment_id   INTEGER      NOT NULL,
    score           DECIMAL(5,2) NOT NULL CHECK (score >= 0),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments (enrollment_id),
    FOREIGN KEY (assessment_id) REFERENCES assessments (assessment_id),
    UNIQUE (enrollment_id, assessment_id)
);


-- =====================================================================
--  E. FINANCE
-- =====================================================================

-- Price list: what each programme is charged per term
CREATE TABLE fee_structures (
    fee_structure_id INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_id       INTEGER       NOT NULL,
    term_id          INTEGER       NOT NULL,
    fee_type         VARCHAR(30)   NOT NULL
                     CHECK (fee_type IN ('Tuition', 'Registration', 'Library',
                            'Laboratory', 'Accommodation')),
    amount           DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (program_id) REFERENCES programs (program_id),
    FOREIGN KEY (term_id)    REFERENCES academic_terms (term_id),
    UNIQUE (program_id, term_id, fee_type)
);

-- One bill per student per term
CREATE TABLE invoices (
    invoice_id      INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id      INTEGER      NOT NULL,
    term_id         INTEGER      NOT NULL,
    issue_date      DATE         NOT NULL,
    due_date        DATE         NOT NULL,
    CHECK (due_date >= issue_date),
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    FOREIGN KEY (term_id)    REFERENCES academic_terms (term_id),
    UNIQUE (student_id, term_id)
);

-- The lines on a bill
CREATE TABLE invoice_items (
    invoice_item_id INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id      INTEGER       NOT NULL,
    fee_type        VARCHAR(30)   NOT NULL,
    amount          DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id)
);

-- Money received against an invoice
CREATE TABLE payments (
    payment_id      INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id      INTEGER       NOT NULL,
    payment_date    DATE          NOT NULL,
    amount          DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    payment_method  VARCHAR(20)   NOT NULL
                    CHECK (payment_method IN ('Bank Transfer', 'Mobile Money',
                           'Card', 'Cash')),
    reference_no    VARCHAR(50)   UNIQUE,
    FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id)
);

-- Catalogue of scholarships and bursaries
CREATE TABLE scholarships (
    scholarship_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scholarship_name VARCHAR(100) NOT NULL UNIQUE,
    sponsor          VARCHAR(100) NOT NULL
);

-- Which student received which scholarship, for which term, and how much
CREATE TABLE student_scholarships (
    student_scholarship_id INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id             INTEGER       NOT NULL,
    scholarship_id         INTEGER       NOT NULL,
    term_id                INTEGER       NOT NULL,
    amount_awarded         DECIMAL(12,2) NOT NULL CHECK (amount_awarded > 0),
    FOREIGN KEY (student_id)     REFERENCES students (student_id),
    FOREIGN KEY (scholarship_id) REFERENCES scholarships (scholarship_id),
    FOREIGN KEY (term_id)        REFERENCES academic_terms (term_id),
    UNIQUE (student_id, scholarship_id, term_id)
);

-- Monthly payroll for lecturers
CREATE TABLE salary_payments (
    salary_payment_id INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lecturer_id       INTEGER       NOT NULL,
    pay_month         CHAR(7)       NOT NULL,       -- 'YYYY-MM', e.g. '2026-09'
    gross_amount      DECIMAL(12,2) NOT NULL CHECK (gross_amount > 0),
    tax_amount        DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    other_deductions  DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (other_deductions >= 0),
    payment_date      DATE          NOT NULL,
    FOREIGN KEY (lecturer_id) REFERENCES lecturers (lecturer_id),
    UNIQUE (lecturer_id, pay_month)
);


-- =====================================================================
--  F. VIEWS
-- =====================================================================

CREATE VIEW final_grades AS
SELECT f.*,
       g.letter_grade,
       g.grade_point
FROM (
    SELECT e.enrollment_id,
           e.student_id,
           o.offering_id,
           c.course_code,
           c.course_title,
           c.credits,
           t.academic_year,
           t.term_name,
           ROUND(SUM(sc.score * 1.0 / a.max_score * a.weight_percent), 2) AS final_percent
    FROM enrollments e
    JOIN course_offerings  o  ON o.offering_id   = e.offering_id
    JOIN courses           c  ON c.course_id     = o.course_id
    JOIN academic_terms    t  ON t.term_id       = o.term_id
    JOIN assessment_scores sc ON sc.enrollment_id = e.enrollment_id
    JOIN assessments       a  ON a.assessment_id = sc.assessment_id
    GROUP BY e.enrollment_id, e.student_id, o.offering_id, c.course_code,
             c.course_title, c.credits, t.academic_year, t.term_name
) f
JOIN grade_scale g ON f.final_percent BETWEEN g.min_percent AND g.max_percent;

CREATE VIEW student_gpa AS
SELECT s.student_id,
       s.registration_no,
       s.first_name || ' ' || s.last_name                             AS student_name,
       SUM(fg.credits)                                                AS credits_attempted,
       ROUND(SUM(fg.grade_point * fg.credits) * 1.0 / SUM(fg.credits), 2) AS gpa
FROM students s
JOIN final_grades fg ON fg.student_id = s.student_id
GROUP BY s.student_id, s.registration_no, s.first_name, s.last_name;

CREATE VIEW student_balances AS
SELECT b.*,
       b.total_billed - b.total_scholarships - b.total_paid AS balance_due
FROM (
    SELECT i.invoice_id,
           s.student_id,
           s.registration_no,
           s.first_name || ' ' || s.last_name AS student_name,
           t.academic_year,
           t.term_name,
           i.due_date,
           COALESCE((SELECT SUM(ii.amount) FROM invoice_items ii
                     WHERE ii.invoice_id = i.invoice_id), 0)          AS total_billed,
           COALESCE((SELECT SUM(ss.amount_awarded) FROM student_scholarships ss
                     WHERE ss.student_id = i.student_id
                       AND ss.term_id    = i.term_id), 0)             AS total_scholarships,
           COALESCE((SELECT SUM(p.amount) FROM payments p
                     WHERE p.invoice_id = i.invoice_id), 0)           AS total_paid
    FROM invoices i
    JOIN students       s ON s.student_id = i.student_id
    JOIN academic_terms t ON t.term_id    = i.term_id
) b;


-- =====================================================================
--  SAMPLE DATA  (amounts in Rwandan francs, RWF)
--
--  The data is small enough to check by hand, but it deliberately
--  contains the situations the lessons need:
--    * NULLs   : students/lecturers with no phone, a student with no
--                date of birth, a department with no building, an
--                offering with no lecturer or room yet, cash payments
--                with no reference number, an assessment with no due date
--    * "orphans": a faculty with no departments, a programme with no
--                students, a course never offered, lecturers with no
--                classes, a student with no enrollments, a scholarship
--                nobody has received yet
--    * 3 terms : a past term (term_id 2), the current term (term_id 1)
--                and the next term (term_id 3, registration only).
--                IDs are NOT in date order: always sort terms by start_date.
-- =====================================================================

INSERT INTO faculties (faculty_name) VALUES
    ('Faculty of Science and Technology'),      -- faculty_id 1
    ('Faculty of Business and Economics'),      -- faculty_id 2
    ('Faculty of Law');                         -- faculty_id 3 (no departments yet)

INSERT INTO departments (department_name, building, faculty_id) VALUES
    ('Computer Science',          'Block A', 1),   -- department_id 1
    ('Mathematics',               'Block B', 1),   -- department_id 2
    ('Accounting and Finance',    'Block C', 2),   -- department_id 3
    ('Economics',                 NULL,      2);   -- department_id 4 (building not assigned)

INSERT INTO programs (program_name, degree_level, duration_years, department_id) VALUES
    ('BSc Computer Science',              'Bachelor', 4, 1),   -- program_id 1
    ('BSc Mathematics',                   'Bachelor', 4, 2),   -- program_id 2
    ('BBA Accounting',                    'Bachelor', 4, 3),   -- program_id 3
    ('Diploma in Information Technology', 'Diploma',  2, 1),   -- program_id 4
    ('MSc Data Science',                  'Master',   2, 1);   -- program_id 5 (no students yet)

INSERT INTO academic_terms (academic_year, term_name, start_date, end_date) VALUES
    ('2026/2027', 'Semester 1', '2026-09-07', '2027-01-22'),   -- term_id 1: current term
    ('2025/2026', 'Semester 2', '2026-02-02', '2026-06-19'),   -- term_id 2: PREVIOUS term
    ('2026/2027', 'Semester 2', '2027-02-08', '2027-06-25');   -- term_id 3: NEXT term

INSERT INTO lecturers (first_name, last_name, email, phone, academic_rank, hire_date, monthly_salary, department_id) VALUES
    ('Claudine', 'Mukamana',     'c.mukamana@uni.example',     '+250788000001', 'Senior Lecturer',     '2015-02-01', 1800000.00, 1),  -- 1
    ('Olivier',  'Ndayisaba',    'o.ndayisaba@uni.example',    '+250788000002', 'Lecturer',            '2020-09-01', 1300000.00, 1),  -- 2
    ('Joseph',   'Nshimiyimana', 'j.nshimiyimana@uni.example', '+250788000003', 'Associate Professor', '2010-01-15', 2400000.00, 2),  -- 3
    ('Ange',     'Umutoni',      'a.umutoni@uni.example',      '+250788000004', 'Assistant Lecturer',  '2024-02-01',  900000.00, 3),  -- 4
    ('Samuel',   'Habyarimana',  's.habyarimana@uni.example',  NULL,            'Lecturer',            '2018-03-01', 1400000.00, 1),  -- 5
    ('Esther',   'Mukeshimana',  'e.mukeshimana@uni.example',  '+250788000006', 'Professor',           '2005-09-01', 2900000.00, 2),  -- 6
    ('Didier',   'Nkurunziza',   'd.nkurunziza@uni.example',   '+250788000007', 'Senior Lecturer',     '2016-01-10', 1750000.00, 3),  -- 7
    ('Josiane',  'Uwimana',      'j.uwimana@uni.example',      NULL,            'Lecturer',            '2022-02-01', 1250000.00, 4);  -- 8

INSERT INTO department_heads (department_id, lecturer_id, start_date) VALUES
    (1, 1, '2023-07-01'),
    (2, 3, '2021-07-01');
    -- Accounting (3) and Economics (4) have no head yet

INSERT INTO students (registration_no, first_name, last_name, email, phone, date_of_birth, admission_year, status, program_id) VALUES
    ('2024CS001', 'Aline',    'Uwase',         'aline.uwase@uni.example',           '+250789100001', '2005-03-14', 2024, 'Active',    1),  -- 1
    ('2023CS014', 'Jean',     'Mugisha',       'jean.mugisha@uni.example',          '+250789100002', '2004-11-02', 2023, 'Active',    1),  -- 2
    ('2024MA003', 'Grace',    'Ingabire',      'grace.ingabire@uni.example',        '+250789100003', '2005-07-21', 2024, 'Active',    2),  -- 3
    ('2022CS027', 'Patrick',  'Habimana',      'patrick.habimana@uni.example',      '+250789100004', '2003-01-30', 2022, 'Active',    1),  -- 4
    ('2025CS008', 'Diane',    'Iradukunda',    'diane.iradukunda@uni.example',      '+250789100005', '2006-05-09', 2025, 'Active',    1),  -- 5
    ('2022MA011', 'Yves',     'Niyonzima',     'yves.niyonzima@uni.example',        NULL,            '2003-08-19', 2022, 'Active',    2),  -- 6
    ('2023AC005', 'Sandrine', 'Mutesi',        'sandrine.mutesi@uni.example',       '+250789100007', '2004-02-11', 2023, 'Active',    3),  -- 7
    ('2024AC019', 'Kevin',    'Manzi',         'kevin.manzi@uni.example',           '+250789100008', NULL,         2024, 'Active',    3),  -- 8
    ('2021CS030', 'Alice',    'Umuhoza',       'alice.umuhoza@uni.example',         '+250789100009', '2002-12-05', 2021, 'Graduated', 1),  -- 9
    ('2023CS041', 'Fabrice',  'Hakizimana',    'fabrice.hakizimana@uni.example',    '+250789100010', '2004-06-27', 2023, 'Suspended', 1),  -- 10
    ('2025IT002', 'Nadia',    'Uwera',         'nadia.uwera@uni.example',           NULL,            '2006-09-13', 2025, 'Active',    4),  -- 11
    ('2025IT007', 'Emmanuel', 'Bizimana',      'emmanuel.bizimana@uni.example',     '+250789100012', '2005-04-02', 2025, 'Active',    4),  -- 12
    ('2022AC009', 'Chantal',  'Nyirahabimana', 'chantal.nyirahabimana@uni.example', '+250789100013', '2003-10-08', 2022, 'Withdrawn', 3),  -- 13
    ('2024MA015', 'Thierry',  'Mugabo',        'thierry.mugabo@uni.example',        '+250789100014', '2005-01-25', 2024, 'Active',    2),  -- 14
    ('2026CS001', 'Belinda',  'Ishimwe',       'belinda.ishimwe@uni.example',       '+250789100015', '2007-03-30', 2026, 'Active',    1);  -- 15 (no enrollments yet)

INSERT INTO courses (course_code, course_title, credits, department_id) VALUES
    ('CS101',   'Introduction to Databases',  4, 1),   -- course_id 1
    ('CS201',   'Data Structures',            4, 1),   -- course_id 2
    ('MATH110', 'Linear Algebra',             3, 2),   -- course_id 3
    ('ACC101',  'Principles of Accounting',   3, 3),   -- course_id 4
    ('CS301',   'Database Systems II',        4, 1),   -- course_id 5
    ('CS401',   'Big Data Analytics',         4, 1),   -- course_id 6 (never offered yet)
    ('MATH210', 'Probability and Statistics', 3, 2),   -- course_id 7
    ('ACC201',  'Financial Accounting',       3, 3),   -- course_id 8
    ('ECO101',  'Principles of Economics',    3, 4);   -- course_id 9

-- Prerequisite chain:  CS101 -> CS201 -> CS301 -> CS401 <- MATH210 <- MATH110
--                      ACC101 -> ACC201
INSERT INTO course_prerequisites (course_id, prerequisite_course_id) VALUES
    (2, 1),   -- CS201   needs CS101
    (5, 2),   -- CS301   needs CS201
    (6, 5),   -- CS401   needs CS301
    (6, 7),   -- CS401   needs MATH210
    (7, 3),   -- MATH210 needs MATH110
    (8, 4);   -- ACC201  needs ACC101

INSERT INTO course_offerings (course_id, term_id, lecturer_id, room, capacity) VALUES
    (1, 1, 1,    'A-101', 60),     -- offering_id 1  CS101   current term
    (2, 1, 2,    'A-204', 40),     -- offering_id 2  CS201   current term
    (3, 1, 3,    'B-012', 80),     -- offering_id 3  MATH110 current term
    (8, 1, 7,    'C-110', 50),     -- offering_id 4  ACC201  current term
    (7, 1, 6,    'B-014', 60),     -- offering_id 5  MATH210 current term
    (1, 2, 1,    'A-101', 60),     -- offering_id 6  CS101   previous term
    (3, 2, 3,    'B-012', 80),     -- offering_id 7  MATH110 previous term
    (4, 2, 7,    'C-110', 50),     -- offering_id 8  ACC101  previous term
    (5, 3, 5,    'A-204', 40),     -- offering_id 9  CS301   next term
    (9, 3, NULL, NULL,    45);     -- offering_id 10 ECO101  next term (no lecturer/room yet)

INSERT INTO enrollments (student_id, offering_id, enrollment_date, status) VALUES
    (1,  1,  '2026-09-01', 'Completed'),    -- enrollment_id 1   Aline    CS101
    (1,  3,  '2026-09-01', 'Completed'),    -- enrollment_id 2   Aline    MATH110
    (2,  1,  '2026-09-02', 'Completed'),    -- enrollment_id 3   Jean     CS101
    (2,  2,  '2026-09-02', 'Completed'),    -- enrollment_id 4   Jean     CS201
    (3,  3,  '2026-09-01', 'Completed'),    -- enrollment_id 5   Grace    MATH110
    (4,  1,  '2026-09-03', 'Completed'),    -- enrollment_id 6   Patrick  CS101
    (5,  2,  '2026-09-04', 'Completed'),    -- enrollment_id 7   Diane    CS201
    (6,  5,  '2026-09-02', 'Completed'),    -- enrollment_id 8   Yves     MATH210
    (14, 3,  '2026-09-03', 'Completed'),    -- enrollment_id 9   Thierry  MATH110
    (7,  4,  '2026-09-01', 'Completed'),    -- enrollment_id 10  Sandrine ACC201
    (8,  4,  '2026-09-04', 'Completed'),    -- enrollment_id 11  Kevin    ACC201
    (11, 1,  '2026-09-05', 'Completed'),    -- enrollment_id 12  Nadia    CS101
    (12, 1,  '2026-09-05', 'Completed'),    -- enrollment_id 13  Emmanuel CS101
    (10, 2,  '2026-09-02', 'Dropped'),      -- enrollment_id 14  Fabrice  CS201 (dropped)
    (5,  6,  '2026-02-03', 'Completed'),    -- enrollment_id 15  Diane    CS101   previous term
    (10, 6,  '2026-02-04', 'Completed'),    -- enrollment_id 16  Fabrice  CS101   previous term
    (6,  7,  '2026-02-03', 'Completed'),    -- enrollment_id 17  Yves     MATH110 previous term
    (4,  7,  '2026-02-05', 'Completed'),    -- enrollment_id 18  Patrick  MATH110 previous term
    (7,  8,  '2026-02-03', 'Completed'),    -- enrollment_id 19  Sandrine ACC101  previous term
    (8,  8,  '2026-02-03', 'Completed'),    -- enrollment_id 20  Kevin    ACC101  previous term
    (13, 8,  '2026-02-06', 'Dropped'),      -- enrollment_id 21  Chantal  ACC101  (dropped)
    (2,  9,  '2027-01-25', 'Registered'),   -- enrollment_id 22  Jean     CS301   next term
    (1,  9,  '2027-01-26', 'Registered'),   -- enrollment_id 23  Aline    CS301   (has NOT taken CS201!)
    (7,  10, '2027-01-25', 'Registered'),   -- enrollment_id 24  Sandrine ECO101  next term
    (8,  10, '2027-01-27', 'Registered');   -- enrollment_id 25  Kevin    ECO101  next term

INSERT INTO grade_scale (letter_grade, min_percent, max_percent, grade_point, description) VALUES
    ('A', 80.00, 100.00, 4.00, 'Excellent'),
    ('B', 70.00,  79.99, 3.00, 'Very good'),
    ('C', 60.00,  69.99, 2.00, 'Good'),
    ('D', 50.00,  59.99, 1.00, 'Pass'),
    ('F',  0.00,  49.99, 0.00, 'Fail');

INSERT INTO assessments (offering_id, assessment_name, assessment_type, max_score, weight_percent, due_date) VALUES
    (1, 'CAT 1',         'CAT',         30, 20, '2026-10-15'),   -- assessment_id 1
    (1, 'Assignment',    'Assignment',  20, 20, '2026-11-20'),   -- assessment_id 2
    (1, 'Final Exam',    'Final Exam', 100, 60, '2027-01-12'),   -- assessment_id 3
    (2, 'CAT 1',         'CAT',         30, 20, '2026-10-16'),   -- assessment_id 4
    (2, 'Assignment',    'Assignment',  20, 20, '2026-11-21'),   -- assessment_id 5
    (2, 'Final Exam',    'Final Exam', 100, 60, '2027-01-13'),   -- assessment_id 6
    (3, 'CAT 1',         'CAT',         30, 20, '2026-10-17'),   -- assessment_id 7
    (3, 'Assignment',    'Assignment',  20, 20, '2026-11-22'),   -- assessment_id 8
    (3, 'Final Exam',    'Final Exam', 100, 60, '2027-01-14'),   -- assessment_id 9
    (4, 'CAT 1',         'CAT',         30, 20, '2026-10-19'),   -- assessment_id 10
    (4, 'Assignment',    'Assignment',  20, 20, '2026-11-23'),   -- assessment_id 11
    (4, 'Final Exam',    'Final Exam', 100, 60, '2027-01-15'),   -- assessment_id 12
    (5, 'CAT 1',         'CAT',         30, 20, '2026-10-20'),   -- assessment_id 13
    (5, 'Assignment',    'Assignment',  20, 20, '2026-11-24'),   -- assessment_id 14
    (5, 'Final Exam',    'Final Exam', 100, 60, '2027-01-18'),   -- assessment_id 15
    (6, 'CAT 1',         'CAT',         30, 20, '2026-03-16'),   -- assessment_id 16
    (6, 'Assignment',    'Assignment',  20, 20, '2026-04-20'),   -- assessment_id 17
    (6, 'Final Exam',    'Final Exam', 100, 60, '2026-06-08'),   -- assessment_id 18
    (7, 'CAT 1',         'CAT',         30, 20, '2026-03-17'),   -- assessment_id 19
    (7, 'Assignment',    'Assignment',  20, 20, '2026-04-21'),   -- assessment_id 20
    (7, 'Final Exam',    'Final Exam', 100, 60, '2026-06-09'),   -- assessment_id 21
    (8, 'CAT 1',         'CAT',         30, 20, '2026-03-18'),   -- assessment_id 22
    (8, 'Assignment',    'Assignment',  20, 20, '2026-04-22'),   -- assessment_id 23
    (8, 'Final Exam',    'Final Exam', 100, 60, '2026-06-10'),   -- assessment_id 24
    (9, 'CAT 1',         'CAT',         30, 20, '2027-03-15'),   -- assessment_id 25 (next term)
    (9, 'Group Project', 'Project',     40, 40, NULL);           -- assessment_id 26 (date not set)

-- Final % = (CAT/30 x 20) + (Assignment/20 x 20) + (Exam/100 x 60)
INSERT INTO assessment_scores (enrollment_id, assessment_id, score) VALUES
    (1,  1, 25), (1,  2, 17), (1,  3, 82),     -- Aline    CS101    82.87 A
    (2,  7, 20), (2,  8, 15), (2,  9, 70),     -- Aline    MATH110  70.33 B
    (3,  1, 28), (3,  2, 19), (3,  3, 90),     -- Jean     CS101    91.67 A
    (4,  4, 18), (4,  5, 14), (4,  6, 60),     -- Jean     CS201    62.00 C
    (5,  7, 27), (5,  8, 18), (5,  9, 85),     -- Grace    MATH110  87.00 A
    (6,  1, 15), (6,  2, 10), (6,  3, 45),     -- Patrick  CS101    47.00 F
    (7,  4, 22), (7,  5, 16), (7,  6, 68),     -- Diane    CS201    71.47 B
    (8,  13, 24), (8,  14, 16), (8,  15, 75),  -- Yves     MATH210  77.00 B
    (9,  7, 21), (9,  8, 14), (9,  9, 66),     -- Thierry  MATH110  67.60 C
    (10, 10, 27), (10, 11, 18), (10, 12, 88),  -- Sandrine ACC201   88.80 A
    (11, 10, 18), (11, 11, 12), (11, 12, 52),  -- Kevin    ACC201   55.20 D
    (12, 1, 26), (12, 2, 17), (12, 3, 79),     -- Nadia    CS101    81.73 A
    (13, 1, 12), (13, 2,  9), (13, 3, 38),     -- Emmanuel CS101    39.80 F
    (15, 16, 23), (15, 17, 15), (15, 18, 72),  -- Diane    CS101    73.53 B (previous term)
    (16, 16, 10), (16, 17,  8), (16, 18, 35),  -- Fabrice  CS101    35.67 F (previous term)
    (17, 19, 25), (17, 20, 17), (17, 21, 80),  -- Yves     MATH110  81.67 A (previous term)
    (18, 19, 19), (18, 20, 13), (18, 21, 58),  -- Patrick  MATH110  60.47 C (previous term)
    (19, 22, 26), (19, 23, 18), (19, 24, 84),  -- Sandrine ACC101   85.73 A (previous term)
    (20, 22, 20), (20, 23, 14), (20, 24, 62);  -- Kevin    ACC101   64.53 C (previous term)

INSERT INTO fee_structures (program_id, term_id, fee_type, amount) VALUES
    (1, 1, 'Tuition',      650000.00),
    (1, 1, 'Registration',  50000.00),
    (2, 1, 'Tuition',      600000.00),
    (2, 1, 'Registration',  50000.00),
    (3, 1, 'Tuition',      550000.00),
    (3, 1, 'Registration',  50000.00),
    (4, 1, 'Tuition',      400000.00),
    (4, 1, 'Registration',  50000.00),
    (1, 2, 'Tuition',      620000.00),     -- previous term was cheaper
    (1, 2, 'Registration',  50000.00),
    (2, 2, 'Tuition',      580000.00),
    (2, 2, 'Registration',  50000.00),
    (3, 2, 'Tuition',      530000.00),
    (3, 2, 'Registration',  50000.00);

INSERT INTO invoices (student_id, term_id, issue_date, due_date) VALUES
    (1,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 1
    (2,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 2
    (3,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 3
    (4,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 4
    (5,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 5
    (6,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 6
    (7,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 7
    (8,  1, '2026-08-15', '2026-09-30'),   -- invoice_id 8
    (10, 1, '2026-08-15', '2026-09-30'),   -- invoice_id 9
    (11, 1, '2026-08-15', '2026-09-30'),   -- invoice_id 10
    (12, 1, '2026-08-15', '2026-09-30'),   -- invoice_id 11
    (14, 1, '2026-08-15', '2026-09-30'),   -- invoice_id 12
    (15, 1, '2026-08-15', '2026-09-30'),   -- invoice_id 13
    (4,  2, '2026-01-15', '2026-02-28'),   -- invoice_id 14 (previous term)
    (5,  2, '2026-01-15', '2026-02-28'),   -- invoice_id 15
    (6,  2, '2026-01-15', '2026-02-28'),   -- invoice_id 16
    (7,  2, '2026-01-15', '2026-02-28'),   -- invoice_id 17
    (8,  2, '2026-01-15', '2026-02-28'),   -- invoice_id 18
    (10, 2, '2026-01-15', '2026-02-28'),   -- invoice_id 19
    (13, 2, '2026-01-15', '2026-02-28');   -- invoice_id 20

-- Each invoice gets one line per fee in the student's programme price list.
-- INSERT ... SELECT copies rows from a query instead of typing VALUES.
INSERT INTO invoice_items (invoice_id, fee_type, amount)
SELECT i.invoice_id, fs.fee_type, fs.amount
FROM invoices i
JOIN students       s  ON s.student_id  = i.student_id
JOIN fee_structures fs ON fs.program_id = s.program_id
                      AND fs.term_id    = i.term_id
ORDER BY i.invoice_id, fs.fee_structure_id;

INSERT INTO payments (invoice_id, payment_date, amount, payment_method, reference_no) VALUES
    (1,  '2026-08-20', 400000.00, 'Bank Transfer', 'BK-2026-0001'),
    (1,  '2026-09-25', 300000.00, 'Mobile Money',  'MM-2026-0457'),
    (2,  '2026-08-28', 375000.00, 'Bank Transfer', 'BK-2026-0019'),
    (3,  '2026-09-01',  50000.00, 'Mobile Money',  'MM-2026-0502'),
    (4,  '2026-09-10', 200000.00, 'Cash',          'CS-2026-0033'),
    (6,  '2026-08-25', 650000.00, 'Bank Transfer', 'BK-2026-0031'),
    (7,  '2026-08-30', 200000.00, 'Mobile Money',  'MM-2026-0611'),
    (7,  '2026-09-20', 125000.00, 'Mobile Money',  'MM-2026-0874'),
    (8,  '2026-09-15', 150000.00, 'Cash',          NULL),            -- no receipt number
    (10, '2026-08-18', 450000.00, 'Card',          'CD-2026-0007'),
    (11, '2026-09-05', 200000.00, 'Mobile Money',  'MM-2026-0915'),
    (12, '2026-09-12', 325000.00, 'Bank Transfer', 'BK-2026-0044'),
    (13, '2026-10-02',  50000.00, 'Cash',          NULL),
    (14, '2026-01-28', 670000.00, 'Bank Transfer', 'BK-2026-0101'),
    (15, '2026-01-30', 400000.00, 'Bank Transfer', 'BK-2026-0102'),
    (15, '2026-03-10', 270000.00, 'Mobile Money',  'MM-2026-0103'),
    (16, '2026-02-02',  50000.00, 'Mobile Money',  'MM-2026-0104'),
    (17, '2026-02-10', 580000.00, 'Card',          'CD-2026-0105'),
    (18, '2026-02-25', 500000.00, 'Cash',          NULL),
    (19, '2026-03-05', 300000.00, 'Mobile Money',  'MM-2026-0106'),
    (20, '2026-02-12', 100000.00, 'Cash',          NULL);
    -- invoices 5 and 9 have no payments at all

INSERT INTO scholarships (scholarship_name, sponsor) VALUES
    ('Merit Scholarship',       'University'),                 -- scholarship_id 1
    ('Government Bursary',      'Higher Education Council'),   -- scholarship_id 2
    ('Sports Excellence Award', 'ULK Sports Club');            -- scholarship_id 3 (not awarded yet)

INSERT INTO student_scholarships (student_id, scholarship_id, term_id, amount_awarded) VALUES
    (2, 1, 1, 325000.00),     -- Jean:     50% of tuition
    (3, 2, 1, 600000.00),     -- Grace:    full tuition
    (7, 1, 1, 275000.00),     -- Sandrine: merit award
    (6, 2, 2, 580000.00);     -- Yves:     full tuition, previous term

INSERT INTO salary_payments (lecturer_id, pay_month, gross_amount, tax_amount, other_deductions, payment_date) VALUES
    (1, '2026-09', 1800000.00, 540000.00,  90000.00, '2026-09-28'),
    (2, '2026-09', 1300000.00, 390000.00,  65000.00, '2026-09-28'),
    (3, '2026-09', 2400000.00, 720000.00, 120000.00, '2026-09-28'),
    (4, '2026-09',  900000.00, 270000.00,  45000.00, '2026-09-28'),
    (5, '2026-09', 1400000.00, 420000.00,  70000.00, '2026-09-28'),
    (6, '2026-09', 2900000.00, 870000.00, 145000.00, '2026-09-28'),
    (7, '2026-09', 1750000.00, 525000.00,  87500.00, '2026-09-28'),
    (8, '2026-09', 1250000.00, 375000.00,  62500.00, '2026-09-28'),
    (1, '2026-10', 1800000.00, 540000.00,  90000.00, '2026-10-28'),
    (2, '2026-10', 1450000.00, 435000.00,  72500.00, '2026-10-28'),   -- includes overtime
    (3, '2026-10', 2400000.00, 720000.00, 120000.00, '2026-10-28'),
    (4, '2026-10',  900000.00, 270000.00,  45000.00, '2026-10-28'),
    (5, '2026-10', 1400000.00, 420000.00,  70000.00, '2026-10-28'),
    (6, '2026-10', 2900000.00, 870000.00, 145000.00, '2026-10-28'),
    (7, '2026-10', 1750000.00, 525000.00,  87500.00, '2026-10-28'),
    (8, '2026-10', 1250000.00, 375000.00,  62500.00, '2026-10-28');


-- =====================================================================
--  PRACTICE QUERIES & VERIFICATION
-- =====================================================================

-- Q1. Academic structure: faculty > department > head of department
SELECT f.faculty_name,
       d.department_name,
       COALESCE(l.first_name || ' ' || l.last_name, '(vacant)') AS head_of_department
FROM departments d
JOIN faculties f             ON f.faculty_id    = d.faculty_id
LEFT JOIN department_heads h ON h.department_id = d.department_id
LEFT JOIN lecturers l        ON l.lecturer_id   = h.lecturer_id
ORDER BY f.faculty_name, d.department_name;

-- Q2. Lecturer teaching load this term (LEFT JOIN keeps lecturers with no classes)
SELECT l.first_name || ' ' || l.last_name AS lecturer,
       l.academic_rank,
       COUNT(DISTINCT o.offering_id)      AS courses_taught,
       COUNT(e.enrollment_id)             AS total_students
FROM lecturers l
LEFT JOIN course_offerings o ON o.lecturer_id = l.lecturer_id AND o.term_id = 1
LEFT JOIN enrollments e      ON e.offering_id = o.offering_id
GROUP BY l.lecturer_id, l.first_name, l.last_name, l.academic_rank
ORDER BY total_students DESC;

-- Q3. Transcript for one student
SELECT course_code, course_title, credits, final_percent, letter_grade
FROM final_grades
WHERE student_id = 1
ORDER BY course_code;

-- Q4. Class results per course: average, highest, pass rate
SELECT course_code,
       COUNT(*)                                                    AS students,
       ROUND(AVG(final_percent), 1)                                AS average_percent,
       MAX(final_percent)                                          AS highest,
       ROUND(100.0 * SUM(CASE WHEN letter_grade <> 'F' THEN 1 ELSE 0 END)
             / COUNT(*), 0)                                        AS pass_rate_percent
FROM final_grades
GROUP BY course_code
ORDER BY course_code;

-- Q5. GPA ranking
SELECT registration_no, student_name, credits_attempted, gpa
FROM student_gpa
ORDER BY gpa DESC;

-- Q6. Students who still owe fees
SELECT registration_no, student_name, total_billed,
       total_scholarships, total_paid, balance_due
FROM student_balances
WHERE balance_due > 0
ORDER BY balance_due DESC;

-- Q7. Fee collection summary for the term
SELECT SUM(total_billed)       AS billed,
       SUM(total_scholarships) AS scholarships,
       SUM(total_paid)         AS collected,
       SUM(balance_due)        AS outstanding
FROM student_balances;

-- Q8. Payroll for September 2026 by department (net pay is calculated)
SELECT d.department_name,
       COUNT(*)                                                  AS lecturers_paid,
       SUM(sp.gross_amount)                                      AS gross_pay,
       SUM(sp.gross_amount - sp.tax_amount - sp.other_deductions) AS net_pay
FROM salary_payments sp
JOIN lecturers   l ON l.lecturer_id   = sp.lecturer_id
JOIN departments d ON d.department_id = l.department_id
WHERE sp.pay_month = '2026-09'
GROUP BY d.department_name
ORDER BY d.department_name;
