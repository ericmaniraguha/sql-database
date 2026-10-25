/*
================================================================================
Topic: Table Creation and Fundamental Data Types
Objective: Define and create the 21 relational tables of the ULK University
           database schema with auto-generated identity primary keys (PostgreSQL
           GENERATED ALWAYS AS IDENTITY).
Database: PostgreSQL (pgAdmin)
          MySQL 8: replace "INTEGER GENERATED ALWAYS AS IDENTITY" with
                   "INT AUTO_INCREMENT"
          Oracle:  replace INTEGER with NUMBER and keep GENERATED ALWAYS AS IDENTITY
================================================================================
*/

-- =====================================================================
--  ULK UNIVERSITY DATABASE - TABLE CREATION
--  Academic structure, lecturers, students, courses, grades and finance
--
--  Naming rules used everywhere (teach these first!):
--    * table names are plural, lowercase, snake_case      -> lecturers
--    * every primary key is <singular>_id                  -> lecturer_id
--    * primary keys are AUTO-GENERATED and CANNOT be inserted manually:
--      -> INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
--      (PostgreSQL rejects any manual primary key insertion in INSERT statements)
--    * a foreign key has the SAME name as the key it uses  -> lecturer_id
--    * no abbreviations: first_name, not fname
--    * money is DECIMAL(12,2), never FLOAT
--    * values that can be calculated are NOT stored; they live in VIEWS
--      (final grades, GPA, fee balances)
--
--  Table Architecture
--    A. ACADEMIC STRUCTURE : faculties, departments, programs, academic_terms
--    B. PEOPLE             : lecturers, department_heads, students
--    C. TEACHING           : courses, course_prerequisites,
--                            course_offerings, enrollments
--    D. GRADES             : grade_scale, assessments, assessment_scores
--    E. FINANCE            : fee_structures, invoices, invoice_items,
--                            payments, scholarships, student_scholarships,
--                            salary_payments
--
--  Tables are created PARENT FIRST: a table can only reference
--  (FOREIGN KEY) a table that already exists.
-- =====================================================================

-- NOTE: These tables already exist if you ran 00_master_schema_and_data.sql.
--       Run '00_drop_tables_if_needed.sql' first to rebuild them from scratch.


-- =====================================================================
--  A. ACADEMIC STRUCTURE
-- =====================================================================

-- 1. One row per faculty / school / college of the university
CREATE TABLE faculties (
    faculty_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_name    VARCHAR(100) NOT NULL UNIQUE
);

-- 2. One row per department. Every department belongs to one faculty.
CREATE TABLE departments (
    department_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building        VARCHAR(50),
    faculty_id      INTEGER      NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculties (faculty_id)
);

-- 3. One row per degree programme a student can register for
CREATE TABLE programs (
    program_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_name    VARCHAR(100) NOT NULL UNIQUE,   -- e.g. 'BSc Computer Science'
    degree_level    VARCHAR(20)  NOT NULL
                    CHECK (degree_level IN ('Diploma', 'Bachelor', 'Master', 'PhD')),
    duration_years  INTEGER      NOT NULL CHECK (duration_years BETWEEN 1 AND 7),
    department_id   INTEGER      NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

-- 4. One row per semester / term
CREATE TABLE academic_terms (
    term_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    academic_year   VARCHAR(9)   NOT NULL,          -- e.g. '2026/2027'
    term_name       VARCHAR(20)  NOT NULL,          -- e.g. 'Semester 1'
    start_date      DATE         NOT NULL,
    end_date        DATE         NOT NULL,
    CHECK (end_date > start_date),
    UNIQUE (academic_year, term_name)
);


-- =====================================================================
--  B. PEOPLE
-- =====================================================================

-- 5. One row per lecturer. Personal and employment details live only here.
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

-- 6. Who heads each department (auto-generated department_head_id)
CREATE TABLE department_heads (
    department_head_id INTEGER   GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id      INTEGER   NOT NULL UNIQUE,   -- one head per department
    lecturer_id        INTEGER   NOT NULL UNIQUE,   -- a lecturer heads at most one department
    start_date         DATE      NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id),
    FOREIGN KEY (lecturer_id)   REFERENCES lecturers (lecturer_id)
);

