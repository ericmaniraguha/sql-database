/*
================================================================================
Topic: Oracle Database-Specific Features and Capabilities
Objective: Understand Oracle enterprise features: VARCHAR2, Sequences, the DUAL 
           table, NVL/NVL2, ROWNUM, and hierarchical CONNECT BY queries.
Database: Oracle Database (12c / 19c / 21c / 23c)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview
-- =============================================================================
-- Oracle Database is an enterprise-grade RDBMS with proprietary SQL syntax,
-- distinct data types (e.g. VARCHAR2, NUMBER), and specialized hierarchical operators.

-- =============================================================================
-- 2. The DUAL Dummy Table
-- =============================================================================
-- In Oracle, all SELECT statements historically required a FROM clause.
-- DUAL is a special single-row, single-column table provided for evaluating expressions:

/*
SELECT SYSDATE AS current_oracle_time FROM DUAL;
SELECT USER AS current_oracle_user FROM DUAL;
SELECT 25 * 4 AS calculation FROM DUAL;
*/

-- =============================================================================
-- 3. Oracle Data Types: VARCHAR2 and NUMBER
-- =============================================================================
-- - VARCHAR2(n): Variable-length character string (up to 4000 bytes in SQL, or 32767 with extended strings).
-- - NUMBER(p, s): Universal numeric type handling integers, floats, and decimals.

/*
CREATE TABLE oracle_course_log (
    log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    action_msg  VARCHAR2(255) NOT NULL,
    logged_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/

-- =============================================================================
-- 4. Oracle NULL Handling: NVL and NVL2
-- =============================================================================
-- - NVL(val, default): Returns 'default' if 'val' is NULL (analogous to COALESCE).
-- - NVL2(val, if_not_null, if_null): If val is NOT null returns 2nd arg, otherwise 3rd arg.

/*
SELECT 
    instructor_id,
    first_name,
    NVL(office_number, 'No Office Assigned') AS office_info,
    NVL2(mentor_id, 'Has Senior Mentor', 'Top Level Instructor') AS mentorship_status
FROM instructors;
*/

-- =============================================================================
-- 5. Oracle Hierarchical Queries: CONNECT BY PRIOR
-- =============================================================================
-- In Oracle, hierarchical tree queries can be written using native CONNECT BY syntax
-- in addition to recursive CTEs:

/*
SELECT 
    LEVEL,
    LPAD(' ', 2 * (LEVEL - 1)) || first_name || ' ' || last_name AS hierarchy_tree,
    academic_rank
FROM instructors
START WITH mentor_id IS NULL                     -- Root condition
CONNECT BY PRIOR instructor_id = mentor_id       -- Parent-child link
ORDER SIBLINGS BY first_name;
*/

-- =============================================================================
-- 6. Practice Questions
-- =============================================================================
-- Exercise 1: Why does Oracle distinguish between VARCHAR and VARCHAR2?
-- Exercise 2: How does Oracle's CONNECT BY PRIOR compare with standard ANSI recursive CTEs?
