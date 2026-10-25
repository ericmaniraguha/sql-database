"""
================================================================================
Topic: Reports with pandas
Objective: Load query results into pandas DataFrames through a SQLAlchemy
           engine, pass parameters safely, decide what to compute in SQL and
           what in pandas, and export a report to CSV.
Database: PostgreSQL (ulk_university_db) - Python 3.10+, pandas, SQLAlchemy
Run:      python 04_reports_with_pandas.py
Output:   output/outstanding_balances.csv (the folder is created if needed)
================================================================================
"""
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

from db import run, sqlalchemy_url

OUTPUT = Path(__file__).with_name("output")
pd.set_option("display.width", 120)


def main() -> None:
    # =========================================================================
    # 1. An Engine Instead of a Connection
    # =========================================================================
    # pandas talks to databases through SQLAlchemy. An engine holds the
    # connection settings and opens connections when needed.
    engine = create_engine(sqlalchemy_url())

    with engine.connect() as conn:

        # =====================================================================
        # 2. A Query Result as a DataFrame
        # =====================================================================
        gpa = pd.read_sql_query(
            text("SELECT registration_no, student_name, credits_attempted, gpa "
                 "FROM student_gpa ORDER BY gpa DESC, student_name"),
            conn,
        )
        print("GPA ranking:")
        print(gpa.head(5).to_string(index=False), "\n")
        print(f"{len(gpa)} students, average GPA {gpa['gpa'].mean():.2f}\n")     # 12 students

        # =====================================================================
        # 3. Parameters with pandas: :name placeholders
        # =====================================================================
        # With SQLAlchemy's text(), placeholders are written :name.
        # As in script 02: never build the SQL with f-strings.
        term = pd.read_sql_query(
            text("SELECT course_code, student_id, final_percent, letter_grade "
                 "FROM final_grades "
                 "WHERE academic_year = :year AND term_name = :term "
                 "ORDER BY course_code, final_percent DESC"),
            conn,
            params={"year": "2026/2027", "term": "Semester 1"},
        )
        print(f"Current-term results: {len(term)} rows")                       # 13 rows

        # =====================================================================
        # 4. Pivot: One Row per Student, One Column per Course
        # =====================================================================
        grid = term.pivot_table(index="student_id", columns="course_code",
                                values="final_percent")
        print(grid.to_string(na_rep="-"), "\n")
        # Reshaping like this is awkward in SQL and easy in pandas.

        # =====================================================================
        # 5. Aggregate in SQL or in pandas? Both give the same answer
        # =====================================================================
        # In SQL: the database sends back only 4 summary rows.
        in_sql = pd.read_sql_query(
            text("""
                SELECT p.program_name, SUM(sb.balance_due) AS outstanding
                FROM student_balances sb
                JOIN students s ON s.student_id = sb.student_id
                JOIN programs p ON p.program_id = s.program_id
                GROUP BY p.program_name
                ORDER BY outstanding DESC
            """),
            conn,
        )
        # In pandas: every invoice row is sent, then grouped in Python.
        rows = pd.read_sql_query(
            text("""
                SELECT p.program_name, sb.registration_no, sb.student_name,
                       sb.academic_year, sb.term_name, sb.total_billed,
                       sb.total_scholarships, sb.total_paid, sb.balance_due
                FROM student_balances sb
                JOIN students s ON s.student_id = sb.student_id
                JOIN programs p ON p.program_id = s.program_id
            """),
            conn,
        )
        in_pandas = (rows.groupby("program_name", as_index=False)["balance_due"].sum()
                         .rename(columns={"balance_due": "outstanding"})
                         .sort_values("outstanding", ascending=False))
        print("Outstanding fees per programme (SQL GROUP BY):")
        print(in_sql.to_string(index=False), "\n")
        same = in_sql.set_index("program_name")["outstanding"].sort_index().equals(
            in_pandas.set_index("program_name")["outstanding"].sort_index())
        print("pandas groupby gives the same totals:", same, "\n")             # True
        # Rule of thumb: filter and aggregate in SQL (less data to send);
        # use pandas for reshaping, charts and files.

        # =====================================================================
        # 6. Export a Report to CSV
        # =====================================================================
        owing = rows[rows["balance_due"] > 0].sort_values("balance_due", ascending=False)
        OUTPUT.mkdir(exist_ok=True)
        csv_path = OUTPUT / "outstanding_balances.csv"
        owing.to_csv(csv_path, index=False)
        print(f"Saved {len(owing)} invoices with a balance to {csv_path}")   # 10 invoices
        # The CSV opens directly in Excel or Google Sheets.

    engine.dispose()            # close every connection the engine opened


# =============================================================================
# 7. Practice Exercises
# =============================================================================
# Exercise 1: Load the salary_payments table and compute total net pay per
#             pay_month in pandas. Check the result with a SQL GROUP BY.
# Exercise 2: Save the GPA ranking from Section 2 to output/gpa_ranking.csv.
# Exercise 3: Make a pivot table of payments: rows = payment_method,
#             columns = month of payment_date, values = total amount.

if __name__ == "__main__":
    run(main)
