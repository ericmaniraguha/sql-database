"""
================================================================================
Topic: Connecting to PostgreSQL from Python and Running Queries
Objective: Open a connection with psycopg, run SELECT queries, read the rows
           as tuples or as dictionaries, and always close the connection.
Database: PostgreSQL (ulk_university_db) - Python 3.10+ with psycopg 3
Run:      python 01_connect_and_query.py
================================================================================
"""
from psycopg.rows import dict_row

from db import describe, get_connection, print_table, run, show


def main() -> None:
    # =========================================================================
    # 1. Open a Connection
    # =========================================================================
    # A connection is a session with the server, like one pgAdmin Query Tool tab.
    # The `with` block closes it at the end, even if an error happens.
    print(f"Connecting as {describe()} ...\n")

    with get_connection() as conn:

        # =====================================================================
        # 2. Who and Where Am I? (fetchone)
        # =====================================================================
        # A cursor sends SQL to the server and brings the results back.
        # fetchone() returns ONE row as a tuple, or None if there are no rows.
        with conn.cursor() as cur:
            cur.execute("SELECT current_database(), current_user, inet_server_port()")
            database, user, port = cur.fetchone()
            print(f"Connected to database '{database}' as '{user}' on port {port}.\n")

        # =====================================================================
        # 3. Many Rows (fetchall)
        # =====================================================================
        # Students per programme. fetchall() returns a list of tuples.
        with conn.cursor() as cur:
            cur.execute("""
                SELECT p.program_name, COUNT(s.student_id) AS students
                FROM programs p
                LEFT JOIN students s ON s.program_id = p.program_id
                GROUP BY p.program_id, p.program_name
                ORDER BY students DESC, p.program_name
            """)
            rows = cur.fetchall()                       # 5 rows
            print("Students per programme:")
            print_table(rows, [column.name for column in cur.description])
            # cur.description describes the result columns (name, type, ...)

        # =====================================================================
        # 4. Row by Row (iterating the cursor)
        # =====================================================================
        # For big results, loop over the cursor instead of loading everything
        # with fetchall(). Here: every lecturer with their department.
        with conn.cursor() as cur:
            cur.execute("""
                SELECT l.first_name || ' ' || l.last_name, d.department_name, l.monthly_salary
                FROM lecturers l
                JOIN departments d ON d.department_id = l.department_id
                ORDER BY l.monthly_salary DESC
            """)
            print("Lecturers by salary:")
            for name, department, salary in cur:        # one tuple per loop
                print(f"  {name:<22} {department:<24} {salary:>12,.2f} RWF")
            print()
            # salary arrives as a Python Decimal: exact money, never a float.

        # =====================================================================
        # 5. Rows as Dictionaries (dict_row)
        # =====================================================================
        # With row_factory=dict_row each row is a dict, so you read columns by
        # NAME (row["gpa"]) instead of by position (row[3]).
        with conn.cursor(row_factory=dict_row) as cur:
            cur.execute("""
                SELECT registration_no, student_name, gpa
                FROM student_gpa
                ORDER BY gpa DESC, student_name
                LIMIT 3
            """)
            print("Top 3 GPAs:")
            for row in cur.fetchall():
                print(f"  {row['registration_no']}  {row['student_name']:<20} GPA {row['gpa']}")
            print()

        # =====================================================================
        # 6. A Quick Way to Look at Any Result
        # =====================================================================
        # show() (from db.py) prints the rows with their column names.
        # conn.execute() is a shortcut that creates the cursor for you.
        print("Course offerings next term:")
        show(conn.execute("""
            SELECT c.course_code, c.course_title, COALESCE(o.room, 'TBA') AS room
            FROM course_offerings o
            JOIN courses c ON c.course_id = o.course_id
            WHERE o.term_id = 3
            ORDER BY c.course_code
        """))

    # Leaving the `with` block committed the (empty) transaction and closed
    # the connection. conn.closed is now True.
    print("Connection closed:", conn.closed)


# =============================================================================
# 7. Practice Exercises
# =============================================================================
# Exercise 1: Print the number of students in each status (Active, Graduated...).
# Exercise 2: Print every course with its department name, using dict_row and
#             reading the columns by name.
# Exercise 3: What does fetchone() return when the query finds no rows?
#             Try it with WHERE student_id = 999.

if __name__ == "__main__":
    run(main)