-- 7. One row per student
CREATE TABLE students (
    student_id      INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_no VARCHAR(20)  NOT NULL UNIQUE,   -- student ID printed on physical card
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

-- 8. The course CATALOGUE: what can be taught (does not change each term)
CREATE TABLE courses (
    course_id       INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code     VARCHAR(10)  NOT NULL UNIQUE,   -- e.g. 'CS101'
    course_title    VARCHAR(100) NOT NULL,
    credits         INTEGER      NOT NULL CHECK (credits BETWEEN 1 AND 20),
    department_id   INTEGER      NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

-- 9. Which course must be passed before another. Both columns point at
--    courses, so the table forms a hierarchy (walked with recursive CTEs).
CREATE TABLE course_prerequisites (
    course_prerequisite_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id              INTEGER NOT NULL,        -- the course being taken
    prerequisite_course_id INTEGER NOT NULL,        -- the course required first
    FOREIGN KEY (course_id)              REFERENCES courses (course_id),
    FOREIGN KEY (prerequisite_course_id) REFERENCES courses (course_id),
    UNIQUE (course_id, prerequisite_course_id),
    CHECK (course_id <> prerequisite_course_id)     -- a course cannot require itself
);

-- 10. A course actually RUNNING in a given term, taught by a given lecturer.
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

-- 11. Junction table: which student is registered in which offering.
CREATE TABLE enrollments (
    enrollment_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id      INTEGER      NOT NULL,
    offering_id     INTEGER      NOT NULL,
    enrollment_date DATE         NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'Registered'
                    CHECK (status IN ('Registered', 'Dropped', 'Completed')),
    FOREIGN KEY (student_id)  REFERENCES students (student_id),
    FOREIGN KEY (offering_id) REFERENCES course_offerings (offering_id),
    UNIQUE (student_id, offering_id)                -- prevents double registration
);


-- =====================================================================
--  D. GRADES
-- =====================================================================

-- 12. Converts a final percentage into a letter grade and grade point.
CREATE TABLE grade_scale (
    grade_id        INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    letter_grade    VARCHAR(2)   NOT NULL UNIQUE,
    min_percent     DECIMAL(5,2) NOT NULL,
    max_percent     DECIMAL(5,2) NOT NULL,
    grade_point     DECIMAL(3,2) NOT NULL,
    description     VARCHAR(30),
    CHECK (min_percent <= max_percent)
);

-- 13. Assessment items in an offering: CAT, assignment, final exam...
CREATE TABLE assessments (
    assessment_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    offering_id     INTEGER      NOT NULL,
    assessment_name VARCHAR(50)  NOT NULL,          -- e.g. 'CAT 1'
    assessment_type VARCHAR(20)  NOT NULL
                    CHECK (assessment_type IN ('CAT', 'Assignment', 'Project',
                           'Lab', 'Final Exam')),
    max_score       DECIMAL(5,2) NOT NULL CHECK (max_score > 0),
    weight_percent  DECIMAL(5,2) NOT NULL CHECK (weight_percent BETWEEN 0 AND 100),
    due_date        DATE,
    FOREIGN KEY (offering_id) REFERENCES course_offerings (offering_id),
    UNIQUE (offering_id, assessment_name)
);

-- 14. One mark per student per assessment (auto-generated score_id)
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

-- 15. Price list: what each programme is charged per term
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

-- 16. One bill per student per term
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

-- 17. The lines on a bill
CREATE TABLE invoice_items (
    invoice_item_id INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id      INTEGER       NOT NULL,
    fee_type        VARCHAR(30)   NOT NULL,
    amount          DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id)
);

-- 18. Money received against an invoice
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

-- 19. Catalogue of scholarships and bursaries
CREATE TABLE scholarships (
    scholarship_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scholarship_name VARCHAR(100) NOT NULL UNIQUE,
    sponsor          VARCHAR(100) NOT NULL
);

-- 20. Which student received which scholarship, for which term, and how much
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

-- 21. Monthly payroll for lecturers
CREATE TABLE salary_payments (
    salary_payment_id INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lecturer_id       INTEGER       NOT NULL,
    pay_month         CHAR(7)       NOT NULL,       -- 'YYYY-MM', e.g. '2026-09'
    gross_amount      DECIMAL(12,2) NOT NULL CHECK (gross_amount > 0),
    tax_amount        DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    other_deductions  DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (other_deductions >= 0),
    payment_date      DATE          NOT NULL,
    FOREIGN KEY (lecturer_id) REFERENCES lecturers (lecturer_id),
    UNIQUE (lecturer_id, pay_month)                 -- paid once per month
);


-- =====================================================================
--  Next Curriculum Steps:
--  * Module 02 - File 02: Primary & Foreign Keys (02_primary_foreign_keys.sql)
--  * Module 02 - File 03: Constraints Validation (03_check_unique_constraints.sql)
--  * Module 02 - File 04: Schema Evolution (04_alter_tables.sql)
--  * Module 03: Data Insertion (03-data-manipulation/01_insert_records.sql)
--  * Module 09: Dynamic Views (09-views/01_creating_views.sql)
--    The views final_grades, student_gpa and student_balances are used from
--    module 06 onwards. 00_master_schema_and_data.sql creates them for you.
-- =====================================================================
