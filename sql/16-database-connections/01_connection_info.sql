/*
================================================================================
Topic: Inspecting Your Database Connection
Objective: Find out which server, database and user a session is connected
           to, see the other open connections, and read the server settings
           that control connections.
Database: PostgreSQL (pgAdmin, psql, or any client)
          MySQL: SELECT DATABASE(), USER(), @@port;  SHOW PROCESSLIST;
          Oracle: SELECT SYS_CONTEXT('USERENV', 'DB_NAME'), USER FROM dual;
================================================================================
*/

-- =============================================================================
-- 1. Concept Overview: What Is a Connection?
-- =============================================================================
-- A client program (pgAdmin, psql, DBeaver, a Python script) opens a network
-- connection to the PostgreSQL SERVER, logs in as a ROLE (user), and works in
-- ONE database. That connection is a SESSION: it has its own transaction,
-- its own settings, and its own server process.
--
-- Every connection needs five values:
--   host      where the server runs          localhost (your own computer)
--   port      which door on that host         5432 (PostgreSQL's default)
--   database  which database on the server    ulk_university_db
--   user      who you log in as               ulk_admin or postgres
--   password  proof that you are that user


-- =============================================================================
-- 2. Who and Where Am I?
-- =============================================================================
SELECT
    current_database()               AS database,
    current_user                     AS logged_in_as,
    inet_server_addr()               AS server_address,   -- NULL over a local socket
    inet_server_port()               AS server_port,
    inet_client_addr()               AS my_address,
    pg_backend_pid()                 AS my_server_process,
    current_setting('application_name') AS application;  -- e.g. 'pgAdmin 4 - CONN:...'

SELECT version();                    -- the exact PostgreSQL version


-- =============================================================================
-- 3. Who Else Is Connected?
-- =============================================================================
-- pg_stat_activity has one row per open connection. Open a second pgAdmin
-- tab or run a Python script from this module and watch new rows appear.
SELECT
    pid,
    usename          AS user_name,
    datname          AS database,
    application_name,
    client_addr,
    state,                           -- active, idle, idle in transaction ...
    backend_start    AS connected_since
FROM pg_stat_activity
WHERE datname = current_database()
ORDER BY backend_start;
-- 'idle in transaction' means a session ran BEGIN and has not finished:
-- it may be holding locks that make other users wait (module 12).


-- =============================================================================
-- 4. Settings That Control Connections
-- =============================================================================
SHOW port;                           -- 5432
SHOW max_connections;                -- connections the whole server accepts (default 100)
SHOW listen_addresses;               -- 'localhost' = only programs on this computer,
                                     -- '*' = any network address (pg_hba.conf then
                                     -- decides who may log in, see Section 6)

-- Connection limits per database and per role (-1 = no limit)
SELECT datname, datconnlimit
FROM pg_database
WHERE datname = current_database();

SELECT rolname, rolcanlogin, rolconnlimit
FROM pg_roles
WHERE rolname IN ('postgres', 'ulk_admin');


-- =============================================================================
-- 5. What May This User Do Here?
-- =============================================================================
-- Run these to diagnose "permission denied" errors (see the README's
-- troubleshooting table).
SELECT
    has_database_privilege(current_user, current_database(), 'CONNECT') AS can_connect,
    has_schema_privilege(current_user, 'public', 'USAGE')               AS can_use_schema,
    has_table_privilege(current_user, 'public.students', 'SELECT')      AS can_read_students,
    has_table_privilege(current_user, 'public.payments', 'INSERT')      AS can_add_payments;


-- =============================================================================
-- 6. Administrator Only (reference, run as postgres)
-- =============================================================================
-- Where the login rules (pg_hba.conf) live, and what they say:
--   SHOW hba_file;
--   SELECT type, database, user_name, address, auth_method FROM pg_hba_file_rules;
-- auth_method 'scram-sha-256' asks for a password; 'trust' lets anyone on that
-- address in WITHOUT a password (fine on a personal laptop, never on a server).
--
-- End another session (for example one stuck 'idle in transaction'):
--   SELECT pg_terminate_backend(<pid>);


-- =============================================================================
-- 7. Practice Exercises
-- =============================================================================
-- Exercise 1: Connect once with pgAdmin and once with psql. Compare the
--             application_name and my_server_process values of the two sessions.
-- Exercise 2: Run python/01_connect_and_query.py and, while it runs (or right
--             after), query pg_stat_activity. Which application_name does the
--             script use? (Hint: look in python/db.py.)
-- Exercise 3: Create a role ulk_reader that can LOGIN and only SELECT. Connect
--             as ulk_reader and try an UPDATE. What error do you get?
