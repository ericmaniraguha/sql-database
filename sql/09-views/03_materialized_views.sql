/*
================================================================================
Topic: Materialized Views and Performance Caching
Objective: Understand physical query result caching with Materialized Views, 
           refresh strategies, and indexing analytical cache tables.
Database: PostgreSQL / Oracle (with MySQL simulation patterns)
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: Standard View vs Materialized View
-- =============================================================================
-- | Feature              | Standard View                    | Materialized View               |
-- |----------------------|----------------------------------|----------------------------------|
-- | Physical Storage     | None (query runs every time)     | Stores query results on disk    |
-- | Read Performance     | Can be slow for large joins/aggs | Extremely fast (like a table)    |
-- | Data Freshness       | Real-time (always latest data)   | Snapshot in time until refreshed |
-- | Indexing             | Cannot be indexed directly       | Can have secondary indexes!      |
-- | Native RDBMS Support | PostgreSQL, MySQL, Oracle        | PostgreSQL, Oracle (Not in MySQL)|

-- =============================================================================
-- 2. PostgreSQL / Oracle Materialized View Implementation
-- =============================================================================

/*
-- Create Materialized View for heavy analytical report
CREATE MATERIALIZED VIEW mv_student_transcript_summary AS
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    d.department_name,
    COUNT(e.enrollment_id)         AS total_courses,
    SUM(c.credits)                 AS total_credits_earned,
    ROUND(AVG(e.numeric_grade), 2) AS cumulative_average_grade
FROM students s
INNER JOIN departments d 
    ON s.department_id = d.department_id
LEFT JOIN enrollments e 
    ON s.student_id = e.student_id AND e.status = 'Completed'
LEFT JOIN courses c 
    ON e.course_id = c.course_id
GROUP BY s.student_id, s.first_name, s.last_name, d.department_name
WITH DATA;

-- Create an index directly on the Materialized View for lightning-fast lookups
CREATE UNIQUE INDEX idx_mv_student_id ON mv_student_transcript_summary(student_id);

-- Querying the materialized view (operates at physical disk read speed)
SELECT * 
FROM mv_student_transcript_summary 
WHERE cumulative_average_grade >= 85.00;

-- Refreshing the snapshot when underlying data changes:
-- Standard refresh:
REFRESH MATERIALIZED VIEW mv_student_transcript_summary;

-- Non-blocking concurrent refresh (requires UNIQUE index, supported in PostgreSQL):
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_student_transcript_summary;

-- Drop Materialized View:
DROP MATERIALIZED VIEW IF EXISTS mv_student_transcript_summary;
*/

-- =============================================================================
-- 3. Emulating Materialized Views in MySQL
-- =============================================================================
-- Since MySQL does not support CREATE MATERIALIZED VIEW natively, the common
-- pattern is to create a physical summary table refreshed via a stored procedure
-- or event scheduler:

CREATE TABLE IF NOT EXISTS summary_student_transcripts (
    student_id          INT PRIMARY KEY,
    student_name        VARCHAR(120),
    department_name     VARCHAR(100),
    total_courses       INT,
    cumulative_avg      DECIMAL(5, 2),
    last_refreshed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stored procedure to refresh the summary table (replaces REFRESH MATERIALIZED VIEW):
/*
DELIMITER //
CREATE PROCEDURE refresh_student_transcripts_cache()
BEGIN
    TRUNCATE TABLE summary_student_transcripts;
    
    INSERT INTO summary_student_transcripts (student_id, student_name, department_name, total_courses, cumulative_avg, last_refreshed_at)
    SELECT 
        s.student_id,
        CONCAT(s.first_name, ' ', s.last_name),
        d.department_name,
        COUNT(e.enrollment_id),
        ROUND(AVG(e.numeric_grade), 2),
        NOW()
    FROM students s
    INNER JOIN departments d ON s.department_id = d.department_id
    LEFT JOIN enrollments e ON s.student_id = e.student_id AND e.status = 'Completed'
    GROUP BY s.student_id, s.first_name, s.last_name, d.department_name;
END //
DELIMITER ;
*/

-- =============================================================================
-- 4. Practice Questions
-- =============================================================================
-- Exercise 1: Why is REFRESH MATERIALIZED VIEW CONCURRENTLY preferable in 24/7 web applications?
-- Exercise 2: Name two real-world business scenarios where a stale Materialized View is 
--             acceptable, and one scenario where it is NOT acceptable.
