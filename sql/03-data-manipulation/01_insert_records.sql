/*
================================================================================
Topic: Inserting Records (Data Manipulation Language - DML)
Objective: Populate the 21 tables of the ULK University database in parent ->
           child order, letting the database generate primary key values
           (IDENTITY), and copy rows with INSERT ... SELECT.
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: same INSERT syntax (Oracle 23c+ for multi-row VALUES)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: Auto-Generated Primary Keys
-- =============================================================================
-- Every table uses 'GENERATED ALWAYS AS IDENTITY' for its primary key, so the
-- database assigns 1, 2, 3 ... automatically.
--
-- Rule: NEVER list the primary key column in an INSERT.
--   INSERT INTO faculties (faculty_name) VALUES ('Faculty of Arts');   -- correct
--   INSERT INTO faculties (faculty_id, faculty_name) VALUES (9, 'Arts');
--   -> ERROR: cannot insert a non-DEFAULT value into column "faculty_id"
--
-- Foreign key values (faculty_id inside departments, etc.) ARE typed in, and
-- must match a row that already exists. That is why parents are inserted
-- before children.
--
-- WHEN TO RUN THIS FILE: only on EMPTY tables, i.e. after
--   02-tables-and-constraints/00_drop_tables_if_needed.sql and
--   02-tables-and-constraints/01_create_tables.sql.
-- It inserts exactly the same rows as 00_master_schema_and_data.sql.
-- Running it on the master database fails with "duplicate key" errors.


-- =============================================================================
-- 2. Step-by-Step Data Insertion (Parent to Child Order)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Domain A: Academic Structure
-- -----------------------------------------------------------------------------

-- 1. Faculties (faculty_id generated: 1-3)
INSERT INTO faculties (faculty_name) VALUES
    ('Faculty of Science and Technology'),      -- 1
    ('Faculty of Business and Economics'),      -- 2
    ('Faculty of Law');                         -- 3 (no departments yet)

-- 2. Departments (department_id generated: 1-4)
INSERT INTO departments (department_name, building, faculty_id) VALUES
    ('Computer Science',          'Block A', 1),   -- 1
    ('Mathematics',               'Block B', 1),   -- 2
    ('Accounting and Finance',    'Block C', 2),   -- 3
    ('Economics',                 NULL,      2);   -- 4 (building not assigned: NULL)

-- 3. Programs (program_id generated: 1-5)
INSERT INTO programs (program_name, degree_level, duration_years, department_id) VALUES
    ('BSc Computer Science',              'Bachelor', 4, 1),   -- 1
    ('BSc Mathematics',                   'Bachelor', 4, 2),   -- 2
    ('BBA Accounting',                    'Bachelor', 4, 3),   -- 3
    ('Diploma in Information Technology', 'Diploma',  2, 1),   -- 4
    ('MSc Data Science',                  'Master',   2, 1);   -- 5 (no students yet)

-- 4. Academic Terms (term_id generated: 1-3). IDs are NOT in date order!
INSERT INTO academic_terms (academic_year, term_name, start_date, end_date) VALUES
    ('2026/2027', 'Semester 1', '2026-09-07', '2027-01-22'),   -- 1: current term
    ('2025/2026', 'Semester 2', '2026-02-02', '2026-06-19'),   -- 2: previous term
    ('2026/2027', 'Semester 2', '2027-02-08', '2027-06-25');   -- 3: next term


-- -----------------------------------------------------------------------------
-- Domain B: People
-- -----------------------------------------------------------------------------

-- 5. Lecturers (lecturer_id generated: 1-8)
INSERT INTO lecturers (first_name, last_name, email, phone, academic_rank, hire_date, monthly_salary, department_id) VALUES
    ('Claudine', 'Mukamana',     'c.mukamana@uni.example',     '+250788000001', 'Senior Lecturer',     '2015-02-01', 1800000.00, 1),  -- 1
    ('Olivier',  'Ndayisaba',    'o.ndayisaba@uni.example',    '+250788000002', 'Lecturer',            '2020-09-01', 1300000.00, 1),  -- 2
    ('Joseph',   'Nshimiyimana', 'j.nshimiyimana@uni.example', '+250788000003', 'Associate Professor', '2010-01-15', 2400000.00, 2),  -- 3
    ('Ange',     'Umutoni',      'a.umutoni@uni.example',      '+250788000004', 'Assistant Lecturer',  '2024-02-01',  900000.00, 3),  -- 4
    ('Samuel',   'Habyarimana',  's.habyarimana@uni.example',  NULL,            'Lecturer',            '2018-03-01', 1400000.00, 1),  -- 5
    ('Esther',   'Mukeshimana',  'e.mukeshimana@uni.example',  '+250788000006', 'Professor',           '2005-09-01', 2900000.00, 2),  -- 6
    ('Didier',   'Nkurunziza',   'd.nkurunziza@uni.example',   '+250788000007', 'Senior Lecturer',     '2016-01-10', 1750000.00, 3),  -- 7
    ('Josiane',  'Uwimana',      'j.uwimana@uni.example',      NULL,            'Lecturer',            '2022-02-01', 1250000.00, 4);  -- 8

-- 6. Department Heads (one head per department; Accounting and Economics have none yet)
INSERT INTO department_heads (department_id, lecturer_id, start_date) VALUES
    (1, 1, '2023-07-01'),
    (2, 3, '2021-07-01');

-- 7. Students (student_id generated: 1-15). status could be left out: it defaults to 'Active'.
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
    ('2026CS001', 'Belinda',  'Ishimwe',       'belinda.ishimwe@uni.example',       '+250789100015', '2007-03-30', 2026, 'Active',    1);  -- 15


-- -----------------------------------------------------------------------------
-- Domain C: Teaching
-- -----------------------------------------------------------------------------

-- 8. Courses (course_id generated: 1-9)
INSERT INTO courses (course_code, course_title, credits, department_id) VALUES
    ('CS101',   'Introduction to Databases',  4, 1),   -- 1
    ('CS201',   'Data Structures',            4, 1),   -- 2
    ('MATH110', 'Linear Algebra',             3, 2),   -- 3
    ('ACC101',  'Principles of Accounting',   3, 3),   -- 4
    ('CS301',   'Database Systems II',        4, 1),   -- 5
    ('CS401',   'Big Data Analytics',         4, 1),   -- 6 (never offered yet)
    ('MATH210', 'Probability and Statistics', 3, 2),   -- 7
    ('ACC201',  'Financial Accounting',       3, 3),   -- 8
    ('ECO101',  'Principles of Economics',    3, 4);   -- 9

-- 9. Course Prerequisites
--    CS101 -> CS201 -> CS301 -> CS401 <- MATH210 <- MATH110 ;  ACC101 -> ACC201
INSERT INTO course_prerequisites (course_id, prerequisite_course_id) VALUES
    (2, 1),   -- CS201   needs CS101
    (5, 2),   -- CS301   needs CS201
    (6, 5),   -- CS401   needs CS301
    (6, 7),   -- CS401   needs MATH210
    (7, 3),   -- MATH210 needs MATH110
    (8, 4);   -- ACC201  needs ACC101

-- 10. Course Offerings (offering_id generated: 1-10)
INSERT INTO course_offerings (course_id, term_id, lecturer_id, room, capacity) VALUES
    (1, 1, 1,    'A-101', 60),     -- 1  CS101   current term
    (2, 1, 2,    'A-204', 40),     -- 2  CS201   current term
    (3, 1, 3,    'B-012', 80),     -- 3  MATH110 current term
    (8, 1, 7,    'C-110', 50),     -- 4  ACC201  current term
    (7, 1, 6,    'B-014', 60),     -- 5  MATH210 current term
    (1, 2, 1,    'A-101', 60),     -- 6  CS101   previous term
    (3, 2, 3,    'B-012', 80),     -- 7  MATH110 previous term
    (4, 2, 7,    'C-110', 50),     -- 8  ACC101  previous term
    (5, 3, 5,    'A-204', 40),     -- 9  CS301   next term
    (9, 3, NULL, NULL,    45);     -- 10 ECO101  next term (lecturer and room not assigned)

-- 11. Enrollments (enrollment_id generated: 1-25)
INSERT INTO enrollments (student_id, offering_id, enrollment_date, status) VALUES
    (1,  1,  '2026-09-01', 'Completed'),    -- 1   Aline    CS101
    (1,  3,  '2026-09-01', 'Completed'),    -- 2   Aline    MATH110
    (2,  1,  '2026-09-02', 'Completed'),    -- 3   Jean     CS101
    (2,  2,  '2026-09-02', 'Completed'),    -- 4   Jean     CS201
    (3,  3,  '2026-09-01', 'Completed'),    -- 5   Grace    MATH110
    (4,  1,  '2026-09-03', 'Completed'),    -- 6   Patrick  CS101
    (5,  2,  '2026-09-04', 'Completed'),    -- 7   Diane    CS201
    (6,  5,  '2026-09-02', 'Completed'),    -- 8   Yves     MATH210
    (14, 3,  '2026-09-03', 'Completed'),    -- 9   Thierry  MATH110
    (7,  4,  '2026-09-01', 'Completed'),    -- 10  Sandrine ACC201
    (8,  4,  '2026-09-04', 'Completed'),    -- 11  Kevin    ACC201
    (11, 1,  '2026-09-05', 'Completed'),    -- 12  Nadia    CS101
    (12, 1,  '2026-09-05', 'Completed'),    -- 13  Emmanuel CS101
    (10, 2,  '2026-09-02', 'Dropped'),      -- 14  Fabrice  CS201
    (5,  6,  '2026-02-03', 'Completed'),    -- 15  Diane    CS101   previous term
    (10, 6,  '2026-02-04', 'Completed'),    -- 16  Fabrice  CS101   previous term
    (6,  7,  '2026-02-03', 'Completed'),    -- 17  Yves     MATH110 previous term
    (4,  7,  '2026-02-05', 'Completed'),    -- 18  Patrick  MATH110 previous term
    (7,  8,  '2026-02-03', 'Completed'),    -- 19  Sandrine ACC101  previous term
    (8,  8,  '2026-02-03', 'Completed'),    -- 20  Kevin    ACC101  previous term
    (13, 8,  '2026-02-06', 'Dropped'),      -- 21  Chantal  ACC101  previous term
    (2,  9,  '2027-01-25', 'Registered'),   -- 22  Jean     CS301   next term
    (1,  9,  '2027-01-26', 'Registered'),   -- 23  Aline    CS301   next term
    (7,  10, '2027-01-25', 'Registered'),   -- 24  Sandrine ECO101  next term
    (8,  10, '2027-01-27', 'Registered');   -- 25  Kevin    ECO101  next term


-- -----------------------------------------------------------------------------
-- Domain D: Grades
-- -----------------------------------------------------------------------------

-- 12. Grade Scale (grade_id generated: 1-5; letter_grade is UNIQUE)
INSERT INTO grade_scale (letter_grade, min_percent, max_percent, grade_point, description) VALUES
    ('A', 80.00, 100.00, 4.00, 'Excellent'),
    ('B', 70.00,  79.99, 3.00, 'Very good'),
    ('C', 60.00,  69.99, 2.00, 'Good'),
    ('D', 50.00,  59.99, 1.00, 'Pass'),
    ('F',  0.00,  49.99, 0.00, 'Fail');

-- 13. Assessments (assessment_id generated: 1-26)
INSERT INTO assessments (offering_id, assessment_name, assessment_type, max_score, weight_percent, due_date) VALUES
    (1, 'CAT 1',         'CAT',         30, 20, '2026-10-15'),   -- 1
    (1, 'Assignment',    'Assignment',  20, 20, '2026-11-20'),   -- 2
    (1, 'Final Exam',    'Final Exam', 100, 60, '2027-01-12'),   -- 3
    (2, 'CAT 1',         'CAT',         30, 20, '2026-10-16'),   -- 4
    (2, 'Assignment',    'Assignment',  20, 20, '2026-11-21'),   -- 5
    (2, 'Final Exam',    'Final Exam', 100, 60, '2027-01-13'),   -- 6
    (3, 'CAT 1',         'CAT',         30, 20, '2026-10-17'),   -- 7
    (3, 'Assignment',    'Assignment',  20, 20, '2026-11-22'),   -- 8
    (3, 'Final Exam',    'Final Exam', 100, 60, '2027-01-14'),   -- 9
    (4, 'CAT 1',         'CAT',         30, 20, '2026-10-19'),   -- 10
    (4, 'Assignment',    'Assignment',  20, 20, '2026-11-23'),   -- 11
    (4, 'Final Exam',    'Final Exam', 100, 60, '2027-01-15'),   -- 12
    (5, 'CAT 1',         'CAT',         30, 20, '2026-10-20'),   -- 13
    (5, 'Assignment',    'Assignment',  20, 20, '2026-11-24'),   -- 14
    (5, 'Final Exam',    'Final Exam', 100, 60, '2027-01-18'),   -- 15
    (6, 'CAT 1',         'CAT',         30, 20, '2026-03-16'),   -- 16
    (6, 'Assignment',    'Assignment',  20, 20, '2026-04-20'),   -- 17
    (6, 'Final Exam',    'Final Exam', 100, 60, '2026-06-08'),   -- 18
    (7, 'CAT 1',         'CAT',         30, 20, '2026-03-17'),   -- 19
    (7, 'Assignment',    'Assignment',  20, 20, '2026-04-21'),   -- 20
    (7, 'Final Exam',    'Final Exam', 100, 60, '2026-06-09'),   -- 21
    (8, 'CAT 1',         'CAT',         30, 20, '2026-03-18'),   -- 22
    (8, 'Assignment',    'Assignment',  20, 20, '2026-04-22'),   -- 23
    (8, 'Final Exam',    'Final Exam', 100, 60, '2026-06-10'),   -- 24
    (9, 'CAT 1',         'CAT',         30, 20, '2027-03-15'),   -- 25
    (9, 'Group Project', 'Project',     40, 40, NULL);           -- 26 (due date not set)

-- 14. Assessment Scores (score_id generated; UNIQUE (enrollment_id, assessment_id)
--     stops a student getting two marks for the same assessment)
INSERT INTO assessment_scores (enrollment_id, assessment_id, score) VALUES
    (1,  1, 25), (1,  2, 17), (1,  3, 82),     -- Aline    CS101
    (2,  7, 20), (2,  8, 15), (2,  9, 70),     -- Aline    MATH110
    (3,  1, 28), (3,  2, 19), (3,  3, 90),     -- Jean     CS101
    (4,  4, 18), (4,  5, 14), (4,  6, 60),     -- Jean     CS201
    (5,  7, 27), (5,  8, 18), (5,  9, 85),     -- Grace    MATH110
    (6,  1, 15), (6,  2, 10), (6,  3, 45),     -- Patrick  CS101
    (7,  4, 22), (7,  5, 16), (7,  6, 68),     -- Diane    CS201
    (8,  13, 24), (8,  14, 16), (8,  15, 75),  -- Yves     MATH210
    (9,  7, 21), (9,  8, 14), (9,  9, 66),     -- Thierry  MATH110
    (10, 10, 27), (10, 11, 18), (10, 12, 88),  -- Sandrine ACC201
    (11, 10, 18), (11, 11, 12), (11, 12, 52),  -- Kevin    ACC201
    (12, 1, 26), (12, 2, 17), (12, 3, 79),     -- Nadia    CS101
    (13, 1, 12), (13, 2,  9), (13, 3, 38),     -- Emmanuel CS101
    (15, 16, 23), (15, 17, 15), (15, 18, 72),  -- Diane    CS101   previous term
    (16, 16, 10), (16, 17,  8), (16, 18, 35),  -- Fabrice  CS101   previous term
    (17, 19, 25), (17, 20, 17), (17, 21, 80),  -- Yves     MATH110 previous term
    (18, 19, 19), (18, 20, 13), (18, 21, 58),  -- Patrick  MATH110 previous term
    (19, 22, 26), (19, 23, 18), (19, 24, 84),  -- Sandrine ACC101  previous term
    (20, 22, 20), (20, 23, 14), (20, 24, 62);  -- Kevin    ACC101  previous term


-- -----------------------------------------------------------------------------
-- Domain E: Finance
-- -----------------------------------------------------------------------------

-- 15. Fee Structures: the price list per programme and term (fee_structure_id 1-14)
INSERT INTO fee_structures (program_id, term_id, fee_type, amount) VALUES
    (1, 1, 'Tuition',      650000.00),
    (1, 1, 'Registration',  50000.00),
    (2, 1, 'Tuition',      600000.00),
    (2, 1, 'Registration',  50000.00),
    (3, 1, 'Tuition',      550000.00),
    (3, 1, 'Registration',  50000.00),
    (4, 1, 'Tuition',      400000.00),
    (4, 1, 'Registration',  50000.00),
    (1, 2, 'Tuition',      620000.00),
    (1, 2, 'Registration',  50000.00),
    (2, 2, 'Tuition',      580000.00),
    (2, 2, 'Registration',  50000.00),
    (3, 2, 'Tuition',      530000.00),
    (3, 2, 'Registration',  50000.00);

-- 16. Invoices: one bill per student per term (invoice_id generated: 1-20)
INSERT INTO invoices (student_id, term_id, issue_date, due_date) VALUES
    (1,  1, '2026-08-15', '2026-09-30'),   -- 1
    (2,  1, '2026-08-15', '2026-09-30'),   -- 2
    (3,  1, '2026-08-15', '2026-09-30'),   -- 3
    (4,  1, '2026-08-15', '2026-09-30'),   -- 4
    (5,  1, '2026-08-15', '2026-09-30'),   -- 5
    (6,  1, '2026-08-15', '2026-09-30'),   -- 6
    (7,  1, '2026-08-15', '2026-09-30'),   -- 7
    (8,  1, '2026-08-15', '2026-09-30'),   -- 8
    (10, 1, '2026-08-15', '2026-09-30'),   -- 9
    (11, 1, '2026-08-15', '2026-09-30'),   -- 10
    (12, 1, '2026-08-15', '2026-09-30'),   -- 11
    (14, 1, '2026-08-15', '2026-09-30'),   -- 12
    (15, 1, '2026-08-15', '2026-09-30'),   -- 13
    (4,  2, '2026-01-15', '2026-02-28'),   -- 14 previous term
    (5,  2, '2026-01-15', '2026-02-28'),   -- 15
    (6,  2, '2026-01-15', '2026-02-28'),   -- 16
    (7,  2, '2026-01-15', '2026-02-28'),   -- 17
    (8,  2, '2026-01-15', '2026-02-28'),   -- 18
    (10, 2, '2026-01-15', '2026-02-28'),   -- 19
    (13, 2, '2026-01-15', '2026-02-28');   -- 20

-- 17. Invoice Items with INSERT ... SELECT
--     Instead of typing 40 rows, copy each student's fees from the price list.
--     The SELECT returns (invoice_id, fee_type, amount) rows, which are inserted.
INSERT INTO invoice_items (invoice_id, fee_type, amount)
SELECT i.invoice_id, fs.fee_type, fs.amount
FROM invoices i
JOIN students       s  ON s.student_id  = i.student_id
JOIN fee_structures fs ON fs.program_id = s.program_id
                      AND fs.term_id    = i.term_id
ORDER BY i.invoice_id, fs.fee_structure_id;

-- 18. Payments (payment_id generated: 1-21). Some cash payments have no reference (NULL).
INSERT INTO payments (invoice_id, payment_date, amount, payment_method, reference_no) VALUES
    (1,  '2026-08-20', 400000.00, 'Bank Transfer', 'BK-2026-0001'),
    (1,  '2026-09-25', 300000.00, 'Mobile Money',  'MM-2026-0457'),
    (2,  '2026-08-28', 375000.00, 'Bank Transfer', 'BK-2026-0019'),
    (3,  '2026-09-01',  50000.00, 'Mobile Money',  'MM-2026-0502'),
    (4,  '2026-09-10', 200000.00, 'Cash',          'CS-2026-0033'),
    (6,  '2026-08-25', 650000.00, 'Bank Transfer', 'BK-2026-0031'),
    (7,  '2026-08-30', 200000.00, 'Mobile Money',  'MM-2026-0611'),
    (7,  '2026-09-20', 125000.00, 'Mobile Money',  'MM-2026-0874'),
    (8,  '2026-09-15', 150000.00, 'Cash',          NULL),
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

-- 19. Scholarships (scholarship_id generated: 1-3)
INSERT INTO scholarships (scholarship_name, sponsor) VALUES
    ('Merit Scholarship',       'University'),
    ('Government Bursary',      'Higher Education Council'),
    ('Sports Excellence Award', 'ULK Sports Club');            -- not awarded yet

-- 20. Student Scholarships (UNIQUE (student_id, scholarship_id, term_id))
INSERT INTO student_scholarships (student_id, scholarship_id, term_id, amount_awarded) VALUES
    (2, 1, 1, 325000.00),     -- Jean:     50% of tuition
    (3, 2, 1, 600000.00),     -- Grace:    full tuition
    (7, 1, 1, 275000.00),     -- Sandrine: merit award
    (6, 2, 2, 580000.00);     -- Yves:     full tuition, previous term

-- 21. Salary Payments (UNIQUE (lecturer_id, pay_month): paid once per month)
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


-- =============================================================================
-- 3. Verification: Count the Rows in Every Table
-- =============================================================================

SELECT 'faculties' AS table_name, COUNT(*) AS total_rows FROM faculties   -- 3
UNION ALL SELECT 'departments',          COUNT(*) FROM departments          -- 4
UNION ALL SELECT 'programs',             COUNT(*) FROM programs             -- 5
UNION ALL SELECT 'academic_terms',       COUNT(*) FROM academic_terms       -- 3
UNION ALL SELECT 'lecturers',            COUNT(*) FROM lecturers            -- 8
UNION ALL SELECT 'department_heads',     COUNT(*) FROM department_heads     -- 2
UNION ALL SELECT 'students',             COUNT(*) FROM students             -- 15
UNION ALL SELECT 'courses',              COUNT(*) FROM courses              -- 9
UNION ALL SELECT 'course_prerequisites', COUNT(*) FROM course_prerequisites -- 6
UNION ALL SELECT 'course_offerings',     COUNT(*) FROM course_offerings     -- 10
UNION ALL SELECT 'enrollments',          COUNT(*) FROM enrollments          -- 25
UNION ALL SELECT 'grade_scale',          COUNT(*) FROM grade_scale          -- 5
UNION ALL SELECT 'assessments',          COUNT(*) FROM assessments          -- 26
UNION ALL SELECT 'assessment_scores',    COUNT(*) FROM assessment_scores    -- 57
UNION ALL SELECT 'fee_structures',       COUNT(*) FROM fee_structures       -- 14
UNION ALL SELECT 'invoices',             COUNT(*) FROM invoices             -- 20
UNION ALL SELECT 'invoice_items',        COUNT(*) FROM invoice_items        -- 40
UNION ALL SELECT 'payments',             COUNT(*) FROM payments             -- 21
UNION ALL SELECT 'scholarships',         COUNT(*) FROM scholarships         -- 3
UNION ALL SELECT 'student_scholarships', COUNT(*) FROM student_scholarships -- 4
UNION ALL SELECT 'salary_payments',      COUNT(*) FROM salary_payments;     -- 16

-- NEXT: the views final_grades, student_gpa and student_balances (used from
-- module 06 on) are created in 09-views/01_creating_views.sql. If you built
-- the database with these module files, run that file now.


-- =============================================================================
-- 4. Practice Exercises
-- =============================================================================
-- Run these inside BEGIN; ... ROLLBACK; so the sample data stays unchanged.
-- Exercise 1: Insert a new course 'CS210 Web Development' (3 credits, department 1).
--             Use RETURNING course_id to see the ID the database generated.
-- Exercise 2: Insert a new student into 'MSc Data Science' (program 5) without
--             giving a status. Which status is stored, and why?
-- Exercise 3: Try to insert an enrollment for student_id 99. What error do you
--             get, and which constraint produces it?
