/*
================================================================================
Topic: Constraints: UNIQUE, CHECK, NOT NULL, and DEFAULT
Objective: Learn how to enforce domain integrity, prevent invalid data entry, 
           and maintain data quality using SQL constraints.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Constraints enforce business logic and data integrity at the database layer:
-- - NOT NULL: Prohibits missing/null values in a column.
-- - UNIQUE: Ensures all values in a column or set of columns are distinct.
-- - CHECK: Validates that all values in a column satisfy a Boolean expression.
-- - DEFAULT: Assigns an automatic fallback value when no value is supplied.

-- =============================================================================
-- 2. Applying UNIQUE Constraints
-- =============================================================================

-- Ensure department codes and names are globally unique
ALTER TABLE departments
ADD CONSTRAINT uq_departments_code UNIQUE (department_code);

ALTER TABLE departments
ADD CONSTRAINT uq_departments_name UNIQUE (department_name);

-- Ensure instructor and student email addresses are unique
ALTER TABLE instructors
ADD CONSTRAINT uq_instructors_email UNIQUE (email);

ALTER TABLE students
ADD CONSTRAINT uq_students_email UNIQUE (email);

-- Ensure course code (e.g., 'CS101') is unique
ALTER TABLE courses
ADD CONSTRAINT uq_courses_code UNIQUE (course_code);

-- Composite Unique Constraint: A student can only enroll once in the same course during the same term
ALTER TABLE enrollments
ADD CONSTRAINT uq_student_term_course UNIQUE (student_id, course_id, semester, academic_year);

-- =============================================================================
-- 3. Applying CHECK Constraints
-- =============================================================================

-- Department budget must not be negative
ALTER TABLE departments
ADD CONSTRAINT chk_departments_budget CHECK (budget >= 0.00);

-- Instructor salary must be positive and have a minimum wage
ALTER TABLE instructors
ADD CONSTRAINT chk_instructors_salary CHECK (salary >= 20000.00);

-- Student GPA must be between 0.00 and 4.00
ALTER TABLE students
ADD CONSTRAINT chk_students_gpa CHECK (gpa >= 0.00 AND gpa <= 4.00);

-- Student status must belong to allowed categories
ALTER TABLE students
ADD CONSTRAINT chk_students_status CHECK (status IN ('Active', 'Suspended', 'Graduated', 'Withdrawn'));

-- Enrollment numeric grade must be between 0 and 100
ALTER TABLE enrollments
ADD CONSTRAINT chk_enrollments_numeric_grade CHECK (numeric_grade >= 0.00 AND numeric_grade <= 100.00);

-- Course credits must be between 1 and 6
ALTER TABLE courses
ADD CONSTRAINT chk_courses_credits CHECK (credits BETWEEN 1 AND 6);

-- =============================================================================
-- 4. Testing Constraint Violations (Expected to Fail)
-- =============================================================================

-- The following statement violates chk_students_gpa:
-- INSERT INTO students (first_name, last_name, email, birth_date, gpa) 
-- VALUES ('John', 'Doe', 'johndoe@ulk.ac.rw', '2001-05-15', 4.50); 
-- ERROR: Check constraint violation

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Write a CHECK constraint ensuring instructor email contains an '@' symbol.
-- Exercise 2: Write a CHECK constraint ensuring semester is only 'Fall', 'Spring', or 'Summer'.
