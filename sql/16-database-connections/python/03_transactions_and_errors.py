"""
================================================================================
Topic: Transactions and Error Handling from Python
Objective: Understand how psycopg groups statements into transactions, commit
           and roll back from Python, catch database errors by type, and use
           savepoints so one failed step does not lose the others.
Database: PostgreSQL (ulk_university_db) - Python 3.10+ with psycopg 3
Run:      python 03_transactions_and_errors.py
NOTE:     Every change in this script is rolled back, so your sample data
          stays the same (see force_rollback below).
================================================================================
"""
from decimal import Decimal

import psycopg
from psycopg import errors

from db import get_connection, run


def balance(conn, invoice_id: int) -> Decimal:
    """Amount still owed on one invoice, read from the student_balances view."""
    return conn.execute(
        "SELECT balance_due FROM student_balances WHERE invoice_id = %s", (invoice_id,)
    ).fetchone()[0]


def record_payment(conn, invoice_id: int, amount: Decimal, method: str, reference: str | None) -> Decimal:
    """Insert a payment and refuse it if it would make the balance negative."""
    conn.execute(
        "INSERT INTO payments (invoice_id, payment_date, amount, payment_method, reference_no) "
        "VALUES (%s, CURRENT_DATE, %s, %s, %s)",
        (invoice_id, amount, method, reference),
    )
    new_balance = balance(conn, invoice_id)
    if new_balance < 0:
        # Raising inside a transaction block makes psycopg roll it back.
        raise ValueError(f"overpayment: balance would be {new_balance:,.2f}")
    return new_balance


def main() -> None:
    with get_connection() as conn:

        # =====================================================================
        # 1. How psycopg Handles Transactions
        # =====================================================================
        # - The first statement on a connection starts a transaction (BEGIN).
        # - Nothing is permanent until conn.commit().
        # - `with get_connection() as conn:` commits when the block ends
        #   normally and rolls back if an exception escapes it.
        # - `with conn.transaction():` makes one block atomic: COMMIT at the
        #   end, ROLLBACK if an exception is raised inside.
        # - force_rollback=True always rolls back: ideal for practising.
        print("Diane's invoice (5) before:", f"{balance(conn, 5):,.2f}")         # 700,000.00

        # =====================================================================
        # 2. A Successful Change (rolled back here only for practice)
        # =====================================================================
        with conn.transaction(force_rollback=True):
            new_balance = record_payment(conn, 5, Decimal("300000.00"), "Mobile Money", "MM-PY-0001")
            print("Inside the transaction, after paying 300,000:", f"{new_balance:,.2f}")   # 400,000.00
        print("After force_rollback:", f"{balance(conn, 5):,.2f}\n")             # 700,000.00
        # In a real program you would write `with conn.transaction():` and the
        # payment would be committed at the end of the block.

        # =====================================================================
        # 3. A Business Rule Fails: the Whole Block Is Undone
        # =====================================================================
        try:
            with conn.transaction():
                record_payment(conn, 5, Decimal("900000.00"), "Bank Transfer", "BK-PY-0002")
        except ValueError as problem:
            print("Payment refused:", problem)                                    # -200,000.00
        print("Balance unchanged:", f"{balance(conn, 5):,.2f}\n")

        # =====================================================================
        # 4. Catching Database Errors by Type
        # =====================================================================
        # Each constraint failure raises its own exception class, so a program
        # can react differently to each one. error.diag explains the details.
        attempts = [
            ("negative amount (CHECK)",
             "INSERT INTO payments (invoice_id, payment_date, amount, payment_method) "
             "VALUES (5, CURRENT_DATE, -100, 'Cash')"),
            ("student 1 already in offering 1 (UNIQUE)",
             "INSERT INTO enrollments (student_id, offering_id, enrollment_date) "
             "VALUES (1, 1, CURRENT_DATE)"),
            ("student 99 does not exist (FOREIGN KEY)",
             "INSERT INTO enrollments (student_id, offering_id, enrollment_date) "
             "VALUES (99, 1, CURRENT_DATE)"),
        ]
        for label, statement in attempts:
            try:
                with conn.transaction():
                    conn.execute(statement)
            except errors.CheckViolation as error:
                print(f"{label}: CheckViolation on {error.diag.constraint_name}")
            except errors.UniqueViolation as error:
                print(f"{label}: UniqueViolation on {error.diag.constraint_name}")
            except errors.ForeignKeyViolation as error:
                print(f"{label}: ForeignKeyViolation on {error.diag.constraint_name}")
        print()
        # All three are subclasses of psycopg.errors.IntegrityError, and every
        # database error is a psycopg.Error. Each error also has a 5-character
        # SQLSTATE code: error.sqlstate ('23514', '23505', '23503').

        # The connection is still usable: each failed block was rolled back.
        print("Still connected, students:", conn.execute("SELECT COUNT(*) FROM students").fetchone()[0])

        # =====================================================================
        # 5. Savepoints: Nested transaction() Blocks
        # =====================================================================
        # A transaction() inside another one becomes a SAVEPOINT. If the inner
        # block fails, only the inner work is undone (module 12, file 03).
        with conn.transaction(force_rollback=True):                       # outer
            conn.execute(
                "INSERT INTO enrollments (student_id, offering_id, enrollment_date) "
                "VALUES (15, 10, CURRENT_DATE)")                              # Belinda: ECO101
            try:
                with conn.transaction():                                  # inner = SAVEPOINT
                    conn.execute(
                        "INSERT INTO enrollments (student_id, offering_id, enrollment_date) "
                        "VALUES (15, 10, CURRENT_DATE)")                      # duplicate!
            except errors.UniqueViolation:
                print("Duplicate registration undone; the first one is kept.")
            kept = conn.execute(
                "SELECT COUNT(*) FROM enrollments WHERE student_id = 15").fetchone()[0]
            print("Belinda's enrollments inside the transaction:", kept)     # 1
        kept = conn.execute("SELECT COUNT(*) FROM enrollments WHERE student_id = 15").fetchone()[0]
        print("After force_rollback:", kept, "\n")                             # 0

    # =========================================================================
    # 6. Autocommit Mode
    # =========================================================================
    # With autocommit=True every statement is committed immediately, like the
    # default in pgAdmin. Needed for commands that refuse to run inside a
    # transaction, such as CREATE DATABASE or VACUUM.
    with get_connection(autocommit=True) as conn:
        print("Autocommit on, transaction status:", conn.info.transaction_status.name)   # IDLE


# =============================================================================
# 7. Practice Exercises
# =============================================================================
# Exercise 1: Write a function enrol(conn, student_id, offering_id) that inserts
#             the enrollment and prints a friendly message for UniqueViolation
#             and ForeignKeyViolation.
# Exercise 2: In one `with conn.transaction():` block, give two lecturers a raise.
#             Make the second UPDATE fail (negative salary). Is the first raise
#             kept? Why?
# Exercise 3: Change force_rollback=True to False in Section 2, run the script,
#             then check invoice 5 in pgAdmin. Run 00_master_schema_and_data.sql
#             afterwards to restore the sample data.

if __name__ == "__main__":
    run(main)
