/*
================================================================================
Topic: Recursive Common Table Expressions (Recursive CTEs)
Objective: Master recursive queries to traverse tree structures, evaluate 
           prerequisite dependency chains, and generate sequence series.
Database: PostgreSQL / MySQL 8.0+ / Oracle
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: Recursive CTE Architecture
-- =============================================================================
-- A recursive CTE references its own name. It consists of three fundamental parts:
-- 1. Anchor Member (Base Query): Runs once to seed the initial result set.
-- 2. UNION ALL: Combines the anchor rows with the recursive results.
-- 3. Recursive Member: References the CTE itself, executing iteratively until
--    it returns an empty result set (termination condition).
--
-- Syntax Note: PostgreSQL and MySQL require `WITH RECURSIVE`, whereas Oracle 
-- supports `WITH` (and `WITH RECURSIVE` in modern releases).

-- =============================================================================
-- 2. Generating a Sequence of Numbers (1 to 5)
-- =============================================================================

WITH RECURSIVE NumberSeries AS (
    -- Anchor member
    SELECT 1 AS n
    
    UNION ALL
    
    -- Recursive member
    SELECT n + 1 
    FROM NumberSeries 
    WHERE n < 5 -- Termination condition
)
SELECT n FROM NumberSeries;

-- =============================================================================
-- 3. Traversing Instructor Mentorship Hierarchy (Tree Traversal)
-- =============================================================================
-- Find the chain of mentorship starting from senior mentors down through mentees,
-- calculating hierarchy depth (level):

WITH RECURSIVE MentorshipHierarchy AS (
    -- Anchor Member: Find top-level mentors (instructors with no mentor assigned)
    SELECT 
        instructor_id,
        first_name,
        last_name,
        mentor_id,
        1 AS hierarchy_level,
        CAST(first_name || ' ' || last_name AS VARCHAR(255)) AS mentorship_path
    FROM instructors
    WHERE mentor_id IS NULL
    
    UNION ALL
    
    -- Recursive Member: Find instructors mentored by those in the previous level
    SELECT 
        i.instructor_id,
        i.first_name,
        i.last_name,
        i.mentor_id,
        mh.hierarchy_level + 1,
        CAST(mh.mentorship_path || ' -> ' || i.first_name || ' ' || i.last_name AS VARCHAR(255))
    FROM instructors i
    INNER JOIN MentorshipHierarchy mh 
        ON i.mentor_id = mh.instructor_id
)
SELECT 
    instructor_id,
    mentorship_path,
    hierarchy_level
FROM MentorshipHierarchy
ORDER BY hierarchy_level, instructor_id;

-- =============================================================================
-- 4. Course Prerequisite Chain Traversal
-- =============================================================================
-- Trace the entire prerequisite dependency chain required to take CS301:

WITH RECURSIVE PrerequisiteChain AS (
    -- Anchor Member: Immediate prerequisites for CS301 (course_id = 3)
    SELECT 
        cp.course_id,
        cp.prerequisite_course_id,
        1 AS step_depth
    FROM course_prerequisites cp
    WHERE cp.course_id = 3
    
    UNION ALL
    
    -- Recursive Member: Prerequisites of the prerequisite courses
    SELECT 
        pc.course_id,
        cp_parent.prerequisite_course_id,
        pc.step_depth + 1
    FROM PrerequisiteChain pc
    INNER JOIN course_prerequisites cp_parent 
        ON pc.prerequisite_course_id = cp_parent.course_id
)
SELECT 
    target.course_code AS target_course,
    prereq.course_code AS required_prerequisite,
    chain.step_depth
FROM PrerequisiteChain chain
INNER JOIN courses target ON chain.course_id = target.course_id
INNER JOIN courses prereq ON chain.prerequisite_course_id = prereq.course_id;

-- =============================================================================
-- 5. Practice Questions
-- =============================================================================
-- Exercise 1: Write a recursive CTE to generate all dates for the next 7 days 
--             starting from CURRENT_DATE.
-- Exercise 2: Why is UNION ALL strictly required instead of UNION in recursive CTEs?
