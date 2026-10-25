/*
================================================================================
Topic: Materialized Views
Objective: Store the result of a heavy query on disk, index it, see it go
           stale, and refresh it (normally and CONCURRENTLY).
Database: PostgreSQL (pgAdmin)
          Oracle: CREATE MATERIALIZED VIEW (refresh with DBMS_MVIEW.REFRESH)
          MySQL: no materialized views; see Section 6 for the usual workaround
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: View vs. Materialized View
-- =============================================================================
-- | Feature        | View                         | Materialized view               |
-- |----------------|------------------------------|---------------------------------|
-- | Stores data?   | No: the query runs each time | Yes: the result is saved on disk|
-- | Read speed     | As slow as its query         | Fast, like reading a table      |
-- | Freshness      | Always up to date            | A snapshot: stale until REFRESH |
-- | Indexes        | Not possible                 | Possible                        |
--
-- Use one for expensive reports that may be a little out of date: dashboards,
-- end-of-term statistics, nightly finance summaries.


-- =============================================================================
-- 2. Creating a Materialized View
-- =============================================================================
-- This section is wrapped in BEGIN ... COMMIT so that the ROLLBACK in
-- Section 3 cannot undo it, even when pgAdmin runs the whole file at once.
BEGIN;

DROP MATERIALIZED VIEW IF EXISTS mv_course_results;   -- safe to re-run

-- Class results per course and term (built on the final_grades view)
CREATE MATERIALIZED VIEW mv_course_results AS
SELECT
    course_code,
    academic_year,
    term_name,
    COUNT(*)                     AS students,
    ROUND(AVG(final_percent), 1) AS class_average,
    MAX(final_percent)           AS best_result,
    ROUND(100.0 * SUM(CASE WHEN letter_grade <> 'F' THEN 1 ELSE 0 END)
          / COUNT(*), 0)         AS pass_rate_percent
FROM final_grades
GROUP BY course_code, academic_year, term_name
WITH DATA;                       -- fill it now (WITH NO DATA = create empty)

-- A UNIQUE index: speeds up lookups and is required for CONCURRENTLY (Section 4)
CREATE UNIQUE INDEX ux_mv_course_results
    ON mv_course_results (course_code, academic_year, term_name);

COMMIT;

SELECT *
FROM mv_course_results
ORDER BY academic_year, course_code;              -- 8 rows


-- =============================================================================
-- 3. Watching It Go Stale, Then Refreshing
-- =============================================================================
-- Patrick's CS101 exam is re-marked from 45 to 75 (his result becomes 65 %, C).
BEGIN;
    UPDATE assessment_scores
    SET score = 75
    WHERE enrollment_id = 6
      AND assessment_id = 3;

    -- The normal view sees the change immediately: pass rate is now 80 %
    SELECT course_code,
           ROUND(100.0 * SUM(CASE WHEN letter_grade <> 'F' THEN 1 ELSE 0 END)
                 / COUNT(*), 0) AS live_pass_rate
    FROM final_grades
    WHERE course_code = 'CS101' AND academic_year = '2026/2027'
    GROUP BY course_code;

    -- The materialized view still shows the old snapshot: 60 %
    SELECT course_code, pass_rate_percent AS stored_pass_rate
    FROM mv_course_results
    WHERE course_code = 'CS101' AND academic_year = '2026/2027';

    -- Re-run the stored query and replace the snapshot
    REFRESH MATERIALIZED VIEW mv_course_results;

    SELECT course_code, pass_rate_percent AS stored_pass_rate
    FROM mv_course_results
    WHERE course_code = 'CS101' AND academic_year = '2026/2027';   -- now 80 %
ROLLBACK;   -- undoes the re-mark AND the refresh


-- =============================================================================
-- 4. REFRESH ... CONCURRENTLY
-- =============================================================================
-- A plain REFRESH locks the materialized view: nobody can read it until the
-- refresh finishes. CONCURRENTLY builds the new result on the side and lets
-- readers keep using the old one meanwhile. It needs a UNIQUE index on the
-- materialized view, and it is slower than a plain refresh.
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_course_results;

-- Typical scheduling: refresh every night with a job (cron, pgAgent) or right
-- after the exam board publishes results.


-- =============================================================================
-- 5. Inspecting and Dropping
-- =============================================================================
SELECT matviewname, ispopulated
FROM pg_matviews
WHERE schemaname = 'public';

-- Clean up (remove this line to keep the materialized view):
DROP MATERIALIZED VIEW IF EXISTS mv_course_results;


-- =============================================================================
-- 6. MySQL: Emulating a Materialized View (reference only, MySQL syntax)
-- =============================================================================
-- MySQL has no CREATE MATERIALIZED VIEW. The usual pattern is a summary TABLE
-- that a scheduled procedure empties and refills:
/*
CREATE TABLE summary_course_results (
    course_code       VARCHAR(10),
    academic_year     VARCHAR(9),
    term_name         VARCHAR(20),
    students          INT,
    class_average     DECIMAL(5,1),
    refreshed_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (course_code, academic_year, term_name)
);

DELIMITER //
CREATE PROCEDURE refresh_summary_course_results()
BEGIN
    TRUNCATE TABLE summary_course_results;
    INSERT INTO summary_course_results (course_code, academic_year, term_name, students, class_average)
    SELECT course_code, academic_year, term_name, COUNT(*), ROUND(AVG(final_percent), 1)
    FROM final_grades
    GROUP BY course_code, academic_year, term_name;
END //
DELIMITER ;

-- Run it every night with the event scheduler:
CREATE EVENT ev_refresh_course_results
ON SCHEDULE EVERY 1 DAY
DO CALL refresh_summary_course_results();
*/


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Create a materialized view mv_department_payroll with the total
--             gross and net pay per department and pay_month. Add a UNIQUE index.
-- Exercise 2: Why is REFRESH ... CONCURRENTLY better for a website that is used
--             24 hours a day?
-- Exercise 3: Give two situations where a slightly stale materialized view is
--             acceptable, and one where it is not.
