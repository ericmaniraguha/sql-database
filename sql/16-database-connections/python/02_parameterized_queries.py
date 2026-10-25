"""
================================================================================
Topic: Parameterized Queries and SQL Injection
Objective: Pass values to SQL safely with %s and %(name)s placeholders, see how
           gluing user input into SQL text lets an attacker change the query,
           and build dynamic column names safely with psycopg.sql.
Database: PostgreSQL (ulk_university_db) - Python 3.10+ with psycopg 3
Run:      python 02_parameterized_queries.py            (uses 2024CS001)
          python 02_parameterized_queries.py 2023CS014  (any registration no)
================================================================================
"""
import sys
from datetime import date

from psycopg import sql

from db import get_connection, print_table, run, show


def main() -> None:
    registration_no = sys.argv[1] if len(sys.argv) > 1 else "2024CS001"

    with get_connection() as conn:

        # =====================================================================
        # 1. The Dangerous Way: Gluing Input into the SQL Text
        # =====================================================================
        # Imagine a web form where a student types their registration number.
        # An attacker types this instead:
        typed = "nobody' OR '1'='1"

        unsafe_sql = f"SELECT registration_no, first_name, last_name FROM students WHERE registration_no = '{typed}'"
        print("The query the program built:\n ", unsafe_sql, "\n")
        # The quote in the input ENDS the string early, and OR '1'='1' is
        # always true, so the WHERE clause no longer filters anything.
        rows = conn.execute(unsafe_sql).fetchall()
        print(f"Unsafe query returned {len(rows)} rows: every student's data leaked!\n")   # 15

        # =====================================================================
        # 2. The Safe Way: Placeholders
        # =====================================================================
        # Write %s where a value goes and pass the values separately. psycopg
        # sends them to the server apart from the SQL, so they can never
        # become SQL code. NEVER use f-strings or + to put values in SQL.
        safe_sql = "SELECT registration_no, first_name, last_name FROM students WHERE registration_no = %s"
        rows = conn.execute(safe_sql, (typed,)).fetchall()
        print(f"Safe query with the attack text returned {len(rows)} rows.\n")             # 0
        # Note: (typed,) is a tuple with ONE value; the comma is required.

        # The same safe query with a real registration number:
        student = conn.execute(safe_sql, (registration_no,)).fetchone()
        if student is None:
            print(f"No student has registration number {registration_no}.\n")
            return
        print(f"Found student: {student[1]} {student[2]} ({student[0]})\n")

        # =====================================================================
        # 3. Named Placeholders: %(name)s with a Dictionary
        # =====================================================================
        # Clearer when a query has several values.
        print(f"Transcript for {registration_no}:")
        show(conn.execute(
            """
            SELECT fg.academic_year, fg.term_name, fg.course_code,
                   fg.final_percent, fg.letter_grade
            FROM final_grades fg
            JOIN students s ON s.student_id = fg.student_id
            WHERE s.registration_no = %(reg)s
              AND fg.final_percent >= %(min_percent)s
            ORDER BY fg.academic_year, fg.course_code
            """,
            {"reg": registration_no, "min_percent": 0},
        ))

        # =====================================================================
        # 4. A List of Values: = ANY(%s)
        # =====================================================================
        # Pass a Python list; PostgreSQL receives it as an array.
        wanted = ["CS101", "MATH110", "ACC101"]
        print("Courses from a Python list:")
        show(conn.execute(
            "SELECT course_code, course_title, credits FROM courses "
            "WHERE course_code = ANY(%s) ORDER BY course_code",
            (wanted,),
        ))

        # =====================================================================
        # 5. LIKE Searches: the % Wildcards Go INSIDE the Value
        # =====================================================================
        search = "data"
        print(f"Course titles containing '{search}':")
        show(conn.execute(
            "SELECT course_code, course_title FROM courses "
            "WHERE course_title ILIKE %s ORDER BY course_code",
            (f"%{search}%",),           # the value is '%data%'; the SQL keeps %s
        ))

        # =====================================================================
        # 6. Python Types In, Python Types Out
        # =====================================================================
        # Dates and numbers keep their real types in both directions:
        # date -> DATE, Decimal <- DECIMAL(12,2), None <-> NULL.
        row = conn.execute(
            "SELECT payment_date, amount, reference_no FROM payments "
            "WHERE payment_date >= %s ORDER BY payment_date, payment_id LIMIT 1",
            (date(2026, 9, 1),),
        ).fetchone()
        print("First payment since 1 Sept 2026:", row)
        print("Python types:", [type(value).__name__ for value in row], "\n")
        # -> ['date', 'Decimal', 'str']

        # =====================================================================
        # 7. Table and Column Names Cannot Be Parameters
        # =====================================================================
        # %s is only for VALUES. To let a user choose the sort column, accept
        # only names from a fixed list and build the SQL with psycopg.sql,
        # which quotes identifiers safely.
        allowed = {"gpa", "student_name", "credits_attempted"}
        sort_by = "credits_attempted"                     # e.g. from a dropdown
        if sort_by not in allowed:
            raise ValueError(f"cannot sort by {sort_by!r}")
        query = sql.SQL("SELECT student_name, credits_attempted, gpa FROM student_gpa "
                        "ORDER BY {} DESC, student_name LIMIT 5").format(sql.Identifier(sort_by))
        print("Query built with psycopg.sql:", query.as_string(conn))
        cur = conn.execute(query)
        print_table(cur.fetchall(), [column.name for column in cur.description])


# =============================================================================
# 8. Practice Exercises
# =============================================================================
# Exercise 1: Ask the user for a course code with input() and print every
#             student who took that course, using a %s placeholder.
# Exercise 2: Print the payments between two dates given as Python date objects.
# Exercise 3: Run section 1 with typed = "x'; DROP TABLE students; --" and read
#             the SQL it builds. Why is that dangerous? Why is %s safe?

if __name__ == "__main__":
    run(main)
