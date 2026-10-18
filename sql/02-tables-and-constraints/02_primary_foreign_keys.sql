/*
================================================================================
Topic: Primary Keys, Foreign Keys, and Referential Integrity
Objective: Understand relational integrity, define primary and foreign key 
           constraints, and configure cascading actions.
Database: PostgreSQL / MySQL / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- - PRIMARY KEY: Uniquely identifies each record in a table. It cannot contain 
--   NULL values and enforces an implicit unique index.
-- - FOREIGN KEY: Enforces referential integrity by linking a column in a child 
--   table to the primary key of a parent table.
-- - Referential Actions:
--     * ON DELETE RESTRICT / NO ACTION: Blocks parent deletion if child exists.
--     * ON DELETE CASCADE: Automatically deletes child rows when parent is deleted.
--     * ON DELETE SET NULL: Sets child foreign key to NULL when parent is deleted.

-- =============================================================================
-- 2. Adding Primary and Foreign Key Constraints via ALTER TABLE
-- =============================================================================

-- Add Foreign Key from instructors to departments
ALTER TABLE instructors
ADD CONSTRAINT fk_instructors_department
FOREIGN KEY (department_id) 
REFERENCES departments(department_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- Add Foreign Key from students to departments
ALTER TABLE students
ADD CONSTRAINT fk_students_department
FOREIGN KEY (department_id) 
REFERENCES departments(department_id)
ON DELETE RESTRICT;

-- Add Foreign Keys from courses to departments & instructors
ALTER TABLE courses
ADD CONSTRAINT fk_courses_department
FOREIGN KEY (department_id) 
REFERENCES departments(department_id)
ON DELETE RESTRICT;

ALTER TABLE courses
ADD CONSTRAINT fk_courses_instructor
FOREIGN KEY (instructor_id) 
REFERENCES instructors(instructor_id)
ON DELETE SET NULL;

-- Add Foreign Keys for enrollments
ALTER TABLE enrollments
ADD CONSTRAINT fk_enrollments_student
FOREIGN KEY (student_id) 
REFERENCES students(student_id)
ON DELETE CASCADE;

ALTER TABLE enrollments
ADD CONSTRAINT fk_enrollments_course
FOREIGN KEY (course_id) 
REFERENCES courses(course_id)
ON DELETE RESTRICT;

-- =============================================================================
-- 3. Composite Primary Key Example (Course Prerequisites)
-- =============================================================================
-- A course may have multiple prerequisites, and a prerequisite can belong to 
-- multiple courses (Many-to-Many self-referencing relationship).

CREATE TABLE course_prerequisites (
    course_id               INT NOT NULL,
    prerequisite_course_id  INT NOT NULL,
    minimum_grade           VARCHAR(2) DEFAULT 'C',
    
    -- Composite Primary Key: Combination of both IDs must be unique
    CONSTRAINT pk_course_prerequisites 
        PRIMARY KEY (course_id, prerequisite_course_id),
        
    CONSTRAINT fk_cp_course 
        FOREIGN KEY (course_id) 
        REFERENCES courses(course_id) 
        ON DELETE CASCADE,
        
    CONSTRAINT fk_cp_prerequisite 
        FOREIGN KEY (prerequisite_course_id) 
        REFERENCES courses(course_id) 
        ON DELETE CASCADE
);

-- =============================================================================
-- 4. Practice Questions
-- =============================================================================
-- Exercise 1: Why is ON DELETE CASCADE safe for enrollments when a student is deleted,
--             but dangerous if applied from departments to students?
-- Exercise 2: Write a foreign key definition with ON DELETE SET NULL for a 
--             'department_head_id' column inside the departments table.
